//
//  AppDelegate.swift
//  e2e
//
//  Created by José Luis Díaz González on 6/7/15.
//  Copyright (c) 2015 UPM. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  let defaultKey = MessageList.ListKeys.Global
  var coreLocationController:CoreLocationController?
  var requestController:RESTRequestController?
  var myConsumer: Consumer?
  var myServer:Server?
  
  // Tells the delegate that the launch process is almost done and the app is almost ready to run
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    let types: UIUserNotificationType = [UIUserNotificationType.Badge, UIUserNotificationType.Alert, UIUserNotificationType.Sound]
    
    //notificaciones
    let settings: UIUserNotificationSettings = UIUserNotificationSettings( forTypes: types, categories: nil )
    application.registerUserNotificationSettings( settings )
    application.registerForRemoteNotifications()
    
//    let cleanKey = "consumer"
//    let defaults = NSUserDefaults.standardUserDefaults()
//    defaults.removeObjectForKey(cleanKey)
//
    myServer = Server(addss: "192.168.6.6:3000")
    //geolocalización
    self.coreLocationController = CoreLocationController()
    
    //RESTful requests
    self.requestController = RESTRequestController(e2eServer: (myServer?.getServer())!)
    
    //Consumidor
    self.myConsumer = Consumer()
    
    //background fetch
    application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
    
    //initializing all lists
    _ = VersionList()
    _ = BlockedList()
    _ = NotificationList().initialConfig()
    let initCategory = CategoryList()
    if initCategory.catList.count == 0 {
      initCategory.updateListFromServer()
      print("INIT: Categories list updated from the Server")
    } else {
      print("INIT: Categories list already initialized")
    }
    let initSubs = SubscriptionList()
    if initSubs.subList.count == 0 {
      initSubs.initialSubscriptions()
      print("INIT: Subscriptions initialized to false")
    } else {
      print("INIT: Subscriptions already initilized")
    }
    
    return true
  }
  
  // Tells the delegate that the app successfully registered with Apple Push Notification service (APNs)
  func application( application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData ) {
    
//    let characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )
    
//    let deviceTokenString: String = ( deviceToken.description as NSString )
//      .stringByTrimmingCharactersInSet( characterSet )
//      .stringByReplacingOccurrencesOfString( " ", withString: "" ) as String
    
    //registerTokenOnServer(cleanToken) //theoretical method! Needs your own implementation
//    myConsumer?.updateToken("")
    if (myConsumer?.token == "") || (myConsumer?.conID == "") {
      self.myConsumer?.updateToken(deviceToken.description as String)
      self.requestController?.postConsumer() {(statCode, id) in
        if statCode == 201 {
          print("CONSUMER: consumer created successfuly in the server")
          self.myConsumer?.updateID(id)
          print("ID: \(self.myConsumer!.getConID())")
        } else if statCode == 409 {
          print("ERROR: consumer is already in the server")
          print("DEBUG: ID \(self.myConsumer!.getConID())")
        }
      }
    } else {
      print("CONSUMER: consumer already initilized to receive notifications")
    }
    print("TOKEN: \(deviceToken.description as NSString)")
    print("ID: \(self.myConsumer!.getConID())")
//    print( deviceTokenString )

    
  }
  
  func application( application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError ) {
    
    print( error.localizedDescription )
  }
  
  
  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  //this method executes when a new remote notification is received
  //the notification is going to be captured and added to "messages" list
  //everything happens when the app is in the foreground and also when it is in the background
  func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
    print("Received: \(userInfo)")
    //Parsing userinfo:
    if let newNotification = userInfo as NSDictionary! {
      //create a new Message from the received notification
      let newMessage = Message(notification: newNotification)
      //load or create default list to store messages in UserDefaults
      let messList = MessageList(myKey: defaultKey)
      //check if message exists, it has already been received
      if messList.existMessage(newMessage.messageID!) == false {
        //comprobamos si el mensaje ya lo hemos recibido
        messList.addMessage(newMessage)
        messList.saveList(defaultKey)
      } else {
        print("MESSAGE: received message but it's already in messages list")
      }
    }
    completionHandler(UIBackgroundFetchResult.NewData)
  }
}