//
//  Model.swift
//  Notes
//
//  Created by Ryan A Snell on 2/17/25.
//

import CoreData
import UIKit

class NotesModel {
    
    // Fetch all notes
    static func fetchAllNotes(context: NSManagedObjectContext) -> [Item]? {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        do {
            let notes = try context.fetch(fetchRequest)
            return notes
        } catch {
            print("Error fetching notes: \(error)")
            return nil
        }
    }

    // Save a new note
    static func saveNewNote(title: String, content: String, context: NSManagedObjectContext) {
        let newNote = Item(context: context)
        newNote.title = title
        newNote.content = content
        newNote.dateCreated = Date()

        do {
            try context.save()
        } catch {
            print("Error saving note: \(error)")
        }
    }

    // Delete a note
    static func deleteNote(note: Item, context: NSManagedObjectContext) {
        context.delete(note)
        do {
            try context.save()
        } catch {
            print("Error deleting note: \(error)")
        }
    }
}
