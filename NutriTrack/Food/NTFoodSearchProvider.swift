//
//  NTSearchProvider.swift
//  NutriTrack
//
//  Created by Avais on 2016-04-19.
//  Copyright © 2016 Aveth. All rights reserved.
//

import UIKit
import CoreData

class NTSearchProvider {
    
    private enum Error: Int {
        case None
        case NoResults
        case ParsingError
        case ServerError
    }
    
    internal enum Diet: Int {
        case Renal
        case Diabetic
        func nutrientCodes() -> [String] {
            switch self {
                case Diabetic: return ["205", "269"]
                case Renal: return ["305", "306", "307"]
            }
        }
    }

    internal var service: NTSearchService
    
    private let errorDomain: String = "com.aveth.NutriTrack.NTSearchProvider"
    
    lazy private var managedObjectContext: NSManagedObjectContext = {
        return NTCoreDataContextProvider.sharedProvider.managedObjectContext
    }()
    
    init(service: NTSearchService) {
        self.service = service
    }
    
    internal func fetchFoods(query: String, success: ((originalQuery: String, results: [NTFood]) -> Void), failure:((error: ErrorType) -> Void)?) {
        
        self.service.fetchResults(searchQuery: query,
            success: { (result: [String: AnyObject]) -> Void in
                
                if let
                    resultsDict = result["data"]?["results"] as? [[String: AnyObject]],
                    originalQuery = result["data"]?["query"] as? String
                {
                    let foods = self.arrayToFoods(resultsDict)
                    success(originalQuery: originalQuery, results: foods)
                
                } else if let errCode = result["errors"]?["code"] as? String where errCode == "err_no_results" {
                    
                    if let fail = failure {
                        let error: NSError = NSError(domain: self.errorDomain, code: NTSearchProvider.Error.NoResults.rawValue, userInfo: nil)
                        fail(error: error)
                    }
                
                } else {
                    
                    if let fail = failure {
                        let error: NSError = NSError(domain: self.errorDomain, code: NTSearchProvider.Error.ParsingError.rawValue, userInfo: nil)
                        fail(error: error)
                    }
                
                }
                
            },
            failure: { (error: ErrorType) -> Void in
                if let fail = failure {
                    fail(error: error)
                }
            }
        )
        
    }
    
    internal func fetchFoodDetails(id: String, diet: NTSearchProvider.Diet, success: ((result: NTFood) -> Void), failure:((error: ErrorType) -> Void)?) {
        
        self.service.fetchDetails(itemId: id,
            success: { (result: [String: AnyObject]) -> Void in
                if let
                    dict = result["data"] as? [AnyObject],
                    firstResult = dict.first,
                    resultId = firstResult["id"] as? String,
                    resultName = firstResult["name"] as? String
                    where resultId == id
                {
                    let food = NTFood(id: resultId, name: resultName)
                    if let measures = firstResult["measures"] as? [[String: AnyObject]] {
                        food.measures = self.arrayToMeasureItems(measures)
                    }
                    if let nutrients = firstResult["nutrients"] as? [[String: AnyObject]] {
                        food.nutrients = self.arrayToNutrientItems(nutrients, nutrientCodes: NTSearchProvider.Diet.Renal.nutrientCodes())
                    }
                    success(result: food)
                }
            },
            failure: { (error: ErrorType) -> Void in
                
            }
        )
        
    }
    
    private func arrayToFoods(array: [[String: AnyObject]]) -> [NTFood] {
        var result = [NTFood]()
        for dict: [String: AnyObject] in array {
            if let
                id = dict["id"] as? String,
                name = dict["name"] as? String
            {
                let item = NTFood(id: id, name: name)
                result.append(item)
            }
        }
        return result
    }
    
    private func arrayToMeasureItems(array: [[String: AnyObject]]) -> [NTMeasure] {
        var result = [NTMeasure]()
        for measure: [String: AnyObject] in array {
            if let
                name = measure["name"] as? String,
                value = measure["value"] as? Float
            {
                let item = NTMeasure(name: name, value: value)
                result.append(item)
            }
        }
        return result
    }
    
    private func arrayToNutrientItems(array: [[String: AnyObject]], nutrientCodes: [String]?) -> [NTNutrient] {
        var result = [NTNutrient]()
        for nutrient: [String: AnyObject] in array {
            if let
                id = nutrient["id"] as? String,
                name = nutrient["name"] as? String,
                unit = nutrient["unit"] as? String,
                value = nutrient["value"] as? String,
                floatVal = Float(value)
            {
                let item = NTNutrient(id: id, name: name, unit: unit, value: floatVal)
                if let codes = nutrientCodes {
                    if codes.contains(id) {
                        result.append(item)
                    }
                } else {
                    result.append(item)
                }
                
            }
        }
        return result
    }
    

}