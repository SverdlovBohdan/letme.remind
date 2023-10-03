import SwiftUI



struct MainView: View {
    var body: some View {
        TabView {
            HomeView()
            .tabItem {
                Label("Home", systemImage: "square.and.pencil")
            }
            
            ArchiveView()
            .badge(13)
            .tabItem {
                Label("Archive", systemImage: "archivebox")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
