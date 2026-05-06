//
//  DetailView.swift
//  Portal_mabe
//
//  Created by Máximo Magallanes Urtuzuástegui on 05/05/26.
//
import SwiftUI

struct DetailView: View {
    let category: DemoRequestCategory

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title2.bold())
                        .foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.5))
                        .padding(10)
                        .background(Circle().fill(Color.gray.opacity(0.2)))
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 10)

            Text("Consulta específica")
                .font(.system(size: 28, weight: .bold))
                .padding(.horizontal)
                .padding(.top, 15)

            ScrollView {
                VStack(spacing: 30) {
                    CategorySummaryCard(text: category.description)

                    ForEach(Array(category.requests.enumerated()), id: \.element.id) { index, request in
                        DescriptionCard(
                            title: request.name,
                            text: request.description
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 30)
            }
        }
        .navigationBarHidden(true)
    }
}

struct CategorySummaryCard: View {
    let text: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            Image("pm_SPECIFIC_element_0")
                .resizable()
                .scaledToFill()

            Text(text)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)
                .padding()
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipped()
    }
}

struct DescriptionCard: View {
    let title: String
    let text: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            Image("pm_SPECIFIC_element_1")
                .resizable()
                .scaledToFill()

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image("pm_SPECIFIC_element_2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)

                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)

                    Spacer(minLength: 0)
                }

                Text(text)
                    .font(.system(size: 14))
                    .foregroundColor(.black.opacity(0.75))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
        .clipped()
    }
}

private enum DetailViewPreviewData {
    static var category: DemoRequestCategory {
        DemoRequestCatalog.bundled.categories.first ?? DemoRequestCategory(
            id: 504,
            name: "Permisos y Beneficios",
            description: "Solicitudes frecuentes administradas por Recursos Humanos.",
            requests: [
                DemoRequestItem(
                    id: 1008,
                    name: "Solicitud vacaciones",
                    description: "Solicitud de días de vacaciones con validación de saldo disponible."
                ),
                DemoRequestItem(
                    id: 1009,
                    name: "Permiso personal",
                    description: "Solicitud de permiso temporal por asuntos personales o familiares."
                )
            ]
        )
    }
}

#Preview {
    DetailView(category: DetailViewPreviewData.category)
}
