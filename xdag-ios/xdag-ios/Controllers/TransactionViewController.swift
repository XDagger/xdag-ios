//
//  TransactionViewController.Swift
//  xdag-ios
//
//  Created by yangyin on 2018/2/27.
//  Copyright © 2018年 xdag.org. All rights reserved.
//

import UIKit

class TransactionViewController: UITableViewController {

    private let items = [
        XDAGTransaction(txHash: "eAHUyypJGd...jG4nIzMFjNhAlDV7h ", txType: 1, txAmount: 0.001, txTime: "3秒前"),
        XDAGTransaction(txHash: "asdfdedd...jG4nIzMFjNhAlDV7h ", txType: 0, txAmount: 5.120, txTime: "2分前"),
        XDAGTransaction(txHash: "d3dd3dc...jG4nIzMFjNhAlDV7h ", txType: 0, txAmount: 1.200, txTime: "2018-02-28"),
        XDAGTransaction(txHash: "deasdf3...jG4nIzMFjNhAlDV7h ", txType: 1, txAmount: 3.231, txTime: "2018-02-28"),
        XDAGTransaction(txHash: "oiinknijd...jG4nIzMFjNhAlDV7h ", txType: 1, txAmount: 4.32, txTime: "2018-02-27")
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 60;
        self.tableView.rowHeight = UITableViewAutomaticDimension
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
     
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }


     override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 20
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "txTableViewCell", for: indexPath) as! TransactionTableViewCell
        
        cell.setData(tx: items[indexPath.row % 5])
//         Configure the cell...
//        cell.textLabel?.text = String(indexPath.row)
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
