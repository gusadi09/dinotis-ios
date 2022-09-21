//
//  SelectChannelView.swift
//  DinotisApp
//
//  Created by Gus Adi on 06/09/22.
//

import SwiftUI

struct SelectChannelView: View {
	@Binding var channel: DeliveryOTPVia
	let geo: GeometryProxy
	var action: () -> Void

    var body: some View {
				VStack(spacing: 35) {
					Text(LocaleText.selectDeliveryOptionOTP)
						.font(.montserratBold(size: 16))
						.foregroundColor(.black)

					VStack(spacing: 15) {
						Button {
							channel = .whatsapp
							action()
						} label: {

							HStack(spacing: 15) {
								Image.Dinotis.otpWhatsappIcon
									.resizable()
									.scaledToFit()
									.frame(height: geo.size.height/22)
									.foregroundColor(.primaryViolet)

								VStack(alignment: .leading, spacing: 5) {
									Text(LocaleText.viaWhatsapp)
										.font(.montserratSemiBold(size: 14))

									Text(LocaleText.viaWhatsappCaption)
										.font(.montserratRegular(size: 12))
										.multilineTextAlignment(.leading)
								}
								.foregroundColor(.black)

								Spacer()

								Image.Dinotis.chevronLeftCircleIcon

							}
							.padding()
							.background(
								RoundedRectangle(cornerRadius: 10)
									.foregroundColor(.clear)
							)
							.overlay(
								RoundedRectangle(cornerRadius: 10)
									.stroke(Color.dinotisStrokeSecondary, lineWidth: 1)
							)
						}

						Button {
							channel = .sms
							action()
						} label: {
							HStack(spacing: 15) {
								Image.Dinotis.otpSmsIcon
									.resizable()
									.scaledToFit()
									.frame(height: geo.size.height/22)
									.foregroundColor(.primaryViolet)

								VStack(alignment: .leading, spacing: 5) {
									Text(LocaleText.viaSms)
										.font(.montserratSemiBold(size: 14))

									Text(LocaleText.viaSmsCaption)
										.font(.montserratRegular(size: 12))
										.multilineTextAlignment(.leading)
								}
								.foregroundColor(.black)

								Spacer()

								Image.Dinotis.chevronLeftCircleIcon

							}
							.padding()
							.background(
								RoundedRectangle(cornerRadius: 10)
									.foregroundColor(.clear)
							)
							.overlay(
								RoundedRectangle(cornerRadius: 10)
									.stroke(Color.dinotisStrokeSecondary, lineWidth: 1)
							)
						}

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
