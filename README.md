[https://www.youtube.com/watch?v=MP03SfD63Hs&t=2117s](https://www.youtube.com/watch?v=MP03SfD63Hs&t=2117s)

[https://github.com/realm/realm-swift](https://github.com/realm/realm-swift)

### ItemListView

```swift
//
//  ItemListView.swift
//  RealmInSwiftUI
//
//  Created by paige shin on 2022/11/08.
//

import SwiftUI
import RealmSwift

struct ItemListView: View {
    
    @StateObject var itemViewModel = ItemsViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(itemViewModel.items.freeze()) { item in
                    NavigationLink(
                        destination: DetailsItemView(item: itemViewModel.realm!.resolve(ThreadSafeReference(to: item))!),
                        label: {
                            HStack {
                                Text(item.name)
                                if item.isFavorite {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.pink)
                                } else {
                                    
                                }
                            }
                        }
                    )
                    
                }
                .onDelete { indexSet in
                    itemViewModel.delete(at: indexSet)
                }
            }
            .navigationTitle("Items")
            .navigationBarItems(trailing:
                Button {
                    itemViewModel.addNewItem()
                } label: {
                    Image(systemName: "plus")
                }
            )

        }

    }
}

struct ItemListView_Previews: PreviewProvider {
    static var previews: some View {
        ItemListView()
    }
}
```

- Free Objects

```swift
ForEach(itemViewModel.items.freeze()) { item in
```

- How to make Thread SafetyObject

```swift
DetailsItemView(item: itemViewModel.realm!.resolve(ThreadSafeReference(to: item))!)
```

### DetailsItemView

```swift
//
//  DetailsItemView.swift
//  RealmInSwiftUI
//
//  Created by paige shin on 2022/11/08.
//

import SwiftUI

struct DetailsItemView: View {
    
    let item: Item
    @State private var name: String = ""
    @Environment(\.presentationMode) var presentation
    private var isFavorite: Binding<Bool> {
        Binding<Bool>(
            get: {
                item.isFavorite
            },
            set: { value in
                item.update(isFavorite: value)
            })
    }
    
    var body: some View {
        VStack {
            Text("Edit Item Name")
            
            TextField("edit", text: $name)
                .textFieldStyle(.roundedBorder)
            
            Toggle(isOn: isFavorite, label: {
                Text("Select as favorite")
            })
            
            Button {
                item.update(name: name)
                presentation.wrappedValue.dismiss()
            } label: {
                Text("save")
            }
        }
        .padding()
        .onAppear {
            name = item.name
        }
        /// Publisher
        .onReceive(item.publisher(for: \.isFavorite), perform: { newValue in
            print("update: \(newValue)")
        })
    }
}

struct DetailsItemView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsItemView(item: Item())
    }
}
```

- Using realm publisher

```swift
.onReceive(item.publisher(for: \.isFavorite), perform: { newValue in
      print("update: \(newValue)")
  })
```

- Use binding with realm

```swift
private var isFavorite: Binding<Bool> {
    Binding<Bool>(
        get: {
            item.isFavorite
        },
        set: { value in
            item.update(isFavorite: value)
        })
}
```

### ItemViewModel

```swift
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
```

- Get realm data changes

```swift
        /// Observe RealmObject 
        token = selectedGroup?.observe({ [weak self] changes in
            switch changes {
            case .error(_): break
            case .change(_, _): self?.objectWillChange.send()
            case .deleted: self?.selectedGroup = nil
            }
        })
        
        /// Observe Realm List Items 
        token = selectedGroup?.items.observe({ changes in
            switch changes {
            case .error(_): break
            case .initial(_): break
            case .update(_, deletions: _, insertions: _, modifications: _):
                self.objectWillChange.send()
            }
        })
        
        /// Publisher
        selectedGroup?.publisher(for: \.name).sink(receiveValue: { name in

        })
```
