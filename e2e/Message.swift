//
//  Message.swift
//  e2e
//
//  Created by José Luis Díaz González on 16/7/15.
//  Copyright (c) 2015 UPM. All rights reserved.
//

import Foundation

class Message: NSObject, NSCoding {
  
  var alert: String?              //mensaje de alerta de la notificación. Título o asunto del mensaje
  var messageID: String?          //identificador de mensaje que coincide con el id de la notificación en la BBDD del servidor. Identifica de forma única cada mensaje que pasa por el sistema
  var body: String?               //descripción o cuerpo del mensaje
  var deadline: String?           //fecha de caducidad del mensaje o período de validez de la información que contiene
  var producerID: String?         //identificar del productor para poder gestionar el bloqueo
  var producer: String?           //productor del mensaje
  var category: String?           //categoría a la que pertenece el mensaje según el productor
  var address: String?            //dirección del productor
  var longitude: Double?
  var latitude: Double?
  var city: String?               //ciudad del productor
  var phone: String?              //teléfono de contacto del productor
  var email: String?              //email de contacto del productor
  var web: String?                //web de contacto del productor
  var cateversion: String?        //versión de la lista de categorías del sistema
  var protoversion: String?       //versión del protocolo del sistema
  var finished: Bool?             //si el mensaje ha caducado o sigue activo
  var thisWeek: Bool?             //si el mensaje caduca en los próximos 5 días
  var saved: Bool?                //si el mensaje se ha guardado o no
  
  init(notification: NSDictionary) {
    self.alert        = notification["aps"]?["alert"] as? String
    self.messageID    = notification["_id"] as? String
    self.body         = notification["content"]?["body"] as? String
    self.deadline     = notification["content"]?["deadline"] as? String
    self.producerID   = notification["producer"]?["pid"] as? String
    self.producer     = notification["producer"]?["name"] as? String
    self.category     = notification["producer"]?["category"] as? String
    self.address      = (notification["producer"]?["address"] as! NSDictionary)["street"] as? String
    self.city         = (notification["producer"]?["address"] as! NSDictionary)["city"] as? String
    self.longitude    = (notification["producer"]?["geo"] as! NSDictionary)["longitude"] as? Double
    self.latitude     = (notification["producer"]?["geo"] as! NSDictionary)["latitude"] as? Double
    self.phone        = (notification["producer"]?["contact"] as! NSDictionary)["phone"] as? String
    self.email        = (notification["producer"]?["contact"] as! NSDictionary)["email"] as? String
    self.web          = (notification["producer"]?["contact"] as! NSDictionary)["web"] as? String
    self.cateversion  = notification["cat"]?["version"] as? String
    self.protoversion = notification["protocol"]?["version"] as? String
    self.finished     = false
    self.saved        = false
    self.thisWeek     = false
  }
  
  required init?(coder aDecoder: NSCoder) {
    alert      = aDecoder.decodeObjectForKey("alert") as? String
    messageID  = aDecoder.decodeObjectForKey("messageID") as? String
    body       = aDecoder.decodeObjectForKey("body") as? String
    deadline   = aDecoder.decodeObjectForKey("deadline") as? String
    producerID = aDecoder.decodeObjectForKey("producerID") as? String
    producer   = aDecoder.decodeObjectForKey("producer") as? String
    category   = aDecoder.decodeObjectForKey("category") as? String
    address    = aDecoder.decodeObjectForKey("address") as? String
    city       = aDecoder.decodeObjectForKey("city") as? String
    longitude  = aDecoder.decodeObjectForKey("longitude") as? Double
    latitude   = aDecoder.decodeObjectForKey("latitude") as? Double
    phone      = aDecoder.decodeObjectForKey("phone")   as? String
    email      = aDecoder.decodeObjectForKey("email")   as? String
    web        = aDecoder.decodeObjectForKey("web")   as? String
    cateversion  = aDecoder.decodeObjectForKey("cateversion") as? String
    protoversion = aDecoder.decodeObjectForKey("protoversion") as? String
    finished   = aDecoder.decodeObjectForKey("finished") as? Bool
    thisWeek   = aDecoder.decodeObjectForKey("thisWeek") as? Bool
    saved      = aDecoder.decodeObjectForKey("saved") as? Bool
  }
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(alert,      forKey:"alert")
    aCoder.encodeObject(messageID,  forKey:"messageID")
    aCoder.encodeObject(body,       forKey:"body")
    aCoder.encodeObject(deadline,   forKey:"deadline")
    aCoder.encodeObject(producerID, forKey:"producerID")
    aCoder.encodeObject(producer,   forKey:"producer")
    aCoder.encodeObject(category,   forKey:"category")
    aCoder.encodeObject(address,    forKey:"address")
    aCoder.encodeObject(city,       forKey:"city")
    aCoder.encodeObject(longitude,  forKey:"longitude")
    aCoder.encodeObject(latitude,   forKey:"latitude")
    aCoder.encodeObject(phone,      forKey:"phone")
    aCoder.encodeObject(email,      forKey:"email")
    aCoder.encodeObject(web,        forKey:"web")
    aCoder.encodeObject(cateversion,    forKey:"cateversion")
    aCoder.encodeObject(protoversion,   forKey:"protoversion")
    aCoder.encodeObject(finished,   forKey:"finished")
    aCoder.encodeObject(thisWeek,   forKey:"thisWeek")
    aCoder.encodeObject(saved,      forKey:"saved")
  }
  
  func deadlineFormatter(isLong: Bool) -> String {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let myDate = dateFormatter.dateFromString(deadline!)
    let daysLeft = Int(ceil((myDate?.timeIntervalSinceNow)!/60/60/24))
    let intLong: Int
    if isLong {
      intLong = 1
    } else {
      intLong = 0
    }
    
    if daysLeft < 0 {
      finished = true
      switch intLong {
      case 1:
        return "terminado hace \(daysLeft*(-1)) días"
      case 0:
        return "terminado"
      default:
        return ""
      }
    } else if daysLeft == 0 {
      thisWeek = true
      switch intLong {
      case 1:
        dateFormatter.dateFormat = "eee dd MMM"
        return "\(dateFormatter.stringFromDate(myDate!)) hoy"
      case 0:
        return "hoy"
      default:
        return ""
      }
    } else if daysLeft <= 6 {
      thisWeek = true
      switch intLong {
      case 1:
        dateFormatter.dateFormat = "eee dd MMM"
        return "\(dateFormatter.stringFromDate(myDate!)) (quedan \(daysLeft) días)"
      case 0:
        return "quedan \(daysLeft) días"
      default:
        return ""
      }
    } else {
      switch intLong {
      case 1:
        dateFormatter.dateFormat = "eeee dd MMMM"
        return dateFormatter.stringFromDate(myDate!)
      case 0:
        dateFormatter.dateFormat = "eee dd MMM"
        return dateFormatter.stringFromDate(myDate!)
      default:
        return ""
      }
    }
  }
}
