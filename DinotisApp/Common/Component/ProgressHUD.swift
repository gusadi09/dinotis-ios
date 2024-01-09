//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI
import DinotisDesignSystem

struct ProgressHUD: View {
	var title: String?
    var description = ""
	var geo: GeometryProxy
    let closeLive: (() -> Void)
	
	var body: some View {
		ZStack {
			Color.black
				.opacity(0.7)
			VStack(spacing: 20) {
				LottieView(name: "dinotis-white-lottie-loading", loopMode: .loop)
					.scaledToFit()
					.frame(height: geo.size.height/4)
				
				if let title = title {
					Text(title)
						.foregroundColor(.white)
                        .font(.robotoBold(size: 16))
						.multilineTextAlignment(.center)
				}
                
                Text(description)
                    .foregroundColor(.white)
                    .font(.robotoRegular(size: 10))
                    .multilineTextAlignment(.center)
			}
			.padding()
		}
		.ignoresSafeArea()
	}
}

struct ProgressHUDFlat: View {

	var title: String?
	var description = ""
    
    var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

	var body: some View {
		VStack {
            Spacer()
            
			VStack(spacing: 20) {
				LottieView(name: "waiting-talent", loopMode: .loop)
					.scaledToFit()
                    .frame(height: isPad ? 300 : 180)

				if let title = title {
					Text(title)
						.foregroundColor(.white)
						.font(.robotoBold(size: 16))
						.multilineTextAlignment(.center)
				}

				Text(description)
					.foregroundColor(.white)
					.font(.robotoRegular(size: 10))
					.multilineTextAlignment(.center)
			}
			.padding()
            
            Spacer()
		}
	}
}

struct ProgressHUD_Previews: PreviewProvider {
	static var previews: some View {
		GeometryReader { geo in
			ProgressHUD(title: "Title", geo: geo, closeLive: {})
		}
	}
}
