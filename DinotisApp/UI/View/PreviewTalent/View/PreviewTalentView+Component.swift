//
//  PreviewTalentView+Component.swift
//  DinotisApp
//
//  Created by Gus Adi on 23/04/22.
//

import SwiftUI
import DinotisData
import DinotisDesignSystem

extension PreviewTalentView {
	struct HeaderView: View {

		@ObservedObject var viewModel: PreviewTalentViewModel

		@Environment(\.presentationMode) var presentationMode

		var body: some View {
			ZStack {
				HStack {
					Button(action: {
						presentationMode.wrappedValue.dismiss()
					}, label: {
						Image.Dinotis.arrowBackIcon
							.padding()
							.background(Color.white)
							.clipShape(Circle())
							.shadow(color: .black.opacity(0.1), radius: 15)
					})
					.padding(.leading)

					Spacer()
				}

				HStack {
					Spacer()
					Text((viewModel.nameOfUser).orEmpty())
						.font(.robotoBold(size: 14))
						.foregroundColor(.black)

					Spacer()
				}
			}
		}
	}

	struct CardProfile: View {

		@ObservedObject var viewModel: PreviewTalentViewModel

		private let config = Configuration.shared

		@State var textJob = Text("")

		var body: some View {
			VStack(spacing: 25) {
				HStack(spacing: 15) {
					ProfileImageContainer(
						profilePhoto: $viewModel.photoProfile,
						name: $viewModel.nameOfUser,
						width: 56,
						height: 56
					)

					VStack(alignment: .leading, spacing: 10) {
						HStack(spacing: 5) {
							Text((viewModel.userData?.name).orEmpty())
                                .font(.robotoMedium(size: 14))
								.minimumScaleFactor(0.9)
								.lineLimit(1)
								.foregroundColor(.black)

							if viewModel.userData?.isVerified ?? false {
								Image.Dinotis.accountVerifiedIcon
									.resizable()
									.scaledToFit()
									.frame(height: 16)
							}
						}

						HStack {
							Image.Dinotis.suitcaseIcon
								.resizable()
								.scaledToFit()
								.frame(height: 12)

							textJob
						}
					}
					.valueChanged(value: viewModel.userData?.name) { _ in
						for item in viewModel.userData?.professions ?? [] {
							textJob = textJob + Text(" \((item.profession?.name).orEmpty()) ")
								.font(.robotoRegular(size: 12))
								.foregroundColor(.black)
						}
					}

					Spacer()

				}

				HStack {
					Spacer()

					Text((viewModel.userData?.profileDescription).orEmpty())
						.font(.robotoRegular(size: 12))
						.foregroundColor(.black)
						.padding(.horizontal)
						.padding(.vertical, 20)
						.multilineTextAlignment(.center)

					Spacer()
				}
				.background(Color.secondaryViolet)
				.cornerRadius(12)

				HStack(alignment: .center) {
					Image.Dinotis.personPhoneIcon
						.resizable()
						.scaledToFit()
						.frame(height: 16)

					Text(LocaleText.videoCallSchedule)
						.font(.robotoRegular(size: 14))
						.foregroundColor(.black)

				}
				.background(Color.clear)
				.padding([.top, .bottom], -5)

				Rectangle()
					.frame(height: 1.5, alignment: .center)
					.foregroundColor(Color(.purple).opacity(0.1))
					.padding([.leading, .trailing], 20)

			}
			.padding([.leading, .trailing, .top])
			.background(Color.clear)
		}
	}
}
