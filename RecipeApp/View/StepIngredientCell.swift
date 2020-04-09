//
//  StepCell.swift
//  RecipeApp
//
//  Created by Callie on 4/8/20.
//  Copyright © 2020 Tu (Callie) T. NGUYEN. All rights reserved.
//

import UIKit

class StepIngredientCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var orderLB: UILabel!
    @IBOutlet weak var descLB: UILabel!
    
    func updateViewByStep(_ step: Step, order: Int) {
        orderLB.text = "\(order)"
        descLB.text = step.desc
        borderOrderLB()
    }
    
    func updateViewByIngredient(_ ingredient: Ingredient, order: Int) {
        orderLB.text = "\(order)"
        descLB.text = ingredient.desc
        borderOrderLB()
    }
    
    func borderOrderLB() {
        orderLB.backgroundColor = .systemRed
        orderLB.layer.cornerRadius = 10
        orderLB.layer.masksToBounds = true
        orderLB.textColor = .white
    }
}
