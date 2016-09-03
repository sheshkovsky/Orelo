//
//  VoiceTableViewController.swift
//  Orelo
//
//  Created by sheshkovsky on 15/08/16.
//  Copyright © 2016 Ali Gholami. All rights reserved.
//

import UIKit
import CoreData


class VoiceTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: Properties
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let request = NSFetchRequest(entityName: "Voice")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        let frc = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil ,
            cacheName: nil)
        
        frc.delegate = self
        
        return frc
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem()

        do {
            try fetchedResultsController.performFetch()
            print("perform fetch is done!")
        } catch {
            print("An error occurred")
        }
        // commented due to deletion problem
        // self.tableView.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // return the number of sections
        if let sections = fetchedResultsController.sections {
            return sections.count
        } else { return 0 }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        } else { return 0 }
    }
    
    lazy var dateFormatter: NSDateFormatter = {
        var formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
        return formatter
    }()

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Configuration the cell
        let cellIdentifier = "VoiceTableViewCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! VoiceTableViewCell
        let obj = fetchedResultsController.objectAtIndexPath(indexPath) as! Voice
//        cell.titleLabel.text = obj.title
//        cell.durationLabel.text = dateFormatter.stringFromDate(obj.createdAt!)
        cell.textLabel?.text = obj.title
        // caused problem!!
//        cell.detailTextLabel!.text = dateFormatter.stringFromDate(obj.createdAt!)
        cell.detailTextLabel!.text = obj.duration
        
        // let voice = voices[indexPath.row]
        // cell.titleLabel.text = voice.title
        return cell
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }


    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let context = appDelegate.managedObjectContext
            let obj = fetchedResultsController.objectAtIndexPath(indexPath) as! Voice
            context.deleteObject(obj)
            do{
                try context.save()
            } catch let error {
                print("Core Data Error: \(error)")
            }
            // self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)

        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    // NSftechedresults delegation
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        // case .Insert:
        //    tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        // case .Insert:
        //    tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            return
            //Should also manage this case!!!
        //self.configureCell(tableView.cellForRowAtIndexPath(indexPath), atIndexPath: indexPath)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }

    
    
    
    
    // MARK: Prepare for segue to detial view
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showVoiceDetialSegue" {
            if let vdv = segue.destinationViewController as? VoiceDetialViewController {
                if let selectedVoiceCell = sender as? VoiceTableViewCell {
                    let indexPath = tableView.indexPathForCell(selectedVoiceCell)!
                    let selectedVoice = fetchedResultsController.objectAtIndexPath(indexPath) as! Voice
                    vdv.voice = selectedVoice
                }
            }
        }
    }
    
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
