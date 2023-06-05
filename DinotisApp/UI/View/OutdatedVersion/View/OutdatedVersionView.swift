//
//  OutdatedVersionView.swift
//  DinotisApp
//
//  Created by Gus Adi on 31/05/23.
//

import SwiftUI
import SwiftUINavigation
import DinotisDesignSystem

struct OutdatedVersionView: View {
    var body: some View {
        ZStack {
            
            Color.DinotisDefault.baseBackground
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Image.generalDinotisImage
                        .resizable()
                        .scaledToFit()
                        .frame(height: 35)
                    
                    Spacer()
                }
                
                Spacer()
                
                VStack(spacing: 35) {
                    Image.versionUpdateImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)
                    
                    VStack(spacing: 15) {
                        Text(LocalizableText.outdatedVersionTitleContent)
                            .font(.robotoBold(size: 20))
                            .foregroundColor(.DinotisDefault.black1)
                            .multilineTextAlignment(.center)
                        
                        Text(LocalizableText.outdatedVersionSubtitleContent)
                            .font(.robotoRegular(size: 14))
                            .foregroundColor(.DinotisDefault.black3)
                            .multilineTextAlignment(.center)
                    }
                    
                }
                
                Spacer()
                
                DinotisPrimaryButton(
                    text: LocalizableText.outdatedVersionSubtitleContent,
                    type: .adaptiveScreen,
                    height: 44,
                    textColor: .white,
                    bgColor: .DinotisDefault.primary
                ) {
                    if let url = URL(string: "itms-apps://apple.com/app/id1591802494"),
                       UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                }
            }
            .padding()
        }
    }
}

struct OutdatedVersionView_Previews: PreviewProvider {
    static var previews: some View {
        OutdatedVersionView()
    }
}
