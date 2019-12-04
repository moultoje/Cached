//
//  Validation.swift
//  Cached
//
//  Created by Katie Rievley on 12/2/19.
//  Copyright © 2019 Mobile Treasure Hunt. All rights reserved.
//

import Foundation
import UIKit

//for failure and success results
enum Alert {
    case success
    case failure
    case error
}

//for success or failure of validation with alert message
enum Valid {
    case success
    case failure(Alert, AlertMessages)
}

enum ValidationType {
    case email
    case name
    case description
    case clue
    case radius
}

enum RegEx: String {
    case email = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}" // Email
    case alphanumericString = "^[A-Za-z0-9 .,'!?@=+#()%*_<>$&;:\"]*$" //string with special chars
    case radius = "[0-9]{1,3}"
}

enum AlertMessages: String {
    case invalidEmail = "Invalid Email"
    case invalidName = "Name Contains Prohibited Character"
    case invalidDescription = "Description Contains Prohibited Character"
    case invalidClue = "Clue Contains Prohibited Character"
    case invalidRadius = "Enter Radius Between 0 - 999 Meters"
    
    case emptyEmail = "Please Enter Email"
    case emptyName = "Please Enter Hunt Name"
    case emptyDescription = "Please Enter Description"
    case emptyClue = "Please Enter Clue"
    case emptyRadius = "Please Enter Radius"
    
    func localized() -> String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}

class Validation: NSObject {
    
    public static let shared = Validation()
    
    func validate(values: (type: ValidationType, inputValue: String)...) -> Valid {
        for valueToBeChecked in values {
            switch valueToBeChecked.type {
            case.email:
                if let tempValue = isValidString((valueToBeChecked.inputValue, .email, .emptyEmail, .invalidEmail)) {
                    return tempValue
                }
            case.name:
                if let tempValue = isValidString((valueToBeChecked.inputValue, .alphanumericString, .emptyName, .invalidName)) {
                    return tempValue
                }
            case.description:
                if let tempValue = isValidString((valueToBeChecked.inputValue, .alphanumericString, .emptyDescription, .invalidDescription)) {
                    return tempValue
                }
            case.clue:
                if let tempValue = isValidString((valueToBeChecked.inputValue, .alphanumericString, .emptyClue, .invalidClue)) {
                    return tempValue
                }
            case.radius:
                if let tempValue = isValidString((valueToBeChecked.inputValue, .radius, .emptyRadius, .invalidRadius)) {
                    return tempValue
                }
            }
        }
        return .success
    }
    
    
    func isValidString(_ input: (text: String, regex: RegEx, emptyAlert: AlertMessages, invalidAlert: AlertMessages)) -> Valid? {
        if input.text.isEmpty {
            return .failure(.error, input.emptyAlert)
        } else if isValidRegEx(input.text, input.regex) != true {
            return .failure(.error, input.invalidAlert)
        }
        return nil
    }
    
    
    func isValidRegEx(_ testStr: String, _ regex: RegEx) -> Bool {
        let stringTest = NSPredicate(format:"SELF MATCHES %@", regex.rawValue)
        let result = stringTest.evaluate(with: testStr)
        return result
    }
    
}
