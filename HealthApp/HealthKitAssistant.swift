//
//  HealthKitAssistant.swift
//  HealthApp
//
//  Created by Tatsuya Moriguchi on 8/6/20.
//  Copyright © 2020 Tatsuya Moriguchi. All rights reserved.
//

import Foundation
import HealthKit

class HealthKitAssistant {
    // Shared Variable
    static let shared = HealthKitAssistant()
    
    // HealthKit store object
    let healthKitStore = HKHealthStore()
    
    // MARK: Permission Block
    func getHealthKitPermission(completion: @escaping (Bool) -> Void) {
        
        // Check if HealthKit is available
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }
        
        //let stepCount = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
        
        let allTypes = Set([HKObjectType.quantityType(forIdentifier: .stepCount),
                            HKObjectType.workoutType(),
                            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
                            HKObjectType.quantityType(forIdentifier: .distanceCycling),
                            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning),
                            HKObjectType.quantityType(forIdentifier: .heartRate),
        ])
        
//        self.healthKitStore.requestAuthorization(toShare: [stepCount], read: [stepCount]) { (success, error) in
        self.healthKitStore.requestAuthorization(toShare: (allTypes as! Set<HKSampleType>), read: (allTypes as! Set<HKObjectType>)) { (success, error) in
            if success {
                completion(true)
            } else {
                if error != nil {
                    print(error ?? "HealthKit Authorization Error")
                }
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
        
    }
    
    // Get recent step data
    func getMostRecentStep(for sampleType: HKQuantityType, completion: @escaping (_ stepRetrieved: Int, _ stepAll : [[String : String]]) -> Void ) {
        
        // Use HKQuery to load the most recent samples.
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictStartDate)
        
        var interval = DateComponents()
        interval.day = 1
        
        let stepQuery = HKStatisticsCollectionQuery(quantityType: sampleType, quantitySamplePredicate: mostRecentPredicate, options: .cumulativeSum, anchorDate: Date.distantPast, intervalComponents: interval)
        stepQuery.initialResultsHandler = { query, results, error in
            if error != nil {
                // Something went wrong.
                print(error as Any)
                return
            }
            
            if let myResults = results {
                var stepsData : [[String : String]] = [[:]]
                var steps : Int = Int()
                stepsData.removeAll()
                
                myResults.enumerateStatistics(from: Date.distantPast, to: Date()) {
                    statistics, stop in
                    
                    // Take local variable
                    if let quantity = statistics.sumQuantity() {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MMM d, yyyy"
                        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
                        dateFormatter.timeZone = NSTimeZone.local
                        
                        var tempDic : [String : String]?
                        let endDate: Date = statistics.endDate
                        
                        steps = Int(quantity.doubleValue(for: HKUnit.count()))
                        //print("DataStore Steps = \(steps)")
                        
                        tempDic = [
                            "enddate" : "\(dateFormatter.string(from: endDate))",
                            "steps" : "\(steps)"
                        ]
                        
                        stepsData.append(tempDic!)
                    }
                    
                }
                    completion(steps, stepsData.reversed())
            }
        }
        HKHealthStore().execute(stepQuery)
    }

}

