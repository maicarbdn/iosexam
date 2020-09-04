//
//  ViewController.swift
//  iOSExam
//
//  Created by E-Science on 8/22/20.
//  Copyright © 2020 E-Science. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var showPasswordButton: UIButton!
    
    let preferences = UserDefaults.standard
    
    var company : Company?
    var buttonActive = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Override UI DESIGNS
        usernameTextField.addBottomBorderField()
        passwordTextField.addBottomBorderField()
        registerButton.addButtonBorder()
        exitButton.addButtonBorder()
        loginButton.roundButtonborder()
        registerButton.roundButtonborder()
        exitButton.roundButtonborder()
        
        // Initializers
        initializeCredential()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
 
}


// MARK: - UI DESIGNS
extension UITextField {
    
    func addBottomBorderField(){
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.0
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 2.0
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 1.0
    }
    
}

extension UIButton {
    
    func addButtonBorder(){
        self.layer.borderWidth = CGFloat(1.0)
        self.layer.borderColor = UIColor.systemOrange.cgColor
    }
    
    func roundButtonborder(){
        self.layer.cornerRadius = 10;
        self.clipsToBounds = true;
    }
    
}


//MARK: - DB HELPER
private extension ViewController {
    
    func getCompany() -> Company? {
        return DatabaseHelper.shared.getCompany(username: usernameTextField.text, password: passwordTextField.text)
    }
    
}


// MARK: - INITIALIZERS
private extension ViewController {
    
    // Auto login
    private func initializeCredential(){
        if let username = preferences.string(forKey: USERNAME_PREF_KEY), username.count > 0, let password = preferences.string(forKey: PASSWORD_PREF_KEY), password.count > 0 {
            usernameTextField.text = username
            passwordTextField.text = password
            if let companyDetail = getCompany(), companyDetail.id! > 0 {
                company = companyDetail
                displaySplashController()
            }
        }
    }
    
    private func updateUserCredentials(){
        preferences.set(usernameTextField.text, forKey: USERNAME_PREF_KEY)
        preferences.set(passwordTextField.text, forKey: PASSWORD_PREF_KEY)
        preferences.synchronize()
    }
     
}


// MARK: - LISTENERS
private extension ViewController {
    
    @IBAction func onLoginClick(_ sender: Any) {
        if let companyDetail = getCompany(), companyDetail.id! > 0 {
            company = companyDetail
            displayAlert(title: "Login", message: "Successfully logged in", isLoginSuccess: true)
            print("Success login")
       
        } else {
            displayAlert(title: "Login", message: "Invalid username and password", isLoginSuccess: false)
            print("Invalid login")
        }
    }
      
    @IBAction func onRegisterClick(_ sender: Any) {
        dispayRegister()
    }
    
    @IBAction func onExitClick(_ sender: Any) {
        UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
        exit(0)
    }
    
    
    @IBAction func onShowPasswordClick(_ sender: Any) {
        buttonActive = !buttonActive
         if buttonActive {
            showPasswordButton.setImage(UIImage(systemName: "eye"), for: .normal)
            passwordTextField.isSecureTextEntry = false
         } else {
            showPasswordButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            passwordTextField.isSecureTextEntry = true
        }
    }
    
}


// MARK: - METHODS
extension ViewController {
    
    func displayAlert(title: String, message: String, isLoginSuccess: Bool) {
       let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
       let okAction = UIAlertAction(title: "ok", style: .default) { (action) in
           if isLoginSuccess {
                self.updateUserCredentials()
                self.displaySplashController()
           }
       }
           
       alert.addAction(okAction)
       self.present(alert, animated: true, completion: nil )
   }
   
    func dispayRegister(){
        self.performSegue(withIdentifier: "PresentCompanyRegistration", sender: nil)
    }
    
    func displaySplashController(){
        self.performSegue(withIdentifier: "PresentSplashController", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let splashController = segue.destination as? SplashViewController
        splashController?.companyName = company?.company_name
        splashController?.company_id = company?.id
    }

}

