//
//  Overtime.swift
//  PORTAL mape
//
//  Created by Máximo Magallanes Urtuzuástegui on 05/05/26.
//
import SwiftData
import Foundation

@Model
class Overtime: Identifiable {
    @Attribute(.unique) var id_overtime: Int
    
    //Assign numeric value for each weekday
    var weekDay: Int
    
    //Amount of extra hours worked
    var hours: Int
    
    var approved: Bool
    
    var Notes: String?
    
    var employee: Employee
    
    init(id_overtime: Int, weekDay: Int, hours: Int, approved: Bool, Notes: String? = nil, employee: Employee) {
        self.id_overtime = id_overtime
        self.weekDay = weekDay
        self.hours = hours
        self.approved = approved
        self.Notes = Notes
        self.employee = employee
    }
}
