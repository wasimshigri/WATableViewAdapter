//
//  WATableViewAdapter.swift
//  multiLevelTable
//
//  Created by Waseem Ahmed on 5/4/18.
//  Copyright © 2018 Waseem Ahmed. All rights reserved.
//



import UIKit
import SwipeCellKit

 @objc public protocol WATableViewDataSource {
    func waTableViewHeightFor(cellAtIndexLevel indexLevel:Int,forData data:Any?)->CGFloat;
    func waTableViewCellFor(indexPath:IndexPath, forIndexLevel indexLevel:Int,forData data:Any, forTableView tableview:UITableView)->WATableViewCell;
    @objc optional func waTableView(cellAtIndexLevel indexLevel: Int, for orientation: WASwipeActionsOrientation, itemData:ItemDataModel, isSelected:Bool,isExpended: Bool) -> [SwipeAction]?;

}

@objc public protocol WATableViewDelegate {
    @objc optional func waTableViewCellSelectionChanged(toStatus:Bool,cell:UITableViewCell,atIndexLevel indexLevel:Int,forData data:Any?);
    @objc optional func waTableViewUpdateCellFor(selectionStatus:Bool,cell:UITableViewCell,atIndexLevel indexLevel:Int,forData data:Any?);
}

open class WATableViewAdapter: NSObject ,UITableViewDelegate,UITableViewDataSource,SwipeTableViewCellDelegate{
    
    open var  tableview:UITableView? = nil {
        didSet{
            tableview?.dataSource = self
            tableview?.delegate = self
        }
    }
    
    open weak var delegate:WATableViewDelegate?
    
    open weak var datasource:WATableViewDataSource?
    
    /// Expand cells on selection
    var expandOnSelection = true
    
    /// Allow only one cell to expand at a time.
    /// It will collapse the opend cells automatically on expanding another cell
    var toggleSelection = true
    
    var dataArray = NSMutableArray()
    
    private var objects = NSMutableArray()
    private let keyIndent = "indent";
    private let keyTitle = "title";
    private let keyChildren = "children";
    
    public  init(datasource:WATableViewDataSource,delegate:WATableViewDelegate) {
        super.init()
        self.datasource = datasource;
        self.delegate = delegate;
    }
    
    
    ///
    ///
    /// - Parameter dataList: SHould be array of arrays according to the required levels.
   public func reloadData(dataList:[ItemDataModel]){
        loadData(dataList: dataList)
    }
    
    private func loadData(dataList:[ItemDataModel]) {
        
        // Do any additional setup after loading the view, typically from a nib.
        
        dataArray = NSMutableArray()
        populateData(indexlevel: 0, parentIndentLevel: 0, listResult: dataArray, dataList: dataList);
        objects = dataArray.mutableCopy() as! NSMutableArray;
        tableview?.reloadData()
    }
    
    
    //------------TableView Adapter And DataSource--------------//
    
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.objects.count;
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let d = self.datasource {
            let data = objects[indexPath.row];
            return d.waTableViewHeightFor(cellAtIndexLevel:(data as! DataModel).levelIndex, forData:(data as! DataModel).data);
        }else{
            return 44;
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = (self.objects[indexPath.row] as! DataModel);
        var cell = datasource?.waTableViewCellFor(indexPath: indexPath, forIndexLevel: data.levelIndex, forData: data.data, forTableView: tableView);
        if(cell != nil){
            delegate?.waTableViewUpdateCellFor?(selectionStatus: data.isSelected, cell: cell!, atIndexLevel: data.levelIndex, forData: data.data);
            cell?.delegate = self;
        }
        if(cell == nil){
            cell = WATableViewCell();
        }
        cell?.indentationWidth = 20;
        cell?.indentationLevel = data.keyIndent;
        cell?.contentView.backgroundColor = UIColor.black.withAlphaComponent(CGFloat(CGFloat(cell!.indentationLevel) / 50.0));
        return cell!;
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = (self.objects[indexPath.row] as! DataModel);
         data.isSelected = true;
        
        if let cell = tableView.cellForRow(at: indexPath){
            
            delegate?.waTableViewUpdateCellFor?(selectionStatus: data.isSelected, cell: cell, atIndexLevel: data.levelIndex, forData: data.data);
            
            delegate?.waTableViewCellSelectionChanged?(toStatus: true, cell: cell, atIndexLevel: data.levelIndex, forData: data.data);
        }
        
        if(expandOnSelection){
            toggleCell(indexPath: indexPath, tableView: tableView);
        }
        

    }

    
    @available(iOS 11.0, *)
    public func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let closeAction = UIContextualAction(style: .normal, title:  "Close", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            print("OK, marked as Closed")
            success(true)
        })
        closeAction.image = UIImage(named: "tick")
        closeAction.backgroundColor = .purple
        
        return UISwipeActionsConfiguration(actions: [closeAction])
        
    }
    
    @available(iOS 11.0, *)
   public func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let modifyAction = UIContextualAction(style: .normal, title:  "Update", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            print("Update action ...")
            success(true)
        })
        modifyAction.image = UIImage(named: "hammer")
        modifyAction.backgroundColor = .blue
        
        return UISwipeActionsConfiguration(actions: [modifyAction])
    }
    
    
    func toggleCell(indexPath:IndexPath,tableView:UITableView){
        let data = objects[indexPath.row] as! DataModel;
        
        let indentlevel = data.keyIndent;
        let indentArray = objects.map({($0 as! DataModel).keyIndent});
        
        let indentCheeck = indentArray.contains(indentlevel);
        var isChildrenAlreadyInserted = self.objects.contains(data.childerns);
        if data.childerns == nil {
            return;
        }
        
        for dicChildren in data.childerns! {
            let index = objects.indexOfObjectIdentical(to: dicChildren)
            _ = objects.indexOfObjectIdentical(to: dicChildren)
            isChildrenAlreadyInserted = (index > 0 && index != NSIntegerMax);
            if isChildrenAlreadyInserted { break; }
        }
        if(indentCheeck && isChildrenAlreadyInserted){
            data.isExpended = false;
            miniMizeThisRows(ar: data.childerns!,forTable: tableView, withIndexpath: indexPath);
        }else if(data.childerns != nil && data.childerns!.count > 0){
            data.isExpended = true;
            let ipsArray = NSMutableArray();
            let childArray = data.childerns;
            var count = indexPath.row + 1;
            for i:Int in 0..<data.childerns!.count {
                let ip = IndexPath.init(row: count, section: indexPath.section);
                ipsArray.add(ip);
                objects.insert(childArray![i], at: count);
                count = count + 1;
            }
            
            tableView.beginUpdates()
            tableView.insertRows(at: ipsArray as! [IndexPath], with: .automatic);
            tableView.endUpdates()
            
            if(toggleSelection){
                collapseSibblings(levelIndex: data.levelIndex,dataExpended: data, tableview: tableview!);
            }
        }
    }
    
    
    
   private  func miniMizeThisRows(ar:NSArray,forTable tableview:UITableView, withIndexpath indexpath:IndexPath){
        for dicChildren in ar {
            let indexToRemove = self.objects.indexOfObjectIdentical(to: dicChildren);
            let arrayChildren = (dicChildren as! DataModel).childerns;
            if(arrayChildren != nil && arrayChildren!.count > 0){
                self.miniMizeThisRows(ar: arrayChildren!, forTable: tableview, withIndexpath: indexpath);
            }
            
            if(objects.indexOfObjectIdentical(to: dicChildren) != NSNotFound){
                objects.removeObject(identicalTo: dicChildren);
                
                tableview.deleteRows(at: [IndexPath.init(row: indexToRemove, section: indexpath.section)], with: .automatic);
            }
        }
    }
    
   private  func miniMizeThisRows(ar:NSArray,forTable tableview:UITableView ){
        for dicChildren in ar {
            let indexToRemove = self.objects.indexOfObjectIdentical(to: dicChildren);
            let arrayChildren = (dicChildren as! DataModel).childerns;
            if(arrayChildren != nil && arrayChildren!.count > 0){
                self.miniMizeThisRows(ar: arrayChildren!, forTable: tableview);
            }
            
            if(objects.indexOfObjectIdentical(to: dicChildren) != NSNotFound){
                if let d = dicChildren as? DataModel {
                    d.isSelected = false;
                    d.isExpended = false;
                }
                objects.removeObject(identicalTo: dicChildren);
                tableview.deleteRows(at: [IndexPath.init(row: indexToRemove, section: 0)], with: .automatic);
            }
        }
    }
    
    
    func populateData(indexlevel:Int,parentIndentLevel:Int,listResult:NSMutableArray,dataList:[ItemDataModel]?){
        if let listIn = dataList {
            for i in 0..<listIn.count {
                let p = DataModel()
                let dataIn = listIn[i];
                p.data = dataIn;
                p.keyIndent = parentIndentLevel + i;
                p.levelIndex = indexlevel;
                listResult.add(p);
                if(dataIn.childerns != nil && dataIn.childerns!.count > 0){
                    p.childerns = NSMutableArray()
                    populateData(indexlevel: indexlevel + 1, parentIndentLevel: parentIndentLevel * 100, listResult: p.childerns!, dataList: dataIn.childerns!)
                }
            }
        }
    }

    
    //SwipeCell Delegate Functions---------------------------------------------------------
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        let data = objects[indexPath.row] as! DataModel;
        if datasource?.waTableView != nil {
            return datasource?.waTableView!(cellAtIndexLevel: data.levelIndex, for: getWaSwipeActionsOrientation(swipeAction: orientation), itemData:data.data as! ItemDataModel, isSelected: data.isSelected ,isExpended: data.isExpended);
        }
        return nil;
    }
    
    public func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .selection
        options.transitionStyle = .border
        return options
    }
    //----------------------------------------------------------------------
    
    
    private func getWaSwipeActionsOrientation(swipeAction:SwipeActionsOrientation)->WASwipeActionsOrientation{
        switch swipeAction {
        case SwipeActionsOrientation.right:
            return WASwipeActionsOrientation.right;
        case SwipeActionsOrientation.left:
            return WASwipeActionsOrientation.left;
        }
    }
    
    private func collapseForData(dataToCollapse:DataModel,tableview:UITableView){
        
        let indentlevel = dataToCollapse.keyIndent;
        
        let indentArray = objects.map({($0 as! DataModel).keyIndent});
        
        let indentCheck = indentArray.contains(indentlevel);
        
        if(dataToCollapse.childerns != nil) {
            
            var isChildrenAlreadyInserted = false;
            
            for dicChildren in dataToCollapse.childerns! {
                let index = objects.indexOfObjectIdentical(to: dicChildren)
                isChildrenAlreadyInserted = (index > 0 && index != NSIntegerMax);
                if isChildrenAlreadyInserted { break; }
            }
            
            if(indentCheck && isChildrenAlreadyInserted){
                miniMizeThisRows(ar: dataToCollapse.childerns!, forTable: tableview);
            }
        }
        dataToCollapse.isExpended = false
        if(dataToCollapse.isSelected) {
            dataToCollapse.isSelected = false;
            if  self.objects.indexOfObjectIdentical(to: dataToCollapse) != NSNotFound {
                let indexRow = self.objects.indexOfObjectIdentical(to: dataToCollapse);
                if let cell = tableview.cellForRow(at: IndexPath.init(row: indexRow, section: 0)){
                    delegate?.waTableViewCellSelectionChanged?(toStatus: false, cell:cell , atIndexLevel: dataToCollapse.levelIndex, forData: dataToCollapse.data);
                }
            }
        }
    }
    
    private func collapseSibblings(levelIndex:Int,dataExpended:DataModel,tableview:UITableView){
        
        let data = objects.filter({($0 as? DataModel)?.levelIndex == levelIndex});
        for d in data{
            if let dToCollapse = d as? DataModel, dToCollapse != dataExpended {
                self.collapseForData(dataToCollapse:d as! DataModel,tableview: tableview);
            }
        }
    }
    
    
    
    
    //    func getUserDataList()->[ItemDataModel]{
    //        var listData = [ItemDataModel]()
    //        for i in 0..<15{
    //            let item = ItemDataModel();
    //            var cList  = [ItemDataModel]()
    //            let s = SampleDatModel()
    //            s.title = "Title \(i)}"
    //            item.data = s;
    //            for j in 0..<i{
    //                let item1 = ItemDataModel();
    //                var cList1  = [ItemDataModel]()
    //                let s1 = SampleDatModel()
    //                s1.title = "Title \(i):\(j)}"
    //                item1.data = s1;
    //                for k in 0..<j{
    //                    let item2 = ItemDataModel();
    //                    cList1.append(item2)
    //                    let s2 = SampleDatModel()
    //                    s2.title = "Title \(i):\(j):\(k)}"
    //                    item2.data = s2;
    //                }
    //                item1.childerns = cList1;
    //                cList.append(item1);
    //            }
    //            item.childerns = cList;
    //            listData.append(item);
    //        }
    //        return listData;
    //    }
    
    
    
    private class DataModel: NSObject {
        var keyIndent:Int = 0
        var levelIndex:Int = 0
        var isSelected:Bool = false
        var isExpended:Bool = false
        var childerns:NSMutableArray? = nil
        
        var data:Any? = nil
    }
}


