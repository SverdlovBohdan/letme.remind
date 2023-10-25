import SwiftUI
import Combine

struct NoteView: View {    
    @StateObject private var store: MakeNewNoteStore = .makeDefault()
    @State private var remindOption: WhenToRemind = .within7Days
    
    private var noteArchiver: NoteArchiver = AppEnvironment.forceResolve(type: NoteArchiver.self)
    private var noteScheduler: NoteScheduler = AppEnvironment.forceResolve(type: NoteScheduler.self)
    
    private let noteToPreview: Note?
    private var isPreview: Bool {
        noteToPreview != nil
    }
    
    typealias DoneCallback = () -> Void
    private var doneCallback: DoneCallback?
    
    typealias ErrorCallback = (ScheduleError) -> Void
    private var errorCallback: ErrorCallback?
    
    init(note: Note? = nil, didSave: DoneCallback? = nil, onError: ErrorCallback? = nil) {
        self.noteToPreview = note
        self.doneCallback = didSave
        self.errorCallback = onError
    }
    
    var confirmationActionText: String {
        isPreview ? String(localized: "Reschedule") : String(localized: "Schedule")
    }
    
    var body: some View {
        ScrollView {
            HStack {
                Text(String(localized: "Remind"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                
                Spacer()
                
                Picker(String(localized: "Remind"), selection: $remindOption) {
                    Text(String(localized: "Within 7 days")).tag(WhenToRemind.within7Days)
                    Text(String(localized: "Within 30 days")).tag(WhenToRemind.within30Days)
                    Text(String(localized: "In this month")).tag(WhenToRemind.inThisMonth)
                    Text(String(localized: "Random")).tag(WhenToRemind.someday)
                }
                .pickerStyle(.menu)
            }
            
            HStack {
                Text(String(localized: "tags"))
                    .padding(.top)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                Spacer()
            }
            
            ColorTagPickerView { colorTag in
                store.dispatch(action: .setColorTag(colorTag))
            }
            
            TagsInputView(color: store.colorTag) { tags in
                store.dispatch(action: .setTags(tags))
            }
            Divider()
            
            HStack {
                Text(String(localized: "note"))
                    .padding(.top)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                
                Spacer()
            }
            
            TextField(String(localized: "Title"), text: makeTitleBinding())
            Divider()
            
            TextField(String(localized: "Note content"),
                      text: makeContentBinding(),
                      axis: .vertical)
            .lineLimit(15)
            
            Spacer()
        }
        .padding()
        .toolbar {
            ToolbarItemGroup(placement: .confirmationAction) {
                Button(confirmationActionText) {
                    tryToScheduleNewNote()
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
        noteArchiver.addToArchive(note)
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
    
    private func tryToScheduleNewNote() -> Void {
        Task { @MainActor in
            if store.isValid {
                let newNote: Note = Note(title: store.title,
                                         content: store.content,
                                         color: store.colorTag)
                var result: Result<Void, ScheduleError> = .failure(.failed)
                if isPreview {
                    result = await noteScheduler.rescheduleNote(note: newNote, oldNote: noteToPreview!,
                                                                when: remindOption)
                } else {
                    result = await noteScheduler.scheduleNote(note: newNote, when: remindOption)
                }
                
                switch result {
                case .success(_):
                    doneCallback?()
                case .failure(let error):
                    errorCallback?(error)
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
