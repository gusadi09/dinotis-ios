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
    public var isAutoPlay: Bool = false
    
    public init(url: URL, isAutoPlay: Bool = false) {
        self.url = url
        self.isAutoPlay = isAutoPlay
        self.setUpAudio()
    }
    
    public func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        let player = AVPlayer(url: url)
        player.currentItem?.asset.loadValuesAsynchronously(forKeys: ["tracks"], completionHandler: {
            
        })
        
        controller.player = player
        
        DispatchQueue.global().async {
                   let asset = AVURLAsset(url: url)
                   let assetKeys = ["playable", "hasProtectedContent"]

                   asset.loadValuesAsynchronously(forKeys: assetKeys) {
                       var error: NSError?
                       for key in assetKeys {
                           let status = asset.statusOfValue(forKey: key, error: &error)
                           if status == .failed {
                               // Handle error loading the asset
                               print("Failed to load \(key): \(error?.localizedDescription ?? "Unknown error")")
                               return
                           }
                       }

                       // All necessary keys loaded successfully
                       DispatchQueue.main.async {
                           player.replaceCurrentItem(with: AVPlayerItem(asset: asset))
                       }
                   }
               }
        
        if isAutoPlay {
            player.play()
        }
        
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
