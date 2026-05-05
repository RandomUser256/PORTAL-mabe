import SwiftUI

struct ContentView: View {
    enum Tab {
        case menu
        case perfil
        case consulta
    }

    @State private var selectedTab: Tab = .perfil

    var body: some View {
        TabView {
            menuScreen()
                .tabItem {
                    Image("pm_ICON_MENU")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .tag(Tab.menu)
            
            userScreen()
                .tabItem {
                    Image("pm_ICON_PERFIL")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .tag(Tab.perfil)
            
            consultaDinamicaScreen()
                .tabItem {
                    Image("pm_ICON_CONSULTADINÁMIC")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .tag(Tab.consulta)
        }
    }
}

#Preview {
    ContentView()
}
