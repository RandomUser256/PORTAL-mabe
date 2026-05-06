//
//  CategoriesView.swift
//  Portal_mabe
//
//  Created by Máximo Magallanes Urtuzuástegui on 05/05/26.
//
import SwiftUI

struct CategoriesView: View {
    private let requestCategories = DemoRequestCatalog.bundled.categories
    private let images = ["pexels-pavel-danilyuk-7654129", "hand-holding-key-outdoors", "pexels-ekaterina-bolovtsova-6077554", "medium-shot-couple-preparing-food-together", "pexels-markus-winkler-1430818-19891028", "business-man-calculating-finance-numbers"]

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .firstTextBaseline) {
                    Text("Categorías")
                        .font(.system(size: 36, weight: .bold))

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 20)

                HStack(alignment: .top, spacing: 16) {
                    Image("pm_SPECIFIC_element_EXTRA")
                        .resizable()
                        .scaledToFill()
                        .containerRelativeFrame(.vertical) { height, _ in
                            height * 0.1
                        }
                        .frame(width: 4)

                    Text("Haz tu selección de categoría para acceder o consultar al respecto.")
                        .font(.body)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal)
                .padding(.vertical, 30)

                Text("Las más visitadas...")
                    .font(.headline)
                    .foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.6))
                    .padding(.horizontal)
                    .padding(.bottom, 10)

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(Array(requestCategories.enumerated()), id: \.element.id) { index, category in
                            NavigationLink(destination: DetailView(category: category)) {
                                CategoryGridItem(
                                    title: category.name,
                                    imageName: images[index % images.count]
                                )
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

struct CategoryGridItem: View {
    let title: String
    let imageName: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image("pm_FRAME_default")
                .resizable()
                .aspectRatio(1.0, contentMode: .fit)
                
            /*
            VStack(spacing: 10) {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 14)
                    .padding(.top, 14)
                    .containerRelativeFrame(.vertical) { height, axis in
                        height * 0.4
                    }

                Spacer(minLength: 0)
            }
             */

            HStack(spacing: 4) {
                Text(title.uppercased())
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding([.trailing, .bottom], 14)
            .padding(.trailing, 5)
        }
    }
}

#Preview {
    CategoriesView()
}
