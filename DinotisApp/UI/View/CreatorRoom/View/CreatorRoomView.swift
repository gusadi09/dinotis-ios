//
//  CreatorRoomView.swift
//  DinotisApp
//
//  Created by Irham Naufal on 25/01/24.
//

import DinotisDesignSystem
import SwiftUI
import SwiftUINavigation

struct CreatorRoomView: View {
    
    @EnvironmentObject var viewModel: CreatorRoomViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        LazyVStack(spacing: 0) {
            NavigationLink(
                unwrapping: $viewModel.route,
                case: /HomeRouting.editTalentProfile,
                destination: { viewModel in
                    TalentEditProfile(profesionSelect: $viewModel.profesionSelect, viewModel: viewModel.wrappedValue)
                },
                onNavigate: {_ in},
                label: {
                    EmptyView()
                }
            )
            
            HeaderView(
                type: .textHeader,
                title: LocalizableText.creatorRoomLabel,
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
                                    .shadow(color: .black.opacity(0.03), radius: 5)
                            )
                    }
                }
            )
            
            LazyVStack {
                HStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(LocalizableText.activateCreatorModeTitle)
                            .font(.robotoBold(size: 16))
                            .foregroundColor(.DinotisDefault.black1)
                        
                        Text(LocalizableText.activateCreatorModeDesc)
                            .font(.robotoRegular(size: 12))
                            .foregroundColor(.DinotisDefault.black3)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Toggle("", isOn: $viewModel.isCreatorModeActive)
                        .labelsHidden()
                        .tint(Color.DinotisDefault.green)
                        .onChange(of: viewModel.isCreatorModeActive) { newValue in
                            viewModel.isShowCompleteProfileSheet = newValue == true ? newValue : viewModel.isShowCompleteProfileSheet
                        }
                }
                .padding(16)
                .background(.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .inset(by: 0.5)
                        .stroke(Color.DinotisDefault.grayDinotis, lineWidth: 1)
                )
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.DinotisDefault.baseBackground.ignoresSafeArea())
        .navigationBarTitle(Text(""))
        .navigationBarHidden(true)
        .sheet(isPresented: $viewModel.isShowCompleteProfileSheet, content: {
            if #available(iOS 16.0, *) {
                CompleteProfileSheet()
                    .presentationDetents([.height(390)])
                    .presentationDragIndicator(.hidden)
            } else {
                CompleteProfileSheet()
            }
        })
    }
}

extension CreatorRoomView {
    @ViewBuilder
    func CompleteProfileSheet() -> some View {
        VStack(spacing: 24) {
            Image.loginCreatorImage
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 360)
                .padding(.horizontal, 24)
            
            VStack(spacing: 7) {
                Text(LocalizableText.completeProfileTitle)
                    .font(.robotoBold(size: 18))
                
                Text(LocalizableText.completeProfileDesc)
                    .font(.robotoRegular(size: 14))
            }
            .multilineTextAlignment(.center)
            .foregroundColor(.DinotisDefault.black1)
            
            DinotisPrimaryButton(
                text: LocalizableText.changeNowLabel,
                type: .adaptiveScreen,
                textColor: .white,
                bgColor: .DinotisDefault.primary
            ) {
                viewModel.routeToEditProfile()
            }
        }
        .padding()
    }
}

fileprivate struct Preview: View {
    
    init() {
        FontInjector.registerFonts()
    }
    
    var body: some View {
        CreatorRoomView()
            .environmentObject(CreatorRoomViewModel(profesionSelect: [], backToHome: {}))
    }
}

#Preview {
    Preview()
}
