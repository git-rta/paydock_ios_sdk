//
//  ViewController.swift
//  Demo_app_swift
//
//  Created by Oleksandr Omelchenko on 18.10.17.
//  Copyright © 2017 Oleksandr Omelchenko. All rights reserved.
//

import UIKit
@testable import PayDock
class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var cardSchemeImage: UIImageView!
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
    var autoInsertDateSlash = true
    var mCardType: CardType = .Unknown
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        cardNumberField.delegate = self
        expirationDateField.delegate = self
        ccvField.delegate = self
        
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
    
    @IBAction func cardNumberChanged(_ sender: UITextField) {
        let (cardType, _, cardValid) = checkCardNumber(input: cardNumberField.text!)
        mCardType = cardType
        switch cardType {
        case .Amex:
            cardSchemeImage.image = UIImage(named: "ic_amex")
            break
        case .Visa:
            cardSchemeImage.image = UIImage(named: "ic_visa")
            break
        case .MasterCard:
            cardSchemeImage.image = UIImage(named: "ic_mastercard")
            break
        case .Diners:
            cardSchemeImage.image = UIImage(named: "ic_diners")
            break
        case .UnionPay:
            cardSchemeImage.image = UIImage(named: "ic_cup")
            break
        default:
            cardSchemeImage.image = UIImage(named: "ic_default")
            break
        }
        
        if (cardValid) {
            self.cardHolderNameField.becomeFirstResponder()
        }
    
    }
    
    @IBAction func DateChanged(_ sender: UITextField) {
        var nsText = expirationDateField.text!
        
        if ((nsText.count <= 2) && (nsText.contains("/"))){
            nsText = nsText.replacingOccurrences(of: String("/"), with: "")
            nsText = nsText.replacingOccurrences(of: String("0"), with: "")
            nsText.insert("0", at: nsText.index(nsText.startIndex, offsetBy: 0))
            expirationDateField.text = nsText
        }
        if ((nsText.count >= 2) && (nsText.count < 5) && (!nsText.contains("/")) && autoInsertDateSlash ){
            nsText.insert("/", at: nsText.index(nsText.startIndex, offsetBy: 2))
            expirationDateField.text = nsText
        }
        
        if (nsText.count == 5){
            let (_, _, validDateNumber) = checkDate(input: nsText as String)
            if (validDateNumber){
                self.ccvField.becomeFirstResponder()
            }
        }
        
        
        
    }
    
    let allowedDateCharacters = "0123456789/"
    let allowedCardCharacters = "0123456789"
    
    func textField(_ textFieldToChange: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        if textFieldToChange == expirationDateField {
            let nsText = textFieldToChange.text!
            let startingLength = textFieldToChange.text?.count ?? 0
            let lengthToAdd = string.count
            let lengthToReplace = range.length
            let newLength = startingLength + lengthToAdd - lengthToReplace
            if (newLength > 5){
                return false
            }
            
            if (lengthToReplace > 0){
                autoInsertDateSlash = false
            }
            
            if (lengthToAdd > 0){
                autoInsertDateSlash = true
                if ((nsText.contains("/")) && ( string == "/")) {
                    return false
                }

                if (nsText.contains("/")) {
                    guard let index = nsText.index(of: "/") else { return false }
                    let mentionPosition = nsText.distance(from: nsText.startIndex, to: index)
                    if  ((range.location <= 2) && (mentionPosition >= 2)) {
                        return false
                    }
                }
                let cs = CharacterSet(charactersIn: allowedDateCharacters)
                let filtered: String = (string.components(separatedBy: cs) as NSArray).componentsJoined(by: "")
                if (string == filtered) {
                    return false
                }
                return true
            }
        }
        
        if textFieldToChange == cardNumberField {
            let startingLength = textFieldToChange.text?.count ?? 0
            let lengthToAdd = string.count
            let lengthToReplace = range.length
            let newLength = startingLength + lengthToAdd - lengthToReplace
            if (newLength > 16){
                return false
            }
            
            if (lengthToAdd > 0) {
                let cs = CharacterSet(charactersIn: allowedCardCharacters)
                let filtered: String = (string.components(separatedBy: cs) as NSArray).componentsJoined(by: "")
                if (string == filtered) {
                    return false
                }
            }
            
            return true
        }
        
        if textFieldToChange == ccvField {
            let startingLength = textFieldToChange.text?.count ?? 0
            let lengthToAdd = string.count
            let lengthToReplace = range.length
            let newLength = startingLength + lengthToAdd - lengthToReplace
            if (newLength > 4){
                return false
            } else if ((mCardType != CardType.Amex) && (newLength > 3)) {
                return false
            }
            if (lengthToAdd > 0) {
                let cs = CharacterSet(charactersIn: allowedCardCharacters)
                let filtered: String = (string.components(separatedBy: cs) as NSArray).componentsJoined(by: "")
                if (string == filtered) {
                    return false
                }
            }
            return true
        }
        
        return true
    }


    @IBAction func cardSubmitPressed(_ sender: Any) {
        clearErrors()        
        
        var valid = true
        
        let (_, _, validCardNumber) = checkCardNumber(input: cardNumberField.text!)
        let (monthString, yearString, validDateNumber) = checkDate(input: expirationDateField.text!)
        
        if (cardHolderNameField.text == "")
        {
            valid = false
            lblVCardH.text="Name is required";
        }
        
        if (validCardNumber == false)
        {
            valid = false
            lblVNo.text="Card number invalid";
        }
        if (validDateNumber == false)
        {
            valid = false
            lblVdate.text="Expiration error";
        }
        
        if (((mCardType == CardType.Amex) && (ccvField.text!.count != 4)) ||
            ((mCardType != CardType.Amex) && (ccvField.text!.count != 3)))
        {
            valid = false
            lblVccv.text="CCV error";
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

