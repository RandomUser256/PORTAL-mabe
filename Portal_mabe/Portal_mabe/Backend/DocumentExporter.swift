//
//  DocumentExporter.swift
//  Portal_mabe
//
//  Created by Máximo Magallanes Urtuzuástegui on 05/05/26.
//
import SwiftUI
import UniformTypeIdentifiers
import UIKit

//Handles the exporter menu to save pdf files in the phone files

struct DocumentExporter: UIViewControllerRepresentable {
    let urlsToExport: [URL]
    var asCopy: Bool = true
    var onCompletion: ((Bool) -> Void)? = nil

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forExporting: urlsToExport, asCopy: asCopy)
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onCompletion: onCompletion)
    }

    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        private let onCompletion: ((Bool) -> Void)?

        init(onCompletion: ((Bool) -> Void)?) {
            self.onCompletion = onCompletion
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            onCompletion?(false)
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            // Export succeeded if we got at least one destination URL
            onCompletion?(true)
        }
    }
}
