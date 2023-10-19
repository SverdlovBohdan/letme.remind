import SwiftUI

struct MainView: View {
    @StateObject var navigationStore: NavigationStore = .makeDefault()
    
    var setNavigationStore: (NavigationStore) -> Void
    
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
        .environmentObject(navigationStore)
        .onAppear(perform: {
            setNavigationStore(navigationStore)
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView { _ in
            
        }
    }
}
