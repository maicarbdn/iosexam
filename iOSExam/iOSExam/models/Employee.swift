//
//  company.swift
//  iOSExam
//
//  Created by E-Science on 8/22/20.
//  Copyright © 2020 E-Science. All rights reserved.
//

import Foundation

class Employee : NSObject {
    
    var id: Int?
    var name: String?
    var company_id: Int?
    var address: String?
    var contact_number: String?
    var position: String?
    var photo: String?
    
    init(id: Int?, name: String?, company_id: Int?, address: String?, contact_number: String?, position: String?, photo: String?){
        self.id = id
        self.name = name
        self.company_id = company_id
        self.address = address
        self.contact_number = contact_number
        self.position = position
        self.photo = photo
    }
}
