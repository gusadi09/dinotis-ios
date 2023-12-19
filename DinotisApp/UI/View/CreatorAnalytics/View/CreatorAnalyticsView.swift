//
//  CreatorAnalyticsView.swift
//  DinotisApp
//
//  Created by Gus Adi on 17/12/23.
//

import DinotisDesignSystem
import DinotisData
import SwiftUI

struct CreatorAnalyticsView: View {
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var state = StateObservable.shared
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(
                type: .textHeader,
                title: LocalizableText.profileCreatorAnalytics,
                headerColor: .clear,
                textColor: .DinotisDefault.black1,
                leadingButton:  {
                    Button {
                        dismiss()
                    } label: {
                        Image.generalBackIcon
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(.white)
                                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 0)
                            )
                    }
                })
            
            WebView(
                url: URL(string: "\(Configuration.shared.environment.openURL)talent/analytics"),
                accessToken: state.accessToken,
                refreshToken: state.refreshToken,
                userRole: state.userType == 2 ? "talent" : "user",
                domain: Configuration.shared.environment.cookiesDomain
            )
                .ignoresSafeArea()
        }
        .navigationBarTitle(Text(""))
        .navigationBarHidden(true)
    }
}

#Preview {
    CreatorAnalyticsView()
}
