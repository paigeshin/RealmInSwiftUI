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
