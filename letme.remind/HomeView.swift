//
//  HomeView.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 15.09.2023.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var navigation: NavigationStore
    @AppStorage(NotesPersitenceKeys.notesToRemindKey) var notesPayload: Data = Data()
    @AppStorage(NotesPersitenceKeys.unhandledNotes) var unhandledNotesPayload: Data = Data()
    @StateObject var viewStore: HomeViewStore = .makeDefault()
    
    // TODO: Use DI
    private var notifications: LocalNotificationPermissionsProvider = Notifications.standart
    
    // TODO: Use DI
    private var notesReader: NotesReader = NotesPersistence.standart
    
    // DELETE. For manual tests only
    private var notesWriter: NotesWriter = NotesPersistence.standart
    
    @State var count: Int = 0
    
    var body: some View {
        NavigationStack(path: $navigation.navigationPath) {
            VStack {
                let _ = Self._printChanges()
                
                Text("\(notesReader.count($notesPayload))")
                    .font(.largeTitle)
                Text("notes in memory")
                
                Button("Test notification") {
                    let newNote: Note = Note(title: "testTitle", content: "Testcontn")
                    Notifications.standart.scheduleTestNotification(note: newNote)
                    notesWriter.write(newNote,to: $notesPayload)
                }
                
                Text("Delivered notifications \(count)")
                Button("Refresh notificaitons count") {
                    Task { @MainActor in
                        count = await UNUserNotificationCenter.current().deliveredNotifications().count
                    }
                }
                
                if notesReader.count($unhandledNotesPayload) != 0 {
                    List {
                        Section {
                            ForEach(notesReader.read(from: $unhandledNotesPayload), id: \.self) { unhandledNote in
                                UnhandledNoteRowView(note: unhandledNote)
                            }
                        } header: {
                            Text("Unhandled notes")
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .alert(isPresented: $viewStore.isLocalNotificationsAlertAreDisabledPresented) {
                Alert(title: Text("Local notifications are disabled"),
                      message: Text("You can enable local notifications in settings"),
                      primaryButton: .default(Text("Open settings"), action: openSettings),
                      secondaryButton: .cancel())
            }
            .navigationDestination(isPresented: $viewStore.isMakingNoteViewPresented) {
                NoteView {
                    closeMakingNoteView()
                }
            }
            .navigationDestination(for: NoteId.self, destination: { noteId in
                NoteView(note: notesReader.one(by: noteId.noteId, from: $notesPayload)) {
                    closePreviewNoteView()
                }
                .navigationBarBackButtonHidden()
            })
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            let isPermissionGranted: Bool = await notifications.isLocalNotificationPermissionsGranted()
                            isPermissionGranted ? showMakingNoteView() : showNotificationsAreDisabledAlert()
                        }
                    } label: {
                        Image(systemName: "plus")
                            .imageScale(.large)
                    }
                }
            }
        }
    }
    
    private func openSettings() {
        if let settingUrl = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(settingUrl) {
                Task {
                    await UIApplication.shared.open(settingUrl)
                }
            }
        }
    }
    
    private func closePreviewNoteView() {
        navigation.dispatch(action: .openRootView)
    }
    
    private func closeMakingNoteView() {
        viewStore.dispatch(action: .closeMakingNoteView)
    }
    
    private func showMakingNoteView() {
        viewStore.dispatch(action: .showMakingNoteView)
    }
    
    private func showNotificationsAreDisabledAlert() {
        viewStore.dispatch(action: .showLocalNotificationsAlertAreDisabled)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(NavigationStore.makeDefault())
    }
}
