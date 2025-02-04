//
//  WaypointListTableViewCell.swift
//  Cached
//
//  Created by Jeffrey Moulton on 11/24/19.
//  Copyright © 2019 Mobile Treasure Hunt. All rights reserved.
//

import UIKit

class WaypointListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var clueLabel: UILabel!
    @IBOutlet weak var latLabel: UILabel!
    @IBOutlet weak var longLabel: UILabel!
    @IBOutlet weak var radiusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var waypoints:[Waypoint] = []
    var waypointTable:UITableView?
    
    func setUpTable(){
        waypointTable?.delegate = self as? UITableViewDelegate
        waypointTable?.dataSource = self as? UITableViewDataSource
        self.addSubview(waypointTable!)
    }
    
    func tableView(waypointTable: UITableView, numberOfRowsInSection section: Int) -> Int{
        return waypoints.count
    }
    
    func numberOfSectionsInTableView(waypointTable: UITableView) -> Int {
        return 1
    }
    
    func tableView(waypointTable: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell? = waypointTable.dequeueReusableCell(withIdentifier: "waypoint_cell")
        
        cell?.textLabel?.text = waypoints[indexPath.row].name
        
        return cell!
    }
    
}
