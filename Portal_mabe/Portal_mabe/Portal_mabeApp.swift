//
//  Portal_mabeApp.swift
//  Portal_mabe
//
//  Created by CETYS Universidad  on 04/05/26.
//

import SwiftUI
import SwiftData
internal import Combine

//Structure for storing the user currently in session
/// Shares the currently active user profile across the SwiftUI environment.
class UserSettings: ObservableObject {
    @Published var user: Employee?
    
    init(user: Employee? = nil) {
        self.user = user
    }
}

@main
struct Portal_mabeApp: App {
    //Persisted storage indicator if dataset has previously been loaded
    @AppStorage("didPrepopulateStore") private var didPrepopulate: Bool = false
    
    //SET TO TRUE FOR DEBUG PURPOSES
    @State private var isReadyToBoot: Bool = true
    
    //SET TRUE FOR DEBUG PURPOSES
    @State private var shouldShowMainMenu: Bool = true
    @StateObject private var userSettings = UserSettings()
    
    //Message for debugging purposes
    @State private var loadingMessage: String = "Preparing data…"
        
    //Loads different SwiftData schema
    var sharedModelContainer: ModelContainer

    var body: some Scene {
        WindowGroup {
            if shouldShowMainMenu {
                ContentView()
                    .environmentObject(userSettings)
            } /*else {
                LoginView()
                    .environmentObject(userSettings)
            }*/
        }
        .modelContainer(sharedModelContainer)
    }
    
    init() {
        //Add function to load data from database on first boot
        //preloadStoreIfNeeded()
        
        let fileManager = FileManager.default
        
        let appSupport = try! fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        
        let storeURL = appSupport.appendingPathComponent("default.store")
        
        let config = ModelConfiguration(url: storeURL)
        
        /*
         sharedModelContainer = try! ModelContainer(
         for: Medicine.self, Ingredient.self, AdverseEffect.self,
         configurations: ModelConfiguration()
         )*/
        
        print("Disk storage path: ", URL.applicationSupportDirectory.path(percentEncoded: false))
        
        print(Bundle.main.bundlePath)
        
        let files = try? FileManager.default.contentsOfDirectory(atPath: Bundle.main.bundlePath)
        
        sharedModelContainer = try! ModelContainer(
            for: Department.self,
            Employee.self,
            Employee_requests.self,
            Employee_roles.self,
            Employee_superior.self,
            Overtime.self,
            Request_class.self,
            Requests.self,
            Workday.self,
            configurations: config
        )
        
        do {
            try DataImportModel.importIfNeeded(into: sharedModelContainer)
        }
        catch {
            fatalError("Error loading database into app: \(error)")
        }
        
        print(files ?? [])
    }
    
    /// Verifies that the local medicine store is accessible before enabling the main menu.
        @MainActor
        private func prepareBoot() async {
            guard !isReadyToBoot else { return }

            loadingMessage = "Verificando la base local de la planta…"
            await Task.yield()

            let context = ModelContext(sharedModelContainer)
            
            //Verify that the employee database is not empty
            let employeeCount = (try? context.fetchCount(FetchDescriptor<Employee>())) ?? 0


            loadingMessage = employeeCount > 0
                ? "Base de datos lista. Puedes continuar."
                : "No se cargó existosamente la base de datos."
            isReadyToBoot = true
        }
}

/// Copies the bundled SwiftData store into Application Support the first time the app launches.
func preloadStoreIfNeeded() {
    let fm = FileManager.default
    
    let appSupport = try! fm.url(
        for: .applicationSupportDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
    )
    
    let storeURL = appSupport.appendingPathComponent("default.store")
    
    // If main file exists, assume all are present
    // ACTIVATE FOR FINAL VERSION!!!!!!!!
    guard !fm.fileExists(atPath: storeURL.path) else { return }
    
    let files = ["default.store", "default.store-wal", "default.store-shm"]
    
    for file in files {
        guard let src = Bundle.main.url(forResource: file, withExtension: nil) else {
            fatalError("Missing \(file)")
        }
        
        let dst = appSupport.appendingPathComponent(file)
        try! fm.copyItem(at: src, to: dst)
    }
}
