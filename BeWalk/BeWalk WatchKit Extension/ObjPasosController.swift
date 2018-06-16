//
//  ObjPasosController.swift
//  BeWalk WatchKit Extension
//
//  Created by Alejandro Garcia Vallecillo on 16/6/18.
//  Copyright © 2018 Alejandro Garcia Vallecillo. All rights reserved.
//

import WatchKit
import Foundation

protocol Item1ChooserDelegate {
    func changeMeta(valor: String)
}

class ObjPasosController: WKInterfaceController {

    @IBOutlet var pickerPasos: WKInterfacePicker!
    
    var items: [String]! = nil
    
    var delegate: InterfaceController?
    
    @IBAction func pickerDidChange(_ value: Int) {
        
        self.delegate?.changeMeta(valor: "Meta: \(items.index(after: value))")
        
    }
    
    @IBAction func cambiarObjetivo() {
        
        self.pop()
        
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.delegate = context as? InterfaceController
        
        self.setTitle("Atras")
        rellenarPicker()
        
    }
    
    func rellenarPicker() {
        
        items = (1...1000).map { "\($0)" }
        
        let pickerItems: [WKPickerItem] = items.map {
            let pickerItem = WKPickerItem()
            pickerItem.title = $0
            return pickerItem
        }
        
        pickerPasos.setItems(pickerItems)
        
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
