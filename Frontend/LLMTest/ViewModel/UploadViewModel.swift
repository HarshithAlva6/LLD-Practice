//
//  UploadViewModel.swift
//  LLMTest
//
//  Created by Harshith Harijeevan on 1/1/26.
//

import Foundation

@MainActor
@Observable
class UploadViewModel {
    var document: String = ""
    var isUploading: Bool = false
    var success: String = ""
    func uploadDoc() async {
        isUploading = true
        do {
            let body = ["texts": [document]]
            let _: [String: String] = try await NetworkService.post(
                endpoint: .addCollection,
                body: body
            )
            success = "Document Indexed!"
            document = ""
        } catch {
            print("Upload error! \(error)")
        }
        isUploading = false
    }
}
