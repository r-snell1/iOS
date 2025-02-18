//
//  ContentView.swift
//  Notes
//
//  Created by Ryan A Snell on 2/17/25.
//

import SwiftUI
import CoreData

struct NotesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isAddingNote: Bool = false
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.dateCreated, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(items) { item in
                        NavigationLink {
                            Text("\(item.content ?? "No Content")")
                        } label: {
                            Text(item.title ?? "Untitled")
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                    ToolbarItem {
                        Button(action: {
                            isAddingNote.toggle()
                        }) {
                            Label("Add Note", systemImage: "plus")
                        }
                    }
                }
                NavigationLink(destination: AddNoteView(), isActive: $isAddingNote) {
                    EmptyView()
                }
                .navigationDestination(for: Bool.self) { isAddingNote in
                    AddNoteView()
                }
            }
            .navigationTitle("Notes")
            .padding()
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Handle error properly
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    NotesView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
