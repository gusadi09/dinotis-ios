//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct ProgressHUD: View {
	var title: String?
	var geo: GeometryProxy
	
	var body: some View {
		ZStack {
			Color.black
				.opacity(0.4)
			VStack(spacing: 40) {
				LottieView(name: "waiting-talent", loopMode: .loop)
					.scaledToFit()
					.frame(height: geo.size.height/4)
				
				if let title = title {
					Text(title)
						.foregroundColor(.white)
						.font(.system(size: 20, weight: .bold))
						.multilineTextAlignment(.center)
				}
			}
			.padding()
		}
		.ignoresSafeArea()
	}
}

struct ProgressHUD_Previews: PreviewProvider {
	static var previews: some View {
		GeometryReader { geo in
			ProgressHUD(title: "Title", geo: geo)
		}
	}
}
