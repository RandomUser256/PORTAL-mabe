//
//  DetailView.swift
//  Portal_mabe
//
//  Created by Máximo Magallanes Urtuzuástegui on 05/05/26.
//
import SwiftUI

import SwiftUI

struct DetailView: View {
    // The data model passed to the view
    let requestClasses: [Request_class]
    
    // Environment variable to handle the custom back button action
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // MARK: - Navigation Header
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
            
            // MARK: - Main Title
            Text("Consulta específica")
                .font(.system(size: 28, weight: .bold))
                .padding(.horizontal)
                .padding(.top, 15)
            
            // MARK: - Scrollable Content
            ScrollView {
                VStack(spacing: 30) {
                    // Bottom Section: Repeating Request Items
                    ForEach(requestClasses) { requestClass in
                        DescriptionCard(text: requestClass.request_class_description, requests: requestClass.requests)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 30)
            }
        }
        .navigationBarHidden(true) // We use a custom back button
    }
}

// MARK: - Subviews

struct DescriptionCard: View {
    let text: String
    let requests: [Requests]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header asset (Gray rectangle)
            ZStack(alignment: .topLeading) {
                Image("pm_SPECIFIC_element_0")
                    .resizable()
                    .frame(height: 50)
                
                Text(text)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(.black))
                    .padding()
            }
            
            // Body asset (Container rectangle)
            ZStack(alignment: .topLeading) {
                Image("pm_SPECIFIC_element_1")
                    .resizable()
                    .frame(height: 50)
                
                VStack {
                    ForEach(requests) { request in
                        HStack () {
                            Image("pm_SPECIFIC_element_2")
                                .resizable()
                                .containerRelativeFrame(.vertical) { height, axis in
                                    height * 0.05
                                }
                                .containerRelativeFrame(.horizontal) { width, axis in
                                    width * 0.1
                                }
                            
                            Text(request.name)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(.black))
                                .padding()
                        }
                    }
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

/*
struct RequestListItem: View {
    // Assuming Requests model has a 'name' or 'title' property
    let request: [Requests]
    
    var body: some View {
        VStack(spacing: 0) {
            // Gray square header aligned to the bottom of the previous section
            Image("pm_SPECIFIC_element_0")
                .resizable()
                .frame(height: 40)
            
            // Main container for the row elements
            ForEach()
            ZStack {
                Image("pm_SPECIFIC_element_1")
                    .resizable()
                
                HStack(spacing: 15) {
                    // Left button asset
                    Image("pm_SPECIFIC_element_2")
                        .resizable()
                        .frame(width: 40, height: 40)
                    
                    // Vertical divider (placeholder based on image)
                    Rectangle()
                        .fill(Color(red: 0.1, green: 0.3, blue: 0.4))
                        .frame(width: 3, height: 30)
                    
                    Spacer()
                    
                    // Navigation Link using the arrow asset
                    NavigationLink(destination: Text("Detail View for \(request.name)")) {
                        Image("pm_SPECIFIC_element_3")
                            .resizable()
                            .frame(width: 25, height: 35)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}
*/
private enum DetailViewPreviewData {
    static func requestClasses() -> [Request_class] {
        let department = Department(
            id_department: 10,
            name: "Recursos Humanos",
            department_description: "Área responsable de gestiones administrativas del colaborador."
        )
        let requestClass = Request_class(
            id_request_classification: 2,
            name: "Trámites de personal",
            request_class_description: "Solicitudes frecuentes relacionadas con documentos, permisos y actualizaciones del expediente del colaborador.",
            department: department
        )
        let employeeRole = Employee_roles(
            id_employee_role: 1,
            name: "Operador",
            role_description: "Colaborador de línea de producción.",
            department: department
        )
        let employee = Employee(
            id_employee: 100245,
            employee_role: employeeRole,
            requests: [],
            workdays: [],
            overtime: [],
            employee_superior: Employee_superior(),
            name: "Maria",
            surname: "Lopez",
            institutional_email: "maria.lopez@mabe.com",
            bankNumber: "1234567890",
            salary: 18500
        )

        requestClass.requests = [
            Requests(
                id_request: 1,
                name: "Constancia laboral",
                request_description: "Solicitud de carta laboral para tramite bancario.",
                request_class: requestClass,
                employee: employee
            ),
            Requests(
                id_request: 2,
                name: "Actualizacion de datos",
                request_description: "Cambio de numero telefonico y contacto de emergencia.",
                request_class: requestClass,
                employee: employee
            ),
            Requests(
                id_request: 3,
                name: "Permiso personal",
                request_description: "Permiso de salida anticipada por cita medica.",
                request_class: requestClass,
                employee: employee
            ),
            Requests(
                id_request: 4,
                name: "Reposicion de gafete",
                request_description: "Reposicion por extravio del identificador institucional.",
                request_class: requestClass,
                employee: employee
            )
        ]

        return [requestClass]
    }
}

#Preview {
    DetailView(requestClasses: DetailViewPreviewData.requestClasses())
}
