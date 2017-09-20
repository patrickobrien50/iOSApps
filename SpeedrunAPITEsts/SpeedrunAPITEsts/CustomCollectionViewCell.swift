//
//  CustomCollectionViewCell.swift
//  SpeedrunAPITEsts
//
//  Created by Patrick O'Brien on 9/2/17.
//  Copyright © 2017 Patrick O'Brien. All rights reserved.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    var cellDelegate: CustomCollectionViewCellDelegate?
    
    
    @IBOutlet weak var deleteGameButton: UIButton!
    @IBAction func deleteGameButtonPressed(_ sender: UIButton) {
        cellDelegate?.didSelectButtonAtIndexPathOfCell(sender: self)
        print("Pressed the button")
    }
    @IBOutlet weak var gameNameLabel: UILabel!
    @IBOutlet weak var gameImageView: UIImageView!
}
