//
//  LogWorkoutViewController.swift
//  MeghanHealthKitDemo
//
//  Created by Meghan Mehta on 11/14/18.
//  Copyright © 2018 Meghan Mehta. All rights reserved.
//

import UIKit
import HealthKit
class LogWorkoutViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var recommendedExercisePicker: UIPickerView!
    @IBOutlet weak var customWorkoutPicker: UIPickerView!
    @IBOutlet weak var numCaloriesBurnedLabel: UILabel!
    
    var recommendedPickerData: [String] = [String]()
    var customPickerData: [String] = [String]()
    var exerciseData = [String:Int]()
    var exercisePlanData = [String:Double]()
    let healthKitManager = HealthKitManager()
    
    override func viewDidLoad() {
        self.recommendedExercisePicker.delegate = self
        self.recommendedExercisePicker.dataSource = self
        
        recommendedPickerData = ["", "Exercise Plan 1", "Exercise Plan 2", "Exercise Plan 3"]
        exercisePlanData = ["Exercise Plan 1": 300.0, "Exercise Plan 2": 450.0, "Exercise Plan 3": 600.0]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return recommendedPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(recommendedPickerData[row])"
    }
    
    @IBAction func doneButtonDidTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func saveEnergyBurnedToHealthKit() -> Double {
        let selectedRow = recommendedExercisePicker.selectedRow(inComponent: 0)
        let selectedValue = recommendedPickerData[selectedRow]
        let numCaloriesBurned = exercisePlanData[selectedValue] ?? 0.0
        numCaloriesBurnedLabel.text = "You burned \(numCaloriesBurned) calories!"
        return exercisePlanData[selectedValue] ?? 0.0
    }
    
    @IBAction func logWorkoutDidTap(_ sender: Any) {
        //checks access to the type still exists
        guard let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            numCaloriesBurnedLabel.text = "Active Energy is no longer available in Health Kit"
            return
        }
        //function calculates calories burned from workout
        let numCalories = saveEnergyBurnedToHealthKit()
        //takes in the unit (calories) and the number of calories burned
        let calorieQuantity = HKQuantity(unit: HKUnit.kilocalorie(),
                                         doubleValue: numCalories)
        //specifies that this is of type activeEnergy, takes in the calories burned and specifies it is for today
        let activeEnergySample = HKQuantitySample(type: activeEnergyType,
                                                  quantity: calorieQuantity,
                                                  start: Date(),
                                                  end: Date())
        
        //saves data to Health Kit
        healthKitManager.save(object: activeEnergySample){ (success, error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        recommendedExercisePicker.selectRow(0, inComponent: 0, animated: true)
    }
}
