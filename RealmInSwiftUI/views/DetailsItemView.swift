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
