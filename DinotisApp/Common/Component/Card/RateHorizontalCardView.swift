//
//  RateHorizontalCardView.swift
//  DinotisApp
//
//  Created by Gus Adi on 01/10/22.
//

import SwiftUI
import DinotisData
import DinotisDesignSystem

struct RateHorizontalCardView: View {

	let item: RateCardResponse?
	let isTalent: Bool

	var onTapDelete: () -> Void
	var onTapEdit: () -> Void

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
					Text((item?.title).orEmpty())
						.font(.robotoBold(size: 12))
						.foregroundColor(.black)
						.multilineTextAlignment(.leading)

					Spacer()

					if isTalent {

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

									Text(LocaleText.editRateCardText)
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

									Text(LocaleText.deleteRateCardText)
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
				}

				Text(LocaleText.rateCardPrivateSublabel(duration: (item?.duration).orZero()))
					.font(.robotoRegular(size: 10))
					.foregroundColor(.black)
					.multilineTextAlignment(.leading)

				HStack {
					Image.Dinotis.priceTagIcon
						.resizable()
						.scaledToFit()
						.frame(height: 16)

                    if (item?.price).orEmpty().isEmpty || (item?.price).orEmpty() == "0" {
                        Text(LocalizableText.freeText)
                            .font(.robotoBold(size: 12))
                            .foregroundColor(.DinotisDefault.primary)
                            .multilineTextAlignment(.leading)
                    } else {
                        Text((item?.price).orEmpty().toCurrency())
                            .font(.robotoBold(size: 12))
                            .foregroundColor(.DinotisDefault.primary)
                            .multilineTextAlignment(.leading)
                    }
				}
			}

		}
		.padding(18)
		.background(
			RoundedRectangle(cornerRadius: 12)
				.foregroundColor(.white)
				.shadow(color: .black.opacity(0.1), radius: 8)
		)

    }
}

struct RateHorizontalCardView_Previews: PreviewProvider {
    static var previews: some View {
		RateHorizontalCardView(item: nil, isTalent: false, onTapDelete: {}, onTapEdit: {})
    }
}
