//
//  HomeView.swift
//  letme.remind
//
//  Created by Bohdan Sverdlov on 15.09.2023.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var navigation: NavigationStore
    @AppStorage(NotesPersitenceKeys.notesToRemindKey) private var notesPayload: Data = Data()
    @AppStorage(NotesPersitenceKeys.unhandledNotes) private var unhandledNotesPayload: Data = Data()
    @StateObject private var viewStore: HomeViewStore = .makeDefault()
    
    private var notificationPermissions: LocalNotificationPermissionsProvider =
    AppEnvironment.forceResolve(type: LocalNotificationPermissionsProvider.self)
    
    private var notesReader: NotesReader = AppEnvironment.forceResolve(type: NotesReader.self)
    private var unhadledNotesProvider: UnhandlerNotesProvider =
        AppEnvironment.forceResolve(type: UnhandlerNotesProvider.self)
    
#if DEBUG
    private var notesWriter: NotesWriter = AppEnvironment.forceResolve(type: NotesWriter.self)
#endif
    
    var body: some View {
        NavigationStack(path: $navigation.navigationPath) {
            VStack {
                Group {
                    Text("\(notesReader.count($notesPayload))")
                        .font(.largeTitle)
                    Text(String(localized: "notes in memory"))
                }
                
                if notesReader.count($unhandledNotesPayload) != 0 {
                    List {
                        Section {
                            ForEach(notesReader.read(from: $unhandledNotesPayload), id: \.self) { unhandledNote in
                                NoteRowView(note: unhandledNote)
                            }
                        } header: {
                            Text(String(localized: "Reminded notes"))
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .animation(.bouncy, value: unhandledNotesPayload)
            .alert(isPresented: $viewStore.isLocalNotificationsAlertAreDisabledPresented) {
                Alert(title: Text(String(localized: "Local notifications are disabled")),
                      message: Text(String(localized: "You can enable local notifications in settings")),
                      primaryButton: .default(Text(String(localized: "Open settings")), action: openSettings),
                      secondaryButton: .cancel())
            }
            .navigationDestination(isPresented: $viewStore.isMakingNoteViewPresented) {
                NoteView {
                    closeMakingNoteView()
                } onError: { error in
                    if error == .nopermissions {
                        showNotificationsAreDisabledAlert()
                    }
                }
            }
            .navigationDestination(for: NoteId.self, destination: { noteId in
                NoteView(note: notesReader.one(by: noteId.noteId, from: $notesPayload)) {
                    closePreviewNoteView()
                } onError: { error in
                    if error == .nopermissions {
                        showNotificationsAreDisabledAlert()
                    }
                }
                .navigationBarBackButtonHidden()
            })
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            let isPermissionGranted: Bool = await notificationPermissions.isLocalNotificationPermissionsGranted()
                            isPermissionGranted ? showMakingNoteView() : showNotificationsAreDisabledAlert()
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .task {
                await updateUnhandledNotes()
            }
            
#if DEBUG
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        Task {
                            let newNote: Note = Note(tags: ["adasd", "23123", "asdasdas"],
                                                     title: "testTitle", content: "Testcontn",
                                                     color: Color.green.description)
                            Notifications.standart.scheduleTestNotification(note: newNote)
                            notesWriter.write(newNote,to: $notesPayload)
                        }
                    } label: {
                        Image(systemName: "note.text.badge.plus")
                    }
                }
            }
#endif
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
    
    private func updateUnhandledNotes() async {
        await unhadledNotesProvider.populateUnhandledNotes()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(NavigationStore.makeDefault())
    }
}
