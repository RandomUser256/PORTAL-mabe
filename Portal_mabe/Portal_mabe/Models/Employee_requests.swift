//
//  Employee_requests.swift
//  PORTAL mape
//
//  Created by Máximo Magallanes Urtuzuástegui on 05/05/26.
//
import SwiftData
import Foundation

//----------!!!!!Only download local copy of current users information!!!!!!----------------

@Model
class Employee_requests: Identifiable {
    var id_request_event: Int?
    
    var employee: Employee
    var request: Requests
    
    var event_date: Date
    var register_date: Date
    
    var amount: Int? //In case of monetary or vacation day requests
    
    //ADD METADATA LATER
    //var metadata: Js
    
    init(id_request_event: Int? = nil, employee: Employee, request: Requests, event_date: Date, register_date: Date, amount: Int? = nil) {
        self.id_request_event = id_request_event
        self.employee = employee
        self.request = request
        self.event_date = event_date
        self.register_date = register_date
        self.amount = amount
    }
}
