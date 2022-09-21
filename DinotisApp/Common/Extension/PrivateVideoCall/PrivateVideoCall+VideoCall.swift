//
//  VideoCallServices.swift
//  Agora-iOS-Tutorial-SwiftUI-1to1
//
//  Created by Gus Adi on 08/10/21.
//  Copyright © 2021 Agora. All rights reserved.
//

import Foundation
import SwiftUI

extension PrivateVideoCallView {
	
	func switchCamera() {
		DispatchQueue.main.async {
			self.viewModel.isSwitchCam.toggle()
		}
	}
	
	func toggleLocalAudio() {
		DispatchQueue.main.async {
			self.speakerSettingsManager.isMicOn.toggle()
		}
	}
	
	func toogleLocalCamera() {
		DispatchQueue.main.async {
			
			self.speakerSettingsManager.isCameraOn.toggle()
		}
	}
}
