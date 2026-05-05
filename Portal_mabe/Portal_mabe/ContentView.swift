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
                    Image("pm_ICON_MENU")
                        .resizable()
                        .aspectRatio(contentMode: .fit)

                }
                .tag(Tab.consult)
            
            userScreen()
                .tabItem {
                    Image("pm_ICON_PERFIL")
                        .resizable()
                        .aspectRatio(contentMode: .fit)

                }
                .tag(Tab.profile)
            
            consultaDinamicaScreen()
                .tabItem {
                    Image("pm_ICON_CONSULTADINAMIC")
                        .resizable()
                        .aspectRatio(contentMode: .fit)

                }
                .tag(Tab.chat)
        }
    }
}

#Preview {
    ContentView()
}
