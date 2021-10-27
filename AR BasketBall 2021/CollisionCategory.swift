//
//  CollisionCategory.swift
//  AR BasketBall 2021
//
//  Created by Наталья Шарапова on 26.10.2021.
//

import Foundation

struct CollisionCategory: OptionSet {
    let rawValue: Int
    
    static let ball = CollisionCategory(rawValue: 1 << 0)
    static let point = CollisionCategory(rawValue: 1 << 1)
    static let hoop = CollisionCategory(rawValue: 1 << 2)
    static let floor = CollisionCategory(rawValue: 1 << 3)
 
    }



