//
//  StepsTableViewController.swift
//  HealthApp
//
//  Created by Tatsuya Moriguchi on 8/6/20.
//  Copyright © 2020 Tatsuya Moriguchi. All rights reserved.
//

import UIKit
import HealthKit

class StepsTableViewController: UITableViewController {
    
    
    var todayStep: Int = 0
    var stepDataSource: [[String: String]]? = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                
            }
        }
    }
    
    @IBAction func RefreshDataPressedOn(_ sender: UIBarButtonItem) {
        loadMostRecentSteps()
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HealthKitAssistant.shared.getHealthKitPermission { (response) in
            
            // MARK: Permission response
            self.loadMostRecentSteps()
            
            print("Hello World, this is a test.")
            print("here's more print Changed here again")
            print("Another text here")
            print("One more text added for a test")
            print("TEST for GitHub")
            
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    func loadMostRecentSteps() {
        guard let stepsdata = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        HealthKitAssistant.shared.getMostRecentStep(for: stepsdata) { (steps, stepsData ) in
            self.todayStep = steps
            self.stepDataSource = stepsData
            DispatchQueue.main.async {
                
                self.navigationItem.title = "\(self.todayStep)"
                //print("stepDataSource")
                //print(self.stepDataSource)
            }
        }
    }
    


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (stepDataSource?.count)!
    }
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

          let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // Configure the cell...
        
        cell.textLabel?.text = (stepDataSource![indexPath.row] as AnyObject).object(forKey: "steps") as? String
        cell.detailTextLabel?.text = (stepDataSource![indexPath.row] as AnyObject).object(forKey: "enddate") as? String
        
        print((stepDataSource![indexPath.row] as AnyObject).object(forKey: "steps") as? String as Any)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "steps"
    }

  
  
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
