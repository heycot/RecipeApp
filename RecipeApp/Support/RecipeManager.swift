//
//  RecipeManager.swift
//  RecipeApp
//
//  Created by Callie on 4/8/20.
//  Copyright © 2020 Tu (Callie) T. NGUYEN. All rights reserved.
//

import Foundation
import SwiftyXMLParser

class RecipeManager  {
    
    static func saveDataToRealm(completion: @escaping () -> Void)  {
        let recipes = RecipeManager.readListRecipe()
        let steps = RecipeManager.readListStep()
        let ingredients = RecipeManager.readListIngredient()
        let types = RecipeManager.readListRecipeType()
        
        for item in recipes {
            //get list steps of recipe and save
            let listStep = steps.filter({ $0.recipeId == item.id })
            item.steps.append(objectsIn: listStep)
                        
            //get list ingredients of recipe and save
            let listIngredient = ingredients.filter({ $0.recipeId == item.id })
            item.ingredients.append(objectsIn: listIngredient)
        }
        
        RealmManager.saveData(recipes: recipes, types: types) {
            completion()
        }
    }
    

    static func readListRecipe() -> [Recipe] {
        var recipes = [Recipe]()
        
        if let filepath = Bundle.main.path(forResource: "recipes", ofType: "xml") {
            do {
                
                let contents = try String(contentsOfFile: filepath)
                // parse xml document
                let xml = try! XML.parse(contents)
                
                
                // enumerate child Elements in the parent Element
                for data in xml["data", "recipes", "recipe"] {
                    let recipe = Recipe()
                    
                    recipe.id = data.attributes["id"] ?? ""
                    recipe.name = data.attributes["name"]
                    recipe.desc = data.attributes["desc"]
                    recipe.thumbnail = data.attributes["thumbnail"]
                    recipe.typeId = data.attributes["typeId"] ?? ""
                    
                    recipes.append(recipe)
                }
                
                return recipes
                
            } catch {
                // contents could not be loaded
                print("Error: contents could not be loaded")
                return recipes
            }
        } else {
            return recipes
        }
    }
    
    static func readListIngredient() -> [Ingredient] {
        var results = [Ingredient]()
        
        if let filepath = Bundle.main.path(forResource: "recipes", ofType: "xml") {
            do {
                
                let contents = try String(contentsOfFile: filepath)
                // parse xml document
                let xml = try! XML.parse(contents)
                
                
                // enumerate child Elements in the parent Element
                for data in xml["data", "ingredients", "ingredient"] {
                    let obj = Ingredient()
                    
                    obj.id = data.attributes["id"] ?? ""
                    obj.recipeId = data.attributes["recipeId"] ?? ""
                    obj.desc = data.attributes["desc"]
                    
                    results.append(obj)
                }
                
                return results
                
            } catch {
                // contents could not be loaded
                print("Error: contents could not be loaded")
                return results
            }
        } else {
            return results
        }
    }
    
    static func readListRecipeType() -> [RecipeType] {
        var results = [RecipeType]()
        
        if let filepath = Bundle.main.path(forResource: "recipes", ofType: "xml") {
            do {
                
                let contents = try String(contentsOfFile: filepath)
                // parse xml document
                let xml = try! XML.parse(contents)
                
                
                // enumerate child Elements in the parent Element
                for data in xml["data", "types", "type"] {
                    let obj = RecipeType()
                    
                    obj.id = data.attributes["id"] ?? ""
                    obj.name = data.attributes["name"]
                    obj.desc = data.attributes["desc"]
                    
                    results.append(obj)
                }
                
                return results
                
            } catch {
                // contents could not be loaded
                print("Error: contents could not be loaded")
                return results
            }
        } else {
            return results
        }
    }
    
    static func readListStep() -> [Step] {
        var results = [Step]()
        
        if let filepath = Bundle.main.path(forResource: "recipes", ofType: "xml") {
            do {
                
                let contents = try String(contentsOfFile: filepath)
                // parse xml document
                let xml = try! XML.parse(contents)
                                
                // enumerate child Elements in the parent Element
                for data in xml["data", "steps", "step"] {
                    let obj = Step()
                    
                    obj.id = data.attributes["id"] ?? ""
                    obj.recipeId = data.attributes["recipeId"] ?? ""
                    obj.desc = data.attributes["desc"]
                    
                    if let orderStr = data.attributes["order"] {
                        if let order = Int(orderStr) {
                            obj.order = order
                        }
                    }
                    
                    results.append(obj)
                }
                
                return results
                
            } catch {
                // contents could not be loaded
                print("Error: contents could not be loaded")
                return results
            }
        } else {
            return results
        }
    }
    
}
