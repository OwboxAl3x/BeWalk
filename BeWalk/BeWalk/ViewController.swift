//
//  ViewController.swift
//  BeWalk
//
//  Created by Alejandro Garcia Vallecillo on 16/6/18.
//  Copyright © 2018 Alejandro Garcia Vallecillo. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {
    
    let healthStore = HKHealthStore()

    @IBAction func autorizarSalud(_ sender: Any) {
        
        let healthKitTypes: Set = [
            // access step count
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
        ]
        healthStore.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes) { (_, _) in
            print("Autorizado?")
        }
        healthStore.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes) { (bool, error) in
            if let e = error {
                print("Algo fue mal durante la autorización \(e.localizedDescription)")
            } else {
                print("El usuario ha completado la autorización")
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

