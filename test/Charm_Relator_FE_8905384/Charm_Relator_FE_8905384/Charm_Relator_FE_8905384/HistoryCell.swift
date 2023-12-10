//
//  HistoryCell.swift
//  Charm_Relator_FE_8905384
//
//  Created by Charm Johannes Relator on 2023-12-05.
//

import UIKit


class HistoryCell: UITableViewCell {


    @IBOutlet weak var fromModuleOutlet: UILabel!
    @IBOutlet weak var cityNameOutlet: UILabel!
    @IBOutlet weak var interactionTypeButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func interactionType(_ sender: Any) {
    }
    
}
