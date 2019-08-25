//
//  Category.swift
//  ToDoList
//
//  Created by Regan Walsh on 16/11/2018.
//  Copyright © 2018 Regan Walsh. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var colour: String = ""
    let items = List<Item>()
}
