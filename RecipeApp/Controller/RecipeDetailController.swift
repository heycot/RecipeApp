//
//  RecipeDetailController.swift
//  RecipeApp
//
//  Created by Callie on 4/8/20.
//  Copyright © 2020 Tu (Callie) T. NGUYEN. All rights reserved.
//

import UIKit
import YPImagePicker

class RecipeDetailController: UIViewController {

    @IBOutlet weak var uploadPhotoBtn: UIButton!
    @IBOutlet weak var bodyView: UIView!
    @IBOutlet weak var recipeThumbImageView: UIImageView!
    let imageTapRec = UITapGestureRecognizer()
    
    @IBOutlet weak var tableView: UITableView! {
           didSet {
               tableView.register(UINib(nibName: "StepIngredientCell", bundle: nil), forCellReuseIdentifier: "StepIngredientCellID")
           }
       }
    
    var recipe = Recipe()
    var steps = [Step]()
    var ingredients = [Ingredient]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showRecipeData()
        uploadPhotoBtn.isHidden = true
        
        imageTapRec.addTarget(self, action: #selector(tappedView))
        recipeThumbImageView.addGestureRecognizer(imageTapRec)
        recipeThumbImageView.isUserInteractionEnabled = true
    }
    
    @objc func tappedView() {
        uploadPhotoBtn.layer.cornerRadius = 10
        uploadPhotoBtn.layer.masksToBounds = true
        uploadPhotoBtn.isHidden = !uploadPhotoBtn.isHidden
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //reload data after user edited
        getNewestDataFromLocal()
        tableView.reloadData()
    }
    
    func showRecipeData() {
        //get image from local
        if let image = getSavedImage(named: recipe.thumbnail ?? "") {
            recipeThumbImageView.image = image
        } else {
            recipeThumbImageView.image = UIImage(named: recipe.thumbnail ?? "recipe1")
        }
        self.title = recipe.name
    }
    
    func getNewestDataFromLocal() {
        if let data = RealmManager.getRecipeById(recipe.id) {
            recipe = data
        }
        steps = RealmManager.getStepsByRecipeId(recipe.id)
        steps.sort { $0.order < $1.order }
        ingredients = RealmManager.getIngredientByRecipeId(recipe.id)
        setupTableView()
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = 50
    }
    
    func deleteData(section: Int, row: Int) {
        var id = ""
        var isStep = false
    
        if section == 0 {
            id = ingredients[row].id
            isStep = false
        } else {
            id = steps[row].id
            isStep = true
        }
        
        //delete the data on realm
        RealmManager.delStepIngredientByID(id, isStep: isStep) { (data) in
            if data {
                if isStep {
                    self.steps.remove(at: row)
                } else {
                    self.ingredients.remove(at: row)
                }
                //remove tableViewCell
                let indexPath = IndexPath(item: row, section: section)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            } else {
                self.showErrorMessage()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
        
        if segue.identifier == "goToEdit" {
            if let vc = segue.destination as? EditController {
                if let indexPath = sender as? IndexPath {
                    if indexPath.section == 0 {
                        vc.ingredient = ingredients[indexPath.row]
                        vc.isStep = false
                    } else {
                        vc.step = steps[indexPath.row]
                        vc.isStep = true
                    }
                } else {
                    self.showErrorMessage()
                }
                vc.title = self.title
            } else {
                self.showErrorMessage()
            }
        } else {
            self.showErrorMessage()
        }
    }
    
}

//handle thumnail image
extension RecipeDetailController {
    @IBAction func uploadPhotoBtnDidTap(_ sender: Any) {
        let picker = YPImagePicker()
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                let photoName = "photo\(self.recipe.id)"
                
                //save image to local
                let success = self.saveImage(image: photo.image, imageName: photoName)
                if success {
                    //save new thumbnail name to realm
                    RealmManager.updateRecipeThumnail(self.recipe, thumnailName: photoName) { (data) in
                        if data {
                            self.recipeThumbImageView.image = photo.image
                        } else {
                            self.showErrorMessage()
                        }
                    }
                } else {
                    self.showErrorMessage()
                }
            }
            picker.dismiss(animated: true, completion: nil)
            self.uploadPhotoBtn.isHidden = true
        }
        present(picker, animated: true, completion: nil)
    }
}

extension RecipeDetailController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        //firstly: ingredients
        //secondly: steps
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? ingredients.count : steps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //ingredients table view
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StepIngredientCellID", for: indexPath) as! StepIngredientCell
            cell.updateViewByIngredient(ingredients[indexPath.row], order: indexPath.row + 1)
            return cell
        }
        
        //steps table view
        let cell = tableView.dequeueReusableCell(withIdentifier: "StepIngredientCellID", for: indexPath) as! StepIngredientCell
        cell.updateViewByStep(steps[indexPath.row], order: indexPath.row + 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UITableViewHeaderFooterView()
        
        if section == 0 {
            headerView.textLabel?.text = "Ingredients"
        } else {
            headerView.textLabel?.text = "Steps"
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var desc = ""
        if indexPath.section == 0 {
            desc = ingredients[indexPath.row].desc ?? ""
        } else {
            desc = steps[indexPath.row].desc ?? ""
        }
        let width = UIScreen.main.bounds.width - 50
        let height = desc.height(withConstrainedWidth: width, font: UIFont.systemFont(ofSize: 17)) + 20
        return height > 50 ? height : 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
       return 30
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let edit = UIContextualAction(style: .normal, title: "Edit") { _,_,_ in
            self.performSegue(withIdentifier: "goToEdit", sender: indexPath)
        }
        edit.backgroundColor = .blue
        
        let del = UIContextualAction(style: .destructive, title: "Delete") { _,_,_ in
            self.deleteData(section: indexPath.section, row: indexPath.row)
        }
        del.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [del, edit])
    }
    
    
}
