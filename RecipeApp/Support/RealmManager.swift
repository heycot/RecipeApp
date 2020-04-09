//
//  RealmManager.swift
//  RecipeApp
//
//  Created by Callie on 4/8/20.
//  Copyright © 2020 Tu (Callie) T. NGUYEN. All rights reserved.
//

import Foundation
import RealmSwift

class RealmManager {
    
    static func saveData(recipes: [Recipe], types: [RecipeType], completion: @escaping () -> Void) {
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(recipes, update: .modified)
            realm.add(types, update: .modified)
            completion()
        }
    }
    
    static func saveNewType(_ type: RecipeType) {
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(type, update: .modified)
        }
    }
    
    static func saveRecipes(data: [Recipe], completion: @escaping () -> Void) {
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(data, update: .modified)
            completion()
        }
    }
    
    static func saveOneRecipe(_ data: Recipe, completion: @escaping () -> Void) {
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(data, update: .modified)
            completion()
        }
    }
    
    static func updateRecipeThumnail(_ recipe: Recipe, thumnailName: String, completion: @escaping (Bool) -> Void) {
        let realm = try! Realm()
        if let recipe = realm.objects(Recipe.self).filter("id = %@", recipe.id).first {
            try! realm.write {
                recipe.thumbnail = thumnailName
                realm.add(recipe, update: .modified)
                completion(true)
            }
        } else {
            completion(false)
        }
    }
    
    static func saveTypes(data: [RecipeType], completion: @escaping () -> Void) {
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(data, update: .modified)
            completion()
        }
    }
    
    
    static func saveSteps(data: [Step], completion: @escaping () -> Void) {
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(data, update: .modified)
            completion()
        }
    }
    
    static func saveStepsOfNewRecipe(data: [Step], recipeId: String) {
        let realm = try! Realm()
        
        for step in data {
            step.recipeId = recipeId
        }
        
        try! realm.write {
            realm.add(data, update: .modified)
        }
    }
    
    static func updateStep(_ data: Step, desc: String, order: Int, completion: @escaping (Bool) -> Void) {
        let realm = try! Realm()
        if let step = realm.objects(Step.self).filter("id = %@", data.id).first {
            try! realm.write {
                step.desc = desc
                step.order = order
                realm.add(step, update: .modified)
                completion(true)
            }
        } else {
            completion(false)
        }
    }
    
    static func saveIngredients(data: [Ingredient], completion: @escaping () -> Void) {
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(data, update: .modified)
            completion()
        }
    }
    
    static func saveIngredientsOfNewRecipe(data: [Ingredient], recipeId: String) {
        let realm = try! Realm()
        
        for item in data {
            item.recipeId = recipeId
        }
        
        try! realm.write {
            realm.add(data, update: .modified)
        }
    }
    
    static func updateIngredient(_ data: Ingredient, desc: String, completion: @escaping (Bool) -> Void) {
        let realm = try! Realm()
        if let ingredient = realm.objects(Ingredient.self).filter("id = %@", data.id).first {
            try! realm.write {
                ingredient.desc = desc
                realm.add(ingredient, update: .modified)
                completion(true)
            }
        } else {
            completion(false)
        }
    }
    
    static func delStepIngredientByID(_ id: String, isStep: Bool, completion: @escaping (Bool) -> Void) {
        let realm = try! Realm()
        
        if isStep {
            if let step = realm.objects(Step.self).filter("id = %@", id).first {
                try! realm.write {
                    realm.delete(step)
                    completion(true)
                }
            } else {
                completion(false)
            }
        } else {
            if let ingredient = realm.objects(Ingredient.self).filter("id = %@", id).first {
                try! realm.write {
                    realm.delete(ingredient)
                    completion(true)
                }
            } else {
                completion(false)
            }
        }
    }
    
    static func getRecipes() -> [Recipe] {
        let realm = try! Realm()
        return realm.objects(Recipe.self).toArray(type: Recipe.self)
    }
    
    static func getRecipeById(_ id: String) -> Recipe? {
        let realm = try! Realm()
        return realm.objects(Recipe.self).filter("id = %@", id).first
    }
    
    static func getRecipesByType(typeId: String) -> [Recipe] {
        let realm = try! Realm()
        return realm.objects(Recipe.self).filter("typeId = %@", typeId).toArray(type: Recipe.self)
    }
    
    static func getSteps() -> [Step] {
        let realm = try! Realm()
        return realm.objects(Step.self).toArray(type: Step.self)
    }
    
    static func getStepsByRecipeId(_ id: String) -> [Step] {
        let realm = try! Realm()
        return realm.objects(Step.self).filter("recipeId = %@", id).toArray(type: Step.self)
    }
    
    static func getIngredients() -> [Ingredient] {
        let realm = try! Realm()
        return realm.objects(Ingredient.self).toArray(type: Ingredient.self)
    }
    
    static func getIngredientByRecipeId(_ id: String) -> [Ingredient] {
        let realm = try! Realm()
        return realm.objects(Ingredient.self).filter("recipeId = %@", id).toArray(type: Ingredient.self)
    }
    
    static func getTypes() -> [RecipeType] {
        let realm = try! Realm()
        return realm.objects(RecipeType.self).toArray(type: RecipeType.self)
    }
    
}

extension List {
    func toArray<T>(type: T.Type) -> [T] {
        return compactMap { $0 as? T }
    }
}

extension Results {
    func toArray<T>(type: T.Type) -> [T] {
        return compactMap { $0 as? T }
    }
}
