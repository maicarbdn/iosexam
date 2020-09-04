//
//  company.swift
//  iOSExam
//
//  Created by E-Science on 8/22/20.
//  Copyright © 2020 E-Science. All rights reserved.
//

import Foundation

class Company : NSObject {
    
    var id: Int?
    var username: String?
    var password: String?
    var name: String?
    var company_name: String?
    var address: String?
    var contact_number: String?
    var logo: String?
    
    init(id: Int?, username: String?, password: String?, name: String?, company_name: String?, address: String?, contact_number: String?, logo: String?){
        self.id = id
        self.username = username
        self.password = password
        self.name = name
        self.company_name = company_name
        self.address = address
        self.contact_number = contact_number
        self.logo = logo
    }
}
