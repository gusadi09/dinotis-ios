//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI
import DinotisDesignSystem

struct ProgressHUD: View {
    @EnvironmentObject var streamManager: StreamManager
    
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
                
                if streamManager.state == .connecting {
                    Button {
                        withAnimation(.spring()) {
                            closeLive()
                        }
                    } label: {
                        Image.Dinotis.closeGroupCallIcon
                            .resizable()
                            .scaledToFit()
                            .frame(height: 45)
                    }
                    .padding(.top, 20)
                }
			}
			.padding()
		}
		.ignoresSafeArea()
	}
}

struct ProgressHUDFlat: View {

	var title: String?
	var description = ""
	var geo: GeometryProxy

	var body: some View {
		ZStack {
			Color.black
				.opacity(0.4)
			VStack(spacing: 20) {
				LottieView(name: "waiting-talent", loopMode: .loop)
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

struct ProgressHUD_Previews: PreviewProvider {
	static var previews: some View {
		GeometryReader { geo in
			ProgressHUD(title: "Title", geo: geo, closeLive: {})
		}
	}
}
