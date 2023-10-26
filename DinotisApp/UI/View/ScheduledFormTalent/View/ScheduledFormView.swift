//
//  ScheduledFormView.swift
//  DinotisApp
//
//  Created by Gus Adi on 19/08/21.
//

import DinotisData
import DinotisDesignSystem
import OneSignal
import SwiftUI
import SwiftKeychainWrapper
import SwiftUITrackableScrollView

struct ScheduledFormView: View {
    @Environment(\.dismiss) var dismiss
    
    @Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
    
    @ObservedObject var stateObservable = StateObservable.shared
    @ObservedObject var viewModel: ScheduledFormViewModel
    
    private var viewController: UIViewController? {
        self.viewControllerHolder.value
    }
    
    init(viewModel: ScheduledFormViewModel) {
        self.viewModel = viewModel
        FontInjector.registerFonts()
        UISlider.appearance().maximumTrackTintColor = .white
    }
    
    var body: some View {
        ZStack {
            ZStack(alignment: .topLeading) {
                Image.Dinotis.linearGradientBackground
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .alert(isPresented: $viewModel.isRefreshFailed) {
                        Alert(
                            title: Text(LocaleText.attention),
                            message: Text(LocaleText.sessionExpireText),
                            dismissButton: .default(
                                Text(LocaleText.returnText),
                                action: {
                                    viewModel.routeToRoot()
                                }
                            )
                        )
                    }
                
                VStack(spacing: 0) {
                    ZStack {
                        HStack {
                            Spacer()
                            Text(LocaleText.createScheduleTitleText)
                                .font(.robotoBold(size: 14))
                                .foregroundColor(.black)
                            
                            Spacer()
                        }
                        
                        HStack {
                            Button(action: {
                                dismiss()
                            }, label: {
                                Image.Dinotis.arrowBackIcon
                                    .padding()
                                    .background(Color.white)
                                    .clipShape(Circle())
                            })
                            .padding(.leading)
                            
                            Spacer()
                        }
                        
                    }
                    .padding(.vertical)
                    .background(
                        viewModel.colorTab
                            .edgesIgnoringSafeArea(.vertical)
                    )
                    .alert(isPresented: $viewModel.minimumPeopleError) {
                        Alert(
                            title: Text(LocaleText.attention),
                            message: Text(LocaleText.errorMinimumPeopleText),
                            dismissButton: .cancel(Text(LocaleText.returnText))
                        )
                    }
                    
                    ZStack(alignment: .bottomTrailing) {
                        ScrollViews(axes: .vertical, showsIndicators: false) { value in
                            DispatchQueue.main.async {
                                if value.y < 0 {
                                    viewModel.colorTab = Color.white
                                } else {
                                    viewModel.colorTab = Color.clear
                                }
                            }
                        } content: {
                            LazyVStack(spacing: 10) {
                                ForEach($viewModel.meetingArr, id: \.id) { value in
                                    FormScheduleTalentCardView(
                                        collab: .constant([]),
                                        managements: $viewModel.managements,
                                        meetingForm: value,
                                        onTapRemove: {
                                            if let index = viewModel.meetingArr.firstIndex(where: { item in
                                                value.wrappedValue.id == item.id
                                            }) {
                                                viewModel.meetingArr.remove(at: index)
                                            }
                                        },
                                        isShowRemove: value.wrappedValue.id != viewModel.meetingArr.first?.id,
                                        isEdit: false,
                                        maxEdit: .constant(0)
                                    )
                                }
                            }
                            .padding(.vertical, 15)
                        }
                        .alert(isPresented: $viewModel.isError) {
                            Alert(
                                title: Text(LocaleText.attention),
                                message: Text(viewModel.error.orEmpty()),
                                dismissButton: .cancel(Text(LocaleText.returnText)))
                        }
                        
                        HStack {
                            Button(action: {
                                viewModel.meetingArr.append(AddMeetingRequest(id: String.random(), title: "", description: "", price: 0, startAt: "", endAt: "", isPrivate: true, slots: 1, managementId: nil, urls: []))
                            }, label: {
                                Image.Dinotis.plusIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 24)
                                    .padding()
                                    .background(Color.DinotisDefault.primary)
                                    .clipShape(Circle())
                            })
                            .padding()
                        }
                    }
                    
                    VStack(spacing: 0) {
                        Button(action: {
                            viewModel.submitMeeting()
                        }, label: {
                            HStack {
                                Spacer()
                                Text(LocaleText.saveText)
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(viewModel.meetingArr.contains(where: {
                                        !$0.urls.isEmpty && $0.urls.allSatisfy({
                                            !$0.url.validateURL()
                                        })
                                    }) ? .DinotisDefault.primary.opacity(0.5) : .white)
                                    .padding(10)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 5)
                                
                                Spacer()
                            }
                            .background(
                                viewModel.meetingArr.contains(where: {
                                    !$0.urls.isEmpty && $0.urls.allSatisfy({
                                        !$0.url.validateURL()
                                    })
                                }) ? Color.DinotisDefault.lightPrimary : Color.DinotisDefault.primary
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        })
                        .disabled(viewModel.meetingArr.contains(where: {
                            !$0.urls.isEmpty && $0.urls.allSatisfy({
                                !$0.url.validateURL()
                            })
                        }))
                        .padding()
                        .background(Color.white.edgesIgnoringSafeArea(.vertical))
                        
                    }
                }
                .valueChanged(value: viewModel.success) { value in
                    if value {
                        dismiss()
                    }
                }
                
            }
            
            DinotisLoadingView(.fullscreen, hide: !viewModel.isLoading)
        }
        .onAppear {
            Task {
                await viewModel.getUsers()
            }
        }
        .navigationBarTitle(Text(""))
        .navigationBarHidden(true)
        .sheet(isPresented: $viewModel.isShowAppCostsManagement) {
            if #available(iOS 16.0, *) {
                SetupAppUsageFaresSheetView()
                    .environmentObject(viewModel)
                    .presentationDetents([.height(viewModel.appUsageFareSheetHeight)])
                    .animation(.spring(), value: viewModel.appUsageFareSheetHeight)
                    .presentationDragIndicator(.visible)
            } else {
                SetupAppUsageFaresSheetView()
                    .environmentObject(viewModel)
            }
        }
    }
}

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
                            VStack(content: {
                                HStack(alignment: .top, spacing: 5) {
                                    if let attr = try? AttributedString(markdown: LocalizableText.costCalculatedSubtitle) {
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
                                    
                                    Spacer()
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
                                if let attr = try? AttributedString(markdown: LocalizableText.appUsageCostCalculationTooltip) {
                                    Text(attr)
                                        .font(.robotoRegular(size: 14))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                } else {
                                    Text(LocalizableText.appUsageCostCalculationTooltip)
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
                            if viewModel.appUsageFareSheetHeight <= 400 {
                                VStack(spacing: 10) {
                                    HStack {
                                        Text(LocalizableText.estimatedAppUsageCosts)
                                            .font(.robotoRegular(size: 14))
                                            .fontWeight(.semibold)
                                            .foregroundColor(.DinotisDefault.black1)
                                            .multilineTextAlignment(.leading)
                                        
                                        Spacer()
                                        
                                        DinotisNudeButton(
                                            text: viewModel.appUsageFareSheetHeight <= 400 ? LocalizableText.seeDetailsLabel : LocalizableText.generalCloseDetails,
                                            textColor: .DinotisDefault.primary,
                                            fontSize: 12
                                        ) {
                                            withAnimation(.spring()) {
                                                if viewModel.appUsageFareSheetHeight <= 400 {
                                                    viewModel.appUsageFareSheetHeight = 560.0
                                                } else {
                                                    viewModel.appUsageFareSheetHeight = 400.0
                                                }
                                            }
                                        }
                                    }
                                    
                                    HStack {
                                        Text(LocalizableText.audienceCountLabel(count: 12))
                                            .font(.robotoBold(size: 12))
                                            .foregroundColor(.DinotisDefault.black3)
                                            .multilineTextAlignment(.leading)
                                        
                                        Spacer()
                                        
                                        Text(60000.0.toCurrency())
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
                                            text: viewModel.appUsageFareSheetHeight <= 400 ? LocalizableText.seeDetailsLabel : LocalizableText.generalCloseDetails,
                                            textColor: .DinotisDefault.primary,
                                            fontSize: 12
                                        ) {
                                            withAnimation(.spring()) {
                                                if viewModel.appUsageFareSheetHeight <= 400 {
                                                    viewModel.appUsageFareSheetHeight = 560.0
                                                } else {
                                                    viewModel.appUsageFareSheetHeight = 400.0
                                                }
                                            }
                                        }
                                    }
                                    
                                    HStack {
                                        Text(LocalizableText.audienceCountLabel(count: 12))
                                            .font(.robotoBold(size: 12))
                                            .foregroundColor(.DinotisDefault.black3)
                                            .multilineTextAlignment(.leading)
                                        
                                        Spacer()
                                        
                                        Text(60000.0.toCurrency())
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
                                        
                                        Text(0.0.toCurrency())
                                            .font(.robotoBold(size: 12))
                                            .foregroundColor(.DinotisDefault.black1)
                                            .multilineTextAlignment(.trailing)
                                    }
                                    .padding(.top, 16)
                                    
                                    if let attr = try? AttributedString(markdown: LocalizableText.totalBorneSubtitle(total: 0.0.toCurrency())) {
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
                                        
                                        Text(0.0.toCurrency())
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
                                if let attr = try? AttributedString(markdown: LocalizableText.costCalculatedSubtitle) {
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
                            if let attr = try? AttributedString(markdown: LocalizableText.appUsageCostCalculationTooltip) {
                                Text(attr)
                                    .font(.robotoRegular(size: 14))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                            } else {
                                Text(LocalizableText.appUsageCostCalculationTooltip)
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
    
}

struct SliderView: View {
    
    @Binding var value: Double
    @Binding var label: String
    
    var range: ClosedRange<Double> = 0...1
    
    @State private var pinSize: CGFloat = 38
    @State private var isDragging = false
    
    init(
        value: Binding<Double>,
        label: Binding<String>,
        range: ClosedRange<Double> = 0...1
    ) {
        self._value = value
        self._label = label
        self.range = range
    }
    
    public var body: some View {
        GeometryReader { geo in
            
            let width = geo.size.width - pinSize
            let scale = width / CGFloat(range.upperBound)
            let sliderValue = CGFloat(value) * scale
            
            HStack {
                Capsule()
                    .foregroundColor(.white)
                    .frame(height: 4)
            }
            .padding(.horizontal)
            .frame(height: 48)
            .overlay(alignment: .leading) {
                Text("\(label)%")
                    .foregroundColor(.DinotisDefault.primary)
                    .font(.robotoRegular(size: 12))
                    .fontWeight(.semibold)
                    .frame(width: pinSize, height: pinSize)
                    .background(
                        Circle()
                            .foregroundColor(.white)
                    )
                    .overlay {
                        Circle()
                            .inset(by: 1)
                            .stroke(Color.DinotisDefault.primary, lineWidth: 3)
                    }
                    .offset(x: sliderValue, y: 0)
                    .gesture(
                        DragGesture()
                            .onChanged({ value in
                                withAnimation(.spring(response: 0.2)) {
                                    let dragValue = max(0, min(value.location.x, width))
                                    let stepSize = scale
                                    let step = Double((dragValue + 0.0 * stepSize) / stepSize) + range.lowerBound
                                    self.value = min(max(step, range.lowerBound), range.upperBound)
                                    
                                    self.label = "\(Int(self.value * 100))"
                                    isDragging = true
                                }
                            })
                            .onEnded { value in
                                withAnimation(.spring(response: 0.2)) {
                                    let dragValue = max(0, min(value.location.x, width))
                                    let stepSize = scale
                                    let step = Double((dragValue + 0.0 * stepSize) / stepSize) + range.lowerBound
                                    self.value = min(max(step, range.lowerBound), range.upperBound)
                                    self.label = "\(Int(self.value * 100))"
                                    isDragging = false
                                }
                            }
                    )
            }
            .onChange(of: value) { _ in
                addHaptic()
            }
        }
        .padding(.horizontal, 5)
        .frame(height: 48)
        .background(
            Color.DinotisDefault.primary
                .clipShape(.capsule)
        )
    }
    
    private func addHaptic() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

struct ScheduledFormView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduledFormView(viewModel: ScheduledFormViewModel(backToHome: {}))
    }
}
