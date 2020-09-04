//
//  SplashViewController.swift
//  iOSExam
//
//  Created by E-Science on 8/23/20.
//  Copyright © 2020 E-Science. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    var companyName: String?
    var company_id: Int?
    var name: String?
    
    var startSeconds = 0
    var endSeconds = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide navigation bar
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        // Replace label to logged company
        companyNameLabel.text = companyName
        
        // Start timer
        runTimer()
    }

}


extension SplashViewController {
    
    func runTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.startSeconds += 1
            if self.startSeconds == self.endSeconds {
                timer.invalidate()
                self.performSegue(withIdentifier: "PresentCompanyView", sender: nil)
            } else {
                self.progressBar.setProgress(Float(self.startSeconds) / Float(self.endSeconds), animated: true)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let companyController = segue.destination as? CompanyViewController
        companyController?.companyName = companyName
        companyController?.company_id = company_id
    }

}
