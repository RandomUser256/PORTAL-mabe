//
//  Employee_roles.swift
//  PORTAL mape
//
//  Created by Máximo Magallanes Urtuzuástegui on 04/05/26.
//
import SwiftData
import Foundation

@Model
class Employee_roles: Identifiable {
    @Attribute(.unique) var id_employee_role: Int
    
    var name: String
    
    var role_description: String
    
    var department: Department
    
    @Relationship(deleteRule: .cascade, inverse: \Employee.employee_role)
    var employees: [Employee] = []
    
    init(id_employee_role: Int, name: String, role_description: String, department: Department) {
        self.id_employee_role = id_employee_role
        self.name = name
        self.role_description = role_description
        self.department = department
    }
}
