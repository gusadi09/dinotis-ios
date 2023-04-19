//
//  TalentTransactionCard.swift
//  DinotisApp
//
//  Created by Gus Adi on 30/08/21.
//

import SwiftUI
import CurrencyFormatter
import DinotisDesignSystem
import DinotisData

struct TalentTransactionCard: View {
	@Binding var data: BalanceDetailData
	
	var body: some View {
		HStack {
			Image(!(data.isOut ?? true) ? "ic-fee-talent" : "ic-withdraw-talent")
				.resizable()
				.scaledToFit()
				.frame(height: 40)
			
			VStack(alignment: .leading, spacing: 8) {
				Text(!(data.isOut ?? true) ? NSLocalizedString("revenue", comment: "") : NSLocalizedString("withdraw", comment: ""))
                    .font(.robotoBold(size: 14))
					.foregroundColor(.black)
				
				if let dateISO = data.createdAt {
                    Text(DateUtils.dateFormatter(dateISO, forFormat: .EEEEddMMMMyyyy))
                        .font(.robotoRegular(size: 12))
						.foregroundColor(.black)
				}
			}
			
			Spacer()
			
			VStack(alignment: .trailing) {
				HStack {
					Text(!(data.isOut ?? true) ? "+" : "-")
                        .font(.robotoBold(size: 14))
						.foregroundColor(!(data.isOut ?? true) ? .green : .black)
					
					Text(currencyFormatter.string(from: Double(data.amount ?? 0)) ?? "")
                        .font(.robotoBold(size: 14))
						.foregroundColor(!(data.isOut ?? true) ? .green : .black)
				}
				
				if data.isOut ?? true {
					if let dataIsFailed = data.withdraw?.isFailed {
						if data.withdraw?.doneAt != nil && !dataIsFailed {
							Text(NSLocalizedString("finished", comment: ""))
								.font(.robotoRegular(size: 12))
								.foregroundColor(.black)
								.padding(.vertical, 5)
								.padding(.horizontal, 8)
								.background(Color("color-green-complete"))
								.clipShape(Capsule())
								.overlay(
									Capsule()
										.stroke(Color("color-green-stroke"))
								)
						} else if dataIsFailed {
							Text(NSLocalizedString("fail", comment: ""))
								.font(.robotoRegular(size: 12))
								.foregroundColor(.black)
								.padding(.vertical, 3)
								.padding(.horizontal, 8)
								.background(Color("color-red-failed"))
								.clipShape(Capsule())
								.overlay(
									Capsule()
										.stroke(Color("color-red-stroke"))
								)
						}
					}
				} else {
					if data.withdraw?.doneAt != nil || (data.amount ?? 0) >= 0 {
						Text(NSLocalizedString("finished", comment: ""))
							.font(.robotoRegular(size: 12))
							.foregroundColor(.black)
							.padding(.vertical, 5)
							.padding(.horizontal, 8)
							.background(Color("color-green-complete"))
							.clipShape(Capsule())
							.overlay(
								Capsule()
									.stroke(Color("color-green-stroke"))
							)
					}
				}
			}
		}
		.contentShape(Rectangle())
	}
}

private let dateFormatter: DateFormatter = {
	let formatter = DateFormatter()
	formatter.dateStyle = .short
	formatter.locale = Locale.current
	formatter.dateFormat = "EEEE, dd MMMM yyyy"
	return formatter
}()

private let dateISOFormatter: DateFormatter = {
	let dateFormatter = DateFormatter()
	dateFormatter.locale = Locale.current
	dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
	return dateFormatter
}()

private let timeFormatter: DateFormatter = {
	let formatter = DateFormatter()
	formatter.dateStyle = .short
	formatter.locale = Locale.current
	formatter.dateFormat = "HH.mm"
	return formatter
}()

private let currencyFormatter: CurrencyFormatter = {
	let fm = CurrencyFormatter()
	
	fm.currency = .rupiah
	fm.locale = CurrencyLocale.indonesian
	fm.decimalDigits = 0
	
	return fm
}()
