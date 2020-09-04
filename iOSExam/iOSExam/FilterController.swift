//
//  FilterController.swift
//  iOSExam
//
//  Created by E-Science on 8/29/20.
//  Copyright © 2020 E-Science. All rights reserved.
//

import UIKit

protocol FilterControllerDelegate {
    
    func onFilterEmployee(position: String)

}

class FilterController: UIViewController {

    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    var company_id: Int?
    var filter: String?
    
    var delegate: FilterControllerDelegate?
    
    var positions: [String] = [String]()
    var selected: String? = ""

    convenience init(company_id: Int, filter: String?){
        self.init(company_id: nil, filter: nil)
    }

    init(company_id: Int?, filter: String?){
        self.company_id = company_id
        self.filter = filter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Override UI DESIGNS from ViewController.swift
        submitButton.roundButtonborder()
        cancelButton.roundButtonborder()
        resetButton.roundButtonborder()
        cancelButton.addButtonBorder()
        resetButton.addButtonBorder()
        
        // Connect data
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        
        // Create position list
        positions = ["ALL"] + fetchAllPosition()
    
        if filter != nil, let index =  positions.firstIndex(of: filter!), index >= 0 {
            pickerView.selectRow(index, inComponent: 0, animated: true)
        }
            
    }

}


//MARK: - DB HELPER
extension FilterController {
   
    func fetchAllPosition() -> [String] {
        return DatabaseHelper.shared.fetchEmployeePosition(company_id: company_id)
    }
    
}


//MARK: - LISTENERS
extension FilterController {
    
    @IBAction func onSubmitClick(_ sender: Any) {
        print(selected!)
        
        self.dismiss(animated: true) {
            self.delegate?.onFilterEmployee(position: self.selected!)
        }
      
    }
    
    @IBAction func onResetClick(_ sender: Any) {
        pickerView.selectRow(0, inComponent: 0, animated: true)
    }
    
    @IBAction func onCancelClick(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}


//MARK: - PICKER VIEW DELEGATE
extension FilterController : UIPickerViewDelegate {
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}


//MARK: - PICKER VIEW DATA SOURCE
extension FilterController : UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return positions.count
    }
    
    // GET SELECTED
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        selected = positions[row]
        return positions[row]
    }
  
}
