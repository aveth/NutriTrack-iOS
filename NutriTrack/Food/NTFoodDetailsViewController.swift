//
//  NTFoodDetailsViewController.swift
//  NutriTrack
//
//  Created by Avais on 2016-04-20.
//  Copyright © 2016 Aveth. All rights reserved.
//

import UIKit

protocol NTFoodDetailsViewControllerDelegate: class {
    func foodDetailsViewController(sender: NTFoodDetailsViewController, didConfirmFood food:NTFood, quantity: Int, measureIndex: Int)
}

class NTFoodDetailsViewController: NTViewController, NTFoodDetailsViewDelegate, NTFoodDetailsViewDataSource {
    
    private var _completeText: String = NSLocalizedString("Done", comment: "")
    internal var completeText: String? {
        get {
            return self._completeText
        }
        set {
            if let text = newValue {
                self._completeText = text
                self.navigationItem.rightBarButtonItem?.title = text
            }
        }
    }
    
    weak internal var delegate: NTFoodDetailsViewControllerDelegate?
    internal var food: NTFood
    internal var measureIndex: Int
    internal var quantity: Int
    
    private let quantities: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9]
    private let searchProvider: NTSearchProvider = NTSearchProvider(service: NTSearchService())
    
    private lazy var foodDetailsView: NTFoodDetailsView = {
        let view: NTFoodDetailsView = NTFoodDetailsView()
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    private lazy var spinner: NTLoadingIndicator = {
        let spinner = NTLoadingIndicator()
        return spinner
    }()
    
    internal init(food: NTFood, quantity: Int, measureIndex: Int) {
        self.food = food
        self.quantity = 1
        self.measureIndex = 0
        super.init(nibName: nil, bundle: nil)
    }
    
    internal convenience init(food: NTFood) {
        self.init(food: food, quantity: 1, measureIndex: 0)
    }
    
    required internal init?(coder aDecoder: NSCoder) {
        fatalError("This class doesn't support NSCoding.")
    }
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationTitle = NSLocalizedString("Food Details", comment: "")
        self.rightBarButtonTitle = self._completeText
        
        self.view.addSubview(self.foodDetailsView)
        self.view.addSubview(self.spinner)

        self.reloadData()
        self.updateViewConstraints()
        
    }
    
    override internal func rightBarButtonDidTap(sender: UIBarButtonItem) {
         self.delegate?.foodDetailsViewController(self, didConfirmFood: self.food, quantity: self.quantity, measureIndex: self.measureIndex)
    }
    
    override internal func updateViewConstraints() {
        super.updateViewConstraints()
        self.spinner.autoPinEdgesToSuperviewEdges()
        self.foodDetailsView.autoPinEdgesToSuperviewEdges()
    }
    
    private func reloadData() {
        if let foodId: String = food.id {
            self.navigationItem.rightBarButtonItem?.enabled = false
            self.spinner.activate()
            self.searchProvider.fetchFoodDetails(foodId, diet: NTSearchProvider.Diet.Renal,
                success: { (result: NTFood) -> Void in
                    self.food = result
                    self.foodDetailsView.reloadData()
                    self.navigationItem.rightBarButtonItem?.enabled = true
                    self.spinner.deactivte()
                },
                failure: { (error: ErrorType) -> Void in
                    self.navigationItem.rightBarButtonItem?.enabled = true
                    self.spinner.deactivte()
                }
            )
        }
    }
    
    // MARK: NTFoodDetailsViewDataSource methods
    
    internal func foodDetailsViewTitleForFood(sender: NTFoodDetailsView) -> String {
        return self.food.name + " (" + self.food.id + ")"
    }
    
    internal func foodDetailsViewNumberOfMeasures(sender: NTFoodDetailsView) -> Int {
        return self.food.measures.count
    }
    
    internal func foodDetailsView(sender: NTFoodDetailsView, titleForMeasureAtIndex index: Int) -> String {
        return self.food.measures[index].name
    }
    
    internal func foodDetailsView(sender: NTFoodDetailsView, valueForMeasureAtIndex index: Int) -> Float {
        return self.food.measures[index].value
    }
    
    internal func foodDetailsViewNumberOfNutrients(sender: NTFoodDetailsView) -> Int {
        return self.food.nutrients.count
    }
    
    internal func foodDetailsView(sender: NTFoodDetailsView, titleForNutrientAtIndex index: Int) -> String {
        return self.food.nutrients[index].name
    }
    
    internal func foodDetailsView(sender: NTFoodDetailsView, unitForNutrientAtIndex index: Int) -> String {
        return self.food.nutrients[index].unit
    }
    
    internal func foodDetailsView(sender: NTFoodDetailsView, valueForNutrientAtIndex index: Int) -> Float {
        let nutrientValue = self.food.nutrients[index].value
        let measureValue = self.food.measures[self.measureIndex].value
        let quantityValue = self.quantity
        let adjustedNutrientValue = (nutrientValue / NTNutrient.BaseMeasuresGrams) * measureValue * Float(quantityValue)
        return adjustedNutrientValue
    }
    
    internal func foodDetailsViewNumberOfQuantities(sender: NTFoodDetailsView) -> Int {
        return self.quantities.count
    }
    
    internal func foodDetailsView(sender: NTFoodDetailsView, valueForQuantityAtIndex index: Int) -> Int {
        return self.quantities[index]
    }
    
    internal func foodDetailsViewIndexForSelectedMeasure(sender: NTFoodDetailsView) -> Int {
        return self.measureIndex
    }
    
    internal func foodDetailsViewIndexForSelectedQuantity(sender: NTFoodDetailsView) -> Int {
        if let num = self.quantities.indexOf(self.quantity) {
            return num
        }
        return 0
    }
    
    // MARK: NTFoodDetailsViewDelegate methods
    
    internal func foodDetailsView(sender: NTFoodDetailsView, didSelectMeasureAtIndex index: Int) {
        self.measureIndex = index
    }
    
    internal func foodDetailsView(sender: NTFoodDetailsView, didSelectQuantityAtIndex index: Int) {
        self.quantity = self.quantities[index]
    }
    
    
}