//
//  Request_classification.swift
//  PORTAL mape
//
//  Created by Máximo Magallanes Urtuzuástegui on 04/05/26.
//
import SwiftData
import Foundation

@Model
class Request_class: Identifiable {
    @Attribute(.unique) var id_request_classification: Int
    var name: String
    var request_class_description: String
    
    var department: Department
    
    @Relationship(deleteRule: .cascade, inverse: \Requests.request_class)
    var requests: [Requests] = []
    
    init(id_request_classification: Int, name: String, request_class_description: String, department: Department) {
        self.id_request_classification = id_request_classification
        self.name = name
        self.request_class_description = request_class_description
        self.department = department
    }
}
