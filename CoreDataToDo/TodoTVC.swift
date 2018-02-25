//
//  ViewController.swift
//  CoreDataToDo
//
//  Created by E Nicole Hinckley on 1/20/18.
//  Copyright © 2018 E Nicole Hinckley. All rights reserved.
//

import UIKit
import CoreData


class TodoTVC: UITableViewController {

    // MARK: - Properties
    
    var resultsController : NSFetchedResultsController<Todo>!
    let coreDataStack = CoreDataStack()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
       
        // Request
        let request : NSFetchRequest<Todo> = Todo.fetchRequest()
        let sortDescriptors = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [sortDescriptors]
        
        // Initialize the results controller
        resultsController = NSFetchedResultsController(fetchRequest: request,
                                                       managedObjectContext: coreDataStack.managedContext,
                                                       sectionNameKeyPath: nil,
                                                       cacheName: nil)
        
        // Perform the fetch
        do {
          try resultsController.performFetch()
        } catch {
            print(error)
        }
        
        resultsController.delegate  = self
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)
    
        let todo = resultsController.object(at: indexPath)
        cell.textLabel?.text = todo.name
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showAddTodo", sender: resultsController.object(at: indexPath))
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, complete) in
            let todo = self.resultsController.object(at: indexPath)
            self.resultsController.managedObjectContext.delete(todo)
            do {
                try self.resultsController.managedObjectContext.save()
                complete(true)
            } catch {
                print("Delete failed" , error)
                complete(false)
            }
        }
        action.image = #imageLiteral(resourceName: "delete")
        action.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, complete) in
            // MARK: - TODO: Delete items
            let todo = self.resultsController.object(at: indexPath)
            self.resultsController.managedObjectContext.delete(todo)
            do {
                try self.resultsController.managedObjectContext.save()
                complete(true)
            } catch {
                print("Delete failed" , error)
                complete(false)
            }
        }
        action.image = #imageLiteral(resourceName: "delete")
        action.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [action])

}
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let _ = sender as? UIBarButtonItem, let vc = segue.destination as? AddTodoListItemVC {
            vc.managedContext = resultsController.managedObjectContext
        }
        
        if let todo = sender as? Todo, let vc = segue.destination as? AddTodoListItemVC {
            vc.managedContext = resultsController.managedObjectContext
            vc.todo = todo
        }
    }
}

extension TodoTVC : NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert :
            if let indexPath = newIndexPath {
            tableView.insertRows(at: [indexPath], with: .automatic)
            }
        case .delete :
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .update :
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) {
                let todo = resultsController.object(at: indexPath)
                cell.textLabel?.text = todo.name
            }
        default : break
        }
    }
}

