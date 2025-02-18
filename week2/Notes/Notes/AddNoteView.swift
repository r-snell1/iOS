//
//  AddNoteView.swift
//  Notes
//
//  Created by Ryan A Snell on 2/17/25.
//
import SwiftUI
import CoreData

struct AddNoteView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var note: Item?

    // Initialize with an existing note if available
    init(note: Item? = nil) {
        self._note = State(initialValue: note)
        _title = State(initialValue: note?.title ?? "")
        _content = State(initialValue: note?.content ?? "")
    }

    var body: some View {
        VStack {
            TextField("Title", text: $title)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextEditor(text: $content)
                .padding()
                .border(Color.gray, width: 1)
            
            Spacer()
        }
        .onAppear {
            // Create a new note if none exists
            if note == nil {
                let newNote = Item(context: viewContext)
                newNote.dateCreated = Date()
                self.note = newNote
            }
        }
        .onChange(of: title) { _ in
            autosave()
        }
        .onChange(of: content) { _ in
            autosave()
        }
        .navigationTitle("New Note")
    }
    
    private func autosave() {
        if let note = note {
            note.title = title
            note.content = content
            note.dateCreated = Date()

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
