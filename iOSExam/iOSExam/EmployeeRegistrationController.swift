//
//  EmployeeRegistrationController.swift
//  iOSExam
//
//  Created by E-Science on 8/23/20.
//  Copyright © 2020 E-Science. All rights reserved.
//

import UIKit

protocol RegistrationControllerDelegate {
    
    func onRegister(employee: Employee)
    
    func onRegisterUpdate(employee: Employee)
    
}

class EmployeeRegistrationController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var companyTextField: UITextField!
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var contactNumTextField: UITextField!
    @IBOutlet weak var positionTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    private var employee: Employee?
    private var companyName: String?
    private var company_id: Int?
    
    var delegate: RegistrationControllerDelegate?
    
    convenience init(employee: Employee, companyName: String, company_id: Int){
        self.init(employee: nil, companyName: nil, company_id: nil)
    }

    init(employee: Employee?, companyName: String?, company_id: Int?){
        self.employee = employee
        self.companyName = companyName
        self.company_id = company_id
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Overrides UI DESIGNS from ViewController.swift
        saveButton.roundButtonborder()
        cancelButton.addButtonBorder()
        cancelButton.roundButtonborder()
        addressTextView.addTextViewBorder()
        
        companyTextField.text  = companyName
        
        if let employee = employee {
            titleLabel.text = "Update Employee"
            nameTextField.text = employee.name
            addressTextView.text  = employee.address
            contactNumTextField.text  = employee.contact_number
            positionTextField.text  = employee.position
        }
        
        companyTextField.isUserInteractionEnabled = false
    
    }
    
}


//MARK: - LISTENERS
extension EmployeeRegistrationController {
    
    @IBAction func onSaveClick(_ sender: Any) {
        if let employee = employee {
            
            employee.name = nameTextField.text
            employee.address = addressTextView.text
            employee.contact_number = contactNumTextField.text
            employee.position = positionTextField.text
            employee.company_id = company_id

            let isValid = checkAllRequiredFields(employee: employee)
            
            if isValid {
                displayAlert(title: "Success", message: "Successfully updated!", employee: employee, isSuccess: true, forUpdate: true)
            }
            
            displayAlert(title: "Error", message: "All fields must be answered", employee: employee, isSuccess: false, forUpdate: true)

         } else {
            let employee = Employee(id: nil,
                                   name: nameTextField.text,
                                   company_id: company_id,
                                   address:  addressTextView.text,
                                   contact_number: contactNumTextField.text,
                                   position: positionTextField.text,
                                   photo: nil)
            
            let isValid = checkAllRequiredFields(employee: employee)
           
            if isValid {
                displayAlert(title: "Success", message: "Successfully added!", employee: employee, isSuccess: true, forUpdate: false)
            }
            
             displayAlert(title: "Error", message: "All fields must be answered", employee: employee, isSuccess: false, forUpdate: false)
            
        }
    }
    
    @IBAction func onCanceClick(_ sender: Any) {
       dismiss(animated: true, completion: nil)
    }
    
}


//MARK: - METHODS
extension EmployeeRegistrationController {
    
    func checkAllRequiredFields(employee: Employee) -> Bool {
        let optionals: [String?] = [employee.name, "\(String(describing: employee.company_id))", employee.address, employee.contact_number, employee.position]
        
        if (optionals.contains{ $0 == "" }) {
            return false
        }
        
        return true
    }
    
    func displayAlert(title: String, message: String, employee: Employee, isSuccess: Bool, forUpdate: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ok", style: .default) { action in
            
            // IF SUCCESS AND FOR UPDATE
            if isSuccess && forUpdate {
                self.dismiss(animated: true) {
                    self.delegate?.onRegisterUpdate(employee: employee)
                }
            
            // IF SUCCESS AND FOR ADD
            } else if isSuccess && !forUpdate {
                self.dismiss(animated: true) {
                   self.delegate?.onRegister(employee: employee)
                }
            }
            
        }
        
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil )
    }
    
}
