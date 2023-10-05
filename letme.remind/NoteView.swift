import SwiftUI
import Combine

struct NoteView: View {
    @AppStorage(NotesPersitenceKeys.notesToRemindKey) var notesPayload: Data = Data()
    @AppStorage(NotesPersitenceKeys.unhandledNotes) var unhandledNotesPayload: Data = Data()
    
    @StateObject private var store: MakeNewNoteStore = .makeDefault()
    @State private var remindOption: WhenToRemind = .within7Days
    
    // TODO: Use DI
    private var notesWriter: NotesWriter = NotesPersistence.standart
    // TODO: Use DI
    private var notifications: LocalNotificationScheduler = Notifications.standart
    
    private let noteToPreview: Note?
    private var isPreview: Bool {
        noteToPreview != nil
    }
    
    typealias DoneCallback = () -> Void
    private var doneCallback: DoneCallback?
    
    init(note: Note? = nil, didSave: DoneCallback? = nil) {
        self.noteToPreview = note
        self.doneCallback = didSave
    }
    
    var confirmationActionText: String {
        isPreview ? "Reschedule" : "Save"
    }
    
    var body: some View {
        Form {
            Picker("when to remind", selection: $remindOption) {
                Text("Within 7 days").tag(WhenToRemind.within7Days)
                Text("Within 30 days").tag(WhenToRemind.within30Days)
                Text("In this month").tag(WhenToRemind.inThisMonth)
                Text("Random").tag(WhenToRemind.someday)
            }
            .pickerStyle(.inline)
            
            Section {
                TextField("Title", text: makeTitleBinding())
                
                TextField("Note content", text: makeContentBinding(),
                          axis: .vertical)
                .lineLimit(10, reservesSpace: true)
            } header: {
                Text("note")
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .confirmationAction) {
                Button(confirmationActionText) {
                    tryToScheduleNewNote(when: remindOption)
                }
                .disabled(!store.isValid)
            }
            
            ToolbarItemGroup(placement: .cancellationAction) {
                Button("Forget") {
                    assert(noteToPreview != nil, "Call 'Forget' without known Note")
                    forget(note: noteToPreview!, from: $notesPayload)
                }
                .foregroundStyle(.red)
                .disabled(!isPreview)
                .opacity(isPreview ? 1.0 : 0.0)
            }
        }
        .onAppear(perform: {
            acceptPreviewDataIfExist()
        })
    }
    
    private func acceptPreviewDataIfExist() {
        if !isPreview {
            return
        }
        
        store.dispatch(action: .fillBy(noteToPreview!))
    }
    
    private func forget(note: Note, from notes: Binding<Data>) {
        notesWriter.remove(noteToPreview!, from: $notesPayload)
        notesWriter.remove(noteToPreview!, from: $unhandledNotesPayload)
        doneCallback?()
    }
    
    private func makeTitleBinding() -> Binding<String> {
        return Binding {
            store.title
        } set: {
            store.title = $0
            store.dispatch(action: .validate)
        }
    }
    
    private func makeContentBinding() -> Binding<String> {
        return Binding {
            store.content
        } set: {
            store.content = $0
            store.dispatch(action: .validate)
        }
    }
    
    private func tryToScheduleNewNote(when: WhenToRemind) -> Void {
        if store.isValid {
            let newNote: Note = Note(title: store.title,
                                     content: store.content)
            Task { @MainActor in
                let result = await notifications.schedule(note: newNote, when: remindOption)
                
                switch result {
                case .success(_):
                    /// TODO: extend writer by rewrite()
                    if isPreview {
                        notesWriter.remove(noteToPreview!, from: $notesPayload)
                        notesWriter.remove(noteToPreview!, from: $unhandledNotesPayload)
                    }
                    
                    notesWriter.write(newNote,to: $notesPayload)
                    doneCallback?()
                case .failure(_):
                    break
                }
            }
        }
    }
}

struct NoteMakingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NoteView()
        }
    }
}
