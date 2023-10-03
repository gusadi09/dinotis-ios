//
//  PrivateLocalParticipantManager.swift
//  DinotisApp
//
//  Created by Garry on 08/09/22.
//

import Combine
import TwilioVideo
import Foundation
import DinotisData

class PrivateLocalParticipantManager: NSObject {
    let changePublisher = PassthroughSubject<PrivateLocalParticipantManager, Never>()
    let errorPublisher = PassthroughSubject<Error, Never>()
    let dataTrack = LocalDataTrack()
    let stateObs = StateObservable.shared
    var identity: String { stateObs.twilioUserIdentity }
    var position: AVCaptureDevice.Position? {
        get {
            cameraSource?.device?.position
        }
        set {
            guard let newValue = newValue, let captureDevice = CameraSource.captureDevice(position: newValue) else {
                return
            }
            
            cameraSource?.selectCaptureDevice(captureDevice) { _, _, error in
                if let error = error {
                    print("Select capture device error: \(error)")
                }

                StateObservable.shared.cameraPositionUsed = newValue
            }
        }
    }
    var isMicOn = false {
        didSet {
            
            guard oldValue != isMicOn else {
                return
            }
            
            if isMicOn {
                guard let micTrack = LocalAudioTrack(options: nil, enabled: true, name: TrackName.mic) else {
                    return
                }
                
                self.micTrack = micTrack
                participant?.publishAudioTrack(micTrack)
                
                self.micTrack = micTrack
                participant?.publishAudioTrack(micTrack)
            } else {
                guard let micTrack = micTrack else { return }
                
                participant?.unpublishAudioTrack(micTrack)
                self.micTrack = nil
            }
            
            changePublisher.send(self)
        }
    }
    
    var isCameraOn = false {
        didSet {
            guard oldValue != isCameraOn else { return }
            
            if isCameraOn {
                guard let window = self.app.connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene else { return }
                guard let layer = window.windows.first else { return }
                let sourceOptions = CameraSourceOptions { builder in
                    guard let scene = layer.windowScene else { return }
                    
                    builder.orientationTracker = UserInterfaceTracker(scene: scene)
                }
                
                guard
                    let cameraSource = CameraSource(options: sourceOptions, delegate: self),
                    let captureDevice = CameraSource.captureDevice(position: StateObservable.shared.cameraPositionUsed),
                    let cameraTrack = LocalVideoTrack(source: cameraSource, enabled: true, name: TrackName.camera)
                else {
                    return
                }
                
                cameraSource.startCapture(device: captureDevice, completion: nil)
                
                participant?.publishVideoTrack(cameraTrack)
                self.cameraSource = cameraSource
                self.cameraTrack = cameraTrack
                
            } else {
                if let cameraTrack = cameraTrack {
                    participant?.unpublishVideoTrack(cameraTrack)
                }
                
                cameraSource?.stopCapture()
                cameraSource = nil
                cameraTrack = nil
            }
            
            changePublisher.send(self)
        }
    }
    var participant: LocalParticipant? {
        didSet {
            participant?.delegate = self
        }
    }
    private(set) var micTrack: LocalAudioTrack?
    private(set) var cameraTrack: LocalVideoTrack?
    private let app = UIApplication.shared
    private var cameraSource: CameraSource?
    
    func sendMessage(_ message: PrivateRoomMessage) {
        let encoder = JSONEncoder()
        
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        guard let data = try? encoder.encode(message) else {
            return
        }
        
        dataTrack?.send(data)
    }
    
}

extension PrivateLocalParticipantManager: LocalParticipantDelegate {
    func localParticipantDidFailToPublishVideoTrack(
        participant: LocalParticipant,
        videoTrack: LocalVideoTrack,
        error: Error
    ) {
        errorPublisher.send(error)
    }
    
    func localParticipantDidFailToPublishAudioTrack(
        participant: LocalParticipant,
        audioTrack: LocalAudioTrack,
        error: Error
    ) {
        errorPublisher.send(error)
    }
}

extension PrivateLocalParticipantManager: CameraSourceDelegate {
    func cameraSourceWasInterrupted(source: CameraSource, reason: AVCaptureSession.InterruptionReason) {
        cameraTrack?.isEnabled = false
        changePublisher.send(self)
    }
    
    func cameraSourceInterruptionEnded(source: CameraSource) {
        cameraTrack?.isEnabled = true
        changePublisher.send(self)
    }
}


