//
//  Constant.swift
//  DCSTecorbHyperPay
//
//  Created by Dinesh Saini on 13/03/23.
//

import UIKit
import ipworks3ds_sdk
import Foundation
import Alamofire


let isDebugEnabled = true

struct HyperPayConfig {
    static var paymentDebug:Bool{
        if isDebugEnabled{
            if ServerConfig.shared.selectedServerConfigPaymentMode == .test{return true}
            else{return false}
        }
        else{
            return false
        }
    }
    static let providerMode: OPPProviderMode = paymentDebug ?  .test : .live
    static let visaAndMasterEntityId = paymentDebug ? "Write your visa master test entity id " : "Write your visa master live entity id"
    static let madaEntityId = paymentDebug ? "Write your mada test entity ID" : "Write your mada live entity ID"
    static let applePayEntityId = paymentDebug ? "Write your Apple test entity ID" : "Write your Apple live entity ID"
    static let applePayMerchantId = paymentDebug ? "Write your Apple test merchant ID" : "Write your Apple live merchant ID"
    static let checkoutURL = paymentDebug ? "https://test.oppwa.com" : "https://oppwa.com"
    static let requestPaymentStatusURL = paymentDebug ? "https://test.oppwa.com" : "https://oppwa.com"
    static let asyncPaymentCompletedNotificationKey = "AsyncPaymentCompletedNotificationKey"
    static let urlScheme = "com.tecorb"
    static let mainColor: UIColor = UIColor.init(red: 10.0/255.0, green: 134.0/255.0, blue: 201.0/255.0, alpha: 1.0)
    static let transactionExt = paymentDebug ? "_D" :  "_P"
    static let paymentStatusCheckingInterval = 2.0
    static func getOPPThreeDSConfig() -> OPPThreeDSConfig{
        let config = OPPThreeDSConfig()
        config.appBundleID = "tecorb.DCSTecorbHyperPay"
        
        let uiCustomization = ipworks3ds_sdk.UiCustomization()
        let height = UIScreen.main.bounds.size.width*90/750
        let cornerRadius = 6 //Int(height/8)
        
        let toolBarCustom = uiCustomization.getToolbarCustomization()
        toolBarCustom.setTextColor(color: .red)
        toolBarCustom.setBackgroundColor(color: UIColor.white)
        try? toolBarCustom.setHeaderText(headerText: "Pay Now")
        
        
        let submitButton = uiCustomization.getButtonCustomization(buttonType: .SUBMIT)
        submitButton.setTextColor(color: UIColor.white)
        submitButton.setBackgroundColor(color: .red)
        try? submitButton.setHeight(height: height)
        try? submitButton.setCornerRadius(cornerRadius: cornerRadius)
        
        let nextButton = uiCustomization.getButtonCustomization(buttonType: .NEXT)
        nextButton.setTextColor(color: UIColor.white)
        nextButton.setBackgroundColor(color: .red)
        try? nextButton.setHeight(height: height)
        try? nextButton.setCornerRadius(cornerRadius: cornerRadius)
        
        let resendButton = uiCustomization.getButtonCustomization(buttonType: .RESEND)
        try? resendButton.setHeight(height: height)
        try? resendButton.setCornerRadius(cornerRadius: cornerRadius)
        resendButton.setPadding(edge: UIEdgeInsets(top: 0, left: 32.5, bottom: 0, right: 32.5))
        
        let textField = uiCustomization.getTextBoxCustomization()
        textField.setBorderColor(color: .lightGray)
        try? textField.setCornerRadius(cornerRadius: cornerRadius)
        try? textField.setBorderWidth(borderWidth: 1)
        
        let cancelButton = uiCustomization.getButtonCustomization(buttonType: .CANCEL)
        cancelButton.setTextColor(color: .red)
        try? cancelButton.setHeight(height: height)
        
        config.uiCustomization = uiCustomization
        return config
    }
    static func initialize3DSecure(){
        if paymentDebug{
            let DS_ENCRYPT_CERT = """
        -----BEGIN CERTIFICATE-----
            MIICqjCCAZKgAwIBAgIBATANBgkqhkiG9w0BAQsFADAaMRgwFgYDVQQDEw9uc29mdHdhcmUu
            RFMuQ0EwHhcNMTkwOTI2MDYyODAzWhcNMjkwOTIzMDYyODAzWjAXMRUwEwYDVQQDEwxuc29m
            dHdhcmUuRFMwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCr4I/vgMlFLpwVY+de
            6YTtpyMtFzRIriZ+bmqmaML+qz49HvKO4+2lrZC1sBo74xPbupq7Zfq5c4UWbyGIjqNWdNKa
            XsSJz+RKyjCaNEF6B3rBeltaeBXuJVZ+oF+Q4zt0UI2WFSY4iE67babR0ep3/GNdSEQKHIV9
            oHI1cJsE9/qDrrPqzQnpPI+FdyyEqhi2TfiyWv3kzrEO6Rfxnqila5k5UXLUjrej1gwnhgbs
            Bp+EADxRmcJcmcnWsPOqBgyLthXlFv13f9PZIuDiRIBYqEV9SZZtgr/lBEnYkUb5jaYQd6+n
            YXZ7Q0+kdxDYLS0crrBgaRFdcsJgVimni7JTAgMBAAEwDQYJKoZIhvcNAQELBQADggEBAH65
            NrUSJzDZqcsdsbH3igZQdDetM0IEKOFrunYA0XR4F+aViHOtExoM8FRFYWexxyU85UY8gRin
            eJLkR379JCWVqMNholDWLpT9SYCN8q1eGFJpCT46vB0qxvQ25V71KWKp78uDfAlgJ4Hm0sUa
            yP22oMFZQ9lgAygWG9TR4wkG+KFz/R0LzeXK3V+yJpN9IxG0VCbTF1RIlZp0p77gI7hXWuk+
            ATJeKSbbT89KChbR4VKJesGfZ5VEKmnR2npK/mfSY7qtRH7Ha7zDG8CArX4qiFkX7UfwFcj7
            FmXgZrNTvx5AUJ/XYXz71AE8v1uYyzM5kZuXoyAxXXskb7Rji4s=
            -----END CERTIFICATE-----
        """
            let DS_ROOT_CA_CERT = """
        -----BEGIN CERTIFICATE-----
        MIICrjCCAZagAwIBAgICAN4wDQYJKoZIhvcNAQELBQAwGjEYMBYGA1UEAxMPbnNvZnR3YXJl
        LkRTLkNBMB4XDTE5MDkyNjA2Mjc1NVoXDTI5MDkyMzA2Mjc1NVowGjEYMBYGA1UEAxMPbnNv
        ZnR3YXJlLkRTLkNBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAzqLKOH7g1+Y5
        2wrWnI+n0/XywW3cJECSWT3li5dJiKepSKQ72ni5coZRCLklZaoNeMz9/WLg20fXpqV708zZ
        J6mCyS9art8DwK4i2u3StK5ehCBcz/YuX+C+jYySE2Zi6QxA4PC6UiR89aKoJKX+rJF8Bcys
        q7v5ky+embGCMpUU2jZ3GNKGeZXTqWlXY6verHVRoq3Ynn2In9D4r67CFQ1e3kfxEVWkr+WA
        Zsw/HSWq6u3OBnz7gwTCr4dqztMJIoYgKm70fzbmCr5uCdcSg5ix/GfmTfcTgB305qCjOJj3
        d/BiVl5bV5ORtGnFB7caJ/aXuRNv5gPaigpBAMUzFwIDAQABMA0GCSqGSIb3DQEBCwUAA4IB
        AQDDgjtqXF8D3C9oBS5t2ydjLdswDj+goTadXNNu+P90kJcWVnGFR6D/z2FUvHRD4QEI1QTV
        r5VIy/GDZZ2fFCk9tEWjNbWDBEwxSWNxtMX7m7eTRtWlOBIm4AJOmmoNHj3jTQcxzAmQmHAr
        yuNvk4r43UdjDo/kKQXEo3W0D4mULrbQBman5FcO3vOuc4PMKLZd3SCrHg5g8Novx8zSkkrm
        7/2P3iMxwYMydgioWejVHJgbS0lOum/eIVjHe2zp+FReIQ8yVoQXbAQuyHzZ5c6QuXCbRn/S
        PGkMeXLzbqDh3Oo2vQjoZ3JX17X/jcySnWxGL0RyOZwWBzivSig4NDBE
        -----END CERTIFICATE-----
        """
            let visaSchemeConfig = OPPThreeDSSchemeConfig(dsRefId: "TEST_VISA_DS_ID",
                                                          dsEncryptCert: DS_ENCRYPT_CERT,
                                                          dsCaRootCert: DS_ROOT_CA_CERT)
            
            let masterCardSchemeConfig = OPPThreeDSSchemeConfig(dsRefId: "TEST_MASTERCARD_DS_ID",
                                                                dsEncryptCert: DS_ENCRYPT_CERT,
                                                                dsCaRootCert: DS_ROOT_CA_CERT)
            
            let madaCardSchemeConfig = OPPThreeDSSchemeConfig(dsRefId: "TEST_MADA_DS_ID",
                                                              dsEncryptCert: DS_ENCRYPT_CERT,
                                                              dsCaRootCert: DS_ROOT_CA_CERT)
            
            OPPThreeDSService.sharedInstance.setCustomSchemeConfig(["VISA": visaSchemeConfig, "MASTERCARD": masterCardSchemeConfig, "MADA": madaCardSchemeConfig])
            
            let paymentBrands = ["VISA", "MASTERCARD", "MADA"]
            OPPThreeDSService.sharedInstance.initialize(transactionMode: paymentDebug ? .test : .live, paymentBrands: paymentBrands)
        }
        
    }
}


enum ServerConfigPaymentMode:String{
    case test = "Test"
    case live = "Live"
    init(_ rawValue:String) {
        if rawValue.lowercased() == "Test".lowercased(){
            self = .test
        }else{
            self = .live
        }
    }
}

let kUserDefaults = UserDefaults.standard

class ServerConfig {
    static let shared = ServerConfig()
    fileprivate init() {}

    var selectedServerConfigPaymentMode: ServerConfigPaymentMode{
        get {
            let savedMode = kUserDefaults.string(forKey: "kSelectedServerConfigPaymentMode") ?? "Test"
            let result = ServerConfigPaymentMode(savedMode)
            return result
        }
        
        set(newSelectedServerConfigPaymentMode){
            kUserDefaults.set(newSelectedServerConfigPaymentMode.rawValue, forKey: "kSelectedServerConfigPaymentMode")
        }
    }
    
    var baseUrl: String{
        get {
            let savedUrl = kUserDefaults.string(forKey: "kBaseUrl") ?? "Write your server url here"//"https://dev.ejaro.com"
            return savedUrl
        }
        
        set(newBaseUrl){
            kUserDefaults.set(newBaseUrl, forKey: "kBaseUrl")
        }
    }
    
}

//let accessToken =  "eyJhbGciOiJIUzI1NiJ9.eyJpZCI6MTEsImVtYWlsIjoiaC5yYWhtYW5AZWphcm8uY29tIiwiZm5hbWUiOiJOQURFUiIsImxuYW1lIjoiUyIsImNyZWF0ZWRfYXQiOiIyMDE5LTA1LTMwIDE5OjU3OjI3ICswNTMwIiwic2Vzc2lvblRva2VuIjoiUWpadnhyRzhaeW9BQWdyVkVQWTZYZyJ9.Z5E2kkTSV-tfoeQbE2To_NBqZdoeqNBAHLpfr07chqs"

let udid = UIDevice.current.identifierForVendor?.uuidString ?? ""
func prepareHeader(withAuth:Bool, apiVersion:String? = "v1")-> HTTPHeaders{
        var header = HTTPHeaders()
        let accept = "application/json"
        let currentVersion = UIApplication.appVersion()
        header.add(HTTPHeader(name:"currentVersion", value:currentVersion))
        header.add(HTTPHeader(name:"deviceType", value:"ios"))
        header.add(HTTPHeader(name:"Accept", value:accept))
        header.add(HTTPHeader(name:"deviceToken", value:"__"))
        header.add(HTTPHeader(name:"language", value:"en"))
        header.add(HTTPHeader(name:"Timezone", value:TimeZone.current.identifier))
        header.add(HTTPHeader(name:"udid", value:udid))
        
        if withAuth{
            header.add(HTTPHeader(name:"accessToken", value:"Write  your access token here"))
        }
        
        let deviceModelName = UIDevice.current.model
        let systemNameAndVersion = UIDevice.current.systemName+" "+UIDevice.current.systemVersion
        let systemInfo = deviceModelName + ", " + systemNameAndVersion
    
        header.add(HTTPHeader(name:"systemInfo", value:systemInfo))
        header.add(HTTPHeader(name:"isDebug", value:isDebugEnabled.string))
    
        return header
}

extension LosslessStringConvertible {
    var string: String { return .init(self) }
}
extension UIApplication {
    class func appVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }

    class func appBuild() -> String {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    }
}



