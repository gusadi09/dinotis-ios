//
//  BundlingScheduleCardView.swift
//  DinotisApp
//
//  Created by Gus Adi on 28/09/22.
//

import SwiftUI
import SwiftUINavigation
import DinotisDesignSystem
import DinotisData

struct BundlingScheduleCardView: View {
    
    var onTapButton: (() -> Void)
    
    var onTapEdit: (() -> Void)
    
    var onTapDelete: (() -> Void)
    
    let item: BundlingData

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

				Menu {
					Button(action: {
                        onTapEdit()
					}, label: {
						HStack {
							Image.Dinotis.menuEditIcon
								.renderingMode(.template)
								.resizable()
								.scaledToFit()
								.frame(height: 15)

							Text(LocaleText.editBundling)
								.font(.robotoMedium(size: 12))
						}
					})


					Button(action: {
                        onTapDelete()
					}, label: {
						HStack {
							Image.Dinotis.menuDeleteIcon
								.renderingMode(.template)
								.resizable()
								.scaledToFit()
								.frame(height: 15)

							Text(LocaleText.deleteBundling)
								.font(.robotoMedium(size: 12))
						}
					})

				} label: {
					Image(systemName: "ellipsis")
						.resizable()
						.scaledToFit()
						.frame(height: 6)
						.foregroundColor(.DinotisDefault.primary)
				}

			}

			HStack {
				VStack(alignment: .leading, spacing: 5) {
					Text(item.title.orEmpty())
						.font(.robotoBold(size: 14))
						.multilineTextAlignment(.leading)
						.foregroundColor(.black)

					Text(item.description.orEmpty())
						.font(.robotoRegular(size: 12))
						.multilineTextAlignment(.leading)
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
                    onTapButton()
				} label: {
					Text(LocaleText.seeSessionText)
						.font(.robotoMedium(size: 12))
						.foregroundColor(.black)
						.padding(.vertical, 12)
						.padding(.horizontal, 15)
						.background(
							RoundedRectangle(cornerRadius: 10)
								.foregroundColor(.secondaryViolet)
						)
						.overlay(
							RoundedRectangle(cornerRadius: 10)
								.stroke(Color.DinotisDefault.primary, lineWidth: 1)
						)
				}
			}

			if !(item.isActive ?? false) {
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
				.shadow(color: .black.opacity(0.06), radius: 25, x: 0, y: 0)
		)
		.overlay(
			RoundedRectangle(cornerRadius: 12)
				.stroke(Color.DinotisDefault.primary, lineWidth: 2)
		)
    }
}

struct BundlingScheduleCardView_Previews: PreviewProvider {
    static var previews: some View {
        BundlingScheduleCardView(
			onTapButton: {},
			onTapEdit: {},
			onTapDelete: {},
			item:
				BundlingData(
					id: "",
					title: "",
					description: "",
					price: "",
					createdAt: Date(),
					updatedAt: Date(),
					isActive: false,
					session: 2,
					isBundling: false,
					isAlreadyBooked: nil,
					isFailed: false,
					user: nil,
                    meetings: [],
					meetingBundleId: "",
					background: []
				)
		)
    }
}

struct DummyDataBundling: Hashable {
    let id: Int?
	let title: String = "Testing"
	let desc: String = "Ini testing dengan dummy model sementara"
	let price: Double = 300000
	let bundle: [Int] = [1, 1]
    var isBundleActive: Bool = false
    
    static func == (lhs: DummyDataBundling, rhs: DummyDataBundling) -> Bool {
        lhs.id.orZero() == rhs.id.orZero()
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id.orZero())
    }
}
