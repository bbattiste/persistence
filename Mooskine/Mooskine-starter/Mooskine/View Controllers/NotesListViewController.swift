//
//  NotesListViewController.swift
//  Mooskine
//
//  Created by Josh Svatek on 2017-05-31.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit
import CoreData

class NotesListViewController: UIViewController, UITableViewDataSource {
    /// A table view that displays a list of notes for a notebook
    @IBOutlet weak var tableView: UITableView!

    /// The notebook whose notes are being displayed
    var notebook: Notebook!

    var notes:[Note] = []
    
    var dataController: DataController!
    
    /// A date formatter for date text in note cells
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
                
        navigationItem.title = notebook.name
        navigationItem.rightBarButtonItem = editButtonItem
        
        print("******Test 1")
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        
        print("******Test 2")
        let predicate = NSPredicate(format: "notebook == %@", notebook)
        
        print("******Test 3")
        fetchRequest.predicate = predicate
        
        print("******Test 4")
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        
        print("******Test 5")
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        print("******Test 6")
        print("+++++++++dataController: \(dataController)")
        print("+++++++++dataController.viewContext: \(dataController.viewContext)")
        print("+++++++++fetchRequest: \(fetchRequest)")
        print("+++++++++notebook: \(notebook)")
        print("+++++++++notes: \(notes)")
        
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            print("******Test 7")
            notes = result
            print("******Test 7")
            tableView.reloadData()
            print("******Test 8")
        }
        
        updateEditButtonState()
    }

    override func viewWillAppear(_ animated: Bool) {
        print("+++test 13")
        super.viewWillAppear(animated)

        if let indexPath = tableView.indexPathForSelectedRow {
            print("+++test 14")
            tableView.deselectRow(at: indexPath, animated: false)
            print("+++test 15")
            tableView.reloadRows(at: [indexPath], with: .fade)
            print("+++test 16")
        }
    }

    // -------------------------------------------------------------------------
    // MARK: - Actions

    @IBAction func addTapped(sender: Any) {
        addNote()
    }

    // -------------------------------------------------------------------------
    // MARK: - Editing

    // Adds a new `Note` to the end of the `notebook`'s `notes` array
    func addNote() {
        let note = Note(context: dataController.viewContext)
        note.text = "New note"
        note.creationDate = Date()
        note.noteBook = notebook
        try? dataController.viewContext.save()
        notes.insert(note, at:0)
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
        updateEditButtonState()
    }

    // Deletes the `Note` at the specified index path
    func deleteNote(at indexPath: IndexPath) {
        let noteToDelete = note(at: indexPath)
        dataController.viewContext.delete(noteToDelete)
        try? dataController.viewContext.save()
        notes.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        if numberOfNotes == 0 {
            setEditing(false, animated: true)
        }
        updateEditButtonState()
    }

    func updateEditButtonState() {
        navigationItem.rightBarButtonItem?.isEnabled = numberOfNotes > 0
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }

    // -------------------------------------------------------------------------
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfNotes
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aNote = note(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: NoteCell.defaultReuseIdentifier, for: indexPath) as! NoteCell

        // Configure cell
        cell.textPreviewLabel.text = aNote.text
        if let creationDate = aNote.creationDate {
            cell.dateLabel.text = dateFormatter.string(from: creationDate)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete: deleteNote(at: indexPath)
        default: () // Unsupported
        }
    }

    // Helpers

    var numberOfNotes: Int { return notes.count }

    func note(at indexPath: IndexPath) -> Note {
        return notes[indexPath.row]
    }

    // -------------------------------------------------------------------------
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If this is a NoteDetailsViewController, we'll configure its `Note`
        // and its delete action
        if let vc = segue.destination as? NoteDetailsViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                vc.note = note(at: indexPath)

                vc.onDelete = { [weak self] in
                    if let indexPath = self?.tableView.indexPathForSelectedRow {
                        self?.deleteNote(at: indexPath)
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
}
