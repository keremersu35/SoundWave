//
//  UICollectionView+UINib.swift
//  
//
//  Created by Kerem Ersu on 1.06.2023.
//

import Foundation

import Foundation
import UIKit

extension UICollectionViewCell {
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
}
