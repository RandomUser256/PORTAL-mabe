//
//  Workday.swift
//  PORTAL mape
//
//  Created by Máximo Magallanes Urtuzuástegui on 05/05/26.
//
import SwiftData
import Foundation

//----------!!!!!Only download local copy of current users information!!!!!!----------------

@Model
class Workday: Identifiable {
    var employee: Employee
    
    //Assign a numeric value for each day of the week
    var weekDay: Int
    
    var startTime: Date
    var endTime: Date
    
    init(employee: Employee, weekDay: Int, startTime: Date, endTime: Date) {
        self.employee = employee
        self.weekDay = weekDay
        self.startTime = startTime
        self.endTime = endTime
    }
}
