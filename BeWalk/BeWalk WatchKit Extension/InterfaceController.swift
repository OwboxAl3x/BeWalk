//
//  InterfaceController.swift
//  BeWalk WatchKit Extension
//
//  Created by Alejandro Garcia Vallecillo on 16/6/18.
//  Copyright © 2018 Alejandro Garcia Vallecillo. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit


class InterfaceController: WKInterfaceController, Item1ChooserDelegate {
    
    @IBOutlet var objectLabel: WKInterfaceLabel!
    @IBOutlet var animLabel: WKInterfaceLabel!
    @IBOutlet var pasosLabel: WKInterfaceLabel!
    @IBOutlet var restLabel: WKInterfaceLabel!
    @IBOutlet var startLabel: WKInterfaceButton!
    
    var pasos: String = "Meta: 0"
    var motivacion: String = "Tu puedes!"
    var quedan: String = "Quedan: 0"
    var countPasos: String = "0 pasos"
    var start: String = "Comenzar"
    var fechaComienzo: Date?
    
    let healthStore = HKHealthStore()
    
    var pasosCero: Double = 0.0
    
    var session: HKWorkoutSession?
    
    @IBAction func comenzar() {
        
        if start == "Comenzar" {
            
            var pasosNoText = self.pasos.components(separatedBy: " ")
            self.quedan = "Quedan: "+pasosNoText[1]
            
            if Int(pasosNoText[1]) != 0 {
                
                self.fechaComienzo = Date()
                
                self.restLabel.setText(quedan)
                self.countPasos = "0 pasos"
                self.pasosLabel.setText(countPasos)
                self.startWorkout()
                startLabel.setTitle("Parar")
                start = "Parar"
                
            } else {
                
                let action = WKAlertAction(title: "Aceptar", style: WKAlertActionStyle.default) { }
                
                presentAlert(withTitle: "Ponte una meta", message: "Necesitas una meta para comenzar", preferredStyle: WKAlertControllerStyle.alert, actions:[action])
                
            }
            
        } else {
            
            recargarInterface()
            self.stopWorkout()
            startLabel.setTitle("Comenzar")
            start = "Comenzar"
            crearAlert()
            
        }
        
    }
    
    func crearAlert(){
        
        let action = WKAlertAction(title: "Aceptar", style: WKAlertActionStyle.default) {
            
            var pasosNoText = self.pasos.components(separatedBy: " ")
            self.quedan = "Quedan: "+pasosNoText[1]
            self.restLabel.setText(self.quedan)
            self.countPasos = "0 pasos"
            self.pasosLabel.setText(self.countPasos)
            
        }
        
        presentAlert(withTitle: "Terminado!", message: "Has terminada el paseo.", preferredStyle: WKAlertControllerStyle.alert, actions:[action])
        
    }
    
    func getSteps(completion: @escaping (Double) -> Void) {
        
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        let now = Date()
        let predicate = HKQuery.predicateForSamples(withStart: fechaComienzo!, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
            var resultCount = 0.0
            guard let result = result else {
                print("Failed to fetch steps rate")
                completion(resultCount)
                return
            }
            if let sum = result.sumQuantity() {
                resultCount = sum.doubleValue(for: HKUnit.count())
            }
            
            DispatchQueue.main.async {
                completion(resultCount)
            }
        }
        healthStore.execute(query)
    }
    
    @IBAction func recargar() {
        
        recargarInterface()
        
    }
    
    @IBAction func objPasos() {
        
        self.pushController(withName: "ObjetivoPasos", context: self)
        
    }
    
    func changeMeta(valor: String){
        
        print("Valor cambiado a "+valor)
        self.pasos = valor
        
    }
    
    func recargarInterface(){
        
        if start == "Parar" {
            
            getSteps { (result) in
                DispatchQueue.main.async {
                    var pasosNoText = self.pasos.components(separatedBy: " ")
                    var restan = Double(pasosNoText[1])!-result
                    if restan <= 0.0 {
                        
                        restan = 0.0
                        self.stopWorkout()
                        self.startLabel.setTitle("Comenzar")
                        self.start = "Comenzar"
                        self.crearAlert()
                        
                    } else {
                        
                        self.quedan = "Quedan: \(Int(restan))"
                        self.restLabel.setText(self.quedan)
                        self.countPasos = "\(Int(result)) pasos"
                        self.pasosLabel.setText(self.countPasos)
                        
                    }
                }
            }
            
        }
        
    }
    
    func startWorkout() {
        // If we have already started the workout, then do nothing.
        if (session != nil) {
            return
        }
        
        // Configure the workout session.
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .walking
        workoutConfiguration.locationType = .outdoor
        
        do {
            session = try HKWorkoutSession(configuration: workoutConfiguration)
        } catch {
            fatalError("Unable to create the workout session!")
        }
        
        // Start the workout session and device motion updates.
        healthStore.start(session!)
    }
    
    func stopWorkout() {
        // If we have already stopped the workout, then do nothing.
        if (session == nil) {
            return
        }
        
        // Stop the device motion updates and workout session.
        healthStore.end(session!)
        
        // Clear the workout session.
        session = nil
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        animLabel.setText(motivacion)
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        objectLabel.setText(pasos)
        pasosLabel.setText(countPasos)
        restLabel.setText(quedan)
        startLabel.setTitle(start)
        super.willActivate()
        
        recargarInterface()
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
