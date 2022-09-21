//
//  CoinHistoryCard.swift
//  DinotisApp
//
//  Created by Gus Adi on 21/06/22.
//

import SwiftUI

struct CoinHistoryCard: View {

	private let item: CoinHistoryData

	init(item: CoinHistoryData) {
		self.item = item
	}

	var body: some View {
		HStack(alignment: .top, spacing: 15) {
			(item.isOut ?? false ? Image.Dinotis.coinOutIcon : Image.Dinotis.coinInIcon)
				.resizable()
				.scaledToFit()
				.frame(height: 40)

			HStack {
				VStack(alignment: .leading, spacing: 5) {
					Text(item.title.orEmpty())
						.font(.montserratBold(size: 14))

					Text(item.createdAt.orEmpty().toDate(format: .utcV2).orCurrentDate().toString(format: .ddMMMMyyyy))
						.font(.montserratRegular(size: 12))
						.foregroundColor(.dinotisGray)
				}

				Spacer()

				Text(item.isOut ?? false ? "-\(item.amount ?? 0)" : "+\(item.amount ?? 0)")
					.font(.montserratBold(size: 14))
					.foregroundColor(item.isOut ?? false ? .red : .green)
			}
		}
	}
}

struct CoinHistoryCard_Previews: PreviewProvider {
	static var previews: some View {
		GeometryReader { geo in
			CoinHistoryCard(
				item: CoinHistoryData(
					id: 1,
					title: "Testing",
					description: "Testing",
					amount: 10000,
					isOut: false,
					isConfirmed: true,
					coinBalanceId: 1,
					meetingId: "testing",
					createdAt: Date().toString(format: .utc),
					isPending: false,
					isSuccess: true
				)
			)
		}
	}
}
