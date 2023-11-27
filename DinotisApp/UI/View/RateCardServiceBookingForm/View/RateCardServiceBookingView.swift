//
//  RateCardServiceBookingView.swift
//  DinotisApp
//
//  Created by Gus Adi on 01/10/22.
//

import SwiftUI
import QGrid
import StoreKit
import SwiftUINavigation
import DinotisDesignSystem

struct RateCardServiceBookingView: View {

	@ObservedObject var viewModel: RateCardServiceBookingFormViewModel
    @Environment(\.dismiss) var dismiss
    
    @Binding var mainTabValue: TabRoute

    var body: some View {
		ZStack {
            Color.DinotisDefault.baseBackground
                .edgesIgnoringSafeArea(.all)
            
            NavigationLink(
                unwrapping: $viewModel.route,
                case: /HomeRouting.bookingInvoice,
                destination: { viewModel in
                    UserInvoiceBookingView(
                        viewModel: viewModel.wrappedValue, mainTabValue: $mainTabValue
                    )
                },
                onNavigate: {_ in},
                label: {
                    EmptyView()
                }
            )
            
            NavigationLink(
                unwrapping: $viewModel.route,
                case: /HomeRouting.paymentMethod,
                destination: {viewModel in
                    PaymentMethodView(viewModel: viewModel.wrappedValue, mainTabValue: $mainTabValue)
                },
                onNavigate: {_ in},
                label: {
                    EmptyView()
                }
            )

			VStack(spacing: 0) {
                HeaderView(
                    type: .textHeader,
                    title: LocalizableText.bookingRateCardTitle,
                    leadingButton: {
                        DinotisElipsisButton(
                            icon: .generalBackIcon,
                            iconColor: .DinotisDefault.black1,
                            bgColor: .DinotisDefault.white,
                            strokeColor: nil,
                            iconSize: 12,
                            type: .primary, {
                                dismiss()
                            }
                        )
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 0)
                    }
                )

				ScrollView(.vertical, showsIndicators: false) {
					VStack(spacing: 15) {
						TitleDescriptionForm(viewModel: viewModel)

						NotesForm(viewModel: viewModel)
					}
					.padding()
				}

                DinotisPrimaryButton(
                    text: LocalizableText.nextLabel,
                    type: .adaptiveScreen,
                    textColor: .DinotisDefault.white,
                    bgColor: .DinotisDefault.primary
                ) {
                    UIApplication.shared.endEditing()
                    viewModel.isPresent = true
                }
				.padding()
				.background(
					Color.white
						.edgesIgnoringSafeArea(.bottom)
				)

            }
            .onAppear {
                viewModel.onScreenAppear()
            }
      
      DinotisLoadingView(.fullscreen, hide: !viewModel.isLoading)
		}
		.navigationBarHidden(true)
		.navigationBarTitle("")
        .dinotisAlert(
            isPresent: $viewModel.isError,
            title: LocalizableText.attentionText,
            isError: true,
            message: viewModel.error.orEmpty(),
            primaryButton: .init(
                text: LocalizableText.okText,
                action: {}
            )
        )
        .dinotisAlert(
          isPresent: $viewModel.isShowAlert,
          title: viewModel.alert.title,
          isError: viewModel.alert.isError,
          message: viewModel.alert.message,
          primaryButton: viewModel.alert.primaryButton,
          secondaryButton: viewModel.alert.secondaryButton
        )
        .sheet(
            isPresented: $viewModel.isPresent,
            content: {
				if #available(iOS 16.0, *) {
					DetailOrderSheetView(viewModel: viewModel)
						.padding()
						.padding(.vertical)
                        .presentationDetents([.height(450), .large])
                        .dynamicTypeSize(.large)
				} else {
					DetailOrderSheetView(viewModel: viewModel)
						.padding()
						.padding(.vertical)
                        .dynamicTypeSize(.large)
				}
            }
        )
        .sheet(
            isPresented: $viewModel.showPaymentMenu,
            content: {
				if #available(iOS 16.0, *) {
					PaymentTypeOption(viewModel: viewModel)
						.padding(.top)
                        .padding(.horizontal)
                        .presentationDetents([.height(240)])
                        .dynamicTypeSize(.large)
				} else {
					PaymentTypeOption(viewModel: viewModel)
						.padding(.top)
                        .padding(.horizontal)
                        .dynamicTypeSize(.large)
				}

            }
        )
        .sheet(
            isPresented: $viewModel.isShowCoinPayment,
            onDismiss: {
                viewModel.resetStateCode()
            },
            content: {
				if #available(iOS 16.0, *) {
					CoinPaymentSheetView(viewModel: viewModel)
						.padding()
						.padding(.top)
                        .presentationDetents([.height(550), .large])
                        .dynamicTypeSize(.large)
				} else {
					CoinPaymentSheetView(viewModel: viewModel)
						.padding()
						.padding(.vertical)
                        .dynamicTypeSize(.large)
				}
            }
        )
        .sheet(
            isPresented: $viewModel.showAddCoin,
            content: {
				if #available(iOS 16.0, *) {
					AddCoinSheetView(viewModel: viewModel)
						.padding()
						.padding(.top)
						.presentationDetents([.height(400), .large])
                        .dynamicTypeSize(.large)
				} else {
					AddCoinSheetView(viewModel: viewModel)
						.padding()
						.padding(.top)
                        .dynamicTypeSize(.large)
				}
            }
        )
    }
}

extension RateCardServiceBookingView {

	struct TitleDescriptionForm: View {

		@ObservedObject var viewModel: RateCardServiceBookingFormViewModel

		var body: some View {
			VStack(alignment: .leading, spacing: 12) {
				HStack {
                    DinotisImageLoader(urlString: viewModel.talentPhoto, width: 40, height: 40)
                        .clipShape(Circle())

                    Text(viewModel.talentName)
                        .font(.robotoBold(size: 14))
						.foregroundColor(.black)
                    
                    Image.sessionCardVerifiedIcon
                        .resizable()
                        .scaledToFit()
                        .frame(height: 16)

					Spacer()
				}

				VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.rateCard.title.orEmpty())
						.font(.robotoBold(size: 14))
						.foregroundColor(.black)
						.multilineTextAlignment(.leading)
                        .lineLimit(3)
                    
                    VStack {
                        HStack {
                            Text(viewModel.rateCard.description.orEmpty())
                                .font(.robotoRegular(size: 12))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)
                                .lineLimit(viewModel.isTextComplete ? nil : 3)
                            
                            Spacer()
                        }
                        
                        HStack {
                            Button {
                                withAnimation {
                                    viewModel.isTextComplete.toggle()
                                }
                            } label: {
                                Text(viewModel.isTextComplete ? LocalizableText.bookingRateCardHideFullText : LocalizableText.bookingRateCardShowFullText)
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(.DinotisDefault.primary)
                            }
                            
                            Spacer()
                        }
                        .isHidden(
                            viewModel.rateCard.description.orEmpty().count < 150,
                            remove: viewModel.rateCard.description.orEmpty().count < 150
                        )
                    }
				}
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Image.sessionCardTimeSolidIcon
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18)
                        
                        Text(LocalizableText.minuteInDuration((viewModel.rateCard.duration).orZero()))
                            .font(.robotoRegular(size: 12))
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                    
                    HStack(spacing: 9) {
                        Image.sessionCardCameraIcon
                            .resizable()
                            .scaledToFit()
                            .frame(width: 21)
                        
                        Text(LocalizableText.privateVideoCallLabel)
                            .font(.robotoRegular(size: 12))
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                }
			}
            .padding(.horizontal)
			.padding(.vertical, 16)
			.background(
				RoundedRectangle(cornerRadius: 12)
					.foregroundColor(.white)
			)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
		}
	}

	struct NotesForm: View {

		@ObservedObject var viewModel: RateCardServiceBookingFormViewModel

		var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(LocalizableText.noteForCreatorSuggestTimeTitle)
                            .font(.robotoBold(size: 14))
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                    
                    Text(LocalizableText.noteForCreatorSuggestTimeSubtitle)
                        .font(.robotoMedium(size: 10))
                        .foregroundColor(.DinotisDefault.black3)
                    
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(LocalizableText.noteForCreatorDateTitle)
                                .font(.robotoRegular(size: 14))
                                .foregroundColor(.black)
                            
                            HStack {
                                Text(viewModel.dateSuggestion.toStringFormat(with: .slashddMMyyyy))
                                    .lineLimit(1)
                                    .font(.robotoRegular(size: 14))
                                    .foregroundColor(.black)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                                
                                Spacer()
                                
                                Image.sessionCardDateIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                                    .overlay(
                                        RoundedCorner(radius: 8, corners: [.topRight, .bottomRight])
                                            .stroke(Color.DinotisDefault.lightPrimaryActive, lineWidth: 1)
                                    )
                            }
                            .contentShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.DinotisDefault.lightPrimaryActive, lineWidth: 1)
                            )
                            .onTapGesture {
                                viewModel.isShowDatePicker.toggle()
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            
                            Text(LocalizableText.noteForCreatorTimeTitle)
                                .font(.robotoRegular(size: 14))
                                .foregroundColor(.black)
                            
                            HStack {
                                Text(viewModel.dateSuggestion.toStringFormat(with: .HHmm))
                                    .font(.robotoRegular(size: 14))
                                    .lineLimit(1)
                                    .foregroundColor(.black)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                                
                                Spacer()
                                
                                Image.sessionCardTimeSolidIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                                    .overlay(
                                        RoundedCorner(radius: 8, corners: [.topRight, .bottomRight])
                                            .stroke(Color.DinotisDefault.lightPrimaryActive, lineWidth: 1)
                                    )
                            }
                            .contentShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.DinotisDefault.lightPrimaryActive, lineWidth: 1)
                            )
                            .onTapGesture {
                                viewModel.isShowTimePicker.toggle()
                            }
                        }
                    }
                    
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image.sessionCardNotesSolidIcon
                            .resizable()
                            .scaledToFit()
                            .frame(height: 20)
                        
                        Text(LocalizableText.noteForCreatorTitle)
                            .font(.robotoBold(size: 14))
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                    
                    DinotisTextEditor(
                        LocalizableText.noteForCreatorPlaceholder,
                        label: nil,
                        text: $viewModel.noteText,
                        errorText: .constant(nil),
                        stroke: .DinotisDefault.lightPrimaryActive
                    )
                    .autocorrectionDisabled(true)
                    .autocapitalization(.none)
                    
                }
            }
            .padding(.horizontal)
			.padding(.vertical, 16)
            .multilineTextAlignment(.leading)
			.background(
				RoundedRectangle(cornerRadius: 12)
					.foregroundColor(.white)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
			)
            .sheet(isPresented: $viewModel.isShowDatePicker) {
                if #available(iOS 16.0, *) {
                    DatePickerSheet(viewModel: viewModel)
                    .presentationDetents([.medium])
                    .dynamicTypeSize(.large)
                } else {
                    DatePickerSheet(viewModel: viewModel)
                    .dynamicTypeSize(.large)
                }
            }
            .sheet(isPresented: $viewModel.isShowTimePicker) {
                if #available(iOS 16.0, *) {
                    TimePickerSheet(viewModel: viewModel)
                    .presentationDetents([.medium])
                    .dynamicTypeSize(.large)
                } else {
                    TimePickerSheet(viewModel: viewModel)
                    .dynamicTypeSize(.large)
                }
                
            }
		}
	}
    
    struct TimePickerSheet: View {
        @ObservedObject var viewModel: RateCardServiceBookingFormViewModel
        
        var body: some View {
            ZStack {
                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        
                        DatePicker("", selection: $viewModel.changedDateSuggestion, in: Date()..., displayedComponents: .hourAndMinute)
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden()
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.dateSuggestion = viewModel.changedDateSuggestion
                        viewModel.isShowTimePicker = false
                    }, label: {
                        HStack {
                            Spacer()
                            
                            Text(NSLocalizedString("select_text", comment: ""))
                                .foregroundColor(.white)
                                .font(.robotoMedium(size: 14))
                            
                            Spacer()
                        }
                        .padding(.vertical)
                        .background(Color.DinotisDefault.primary)
                    })
                    .clipShape(RoundedRectangle(cornerRadius: 8.0))
                    .onAppear {
                        viewModel.changedDateSuggestion = viewModel.dateSuggestion
                    }
                }
                .padding()
            }
        }
    }
    
    struct DatePickerSheet: View {
        @ObservedObject var viewModel: RateCardServiceBookingFormViewModel
        
        var body: some View {
            ZStack {
                VStack(alignment: .center, spacing: 0) {
                    DatePicker("", selection: $viewModel.changedDateSuggestion, in: Date()..., displayedComponents: .date)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.dateSuggestion = viewModel.changedDateSuggestion
                        viewModel.isShowDatePicker = false
                    }, label: {
                        HStack {
                            Spacer()
                            
                            Text(NSLocalizedString("select_text", comment: ""))
                                .foregroundColor(.white)
                                .font(.robotoMedium(size: 14))
                            
                            Spacer()
                        }
                        .padding(.vertical)
                        .background(Color.DinotisDefault.primary)
                    })
                    .clipShape(RoundedRectangle(cornerRadius: 8.0))
                }
                .padding()
                .onAppear {
                    viewModel.changedDateSuggestion = viewModel.dateSuggestion
                }
            }
        }
    }

	struct DetailOrderSheetView: View {

		@ObservedObject var viewModel: RateCardServiceBookingFormViewModel

		var body: some View {
            VStack {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(spacing: 12) {
                            HStack(spacing: 16) {
                                DinotisImageLoader(
                                    urlString: viewModel.talentPhoto,
                                    width: 40,
                                    height: 40
                                )
                                .clipShape(Circle())
                                
                                HStack {
                                    Text(viewModel.talentName)
                                        .font(.robotoBold(size: 14))
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.leading)
                                    
                                    Image.sessionCardVerifiedIcon
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 16)
                                }
                                
                                Spacer()
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(viewModel.rateCard.title.orEmpty())
                                        .font(.robotoBold(size: 14))
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(viewModel.rateCard.description.orEmpty())
                                        .font(.robotoRegular(size: 12))
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(viewModel.isDescComplete ? nil : 3)
                                    
                                    Button {
                                        withAnimation {
                                            viewModel.isDescComplete.toggle()
                                        }
                                    } label: {
                                        Text(viewModel.isDescComplete ? LocalizableText.bookingRateCardHideFullText : LocalizableText.bookingRateCardShowFullText)
                                            .font(.robotoBold(size: 12))
                                            .foregroundColor(.DinotisDefault.primary)
                                    }
                                    .isHidden(
                                        viewModel.rateCard.description.orEmpty().count < 150,
                                        remove: viewModel.rateCard.description.orEmpty().count < 150
                                    )
                                }
                            }
                        }
                        
                        VStack(spacing: 10) {
                            HStack(spacing: 10) {
                                Image.sessionCardDateIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 17)
                                
                                Text(LocalizableText.unconfirmedText)
                                    .font(.robotoRegular(size: 12))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                            }
                            
                            HStack(spacing: 10) {
                                Image.sessionCardTimeSolidIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 17)
                                
                                Text(LocalizableText.minuteInDuration((viewModel.rateCard.duration).orZero()))
                                    .font(.robotoRegular(size: 12))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                            }
                            
                            HStack(spacing: 10) {
                                Image.sessionCardPersonSolidIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 17)
                                
                                Text("1 \(LocalizableText.participant)")
                                    .font(.robotoRegular(size: 12))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.leading)
                                
                                Text(LocalizableText.limitedQuotaLabelWithEmoji)
                                    .font(.robotoBold(size: 10))
                                    .foregroundColor(.DinotisDefault.red)
                                    .padding(.vertical, 5)
                                    .padding(.horizontal, 8)
                                    .background(Color.DinotisDefault.red.opacity(0.1))
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.DinotisDefault.red, lineWidth: 1.0)
                                    )
                                
                                Spacer()
                            }
                        }
                        
                        Divider()
                        
                        HStack {
                            Text(LocalizableText.priceLabel)
                                .font(.robotoRegular(size: 12))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Text((viewModel.rateCard.price.orEmpty()).toCurrency())
                                .font(.robotoBold(size: 16))
                                .foregroundColor(.black)
                        }
                    }
                }
                
                Spacer()
                
                HStack(spacing: 15) {
                    DinotisSecondaryButton(
                        text: LocalizableText.cancelLabel,
                        type: .adaptiveScreen,
                        textColor: .DinotisDefault.black1,
                        bgColor: .DinotisDefault.lightPrimary,
                        strokeColor: .DinotisDefault.primary) {
                            viewModel.isPresent = false
                        }
                    
                    DinotisPrimaryButton(
                        text: LocalizableText.payLabel,
                        type: .adaptiveScreen,
                        textColor: .white,
                        bgColor: .DinotisDefault.primary) {
                            if viewModel.rateCard.price == nil ||
                                viewModel.rateCard.price.orEmpty() == "" ||
                                viewModel.rateCard.price.orEmpty() == "0"
                            {
                                Task {
                                    viewModel.isPresent = false
                                    await viewModel.coinPayment(99)
                                }
                            } else {
                                viewModel.isPresent = false
                                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                                    withAnimation {
                                        viewModel.showPaymentMenu = true
                                    }
                                }
                            }
                        }
                    
                }
                .padding(.top)
            }
            .onDisappear {
                viewModel.isDescComplete = false
            }
		}
	}
    
    struct PaymentTypeOption: View {
        @ObservedObject var viewModel: RateCardServiceBookingFormViewModel
        
        var body: some View {
            VStack(spacing: 16) {
                HStack {
                    Text(LocalizableText.paymentMethodLabel)
                        .font(.robotoBold(size: 14))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button {
                        viewModel.showPaymentMenu = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20)
                            .foregroundColor(Color(UIColor.systemGray4))
                    }
                }
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        Button {
                            DispatchQueue.main.async {
                                viewModel.showPaymentMenu.toggle()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                                withAnimation {
                                    Task {
                                        await viewModel.extraFees()
                                    }
                                    
                                    viewModel.isShowCoinPayment.toggle()
                                }
                            }
                        } label: {
                            HStack(spacing: 15) {
                                Image.paymentAppleIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 28)
                                    .foregroundColor(.DinotisDefault.primary)
                                
                                Text(LocalizableText.inAppPurchaseLabel)
                                    .font(.robotoBold(size: 12))
                                    .foregroundColor(.DinotisDefault.primary)
                                
                                Spacer()
                                
                                Image.sessionDetailChevronIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 37)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundColor(.DinotisDefault.lightPrimary)
                            )
                        }
                        
                        Button {
                            viewModel.showPaymentMenu.toggle()
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                                withAnimation {
                                    viewModel.routeToPaymentMethod(price: viewModel.rateCard.price.orEmpty(), rateCardId: viewModel.rateCard.id.orEmpty())
                                }
                            }
                        } label: {
                            HStack(spacing: 15) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(LocalizableText.otherPaymentMethodTitle)
                                        .font(.robotoBold(size: 12))
                                    
                                    Text(LocalizableText.otherPaymentMethodDescription)
                                        .font(.robotoRegular(size: 10))
                                }
                                .foregroundColor(.DinotisDefault.primary)
                                
                                Spacer()
                                
                                Image.sessionDetailChevronIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 37)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundColor(.DinotisDefault.lightPrimary)
                            )
                        }
                    }
                }
            }
        }
    }
    
    struct AddCoinSheetView: View {
        
        @ObservedObject var viewModel: RateCardServiceBookingFormViewModel
        
        var body: some View {
            VStack(spacing: 20) {
                
                HStack {
                    Text(LocalizableText.addCoinLabel)
                        .font(.robotoBold(size: 14))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button {
                        viewModel.showAddCoin.toggle()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20)
                            .foregroundColor(Color(UIColor.systemGray4))
                    }
                }
                
                VStack {
                    Text(LocalizableText.yourCoinLabel)
                        .font(.robotoRegular(size: 12))
                        .foregroundColor(.black)
                    
                    HStack(alignment: .top) {
                        Image.coinBalanceIcon
                            .resizable()
                            .scaledToFit()
                            .frame(height: 20)
                        
                        Text("\((viewModel.userData?.coinBalance?.current).orEmpty())")
                            .font(.robotoBold(size: 14))
                            .foregroundColor(.DinotisDefault.primary)
                    }
                    .multilineTextAlignment(.center)
                    
                    Text(LocalizableText.descriptionAddCoin)
                        .font(.robotoRegular(size: 10))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                }
                
                VStack {
                    if viewModel.isLoadingTrx {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        QGrid(viewModel.myProducts, columns: 4, vSpacing: 10, hSpacing: 10, vPadding: 5, hPadding: 5, isScrollable: false, showScrollIndicators: false) { item in
                            
                            Button {
                                viewModel.productSelected = item
                            } label: {
                                HStack {
                                    Spacer()
                                    
                                    Text(item.priceToString())
                                        .font(.robotoMedium(size: 12))
                                        .foregroundColor(.DinotisDefault.primary)
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .foregroundColor((viewModel.productSelected ?? SKProduct()).id == item.id ? .DinotisDefault.lightPrimary : .clear)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.DinotisDefault.primary, lineWidth: 1)
                                )
                            }
                        }
                    }
                }
                .frame(height: 90)
                
                Spacer()
                
                VStack {
                    DinotisPrimaryButton(
                        text: LocalizableText.addCoinLabel,
                        type: .adaptiveScreen,
                        textColor: viewModel.isLoadingTrx || viewModel.productSelected == nil ? .DinotisDefault.lightPrimaryActive : .white,
                        bgColor: viewModel.isLoadingTrx || viewModel.productSelected == nil ? .DinotisDefault.lightPrimary : .DinotisDefault.primary
                    ) {
                        if let product = viewModel.productSelected {
                            viewModel.purchaseProduct(product: product)
                        }
                    }
                    .disabled(viewModel.isLoadingTrx || viewModel.productSelected == nil)
                    
                    DinotisSecondaryButton(
                        text: LocalizableText.helpLabel,
                        type: .adaptiveScreen,
                        textColor: viewModel.isLoadingTrx ? .white : .DinotisDefault.primary,
                        bgColor: viewModel.isLoadingTrx ? Color(UIColor.systemGray3) : .DinotisDefault.lightPrimary,
                        strokeColor: .DinotisDefault.primary) {
                            viewModel.openWhatsApp()
                        }
                        .disabled(viewModel.isLoadingTrx)
                }
            }
        }
    }
    
    struct CoinPaymentSheetView: View {
        
        @ObservedObject var viewModel: RateCardServiceBookingFormViewModel
        
        var body: some View {
            VStack(spacing: 15) {
                HStack {
                    Text(LocalizableText.paymentConfirmationTitle)
                        .font(.robotoBold(size: 14))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button {
                        viewModel.isShowCoinPayment = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20)
                            .foregroundColor(Color(UIColor.systemGray4))
                    }
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(LocalizableText.yourCoinLabel)
                            .font(.robotoBold(size: 12))
                            .foregroundColor(.black)
                        
                        HStack(alignment: .top) {
                            Image.coinBalanceIcon
                                .resizable()
                                .scaledToFit()
                                .frame(height: 15)
                            
                            Text("\((viewModel.userData?.coinBalance?.current).orEmpty())")
                                .font(.robotoBold(size: 14))
                                .foregroundColor((Int(viewModel.userData?.coinBalance?.current ?? "0") ?? 0) >= viewModel.totalPayment ? .DinotisDefault.primary : .DinotisDefault.red)
                        }
                    }
                    
                    Spacer()
                    
                    if (Int(viewModel.userData?.coinBalance?.current ?? "0") ?? 0) < viewModel.totalPayment {
                        Button {
                            DispatchQueue.main.async {
                                viewModel.isShowCoinPayment.toggle()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                                viewModel.showAddCoin.toggle()
                            }
                        } label: {
                            Text(LocalizableText.addCoinLabel)
                                .font(.robotoMedium(size: 12))
                                .foregroundColor(.DinotisDefault.primary)
                                .padding(15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.DinotisDefault.primary, lineWidth: 1)
                                )
                        }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).foregroundColor(.DinotisDefault.lightPrimary))
                
                VStack(alignment: .leading) {
                    Text(LocalizableText.promoCodeTitle)
                        .font(.robotoBold(size: 12))
                        .foregroundColor(.black)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Group {
                                if viewModel.promoCodeSuccess {
                                    HStack {
                                        Text(viewModel.promoCode)
                                            .font(.robotoMedium(size: 12))
                                            .foregroundColor(viewModel.promoCodeSuccess ? Color(.systemGray) : .black)
                                        
                                        Spacer()
                                    }
                                } else {
                                    TextField(LocalizableText.promoCodeLabel, text: $viewModel.promoCode)
                                        .font(.robotoMedium(size: 12))
                                        .autocapitalization(.allCharacters)
                                        .disableAutocorrection(true)
                                }
                            }
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(UIColor.systemGray3), lineWidth: 1)
                            )
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(viewModel.promoCodeSuccess ? Color(.systemGray5) : .white)
                            )
                            
                            Button {
                                if viewModel.promoCodeData != nil {
                                    viewModel.resetStateCode()
                                } else {
									Task {
										await viewModel.checkPromoCode()
									}
                                }
                            } label: {
                                HStack {
                                    Text(viewModel.promoCodeSuccess ? LocalizableText.changeLabel : LocalizableText.enterLabel)
                                        .font(.robotoBold(size: 12))
                                        .foregroundColor(viewModel.promoCode.isEmpty ? Color(.systemGray2) : .white)
                                }
                                .padding()
                                .padding(.horizontal, 5)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .foregroundColor(viewModel.promoCodeSuccess ? .red : (viewModel.promoCode.isEmpty ? Color(.systemGray5) : .DinotisDefault.primary))
                                )
                                
                            }
                            .disabled(viewModel.promoCode.isEmpty)
                            
                        }
                        
                        if viewModel.promoCodeError {
                            HStack {
                                Image.talentProfileAttentionIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 10)
                                    .foregroundColor(.red)
                                Text(LocalizableText.paymentPromoNotFound)
                                    .font(.robotoRegular(size: 10))
                                    .foregroundColor(.red)
                                
                                Spacer()
                            }
                        }
                        
                        if !viewModel.promoCodeTextArray.isEmpty {
                            ForEach(viewModel.promoCodeTextArray, id: \.self) { item in
                                Text(item)
                                    .font(.robotoMedium(size: 10))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).foregroundColor(.DinotisDefault.lightPrimary))
                
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(LocalizableText.paymentLabel)
                            
                            Spacer()
                            
                            Text(LocalizableText.applePayText)
                        }
                        
                        HStack {
                            Text(LocalizableText.feeSubTotalLabel)
                            
                            Spacer()
                            
                            Text("\(Int(viewModel.rateCard.price.orEmpty()).orZero())".toCurrency())
                        }
                        
                        HStack {
                            Text(LocalizableText.feeApplication)
                            
                            Spacer()
                            
                            Text("\(viewModel.extraFee)".toCurrency())
                                
                        }
                        
                        HStack {
                            Text(LocalizableText.feeService)
                            
                            Spacer()
                            
                            Text("0".toCurrency())
                                
                        }
                    }
                    .font(.robotoMedium(size: 12))
                    .foregroundColor(.black)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        
                        if (viewModel.promoCodeData?.discountTotal).orZero() != 0 {
                            HStack {
                                Text(LocalizableText.discountLabel)
                                    .font(.robotoMedium(size: 10))
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Text("-\((viewModel.promoCodeData?.discountTotal).orZero())".toCurrency())
                                    .font(.robotoMedium(size: 10))
                                    .foregroundColor(.red)
                            }
                        } else if (viewModel.promoCodeData?.amount).orZero() != 0 && (viewModel.promoCodeData?.discountTotal).orZero() == 0 {
                            HStack {
                                Text(LocalizableText.discountLabel)
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Text("-\((viewModel.promoCodeData?.amount).orZero())".toCurrency())
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(.bottom)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 1.5)
                        .foregroundColor(.DinotisDefault.primary)
                    
                    HStack {
                        Text(LocalizableText.totalLabel)
                            .font(.robotoBold(size: 12))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Text("\(viewModel.totalPayment)")
                            .font(.robotoBold(size: 12))
                            .foregroundColor(.black)
                    }
                    
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).foregroundColor(.DinotisDefault.lightPrimary))
                
                Spacer()
                
                DinotisPrimaryButton(
                    text: LocalizableText.continuePaymentLabel,
                    type: .adaptiveScreen,
                    textColor: (Int(viewModel.userData?.coinBalance?.current ?? "0") ?? 0) < viewModel.totalPayment ? Color(.systemGray) : .white,
                    bgColor: (Int(viewModel.userData?.coinBalance?.current ?? "0") ?? 0) < viewModel.totalPayment ? Color(.systemGray4) : .DinotisDefault.primary,
                    isLoading: $viewModel.isLoadingCoinPay
                ) {
						Task {
							await viewModel.coinPayment()
						}
                    }
                    .disabled((Int(viewModel.userData?.coinBalance?.current ?? "0") ?? 0) < viewModel.totalPayment || viewModel.isLoadingCoinPay)
            }
            .onAppear {
                viewModel.getProductOnAppear()
            }
        }
    }
}

struct RateCardServiceBookingView_Previews: PreviewProvider {
    static var previews: some View {
        RateCardServiceBookingView(viewModel: RateCardServiceBookingFormViewModel(backToHome: {}), mainTabValue: .constant(.agenda))
    }
}
