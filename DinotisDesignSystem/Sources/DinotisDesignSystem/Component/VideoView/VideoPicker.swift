//
//  VideoPicker.swift
//
//
//  Created by Irham Naufal on 30/10/23.
//

import SwiftUI
import UIKit

public struct VideoPickerView: UIViewControllerRepresentable {
    @Binding var videoURL: URL?
    
    public init(videoURL: Binding<URL?>) {
        self._videoURL = videoURL
    }

    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.mediaTypes = ["public.movie"]
        return picker
    }

    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    public class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: VideoPickerView

        init(parent: VideoPickerView) {
            self.parent = parent
        }

        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let url = info[.mediaURL] as? URL {
                parent.videoURL = url
            }
            picker.dismiss(animated: true)
        }
    }
}
