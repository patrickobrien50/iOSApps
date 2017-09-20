//
//  CustomCollectioViewCellDelegate.swift
//  SpeedrunAPITEsts
//
//  Created by Patrick O'Brien on 9/4/17.
//  Copyright © 2017 Patrick O'Brien. All rights reserved.
//

import Foundation
import UIKit

protocol CustomCollectionViewCellDelegate: class {
    func didSelectButtonAtIndexPathOfCell(sender: CustomCollectionViewCell)
}
