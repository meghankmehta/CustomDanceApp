//
//  HealthKitManager.swift
//  MeghanHealthKitDemo
//
//  Created by Meghan Mehta on 11/11/18.
//  Copyright © 2018 Meghan Mehta. All rights reserved.
//

import Foundation
import HealthKit

class HealthKitManager {
    let healthStore = HKHealthStore()
    
    func authorizeHealthKit() -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            return false
        }
        return true
    }
    
    func save(object: HKObject, completion: @escaping (Bool, Error?) -> Void) {
        healthStore.save(object, withCompletion: completion)
    }
    
    func requestReadWriteAccess() {
        //make sure the types of data we want exists
        guard
            let dietaryEnergyConsumed = HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed),
            let activeEnergyBurned = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
            let bloodType = HKObjectType.characteristicType(forIdentifier: .bloodType),
            let bioSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex)
            else {
                return
            }
        
        //compile into two sets: data we want to read and data we want to write
        let healthKitTypesToWrite: Set<HKSampleType> = [activeEnergyBurned]
        let healthKitTypesToRead: Set<HKObjectType> = [activeEnergyBurned,
                                                       bloodType,
                                                       bioSex,
                                                       dietaryEnergyConsumed]
        
        //request authorization from our healthStore object
        healthStore.requestAuthorization(toShare: healthKitTypesToWrite,
                                         read: healthKitTypesToRead) { (bool, error) in
                                            if let e = error {
                                                print(e.localizedDescription)
                                                return
                                            }
        }
    }
    
    func getEnergyConsumed(completion: @escaping (Double) -> Void) {
        //check that we still have access to the dietaryEnergyConsumed
        guard let dietaryEnergyType = HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed) else {
            return
        }
        //set up predicate to go from beginning of day until now
        let midnight = Calendar.current.startOfDay(for: Date())
        let todayPredicate = HKQuery.predicateForSamples(withStart: midnight,
                                                         end: Date(),
                                                         options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: dietaryEnergyType,
                                      quantitySamplePredicate: todayPredicate,
                                      options: .cumulativeSum){ (_, result, error) in
                                        var resultCount = 0.0
                                        guard let result = result else {
                                            //if we do not get a result back, return
                                            completion(resultCount)
                                            return
                                        }
                                        //sets our value to the total energy consumed
                                        if let sum = result.sumQuantity() {
                                            resultCount = sum.doubleValue(for: HKUnit.kilocalorie())
                                        }
                                        DispatchQueue.main.async {
                                            //pushes this value back onto the main thread
                                            completion(resultCount)
                                        }
        }
        //executes the query
        healthStore.execute(query)
    }
    
    func getEnergyBurned(completion: @escaping (Double) -> Void) {
        
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
            var resultCount = 0.0
            guard let result = result else {
                print("Failed to fetch todays exercise")
                completion(resultCount)
                return
            }
            if let sum = result.sumQuantity() {
                resultCount = sum.doubleValue(for: HKUnit.kilocalorie())
            }
            
            DispatchQueue.main.async {
                completion(resultCount)
            }
        }
        healthStore.execute(query)
    }
}
