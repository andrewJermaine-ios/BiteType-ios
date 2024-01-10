//
//  SavedMealCell.swift
//  MacroMeals
//
//  Created by Andrew on 1/9/24.
//

import UIKit

class SavedMealCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureSavedMealCell(title: String, detail: String) {
        titleLabel.text = title
        detailLabel.text = detail
    }
    
    

}
