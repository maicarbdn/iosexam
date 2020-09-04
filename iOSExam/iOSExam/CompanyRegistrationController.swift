//
//  CompanyRegistrationController.swift
//  iOSExam
//
//  Created by E-Science on 8/22/20.
//  Copyright © 2020 E-Science. All rights reserved.
//

import UIKit

class CompanyRegistrationController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var companyNameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextView!
    @IBOutlet weak var contactNumberTextField: UITextField!
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var showPasswordButton: UIButton!
    
    var registerButtonText: String?
    var onUpdate: Bool = false
    var company: Company?
    
    var buttonActive = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Override UI DESIGNS
        addressTextField.addTextViewBorder()
        registerButton.roundButtonborder()
        
        // If on update
        if onUpdate {
            self.title = "Full Information"
            companyNameTextField.isUserInteractionEnabled = false
            registerButton.setTitle("Update", for: .normal)
            patchCompany()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
       self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

}

//MARK: -  UI DESIGN
extension UITextView {
    
    func addTextViewBorder() {
        self.layer.borderColor = UIColor.systemGray3.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 10;
        self.clipsToBounds = true;
    }
    
}


//MARK: - DB HELPER
extension CompanyRegistrationController {
    
    func getCompany(username: String?) -> Company? {
        return DatabaseHelper.shared.getCompany(username: username, password: nil)
    }
    
    func insertCompany() {
        let company = Company(id: nil,
                              username: usernameTextField.text,
                              password: passwordTextField.text,
                              name: nameTextField.text,
                              company_name: companyNameTextField.text,
                              address: addressTextField.text,
                              contact_number: contactNumberTextField.text,
                              logo: nil)
        
        DatabaseHelper.shared.insertCompany(company: company)
    }
    
    func updateCompany() {
        let company = Company(id: self.company!.id,
                              username: usernameTextField.text,
                              password: passwordTextField.text,
                              name: nameTextField.text,
                              company_name: companyNameTextField.text,
                              address: addressTextField.text,
                              contact_number: contactNumberTextField.text,
                              logo: nil)
        
        DatabaseHelper.shared.updateCompany(company: company)
    }
    
}


//MARK: -  LISTENERS
private extension CompanyRegistrationController {
    
    @IBAction func onShowPasswordClick(_ sender: Any) {
        if(buttonActive) {
            showPasswordButton.setImage(UIImage(systemName: "eye"), for: .normal)
            passwordTextField.isSecureTextEntry = true
         } else {
            showPasswordButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            passwordTextField.isSecureTextEntry = false
         }
         buttonActive = !buttonActive
    }
    
    @IBAction func onRegisterClick(_ sender: Any) {
        let textFields = [
            1: usernameTextField.text,
            2: passwordTextField.text,
            3: nameTextField.text ,
            4: companyNameTextField.text,
            5: addressTextField.text ,
            6: contactNumberTextField.text
        ]
        
        var hasError = false
        
        for textField in textFields.sorted(by: {$0.key<$1.key})  {
            // CHECK IF FIELDS CONTAINS EMOJI
            if textField.value!.containsEmoji  {
                displayAlert(title: "Error", message: "Fields should not contain Emojis", hasError: true)
                hasError = true
                break
            }
       
            // VALIDATE IF USERNAME EXISTS
            if textField.key == 1, onUpdate, self.company?.username != textField.value!, let company: Company = getCompany(username: textField.value!), company.id! > 0 {
               displayAlert(title: "Error", message: "Username already exists", hasError: true)
               hasError = true
               break
            }
            
            if textField.key == 1, !onUpdate, let company: Company = getCompany(username: textField.value!), company.id! > 0 {
                displayAlert(title: "Error", message: "Username already exists", hasError: true)
                hasError = true
                break
            }

            // CHECK IF USERNAME IS INVALID
            if textField.key == 1 && textField.value!.containsSpecialChars {
                displayAlert(title: "Error", message: "Username should not contain special characters", hasError: true)
                hasError = true
                break
            }

            // CHECK IF PASSWORD IS INVALID
            if textField.key == 2 && (!textField.value!.validPasswordFormat || textField.value!.containsSpecialChars) {
                displayAlert(title: "Error", message: "Password should have at least 1 uppercase, 1 lowercase and 1 number", hasError: true)
                hasError = true
                break
            }
            
            // CHECK IF ALL FIELDS HAVE BEEN ANSWERED
            if textField.value == "" || textField.value?.trimmingCharacters(in: .whitespaces) == "" {
                displayAlert(title: "Error", message: "Missing answered fields", hasError: true)
                hasError = true
                break
            }
            
        }
        
        if !hasError {
            if onUpdate {
                updateCompany()
                displayAlert(title: "Success", message: "Successfully Updated", hasError: false)
            } else {
                insertCompany()
                displayAlert(title: "Success", message: "Successfully Registered", hasError: false)
            }
        }
    }
   
}


//MARK: - METHODS
extension CompanyRegistrationController {
    
    func displayAlert(title: String, message: String, hasError: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ok", style: .default) { (action) in
           if !hasError {
                self.navigationController?.popViewController(animated: true)
           }
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil )
    }
    
    func patchCompany(){
        usernameTextField.text = self.company!.username
        passwordTextField.text = self.company!.password
        nameTextField.text = self.company!.name
        companyNameTextField.text = self.company!.company_name
        addressTextField.text = self.company!.address
        contactNumberTextField.text = self.company!.contact_number
    }

}


//MARK: - VALIDATE STRINGS
extension String {
    
    var containsEmoji: Bool {
        for scalar in unicodeScalars {
            switch scalar.value {
            case 0x1F600...0x1F64F, // Emoticons
                 0x1F300...0x1F5FF, // Misc Symbols and Pictographs
                 0x1F680...0x1F6FF, // Transport and Map
                 0x2600...0x26FF,   // Misc symbols
                 0x2700...0x27BF,   // Dingbats
                 0xFE00...0xFE0F,   // Variation Selectors
                 0x1F900...0x1F9FF, // Supplemental Symbols and Pictographs
                 0x1F1E6...0x1F1FF: // Flags
                return true
            default:
                continue
            }
        }
        return false
    }
    
    var containsSpecialChars: Bool {
        let matchString = NSPredicate(format:"SELF MATCHES %@", REGEX_ALPHANUMERIC)
        print(matchString)
        return matchString.evaluate(with: self)
    }
    
    var validPasswordFormat: Bool {
        let matchString = NSPredicate(format:"SELF MATCHES %@", REGDEX_PASSWORD)
        return matchString.evaluate(with: self)
    }
  
}
