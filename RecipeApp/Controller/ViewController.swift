//
//  ViewController.swift
//  RecipeApp
//
//  Created by Callie on 4/8/20.
//  Copyright © 2020 Tu (Callie) T. NGUYEN. All rights reserved.
//

import UIKit
import PKHUD

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(UINib(nibName: "RecipeCell", bundle: nil), forCellReuseIdentifier: "RecipeCellID")
        }
    }
    
    var recipes = [[Recipe]]()
    var types = [RecipeType]()
    var sectionSelected = -1
    var indexSeleted = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Recipes"
        saveDataToRealm()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getData()
    }
    
    func saveDataToRealm() {
        HUD.show(.progress)
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            self.getData()
        } else {
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            RecipeManager.saveDataToRealm { [weak self] in
                self?.getData()
            }
        }
    }
    
    func setupView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = 70
    }
    
    func getData() {
        //remove all old data
        recipes.removeAll()
        HUD.show(.progress)
        types = RealmManager.getTypes()
        for type in types {
            let listRecipe = RealmManager.getRecipesByType(typeId: type.id)
            recipes.append(listRecipe)
        }
        
        tableView.reloadData()
        HUD.hide()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
        
       if segue.identifier == "goToRecipeDetail" {
            if let vc = segue.destination as? RecipeDetailController {
                vc.recipe = recipes[sectionSelected][indexSeleted]
            }
        }
    }
}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return types.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCellID", for: indexPath) as! RecipeCell
        
        cell.updateData(recipe: recipes[indexPath.section][indexPath.row])
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UITableViewHeaderFooterView()
        headerView.textLabel?.text = types[section].name
        return headerView
    }

    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
       return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sectionSelected = indexPath.section
        indexSeleted = indexPath.row
        performSegue(withIdentifier: "goToRecipeDetail", sender: nil)
    }
    
}

