//
//  PopularMentionTableViewController.swift
//  SmashTag
//
//  Created by Vignesh Saravanai on 18/06/16.
//  Copyright © 2016 Vignesh Saravanai. All rights reserved.
//

import UIKit
import CoreData

class PopularMentionTableViewController: CoreDataTableViewController {
    
    var searchText: String? { didSet { updateUI() } }
    
    private func updateUI() {
        if searchText?.characters.count > 0 {
            let context = (UIApplication.sharedApplication().delegate as! AppDelegate).dataController.managedObjectContext
            let request = NSFetchRequest(entityName: "SearchMentionCount")
            request.predicate = NSPredicate(format: "searchText.text = %@ and count > 1", searchText!)
            request.sortDescriptors = [NSSortDescriptor(key:"mention.type", ascending: false),
                                       NSSortDescriptor(key:"count", ascending: false),
                                       NSSortDescriptor(key:"mention.text", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
            fetchedResultsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: "mention.type",
                cacheName: nil)
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MentionCell", forIndexPath: indexPath)

        if let smCount = fetchedResultsController?.objectAtIndexPath(indexPath) as? SearchMentionCount {
            smCount.managedObjectContext?.performBlock {
                cell.textLabel?.text = smCount.mention?.text
                cell.detailTextLabel?.text = "\(smCount.count!)"
            }
        }
        return cell
    }
   

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
