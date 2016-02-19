//
//  CollisionCategoryBitmask.swift
//  Worm
//
//  Created by Piotr Pawluś on 19/02/16.
//  Copyright © 2016 Piotr Pawluś. All rights reserved.
//

import UIKit

struct CollisionCategoryBitmask {
    static let Nil: UInt32 = 0x00
    static let Worm: UInt32 = 0x01
    static let Wall: UInt32 = 0x02
    static let Point: UInt32 = 0x03
}
