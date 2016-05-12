//
//  Food.swift
//  NutriTrack
//
//  Created by Avais on 2016-04-27.
//  Copyright © 2016 Aveth. All rights reserved.
//

import Foundation

class Food {
    
    lazy private(set) var sortedNutrients: [Nutrient] = {
        return self.nutrients.sort({ (nutrient1, nutrient2) -> Bool in
            if nutrient1.name.compare(nutrient2.name) == .OrderedAscending {
                return true
            }
            return false
        })
    }()
    
    internal var id: String
    internal var name: String
    internal var nutrients: [Nutrient]
    internal var measures: [Measure]
    
    internal init(id: String, name: String) {
        self.id = id
        self.name = name
        self.nutrients = [Nutrient]()
        self.measures = [Measure]()
    }

}