//
//  Employee.swift
//  PORTAL mape
//
//  Created by Máximo Magallanes Urtuzuástegui on 04/05/26.
//
import SwiftData
import Foundation

@Model
class Employee: Identifiable {
    @Attribute(.unique) var id_employee: Int
    
    
    //Foreign keys
    var employee_role: Employee_roles
    var requests: [Requests] = []
    
    var workdays: [Workday] = []
    var overtime: [Overtime] = []
    
    var employee_superior: Employee_superior
    
    
    var name: String
    var middleName: String?
    var surname: String
    var second_surname: String?
    var institutional_email: String
    var birthday: Date?
    var emergency_contact: String?
    var phone: String?
    var socialSecurityNumber: String?
    var bankNumber: String
    
    
    init(id_employee: Int, employee_role: Employee_roles, requests: [Requests], workdays: [Workday], overtime: [Overtime], employee_superior: Employee_superior, name: String, middleName: String? = nil, surname: String, second_surname: String? = nil, institutional_email: String, birthday: Date? = nil, emergency_contact: String? = nil, phone: String? = nil, socialSecurityNumber: String? = nil, bankNumber: String) {
        self.id_employee = id_employee
        self.employee_role = employee_role
        self.requests = requests
        self.workdays = workdays
        self.overtime = overtime
        self.employee_superior = employee_superior
        self.name = name
        self.middleName = middleName
        self.surname = surname
        self.second_surname = second_surname
        self.institutional_email = institutional_email
        self.birthday = birthday
        self.emergency_contact = emergency_contact
        self.phone = phone
        self.socialSecurityNumber = socialSecurityNumber
        self.bankNumber = bankNumber
    }
}
