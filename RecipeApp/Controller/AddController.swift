//
//  AddController.swift
//  RecipeApp
//
//  Created by Callie on 4/8/20.
//  Copyright © 2020 Tu (Callie) T. NGUYEN. All rights reserved.
//

import UIKit
import YPImagePicker
import PKHUD
import IQKeyboardManagerSwift

class AddController: UIViewController {
    
    @IBOutlet weak var thumnailImageView: UIImageView!
    @IBOutlet weak var uploadPhotoBtn: UIButton!
    @IBOutlet weak var recipeNameTF: UITextField!
    @IBOutlet weak var recipeTypeTF: UITextField!
    @IBOutlet weak var showSelectTypeTF: UITextField!
    
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    @IBOutlet weak var addIngredientBtn: UIButton!
    @IBOutlet weak var addStepBtn: UIButton!
    @IBOutlet weak var selectTypeBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(UINib(nibName: "StepIngredientCell", bundle: nil), forCellReuseIdentifier: "StepIngredientCellID")
        }
    }
    
    var recipeTypes = [RecipeType]()
    var recipe = Recipe()
    var steps = [Step]()
    var ingredients = [Ingredient]()
    var thumbnailImage : UIImage? = nil
    let typePicker = UIPickerView()
    let toolbar = UIToolbar();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //disable IQKeyboard on add screen
        IQKeyboardManager.shared.enable = false
        self.title = "Add New Recipe"
        recipeTypes = RealmManager.getTypes()
        setupTableView()
        setupToolBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        customUIButton()
    }
    
    @objc func cancelPicker(){
        self.view.endEditing(true)
    }
    
    func setupToolBar() {
        toolbar.sizeToFit()
        toolbar.barStyle = .default
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPicker));
        
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
    }
    
    @IBAction func selectTypeBtnDidTap(_ sender: Any) {
        print("select type did tap")
        //hide keyboard
        recipeTypeTF.endEditing(true)
        // add toolbar to textField
        showSelectTypeTF.inputAccessoryView = toolbar
        
        typePicker.delegate = self
        typePicker.dataSource = self
        //add type picker to keyboard
        showSelectTypeTF.inputView = typePicker
        //show keyboard
        showSelectTypeTF.becomeFirstResponder()
    }
    
    
    
    @objc func donePicker(){
        let row = typePicker.selectedRow(inComponent: 0)
        recipeTypeTF.text = recipeTypes[row].name
        recipe.typeId = recipeTypes[row].id
        self.view.endEditing(true)
    }
    
    @IBAction func saveBtnDidTap(_ sender: UIBarButtonItem) {
        //check data is not nil
        if recipeNameTF.text == "", recipeTypeTF.text == "", steps.count == 0, ingredients.count == 0 {
            showSimpleAlert(title: "Cannt save the recipe", message: "Please update all your content")
        } else {
            //check thumnail image
            if thumbnailImage == nil {
                notifyDefaultThumbnail()
            } else {
                saveRecipe()
            }
        }
    }
    
    func saveRecipe() {
        recipe.id = UUID().uuidString
        if thumbnailImage == nil {
            recipe.thumbnail = "default"
        } else {
            recipe.thumbnail = "photo\(recipe.id)"
            let success = self.saveImage(image: (self.thumbnailImage ?? UIImage(named: "default"))!, imageName: recipe.thumbnail ?? "")
            if !success {
                showErrorMessage()
            }
        }
        
        //new type is need to create
        if !recipeTypes.contains(where: { $0.name == recipeTypeTF.text }) {
            let type = RecipeType()
            type.id = UUID().uuidString
            type.name = recipeTypeTF.text
            recipe.typeId = type.id
            RealmManager.saveNewType(type)
        }
        
        recipe.name = recipeNameTF.text
        
        RealmManager.saveStepsOfNewRecipe(data: steps, recipeId: recipe.id)
        RealmManager.saveIngredientsOfNewRecipe(data: ingredients, recipeId: recipe.id)
        
        RealmManager.saveOneRecipe(recipe) {
            //back to previous controller after save data
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    func notifyDefaultThumbnail() {
        let alert = UIAlertController(title: "No image is uploaded", message: "Use the default image?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { _ in
            //Cancel Action
        }))
        alert.addAction(UIAlertAction(title: "Yes",  style: .default, handler: { _ in
            //save the recipe with default thumbnail image
            self.saveRecipe()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func uploadPhotoBtnDidTap(_ sender: Any) {
        let picker = YPImagePicker()
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {

                self.thumnailImageView.image = photo.image
                self.thumbnailImage = photo.image
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func addIngredientBtnDidTap(_ sender: Any) {
        insertIngredient()
    }
    
    @IBAction func addStepBtnDidTap(_ sender: Any) {
        insertStep()
    }
    
    func insertIngredient() {
        let alertController = UIAlertController(title: "Add new ingredient", message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Add", style: .default) { (_) in
            if let txtField = alertController.textFields?.first, let text = txtField.text {
                if text == "" {
                    txtField.layer.borderColor = UIColor.red.cgColor
                } else {
                    let ingredient = Ingredient()
                    ingredient.id = UUID().uuidString
                    ingredient.desc = text
                    self.ingredients.append(ingredient)
                    //reload to show ingredient data
                    self.tableView.reloadSections(IndexSet([0]), with: .none)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        alertController.addTextField { (textField) in
            textField.placeholder = "description"
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func insertStep() {
        let alertController = UIAlertController(title: "Add new step", message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Add", style: .default) { (_) in
            if let txtField = alertController.textFields?.first, let text = txtField.text {
                if text == "" {
                    txtField.layer.borderColor = UIColor.red.cgColor
                } else {
                    let step = Step()
                    step.id = UUID().uuidString
                    step.desc = text
                    step.order = self.steps.count + 1
                    self.steps.append(step)
                    //reload to show step data
                    self.tableView.reloadSections(IndexSet([1]), with: .none)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        alertController.addTextField { (textField) in
            textField.placeholder = "description"
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func customUIButton() {
        addIngredientBtn.layer.borderWidth = 1
        //link color only available on iOS 13 or later
        addIngredientBtn.layer.borderColor = UIColor.link.cgColor
//        addIngredientBtn.layer.borderColor = UIColor(red: 0, green: 118, blue: 255, alpha: 1).cgColor
        addIngredientBtn.layer.cornerRadius = 10
        addIngredientBtn.layer.masksToBounds = true
        
        addStepBtn.layer.cornerRadius = 10
        addStepBtn.layer.masksToBounds = true
        
        uploadPhotoBtn.layer.cornerRadius = 10
        uploadPhotoBtn.layer.masksToBounds = true
        
        selectTypeBtn.layer.cornerRadius = 10
        selectTypeBtn.layer.masksToBounds = true
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
}

extension AddController : UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return recipeTypes.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return recipeTypes[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        recipeTypeTF.text = recipeTypes[row].name
        recipe.typeId = recipeTypes[row].id
    }
}


extension AddController : UITableViewDelegate, UITableViewDataSource {
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

