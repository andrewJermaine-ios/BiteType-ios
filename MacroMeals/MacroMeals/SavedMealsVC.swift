//
//  SavedMealsVC.swift
//  MacroMeals
//
//  Created by Andrew on 1/9/24.
//

import UIKit

class SavedMealsVC: UIViewController,UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    let data = ["Mac" : "one cup mac n cheese", "Pizza": "one large pizza"]
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var titles = [String]()
        var details = [String]()
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "savedMealCell") as? SavedMealCell else { return UITableViewCell()}
        
        for key in data.keys {
            titles.append(key)
        }
        for value in data.values {
            details.append(value)
        }
        
        cell.configureSavedMealCell(title: titles[indexPath.row], detail: details[indexPath.row])
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
