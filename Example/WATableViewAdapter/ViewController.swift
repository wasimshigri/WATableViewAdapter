//
//  ViewController.swift
//  WATableViewAdapter
//
//  Created by wasimshigri on 07/09/2018.
//  Copyright (c) 2018 wasimshigri. All rights reserved.
//

import UIKit
import SwipeCellKit
import WATableViewAdapter

class ViewController: UIViewController,WATableViewDataSource,WATableViewDelegate{
    
    
    @IBOutlet weak var  tableview:UITableView! = nil
    
    lazy var waTableViewAdapter:WATableViewAdapter = {
        return WATableViewAdapter.init(datasource: self, delegate: self);
    }();
    override func viewDidLoad() {
        super.viewDidLoad()
        waTableViewAdapter.tableview = tableview;
        self.waTableViewAdapter.tableview = self.tableview
        self.waTableViewAdapter.reloadData(dataList: getUserDataList());
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    func waTableViewHeightFor(cellAtIndexLevel indexLevel: Int, forData data: Any?) -> CGFloat {
        return 75;
    }
    func waTableViewCellFor(indexPath: IndexPath, forIndexLevel indexLevel: Int, forData data: Any, forTableView tableview: UITableView) -> WATableViewCell {
        switch indexLevel {
        case 0:
            if let cell = tableview.dequeueReusableCell(withIdentifier: "cell0", for: indexPath) as? WATableViewCell{
                var d = (data as! ItemDataModel).data as! SampleDatModel;
                cell.title.text = d.title;
                cell.subTitle.text = d.subTitle;
                return cell;
            }
            return WATableViewCell();
        case 1:
            if let cell = tableview.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as? WATableViewCell{
                var d = (data as! ItemDataModel).data as! SampleDatModel;
                cell.title.text = d.title;
                cell.subTitle.text = d.subTitle;
                return cell;
            }
            return WATableViewCell();
        case 2:
            if let cell = tableview.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as? WATableViewCell{
                var d = (data as! ItemDataModel).data as! SampleDatModel;
                cell.title.text = d.title;
                cell.subTitle.text = d.subTitle;
                return cell;
            }
            return WATableViewCell();
        default:
            return WATableViewCell();
        }
        
    }
    
    func waTableViewCellSelectionChanged(toStatus: Bool, cell: UITableViewCell, atIndexLevel indexLevel: Int, forData data: Any?) {
        if let c = cell as? WATableViewCell {
            if toStatus {
                c.title.textColor = UIColor.green
                c.subTitle.textColor = UIColor.green
            } else {
                c.title.textColor = UIColor.black
                c.subTitle.textColor = UIColor.black
            }
        }
    }
    func waTableViewUpdateCellFor(selectionStatus: Bool, cell: UITableViewCell, atIndexLevel indexLevel: Int, forData data: Any?) {
        if let c = cell as? WATableViewCell {
            if selectionStatus {
                c.title.textColor = UIColor.green
                c.subTitle.textColor = UIColor.green
            } else {
                c.title.textColor = UIColor.black
                c.subTitle.textColor = UIColor.black
            }
        }
    }
    
    func waTableView(cellAtIndexLevel indexLevel: Int, for orientation: WASwipeActionsOrientation, itemData: ItemDataModel, isSelected: Bool,isExpended:Bool) -> [SwipeAction]? {
        
        if itemData.childerns != nil && (itemData.childerns?.count ?? 0) > 0 {
            if isExpended == false {
                return nil;
            }
        }
        
        //        if isSelected == false {
        //            return nil;
        //        }
        
        if orientation == .right {
            
            let deleteAction = SwipeAction(style: .destructive, title: "Delete1") { action, indexPath in
                // handle action by updating model with deletion
            }
            
            // customize the action appearance
            
            return [deleteAction]
        }else if orientation == .left{
            let deleteAction = SwipeAction(style: .default, title: "Success1") { action, indexPath in
                // handle action by updating model with deletion
            }
            deleteAction.backgroundColor = UIColor.green;
            return [deleteAction]
        }
        return nil;
    }
    func getUserDataList()->[ItemDataModel]{
        var listData = [ItemDataModel]()
        for i in 0..<10{
            let item = ItemDataModel();
            var cList  = [ItemDataModel]()
            let s = SampleDatModel()
            s.title = "Title \(i)}"
            item.data = s;
            for j in 0..<i{
                let item1 = ItemDataModel();
                var cList1  = [ItemDataModel]()
                let s1 = SampleDatModel()
                s1.title = "Title \(i):\(j)}"
                item1.data = s1;
                for k in 0..<j{
                    let item2 = ItemDataModel();
                    cList1.append(item2)
                    let s2 = SampleDatModel()
                    s2.title = "Title \(i):\(j):\(k)}"
                    item2.data = s2;
                }
                item1.childerns = cList1;
                cList.append(item1);
            }
            item.childerns = cList;
            listData.append(item);
        }
        return listData;
    }
}



