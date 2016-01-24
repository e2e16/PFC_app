//
//  MessageDetailViewController.swift
//  e2e
//
//  Created by José Luis Díaz González on 21/7/15.
//  Copyright (c) 2015 UPM. All rights reserved.
//

import UIKit
import MapKit

class MessageDetailViewController: UIViewController {
  
  var message: Message?
  var messIndex: Int?
  
  let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
  
  var defaultTintColor: UIColor!
  @IBOutlet weak var producerLabel: UILabel!
  @IBOutlet weak var alertLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var bodyLabel: UILabel!
  @IBOutlet weak var deadlineLabel: UILabel!
  @IBOutlet weak var mapView: MKMapView!
  @IBAction func phoneButton(sender: UIButton) {
    let alertView = UIAlertController(title: "Llamar", message: message!.phone!, preferredStyle: .ActionSheet)
    let callAction = UIAlertAction (title: "Llamar", style: .Default ) { alertAction in
      UIApplication.sharedApplication().openURL(NSURL(string:"telprompt:"+self.message!.phone!)!)
    }
    let cancelAction = UIAlertAction (title: "Cancelar", style: .Cancel ) {  alertAction in
    }
    
    alertView.addAction(callAction)
    alertView.addAction(cancelAction)
    
    presentViewController(alertView, animated: true, completion: nil)

  }

  @IBAction func mailButton(sender: UIButton) {
    let alertView = UIAlertController(title: "Enviar email", message: message!.email!, preferredStyle: .ActionSheet)
    let mailAction = UIAlertAction (title: "Enviar", style: .Default ) { alertAction in
      UIApplication.sharedApplication().openURL(NSURL(string:"mailto:\(self.message!.email!)")!)
    }
    let cancelAction = UIAlertAction (title: "Cancelar", style: .Cancel ) {  alertAction in
    }
    
    alertView.addAction(mailAction)
    alertView.addAction(cancelAction)
    
    presentViewController(alertView, animated: true, completion: nil)
  }
  
  @IBAction func webButton(sender: UIButton) {
    let alertView = UIAlertController(title: "Abrir página", message: message!.web!, preferredStyle: .ActionSheet)
    let webAction = UIAlertAction (title: "Abrir", style: .Default ) { alertAction in
      UIApplication.sharedApplication().openURL(NSURL(string:"http://\(self.message!.web!)")!)
    }
    let cancelAction = UIAlertAction (title: "Cancelar", style: .Cancel ) {  alertAction in
    }
    
    alertView.addAction(webAction)
    alertView.addAction(cancelAction)
    
    presentViewController(alertView, animated: true, completion: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.toolbarHidden = false    
    producerLabel.text = message?.producer!
    alertLabel.text = message?.alert!
    addressLabel.text = "\(message!.address!)\n\(message!.city!)"
    bodyLabel.text = message?.body!
    
    let center = CLLocationCoordinate2DMake(message!.latitude!, message!.longitude!)
    let span = MKCoordinateSpanMake(0.004, 0.004)
    let reg = MKCoordinateRegionMake(center, span)
    mapView.setRegion(reg, animated: false)
    let annotation = MKPointAnnotation()
    annotation.coordinate = center
    annotation.title = message?.producer!
    annotation.subtitle = "\(message!.address!)\n\(message!.city!)"
    mapView.addAnnotation(annotation)
    
    deadlineLabel.text = message?.deadlineFormatter(true)
    if message?.finished == true {
      deadlineLabel.textColor = UIColor ( red: 0.8467, green: 0.1177, blue: 0.0, alpha: 1.0 )
    } else if message!.thisWeek == true {
      deadlineLabel.textColor = UIColor ( red: 1.0, green: 0.6057, blue: 0.0, alpha: 1.0 )
    } else {
      deadlineLabel.textColor = UIColor ( red: 0.469, green: 0.6513, blue: 0.0, alpha: 1.0 )
    }
    
    if message!.phone! != "" {
      
    }
    
    messageToolbar()
  }
  
  //ocultamos la tabbar cuando aparece la vista para que se vea la toolbar del navigationController
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    tabBarController?.tabBar.hidden = true
  }
  //mostramos la tabbar cuando desaparece la vista para que se vea la toolbar del navigationController
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    tabBarController?.tabBar.hidden = false
  }
  
  func messageToolbar() -> Void {
    
    var toolbarItems: [UIBarButtonItem] = []
    
    var savedButton: UIBarButtonItem
    if self.message?.saved! == true {
      savedButton = UIBarButtonItem(image: UIImage(named: "startool full.png"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("savedButtonAction"))
    } else {
      savedButton = UIBarButtonItem(image: UIImage(named: "startool empty.png"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("savedButtonAction"))
    }
    toolbarItems.append(savedButton)
    toolbarItems.append(flexSpace)
    let deleteButton = UIBarButtonItem(image: UIImage(named: "delete.png"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("deleteButtonAction"))
    toolbarItems.append(deleteButton)
    toolbarItems.append(flexSpace)
    let alarmButton = UIBarButtonItem(image: UIImage(named: "alarm.png"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("alarmButtonAction"))
    toolbarItems.append(alarmButton)
    toolbarItems.append(flexSpace)
    let blockButton = UIBarButtonItem(image: UIImage(named: "block.png"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("blockButtonAction"))
    toolbarItems.append(blockButton)
    
    setToolbarItems(toolbarItems, animated: true)
  }
  
  func toggleSavedButtonIcon(saved: Bool) {
    
    var toolbarItems: [UIBarButtonItem] = []
    
    var savedButton: UIBarButtonItem
    if saved {
      savedButton = UIBarButtonItem(image: UIImage(named: "startool full.png"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("savedButtonAction"))
    } else {
      savedButton = UIBarButtonItem(image: UIImage(named: "startool empty.png"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("savedButtonAction"))
    }
    toolbarItems.append(savedButton)
    toolbarItems.append(flexSpace)
    let deleteButton = UIBarButtonItem(image: UIImage(named: "delete.png"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("deleteButtonAction"))
    toolbarItems.append(deleteButton)
    toolbarItems.append(flexSpace)
    let alarmButton = UIBarButtonItem(image: UIImage(named: "alarm.png"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("alarmButtonAction"))
    toolbarItems.append(alarmButton)
    toolbarItems.append(flexSpace)
    let blockButton = UIBarButtonItem(image: UIImage(named: "block.png"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("blockButtonAction"))
    toolbarItems.append(blockButton)
    
    navigationController?.toolbar.setItems(toolbarItems, animated: true)
  }
  
  func savedButtonAction() {
    var myTempList: MessageList
    if message?.saved! == false {
      myTempList = MessageList(myKey: .Global)
      myTempList.moveToSavedList(message!, messIndex: messIndex!)
      toggleSavedButtonIcon(true)
    } else {
      myTempList = MessageList(myKey: .Saved)
      myTempList.removeFromSavedList(message!, messIndex: messIndex!)
      toggleSavedButtonIcon(false)
    }
    messIndex = 0
  }
  
  
  func deleteButtonAction() {
    let alertView = UIAlertController(title: "Borrar Mensaje", message: "¿Seguro que quieres borrar este mensaje?", preferredStyle: .ActionSheet)
    let deleteAction = UIAlertAction (title: "Borrar", style: .Destructive ) { alertAction in
      self.performSegueWithIdentifier("deleteUnwind", sender: self)
    }
    let cancelAction = UIAlertAction (title: "Cancelar", style: .Cancel ) {  alertAction in
    }
    
    alertView.addAction(deleteAction)
    alertView.addAction(cancelAction)
    
    presentViewController(alertView, animated: true, completion: nil)
  }
  
  func alarmButtonAction() {
    
  }
  
  func blockButtonAction() {
    
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
}
