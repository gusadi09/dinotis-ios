//
//  ImagePicker.swift
//  testingUpload
//
//  Created by Gus Adi on 27/09/21.
//

import Foundation
import UIKit
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
	
	var sourceType: UIImagePickerController.SourceType = .photoLibrary
	
	@Binding var selectedImage: UIImage
    var didFinishPicking: (() -> Void)? = nil
	@Environment(\.dismiss) private var dismiss
	
	func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
		
		let imagePicker = UIImagePickerController()
		imagePicker.allowsEditing = true
		imagePicker.sourceType = sourceType
		imagePicker.delegate = context.coordinator
		
		return imagePicker
	}
	
	func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
		
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}
	
	final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
		
		var parent: ImagePicker
		
		init(_ parent: ImagePicker) {
			self.parent = parent
		}
		
		func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
			
			if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
				parent.selectedImage = image
                if let action = parent.didFinishPicking {
                    action()
                }
			}
			
			parent.dismiss()
		}
	}
}
