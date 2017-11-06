//
//  CardCheck.swift
//  Demo_app_swift
//
//  Created by Mark Cardamis on 3/11/17.
//  Copyright © 2017 Oleksandr Omelchenko. All rights reserved.
//

import Foundation

enum CardType: String {
    case Unknown, Amex, Visa, MasterCard, Diners, Discover, JCB, Elo, Hipercard, UnionPay
    
    static let allCards = [Amex, Visa, MasterCard, Diners, Discover, JCB, Elo, Hipercard, UnionPay]
    
    var regex : String {
        switch self {
        case .Amex:
            return "^3[47][0-9]{5,}$"
        case .Visa:
            return "^4[0-9]{6,}([0-9]{3})?$"
        case .MasterCard:
            return "^(5[1-5][0-9]{4}|677189)[0-9]{5,}$"
        case .Diners:
            return "^3(?:0[0-5]|[68][0-9])[0-9]{4,}$"
        case .Discover:
            return "^6(?:011|5[0-9]{2})[0-9]{3,}$"
        case .JCB:
            return "^(?:2131|1800|35[0-9]{3})[0-9]{3,}$"
        case .UnionPay:
            return "^(62|88)[0-9]{5,}$"
        case .Hipercard:
            return "^(606282|3841)[0-9]{5,}$"
        case .Elo:
            return "^((((636368)|(438935)|(504175)|(451416)|(636297))[0-9]{0,10})|((5067)|(4576)|(4011))[0-9]{0,12})$"
        default:
            return ""
        }
    }
}

func matchesRegex(regex: String!, text: String!) -> Bool {
    do {
        let regex = try NSRegularExpression(pattern: regex, options: [.caseInsensitive])
        let nsString = text as NSString
        let match = regex.firstMatch(in: text, options: [], range: NSMakeRange(0, nsString.length))
        return (match != nil)
    } catch {
        return false
    }
}


func luhnCheck(cardNumber: String) -> Bool {
    var sum = 0
    let reversedCharacters = cardNumber.characters.reversed().map { String($0) }
    for (idx, element) in reversedCharacters.enumerated() {
        guard let digit = Int(element) else { return false }
        switch ((idx % 2 == 1), digit) {
        case (true, 9): sum += 9
        case (true, 0...8): sum += (digit * 2) % 9
        default: sum += digit
        }
    }
    return sum % 10 == 0
}


func checkCardNumber(input: String) -> (type: CardType, formatted: String, valid: Bool) {
    // Get only numbers from the input string
    //let numberOnly = input.stringByReplacingOccurrencesOfString("[^0-9]", withString: "", options: .RegularExpressionSearch)
    let numberOnly = input
    var type: CardType = .Unknown
    var formatted = ""
    var valid = false
    
    // detect card type
    for card in CardType.allCards {
        if (matchesRegex(regex: card.regex, text: numberOnly)) {
            type = card
            break
        }
    }

    // check validity
    if (numberOnly.count > 0) {
        valid = luhnCheck(cardNumber: numberOnly)
    }
    
    
    // format
    var formatted4 = ""
    for character in numberOnly.characters {
        if formatted4.characters.count == 4 {
            formatted += formatted4 + " "
            formatted4 = ""
        }
        formatted4.append(character)
    }
    
    formatted += formatted4 // the rest
    
    // return the tuple
    return (type, formatted, valid)
}
