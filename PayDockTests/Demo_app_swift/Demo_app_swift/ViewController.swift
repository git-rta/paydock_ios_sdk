//
//  ViewController.swift
//  Demo_app_swift
//
//  Created by Oleksandr Omelchenko on 18.10.17.
//  Copyright © 2017 Oleksandr Omelchenko. All rights reserved.
//

import UIKit
@testable import PayDock
class ViewController: UIViewController {
    @IBAction func DateChanged(_ sender: UITextField) {
        var nsText = expirationDateField.text!

        if ((nsText.count <= 2) && (nsText.contains("/"))){
            nsText = nsText.replacingOccurrences(of: String("/"), with: "")
            nsText = nsText.replacingOccurrences(of: String("0"), with: "")
            nsText.insert("0", at: nsText.index(nsText.startIndex, offsetBy: 0))
            expirationDateField.text = nsText
        }
        if (nsText.count >= 3){
            if (!nsText.contains("/")){
                nsText.insert("/", at: nsText.index(nsText.startIndex, offsetBy: 2))
                expirationDateField.text = nsText
            }
        }
        
//        if (nsText.count == 5){
//            let (monthString, yearString, validDateNumber) = checkDate(input: nsText as String)
//        }

        
        
    }
    
    @IBOutlet weak var cardNumberField: UITextField!
    @IBOutlet weak var cardHolderNameField: UITextField!
    @IBOutlet weak var expirationDateField: UITextField!
    @IBOutlet weak var ccvField: UITextField!
    @IBOutlet weak var lblVCardH: UILabel!
    @IBOutlet weak var lblVNo: UILabel!
    @IBOutlet weak var lblVdate: UILabel!
    @IBOutlet weak var lblVccv: UILabel!
    @IBOutlet weak var lblerr: UILabel!

    
   
    let gatewayId: String = "58d06b6a6529147222e4afa8"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
       
        
    }
    override func viewDidAppear(_ animated: Bool) {
//        let frameworkBundle = Bundle(identifier: "com.roundtableapps.PayDock")
//        let storyboard = UIStoryboard(name: "cardForm", bundle: frameworkBundle)
//        let CardFormVC = storyboard.instantiateViewController(withIdentifier: "CardFormViewController") as UIViewController
//
//        self.present(CardFormVC, animated: true, completion: nil)

        //Demo-app-swift
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func cardSubmitPressed(_ sender: Any) {
        clearErrors()        
        
        var valid = true
        
        let (type, formatted, validCardNumber) = checkCardNumber(input: cardNumberField.text!)
        let (monthString, yearString, validDateNumber) = checkDate(input: expirationDateField.text!)
        
        if (cardHolderNameField.text == "")
        {
            valid = false
            lblVCardH.text="Name is required";
        }
        
        if (validCardNumber == false)
        {
            valid = false
            lblVNo.text="card no is incorrect";
        }
        
        if (validDateNumber == false)
        {
            valid = false
            lblVdate.text="expiration Date Field value is required";
        }
        
        if (ccvField.text == "")
        {
            valid = false
            lblVccv.text="CCV is required";
        }
        
        
        if(valid){
            
            PayDock.setSecretKey(key: "")
            PayDock.setPublicKey(key: "8b2dad5fcf18f6f504685a46af0df82216781f3b")
            PayDock.shared.isSandbox = true
            
            let address = Address(line1: "one", line2: "two", city: "city", postcode: "1234", state: "state", country: "AU")
            let card = Card(gatewayId: gatewayId,
                            name: cardHolderNameField.text!,
                            number: cardNumberField.text!,
                            expireMonth: monthString,
                            expireYear: yearString,
                            ccv: ccvField.text,
                            address: address)
            let paymentSource = PaymentSource.card(value: card)
            let customerRequest = CustomerRequest(firstName: "Test_first_name",
                                                  lastName: "Test_last_name",
                                                  email: "Test@test.com",
                                                  reference: "customer Refrence",
                                                  phone: nil,
                                                  paymentSource: paymentSource)
            
            let tokenRequest = TokenRequest(customer: customerRequest,
                                            address: address,
                                            paymentSource: paymentSource)
            PayDock.shared.create(token: tokenRequest) { (token) in
                
                do {
                    let token: String = try token()
                    print(token)
                    self.lblerr.text = token
                } catch let error {
                    debugPrint(error)
                    self.lblerr.text = error.localizedDescription
                }
            }
        }
    }
    
    func clearErrors()
    {
        lblVCardH.text = ""
        lblVNo.text = ""
        lblVdate.text = ""
        lblVccv.text = ""
        lblerr.text = ""
    }

    
}

