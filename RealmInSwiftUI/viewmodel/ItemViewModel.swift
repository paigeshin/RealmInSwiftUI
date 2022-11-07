//
//  ItemViewModel.swift
//  RealmInSwiftUI
//
//  Created by paige shin on 2022/11/08.
//

import Foundation
import RealmSwift
import Combine

class ItemsViewModel: ObservableObject {
    
    @Published var items = List<Item>()
//    {
//        willSet {
//            objectWillChange.send()
//        }
//    }
    @Published var selectedGroup: Group? = nil
    
    var token: NotificationToken?
    var realm: Realm?
    
    init() {
        
        let realm = try? Realm()
        self.realm = realm
        
        if let group = realm?.objects(Group.self).first {
            self.selectedGroup = group
            self.items = group.items
        } else {
            try? realm?.write {
                let group = Group()
                realm?.add(group)
                group.items.append(Item())
                group.items.append(Item())
                group.items.append(Item())
            }
        }
        
        /// List Items
//        token = selectedGroup?.observe({ [weak self] changes in
//            switch changes {
//            case .error(_): break
//            case .change(_, _): self?.objectWillChange.send()
//            case .deleted: self?.selectedGroup = nil
//            }
//        })
  
        token = selectedGroup?.items.observe({ changes in
            switch changes {
            case .error(_): break
            case .initial(_): break
            case .update(_, deletions: _, insertions: _, modifications: _):
                self.objectWillChange.send()
            }
        })
        
        /// Publisher
//        selectedGroup?.publisher(for: \.name).sink(receiveValue: { name in
//
//        })
        
    }
    
    func addNewItem() {
        if let realm = selectedGroup?.realm {
            try? realm.write {
                selectedGroup?.items.append(Item())
            }
        }
    }
    
    func delete(at indexSet: IndexSet) {
        if let index = indexSet.first,
           let realm = items[index].realm {
            try? realm.write {
                realm.delete(items[index])
            }
        }
            
        
    }
    
}
