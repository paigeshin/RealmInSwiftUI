//
//  Group.swift
//  RealmInSwiftUI
//
//  Created by paige shin on 2022/11/07.
//

import Foundation
import RealmSwift

final class Group: Object, ObjectKeyIdentifiable {
    
    @objc dynamic var _id = ObjectId.generate()
    @objc dynamic var name: String = "new"
    
    // backlink to group
    override class func primaryKey() -> String? {
        return "_id"
    }
    
    var items = RealmSwift.List<Item>()
    
}
