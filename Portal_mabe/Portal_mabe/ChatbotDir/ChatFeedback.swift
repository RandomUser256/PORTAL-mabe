//
//  ChatFeedback.swift
//  HealthPoint
//
//  Created by Máximo on 5/5/26.
//
import SwiftData
import Foundation

/// Stores user feedback (thumbs up/down) for assistant responses
@Model
class ChatFeedback: Identifiable {
    @Attribute(.unique) var id: UUID
    
    /// Timestamp when the feedback was given
    var timestamp: Date
    
    /// The user's query that prompted the response
    var userQuery: String
    
    /// The assistant's response that was rated
    var assistantResponse: String
    
    /// True for thumbs up, false for thumbs down
    var isPositive: Bool
    
    /// Optional: User ID if you want to track feedback per user
    var userId: String?
    
    /// Retrieved context that was used for this response
    var contextUsed: [String]?
    
    init(id: UUID = UUID(), 
         timestamp: Date = Date(), 
         userQuery: String, 
         assistantResponse: String, 
         isPositive: Bool,
         userId: String? = nil,
         contextUsed: [String]? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.userQuery = userQuery
        self.assistantResponse = assistantResponse
        self.isPositive = isPositive
        self.userId = userId
        self.contextUsed = contextUsed
    }
}
