//
//  RequestApi.swift
//  DCSTecorbHyperPay
//
//  Created by Dinesh Saini on 14/03/23.
//


import Foundation
import SwiftyJSON
import Alamofire


class RequestApi {

    static let sharedInstance = RequestApi()
    fileprivate  init() {}
    
    func getHyperPayCheckOutIDForTokenization(amount:Double, idOfPayingFor: String, payingMakingFor: String, cardBrand:String, _ completionBlock:@escaping (_ token: String?) -> Void){
        let head =  prepareHeader(withAuth: true)
        var param = Dictionary<String,String>()
        let entityId = cardBrand.lowercased() == "mada" ? HyperPayConfig.madaEntityId : HyperPayConfig.visaAndMasterEntityId
        param.updateValue(String(format: "%.2f", amount), forKey: "amount")
        param.updateValue(entityId, forKey: "entityId")
        if idOfPayingFor != ""{
            param.updateValue(idOfPayingFor, forKey: "payment_for_id")
        }
        param.updateValue(payingMakingFor, forKey: "payment_for")
        param.updateValue("Tim", forKey: "lname")
        param.updateValue("Aarav", forKey: "fname")
        param.updateValue("aarav@gmail.com", forKey: "email")
        
        let url = "Write your server url get for checkoutid "
        
        print("hitting \(url) with headers :\(head) and params: \(param)")

        AF.request(url, method: .post, parameters: param, headers: head).response { response in
            switch response.result {
            case .success:
                if let value = response.data{
                    let json = JSON(value)
                    print(" Checkout id Detail :\(json)")
                        completionBlock(json["result"]["id"].string)
                }else{
                    completionBlock(nil)
                }
            case .failure(let error):
                print(error.localizedDescription)
                completionBlock(nil)
            }
        }
    }
    
    
    func getRequestPaymentStaus(resourcePath: String,_ completionBlock:@escaping (_ staus: String?,_ resData:Dictionary<String,AnyObject>?,_ message:String) -> Void){
        
        let head =  prepareHeader(withAuth: true)
        let url = HyperPayConfig.requestPaymentStatusURL + resourcePath
        AF.request(url, method: .get, headers:head)
            .response { response in
            switch response.result {
            case .success:
                if let value = response.data {
                    let json = JSON(value)
                    print(" response payment status id Detail :\(json)")
                    completionBlock(json["result"]["code"].stringValue, json.dictionaryObject as Dictionary<String, AnyObject>?,json["result"]["description"].stringValue)
                }
                else{
                    completionBlock(nil, nil, response.error?.localizedDescription ?? "Some thing went wrong")
                }
            case .failure(let error):
                print(error.localizedDescription)
                completionBlock(nil,nil,error.localizedDescription)
            }
        }
    }
}
