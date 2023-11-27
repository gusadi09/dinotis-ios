//
//  EditTalentMeetingView+Component.swift
//  DinotisApp
//
//  Created by Gus Adi on 26/10/23.
//

import DinotisData
import DinotisDesignSystem
import SwiftUI

extension EditTalentMeetingView {
    struct PriceSetupForm: View {
        
        @EnvironmentObject var viewModel: EditTalentMeetingViewModel
        
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
                        .disabled(true)
                        .onChange(of: viewModel.pricePerPeople, perform: { value in
                            viewModel.rawPrice = viewModel.pricePerPeople.replacingOccurrences(of: ".", with: "")
                            viewModel.meetingForm.price = Int(viewModel.rawPrice).orZero()
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
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .foregroundStyle(Color.DinotisDefault.black3.opacity(0.1))
                    )
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
                        Picker(selection: $viewModel.meetingForm.managementId) {
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
                        .onChange(of: viewModel.meetingForm.managementId) { val in
                            viewModel.selectedWallet = val == nil ?
                            LocalizableText.personalWalletText :
                            viewModel.managements?.first(where: {
                                $0.management?.id == val
                            })?.management?.user?.name
                        }
                        .onAppear {
                            viewModel.selectedWallet = viewModel.meetingForm.managementId == nil ?
                            LocalizableText.personalWalletText :
                            viewModel.managements?.first(where: {
                                $0.management?.id == viewModel.meetingForm.managementId
                            })?.management?.user?.name
                        }
                    }
                    .disabled(true)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .foregroundStyle(Color.DinotisDefault.black3.opacity(0.1))
                    )
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
                        if viewModel.pricePerPeople.isEmpty {
                            if !viewModel.isShowPriceEmptyWarning {
                                viewModel.getThreeSecondTime()
                            }
                        } else {
                            viewModel.isShowAppCostsManagement.toggle()
                        }
                    } label: {
                        HStack(spacing: 10) {
                            if viewModel.isChangedCostManagement {
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
                    .opacity(0.5)
                    .disabled(true)
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
                            Text("\(((Double(viewModel.rawPrice).orZero()*Double(viewModel.peopleGroup).orZero())-viewModel.creatorEstimated()).toCurrency())")
                                .font(.robotoBold(size: 14))
                                .foregroundStyle(Color.DinotisDefault.primary)
                        }
                    }
                    .padding([.horizontal, .bottom], 16)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
                )
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
    
    struct ScheduleSetupForm: View {
        
        @EnvironmentObject var viewModel: EditTalentMeetingViewModel
        
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
                    
                    TextField(LocaleText.exampleFormTitlePlaceholder, text: $viewModel.meetingForm.title)
                        .font(.robotoRegular(size: 12))
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .padding(.vertical, 15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
                        )
                        .disabled(viewModel.isDisableEdit)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .foregroundStyle(viewModel.isDisableEdit ? Color.DinotisDefault.black3.opacity(0.1) : Color.clear)
                        )
                    
                    MultilineTextField(text: $viewModel.meetingForm.description)
                        .foregroundColor(.black)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
                        )
                        .disabled(viewModel.isDisableEdit)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .foregroundStyle(viewModel.isDisableEdit ? Color.DinotisDefault.black3.opacity(0.1) : Color.clear)
                        )
                    
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
                
                if !viewModel.meetingForm.isPrivate {
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
                            .tint(.DinotisDefault.primary)
                            .disabled(viewModel.isDisableEdit)
                    }
                    .padding(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .foregroundStyle(viewModel.isDisableEdit ? Color.DinotisDefault.black3.opacity(0.1) : Color.clear)
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
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .foregroundStyle(viewModel.isDisableEdit ? Color.DinotisDefault.black3.opacity(0.1) : Color.clear)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
                    )
                    .disabled(viewModel.isDisableEdit)
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
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .foregroundStyle(viewModel.isDisableEdit ? Color.DinotisDefault.black3.opacity(0.1) : Color.clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
                        )
                        .disabled(viewModel.isDisableEdit)
                        
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
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .foregroundStyle(viewModel.isDisableEdit ? Color.DinotisDefault.black3.opacity(0.1) : Color.clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
                        )
                        .disabled(viewModel.isDisableEdit)
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
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .foregroundStyle(viewModel.isDisableEdit ? Color.DinotisDefault.black3.opacity(0.1) : Color.clear)
                                )
                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0))
                                .onChange(of: viewModel.selectedSession) { val in
                                    viewModel.meetingForm.isPrivate = val.contains(LocaleText.privateCallLabel)
                                }
                                .onAppear {
                                    viewModel.selectedSession = viewModel.meetingForm.isPrivate ? LocaleText.privateCallLabel : LocaleText.groupcallLabel
                                }
                            }
                            .disabled(viewModel.isDisableEdit)
                            
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
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .foregroundStyle(viewModel.isDisableEdit ? Color.DinotisDefault.black3.opacity(0.1) : Color.clear)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
                                    )
                                    .frame(width: 95)
                                    .keyboardType(.numberPad)
                                    .valueChanged(value: viewModel.peopleGroup) { value in
                                        viewModel.onPeopleOnGroupChanges(value)
                                    }
                                    .disabled(viewModel.isDisableEdit)
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
                    if !viewModel.meetingForm.isPrivate {
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
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .foregroundStyle(viewModel.isDisableEdit ? Color.DinotisDefault.black3.opacity(0.1) : Color.clear)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
                            )
                            .disabled(viewModel.isDisableEdit)
                            
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
                                            .disabled(viewModel.isDisableEdit)
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
                                                    let usernameIndex = (self.viewModel.meetingForm.collaborations ?? []).firstIndex(where: {
                                                        $0 == (talent.user?.username).orEmpty()
                                                    }).orZero()
                                                    
                                                    self.viewModel.talent.remove(at: index)
                                                    self.viewModel.meetingForm.collaborations?.remove(at: usernameIndex)
                                                    
                                                } label: {
                                                    Image(systemName: "xmark")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(height: 10)
                                                        .foregroundColor(.gray)
                                                        .font(.system(size: 10, weight: .bold))
                                                }
                                                .disabled(viewModel.isDisableEdit)
                                                .isHidden(viewModel.isDisableEdit, remove: viewModel.isDisableEdit)
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
                                    viewModel.meetingForm.urls.append(MeetingURLrequest(title: "", url: ""))
                                }
                            } label: {
                                Text(LocalizableText.addUrlLinkLabel)
                                    .font(.robotoMedium(size: 14))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.DinotisDefault.primary)
                            }
                            .disabled(viewModel.isDisableEdit)
                            .isHidden(viewModel.isDisableEdit, remove: viewModel.isDisableEdit)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(viewModel.meetingForm.urls.indices, id: \.self) { index in
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
                                        viewModel.meetingForm.urls.remove(at: index)
                                    } label: {
                                        Text(LocalizableText.deleteUrlLinkLabel)
                                            .font(.robotoBold(size: 10))
                                            .foregroundColor(.DinotisDefault.primary)
                                    }
                                    .disabled(viewModel.isDisableEdit)
                                    .isHidden(viewModel.isDisableEdit, remove: viewModel.isDisableEdit)
                                }
                                
                                TextField(LocalizableText.urlLinkTitlePlaceholder, text: $viewModel.meetingForm.urls[index].title)
                                    .font(.robotoRegular(size: 12))
                                    .disableAutocorrection(true)
                                    .foregroundColor(.black)
                                    .accentColor(.black)
                                    .padding(.horizontal)
                                    .padding(.vertical, 15)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .foregroundStyle(viewModel.isDisableEdit ? Color.DinotisDefault.black3.opacity(0.1) : Color.clear)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
                                    )
                                    .disabled(viewModel.isDisableEdit)
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    TextField(LocalizableText.urlLinkText, text: $viewModel.meetingForm.urls[index].url)
                                        .font(.robotoRegular(size: 12))
                                        .disableAutocorrection(true)
                                        .foregroundColor(.black)
                                        .accentColor(.black)
                                        .padding(.horizontal)
                                        .padding(.vertical, 15)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .foregroundStyle(viewModel.isDisableEdit ? Color.DinotisDefault.black3.opacity(0.1) : Color.clear)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
                                        )
                                        .disabled(viewModel.isDisableEdit)
                                    
                                    if !viewModel.meetingForm.urls[index].url.validateURL() {
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
        
        @EnvironmentObject var viewModel: EditTalentMeetingViewModel
        
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
                        viewModel.meetingForm.startAt = DateUtils.dateFormatter(viewModel.changedStartDate, forFormat: .utcV2)
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
        
        @EnvironmentObject var viewModel: EditTalentMeetingViewModel
        
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
                        viewModel.meetingForm.startAt = DateUtils.dateFormatter(viewModel.changedStartDate, forFormat: .utcV2)
                        
                        if viewModel.meetingForm.endAt.isEmpty || viewModel.endDate.orCurrentDate() < viewModel.changedStartDate {
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
        
        @EnvironmentObject var viewModel: EditTalentMeetingViewModel
        
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
                        viewModel.meetingForm.endAt = DateUtils.dateFormatter(viewModel.changedEndDate, forFormat: .utcV2)
                        viewModel.showsTimeUntilPicker = false
                        
                        if viewModel.meetingForm.startAt.isEmpty {
                            viewModel.meetingForm.startAt = DateUtils.dateFormatter(viewModel.startDate.orCurrentDate(), forFormat: .utcV2)
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
