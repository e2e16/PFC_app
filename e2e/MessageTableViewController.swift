//
//  MessageTableViewController.swift
//  e2e
//
//  Created by José Luis Díaz González on 17/7/15.
//  Copyright (c) 2015 UPM. All rights reserved.
//

import UIKit

class MessageTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
  
  var listKey: MessageList.ListKeys?      //Key que determina qué lista se carga en messList
  var messageList: MessageList?           //lista cargada
  var currentTab: String!                 //tab seleccionada para cargar .Global o .Saved
  var defaultTintColor: UIColor!
  var menuSelectionIndex: Int?            //Popover: índice de la selección de la tabla popover
  var menuPopover: topMenu?               //Popover: popover mostrado
  var currentCategories: [String] = []    //Popover: categorías de los mensajes en la lista
  var isFiltered = false
  var currentFilteredCategory: String?
  enum topMenu {
    case Clean
    case Filter
  }
  
  // MARK: - View delegates
  
  override func viewDidLoad() {
    super.viewDidLoad()
    refreshControl?.addTarget(self, action: "refreshMyTable", forControlEvents: .ValueChanged)
    currentTab = tabBarController!.tabBar.selectedItem?.title as String!
    defaultTintColor = view.tintColor
    print("\(currentTab) pressed")
    setListKeyFromCurrentTab()
    messageList = MessageList(myKey: listKey!)
    topToolbar()
    tableView.reloadData()
//    NSNotificationCenter.defaultCenter().addObserverForName(NSUserDefaultsDidChangeNotification, object: nil, queue: NSOperationQueue.mainQueue()) { _ in
//      self.tableView.reloadData()
//    }
    NSUserDefaults.standardUserDefaults().addObserver(self, forKeyPath: "\(self.listKey!.rawValue)", options: NSKeyValueObservingOptions.New, context: nil)
  }
 
  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
      self.tableView.reloadData()
  }
  
  override func viewDidAppear(animated: Bool) {
    tableView.reloadData()
    print("FILTER \(isFiltered)")
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setToolbarHidden(true, animated: animated)
    messageList!.loadList(listKey!)
    tableView.reloadData()
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    let nextTab = tabBarController!.tabBar.selectedItem?.title as String!
    print("currentTab: \(currentTab)")
    print("nextTab: \(nextTab)")
    if isFiltered && nextTab != currentTab {
      setFilterOff()
      loadCurrentTab()
    }
    navigationController?.setToolbarHidden(false, animated: animated)
  }
  
  func setListKeyFromCurrentTab() {
    if currentTab == "Guardados" {
      listKey = .Saved
    } else if currentTab == "Mensajes" {
      listKey = .Global
    } else {
      listKey = .Global
      print("ERROR: couldn't identify selected tab")
    }
  }
  
  func refreshMyTable() {
    messageList!.loadList(listKey!)
    tableView.reloadData()
    refreshControl?.endRefreshing()
  }
  
  func reloadCategories() {
    if isFiltered {
      setListKeyFromCurrentTab()
      messageList!.loadList(listKey!)
      currentCategories = messageList!.getAvailableCategories()
      listKey = .Filtered
    } else {
      currentCategories = messageList!.getAvailableCategories()
    }
  }
  
  func topToolbar() {
    var toolbarItemsLeft: [UIBarButtonItem] = []
    var toolbarItemsRight: [UIBarButtonItem] = []
    //        var flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
    let locationButton = UIBarButtonItem(image: UIImage(named: "location.png"), style: .Plain, target: self, action: Selector("locationButtonAction"))
    //        toolbarItems.append(flexSpace)
    let categoryButton = UIBarButtonItem(image: UIImage(named: "catfilter.png"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("categoryButtonAction"))
    toolbarItemsLeft = [locationButton, categoryButton]
    let cleanButton = UIBarButtonItem(image: UIImage(named: "clean.png"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("cleanButtonAction"))
    toolbarItemsRight = [cleanButton]
    navigationItem.setLeftBarButtonItems(toolbarItemsLeft, animated: true)
    navigationItem.setRightBarButtonItem(cleanButton, animated: true)
  }
  
  func showPopoverMenu(menu: topMenu) {
    let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let popoverContent: PopoverMenuTableViewController = storyboard.instantiateViewControllerWithIdentifier("PopoverMenu") as! PopoverMenuTableViewController
    popoverContent.modalPresentationStyle = .Popover
    let popoverController = popoverContent.popoverPresentationController
    popoverController?.permittedArrowDirections = .Up
    popoverController?.delegate = self
    switch menu {
    case .Clean:
      popoverContent.menuItems = ["Borrar Terminados", "Borrar Todos"]
      //popoverContent.preferredContentSize = CGSizeMake(190,88)
      popoverContent.popoverMenu = .Clean
      popoverController?.barButtonItem = navigationItem.rightBarButtonItem
    case .Filter:
      self.reloadCategories()
      popoverContent.menuItems = currentCategories
      popoverContent.popoverMenu = .Filter
      popoverController?.barButtonItem = navigationItem.leftBarButtonItems![1] 
    default:
      popoverContent.menuItems = []
      
    }
    popoverContent.preferredContentSize = CGSize(width: 200, height: popoverContent.menuItems.count*44)
    presentViewController(popoverContent, animated: true, completion: nil)
    
  }
  
  @IBAction func popoverMenuSelectionUnwind(segue: UIStoryboardSegue) {
    print("\(menuSelectionIndex!)")
    var rowIndexes: [NSIndexPath] = []
    switch menuPopover! {
    case .Clean:
      switch menuSelectionIndex! {
      case 0:
        let alertFinished: UIAlertController
        let deleteAction: UIAlertAction
        if isFiltered {
          alertFinished = UIAlertController(title: "Borrar Mensajes Terminados", message: "¿Seguro que quieres borrar todos los mensajes terminados de la categoría \(currentFilteredCategory!)?", preferredStyle: .Alert)
          deleteAction = UIAlertAction (title: "Borrar", style: .Destructive ) { alertAction in
            self.tableView.beginUpdates()
            self.messageList?.deleteFinishedMessagesFromAllList(self.messageList!.messList)
            let rowIndexes = self.messageList!.deleteAllFinishedMessages()
            self.messageList?.saveList(self.listKey!)
            self.tableView.deleteRowsAtIndexPaths(rowIndexes, withRowAnimation: .Fade)
            self.tableView.endUpdates()
            if self.messageList!.messList.isEmpty {
              self.setFilterOff()
              self.reloadCurrentTab()
            }
          }
        } else {
          alertFinished = UIAlertController(title: "Borrar Mensajes Terminados", message: "¿Seguro que quieres borrar todos los mensajes terminados?", preferredStyle: .Alert)
          deleteAction = UIAlertAction (title: "Borrar", style: .Destructive ) { alertAction in
            self.tableView.beginUpdates()
            let rowIndexes = self.messageList!.deleteAllFinishedMessages()
            self.messageList?.saveList(self.listKey!)
            self.tableView.deleteRowsAtIndexPaths(rowIndexes, withRowAnimation: .Fade)
            self.tableView.reloadData()
            self.tableView.endUpdates()
          }
        }
        
        let cancelAction = UIAlertAction (title: "Cancelar", style: .Cancel ) {  alertAction in
          
        }
        alertFinished.addAction(deleteAction)
        alertFinished.addAction(cancelAction)
        
        presentViewController(alertFinished, animated: true, completion: nil)
        
      case 1:
        let alertAll: UIAlertController
        let deleteAction: UIAlertAction
        if isFiltered {
          alertAll = UIAlertController(title: "Borrar Todos los Mensajes", message: "¿Seguro que quieres borrar todos los mensajes de la categoría \(currentFilteredCategory!)?", preferredStyle: .Alert)
          deleteAction = UIAlertAction (title: "Borrar", style: .Destructive ) { alertAction in
            self.tableView.beginUpdates()
            self.messageList?.deleteMessagesFromAllList(self.messageList!.messList)
            let rowIndexes = self.messageList!.getAllIndexPaths()
            self.messageList?.messList.removeAll(keepCapacity: false)
            self.messageList?.saveList(self.listKey!)
            self.tableView.deleteRowsAtIndexPaths(rowIndexes, withRowAnimation: .Fade)
            self.tableView.endUpdates()
            if self.messageList!.messList.isEmpty {
              self.setFilterOff()
              self.reloadCurrentTab()
            }
          }
          
          
        } else {
          alertAll = UIAlertController(title: "Borrar Todos los Mensajes", message: "¿Seguro que quieres borrar todos los mensajes de la lista?", preferredStyle: .Alert)
          deleteAction = UIAlertAction (title: "Borrar", style: .Destructive ) { alertAction in
            self.tableView.beginUpdates()
            let rowIndexes = self.messageList!.getAllIndexPaths()
            self.messageList?.messList.removeAll(keepCapacity: false)
            self.messageList?.saveList(self.listKey!)
            self.tableView.deleteRowsAtIndexPaths(rowIndexes, withRowAnimation: .Fade)
            self.tableView.endUpdates()
          }
        }
        
        
        
        let cancelAction = UIAlertAction (title: "Cancelar", style: .Cancel ) {  alertAction in
          
        }
        alertAll.addAction(deleteAction)
        alertAll.addAction(cancelAction)
        
        presentViewController(alertAll, animated: true, completion: nil)
        
      default: ()
      }
      
    case .Filter:
      switch menuSelectionIndex! {
      case 0:
        setListKeyFromCurrentTab()
        messageList!.loadList(listKey!)
        setFilterOff()
        tableView.reloadData()
      default:
        if isFiltered {
          setListKeyFromCurrentTab()
          messageList!.loadList(listKey!)
          messageList!.filteredByCategory(currentCategories[menuSelectionIndex!])
          listKey = .Filtered
        } else {
          listKey = .Filtered
          messageList!.filteredByCategory(currentCategories[menuSelectionIndex!])
        }
        currentFilteredCategory = currentCategories[menuSelectionIndex!]
        messageList!.loadList(listKey!)
        isFiltered = true
        toggleCategoryIcon(true)
        print("FILTER ON")
        tableView.reloadData()
      }
    default: ()
    }
  }
  
  func adaptivePresentationStyleForPresentationController(
    controller: UIPresentationController) -> UIModalPresentationStyle {
      return .None
  }
  
  func cleanButtonAction() {
    showPopoverMenu(.Clean)
    
  }
  
  func categoryButtonAction() {
    showPopoverMenu(.Filter)
  }
  
  func locationButtonAction() {
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func setFilterOff() {
    isFiltered = false
    toggleCategoryIcon(false)
    print("FILTER OFF")
  }
  
  func loadCurrentTab() {
    setListKeyFromCurrentTab()
    messageList?.loadList(listKey!)
  }
  
  func reloadCurrentTab() {
    setListKeyFromCurrentTab()
    messageList?.loadList(listKey!)
    tableView.reloadData()
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    // Return the number of sections.
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // Return the number of rows in the section.
    return messageList!.messList.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath) as! MessageTableViewCell
    
    let message = messageList!.messList[indexPath.row]
    
    cell.producerLabel.text = message.producer!
    cell.alertLabel.text = message.alert!
    cell.deadlineLabel.text = message.deadlineFormatter(false)
    cell.categoryLabel.textColor = UIColor ( red: 0.0, green: 0.665, blue: 0.8383, alpha: 1.0 )
    cell.categoryLabel.text = message.category!
    cell.backgroundColor = UIColor.whiteColor()
    if message.finished == true {
      //cell.contentView.backgroundColor = UIColor ( red: 0.9023, green: 0.9023, blue: 0.9023, alpha: 1.0 )
      cell.deadlineLabel.textColor = UIColor ( red: 0.8467, green: 0.1177, blue: 0.0, alpha: 1.0 )
      cell.backgroundColor = UIColor ( red: 0.9023, green: 0.9023, blue: 0.9023, alpha: 1.0 )
    } else if message.thisWeek == true {
      cell.deadlineLabel.textColor = UIColor ( red: 1.0, green: 0.6057, blue: 0.0, alpha: 1.0 )
    }
    else {
      cell.deadlineLabel.textColor = UIColor ( red: 0.469, green: 0.6513, blue: 0.0, alpha: 1.0 )
    }
    return cell
  }
  
  /*
  // Override to support conditional editing of the table view.
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
  // Return NO if you do not want the specified item to be editable.
  return true
  }
  */
  
  // Override to support editing the table view.
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
  }
  
  override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
    var saveRowAction: UITableViewRowAction
    
    if currentTab == "Guardados" {
      saveRowAction = UITableViewRowAction(style: .Normal, title: "No\n Guardar",
        handler: { (action: UITableViewRowAction, indexPath: NSIndexPath) in
          if self.isFiltered {
            let currentMessageID = self.messageList!.messList[indexPath.row].messageID!
            self.setListKeyFromCurrentTab()
            self.messageList?.loadList(self.listKey!)
            if let listIndex = self.messageList?.findMessageIndex(currentMessageID) {
              self.messageList?.removeFromSavedList(self.messageList!.messList[listIndex], messIndex: listIndex)
            }
            self.listKey = .Filtered
            self.tableView.beginUpdates()
            self.messageList?.loadList(self.listKey!)
            self.messageList?.deleteMessage(indexPath.row)
            self.messageList?.saveList(self.listKey!)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            self.tableView.endUpdates()
            if self.messageList!.messList.isEmpty {
              self.setFilterOff()
              self.reloadCurrentTab()
            }
          } else {
            self.tableView.beginUpdates()
            self.messageList?.removeFromSavedList(self.messageList!.messList[indexPath.row], messIndex: indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            self.tableView.endUpdates()
          }
          print("Mensaje sacado de la lista Guardados");
        }
      )
      saveRowAction.backgroundColor = UIColor ( red: 1.0, green: 0.7758, blue: 0.2547, alpha: 1.0 )
      
    } else {
      saveRowAction = UITableViewRowAction(style: .Normal, title: "Guardar",
        handler: { (action: UITableViewRowAction, indexPath: NSIndexPath) in
          if self.isFiltered {
            let currentMessageID = self.messageList!.messList[indexPath.row].messageID!
            self.setListKeyFromCurrentTab()
            self.messageList?.loadList(self.listKey!)
            if let listIndex = self.messageList!.findMessageIndex(currentMessageID) {
              print("DEBUG: index found \(listIndex)")
              self.messageList?.moveToSavedList(self.messageList!.messList[listIndex], messIndex: listIndex)
            }
            self.listKey = .Filtered
            self.tableView.beginUpdates()
            self.messageList?.loadList(self.listKey!)
            self.messageList?.deleteMessage(indexPath.row)
            self.messageList?.saveList(self.listKey!)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            self.tableView.endUpdates()
            if self.messageList!.messList.isEmpty {
              self.setFilterOff()
              self.reloadCurrentTab()
            }
          } else {
            self.tableView.beginUpdates()
            self.messageList!.moveToSavedList(self.messageList!.messList[indexPath.row], messIndex: indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            self.tableView.endUpdates()
          }
          print("Mensaje añadido a la lista Guardados");
        }
      )
      saveRowAction.backgroundColor = UIColor ( red: 0.5143, green: 0.7534, blue: 0.838, alpha: 1.0 )
      
    }
    
    let deleteRowAction = UITableViewRowAction(style: .Normal, title: "Borrar",
      handler: { (action: UITableViewRowAction, indexPath: NSIndexPath) in
        let currentListKey = self.listKey
        let currentMessageID = self.messageList!.messList[indexPath.row].messageID!
        self.tableView.beginUpdates()
        self.messageList!.deleteMessegeFromAllList(currentMessageID)
        self.listKey = currentListKey
        self.messageList!.loadList(self.listKey!)
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        self.tableView.endUpdates()
        if self.isFiltered && self.messageList!.messList.isEmpty {
          self.setFilterOff()
          self.reloadCurrentTab()
        }
        print("Celda Borrada");
      }
    );
    deleteRowAction.backgroundColor = UIColor ( red: 1.0, green: 0.366, blue: 0.3337, alpha: 1.0 )
    
    return [deleteRowAction, saveRowAction]
  }
  
  func toggleCategoryIcon(filtered: Bool) {
    var toolbarItemsLeft: [UIBarButtonItem] = []
    let locationButton = UIBarButtonItem(image: UIImage(named: "location.png"), style: .Plain, target: self, action: Selector("locationButtonAction"))
    let categoryButton = UIBarButtonItem(image: UIImage(named: "catfilter.png"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("categoryButtonAction"))
    if filtered {
      categoryButton.tintColor = UIColor ( red: 0.6, green: 0.2, blue: 0.8, alpha: 1.0 )
    } else {
      categoryButton.tintColor = defaultTintColor
    }
    toolbarItemsLeft = [locationButton, categoryButton]
    navigationItem.setLeftBarButtonItems(toolbarItemsLeft, animated: true)
  }
  
  /*
  // Override to support rearranging the table view.
  override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
  
  }
  */
  
  /*
  // Override to support conditional rearranging of the table view.
  override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
  // Return NO if you do not want the item to be re-orderable.
  return true
  }
  */
  
  // MARK: - Navigation
  
  @IBAction func deleteMessageUnwind(segue: UIStoryboardSegue) {
    if let ip = tableView.indexPathForSelectedRow {
      self.tableView.beginUpdates()
      messageList!.deleteMessage(ip.row)
      messageList!.saveList(listKey!)
      tableView.deleteRowsAtIndexPaths([ip], withRowAnimation: .Fade)
      self.tableView.endUpdates()
    }
  }
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if segue.identifier == "MessageDetail" {
      if let mdvc = segue.destinationViewController as? MessageDetailViewController {
        if let ip = tableView.indexPathForSelectedRow {
          mdvc.messIndex = ip.row
          mdvc.message = messageList!.messList[ip.row]
        }
      }
      
    }
    
  }
  
}
