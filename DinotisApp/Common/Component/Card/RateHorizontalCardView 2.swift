//
//  RateHorizontalCardView.swift
//  DinotisApp
//
//  Created by Gus Adi on 01/10/22.
//

import SwiftUI

struct RateHorizontalCardView: View {

	let item: RateCardResponse
	let isTalent: Bool

    var body: some View {
		HStack(spacing: 15) {

			Image.Dinotis.redCameraVideoIcon
				.resizable()
				.scaledToFit()
				.frame(height: 33)
				.padding(15)
				.background(
					RoundedRectangle(cornerRadius: 12)
						.foregroundColor(.white)
						.shadow(color: .black.opacity(0.1), radius: 5)
				)

			VStack(alignment: .leading, spacing: 10) {
				HStack(spacing: 10) {
                    Text(item.title.orEmpty())
						.font(.montserratBold(size: 12))
						.foregroundColor(.black)
						.multilineTextAlignment(.leading)

					Spacer()

					if isTalent {

						Menu {
							Button(action: {

							}, label: {
								HStack {
									Image.Dinotis.menuEditIcon
										.renderingMode(.template)
										.resizable()
										.scaledToFit()
										.frame(height: 15)

									Text(NSLocalizedString("edit_schedule", comment: ""))
										.font(.montserratSemiBold(size: 12))
								}
							})


							Button(action: {

							}, label: {
								HStack {
									Image.Dinotis.menuDeleteIcon
										.renderingMode(.template)
										.resizable()
										.scaledToFit()
										.frame(height: 15)

									Text(NSLocalizedString("delete_schedule", comment: ""))
										.font(.montserratSemiBold(size: 12))
								}
							})

						} label: {
							Image(systemName: "ellipsis")
								.resizable()
								.scaledToFit()
								.frame(height: 4)
								.foregroundColor(.primaryViolet)
						}
					}
				}

                Text(LocaleText.rateCardPrivateSublabel(duration: item.duration.orZero()))
					.font(.montserratRegular(size: 10))
					.foregroundColor(.black)
					.multilineTextAlignment(.leading)

				HStack {
					Image.Dinotis.priceTagIcon
						.resizable()
						.scaledToFit()
						.frame(height: 16)

                    Text(item.price.orEmpty().toCurrency())
						.font(.montserratBold(size: 12))
						.foregroundColor(.primaryViolet)
						.multilineTextAlignment(.leading)
				}
			}

		}
		.padding(18)
		.background(
			RoundedRectangle(cornerRadius: 12)
				.foregroundColor(.white)
				.shadow(color: .black.opacity(0.1), radius: 10)
		)

    }
}

struct RateHorizontalCardView_Previews: PreviewProvider {
    static var previews: some View {
        RateHorizontalCardView(item: RateCardResponse(id: "", title: "", description: "", price: "", duration: 10), isTalent: false)
    }
}

struct DummyDataRateCard {
	let title: String = "Ngobrol bareng aku yuk!"
    let desc: String = "Deskripsi ini deskripsi ini deskripsi ini deskripsi."
	let duration: Int = 60
	let price: Double = 300000
}
