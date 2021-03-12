//
//  MoreOptionsCellModel.swift
//  diskdemo
//
//  Created by macliu on 2021/3/11.
//

import Foundation
import UIKit


struct MoreOptionsCellModel {
    let title: String
    let description: String
    var icon: UIImage?
    let cellTappedMethod: () -> Void
    
}
