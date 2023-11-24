//
//  ScheduleFormView+Component.swift
//  DinotisApp
//
//  Created by Gus Adi on 19/10/23.
//

import DinotisData
import DinotisDesignSystem
import SwiftUI

extension ScheduledFormView {
    struct SetupAppUsageFaresSheetView: View {
        
        @EnvironmentObject var viewModel: ScheduledFormViewModel
        
        var body: some View {
            ZStack {
                VStack(alignment: .center, spacing: 19, content: {
                    Text(LocalizableText.manageAppUsageCostsTitle)
                        .font(.robotoBold(size: 14))
                        .foregroundColor(.DinotisDefault.black1)
                    
                    VStack(alignment: .center, spacing: 16, content: {
                        VStack(content: {
                            VStack(alignment: .leading, content: {
                                HStack(alignment: .top, spacing: 5) {
                                    if let attr = try? AttributedString(markdown: LocalizableText.costCalculatedSubtitle(fee: "\(viewModel.fee)".toDecimal())) {
                                        Text(attr)
                                            .font(.robotoRegular(size: 12))
                                            .foregroundColor(.DinotisDefault.black1)
                                            .multilineTextAlignment(.leading)
                                    }
                                    
                                    Button {
                                        withAnimation {
                                            viewModel.isShowFirstTooltip = true
                                        }
                                        
                                    } label: {
                                        Image.videoCallHelpCircle
                                            .renderingMode(.template)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 14)
                                            .foregroundColor(.DinotisDefault.primary)
                                    }
                                }
                                
                                if !viewModel.isShowSeconTooltip {
                                    HStack(content: {
                                        HStack(spacing: 0) {
                                            Text(LocalizableText.audienceTitle)
                                                .font(.robotoRegular(size: 14))
                                                .foregroundColor(.DinotisDefault.black3)
                                            
                                            TextField("0", text: $viewModel.percentageString, onEditingChanged: { value in
                                                viewModel.isFreeTextUsed = value
                                                viewModel.isSliderUsed = false
                                            })
                                            .font(.robotoBold(size: 14))
                                            .foregroundColor(.DinotisDefault.primary)
                                            .multilineTextAlignment(.trailing)
                                            .keyboardType(.numberPad)
                                            .onChange(of: viewModel.percentageString, perform: { value in
                                                if viewModel.isFreeTextUsed {
                                                    viewModel.percentageRaw = Double(Int(value).orZero()/100)
                                                }
                                            })
                                            .disabled(true)
                                            
                                            Text("%")
                                                .font(.robotoBold(size: 14))
                                                .foregroundColor(.DinotisDefault.primary)
                                        }
                                        .padding(.vertical, 15)
                                        .padding(.horizontal, 8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(Color(red: 0.89, green: 0.91, blue: 0.94), lineWidth: 1.0)
                                        )
                                        
                                        HStack(spacing: 0) {
                                            Text(LocalizableText.creatorTitle)
                                                .font(.robotoRegular(size: 14))
                                                .foregroundColor(.DinotisDefault.black3)
                                            
                                            Spacer()
                                            
                                            Text("\(viewModel.percentageFaresForCreatorStr)")
                                                .font(.robotoBold(size: 14))
                                                .foregroundColor(.DinotisDefault.black3)
                                                .multilineTextAlignment(.trailing)
                                                .keyboardType(.numberPad)
                                                .onChange(of: viewModel.percentageString, perform: { value in
                                                    let temp = ((viewModel.percentageFaresForCreatorRaw*100)-(Double(value).orZero()))/100
                                                    viewModel.percentageFaresForCreator = temp
                                                    viewModel.percentageFaresForCreatorStr = "\(Int(viewModel.percentageFaresForCreator*100))"
                                                })
                                            
                                            Text("%")
                                                .font(.robotoBold(size: 14))
                                                .foregroundColor(.DinotisDefault.black3)
                                        }
                                        .padding(.vertical, 15)
                                        .padding(.horizontal, 8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(Color(red: 0.89, green: 0.91, blue: 0.94), lineWidth: 1.0)
                                        )
                                    })
                                }
                            })
                            .padding(viewModel.isShowSeconTooltip ? 0 : 5)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .foregroundColor(.white)
                            )
                            .padding(.horizontal, 11)
                            .dinotisTooltip(
                                $viewModel.isShowFirstTooltip,
                                alignment: .bottom,
                                id: AppCostTip.first.value,
                                width: 250,
                                height: 95
                            ) {
                                if let attr = try? AttributedString(markdown: LocalizableText.appUsageCostCalculationTooltip(fee: "\(viewModel.fee)".toDecimal(), minute: "45", total: "\(viewModel.fee*45)".toDecimal())) {
                                    Text(attr)
                                        .font(.robotoRegular(size: 14))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                } else {
                                    Text(LocalizableText.appUsageCostCalculationTooltip(fee: "\(viewModel.fee)".toDecimal(), minute: "45", total: "\(viewModel.fee*45)".toDecimal()))
                                        .font(.robotoRegular(size: 14))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            .id(AppCostTip.first.value)
                            
                            VStack(content: {
                                if viewModel.isShowSeconTooltip {
                                    HStack(content: {
                                        HStack(spacing: 0) {
                                            Text(LocalizableText.audienceTitle)
                                                .font(.robotoRegular(size: 14))
                                                .foregroundColor(.DinotisDefault.black3)
                                            
                                            TextField("0", text: $viewModel.percentageString, onEditingChanged: { value in
                                                viewModel.isFreeTextUsed = value
                                            })
                                            .font(.robotoBold(size: 14))
                                            .foregroundColor(.DinotisDefault.primary)
                                            .multilineTextAlignment(.trailing)
                                            .keyboardType(.numberPad)
                                            .onChange(of: viewModel.percentageString, perform: { value in
                                                if viewModel.isFreeTextUsed {
                                                    viewModel.percentageRaw = Double(Int(value).orZero()/100)
                                                }
                                            })
                                            .disabled(true)
                                            
                                            Text("%")
                                                .font(.robotoBold(size: 14))
                                                .foregroundColor(.DinotisDefault.primary)
                                        }
                                        .padding(.vertical, 15)
                                        .padding(.horizontal, 8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(Color(red: 0.89, green: 0.91, blue: 0.94), lineWidth: 1.0)
                                        )
                                        
                                        HStack(spacing: 0) {
                                            Text(LocalizableText.creatorTitle)
                                                .font(.robotoRegular(size: 14))
                                                .foregroundColor(.DinotisDefault.black3)
                                            
                                            Spacer()
                                            
                                            Text("\(viewModel.percentageFaresForCreatorStr)")
                                                .font(.robotoBold(size: 14))
                                                .foregroundColor(.DinotisDefault.black3)
                                                .multilineTextAlignment(.trailing)
                                                .keyboardType(.numberPad)
                                                .onChange(of: viewModel.percentageString, perform: { value in
                                                    let temp = ((viewModel.percentageFaresForCreatorRaw*100)-(Double(value).orZero()))/100
                                                    viewModel.percentageFaresForCreator = temp
                                                    viewModel.percentageFaresForCreatorStr = "\(Int(viewModel.percentageFaresForCreator*100))"
                                                })
                                            
                                            Text("%")
                                                .font(.robotoBold(size: 14))
                                                .foregroundColor(.DinotisDefault.black3)
                                        }
                                        .padding(.vertical, 15)
                                        .padding(.horizontal, 8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(Color(red: 0.89, green: 0.91, blue: 0.94), lineWidth: 1.0)
                                        )
                                    })
                                }
                                
                                SliderView(value: $viewModel.percentageRaw, label: $viewModel.percentageString)
                                    .padding(.vertical, 3)
                                
                                HStack(alignment: .top, spacing: 5) {
                                    Text(LocalizableText.percentageBorneByAudience)
                                        .font(.robotoRegular(size: 12))
                                        .foregroundColor(.DinotisDefault.black3)
                                        .multilineTextAlignment(.center)
                                    
                                    Button {
                                        withAnimation {
                                            viewModel.isShowSeconTooltip.toggle()
                                        }
                                        
                                    } label: {
                                        Image.videoCallHelpCircle
                                            .renderingMode(.template)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 14)
                                            .foregroundColor(.DinotisDefault.primary)
                                    }
                                    
                                }
                            })
                            .padding(viewModel.isShowSeconTooltip ? 5 : 0)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .foregroundColor(.white)
                            )
                            .padding(.horizontal, 11)
                            .dinotisTooltip(
                                $viewModel.isShowSeconTooltip,
                                alignment: .bottom,
                                id: AppCostTip.two.value,
                                width: 245,
                                height: 90
                            ) {
                                if let attr = try? AttributedString(markdown: LocalizableText.appUsageCostsSliderTooltip) {
                                    Text(attr)
                                        .font(.robotoRegular(size: 14))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                } else {
                                    Text(LocalizableText.appUsageCostsSliderTooltip)
                                        .font(.robotoRegular(size: 14))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            .id(AppCostTip.two.value)
                        })
                        
                        Divider()
                            .frame(width: 106)
                            .padding(.horizontal, 16)
                        
                        VStack(spacing: 0) {
                            if viewModel.appUsageFareSheetHeight <= 460 {
                                VStack(spacing: 10) {
                                    HStack {
                                        Text(LocalizableText.estimatedAppUsageCosts)
                                            .font(.robotoRegular(size: 14))
                                            .fontWeight(.semibold)
                                            .foregroundColor(.DinotisDefault.black1)
                                            .multilineTextAlignment(.leading)
                                        
                                        Spacer()
                                        
                                        DinotisNudeButton(
                                            text: viewModel.appUsageFareSheetHeight <= 460 ? LocalizableText.seeDetailsLabel : LocalizableText.generalCloseDetails,
                                            textColor: .DinotisDefault.primary,
                                            fontSize: 12
                                        ) {
                                            withAnimation(.spring()) {
                                                if viewModel.appUsageFareSheetHeight <= 460 {
                                                    viewModel.appUsageFareSheetHeight = 600
                                                } else {
                                                    viewModel.appUsageFareSheetHeight = 460
                                                }
                                            }
                                        }
                                    }
                                    
                                    HStack {
                                        Text(LocalizableText.audienceCountLabel(count: Int(viewModel.peopleGroup).orZero()))
                                            .font(.robotoBold(size: 12))
                                            .foregroundColor(.DinotisDefault.black3)
                                            .multilineTextAlignment(.leading)
                                        
                                        Spacer()
                                        
                                        Text(viewModel.appUsageEstimated().toCurrency())
                                            .font(.robotoBold(size: 12))
                                            .foregroundColor(.DinotisDefault.black3)
                                            .multilineTextAlignment(.trailing)
                                        
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            } else {
                                VStack(spacing: 10) {
                                    HStack {
                                        Text(LocalizableText.estimatedAppUsageCosts)
                                            .font(.robotoRegular(size: 14))
                                            .fontWeight(.semibold)
                                            .foregroundColor(.DinotisDefault.black1)
                                            .multilineTextAlignment(.leading)
                                        
                                        Spacer()
                                        
                                        DinotisNudeButton(
                                            text: viewModel.appUsageFareSheetHeight <= 460 ? LocalizableText.seeDetailsLabel : LocalizableText.generalCloseDetails,
                                            textColor: .DinotisDefault.primary,
                                            fontSize: 12
                                        ) {
                                            withAnimation(.spring()) {
                                                if viewModel.appUsageFareSheetHeight <= 460 {
                                                    viewModel.appUsageFareSheetHeight = 600.0
                                                } else {
                                                    viewModel.appUsageFareSheetHeight = 460
                                                }
                                            }
                                        }
                                    }
                                    
                                    HStack {
                                        Text(LocalizableText.audienceCountLabel(count: Int(viewModel.peopleGroup).orZero()))
                                            .font(.robotoBold(size: 12))
                                            .foregroundColor(.DinotisDefault.black3)
                                            .multilineTextAlignment(.leading)
                                        
                                        Spacer()
                                        
                                        Text(viewModel.appUsageEstimated().toCurrency())
                                            .font(.robotoBold(size: 12))
                                            .foregroundColor(.DinotisDefault.black3)
                                            .multilineTextAlignment(.trailing)
                                        
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .overlay(
                                    RoundedCorner(radius: 12, corners: [.topLeft, .topRight])
                                        .stroke(Color(red: 0.91, green: 0.91, blue: 0.91), lineWidth: 1)
                                )
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        if let attr = try? AttributedString(markdown: LocalizableText.totalBorneByAudience(borne: viewModel.percentageString)) {
                                            Text(attr)
                                                .font(.robotoRegular(size: 12))
                                                .foregroundColor(.DinotisDefault.black2)
                                                .multilineTextAlignment(.leading)
                                        }
                                        
                                        Spacer()
                                        
                                        Text(viewModel.audienceBorne().toCurrency())
                                            .font(.robotoBold(size: 12))
                                            .foregroundColor(.DinotisDefault.black1)
                                            .multilineTextAlignment(.trailing)
                                    }
                                    .padding(.top, 16)
                                    
                                    if let attr = try? AttributedString(markdown: LocalizableText.totalBorneSubtitle(total: (viewModel.audienceBorne()/Double(viewModel.peopleGroup).orZero()).toCurrency())) {
                                        Text(attr)
                                            .font(.robotoRegular(size: 12))
                                            .foregroundColor(.DinotisDefault.black3)
                                            .multilineTextAlignment(.leading)
                                    }
                                    
                                    Divider()
                                        .padding(.bottom, 4)
                                    
                                    HStack {
                                        if let attr = try? AttributedString(markdown: LocalizableText.totalCostsBorneByCreator(total: viewModel.percentageFaresForCreatorStr)) {
                                            Text(attr)
                                                .font(.robotoRegular(size: 12))
                                                .foregroundColor(.DinotisDefault.black2)
                                                .multilineTextAlignment(.leading)
                                        }
                                        
                                        Spacer()
                                        
                                        Text(viewModel.creatorBorne().toCurrency())
                                            .font(.robotoBold(size: 12))
                                            .foregroundColor(.DinotisDefault.black1)
                                            .multilineTextAlignment(.trailing)
                                    }
                                    .padding(.bottom, 12)
                                    
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 0.91, green: 0.91, blue: 0.91), lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                        
                        Spacer()
                        
                        DinotisSecondaryButton(
                            text: LocalizableText.saveLabel,
                            type: .adaptiveScreen,
                            height: 44,
                            textColor: .DinotisDefault.primary,
                            bgColor: .white,
                            strokeColor: .DinotisDefault.primary
                        ) {
                            viewModel.isChangedCostManagement = true
                            viewModel.isShowAppCostsManagement = false
                        }
                        .padding(.horizontal, 16)
                    })
                })
                .padding(.vertical)
                .padding(.top)
                
                Color.black.opacity(0.1).edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            viewModel.isShowFirstTooltip = false
                            viewModel.isShowSeconTooltip = false
                        }
                    }
                    .isHidden(!viewModel.isShowFirstTooltip, remove: !viewModel.isShowFirstTooltip)
                
                Color.black.opacity(0.1).edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            viewModel.isShowFirstTooltip = false
                            viewModel.isShowSeconTooltip = false
                        }
                    }
                    .isHidden(!viewModel.isShowSeconTooltip, remove: !viewModel.isShowSeconTooltip)
            }
            .overlayPreferenceValue(BoundsPreference.self, alignment: .center, { value in
                if let preference = value.first(where: { item in
                    item.key == AppCostTip.two.value
                }), viewModel.isShowSeconTooltip {
                    GeometryReader { proxy in
                        let rect = proxy[preference.value]
                        
                        VStack(content: {
                            if viewModel.isShowSeconTooltip {
                                HStack(content: {
                                    HStack(spacing: 0) {
                                        Text(LocalizableText.audienceTitle)
                                            .font(.robotoRegular(size: 14))
                                            .foregroundColor(.DinotisDefault.black3)
                                        
                                        TextField("0", text: $viewModel.percentageString, onEditingChanged: { value in
                                            viewModel.isFreeTextUsed = value
                                            viewModel.isSliderUsed = false
                                        })
                                        .font(.robotoBold(size: 14))
                                        .foregroundColor(.DinotisDefault.primary)
                                        .multilineTextAlignment(.trailing)
                                        .keyboardType(.numberPad)
                                        .onChange(of: viewModel.percentageString, perform: { value in
                                            if viewModel.isFreeTextUsed {
                                                viewModel.percentageRaw = Double(Int(value).orZero()/100)
                                            }
                                        })
                                        
                                        Text("%")
                                            .font(.robotoBold(size: 14))
                                            .foregroundColor(.DinotisDefault.primary)
                                    }
                                    .padding(.vertical, 15)
                                    .padding(.horizontal, 8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color(red: 0.89, green: 0.91, blue: 0.94), lineWidth: 1.0)
                                    )
                                    
                                    HStack(spacing: 0) {
                                        Text(LocalizableText.creatorTitle)
                                            .font(.robotoRegular(size: 14))
                                            .foregroundColor(.DinotisDefault.black3)
                                        
                                        Spacer()
                                        
                                        Text("\(viewModel.percentageFaresForCreatorStr)")
                                            .font(.robotoBold(size: 14))
                                            .foregroundColor(.DinotisDefault.black3)
                                            .multilineTextAlignment(.trailing)
                                            .keyboardType(.numberPad)
                                            .onChange(of: viewModel.percentageString, perform: { value in
                                                let temp = ((viewModel.percentageFaresForCreatorRaw*100)-(Double(value).orZero()))/100
                                                viewModel.percentageFaresForCreator = temp
                                                viewModel.percentageFaresForCreatorStr = "\(Int(viewModel.percentageFaresForCreator*100))"
                                            })
                                            .disabled(true)
                                        
                                        Text("%")
                                            .font(.robotoBold(size: 14))
                                            .foregroundColor(.DinotisDefault.black3)
                                    }
                                    .padding(.vertical, 15)
                                    .padding(.horizontal, 8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color(red: 0.89, green: 0.91, blue: 0.94), lineWidth: 1.0)
                                    )
                                })
                            }
                            
                            SliderView(value: $viewModel.percentageRaw, label: $viewModel.percentageString)
                                .padding(.vertical, 3)
                            
                            HStack(alignment: .top, spacing: 5) {
                                Text(LocalizableText.percentageBorneByAudience)
                                    .font(.robotoRegular(size: 12))
                                    .foregroundColor(.DinotisDefault.black3)
                                    .multilineTextAlignment(.center)
                                
                                Button {
                                    withAnimation {
                                        viewModel.isShowSeconTooltip.toggle()
                                    }
                                } label: {
                                    Image.videoCallHelpCircle
                                        .renderingMode(.template)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 14)
                                        .foregroundColor(.DinotisDefault.primary)
                                }
                                
                            }
                        })
                        .padding(viewModel.isShowSeconTooltip ? 5 : 0)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .foregroundColor(.white)
                        )
                        .padding(.horizontal, 11)
                        .dinotisTooltip(
                            $viewModel.isShowSeconTooltip,
                            alignment: .bottom,
                            id: AppCostTip.two.value,
                            width: 245,
                            height: 90
                        ) {
                            if let attr = try? AttributedString(markdown: LocalizableText.appUsageCostsSliderTooltip) {
                                Text(attr)
                                    .font(.robotoRegular(size: 14))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                            } else {
                                Text(LocalizableText.appUsageCostsSliderTooltip)
                                    .font(.robotoRegular(size: 14))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .frame(width: rect.width, height: rect.height)
                        .offset(x: rect.minX, y: rect.minY)
                    }
                }
            })
            .overlayPreferenceValue(BoundsPreference.self, alignment: .center, { value in
                if let preference = value.first(where: { item in
                    item.key == AppCostTip.first.value
                }), viewModel.isShowFirstTooltip {
                    GeometryReader { proxy in
                        let rect = proxy[preference.value]
                        
                        VStack(content: {
                            HStack(alignment: .top, spacing: 5) {
                                if let attr = try? AttributedString(markdown: LocalizableText.costCalculatedSubtitle(fee: "\(viewModel.fee)".toDecimal())) {
                                    Text(attr)
                                        .font(.robotoRegular(size: 12))
                                        .foregroundColor(.DinotisDefault.black1)
                                        .multilineTextAlignment(.leading)
                                }
                                
                                Button {
                                    withAnimation {
                                        viewModel.isShowFirstTooltip.toggle()
                                    }
                                    
                                } label: {
                                    Image.videoCallHelpCircle
                                        .renderingMode(.template)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 14)
                                        .foregroundColor(.DinotisDefault.primary)
                                }
                                
                                Spacer()
                            }
                            
                            HStack(content: {
                                HStack(spacing: 0) {
                                    Text(LocalizableText.audienceTitle)
                                        .font(.robotoRegular(size: 14))
                                        .foregroundColor(.DinotisDefault.black3)
                                    
                                    TextField("0", text: $viewModel.percentageString, onEditingChanged: { value in
                                        viewModel.isFreeTextUsed = value
                                        viewModel.isSliderUsed = false
                                    })
                                    .onTapGesture(perform: {
                                        viewModel.isShowFirstTooltip = false
                                    })
                                    .font(.robotoBold(size: 14))
                                    .foregroundColor(.DinotisDefault.primary)
                                    .multilineTextAlignment(.trailing)
                                    .keyboardType(.numberPad)
                                    .onChange(of: viewModel.percentageString, perform: { value in
                                        if viewModel.isFreeTextUsed {
                                            viewModel.percentageRaw = Double(Int(value).orZero()/100)
                                        }
                                    })
                                    .disabled(true)
                                    
                                    Text("%")
                                        .font(.robotoBold(size: 14))
                                        .foregroundColor(.DinotisDefault.primary)
                                }
                                .padding(.vertical, 15)
                                .padding(.horizontal, 8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color(red: 0.89, green: 0.91, blue: 0.94), lineWidth: 1.0)
                                )
                                
                                HStack(spacing: 0) {
                                    Text(LocalizableText.creatorTitle)
                                        .font(.robotoRegular(size: 14))
                                        .foregroundColor(.DinotisDefault.black3)
                                    
                                    Spacer()
                                    
                                    Text("\(viewModel.percentageFaresForCreatorStr)")
                                        .font(.robotoBold(size: 14))
                                        .foregroundColor(.DinotisDefault.black3)
                                        .multilineTextAlignment(.trailing)
                                        .keyboardType(.numberPad)
                                        .onChange(of: viewModel.percentageString, perform: { value in
                                            let temp = ((viewModel.percentageFaresForCreatorRaw*100)-(Double(value).orZero()))/100
                                            viewModel.percentageFaresForCreator = temp
                                            viewModel.percentageFaresForCreatorStr = "\(Int(viewModel.percentageFaresForCreator*100))"
                                        })
                                    
                                    Text("%")
                                        .font(.robotoBold(size: 14))
                                        .foregroundColor(.DinotisDefault.black3)
                                }
                                .padding(.vertical, 15)
                                .padding(.horizontal, 8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color(red: 0.89, green: 0.91, blue: 0.94), lineWidth: 1.0)
                                )
                            })
                        })
                        .padding(5)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .foregroundColor(.white)
                        )
                        .padding(.horizontal, 11)
                        .dinotisTooltip(
                            $viewModel.isShowFirstTooltip,
                            alignment: .bottom,
                            id: AppCostTip.first.value,
                            width: 255,
                            height: 110
                        ) {
                            if let attr = try? AttributedString(markdown: LocalizableText.appUsageCostCalculationTooltip(fee: "\(viewModel.fee)".toDecimal(), minute: "45", total: "\(viewModel.fee*45)".toDecimal())) {
                                Text(attr)
                                    .font(.robotoRegular(size: 14))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                            } else {
                                Text(LocalizableText.appUsageCostCalculationTooltip(fee: "\(viewModel.fee)".toDecimal(), minute: "45", total: "\(viewModel.fee*45)".toDecimal()))
                                    .font(.robotoRegular(size: 14))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .frame(width: rect.width, height: rect.height)
                        .offset(x: rect.minX, y: rect.minY)
                    }
                }
            })
        }
    }
    
    struct PriceSetupForm: View {
        
        @EnvironmentObject var viewModel: ScheduledFormViewModel
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Text(LocalizableText.scheduleFormPriceSettingsTitle)
                    .font(.robotoBold(size: 18))
                    .foregroundColor(.DinotisDefault.black1)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                
                Divider()
                
                VStack(alignment: .leading) {
                    HStack(spacing: 10) {
                        Image.scheduleFormVideoPrimaryOutlineIcon
                            .resizable()
                            .scaledToFit()
                            .frame(height: 28)
                        
                        Text(LocalizableText.scheduleFormSetPrice)
                            .font(.robotoMedium(size: 14))
                            .foregroundColor(.DinotisDefault.black2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.leading)
                    }
                    
                    HStack {
                        Text("Rp")
                            .font(.robotoBold(size: 12))
                            .foregroundColor(.DinotisDefault.black2)
                        
                        TextField(LocalizableText.scheduleFormPricePlaceholder, text: $viewModel.pricePerPeople, onCommit: {
                            let intPeople = Int(viewModel.peopleGroup)
                            let intPrice = Int(viewModel.pricePerPeople)
                            viewModel.estPrice = (intPrice ?? 0) * (intPeople ?? 0)
                        })
                        .font(.robotoRegular(size: 12))
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                        .keyboardType(.numberPad)
                        .foregroundColor(.black)
                        .accentColor(.black)
                        .onChange(of: viewModel.pricePerPeople, perform: { value in
                            viewModel.rawPrice = viewModel.pricePerPeople.replacingOccurrences(of: ".", with: "")
                            viewModel.meeting.price = Int(viewModel.rawPrice).orZero()
                            viewModel.pricePerPeople = viewModel.rawPrice.toDecimal()
                            viewModel.perPersonPriceCount(price: value)
                        })
                        
                        Text(LocalizableText.scheduleFormPerPerson)
                            .font(.robotoMedium(size: 14))
                            .fontWeight(.semibold)
                            .foregroundColor(.DinotisDefault.primary)
                        
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
                    )
                }
                .padding(16)
                
                VStack(alignment: .leading) {
                    HStack(spacing: 10) {
                        Image.scheduleFormCoinPrimaryOutlineIcon
                            .resizable()
                            .scaledToFit()
                            .frame(height: 28)
                        
                        Text(LocalizableText.revenuePurposeText)
                            .font(.robotoMedium(size: 14))
                            .foregroundColor(.DinotisDefault.black2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Menu {
                        Picker(selection: $viewModel.meeting.managementId) {
                            ForEach(viewModel.walletLocal, id: \.id) { item in
                                Text((item.management?.user?.name).orEmpty())
                                    .tag(item.management?.id)
                            }
                            
                            ForEach(viewModel.managements ?? [], id: \.id) { item in
                                Text((item.management?.user?.name).orEmpty())
                                    .tag(item.management?.id)
                            }
                        } label: {
                            EmptyView()
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Text(viewModel.selectedWallet.orEmpty())
                                .lineLimit(1)
                                .font(.robotoRegular(size: 12))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Image.generalChevronDown
                                .resizable()
                                .scaledToFit()
                                .frame(height: 20)
                        }
                        .padding(.horizontal, 15)
                        .padding(.vertical, 14)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0))
                        .onChange(of: viewModel.meeting.managementId) { val in
                            viewModel.selectedWallet = val == nil ?
                            LocalizableText.personalWalletText :
                            viewModel.managements?.first(where: {
                                $0.management?.id == val
                            })?.management?.user?.name
                        }
                        .onAppear {
                            viewModel.selectedWallet = viewModel.meeting.managementId == nil ?
                            LocalizableText.personalWalletText :
                            viewModel.managements?.first(where: {
                                $0.management?.id == viewModel.meeting.managementId
                            })?.management?.user?.name
                        }
                    }
                    
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                
                VStack(alignment: .leading) {
                    HStack(spacing: 10) {
                        Image.scheduleFormCoinPrimaryOutlineIcon
                            .resizable()
                            .scaledToFit()
                            .frame(height: 28)
                        
                        Text(LocalizableText.scheduleFormApplicationCostTransfer)
                            .font(.robotoMedium(size: 14))
                            .foregroundColor(.DinotisDefault.black2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Button {
                        UIApplication.shared.endEditing()
                        if viewModel.pricePerPeople.isEmpty || Double(viewModel.pricePerPeople).orZero() <= 0.0 {
                            if !viewModel.isShowPriceEmptyWarning {
                                viewModel.getThreeSecondTime()
                            }
                        } else {
                            viewModel.isShowAppCostsManagement.toggle()
                        }
                    } label: {
                        HStack(spacing: 10) {
                            if viewModel.isChangedCostManagement && Double(viewModel.pricePerPeople).orZero() > 0.0 {
                                Text(LocalizableText.scheduleFormCoverPercentage(total: viewModel.percentageFaresForCreatorStr))
                                    .lineLimit(1)
                                    .font(.robotoMedium(size: 14))
                                    .foregroundColor(.DinotisDefault.primary)
                            } else {
                                Text(LocalizableText.scheduleFormSetAppUsageCost)
                                    .lineLimit(1)
                                    .font(.robotoMedium(size: 14))
                                    .foregroundColor(.DinotisDefault.primary)
                            }
                            
                            Spacer()
                            
                            Image.generalChevronRight
                                .resizable()
                                .scaledToFit()
                                .frame(height: 24)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.DinotisDefault.primary, lineWidth: 1.0))
                        .contentShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .onChange(of: viewModel.onSecondTime) { value in
                        if value == 3 {
                            withAnimation(.spring()) {
                                viewModel.timer?.invalidate()
                                viewModel.onSecondTime = 0
                                self.viewModel.isShowPriceEmptyWarning = false
                            }
                        }
                    }
                    
                    if viewModel.isShowPriceEmptyWarning {
                        Text(LocalizableText.scheduleFormSetAppUsageWarning)
                            .font(.robotoRegular(size: 10))
                            .foregroundColor(.DinotisDefault.red)
                            .multilineTextAlignment(.leading)
                            .padding(.top, 2)
                    } else {
                        if let attr = try? AttributedString(markdown: LocalizableText.scheduleFormSetAppUsageRule) {
                            Text(attr)
                                .font(.robotoRegular(size: 10))
                                .foregroundColor(.DinotisDefault.black3)
                                .multilineTextAlignment(.leading)
                                .padding(.top, 2)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(LocalizableText.scheduleFormPriceSummary)
                        .font(.robotoMedium(size: 14))
                        .foregroundColor(.DinotisDefault.black1)
                        .multilineTextAlignment(.leading)
                        .padding([.top, .horizontal], 16)
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(LocalizableText.scheduleFormSessionPriceTitle)
                                .font(.robotoRegular(size: 14))
                                .foregroundColor(.DinotisDefault.black3)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                            
                            Text("Rp\(viewModel.rawPrice.toDecimal())")
                                .font(.robotoRegular(size: 14))
                                .foregroundColor(.DinotisDefault.black3)
                        }
                        
                        HStack {
                            Text(LocalizableText.scheduleFormAudienceQuota)
                                .font(.robotoRegular(size: 14))
                                .foregroundColor(.DinotisDefault.black3)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                            
                            Text("\(viewModel.peopleGroup.toDecimal())")
                                .font(.robotoRegular(size: 14))
                                .foregroundColor(.DinotisDefault.black3)
                        }
                        
                        HStack {
                            Text(LocalizableText.scheduleFormCreatorSponsoredCosts)
                                .font(.robotoRegular(size: 14))
                                .foregroundColor(.DinotisDefault.black3)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                            
                            if viewModel.rawPrice.isEmpty || viewModel.rawPrice == "0" {
                                Text("-\(0.0.toCurrency())")
                                    .font(.robotoRegular(size: 14))
                                    .foregroundColor(.DinotisDefault.black3)
                            } else {
                                Text("-\(viewModel.creatorEstimated().toCurrency())")
                                    .font(.robotoRegular(size: 14))
                                    .foregroundColor(.DinotisDefault.black3)
                            }
                        }
                        
                    }
                    .padding(.horizontal, 16)
                    
                    Divider()
                        .padding(.horizontal, 16)
                    
                    HStack {
                        Text(LocalizableText.scheduleFormRevenueEstimation)
                            .font(.robotoBold(size: 14))
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(Color.DinotisDefault.black1)
                        
                        Spacer()
                        
                        if viewModel.rawPrice.isEmpty || viewModel.rawPrice == "0" {
                            Text("\(0.0.toCurrency())")
                                .font(.robotoBold(size: 14))
                                .foregroundStyle(Color.DinotisDefault.primary)
                        } else {
                            Text("\(viewModel.getTotalRevenueEstimation().toCurrency())")
                                .font(.robotoBold(size: 14))
                                .foregroundStyle(viewModel.isTotalEstimationMinus() ? Color.DinotisDefault.red : Color.DinotisDefault.primary)
                        }
                    }
                    .padding([.horizontal, .bottom], 16)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                
                if viewModel.isTotalEstimationMinus() {
                    HStack {
                        Spacer()
                        
                        if let attr = try? AttributedString(markdown: LocalizableText.scheduleFormMinusTotalRevenueWarning) {
                            Text(attr)
                                .font(.robotoRegular(size: 12))
                                .foregroundStyle(Color.DinotisDefault.orange)
                                .multilineTextAlignment(.leading)
                                .padding()
                        }
                        
                        Spacer()
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(Color.DinotisDefault.lightOrange.opacity(0.6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.DinotisDefault.orange, lineWidth: 1)
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(.white)
                    .shadow(color: Color(red: 0.22, green: 0.29, blue: 0.41).opacity(0.06), radius: 20, x: 0.0, y: 0.0)
            )
        }
    }
    
    struct ScheduleSetupForm: View {
        
        @EnvironmentObject var viewModel: ScheduledFormViewModel
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Text(LocalizableText.scheduleFormSessionSettingsTitle)
                    .font(.robotoBold(size: 18))
                    .foregroundColor(.DinotisDefault.black1)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                
                Divider()
                
                VStack(alignment: .leading) {
                    HStack(spacing: 10) {
                        Image.scheduleFormVideoPrimaryOutlineIcon
                            .resizable()
                            .scaledToFit()
                            .frame(height: 28)
                        
                        Text(LocaleText.titleDescriptionFormTitle)
                            .font(.robotoMedium(size: 14))
                            .foregroundColor(.DinotisDefault.black2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.leading)
                    }
                    
                    TextField(LocaleText.exampleFormTitlePlaceholder, text: $viewModel.meeting.title)
                        .font(.robotoRegular(size: 12))
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .padding(.vertical, 15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
                        )
                        .onChange(of: viewModel.meeting.title) { value in
                            viewModel.isFieldDescError = false
                        }
                    
                    if viewModel.isFieldTitleError {
                        HStack {
                            Image.Dinotis.exclamationCircleIcon
                                .resizable()
                                .scaledToFit()
                                .frame(height: 10)
                                .foregroundColor(.red)
                            Text(viewModel.fieldTitleError)
                                .font(.robotoRegular(size: 10))
                                .foregroundColor(.red)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    
                    MultilineTextField(text: $viewModel.meeting.description)
                        .foregroundColor(.black)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
                        )
                        .onChange(of: viewModel.meeting.description) { value in
                            viewModel.isFieldDescError = false
                        }
                    
                    if viewModel.isFieldDescError {
                        HStack {
                            Image.Dinotis.exclamationCircleIcon
                                .resizable()
                                .scaledToFit()
                                .frame(height: 10)
                                .foregroundColor(.red)
                            Text(viewModel.fieldDescError)
                                .font(.robotoRegular(size: 10))
                                .foregroundColor(.red)
                                .multilineTextAlignment(.leading)
                        }
                    }
                }
                .padding(16)
                
                if viewModel.selectedSession == LocaleText.groupcallLabel {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(LocalizableText.scheduleFormEnableVideoArchieveTitle)
                                .font(.robotoMedium(size: 14))
                                .fontWeight(.semibold)
                                .foregroundColor(.DinotisDefault.black2)
                            
                            Text(LocalizableText.scheduleFormEnableVideoArchieveSubtitle)
                                .font(.robotoRegular(size: 10))
                                .foregroundColor(.DinotisDefault.black3)
                                .multilineTextAlignment(.leading)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $viewModel.isArchieve)
                            .labelsHidden()
                            .tint(.DinotisDefault.green)
                    }
                    .padding(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                
                VStack(alignment: .leading) {
                    HStack(spacing: 10) {
                        Image.scheduleFormDatePrimaryOutlineIcon
                            .resizable()
                            .scaledToFit()
                            .frame(height: 28)
                        
                        Text(LocaleText.selectDateText)
                            .font(.robotoMedium(size: 14))
                            .foregroundColor(.DinotisDefault.black2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.leading)
                    }
                    
                    HStack {
                        Text("\(viewModel.startDate.orCurrentDate().toStringFormat(with: .EEEEddMMMMyyyy))")
                            .font(.robotoRegular(size: 12))
                            .foregroundColor(.DinotisDefault.black1)
                        
                        Spacer()
                        
                        Image.generalChevronDown
                            .resizable()
                            .scaledToFit()
                            .frame(height: 20)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .contentShape(Rectangle())
                    .padding(.horizontal)
                    .padding(.vertical, 15)
                    .onTapGesture {
                        self.viewModel.showsDatePicker.toggle()
                        self.viewModel.showsTimePicker = false
                        self.viewModel.showsTimeUntilPicker = false
                        self.viewModel.presentTalentPicker = false
                        UIApplication.shared.endEditing()
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
                    )
                    
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                
                VStack(alignment: .leading) {
                    HStack(spacing: 10) {
                        Image.scheduleFormTimePrimaryOutlineIcon
                            .resizable()
                            .scaledToFit()
                            .frame(height: 28)
                        
                        Text(LocaleText.selectTimeText)
                            .font(.robotoMedium(size: 14))
                            .foregroundColor(.DinotisDefault.black2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.leading)
                    }
                    
                    HStack {
                        HStack {
                            Text("\(viewModel.startDate.orCurrentDate().toStringFormat(with: .HHmm))")
                                .font(.robotoRegular(size: 12))
                                .foregroundColor(.DinotisDefault.black1)
                            
                            Spacer()
                            
                            Image.generalChevronDown
                                .resizable()
                                .scaledToFit()
                                .frame(height: 20)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .contentShape(Rectangle())
                        .padding(.horizontal)
                        .padding(.vertical, 15)
                        .onTapGesture {
                            self.viewModel.presentTalentPicker = false
                            self.viewModel.showsTimePicker.toggle()
                            self.viewModel.showsTimeUntilPicker = false
                            UIApplication.shared.endEditing()
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
                        )
                        
                        
                        HStack {
                            Text("\(viewModel.endDate.orCurrentDate().toStringFormat(with: .HHmm))")
                                .font(.robotoRegular(size: 12))
                                .foregroundColor(.DinotisDefault.black1)
                            
                            Spacer()
                            
                            Image.generalChevronDown
                                .resizable()
                                .scaledToFit()
                                .frame(height: 20)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .contentShape(Rectangle())
                        .padding(.horizontal)
                        .padding(.vertical, 15)
                        .onTapGesture {
                            self.viewModel.presentTalentPicker = false
                            self.viewModel.showsTimeUntilPicker.toggle()
                            self.viewModel.showsTimePicker = false
                            UIApplication.shared.endEditing()
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
                        )
                        
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                
                VStack(alignment: .leading) {
                    HStack(spacing: 10) {
                        Image.scheduleFormSessionPrimaryOutlineIcon
                            .resizable()
                            .scaledToFit()
                            .frame(height: 28)
                        
                        Text(LocaleText.selectedSession)
                            .font(.robotoMedium(size: 14))
                            .foregroundColor(.DinotisDefault.black2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.leading)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Menu {
                                Picker(selection: $viewModel.selectedSession) {
                                    ForEach(viewModel.arrSession, id: \.self) { item in
                                        Text(item)
                                            .tag(item)
                                    }
                                } label: {
                                    EmptyView()
                                }
                            } label: {
                                HStack(spacing: 10) {
                                    Text(viewModel.selectedSession)
                                        .lineLimit(1)
                                        .font(.robotoRegular(size: 12))
                                        .foregroundColor(.DinotisDefault.black1)
                                    
                                    Spacer()
                                    
                                    Image.generalChevronDown
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 20)
                                }
                                .padding(.horizontal, 15)
                                .padding(.vertical)
                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0))
                                .onChange(of: viewModel.selectedSession) { val in
                                    viewModel.meeting.isPrivate = val.contains(LocaleText.privateCallLabel)
                                }
                                .onAppear {
                                    viewModel.selectedSession = viewModel.meeting.isPrivate ? LocaleText.privateCallLabel : LocaleText.groupcallLabel
                                }
                            }
                            
                            if viewModel.selectedSession == LocaleText.groupcallLabel {
                                TextField(LocalizableText.scheduleFormSetParticipant, text: $viewModel.peopleGroup)
                                    .font(.robotoRegular(size: 12))
                                    .autocapitalization(.words)
                                    .disableAutocorrection(true)
                                    .keyboardType(.numberPad)
                                    .foregroundColor(.black)
                                    .accentColor(.black)
                                    .padding(.horizontal)
                                    .padding(.vertical, 15)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
                                    )
                                    .frame(width: 95)
                                    .keyboardType(.numberPad)
                                    .valueChanged(value: viewModel.peopleGroup) { value in
                                        viewModel.onPeopleOnGroupChanges(value)
                                    }
                            }
                        }
                        
                        if !viewModel.isValidPersonForGroup && viewModel.selectedSession.contains(LocaleText.groupcallLabel) {
                            HStack {
                                Image.Dinotis.exclamationCircleIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 10)
                                    .foregroundColor(.red)
                                Text(LocalizableText.createSessionMinimumParticipantAlert)
                                    .font(.robotoRegular(size: 10))
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                
                if viewModel.isShowAdditionalMenu {
                    if !viewModel.meeting.isPrivate {
                        VStack(alignment: .leading) {
                            HStack(spacing: 10) {
                                Image.scheduleFormCollabPrimaryOutlineIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 28)
                                
                                Text(LocalizableText.collaborationTitle)
                                    .font(.robotoMedium(size: 14))
                                    .foregroundColor(.DinotisDefault.black2)
                                    .fontWeight(.semibold)
                                    .multilineTextAlignment(.leading)
                            }
                            
                            HStack {
                                Text(LocalizableText.collaborationPlaceholder)
                                    .font(.robotoRegular(size: 12))
                                    .foregroundColor(.gray)
                                
                                Spacer()
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .padding(.horizontal)
                            .padding(.vertical, 15)
                            .onTapGesture {
                                self.viewModel.presentTalentPicker.toggle()
                                self.viewModel.showsDatePicker = false
                                self.viewModel.showsTimePicker = false
                                self.viewModel.showsTimeUntilPicker = false
                                UIApplication.shared.endEditing()
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
                            )
                            
                            if !viewModel.talent.isEmpty {
                                VStack(spacing: 15) {
                                    HStack {
                                        Text(LocalizableText.invitedCreatorTitle)
                                            .font(.robotoMedium(size: 10))
                                            .foregroundColor(.black)
                                        
                                        Spacer()
                                        
                                        if viewModel.talent.count > 3 {
                                            Button {
                                                viewModel.isShowSelectedTalent.toggle()
                                            } label: {
                                                Text(LocalizableText.searchSeeAllLabel)
                                                    .font(.robotoMedium(size: 10))
                                                    .foregroundColor(.DinotisDefault.primary)
                                                    .underline()
                                            }
                                        }
                                    }
                                    
                                    VStack(spacing: 10) {
                                        ForEach(viewModel.talent.prefix(3), id: \.id) { talent in
                                            HStack {
                                                ImageLoader(url: (talent.user?.profilePhoto).orEmpty(), width: 30, height: 30)
                                                    .frame(width: 30, height: 30)
                                                    .clipShape(Circle())
                                                
                                                VStack(alignment: .leading, spacing: 8) {
                                                    Text((talent.user?.name).orEmpty())
                                                        .font(.robotoMedium(size: 10))
                                                        .foregroundColor(.black)
                                                    
                                                    Text((talent.user?.stringProfessions?.first).orEmpty())
                                                        .font(.robotoMedium(size: 10))
                                                        .foregroundColor(.gray)
                                                }
                                                .multilineTextAlignment(.leading)
                                                
                                                Spacer()
                                                
                                                if talent.declinedAt != nil && talent.approvedAt == nil {
                                                    Text(LocalizableText.declinedCollab)
                                                        .font(.robotoRegular(size: 12))
                                                        .lineLimit(1)
                                                        .foregroundColor(.white)
                                                        .padding(.horizontal, 10)
                                                        .padding(.vertical, 6)
                                                        .background(
                                                            Capsule()
                                                                .foregroundColor(.DinotisDefault.red)
                                                        )
                                                } else if talent.declinedAt == nil && talent.approvedAt != nil {
                                                    Text(LocalizableText.acceptedCollab)
                                                        .font(.robotoRegular(size: 12))
                                                        .lineLimit(1)
                                                        .foregroundColor(.white)
                                                        .padding(.horizontal, 10)
                                                        .padding(.vertical, 6)
                                                        .background(
                                                            Capsule()
                                                                .foregroundColor(.DinotisDefault.green)
                                                        )
                                                } else {
                                                    Text(LocalizableText.waitingForConfirmCollab)
                                                        .font(.robotoRegular(size: 12))
                                                        .lineLimit(1)
                                                        .foregroundColor(.white)
                                                        .padding(.horizontal, 10)
                                                        .padding(.vertical, 6)
                                                        .background(
                                                            Capsule()
                                                                .foregroundColor(.yellow)
                                                        )
                                                }
                                                
                                                Button {
                                                    let index = self.viewModel.talent.firstIndex {
                                                        $0.user?.id == talent.user?.id
                                                    }.orZero()
                                                    let usernameIndex = (self.viewModel.meeting.collaborations ?? []).firstIndex(where: {
                                                        $0 == (talent.user?.username).orEmpty()
                                                    }).orZero()
                                                    
                                                    self.viewModel.talent.remove(at: index)
                                                    self.viewModel.meeting.collaborations?.remove(at: usernameIndex)
                                                    
                                                } label: {
                                                    Image(systemName: "xmark")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(height: 10)
                                                        .foregroundColor(.gray)
                                                        .font(.system(size: 10, weight: .bold))
                                                }
                                                
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.top, 5)
                            }
                            
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                    
                    VStack(alignment: .leading) {
                        HStack(spacing: 10) {
                            Image.scheduleFormURLPrimaryOutlineIcon
                                .resizable()
                                .scaledToFit()
                                .frame(height: 28)
                            
                            Text(LocalizableText.urlLinkText)
                                .font(.robotoMedium(size: 14))
                                .foregroundColor(.DinotisDefault.black2)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                            
                            Button {
                                withAnimation(.spring(response: 0.2)) {
                                    viewModel.meeting.urls.append(MeetingURLrequest(title: "", url: ""))
                                }
                            } label: {
                                Text(LocalizableText.addUrlLinkLabel)
                                    .font(.robotoMedium(size: 14))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.DinotisDefault.primary)
                            }
                            
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(viewModel.meeting.urls.indices, id: \.self) { index in
                                HStack {
                                    Circle()
                                        .scaledToFit()
                                        .frame(height: 8)
                                        .foregroundStyle(Color.DinotisDefault.primary)
                                    
                                    Text("\(LocalizableText.urlLinkText) \(index+1)")
                                        .font(.robotoMedium(size: 10))
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Button {
                                        viewModel.meeting.urls.remove(at: index)
                                    } label: {
                                        Text(LocalizableText.deleteUrlLinkLabel)
                                            .font(.robotoBold(size: 10))
                                            .foregroundColor(.DinotisDefault.primary)
                                    }
                                }
                                
                                TextField(LocalizableText.urlLinkTitlePlaceholder, text: $viewModel.meeting.urls[index].title)
                                    .font(.robotoRegular(size: 12))
                                    .disableAutocorrection(true)
                                    .foregroundColor(.black)
                                    .accentColor(.black)
                                    .padding(.horizontal)
                                    .padding(.vertical, 15)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
                                    )
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    TextField(LocalizableText.urlLinkText, text: $viewModel.meeting.urls[index].url)
                                        .font(.robotoRegular(size: 12))
                                        .disableAutocorrection(true)
                                        .foregroundColor(.black)
                                        .accentColor(.black)
                                        .padding(.horizontal)
                                        .padding(.vertical, 15)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
                                        )
                                    
                                    if !viewModel.meeting.urls[index].url.validateURL() {
                                        HStack {
                                            Image.Dinotis.exclamationCircleIcon
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 10)
                                                .foregroundColor(.red)
                                            Text(LocalizableText.invalidUrlMessage)
                                                .font(.robotoRegular(size: 10))
                                                .foregroundColor(.red)
                                                .multilineTextAlignment(.leading)
                                        }
                                            
                                    }
                                }
                                .padding(.bottom, 5)
                                
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                
                HStack {
                    
                    Spacer()
                    
                    Button {
                        withAnimation(.spring(response: 0.2)) {
                            viewModel.isShowAdditionalMenu.toggle()
                        }
                    } label: {
                        Text(viewModel.isShowAdditionalMenu ? LocalizableText.hideAdditionalMenuLabel : LocalizableText.seeAdditionalMenuLabel)
                            .font(.robotoBold(size: 12))
                            .foregroundColor(.DinotisDefault.primary)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(.white)
                    .shadow(color: Color(red: 0.22, green: 0.29, blue: 0.41).opacity(0.06), radius: 20, x: 0.0, y: 0.0)
            )
        }
    }
    
    struct StartDatePicker: View {
        
        @EnvironmentObject var viewModel: ScheduledFormViewModel
        
        var body: some View {
            ZStack {
                VStack(alignment: .center, spacing: 0) {
                    DatePicker("", selection: $viewModel.changedStartDate, in: Date()..., displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .tint(Color.DinotisDefault.primary)
                        .labelsHidden()
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.startDate = viewModel.changedStartDate
                        viewModel.meeting.startAt = DateUtils.dateFormatter(viewModel.changedStartDate, forFormat: .utcV2)
                        viewModel.showsDatePicker = false
                    }, label: {
                        HStack {
                            Spacer()
                            
                            Text(LocaleText.selectTextLabel)
                                .foregroundColor(.white)
                                .font(.robotoMedium(size: 14))
                                .fontWeight(.semibold)
                            
                            Spacer()
                        }
                        .padding(.vertical)
                        .background(Color.DinotisDefault.primary)
                    })
                    .clipShape(RoundedRectangle(cornerRadius: 8.0))
                }
                .padding()
                .onAppear {
                    viewModel.changedStartDate = viewModel.startDate ?? Date().addingTimeInterval(3600)
                }
            }
        }
    }
    
    struct StartTimePicker: View {
        
        @EnvironmentObject var viewModel: ScheduledFormViewModel
        
        var body: some View {
            ZStack {
                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        
                        DatePicker("", selection: $viewModel.changedStartDate, in: Date()..., displayedComponents: .hourAndMinute)
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden()
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.startDate = viewModel.changedStartDate
                        viewModel.meeting.startAt = DateUtils.dateFormatter(viewModel.changedStartDate, forFormat: .utcV2)
                        
                        if viewModel.meeting.endAt.isEmpty || viewModel.endDate.orCurrentDate() < viewModel.changedStartDate {
                            viewModel.endDate = viewModel.changedStartDate.addingTimeInterval(3600)
                        }
                        viewModel.showsTimePicker = false
                    }, label: {
                        HStack {
                            Spacer()
                            
                            Text(LocaleText.selectTextLabel)
                                .foregroundColor(.white)
                                .font(.robotoMedium(size: 14))
                                .fontWeight(.semibold)
                            
                            Spacer()
                        }
                        .padding(.vertical)
                        .background(Color.DinotisDefault.primary)
                    })
                    .clipShape(RoundedRectangle(cornerRadius: 8.0))
                    .onAppear {
                        if viewModel.changedStartDate < Date().addingTimeInterval(3600) {
                            viewModel.changedStartDate = Date().addingTimeInterval(3600)
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    struct EndTimePicker: View {
        
        @EnvironmentObject var viewModel: ScheduledFormViewModel
        
        var body: some View {
            ZStack {
                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        
                        DatePicker("", selection: $viewModel.changedEndDate, in: viewModel.startDate.orCurrentDate()..., displayedComponents: .hourAndMinute)
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden()
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.endDate = viewModel.changedEndDate
                        viewModel.meeting.endAt = DateUtils.dateFormatter(viewModel.changedEndDate, forFormat: .utcV2)
                        viewModel.showsTimeUntilPicker = false
                        
                        if viewModel.meeting.startAt.isEmpty {
                            viewModel.meeting.startAt = DateUtils.dateFormatter(viewModel.startDate.orCurrentDate(), forFormat: .utcV2)
                        }
                    }, label: {
                        HStack {
                            Spacer()
                            
                            Text(LocaleText.selectTextLabel)
                                .foregroundColor(.white)
                                .font(.robotoMedium(size: 14))
                                .fontWeight(.semibold)
                            
                            Spacer()
                        }
                        .padding(.vertical)
                        .background(Color.DinotisDefault.primary)
                    })
                    .clipShape(RoundedRectangle(cornerRadius: 8.0))
                }
                .padding()
                .onAppear {
                    if let timeStart = viewModel.startDate {
                        viewModel.changedEndDate = timeStart.addingTimeInterval(3600)
                    } else {
                        viewModel.changedEndDate = Date().addingTimeInterval(7200)
                    }
                }
            }
        }
    }
}
