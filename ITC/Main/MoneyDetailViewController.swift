//
//  MoneyDetailViewController.swift
//  ITC
//
//  Created by 果儿 on 2017/5/16.
//  Copyright © 2017年 YunTu. All rights reserved.
//

import UIKit
import SVProgressHUD

class MoneyDetailViewController: UITableViewController {
    
    var MoneyList = [[String:String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "余额明细"
        SVProgressHUD.show()
        NetworkModel.requestGet([:], url: "http://112.74.124.86/ybb/index.php?app=appsdefault&act=banner_list") { (dic) in
            SVProgressHUD.dismiss()
            self.MoneyList = [["payment":"充值","money":"600","orderid":"20170201142755471","time":"2017-02-01"],
                              ["payment":"扣款","money":"-25","orderid":"20170204173513941","time":"2017-02-04"],
                              ["payment":"扣款","money":"-25","orderid":"20170209133524235","time":"2017-02-09"],
                              ["payment":"扣款","money":"-25","orderid":"20170215112841621","time":"2017-02-15"],
                              ["payment":"扣款","money":"-25","orderid":"20170324212853361","time":"2017-03-24"]]
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MoneyList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let dic = MoneyList[indexPath.row]
        (cell.viewWithTag(1) as! UILabel).text = dic["payment"]
        (cell.viewWithTag(2) as! UILabel).text = dic["money"]
        (cell.viewWithTag(3) as! UILabel).text = dic["orderid"]
        (cell.viewWithTag(4) as! UILabel).text = dic["time"]

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
