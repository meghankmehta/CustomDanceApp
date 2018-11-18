//
//  SmartWorkoutViewController.swift
//  MeghanHealthKitDemo
//
//  Created by Meghan Mehta on 11/14/18.
//  Copyright © 2018 Meghan Mehta. All rights reserved.
//

import UIKit
class SmartWorkoutViewController: UIViewController {
    var energyConsumed: Double = 0.0
    var energyBurned: Double = 0.0
    let healthManager = HealthKitManager()
    
    @IBOutlet weak var sleepHoursLabel: UILabel!
    @IBOutlet weak var foodEatenLabel: UILabel!
    @IBOutlet weak var danceReccommendationLabel: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func personalizedButtonDidTap(_ sender: Any) {
        if energyBurned > energyConsumed || energyConsumed == 0 {
            danceReccommendationLabel.text = "It is reccommended that you eat before you dance again!"
        }
        if energyBurned == energyConsumed {
            danceReccommendationLabel.text = "Exercise rountine 1\n-5 minutes of mooches : targets obliques \n\n-10 minutes of grinds : targets glutes \n\n-10 minutes of fishtails : targets upper thighs"
        }
        if energyConsumed - energyBurned < 1000 {
            danceReccommendationLabel.text = "Exercise routine 2\n-10 minutes of mooches : targets obliques \n\n-10 minutes of camel walks : targets calves \n\n-12 minutes of grinds : targets glutes \n\n-20 minutes of fishtails : targets upper thighs"
        }
        else {
            danceReccommendationLabel.text = "Exercise routine 3\n-15 minutes of mooches : targets obliques \n\n-12 minutes of grinds : targets glutes \n\n-20 minutes of fishtails : targets upper thighs"
        }
    }

    @IBAction func updateDataDidTap(_ sender: Any) {
        healthManager.getEnergyBurned { (result) in
            DispatchQueue.main.async {
                self.sleepHoursLabel.text = "Energy burned today: + \(result)"
                self.energyBurned = result
            }
        }
        healthManager.getEnergyConsumed{ (result) in
            DispatchQueue.main.async {
                self.foodEatenLabel.text = "Energy consumed today: + \(result)"
                self.energyConsumed = result
            }
        }
    }
    
    @IBAction func doneButtonDidTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
