//
//  VideoPlayer.swift
//
//
//  Created by Irham Naufal on 27/10/23.
//

import SwiftUI
import AVKit

public struct DinotisVideoPlayer: UIViewControllerRepresentable {
    
    public var url: URL
    
    public init(url: URL) {
        self.url = url
        self.setUpAudio()
    }
    
    public func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        let player = AVPlayer(url: url)
        
        controller.player = player
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        
    }
    
    private func setUpAudio() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playback, mode: .moviePlayback)
        } catch {
            
        }
    }
}

#Preview {
    DinotisVideoPlayer(url: URL(string: "https://storage.googleapis.com/dinotis-recording-1/recordings/bbb789d0-f056-4c89-b936-7bd5051c72b4_1697192142005.mp4")!)
        .frame(width: 339, height: 193)
}
