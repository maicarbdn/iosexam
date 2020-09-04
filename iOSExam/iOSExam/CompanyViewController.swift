//
//  CompanyViewController.swift
//  iOSExam
//
//  Created by E-Science on 8/23/20.
//  Copyright © 2020 E-Science. All rights reserved.
//

import UIKit


class CompanyViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    
    @IBOutlet weak var showInfoButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBOutlet weak var employeeTableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let preferences = UserDefaults.standard
    
    var company: Company?
    var company_id: Int?
    var companyName: String?
    
    var employees: [Employee] = []
    var origEmployees: [Employee] = []
    
    var filter: String?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Override UI DESIGNS from ViewController.swift
        showInfoButton.addButtonBorder()
        logoutButton.addButtonBorder()
        showInfoButton.roundButtonborder()
        logoutButton.roundButtonborder()
        
        // Patch name and company name
        nameLabel.text = "Company ID: \(String(describing: company_id!))"
        companyNameLabel.text = "Company Name: \(String(describing: companyName!))"
        
        // UITableView
        self.employeeTableView.register(UINib(nibName: String(describing: EmployeeCell.self), bundle: nil), forCellReuseIdentifier: String(describing: EmployeeCell.self))
        self.employeeTableView.delegate = self
        self.employeeTableView.dataSource = self
               
        employees = DatabaseHelper.shared.fetchAllEmployee(company_id: company_id, query: nil, position: nil)
        origEmployees = employees
        
        company = DatabaseHelper.shared.getCompanyById(company_id: self.company_id)
        
        // Connect to search bar
        searchBar.delegate = self
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
       self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
}


//MARK: - LISTENERS
extension CompanyViewController {
    
    @IBAction func onShowInfoClick(_ sender: Any) {
       displayRegistration()
    }
       
    @IBAction func onLogoutClick(_ sender: Any) {
        preferences.set(nil, forKey: USERNAME_PREF_KEY)
        preferences.set(nil, forKey: PASSWORD_PREF_KEY)
        preferences.synchronize()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func onAddEmployeeClick(_ sender: Any) {
        presentRegistrationController()
    }
    
    func presentRegistrationController(employee: Employee? = nil) {
        let controller = EmployeeRegistrationController(employee: employee, companyName: self.companyName, company_id: self.company_id)
        controller.delegate = self
        controller.modalPresentationStyle = .overCurrentContext
        self.present(controller, animated: false,  completion: nil)
    }
    
    
    @IBAction func onFilterClick(_ sender: Any) {
        let controller = FilterController(company_id: self.company_id, filter: filter)
        controller.delegate = self
        controller.modalPresentationStyle = .overCurrentContext
        self.present(controller, animated: false,  completion: nil)
    }

}


//MARK: - EMPLOYEE DELEGATE
extension CompanyViewController : RegistrationControllerDelegate {
    
    // ADD
    func onRegister(employee: Employee) {
        DatabaseHelper.shared.insertEmployee(employee: employee)
        employees = DatabaseHelper.shared.fetchAllEmployee(company_id: self.company_id, query: nil, position: nil)
        origEmployees = employees
        filter = nil
        employeeTableView.reloadData()
    }
    
    // UPDATE
    func onRegisterUpdate(employee: Employee) {
        DatabaseHelper.shared.updateEmployee(employee: employee)
        employeeTableView.reloadData()
   }
    
}

//MARK: - FILTER DELEGATE
extension CompanyViewController : FilterControllerDelegate {
    
    func onFilterEmployee(position: String) {
        filter = nil
        if position != "ALL"{
            filter = position
            employees = DatabaseHelper.shared.fetchAllEmployee(company_id: self.company_id, query: nil, position: position)
            origEmployees = employees
        } else {
            employees = DatabaseHelper.shared.fetchAllEmployee(company_id: self.company_id, query: nil, position: nil)
            origEmployees = employees
        }
        employeeTableView.reloadData()
           
    }
    
}


//MARK: - TABLE VIEW DELEGATE
extension CompanyViewController : UITableViewDelegate {
    
    // METHOD TO RUN WHEN TABLE VIEW CELL IS TAPPED
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let employee = employees[indexPath.row]
        presentRegistrationController(employee: employee)
    }
    
    // SET STATIC HEAIGHT FOR ROW
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return UITableView.automaticDimension
    }
    
    // SLIDE ACTION - DELETE
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteItem = UIContextualAction(style: .destructive, title: "Delete") { (contextualAction, view, boolValue) in
            print("delete action: \(self.employees[indexPath.row].id!)")
            DatabaseHelper.shared.delete(id: self.employees[indexPath.row].id!)
            self.employees.remove(at: indexPath.row)
            
            if self.searchBar.text! == "" && self.filter == nil {
                self.employees = DatabaseHelper.shared.fetchAllEmployee(company_id: self.company_id, query: nil, position: nil)
                self.origEmployees = self.employees
            }
            
             self.employeeTableView.reloadData()
            
        }
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteItem])
        return swipeActions
    }
    
}


//MARK: - TABLE VIEW DATA SOURCE
extension CompanyViewController : UITableViewDataSource {
    
    // CREATE A CELL FOR EACH TABLE VIEW ROW (NUMBER OF ITERATION IS BASED ON NUMBER OF ITEM SET IN numberOfRowsInSection)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EmployeeCell.self), for: indexPath) as! EmployeeCell
        
        let employee = employees[indexPath.row]
        cell.nameLabel?.text = employee.name
        cell.positionLabel?.text =  employee.position
        
        return cell
   }
    
    // NUMBER OF ROWS IN TABLE VIEW
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return employees.count
   }
    
}


//MARK: - SEARCH BAR
extension CompanyViewController:  UISearchBarDelegate {
   
     func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchText != "" {
            employees = origEmployees.filter { ($0.name?.lowercased().contains(searchText.lowercased()))!}
        } else {
            origEmployees = DatabaseHelper.shared.fetchAllEmployee(company_id: self.company_id, query: nil, position: nil)
            employees = origEmployees
        }
        
        employeeTableView.reloadData()
    }
    
}

//MARK: - METHODS
extension CompanyViewController {
    
    func displayRegistration(){
         self.performSegue(withIdentifier: "PresentCompanyRegistration", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let company = DatabaseHelper.shared.getCompanyById(company_id: self.company_id)
        let companyRegistrationController = segue.destination as? CompanyRegistrationController
        companyRegistrationController?.company = company
        companyRegistrationController?.onUpdate = true
    }
    
}
