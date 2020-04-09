//
//  RecipeCell.swift
//  RecipeApp
//
//  Created by Callie on 4/8/20.
//  Copyright © 2020 Tu (Callie) T. NGUYEN. All rights reserved.
//

import UIKit

class RecipeCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var nameLB: UILabel!
    
    func updateData(recipe: Recipe) {
        nameLB.text = recipe.name
        
        //get image from local
        if let image = getSavedImage(named: recipe.thumbnail ?? "") {
            thumbnailImageView.image = image
        } else {
            thumbnailImageView.image = UIImage(named: recipe.thumbnail ?? "recipe1")
        }
    }
    
    func getSavedImage(named: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
        }
        return nil
    }
}
