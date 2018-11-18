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
    @IBOutlet weak var reccommendedWorkoutPicker: UIPickerView!
    @IBOutlet weak var customWorkoutPicker: UIPickerView!
    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet weak var numCaloriesBurnedLabel: UILabel!
    
    var reccommendedPickerData: [String] = [String]()
    var customPickerData: [String] = [String]()
    var exerciseData = [String:Int]()
    var exercisePlanData = [String:Double]()
    let healthKitManager = HealthKitManager()
    
    override func viewDidLoad() {
        self.reccommendedWorkoutPicker.delegate = self
        self.customWorkoutPicker.delegate = self
        self.reccommendedWorkoutPicker.dataSource = self
        self.customWorkoutPicker.dataSource = self
        
        reccommendedPickerData = ["", "Exercise Plan 1", "Exercise Plan 2", "Exercise Plan 3"]
        customPickerData = ["", "Mooch", "Grind", "Fishtail", "Camelwalk"]
        exerciseData = ["Mooch": 30, "Grind": 25, "Fishtail": 40, "Camelwalk": 42]
        exercisePlanData = ["Exercise Plan 1": 300.0, "Exercise Plan 2": 450.0, "Exercise Plan 3": 600.0]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return reccommendedPickerData.count
        }
        return customPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView.tag == 1){
            return "\(reccommendedPickerData[row])"
        }else{
            return "\(customPickerData[row])"
        }
    }
    @IBAction func doneButtonDidTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func saveEnergyBurnedToHealthKit() -> Double {
        if let text = durationTextField.text, !text.isEmpty{
            let numMinutes:Int? = Int(text)
            let selectedRow = customWorkoutPicker.selectedRow(inComponent: 0)
            let selectedValue = customPickerData[selectedRow]
            let numCaloriesBurned = (numMinutes ?? 0) * (exerciseData[selectedValue] ?? 0)
            numCaloriesBurnedLabel.text = "You burned \(numCaloriesBurned) calories!"
            return Double(numCaloriesBurned)
        }

        let selectedRow = reccommendedWorkoutPicker.selectedRow(inComponent: 0)
        let selectedValue = reccommendedPickerData[selectedRow]
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

        durationTextField.text = ""
        reccommendedWorkoutPicker.selectRow(0, inComponent: 0, animated: true)
        customWorkoutPicker.selectRow(0, inComponent: 0, animated: true)
    }
}
