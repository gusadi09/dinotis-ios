//
//  CreateTalentRateCardForm.swift
//  DinotisApp
//
//  Created by Gus Adi on 03/10/22.
//

import DinotisDesignSystem
import SwiftUI

struct CreateTalentRateCardForm: View {

	@ObservedObject var viewModel: CreateTalentRateCardFormViewModel
	@Environment(\.dismiss) var dismiss

    var body: some View {
		ZStack {

			Color.secondaryBackground.edgesIgnoringSafeArea(.all)

			VStack(spacing: 0) {
				HeaderView(viewModel: viewModel)

				ScrollView(.vertical, showsIndicators: false) {
					VStack(spacing: 15) {
						TitleDescriptionForm(viewModel: viewModel)
					}
					.padding()
				}
                
                Button {
                    viewModel.submitForm {
                        dismiss()
                    }
                } label: {
                    HStack {
                        Spacer()

						Text(viewModel.buttonSubmitText())
							.font(.robotoMedium(size: 12))
							.foregroundColor(viewModel.isDisabled() ? Color(.systemGray3) : .white)

						Spacer()
					}
					.padding()
					.background(
						RoundedRectangle(cornerRadius: 12)
							.foregroundColor(viewModel.isDisabled() ? Color(.systemGray5) : .DinotisDefault.primary)
					)
				}
				.padding()
				.background(
					Color.white
						.edgesIgnoringSafeArea(.bottom)
				)
				.disabled(viewModel.isDisabled())

			}
            
            DinotisLoadingView(.fullscreen, hide: !viewModel.isLoading)
		}
    .dinotisAlert(
      isPresent: $viewModel.isShowAlert,
      title: viewModel.alert.title,
      isError: viewModel.alert.isError,
      message: viewModel.alert.message,
      primaryButton: viewModel.alert.primaryButton
    )
		.onAppear {
			viewModel.onAppear()
		}
		.navigationBarHidden(true)
		.navigationBarTitle("")
    }
}

extension CreateTalentRateCardForm {
	struct HeaderView: View {
		@Environment(\.dismiss) var dismiss

		@ObservedObject var viewModel: CreateTalentRateCardFormViewModel

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

				Text(viewModel.headerTitle())
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

	struct TitleDescriptionForm: View {

		@ObservedObject var viewModel: CreateTalentRateCardFormViewModel

		var body: some View {
			VStack(alignment: .leading, spacing: 20) {
				HStack {
					Image.Dinotis.videoCallFormIcon
						.resizable()
						.scaledToFit()
						.frame(height: 12)

					Text(LocaleText.titleDescriptionFormTitle)
						.font(.robotoMedium(size: 12))
						.foregroundColor(.black)

					Spacer()
				}

				VStack(spacing: 10) {
					VStack {
						TextField(LocaleText.exampleFormTitlePlaceholder, text: $viewModel.title)
							.font(.robotoRegular(size: 12))
							.autocapitalization(.words)
							.disableAutocorrection(true)
							.foregroundColor(.black)
							.accentColor(.black)
							.padding(.horizontal)
							.padding(.vertical, 15)
							.overlay(
								RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
							)

						if viewModel.titleError != nil {
							HStack {
								Image.Dinotis.exclamationCircleIcon
									.resizable()
									.scaledToFit()
									.frame(height: 10)
									.foregroundColor(.red)
								Text(viewModel.titleError.orEmpty())
									.font(.robotoRegular(size: 10))
									.foregroundColor(.red)
									.multilineTextAlignment(.leading)

								Spacer()
							}
						}
					}

					VStack {
						MultilineTextField(LocaleText.enterDescriptionPlaceholder, text: $viewModel.desc)
							.foregroundColor(.black)
							.accentColor(.black)
							.padding(.horizontal, 10)
							.padding(.vertical, 10)
							.overlay(
								RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
							)

						if viewModel.descError != nil {
							HStack {
								Image.Dinotis.exclamationCircleIcon
									.resizable()
									.scaledToFit()
									.frame(height: 10)
									.foregroundColor(.red)
								Text(viewModel.descError.orEmpty())
									.font(.robotoRegular(size: 10))
									.foregroundColor(.red)
									.multilineTextAlignment(.leading)

								Spacer()
							}
						}
					}
				}

				HStack(alignment: .top, spacing: 10) {
					VStack {
						HStack {
							Image.Dinotis.priceTagIcon
								.resizable()
								.scaledToFit()
								.frame(height: 20)

							Text(LocaleText.priceOnlyGeneralText)
								.font(.robotoBold(size: 12))
								.foregroundColor(.black)

							Spacer()
						}

						HStack {
							Image.Dinotis.coinIcon
								.resizable()
								.scaledToFit()
								.frame(height: 15)

							TextField("0", text: $viewModel.price)
								.font(.robotoRegular(size: 12))
								.autocapitalization(.words)
								.disableAutocorrection(true)
								.foregroundColor(.black)
								.accentColor(.black)
								.keyboardType(.numberPad)
						}
						.padding(.horizontal)
						.padding(.vertical, 15)
						.overlay(
							RoundedRectangle(cornerRadius: 6).stroke(Color(.systemGray6).opacity(0.5), lineWidth: 2.0)
						)
					}

					VStack {
						HStack {
							Image.Dinotis.clockIcon
								.resizable()
								.scaledToFit()
								.frame(height: 20)

							Text(LocaleText.durationOnlyGeneralText)
								.font(.robotoBold(size: 12))
								.foregroundColor(.black)

							Spacer()
						}

						HStack {
							TextField("0", text: $viewModel.duration)
								.font(.robotoRegular(size: 12))
								.autocapitalization(.words)
								.disableAutocorrection(true)
								.foregroundColor(.black)
								.accentColor(.black)
								.keyboardType(.numberPad)

							Text(LocaleText.minuteInParameter)
								.font(.robotoRegular(size: 12))
								.foregroundColor(.black)

						}
						.padding(.horizontal)
						.padding(.vertical, 15)
						.overlay(
							RoundedRectangle(cornerRadius: 6).stroke(Color(.systemGray6).opacity(0.5), lineWidth: 2.0)
						)

						if viewModel.durationError != nil {
							HStack {
								Image.Dinotis.exclamationCircleIcon
									.resizable()
									.scaledToFit()
									.frame(height: 10)
									.foregroundColor(.red)
								Text(viewModel.durationError.orEmpty())
									.font(.robotoRegular(size: 10))
									.foregroundColor(.red)
									.multilineTextAlignment(.leading)

								Spacer()
							}
						}
					}
				}
			}
			.padding()
			.padding(.vertical, 10)
			.background(
				RoundedRectangle(cornerRadius: 12)
					.foregroundColor(.white)
			)
		}
	}
}

struct CreateTalentRateCardForm_Previews: PreviewProvider {
    static var previews: some View {
		CreateTalentRateCardForm(viewModel: CreateTalentRateCardFormViewModel(isEdit: false, rateCardId: "", backToHome: {}))
    }
}
