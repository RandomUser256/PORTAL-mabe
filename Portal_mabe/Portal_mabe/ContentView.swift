import SwiftUI

struct ContentView: View {
    enum Tab {
        case profile
        case consult
        case chat
    }

    @State private var selectedTab: Tab = .profile

    var body: some View {
        TabView {
            consultScreen()
                .tabItem {
                    Label("Consult", systemImage: "doc.text.magnifyingglass")
                }
                .tag(Tab.consult)
            
            userScreen()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(Tab.profile)
            
            chatScreen()
                .tabItem {
                    Label("Chat", systemImage: "bubble.left.and.bubble.right")
                }
                .tag(Tab.chat)
        }
    }
}

#Preview {
    ContentView()
}
