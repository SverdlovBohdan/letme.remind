import SwiftUI
import Combine

struct NoteView: View {
    @AppStorage(NotesPersitenceKeys.notesToRemindKey) private var notesPayload: Data = Data()
    @AppStorage(NotesPersitenceKeys.unhandledNotes) private var unhandledNotesPayload: Data = Data()
    @AppStorage(NotesPersitenceKeys.notesArchive) private var notesArchivePayload: Data = Data()
    
    @StateObject private var store: MakeNewNoteStore = .makeDefault()
    @State private var remindOption: WhenToRemind = .within7Days
    
    private var notesWriter: NotesWriter = Environment.forceResolve(type: NotesWriter.self)
    private var notifications: LocalNotificationScheduler =
    Environment.forceResolve(type: LocalNotificationScheduler.self)
    
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
        isPreview ? String(localized: "Reschedule") : String(localized: "Schedule")
    }
    
    var body: some View {
        Form {
            Picker(String(localized: "Remind"), selection: $remindOption) {
                Text(String(localized: "Within 7 days")).tag(WhenToRemind.within7Days)
                Text(String(localized: "Within 30 days")).tag(WhenToRemind.within30Days)
                Text(String(localized: "In this month")).tag(WhenToRemind.inThisMonth)
                Text(String(localized: "Random")).tag(WhenToRemind.someday)
            }
            .pickerStyle(.inline)
            
            Section {
                ColorTagPickerView { colorTag in
                    store.dispatch(action: .setColorTag(colorTag))
                }
            } header: {
                Text(String(localized: "tags"))
            }
            
            Section {
                TextField(String(localized: "Title"), text: makeTitleBinding())
                
                TextField(String(localized: "Note content"),
                          text: makeContentBinding(),
                          axis: .vertical)
                .lineLimit(10, reservesSpace: true)
            } header: {
                Text(String(localized: "note"))
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
                Button(String(localized: "Forget")) {
                    assert(noteToPreview != nil, "Call 'Forget' without known Note")
                    forget(note: noteToPreview!)
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
    
    private func forget(note: Note) {
        notesWriter.remove(note, from: $notesPayload)
        notesWriter.remove(note, from: $unhandledNotesPayload)
        notesWriter.write(note, to: $notesArchivePayload)
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
                                     content: store.content,
                                     color: store.colorTag)
            Task { @MainActor in
                let result = await notifications.schedule(note: newNote, when: remindOption)
                
                switch result {
                case .success(_):
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
