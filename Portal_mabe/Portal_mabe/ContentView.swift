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
            //Change preset for dynamic information
            CategoriesView(options: [CategoryOption(), CategoryOption(), CategoryOption(), CategoryOption()])
                .tabItem {
                    Label("Consult", image: "pm_ICON_MENU")
                }
                .tag(Tab.consult)
            
            userScreen()
                .tabItem {
                    Label("Profile", image: "pm_ICON_PERFIL")
                }
                .tag(Tab.profile)
            
            chatScreen()
                .tabItem {
                    Label("Chat", image: "pm_ICON_CONSULTADINÁMIC")
                }
                .tag(Tab.chat)
        }
    }
}

#Preview {
    ContentView()
}
