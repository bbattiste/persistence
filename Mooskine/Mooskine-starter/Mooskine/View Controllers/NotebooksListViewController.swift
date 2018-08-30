//
//  NotebooksListViewController.swift
//  Mooskine
//
//  Created by Josh Svatek on 2017-05-31.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit
import CoreData

class NotebooksListViewController: UIViewController, UITableViewDataSource {
    /// A table view that displays a list of notebooks
    @IBOutlet weak var tableView: UITableView!
    
    var dataController: DataController!
    
    // Replacing var notebooks: [Notebook] = [] array that holds the data
    var fetchedResultsController: NSFetchedResultsController<Notebook>!
    
    fileprivate func setUpFetchedResultsController() {
        // 1. Create fetchRequest with sortDescriptors
        let fetchRequest: NSFetchRequest<Notebook> = Notebook.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // 2. Instantiate fetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "notebooks")
        
        // 3. Add NSFetchedResultsController.Delegate protocol above and set the delegate
        fetchedResultsController.delegate = self
        
        // 4. Call performFetch
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("the fecth could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "toolbar-cow"))
        navigationItem.rightBarButtonItem = editButtonItem
        
        setUpFetchedResultsController()
        updateEditButtonState()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }

    // -------------------------------------------------------------------------
    // MARK: - Actions

    @IBAction func addTapped(sender: Any) {
        presentNewNotebookAlert()
    }

    // -------------------------------------------------------------------------
    // MARK: - Editing

    /// Display an alert prompting the user to name a new notebook. Calls
    /// `addNotebook(name:)`.
    func presentNewNotebookAlert() {
        let alert = UIAlertController(title: "New Notebook", message: "Enter a name for this notebook", preferredStyle: .alert)

        // Create actions
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] action in
            if let name = alert.textFields?.first?.text {
                print(name)
                self?.addNotebook(name: name)
            }
        }
        saveAction.isEnabled = false

        // Add a text field
        alert.addTextField { textField in
            textField.placeholder = "Name"
            NotificationCenter.default.addObserver(forName: .UITextFieldTextDidChange, object: textField, queue: .main) { notif in
                if let text = textField.text, !text.isEmpty {
                    saveAction.isEnabled = true
                } else {
                    saveAction.isEnabled = false
                }
            }
        }

        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        present(alert, animated: true, completion: nil)
    }

    /// Adds a new notebook to the end of the `notebooks` array
    func addNotebook(name: String) {
        print("addNotebook: \(name)")
        let notebook = Notebook(context: dataController.viewContext)
        notebook.creationDate = Date()
        notebook.name = name
        try? dataController.viewContext.save()
    }
    
    /// Deletes the notebook at the specified index path
    func deleteNotebook(at indexPath: IndexPath) {
        let notebookToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(notebookToDelete)
        try? dataController.viewContext.save()
    }

    func updateEditButtonState() {
        if let sections = fetchedResultsController.sections {
            navigationItem.rightBarButtonItem?.isEnabled = sections[0].numberOfObjects > 0
        }
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }

    // -------------------------------------------------------------------------
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        print("test 1")
        var numberOfSections = 1
        print("****fetchedResultsController: \(fetchedResultsController)")
        print("*****.fetchedResultsController.sections: \(String(describing: fetchedResultsController.sections))")

        if fetchedResultsController.sections != nil {
            if let sections = fetchedResultsController.sections {
                print("test 1.5")
                numberOfSections = sections.count
            }
        } else {
            print("test 2")
            numberOfSections = 1
        }
        return numberOfSections
    }
    
        //return fetchedResultsController.sections?.count ?? 1
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("test 3")
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("test 5")
        let aNotebook = fetchedResultsController.object(at: indexPath)
        print("test 6")
        let cell = tableView.dequeueReusableCell(withIdentifier: NotebookCell.defaultReuseIdentifier, for: indexPath) as! NotebookCell
        print("test 7")

        // Configure cell
        cell.nameLabel.text = aNotebook.name
        print("test 8")
        if let count = aNotebook.notes?.count {
            print("test 9")
            let pageString = count == 1 ? "page" : "pages"
            print("test 10")
            cell.pageCountLabel.text = "\(count) \(pageString)"
            print("test 11")
        }
        print("test 12")
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete: deleteNotebook(at: indexPath)
        default: () // Unsupported
        }
    }

    // -------------------------------------------------------------------------
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("test 13")
        // If this is a NotesListViewController, we'll configure its `Notebook`
        if let vc = segue.destination as? NotesListViewController {
            print("test 14")
            if let indexPath = tableView.indexPathForSelectedRow {
                print("test 15")
                vc.notebook = fetchedResultsController.object(at: indexPath)
                print("test 16")
                vc.dataController = dataController
                print("test 17")
            }
        }
    }
}

// update table when fetch results controller receives notification that object has been added, deleted, or changed
extension NotebooksListViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("test 18")
        tableView.beginUpdates()
        print("test 19")
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("test 20")
        tableView.endUpdates()
        print("test 21")
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        print("test 22")
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        default:
            break
        }
    }
}
