//
//  EditView.swift
//  BucketList
//
//  Created by Ricardo on 09/05/24.
//

import SwiftUI



struct EditView: View {
    
    @Environment(\.dismiss) var dismiss
    
    
    @State private var viewModel: ViewModel
    
    var onSave: (Location) -> Void // this poperty ask for a function that accepts a single location and returns nothing, whe want to pass back wathever new location we want
    
    
    var body: some View {
        NavigationStack{
            Form {
                Section{
                    TextField("Place Name", text: $viewModel.name)
                }
                Section("Description"){
                    TextField("Description", text: $viewModel.description)
                    Toggle("Favorite", isOn: $viewModel.isFavorite)
                }
                Section("Nearby…") {
                    switch viewModel.loadingState {
                    case .loaded:
                        ForEach(viewModel.pages, id: \.pageid) { page in
                            Text(page.title)
                                .font(.headline)
                            + Text(": ") +
                            Text(page.description)
                                .italic()
                        }
                    case .loading:
                        Text("Loading…")
                    case .failed:
                        Text("Please try again later.")
                    }
                }
            }
            .navigationTitle("Place details")
            .toolbar {
                Button("Save"){
                    // we copy the location
                    let newLocation = viewModel.save()
                    onSave(newLocation)
                    dismiss()
                }
            }
            .task { // as soon as the view appears it loads nearby places
                await viewModel.fetchNearbyPlaces()
            }
        }
    }
    
    
    
    init(location: Location, onSave: @escaping (Location) -> Void) {
        self.onSave = onSave
        _viewModel = State(initialValue: ViewModel(location: location))
        }
}

#Preview {
    // our preview use loads the example
    EditView(location: .example, onSave: { _ in })// because the function we are using to store the new location
}
