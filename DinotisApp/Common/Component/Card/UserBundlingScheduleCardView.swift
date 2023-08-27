//
//  UserBundlingScheduleCardView.swift
//  DinotisApp
//
//  Created by Garry on 01/10/22.
//

import SwiftUI
import DinotisDesignSystem
import DinotisData

struct UserBundlingScheduleCardView: View {

    @Binding var item: BundlingData
    
    var onTapSession: (() -> Void)
    
    var onTapBooking: (() -> Void)

	let isTalent: Bool

    var body: some View {
        VStack(spacing: 20) {
            HStack {

                Image.Dinotis.redPricetagIcon
                    .resizable()
                    .scaledToFit()
                    .frame(height: 20)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.secondaryViolet)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.DinotisDefault.primary, lineWidth: 1)
                    )

                Spacer()
                
            }

            HStack {
                VStack(alignment: .leading, spacing: 5) {
					Text(item.title.orEmpty())
                        .font(.robotoBold(size: 14))
                        .foregroundColor(.black)

					Text(item.description.orEmpty())
                        .font(.robotoRegular(size: 12))
                        .foregroundColor(.black)
                }

                Spacer()
            }

            HStack {

                Image.Dinotis.calendarIcon
                    .resizable()
                    .scaledToFit()
                    .frame(height: 18)

				Text(LocaleText.sessionCountText(count: item.session.orZero()))
                    .font(.robotoRegular(size: 12))
                    .foregroundColor(.black)

                Spacer()
                
                Button {
                    onTapSession()
                } label: {
                    HStack {
                        Text(LocaleText.seeSessionText)
                            .font(.robotoBold(size: 12))
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(.DinotisDefault.primary)
                }
            }

            Divider()

            HStack {
                Image.Dinotis.priceTagIcon
                    .resizable()
                    .scaledToFit()
                    .frame(height: 20)

				Text(item.price.orEmpty().toCurrency())
                    .font(.robotoBold(size: 14))
                    .foregroundColor(.black)

                Spacer()

                Button {
                    onTapBooking()
                } label: {
                    if (item.isFailed ?? false) && (item.isAlreadyBooked ?? false) {
                        Text(NSLocalizedString("booking_again_text", comment: ""))
                            .font(.robotoMedium(size: 12))
                            .foregroundColor(.white)
                            .padding()
                            .padding(.horizontal, 10)
                            .background(Color("btn-stroke-1"))
                            .cornerRadius(8)
                            .multilineTextAlignment(.center)
                    } else if item.isFailed == nil && (item.isAlreadyBooked ?? false) {
                        Text(LocaleText.detailPaymentText)
                            .font(.robotoMedium(size: 12))
                            .foregroundColor(Color.completeGreen)
                            .padding()
                            .padding(.horizontal, 10)
                            .background(Color.primaryGreen)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.completeGreen, lineWidth: 1.0)
                            )
                            .multilineTextAlignment(.center)
                    } else if !(item.isFailed ?? false) && (item.isAlreadyBooked ?? false) {
                        Text(NSLocalizedString("view_details", comment: ""))
                            .font(.robotoMedium(size: 12))
                            .foregroundColor(Color("btn-stroke-1"))
                            .padding()
                            .padding(.horizontal, 10)
                            .background(Color("btn-color-1"))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color("btn-stroke-1"), lineWidth: 1.0)
                            )
                            .multilineTextAlignment(.center)
                    } else {
                        Text(LocaleText.booking)
                            .font(.robotoMedium(size: 12))
                            .foregroundColor(.white)
                            .padding()
                            .padding(.horizontal)
                            .background(Color.DinotisDefault.primary)
                            .cornerRadius(8)
                    }
                }
            }

			if !(item.isActive ?? false) && isTalent {
				HStack {
					Spacer()

					Text(LocaleText.bundlingNotActiveText)
						.font(.robotoRegular(size: 10))
						.foregroundColor(.white)

					Spacer()
				}
				.padding(.vertical, 5)
				.background(
					Capsule()
						.foregroundColor(.attentionPink)
				)
			}
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 0)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.DinotisDefault.primary, lineWidth: 2)
        )
    }
}

struct UserBundlingScheduleCardView_Previews: PreviewProvider {
    static var previews: some View {
		UserBundlingScheduleCardView(
			item: .constant(
				BundlingData(
					id: nil,
					title: nil,
					description: nil,
					price: nil,
					createdAt: nil,
					updatedAt: nil,
					isActive: nil,
					session: nil,
					isBundling: nil,
					isAlreadyBooked: nil,
					isFailed: false,
					user: nil,
                    meetings: [],
					meetingBundleId: "",
					background: []
				)
			),
			onTapSession: {},
			onTapBooking: {},
			isTalent: true
		)
	}
}
