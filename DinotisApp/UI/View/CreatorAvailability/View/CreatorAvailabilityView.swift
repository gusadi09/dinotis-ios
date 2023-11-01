//
//  CreatorAvailabilityView.swift
//  DinotisApp
//
//  Created by Irham Naufal on 26/10/23.
//

import SwiftUI
import DinotisDesignSystem

struct CreatorAvailabilityView: View {
    
    @ObservedObject var viewModel: CreatorAvailabilityViewModel
    @Environment(\.dismiss) var dismiss
    
    init(viewModel: CreatorAvailabilityViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(
                type: .textHeader,
                title: LocalizableText.profileAvailabilityLabel,
                headerColor: .clear,
                textColor: .DinotisDefault.black1,
                leadingButton:  {
                    Button {
                        dismiss()
                    } label: {
                        Image.generalBackIcon
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(.white)
                                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 0)
                            )
                    }
                })
            
            ScrollView {
                VStack {
                    Button {
                        viewModel.isShowSubscriptionSheet = true
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 6, content: {
                                Text(LocalizableText.profileSetSubscriptionTitle)
                                    .font(.robotoBold(size: 16))
                                    .foregroundColor(.DinotisDefault.black1)
                                
                                Text(LocalizableText.profileSetSubscriptionDesc)
                                    .font(.robotoRegular(size: 12))
                                    .foregroundColor(.DinotisDefault.black3)
                            })
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 20, weight: .heavy))
                                .foregroundColor(.DinotisDefault.black1)
                        }
                        .padding(.vertical, 24)
                        .padding(.horizontal, 18)
                        .background(.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .inset(by: 0.5)
                                .stroke(Color(red: 0.91, green: 0.91, blue: 0.91), lineWidth: 1)
                            
                        )
                    }
                }
                .padding()
            }
        }
        .background(Color.DinotisDefault.baseBackground.ignoresSafeArea())
        .navigationBarTitle(Text(""))
        .navigationBarHidden(true)
        .sheet(isPresented: $viewModel.isShowSubscriptionSheet, content: {
            if #available(iOS 16.0, *) {
                SetSubscriptionView()
                    .presentationDetents([.height(460), .fraction(0.99)])
                    .presentationDragIndicator(.hidden)
            } else {
                SetSubscriptionView()
            }
        })
        
    }
}

extension CreatorAvailabilityView {
    
    @ViewBuilder
    func SetSubscriptionView() -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(LocalizableText.profileSetSubscriptionTitle)
                    .font(.robotoBold(size: 16))
                    .foregroundColor(.DinotisDefault.black1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button {
                    viewModel.isShowSubscriptionSheet = false
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.DinotisDefault.black2)
                }
            }
            .padding()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(LocalizableText.profileActivateSubscriptionTitle)
                            .font(.robotoBold(size: 16))
                            .foregroundColor(.DinotisDefault.black1)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Toggle("", isOn: $viewModel.hasSetSubscription)
                            .labelsHidden()
                            .tint(Color.DinotisDefault.green)
                    }
                    .padding(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .inset(by: 0.5)
                            .stroke(Color(red: 0.91, green: 0.91, blue: 0.91), lineWidth: 1)
                        
                    )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 10) {
                            Image.sessionCardPersonSolidIcon
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            
                            Text(LocalizableText.profileSelectSubscriptionTypeTitle)
                                .font(.robotoBold(size: 16))
                                .foregroundColor(.DinotisDefault.black1)
                                .multilineTextAlignment(.leading)
                        }
                        
                        Menu {
                            Button(LocalizableText.subscriptionPaidMonthly) {
                                withAnimation {
                                    viewModel.subscriptionType = .monthly
                                }
                            }
                            
                            Button(LocalizableText.subscriptionPaidFree) {
                                withAnimation {
                                    viewModel.subscriptionType = .free
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(viewModel.subscriptionTypeText)
                                    .font(.robotoRegular(size: 12))
                                    .foregroundColor(viewModel.subscriptionType == nil ? .DinotisDefault.black3 : .DinotisDefault.black1)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.DinotisDefault.black1)
                            }
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .inset(by: 0.5)
                                    .stroke(Color(red: 0.91, green: 0.91, blue: 0.91), lineWidth: 1)
                            )
                        }
                    }
                    .disabled(!viewModel.hasSetSubscription)
                    .opacity(viewModel.hasSetSubscription ? 1 : 0.5)
                    
                    if viewModel.subscriptionType == .monthly {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 10) {
                                Image.sessionCardCoinYellowPurpleIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                
                                Text(LocalizableText.profileSetCostTitle)
                                    .font(.robotoBold(size: 16))
                                    .foregroundColor(.DinotisDefault.black1)
                                    .multilineTextAlignment(.leading)
                            }
                            
                            HStack(spacing: 8) {
                                Text("Rp")
                                    .font(.robotoBold(size: 14))
                                    .foregroundColor(.DinotisDefault.black1)
                                
                                TextField("10.000", text: $viewModel.subscriptionAmount)
                                    .font(.robotoRegular(size: 12))
                                    .foregroundColor(viewModel.subscriptionType == nil ? .DinotisDefault.black3 : .DinotisDefault.black1)
                                    .autocorrectionDisabled()
                                    .keyboardType(.numberPad)
                                    .tint(Color.DinotisDefault.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .onChange(of: viewModel.subscriptionAmount) { newValue in
                                        viewModel.checkZeroAtFirst(newValue)
                                    }
                                
                                Text("/\(LocalizableText.monthLabel)")
                                    .font(.robotoBold(size: 14))
                                    .foregroundColor(.DinotisDefault.primary)
                            }
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .inset(by: 0.5)
                                    .stroke(Color(red: 0.91, green: 0.91, blue: 0.91), lineWidth: 1)
                            )
                            
                            Text(LocalizableText.profileSetCostDesc)
                                .font(.robotoRegular(size: 12))
                                .foregroundColor(.DinotisDefault.black3)
                                .multilineTextAlignment(.leading)
                        }
                        .disabled(!viewModel.hasSetSubscription)
                        .opacity(viewModel.hasSetSubscription ? 1 : 0.5)
                    }
                }
                .padding(.horizontal)
            }
            
            DinotisPrimaryButton(
                text: LocalizableText.saveLabel,
                type: .adaptiveScreen,
                textColor: .white,
                bgColor: .DinotisDefault.primary
            ) {
                viewModel.isShowSubscriptionSheet = false
            }
            .padding()
        }
        .padding(.vertical)
    }
}

#Preview {
    CreatorAvailabilityView(viewModel: .init(backToHome: {}))
}
