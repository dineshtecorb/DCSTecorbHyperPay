//
//  ViewController.swift
//  DCSTecorbHyperPay
//
//  Created by Dinesh Saini on 09/03/23.
//

import UIKit
import SafariServices
import ipworks3ds_sdk
import Sentry

class ViewController: UIViewController,SFSafariViewControllerDelegate{
    
    
    @IBOutlet weak var CardNameTxt: UITextField!
    @IBOutlet weak var CardNumberTxt: BKCardNumberField!
    @IBOutlet weak var CVCNumberTxt: UITextField!
    @IBOutlet weak var ExpDateTxt: BKCardExpiryField!
    @IBOutlet weak var paymentBtn: UIButton!
    
    var provider: OPPPaymentProvider?
    var transaction: OPPTransaction?
    var safariVC: SFSafariViewController?
    var payingWithPreaddedCard = false
    var brand:String?
    var amount:Double = 20.00



    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.provider = OPPPaymentProvider.init(mode: HyperPayConfig.providerMode)
        self.provider?.threeDSEventListener = self
        
        CardNumberTxt.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        ExpDateTxt.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        CVCNumberTxt.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        CardNameTxt.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        self.validateAndConfigPayment()

    }


}

extension ViewController{
    func validateAndConfigPayment(){
        let shouldGoAhead = self.checkValidationForInputs()
        configPaymentButton(shouldGoAhead)
    }
    func configPaymentButton(_ shouldGoAhead:Bool){
        self.paymentBtn.backgroundColor = shouldGoAhead ? UIColor.red : UIColor.red.withAlphaComponent(0.4)
    }
    func checkValidationForInputs()->Bool{
        guard let cardNumber = self.CardNumberTxt.text else {
            return false
        }
        
        let isValidCard = OPPCardPaymentParams.isNumberValid(cardNumber, luhnCheck: true)
        if !isValidCard{
            return false
        }
        
        guard let cardbrand = self.CardNumberTxt.cardCompanyName else {
            return false
        }
        
        guard let expire = self.ExpDateTxt.text else {
            return false
        }
        
        let validateExp = self.validateExpMonthYear(exp: expire)
        if !validateExp.result{
            return false
        }
        
        guard let cvc = self.CVCNumberTxt.text else {
            return false
        }
        
        if !OPPCardPaymentParams.isCvvValid(cvc){
            return false
        }
        
        guard let cardName = self.CardNameTxt.text else {
            return false
        }
        
        if !OPPCardPaymentParams.isHolderValid(cardName){
            return false
        }
        
        let valid = self.validateParams(holderName: cardName, cardNumber: cardNumber.removeBlankSpace(), expireDate: expire, cvc: cvc, cardBrand: cardbrand)
        return valid.success
    }
    @IBAction func actionPayButton(_ button:UIButton){
        guard let cardNumber = self.CardNumberTxt.text else {
            self.showPaymentAlertPendingDetail("Please enter card Number!")
            return
        }
        let isValidCard = OPPCardPaymentParams.isNumberValid(cardNumber, luhnCheck: true)
        if !isValidCard{
            self.showPaymentAlertPendingDetail("Please enter a valid card number")
            return
        }
        guard let cardbrand = self.CardNumberTxt.cardCompanyName else {
            self.showPaymentAlertPendingDetail("We support Visa, Master and Mada")
            return
        }
        guard let expire = self.ExpDateTxt.text else {
            self.showPaymentAlertPendingDetail("Please enter expiry date Number!")
            return
        }
        let validateExp = self.validateExpMonthYear(exp: expire)
        if !validateExp.result{
            self.showPaymentAlertPendingDetail(validateExp.message)
            return
        }
        guard let cvc = self.CVCNumberTxt.text else {
            self.showPaymentAlertPendingDetail("Please enter CVC Number!")
            return
        }
        if !OPPCardPaymentParams.isCvvValid(cvc){
            self.showPaymentAlertPendingDetail("Please enter a valid CVC number")
            return
        }
        guard let cardName = self.CardNameTxt.text else {
            self.showPaymentAlertPendingDetail("Please enter card holder name!")
            return
        }
        if !OPPCardPaymentParams.isHolderValid(cardName){
            self.showPaymentAlertPendingDetail("Please enter a valid card holder name")
            return
        }
        let valid = self.validateParams(holderName: cardName, cardNumber: cardNumber.removeBlankSpace(), expireDate: expire, cvc: cvc, cardBrand: cardbrand)
        if !valid.success{
            self.showPaymentAlertPendingDetail(valid.message)
            return
        }
        let idPayingFor = ""
        let paymentMakingFor = "card"
        RequestApi.sharedInstance.getHyperPayCheckOutIDForTokenization(amount: self.amount, idOfPayingFor: idPayingFor, payingMakingFor: paymentMakingFor, cardBrand: cardbrand) {(checkOutID) in
            DispatchQueue.main.async {
                guard let checkoutID = checkOutID else {
                    self.showPaymentAlertPendingDetail("Checkout ID is empty")
                    return
                }
                guard let transaction = self.createTransaction(checkoutID: checkoutID) else {
                    return
                }
                self.provider?.submitTransaction(transaction){ (transaction, error) in
                    DispatchQueue.main.async {
                        self.handleTransactionSubmission(transaction: transaction, error: error)
                    }
                }
            }
        }
    }
    
    func showPaymentAlertPendingDetail(_ message:String) {
        let alert = UIAlertController(title: "HyperPay", message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .default){(action) in
            alert.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okayAction)
        self.present(alert, animated: true, completion: nil)
    }

    
    // MARK: - Fields validation
    func validateExpMonthYear(exp:String) -> (message:String, result:Bool){
        let updatExpire = exp.replacingOccurrences(of: "/", with: "")
        let newExpire = updatExpire.removeBlankSpace()
        if newExpire.count < 4{
            return("Invalid exp.", false)
        }
        
        let startIndex = newExpire.index(newExpire.startIndex, offsetBy: 0)
        let endIndex = newExpire.index(newExpire.startIndex, offsetBy: 1)
        
        let month = String(newExpire[startIndex...endIndex])
        if !OPPCardPaymentParams.isExpiryMonthValid(month){
            return("Invalid exp. month", false)
        }
        
        let ystartIndex = newExpire.index(newExpire.startIndex, offsetBy: 2)
        let yendIndex = newExpire.index(newExpire.startIndex, offsetBy: 3)
        let year = "20"+String(newExpire[ystartIndex...yendIndex])
        if !OPPCardPaymentParams.isExpiryYearValid(year){
            return("Invalid exp. year", false)
        }
        
        if OPPCardPaymentParams.isExpired(withExpiryMonth: month, andYear: year){
            return("Invalid exp.", false)
        }
        
        return("", true)
    }
    func validateParams(holderName:String, cardNumber:String,expireDate:String,cvc:String,cardBrand:String) -> (success:Bool,message:String){
        
        
        if cardBrand.count == 0{
            return(false,"Please select card brand!")
        }
        if cardNumber.count == 0{
            return (false,"Please enter card Number!")
        }
        
        
        if expireDate.count == 0{
            return (false,"Please enter expiry date!")
        }
        
        if cvc.count == 0{
            return (false,"Please enter CVC Number!")
        }
        
        if holderName.count == 0{
            return (false,"Please enter card holder name!")
        }
        
        return (true,"")
    }

    // MARK: - Payment helpers
    func createTransaction(checkoutID: String) -> OPPTransaction? {
        
        do{
            
            guard let cardNumber = self.CardNumberTxt.text else {
                self.showPaymentAlertPendingDetail("Please enter card Number!")
                return nil
            }
            
            guard let cardbrand = self.CardNumberTxt.cardCompanyName else {
                self.showPaymentAlertPendingDetail("Please select card brand!")

                return nil
            }
            
            guard let expire = self.ExpDateTxt.text else {
                self.showPaymentAlertPendingDetail("Please enter expiry date Number!")
                return nil
            }
            guard let cvc = self.CVCNumberTxt.text else {
                self.showPaymentAlertPendingDetail("Please enter CVC Number!")
                return nil
            }
            guard let cardName = self.CardNameTxt.text else {
                self.showPaymentAlertPendingDetail("Please enter card holder name!")
                return nil
            }
            
            let updatExpire = expire.replacingOccurrences(of: "/", with: "")
            let newExpire = updatExpire.removeBlankSpace()
            if newExpire.count < 4{
                return nil
            }
            
            let startIndex = newExpire.index(newExpire.startIndex, offsetBy: 0)
            let endIndex = newExpire.index(newExpire.startIndex, offsetBy: 1)
            
            let month = String(newExpire[startIndex...endIndex])
            
            let ystartIndex = newExpire.index(newExpire.startIndex, offsetBy: 2)
            let yendIndex = newExpire.index(newExpire.startIndex, offsetBy: 3)
            let year = String(newExpire[ystartIndex...yendIndex])
            let updateCardNumber = cardNumber.removeBlankSpace()
            let params = try OPPCardPaymentParams.init(checkoutID: checkoutID, paymentBrand: cardbrand, holder: cardName, number: updateCardNumber, expiryMonth: month, expiryYear: "20"+year, cvv: cvc)
            params.shopperResultURL = HyperPayConfig.urlScheme + "://payments"
            params.isTokenizationEnabled = true
            return OPPTransaction.init(paymentParams: params)
        } catch let error as NSError {
            self.showPaymentAlertPendingDetail(error.localizedDescription)
            SentrySDK.capture(error: error)
            return nil
        }
    }
    func handleTransactionSubmission(transaction: OPPTransaction?, error: Error?) {
        guard let transaction = transaction else {
            self.showPaymentAlertPendingDetail(error!.localizedDescription)
            return
        }
        
        self.transaction = transaction
        if transaction.type == .synchronous {
            // If a transaction is synchronous, just request the payment status
            self.requestPaymentStatus()
        } else if transaction.type == .asynchronous {
            // If a transaction is asynchronous, you should open transaction.redirectUrl in a browser
            // Subscribe to notifications to request the payment status when a shopper comes back to the app
            if let redirectURL = self.transaction?.redirectURL{
                NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveAsynchronousPaymentCallback), name: Notification.Name(rawValue: HyperPayConfig.asyncPaymentCompletedNotificationKey), object: nil)
                self.presenterURL(url: redirectURL)
            }
            else{
                self.showPaymentAlertPendingDetail("Redirect url is not valide")
                self.dismiss(animated: true, completion: nil)
            }
            
        } else {
            let message = error.debugDescription
            self.showPaymentAlertPendingDetail(message)
        }
    }
    func presenterURL(url: URL) {
        self.safariVC = SFSafariViewController(url: url)
        self.safariVC?.delegate = self;
        self.present(safariVC!, animated: true, completion: nil)
    }
    func requestPaymentStatus() {
        // You can either hard-code resourcePath or request checkout info to get the value from the server
        // * Hard-coding: "/v1/checkouts/" + checkoutID + "/payment"
        // * Requesting checkout info:
        
        guard let checkoutID = self.transaction?.paymentParams.checkoutID else {
            self.showPaymentAlertPendingDetail("Checkout ID is invalid")
            return
        }
        self.transaction = nil
        //AppSettings.shared.showLoader()
        self.provider!.requestCheckoutInfo(withCheckoutID: checkoutID) { (checkoutInfo, error) in
            DispatchQueue.main.async {
                guard let resourcePath = checkoutInfo?.resourcePath else {
                    self.showPaymentAlertPendingDetail("Checkout info is empty or doesn't contain resource path")
                    return
                }
                RequestApi.sharedInstance.getRequestPaymentStaus(resourcePath: resourcePath) { (resCode,response,message) in
                    DispatchQueue.main.async {
                        //AppSettings.shared.hideLoader()
                        if(resCode == "000.100.112" || resCode == "000.100.110" || resCode == "000.000.000" || resCode == "000.000.100" || resCode == "000.100.105" || resCode == "000.300.000") {
                            if let data = response as Dictionary<String,AnyObject>?{
                                print("\(data)")
                                let message = "WOW!\nPayment has succesfully Done\nThankyou!"
                                self.paymentSuccessAlert(message)
                            }
                            else{
                                self.showPaymentAlertPendingDetail(message)
                                let sentryMessage = message + "\n\n" + (response?.description ?? "")
                                SentrySDK.capture(message: sentryMessage)
                            }
                        }
                        else{
                            self.showPaymentAlertPendingDetail(message)
                            let sentryMessage = message + "\n\n" + (response?.description ?? "")
                            SentrySDK.capture(message: sentryMessage)
                        }
                    }
                }
            }
        }
    }
    
    
    func paymentSuccessAlert(_ message:String) {
        let alert = UIAlertController(title: "Tecorb HyperPay", message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .default){(action) in
            alert.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(okayAction)
        self.present(alert, animated: true, completion: nil)
    }

    
    // MARK: - Async payment callback
    @objc func didReceiveAsynchronousPaymentCallback() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: HyperPayConfig.asyncPaymentCompletedNotificationKey), object: nil)
        self.safariVC?.dismiss(animated: true, completion: {
            DispatchQueue.main.async {
                self.requestPaymentStatus()
            }
        })
    }
    // MARK: - Safari Delegate
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: HyperPayConfig.asyncPaymentCompletedNotificationKey), object: nil)
        controller.dismiss(animated: true) {
            DispatchQueue.main.async {
                self.requestPaymentStatus()
            }
        }
    }
}

extension ViewController: OPPThreeDSEventListener{
    // MARK: - OPPThreeDSEventListener methods
    func onThreeDSChallengeRequired(completion: @escaping (UINavigationController) -> Void) {
        completion(self.navigationController!)
    }
    func onThreeDSConfigRequired(completion: @escaping (OPPThreeDSConfig) -> Void) {
        let config = HyperPayConfig.getOPPThreeDSConfig()
        completion(config)
    }
}



extension ViewController: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString =  textField.text ?? ""
        guard let stringRange = Range(range, in: currentString) else { return true }
        let newString = currentString.replacingCharacters(in: stringRange, with: string)
        if let nkTextField = textField as? UITextField{
            let text = nkTextField.text
            let maxLenght = 4
            if text!.count <= maxLenght{
                self.validateAndConfigPayment()
                return newString.count <= maxLenght
            }
        }
        else if let cardNumberField = textField as? BKCardNumberField{
            guard let text = cardNumberField.text else{return true}
            let maxLenght = 19
            if text.count <= maxLenght{
                self.validateAndConfigPayment()
                return newString.count <= maxLenght
            }
        }
        self.validateAndConfigPayment()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.validateAndConfigPayment()
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.validateAndConfigPayment()
    }
    @IBAction func textChanged(_ textField: UITextField) {
        if let textField = textField as? BKCardNumberField{
            textField.updateCardLogoImage()
            let cardNumberDone = self.validateCardField()
            if cardNumberDone{
                textField.resignFirstResponder()
                self.ExpDateTxt.becomeFirstResponder()
            }
        }
        else if let textField = textField as? BKCardExpiryField{
            let expDone = self.validateExpField()
            if expDone{
                textField.resignFirstResponder()
                self.CVCNumberTxt.becomeFirstResponder()
            }
        }
        else if let textField = textField as? UITextField, textField == CVCNumberTxt{
            let cvvDone = self.validateCVVField()
            if cvvDone{
                textField.resignFirstResponder()
                self.CardNameTxt.becomeFirstResponder()
            }
        }
        self.validateAndConfigPayment()
    }
}
extension ViewController{
    func validateCardField()->Bool{
        guard let cardNumber = self.CardNumberTxt.text else {return false}
        if cardNumber.removingWhitespaces().count < 16{return false}
        let isValidCard = OPPCardPaymentParams.isNumberValid(cardNumber, luhnCheck: true)
        if !isValidCard{return false}
        guard let cardbrand = self.CardNumberTxt.cardCompanyName else {return false}
        if cardbrand.isEmpty{return false}
        return true
    }
    func validateExpField()->Bool{
        guard let expire = self.ExpDateTxt.text else {return false}
        let validateExp = self.validateExpMonthYear(exp: expire)
        return validateExp.result
    }
    func validateCardHolderField()->Bool{
        guard let cardName = self.CardNameTxt.text else {return false}
        if !OPPCardPaymentParams.isHolderValid(cardName){return false}
        return true
    }
    func validateCVVField()->Bool{
        guard let cvc = self.CVCNumberTxt.text else {return false}
        if cvc.count < 3{return false}
        if !OPPCardPaymentParams.isCvvValid(cvc){return false}
        return true
    }
    
}

extension String{
    func removingWhitespaces() -> String {
        let customCharSet = CharacterSet(charactersIn: " +-()")
        return components(separatedBy: customCharSet).joined()
    }
    
    func removeBlankSpace() -> String {
        let customCharSet = CharacterSet(charactersIn: " ")
        return components(separatedBy: customCharSet).joined()
    }
}


