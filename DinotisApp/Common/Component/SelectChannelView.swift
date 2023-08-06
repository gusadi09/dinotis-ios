//
//  SelectChannelView.swift
//  DinotisApp
//
//  Created by Gus Adi on 06/09/22.
//

import SwiftUI
import DinotisDesignSystem

struct SelectChannelView: View {
    @Binding var channel: DeliveryOTPVia
    let geo: GeometryProxy
    var action: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            Spacer()
            
            Button {
                channel = .whatsapp
                action()
            } label: {
                
                HStack(spacing: 8) {
                    Image.otpWhatsappIcon
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(LocalizableText.titleOTPSendWA)
                            .font(.robotoBold(size: 16))
                        
                        Text(LocalizableText.descriptionOTPSendWA)
                            .font(.robotoRegular(size: 12))
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(Font.system(size: 24, weight: .bold))
                    
                }
                .foregroundColor(.DinotisDefault.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(.DinotisDefault.primary)
                )
            }
            
            Button {
                channel = .sms
                action()
            } label: {
                HStack(spacing: 8) {
                    Image.otpSmsIcon
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(LocalizableText.titleOTPSendSMS)
                            .font(.robotoBold(size: 16))
                        
                        Text(LocalizableText.descriptionOTPSendSMS)
                            .font(.robotoRegular(size: 12))
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(Font.system(size: 24, weight: .bold))
                    
                }
                .foregroundColor(.DinotisDefault.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(.DinotisDefault.secondary)
                )
            }
            
        }
        
    }
}

struct SelectChannelView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            SelectChannelView(channel: .constant(.sms), geo: geo, action: {})
        }
    }
}
