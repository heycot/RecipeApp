//
//  EditController.swift
//  RecipeApp
//
//  Created by Callie on 4/8/20.
//  Copyright © 2020 Tu (Callie) T. NGUYEN. All rights reserved.
//

import UIKit
import PKHUD

class EditController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    var step = Step()
    var ingredient = Ingredient()
    var isStep = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isStep {
            textView.text = step.desc
        } else {
            textView.text = ingredient.desc
        }
    }

    @IBAction func saveActionDidTap(_ sender: UIBarButtonItem) {
        HUD.show(.progress)
        
        if isStep {
            RealmManager.updateStep(step, desc: textView.text, order: step.order) { (data) in
                if data {
                    _ = self.navigationController?.popViewController(animated: true)
                } else {
                    self.showErrorMessage()
                }
                HUD.hide()
            }
        } else {
            RealmManager.updateIngredient(ingredient, desc: textView.text) { (data) in
                if data {
                    _ = self.navigationController?.popViewController(animated: true)
                } else {
                    self.showErrorMessage()
                }
                HUD.hide()
            }
        }
    }
}
