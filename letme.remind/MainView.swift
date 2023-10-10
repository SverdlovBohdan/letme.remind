import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label(String(localized: "Home"), systemImage: "square.and.pencil")
                }
            
            ArchiveView()
                .tabItem {
                    Label(String(localized: "Archive"), systemImage: "archivebox")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(NavigationStore.makeDefault())
    }
}
