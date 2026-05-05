//
//  CategoriesView.swift
//  Portal_mabe
//
//  Created by Máximo Magallanes Urtuzuástegui on 05/05/26.
//
import SwiftUI

// 1. Model to represent each navigation option
struct CategoryOption: Identifiable {
    let id = UUID()
    let title: String = "placeholder"
    //let destination: View
}

struct CategoriesView: View {
    // Argument list of options passed to the view
    let options: [CategoryOption]
    
    // Grid configuration for two columns
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                
                // MARK: - Header
                HStack(alignment: .firstTextBaseline) {
                    Text("Categorías")
                        .font(.system(size: 36, weight: .bold))
                    
                    Spacer()
                    
                    // Notification Button with image asset label
                    /*/
                    Button(action: {
                        // Placeholder for notification action
                        print("Notification tapped")
                    }) {
                        Image("pm_ICON_NOTIF")
                            .resizable()
                            .frame(width: 32, height: 32)
                    }
                     */
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // MARK: - Description with Decorative Line
                HStack(alignment: .top, spacing: 16) {
                    // Decorative line image asset
                    Image("pm_SPECIFIC_element_EXTRA")
                        .resizable()
                        .scaledToFill()
                        .containerRelativeFrame(.vertical) { height, axis in
                            height * 0.1
                        }
                        .frame(width: 4) // Thin vertical bar
                    
                    Text("Haz tu selección de categoría para acceder o consultar al respecto.")
                        .font(.body)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal)
                .padding(.vertical, 30)
                
                // MARK: - Section Title
                Text("Las más visitadas...")
                    .font(.headline)
                    .foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.6)) // Cyan/Blue tone
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                
                // MARK: - Scrollable Grid Section
                // Only the grid area is scrollable as requested
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(options) { option in
                            NavigationLink(destination: DetailView(requestClasses: [ Request_class(id_request_classification: 2, name: "Placeholder title", request_class_description: "Description", department: Department(id_department: 10, name: "RH", department_description: "Human resources"))])) {
                                CategoryGridItem(title: option.title)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

// MARK: - Grid Item Component
struct CategoryGridItem: View {
    let title: String
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background image asset
            Image("pm_FRAME_default")
                .resizable()
                .aspectRatio(1.0, contentMode: .fit) // Keeps it a perfect square
            
            // Label and Chevron
            HStack(spacing: 4) {
                Text(title.uppercased())
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
            // 1. Correct syntax is maxWidth
            // 2. alignment: .trailing pushes the HStack content to the right
            .frame(maxWidth: .infinity, alignment: .trailing)
            // 3. Change .leading padding to .trailing padding
            .padding([.trailing, .bottom], 14)
            //.padding([.leading, .bottom], 14)
            .padding(.trailing, 5)
        }
    }
}

#Preview {
    CategoriesView(options: [CategoryOption(), CategoryOption(), CategoryOption(), CategoryOption()])
}
