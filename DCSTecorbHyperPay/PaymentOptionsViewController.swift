//
//  PaymentOptionsViewController.swift
//  DCSTecorbHyperPay
//
//  Created by Dinesh Saini on 15/03/23.
//

import UIKit

class PaymentOptionsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onClickHyperPay(_ sender:UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle:nil)
       let hyperVC = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.navigationController?.pushViewController(hyperVC, animated: true)

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
