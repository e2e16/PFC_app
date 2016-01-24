//
//  SettingsViewController.swift
//  e2e
//
//  Created by José Luis Díaz González on 9/11/15.
//  Copyright © 2015 UPM. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate  {

  @IBOutlet weak var serverTextField: UITextField!
  @IBOutlet weak var serverStatus: UILabel!
  var requestController: RESTRequestController?

  override func viewDidLoad() {
    super.viewDidLoad()
    serverTextField.delegate = self
    NSUserDefaults.standardUserDefaults().addObserver(self, forKeyPath: "notifications", options: NSKeyValueObservingOptions.New, context: nil)
    NSUserDefaults.standardUserDefaults().addObserver(self, forKeyPath: "subscriptions", options: NSKeyValueObservingOptions.New, context: nil)
  }
  
  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    var timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: Selector("updateSubscriptions"), userInfo: nil, repeats: false)
  }
  
  
  func updateSubscriptions() {
    // Something after a delay
    requestController = RESTRequestController(e2eServer: Server().getServer())
    requestController?.putSubsConsumer() { (statCode) in
      if statCode == 200 {
        print("CONSUMER: consumer location successfuly updated in the server")
      } else if statCode == 404 {
        print("ERROR: consumer doesn't exist in the server")
      } else {
        print("ERROR: ERROR")
      }
    }
  }
  
  override func viewDidAppear(animated: Bool) {
      serverTextField.text   = Server().getServer()
      Server().isServerAlive() { (status) in
        if status {
        dispatch_async(dispatch_get_main_queue(), {
          print("DEBUG: status is \(status)")
      self.serverStatus.text = "🔵"
          })
        } else {
        dispatch_async(dispatch_get_main_queue(), {
          print("DEBUG: status is \(status)")
      self.serverStatus.text = "🔴"
          })
        }

     }
  }
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  

    /**
     * Called when 'return' key pressed. return NO to ignore.
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }


   /**
    * Called when the user click on the view (outside the UITextField).
    */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
  }
  
  func textFieldDidEndEditing(textField: UITextField) {
    Server().updateServer(self.serverTextField.text!)
    
  }
  
//  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!){
//      if segue.identifier == "embedSegue" {
//      }
//  }
//
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

