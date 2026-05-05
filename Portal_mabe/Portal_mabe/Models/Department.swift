//
//  Department.swift
//  PORTAL mape
//
//  Created by Máximo Magallanes Urtuzuástegui on 04/05/26.
//
import SwiftData
import Foundation

@Model
class Department: Identifiable {
    @Attribute(.unique) var id_department: Int
    
    var name: String
    var department_description: String
    
    //Type of requests that this department handles
    var requests_class: [Request_class] = []
    
    var employees: [Employee] = []
    
    init(id_department: Int, name: String, department_description: String) {
        self.id_department = id_department
        self.name = name
        self.department_description = department_description
    }
}
