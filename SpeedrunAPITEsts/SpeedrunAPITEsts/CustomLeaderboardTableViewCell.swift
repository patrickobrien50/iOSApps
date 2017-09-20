//
//  CustomLeaderboardTableViewCell.swift
//  SpeedrunAPITEsts
//
//  Created by Patrick O'Brien on 9/12/17.
//  Copyright © 2017 Patrick O'Brien. All rights reserved.
//

import UIKit

class CustomLeaderboardTableViewCell: UITableViewCell {

    @IBOutlet weak var trophyImageView: UIImageView!
    @IBOutlet weak var runPlaceLabel: UILabel!
    @IBOutlet weak var runnerNameLabel: UILabel!
    @IBOutlet weak var runTimeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
