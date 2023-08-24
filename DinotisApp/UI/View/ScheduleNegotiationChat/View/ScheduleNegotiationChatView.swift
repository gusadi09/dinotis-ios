//
//  ScheduleNegotiationChatView.swift
//  DinotisApp
//
//  Created by Gus Adi on 05/10/22.
//

import SwiftUI
import DinotisData
import DinotisDesignSystem

struct ScheduleNegotiationChatView: View {

	@ObservedObject var viewModel: ScheduleNegotiationChatViewModel
	@EnvironmentObject var customerChatManager: CustomerChatManager
	@ObservedObject var state = StateObservable.shared

	var body: some View {
		ZStack {
			Color.secondaryBackground.edgesIgnoringSafeArea(.all)

			VStack(spacing: 0) {
				HeaderView(viewModel: viewModel)

				EndChatLimitationView(viewModel: viewModel)
					.padding(.horizontal)
					.padding(.vertical, 10)

				ScrollViewReader { scroll in
					ScrollView {
						LazyVStack(spacing: 15) {
							ForEach(customerChatManager.messages, id: \.id) { item in
								ChatBubbleView(
									sender: item.name.orEmpty(),
									message: item.body,
									date: item.date,
									isSender: item.author == state.userId
								)
								.tag(item.id)
								.onAppear {
									if item.id == (customerChatManager.messages.last?.id).orEmpty() {
										viewModel.count += 30
										customerChatManager.getMessages(count: viewModel.count)
									}
								}
							}
						}
						.padding()
						.onChange(of: customerChatManager.messages.count) { newValue in
							scroll.scrollTo((customerChatManager.messages.last?.id).orEmpty())
						}
						.onAppear {
							scroll.scrollTo((customerChatManager.messages.last?.id).orEmpty())
						}
					}
				}

				HStack(alignment: .bottom, spacing: 15) {
					MultilineTextField(LocaleText.writeYourMessagePlaceholder, text: $viewModel.textMessage)
						.padding(.vertical, 8)
						.padding(.horizontal)
						.background(
							RoundedRectangle(cornerRadius: 20)
								.foregroundColor(Color(.systemGray6))
						)

					Button {
						customerChatManager.sendMessage(viewModel.textMessage)
						viewModel.textMessage = ""
					} label: {
						Image.Dinotis.flatPlaneButtonIcon
							.resizable()
							.scaledToFit()
							.frame(height: 45)
					}
					.disabled(viewModel.textMessage.isEmpty || !viewModel.textMessage.isStringContainWhitespaceAndText())

				}
				.padding(15)
				.background(
					Color.white.edgesIgnoringSafeArea(.bottom)
						.shadow(color: .black.opacity(0.1), radius: 5, x: -2, y: 0)
				)
			}
		}
		.navigationBarHidden(true)
		.navigationBarTitle("")
	}
}

extension ScheduleNegotiationChatView {
	struct HeaderView: View {
		@Environment(\.dismiss) var dismiss

		@ObservedObject var viewModel: ScheduleNegotiationChatViewModel

		var body: some View {
			ZStack {
				HStack {
					Button(action: {
						dismiss()
					}, label: {
						Image.Dinotis.arrowBackIcon
							.padding()
							.background(Color.white)
							.clipShape(Circle())
					})
					.padding()

					Spacer()
				}

				Text(LocaleText.newScheduleDiscussionTitle)
					.font(.robotoBold(size: 14))
					.foregroundColor(.black)
					.lineLimit(2)
					.multilineTextAlignment(.center)
					.frame(width: UIScreen.main.bounds.width - 120)
			}
			.background(
				Color.secondaryBackground
			)
		}
	}

	struct EndChatLimitationView: View {

		@ObservedObject var viewModel: ScheduleNegotiationChatViewModel

		var body: some View {
			HStack {
				Text(LocaleText.finalConfirmationLimitText)
					.font(.robotoMedium(size: 12))
					.foregroundColor(.gray)
					.multilineTextAlignment(.leading)

				Spacer()

                Text(DateUtils.dateFormatter(viewModel.endChat, forFormat: .EEEEddMMMyyyHHmm))
					.font(.robotoMedium(size: 12))
					.foregroundColor(.DinotisDefault.primary)
					.multilineTextAlignment(.trailing)
			}
			.padding(15)
			.background(
				RoundedRectangle(cornerRadius: 10)
					.foregroundColor(.white)
			)
		}
	}
}

struct ScheduleNegotiationChatView_Previews: PreviewProvider {
	static var previews: some View {
		ScheduleNegotiationChatView(viewModel: ScheduleNegotiationChatViewModel(token: "", expireDate: Date(), backToHome: {}))
	}
}
