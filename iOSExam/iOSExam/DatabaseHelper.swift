//
//  File.swift
//  iOSTraining
//
//  Created by E-Science on 8/20/20.
//  Copyright © 2020 E-Science. All rights reserved.
//

import Foundation
import SQLite3
class DatabaseHelper {
    
    static let shared : DatabaseHelper = DatabaseHelper()
    
    init() {
        db = openDatabase()
        createTable()
    }
    
    let dbPath: String = "iosexam.sqlite"
    var db:OpaquePointer?
    
    //MARK: - OPEN DATABASE
    func openDatabase() -> OpaquePointer? {
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(dbPath)
        
        var db: OpaquePointer? = nil
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
            return nil
        } else {
            print("Successfully opened connection to database at \(dbPath)")
            return db
        }
        
    }
    
    
    //MARK: - CREATE TABLE
    func createTable() {
        
        let createTableStrings = [
            "CREATE TABLE IF NOT EXISTS company(id INTEGER PRIMARY KEY, username TEXT, password TEXT, name TEXT, company_name TEXT, address TEXT, contact_number TEXT, logo TEXT);",
            "CREATE TABLE IF NOT EXISTS employee(id INTEGER PRIMARY KEY, name TEXT, address TEXT,  contact_number TEXT, position TEXT, company_id INTEGER, photo TEXT);"
        ]
        
        var createTableStatement: OpaquePointer? = nil
        
        for createTableString in createTableStrings {
            if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
                if sqlite3_step(createTableStatement) == SQLITE_DONE {
                    print("Tables created.")
                } else {
                    print("Tables could not be created.")
                }
            } else {
                print("CREATE TABLE statement could not be prepared.")
            }
            
            sqlite3_finalize(createTableStatement)
            
        }
        
    }
    
    
    //MARK: - FETCH STATEMENTS
    func getCompany(username: String?, password: String?) -> Company? {
        
        var queryStatementString = "SELECT id, username, password, company_name FROM company"
        var queryStatement: OpaquePointer? = nil
        var company : Company?
        
        if password == nil {
            // For registration
            queryStatementString += " WHERE LOWER(username) = ?"
        } else {
            // For login
            queryStatementString += " WHERE username = ? AND password = ?"
        }
    
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            
            if password == nil {
                sqlite3_bind_text(queryStatement, 1, (username!.lowercased() as NSString).utf8String, -1, nil)
            } else {
                sqlite3_bind_text(queryStatement, 1, (username! as NSString).utf8String, -1, nil)
                sqlite3_bind_text(queryStatement, 2, (password! as NSString).utf8String, -1, nil)
            }

            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                let username = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let password = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let company_name = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
         
                company = Company(id: id,
                                  username: username,
                                  password: password,
                                  name: nil,
                                  company_name: company_name,
                                  address: nil,
                                  contact_number: nil,
                                  logo: nil)

                print("\(id) | \(username)")
            }

        } else {
            print("SELECT statement could not be prepared")
        }

        sqlite3_finalize(queryStatement)

        return company
    }
    
    func getCompanyById(company_id: Int?) -> Company? {
        
        let queryStatementString = "SELECT * FROM company WHERE id = ?"
        var queryStatement: OpaquePointer? = nil
        var company : Company?
    
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            
             sqlite3_bind_int(queryStatement, 1, Int32(truncating: company_id! as NSNumber))
      
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                let username = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let password = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let name = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                let company_name = String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))
                let address = String(describing: String(cString: sqlite3_column_text(queryStatement, 5)))
                let contact_number = String(describing: String(cString: sqlite3_column_text(queryStatement, 6)))
         
                company = Company(id: id,
                                  username: username,
                                  password: password,
                                  name: name,
                                  company_name: company_name,
                                  address: address,
                                  contact_number: contact_number,
                                  logo: nil)

                print("\(id) | \(username)")
            }

        } else {
            print("SELECT statement could not be prepared")
        }

        sqlite3_finalize(queryStatement)

        return company
    }
    
    func fetchAllEmployee(company_id: Int?, query: String?, position: String?) -> [Employee] {
        var queryStatementString = "SELECT id, name, address, contact_number, position, company_id FROM employee WHERE company_id = ?"
        
        var queryStatement: OpaquePointer? = nil
        var employees : [Employee] = []
        
        if query != nil {
            queryStatementString += " AND name LIKE '%%?%%'"
        }
        
        if position != nil {
            queryStatementString += " AND position = ?"
        }
        
        print(queryStatementString)
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_int(queryStatement, 1, Int32(truncating: company_id! as NSNumber))
            
            if query != nil {
                sqlite3_bind_text(queryStatement, 2, (query! as NSString).utf8String, -1, nil)
            }
            
            if position != nil {
                let index =  query != nil ? 3 : 2
                sqlite3_bind_text(queryStatement, Int32(index), (position! as NSString).utf8String, -1, nil)
            }
      
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                
                let id = Int(sqlite3_column_int(queryStatement, 0))
                let name = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let address = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let contact_number = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                let position = String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))
                let company_id = String(describing: String(cString: sqlite3_column_text(queryStatement, 5)))

                employees.append(Employee(id: id,
                                        name: name,
                                        company_id: Int(company_id),
                                        address: address,
                                        contact_number: contact_number,
                                        position: position,
                                        photo: nil))

                print("Query Result:")
                print("\(id) | \(name)")
            }

        } else {
            print("SELECT statement could not be prepared")
        }

        sqlite3_finalize(queryStatement)

        return employees

    }
    
    func fetchEmployeePosition(company_id: Int?) -> [String] {
        let queryStatementString = "SELECT DISTINCT position FROM employee WHERE company_id = ?"
        var queryStatement: OpaquePointer? = nil
        var employees : [String] = []
        
        print(queryStatementString)
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_int(queryStatement, 1, Int32(truncating: company_id! as NSNumber))
            
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                
                let position = String(describing: String(cString: sqlite3_column_text(queryStatement, 0)))
             
                employees.append(position)

                print("Query Result:")
                print("\(position)")
            }

        } else {
            print("SELECT statement could not be prepared")
        }

        sqlite3_finalize(queryStatement)

        return employees

    }
    
    //MARK: - INSERT STATEMENTS
    func insertCompany(company: Company) {

       let insertStatementString = "INSERT INTO company (username, password, name, company_name, address, contact_number) VALUES (?, ?, ?, ?, ?, ?);"
       var insertStatement: OpaquePointer? = nil

       if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
           
           sqlite3_bind_text(insertStatement, 1, (company.username! as NSString).utf8String, -1, nil)
           sqlite3_bind_text(insertStatement, 2, (company.password! as NSString).utf8String, -1, nil)
           sqlite3_bind_text(insertStatement, 3, (company.name! as NSString).utf8String, -1, nil)
           sqlite3_bind_text(insertStatement, 4, (company.company_name! as NSString).utf8String, -1, nil)
           sqlite3_bind_text(insertStatement, 5, (company.address! as NSString).utf8String, -1, nil)
           sqlite3_bind_text(insertStatement, 6, (company.contact_number! as NSString).utf8String, -1, nil)
   
           if sqlite3_step(insertStatement) == SQLITE_DONE {
               print("COMPANY: Successfully inserted row.")
           } else {
               print("COMPANY: Could not insert row.")
           }
       } else {
           print("COMPANY: INSERT statement could not be prepared.")
       }
       sqlite3_finalize(insertStatement)
    }
    
    func insertEmployee(employee: Employee) {

        let insertStatementString = "INSERT INTO employee (name, address, contact_number, position, company_id) VALUES (?, ?, ?, ?, ?);"
        var insertStatement: OpaquePointer? = nil

        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_text(insertStatement, 1, (employee.name! as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (employee.address! as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, (employee.contact_number! as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 4, (employee.position! as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 5, Int32(truncating: employee.company_id! as NSNumber))

            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("COMPANY: Successfully inserted row.")
            } else {
                print("COMPANY: Could not insert row.")
            }
        } else {
            print("COMPANY: INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
       
    
    //MARK: - UPDATE STATEMENTS
    func updateCompany(company: Company) {

        let updateStatementString = """
            UPDATE company \
            SET username = ?, password = ?, name = ?, company_name = ?, address = ?, contact_number = ? \
            WHERE id = ?;
            """
        var updateStatment: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatment, nil) == SQLITE_OK {
            
            sqlite3_bind_text(updateStatment, 1, (company.username! as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateStatment, 2, (company.password! as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateStatment, 3, (company.name! as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateStatment, 4, (company.company_name! as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateStatment, 5, (company.address! as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateStatment, 6, (company.contact_number! as NSString).utf8String, -1, nil)
            sqlite3_bind_int(updateStatment, 7, Int32(truncating: company.id! as NSNumber))
           
            if sqlite3_step(updateStatment) == SQLITE_DONE {
                print("Successfully updated row.")
            } else {
                print("Could not updated row.")
            }
        } else {
            print("UPDATE statement could not be prepared.")
        }
        sqlite3_finalize(updateStatment)
    }
    
    func updateEmployee(employee: Employee) {

        let updateStatementString = """
            UPDATE employee \
            SET name = ?, address = ?,  contact_number = ?, position = ? \
            WHERE id = ? AND company_id = ?;
            """
        var updateStatment: OpaquePointer? = nil

        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatment, nil) == SQLITE_OK {

            sqlite3_bind_text(updateStatment, 1, (employee.name! as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateStatment, 2, (employee.address! as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateStatment, 3, (employee.contact_number! as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateStatment, 4, (employee.position! as NSString).utf8String, -1, nil)
            sqlite3_bind_int(updateStatment, 5, Int32(truncating: employee.id! as NSNumber))
            sqlite3_bind_int(updateStatment, 6, Int32(truncating: employee.company_id! as NSNumber))
            
            if sqlite3_step(updateStatment) == SQLITE_DONE {
                print("Successfully updated row.")
            } else {
                print("Could not updated row.")
            }
        } else {
            print("UPDATE statement could not be prepared.")
        }
        sqlite3_finalize(updateStatment)
    }
    
    
    //MARK: - DELETE STATEMENTS
    func delete(id:Int) {
        let deleteStatementStirng = "DELETE FROM employee WHERE Id = ?;"
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(deleteStatement, 1, Int32(id))
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared")
        }
        sqlite3_finalize(deleteStatement)
    }
    
}

