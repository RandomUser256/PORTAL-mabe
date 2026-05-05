//
//  Request_catalogue.swift
//  PORTAL mape
//
//  Created by Máximo Magallanes Urtuzuástegui on 04/05/26.
//
import SwiftData
import Foundation

@Model
class Requests: Identifiable {
    @Attribute(.unique) var id_request: Int
    var name: String
    var request_description: String
    
    var request_class: Request_class
    var employee: Employee
    
    init(id_request: Int, name: String, request_description: String, request_class: Request_class, employee: Employee) {
        self.id_request = id_request
        self.name = name
        self.request_description = request_description
        self.request_class = request_class
        self.employee = employee
    }
}
