//
//  MessageList.swift
//  e2e
//
//  Created by José Luis Díaz González on 17/7/15.
//  Copyright (c) 2015 UPM. All rights reserved.
//

import Foundation

class MessageList {
  
  //enum que contiene las keys donde va a guardarse las distintas listas de mensajes en UserDefaults
  enum ListKeys: String {
    case Global   = "messages"          //lista que guarda todos los mensajes que van llegando
    case Saved    = "saved"             //lista que guarda los mensajes marcados como guardados
    case Filtered = "filtered"          //lista que guarda los mensajes filtrados por una determinada categoría

    static let allValues = [Global, Saved]
    
  }
  
  //lista que contiene todos los mensajes
  var messList: [Message] = []
  //la lista que tiene cargada actualmente la clase
  var loadedKey: ListKeys?
  
  init() {
    print("INIT: REMOTE retrieve messages list from the server")
  }
  //recibe como parámetro la Key del UserDefaults donde se va a guardar la lista de mensajes
  //si existe la Key carga su contenido
  //si no existe la Key, la crea e inicializa a una lista vacía
  init(myKey: ListKeys) {
    let defaults = NSUserDefaults.standardUserDefaults()
    if defaults.objectForKey(myKey.rawValue) != nil {
      //si existe la key en UserDefaults y contiene algo, cargo ese algo con el método loadList()
      print("INIT: \(myKey.rawValue) key exists")
      print("INIT: loading contents from \(myKey.rawValue) list")
      self.loadList(myKey)
    } else {
      //la key o no existe, o existe pero está vacía, así que la inicializo
      messList = []
      print("INIT: \(myKey.rawValue) key doesn't exists")
      print("INIT: creating new empty list and saving in \(myKey.rawValue) key")
      //lista vacía serializada para crear la entrada en el UserDefaults
      let myEmptyListData = NSKeyedArchiver.archivedDataWithRootObject(messList)
      defaults.setObject(myEmptyListData, forKey: myKey.rawValue)
    }
  }
  
  //carga los contenidos de la Key dada como parámetro en el array messList
  func loadList(myKey: ListKeys) {
    let defaults = NSUserDefaults.standardUserDefaults()
    //leemos el NSData almacenado en la key del UserDefaults
    if let data = defaults.dataForKey(myKey.rawValue) {
      //extraemos el NSData para poder leerlo como un array de objetos Message
      if let readList = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [Message] {
        messList = readList
        loadedKey = myKey
        print("LOAD: \(myKey.rawValue) list loaded with \(messList.count) items")
      } else {
        print("ERROR: NSData extraction failed")
        messList = [] //ha fallado la extracción del NSData
      }
    } else {
      print("ERROR: reading key \(myKey.rawValue) failed")
      messList = [] //ha fallado la lectura de la key en el UserDefaults
    }
  }
  
  //carga en el array messList otro array pasado como parámetro
  func loadTempList(tempList: [Message]) {
    messList = tempList
  }
  
  //guarda el array messList en la Key del UserDefaults pasada como parámetro
  //antes de guardar la lista la ordena por fecha de caducidad
  func saveList(myKey: ListKeys) {
    let defaults = NSUserDefaults.standardUserDefaults()
    let messListData = NSKeyedArchiver.archivedDataWithRootObject(sortedByDeadline())
    defaults.setObject(messListData, forKey: myKey.rawValue)
    defaults.synchronize()
    print("SAVE: List saved in \(myKey.rawValue) key with (\(messList.count) elements)")
  }
  
  //inserta un nuevo mensaje recibido al inicio del array
  func addMessage(mess: Message) {
    messList.insert(mess, atIndex: 0)
    print("ADD: message \(mess.messageID!) added")
  }
  
  //elimina el mensaje en el índice del array messIndex
  func deleteMessage(messIndex: Int) {
    print("DELETE: message \(messList[messIndex].messageID!) at index \(messIndex) deleted")
    messList.removeAtIndex(messIndex)
  }
  
  func getMessagesFromServerByCategory(catID: String, completionHandler: ([Message]) -> ()) {
    let req = RESTRequestController(e2eServer: Server().getServer())
    req.getMessagesByCategory(catID) { (messes) in
      for mess in messes {
        self.messList.append(Message(notification: mess as! NSDictionary))
        print("DEBUG: \(self.messList[0].messageID!)")
        print("DEBUG: \(self.messList[0].deadline!)")
      }
      print("REMOTE: retrieve \(self.messList.count) messages")
      self.sortedByDeadline()
      completionHandler(self.messList)
    }
  }
  
  //elimina un mensaje de todas las listas, Global y Saved para que haya consistencia de datos
  func deleteMessegeFromAllList(messID: String) {
    let originalList = loadedKey
    for key in ListKeys.allValues {
      loadList(key)
      if let realIndex = findMessageIndex(messID) {
        deleteMessage(realIndex)
        saveList(key)
        print("DELETE: message \(messID) deleted from list \(key.rawValue)")
      } else {
        continue
      }
    }
    loadList(originalList!)
  }
  
  //elimina una lista de mensajes de todas las lista
  func deleteMessagesFromAllList(myMessList: [Message]) {
    let originalList = loadedKey!
    for mess in myMessList {
      for key in ListKeys.allValues {
        loadList(key)
        if let realIndex = findMessageIndex(mess.messageID!) {
          deleteMessage(realIndex)
          saveList(key)
        } else {
          continue
        }
        
      }
    }
    loadList(originalList)
  }
  
  //elimina una lista de mensajes caducados de todas las listas
  func deleteFinishedMessagesFromAllList(myMessList: [Message]) {
    let originalList = loadedKey!
    for mess in myMessList {
      for key in ListKeys.allValues {
        loadList(key)
        if mess.finished! {
          if let realIndex = findMessageIndex(mess.messageID!) {
            deleteMessage(realIndex)
            saveList(key)
          } else {
            continue
          }
        } else {
          continue
        }
      }
    }
    loadList(originalList)
  }
  
  //elimina todos los mensajes terminados
  //devuelve los NSIndexPath de los mensajes borrados
  func deleteAllFinishedMessages() -> [NSIndexPath] {
    var deletedIndexes: [NSIndexPath] = []
    //recorremos el array de forma inversa para que al borrar un elemento
    //no cambie el índice del resto de elementos
    for index in (messList.count - 1).stride(through: 0, by: -1) {
      if messList[index].finished! {
        deletedIndexes.insert(NSIndexPath(forRow: index, inSection: 0), atIndex: 0)
        messList.removeAtIndex(index)
      } else {
        continue
      }
    }
    return deletedIndexes
  }
  
  func existMessage(messID: String) -> Bool {
    for mess in messList {
      if mess.messageID! == messID {
        print("EXIST: message \(messID) already exists")
        return true
      }
    }
    print("EXIST: message \(messID) doesn't exist")
    return false
  }
  
  func findMessageIndex(messID: String) -> Int? {
    for index in 0..<messList.count {
      if messList[index].messageID! == messID {
        print("FIND: message \(messID) found at index \(index)")
        return Int(index)
      }
    }
    print("FIND: message \(messID) not found")
    return nil
  }
  
  func moveToSavedList(mess: Message, messIndex: Int) {
    //mueve un mensaje de la lista Mensajes a la lista Guardados
    //cargamos la lista de Guardados en una nueva variable
    //se supone que tenemos cargada la lista Mensajes
    print("MOVE: index is \(messIndex)")
    let myTempList: MessageList = MessageList(myKey: .Saved)
    mess.saved = true
    //añadimos el mensaje a la lista y la guardamos
    myTempList.addMessage(mess)
    print("MOVE: message \(mess.messageID!) added to saved list")
    myTempList.saveList(.Saved)
    //cargamos la lista Mensajes
    //borramos el mensaje de la lista Mensajes y la guardamos
    print("MOVE: message \(mess.messageID!) removed from messages list")
    deleteMessage(messIndex)
    saveList(.Global)
  }
  
  func addToSavedList(mess: Message) {
    let myTempList: MessageList = MessageList(myKey: .Saved)
    mess.saved = true
    myTempList.addMessage(mess)
    print("ADD: message \(mess.messageID!) added to saved list")
    myTempList.saveList(.Saved)
  }
  
  func deleteFromSavedList(messIndex:Int) {
    let myTempList: MessageList = MessageList(myKey: .Saved)
    print("DEBUG: index \(messIndex)")
    myTempList.deleteMessage(messIndex)
    myTempList.saveList(.Saved)
  }
  
  func removeFromSavedList(mess: Message, messIndex: Int) {
    //mueve un mensaje de la lista Guardados a la lista Mensajes
    print("REMOVE: index is \(messIndex)")
    let myTempList: MessageList = MessageList(myKey: .Global)
    mess.saved = false
    myTempList.addMessage(mess)
    print("REMOVE: message \(mess.messageID!) added to messages list")
    myTempList.saveList(.Global)
    
    print("REMOVE: message \(mess.messageID!) removed from saved list")
    print("DEBUG: index \(messIndex)")
    deleteMessage(messIndex)
    saveList(.Saved)
  }
  
  //obtiene una lista con todas las categorías de los mensajes de messList
  func getAvailableCategories() -> [String] {
    var catArray: [String] = []
    for mess in messList {
      if catArray.contains((mess.category!)) {
        continue
      } else {
        catArray += [mess.category!]
      }
    }
    catArray = catArray.sort(sortListAlphabetically)
    if catArray.count == 0 {
      catArray = ["Vacío"]
    } else {
      catArray.insert("Todos", atIndex: 0)
    }
    return catArray
  }
  
  func getAllIndexPaths() -> [NSIndexPath] {
    var indexArray: [NSIndexPath] = []
    for index in 0..<messList.count {
      indexArray += [NSIndexPath(forRow: index, inSection: 0)]
    }
    return indexArray
  }
  
  func sortedByDeadline() -> [Message] {
    return messList.sort(sortListByDeadlineAscending)
  }
  
  func filteredByCategory(category: String) {
    messList = messList.filter({$0.category == category})
    saveList(.Filtered)
  }
  
  func sortListByDeadlineAscending(mess1: Message, mess2: Message) -> Bool {
    return mess1.deadline < mess2.deadline
  }
  
  func sortListAlphabetically(s1: String, s2: String) -> Bool {
    return s1 < s2
  }
}
