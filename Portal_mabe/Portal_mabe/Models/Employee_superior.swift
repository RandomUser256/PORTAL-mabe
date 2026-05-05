//
//  Employee_superior.swift
//  PORTAL mape
//
//  Created by Máximo Magallanes Urtuzuástegui on 05/05/26.
//
import SwiftData
import Foundation

@Model
class Employee_superior: Identifiable {
    var employee: Employee?
    var superior: Employee?
    
    init(employee: Employee? = nil, superior: Employee? = nil) {
        self.employee = employee
        self.superior = superior
    }
}
