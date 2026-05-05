//
//  Portal_mabeApp.swift
//  Portal_mabe
//
//  Created by CETYS Universidad  on 04/05/26.
//

import SwiftUI
import SwiftData
internal import Combine

class UserSettings: ObservableObject {
    @Published var user: User
    
    init(user: User) {
        self.user = user
    }
    
    init () {
        self.user = User()
    }
}

@main
struct Portal_mabeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
