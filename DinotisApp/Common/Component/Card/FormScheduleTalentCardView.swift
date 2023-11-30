//
//  FormScheduleTalentCardView.swift
//  DinotisApp
//
//  Created by Gus Adi on 19/08/21.
//

import SwiftUI
import DinotisDesignSystem
import DinotisData

struct FormScheduleTalentCardView: View {
    @Binding var collab: [MeetingCollaborationData]
    @Binding var managements: [ManagementWrappedData]?
    @Binding var meetingForm: AddMeetingRequest
    @Binding var maxEdit: Int
    
    @State var selectedWallet: String? = nil
    @State var isPresent = false
    @State var timeStart: Date?
    @State var timeEnd: Date?
    @State var showsDatePicker = false
    @State var showsTimePicker = false
    @State var showsTimeUntilPicker = false
    @State var sessionPresent = false
    @State var peopleGroup = ""
    @State var estPrice = 0
    @State var pricePerPeople = ""
    
    @State var isShowSelectedTalent = false
    @State var talent = [MeetingCollaborationData]()
    
    @State var presentTalentPicker = false
    
    @State var isValidPersonForGroup = false
  
    @State var isShowAdditionalMenu = false
    
    @State var changedTimeStart: Date = Date()
    @State var changedTimeEnd: Date = Date().addingTimeInterval(3600)
    @State var changedDate: Date = Date()
    
    var arrSession = [LocaleText.privateCallLabel, LocaleText.groupcallLabel]
    var walletLocal = [
        ManagementWrappedData(
            id: nil,
            managementId: nil,
            userId: nil,
            management: UserDataOfManagement(
                createdAt: nil,
                id: nil,
                updatedAt: nil,
                user: ManagementTalentData(
                    id: nil,
                    name: LocalizableText.personalWalletText,
                    username: nil,
                    profilePhoto: nil,
                    profileDescription: nil,
                    professions: nil,
                    userHighlights: nil,
                    isVerified: nil,
                    isVisible: nil,
                    isActive: nil,
                    stringProfessions: nil
                ),
                userId: nil
            )
        )
    ]
    
    var onTapRemove: (() -> Void)
    
    var isShowRemove: Bool = false
    
    var isEdit: Bool
    var disableEdit: Bool
    
    @State var selected = ""
    
    init(collab: Binding<[MeetingCollaborationData]>, managements: Binding<[ManagementWrappedData]?>, meetingForm: Binding<AddMeetingRequest>, onTapRemove: @escaping (() -> Void), isShowRemove: Bool = false, isEdit: Bool, disableEdit: Bool = false, maxEdit: Binding<Int>) {
        self._collab = collab
        self._managements = managements
        self._meetingForm = meetingForm
        self._maxEdit = maxEdit
        self.onTapRemove = onTapRemove
        self.isShowRemove = isShowRemove
        self.isEdit = isEdit
        self.disableEdit = disableEdit
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 20) {
                    if let attr = try? AttributedString(markdown: LocalizableText.creatorRescheduleWarning(maxEdit)) {
                        Text(attr)
                            .font(.robotoRegular(size: 12))
                            .foregroundColor(.DinotisDefault.darkPrimary)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 11)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundColor(.DinotisDefault.lightPrimary)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .inset(by: 0.5)
                                    .stroke(Color.DinotisDefault.darkPrimary, lineWidth: 1)
                            )
                            .isHidden(!isEdit, remove: !isEdit)
                    }
                    
                    VStack(spacing: 10) {
                        HStack {
                            Image("ic-vidcall-form")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 11)
                            
                            Text(NSLocalizedString("title_description", comment: ""))
                                .font(.robotoMedium(size: 12))
                                .foregroundColor(.black)
                            
                            Spacer()
                        }
                        
                        VStack {
                            TextField(NSLocalizedString("example_title", comment: ""), text: $meetingForm.title)
                                .font(.robotoRegular(size: 12))
                                .autocapitalization(.words)
                                .disableAutocorrection(true)
                                .foregroundColor(.black)
                                .accentColor(.black)
                                .padding(.horizontal)
                                .padding(.vertical, 15)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .foregroundColor(.gray.opacity(disableEdit ? 0.1 : 0))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
                                )
                            
                            MultilineTextField(text: $meetingForm.description)
                                .foregroundColor(.black)
                                .accentColor(.black)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .foregroundColor(.gray.opacity(disableEdit ? 0.1 : 0))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
                                )
                        }
                    }
                    
                    VStack(spacing: 10) {
                        HStack {
                            Image("ic-calendar")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 20)
                            
                            Text(NSLocalizedString("select_date", comment: ""))
                                .font(.robotoMedium(size: 12))
                                .foregroundColor(.black)
                            
                            Spacer()
                        }
                        
                        HStack {
                            Text("\(DateUtils.dateFormatter(timeStart.orCurrentDate(), forFormat: .slashddMMyyyy))")
                                .font(.robotoRegular(size: 12))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Image("ic-chevron-bottom")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 15)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .contentShape(Rectangle())
                        .padding(.horizontal)
                        .padding(.vertical, 15)
                        .onTapGesture {
                            self.showsDatePicker.toggle()
                            self.showsTimePicker = false
                            self.showsTimeUntilPicker = false
                            self.sessionPresent = false
                            self.presentTalentPicker = false
                            UIApplication.shared.endEditing()
                        }
                        .background(disableEdit ? Color.gray.opacity(0.1) : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
                        )
                    }
                    
                    VStack(spacing: 10) {
                        HStack {
                            Image("ic-clock")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 20)
                            
                            Text(NSLocalizedString("select_time", comment: ""))
                                .font(.robotoMedium(size: 12))
                                .foregroundColor(.black)
                            
                            Spacer()
                        }
                        
                        HStack {
                            HStack {
                                Text("\(DateUtils.dateFormatter(timeStart.orCurrentDate(), forFormat: .HHmm))")
                                    .font(.robotoRegular(size: 12))
                                    .foregroundColor(.black)
                                    .valueChanged(value: timeStart.orCurrentDate()) { value in
                                        if meetingForm.endAt.isEmpty {
                                            timeEnd = value.addingTimeInterval(3600)
                                            meetingForm.endAt = DateUtils.dateFormatter(timeEnd.orCurrentDate(), forFormat: .utcV2)
                                        }
                                    }
                                    .valueChanged(value: changedTimeStart) { value in
                                        timeEnd = value.addingTimeInterval(3600)
                                        meetingForm.endAt = DateUtils.dateFormatter(timeEnd.orCurrentDate(), forFormat: .utcV2)
                                    }
                                
                                Spacer()
                                
                                Image("ic-chevron-bottom")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 15)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .contentShape(Rectangle())
                            .padding(.horizontal)
                            .padding(.vertical, 15)
                            .onTapGesture {
                                self.presentTalentPicker = false
                                self.showsTimePicker.toggle()
                                self.showsTimeUntilPicker = false
                                self.sessionPresent = false
                                UIApplication.shared.endEditing()
                            }
                            .background(disableEdit ? Color.gray.opacity(0.1) : Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
                            )
                            
                            
                            HStack {
                                Text("\(DateUtils.dateFormatter(timeEnd.orCurrentDate(), forFormat: .HHmm))")
                                    .font(.robotoRegular(size: 12))
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Image("ic-chevron-bottom")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 15)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .contentShape(Rectangle())
                            .padding(.horizontal)
                            .padding(.vertical, 15)
                            .onTapGesture {
                                self.presentTalentPicker = false
                                self.showsTimeUntilPicker.toggle()
                                self.showsTimePicker = false
                                self.sessionPresent = false
                                UIApplication.shared.endEditing()
                            }
                            .background(disableEdit ? Color.gray.opacity(0.1) : Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
                            )
                            
                        }
                    }
                    .onAppear {
                        if meetingForm.startAt.isEmpty {
                            timeStart = DateUtils.dateFormatter(meetingForm.startAt, forFormat: .utcV2).addingTimeInterval(3600)
                            timeEnd = timeStart?.addingTimeInterval(3600)
                        } else {
                            timeStart = DateUtils.dateFormatter(meetingForm.startAt, forFormat: .utcV2)
                            timeEnd = DateUtils.dateFormatter(meetingForm.endAt, forFormat: .utcV2).addingTimeInterval(3600)
                        }
                        
                        selected = meetingForm.isPrivate ? LocaleText.privateCallLabel : LocaleText.groupcallLabel
                        
                        peopleGroup = meetingForm.isPrivate ? "1" : String(meetingForm.slots)
                        
                        pricePerPeople = String(meetingForm.price)
                        
                        isValidPersonForGroup = meetingForm.slots > 0
                        
                        selectedWallet = meetingForm.managementId == nil ?
                        LocalizableText.personalWalletText :
                        managements?.first(where: {
                            $0.management?.id == meetingForm.managementId
                        })?.management?.user?.name
                    }
                    .onChange(of: meetingForm.isPrivate) { value in
                        selected = value ? LocaleText.privateCallLabel : LocaleText.groupcallLabel
                        peopleGroup = value ? "1" : String(meetingForm.slots)
                    }
                    .onChange(of: meetingForm.slots) { newValue in
                        peopleGroup = meetingForm.isPrivate ? "1" : String(newValue)
                        isValidPersonForGroup = meetingForm.slots > 0
                    }
                    .onChange(of: meetingForm.startAt) { newValue in
                        timeStart = DateUtils.dateFormatter(newValue, forFormat: .utcV2)
                    }
                    .onChange(of: meetingForm.endAt) { newValue in
                        timeEnd = DateUtils.dateFormatter(newValue, forFormat: .utcV2)
                    }
                    .onChange(of: meetingForm.price) { newValue in
                        pricePerPeople = String(newValue)
                    }
                    
                    VStack(spacing: 10) {
                        HStack {
                            Image("ic-session")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 20)
                            
                            Text(NSLocalizedString("select_session_type", comment: ""))
                                .font(.robotoMedium(size: 12))
                                .foregroundColor(.black)
                            
                            Spacer()
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Menu {
                                    Picker(selection: $selected) {
                                        ForEach(arrSession, id: \.self) { item in
                                            Text(item)
                                                .tag(item)
                                        }
                                    } label: {
                                        EmptyView()
                                    }
                                } label: {
                                    HStack(spacing: 10) {
                                        Text(selected)
                                            .lineLimit(1)
                                            .font(.robotoRegular(size: 12))
                                            .foregroundColor(.black)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.down")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 5)
                                            .foregroundColor(.black)
                                    }
                                    .padding(.horizontal, 15)
                                    .padding(.vertical)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundColor(disableEdit ? Color.gray.opacity(0.1) : .white)
                                    )
                                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0))
                                    .onChange(of: selected) { val in
                                        meetingForm.isPrivate = val == NSLocalizedString("private_call_label", comment: "")
                                    }
                                }
                                
                                if selected == NSLocalizedString("group_call_label", comment: "") {
                                    TextField(NSLocalizedString("set_participant", comment: ""), text: $peopleGroup)
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
                                                .foregroundColor(.gray.opacity(disableEdit ? 0.1 : 0))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
                                        )
                                        .frame(width: 95)
                                        .keyboardType(.numberPad)
                                        .valueChanged(value: peopleGroup) { value in
                                            if let intVal = Int(value) {
                                                meetingForm.slots = intVal
                                                
                                                let intPeople = Int(peopleGroup)
                                                let intPrice = Int(pricePerPeople)
                                                estPrice = (intPrice ?? 0) * (intPeople ?? 0)
                                                
                                                isValidPersonForGroup = Int(value).orZero() > 0
                                            }
                                        }
                                }
                            }
                            
                            if !isValidPersonForGroup && selected == NSLocalizedString("group_call_label", comment: "") {
                                HStack {
                                    Image.Dinotis.exclamationCircleIcon
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 10)
                                        .foregroundColor(.red)
                                    Text(LocalizableText.createSessionMinimumParticipantAlert)
                                        .font(.robotoRegular(size: 10))
                                        .foregroundColor(.red)
                                    
                                    Spacer()
                                }
                            }
                        }
                    }
                    
                    VStack(spacing: 10) {
                        HStack {
                            Image("ic-pricetag")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 20)
                            
                            Text(NSLocalizedString("set_cost", comment: ""))
                                .font(.robotoMedium(size: 12))
                                .foregroundColor(.black)
                            
                            Spacer()
                        }
                        
                        VStack {
                            HStack {
                                Text("Rp")
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(.black)
                                
                                TextField(NSLocalizedString("enter_cost_label", comment: ""), text: $pricePerPeople, onCommit: {
                                    let intPeople = Int(peopleGroup)
                                    let intPrice = Int(pricePerPeople)
                                    estPrice = (intPrice ?? 0) * (intPeople ?? 0)
                                })
                                .disabled(isEdit)
                                .font(.robotoRegular(size: 12))
                                .autocapitalization(.words)
                                .disableAutocorrection(true)
                                .keyboardType(.numberPad)
                                .foregroundColor(.black)
                                .accentColor(.black)
                                .valueChanged(value: pricePerPeople) { value in
                                    if let intPrice = Int(value) {
                                        meetingForm.price = intPrice
                                        
                                        let intPeople = Int(peopleGroup)
                                        let intPrice = Int(pricePerPeople)
                                        estPrice = (intPrice ?? 0) * (intPeople ?? 0)
                                        
                                    }
                                }
                                
                                if selected == NSLocalizedString("group_call_label", comment: "") {
                                    Text(NSLocalizedString("per_person", comment: ""))
                                        .font(.robotoMedium(size: 12))
                                        .foregroundColor(Color("btn-stroke-1"))
                                }
                                
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 15)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .foregroundColor(isEdit ? .gray.opacity(0.1) : .white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
                            )
                        }
                        
                        if selected == NSLocalizedString("group_call_label", comment: "") {
                            HStack(spacing: 5) {
                                Text(NSLocalizedString("estimated_revenue", comment: ""))
                                    .font(.robotoMedium(size: 10))
                                    .foregroundColor(.black)
                                
                                Text("Rp\(estPrice)")
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(Color("btn-stroke-1"))
                                Spacer()
                            }
                        }
                    }
                    
                    VStack(spacing: 10) {
                        HStack {
                            Image("ic-pricetag")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 20)
                            
                            Text(LocalizableText.revenuePurposeText)
                                .font(.robotoMedium(size: 12))
                                .foregroundColor(.black)
                            
                            Spacer()
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Menu {
                                    Picker(selection: $meetingForm.managementId) {
                                        ForEach(walletLocal, id: \.id) { item in
                                            Text((item.management?.user?.name).orEmpty())
                                                .tag(item.management?.id)
                                        }
                                        
                                        ForEach(managements ?? [], id: \.id) { item in
                                            Text((item.management?.user?.name).orEmpty())
                                                .tag(item.management?.id)
                                        }
                                    } label: {
                                        EmptyView()
                                    }
                                } label: {
                                    HStack(spacing: 10) {
                                        Text(selectedWallet.orEmpty())
                                            .lineLimit(1)
                                            .font(.robotoRegular(size: 12))
                                            .foregroundColor(.black)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.down")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 5)
                                            .foregroundColor(.black)
                                    }
                                    .padding(.horizontal, 15)
                                    .padding(.vertical)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundColor(disableEdit ? .gray.opacity(0.1) : .white)
                                    )
                                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0))
                                    .onChange(of: meetingForm.managementId) { val in
                                        selectedWallet = val == nil ?
                                        LocalizableText.personalWalletText :
                                        managements?.first(where: {
                                            $0.management?.id == val
                                        })?.management?.user?.name
                                    }
                                }
                            }
                        }
                    }
                    
                    if !meetingForm.isPrivate {
                        VStack(spacing: 10) {
                            HStack {
                                Image("ic-session")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 20)
                                
                                Text(LocalizableText.collaborationTitle)
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(.black)
                                
                                Spacer()
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
                                self.presentTalentPicker.toggle()
                                self.showsDatePicker = false
                                self.showsTimePicker = false
                                self.showsTimeUntilPicker = false
                                self.sessionPresent = false
                                UIApplication.shared.endEditing()
                            }
                            .background(disableEdit ? Color.gray.opacity(0.1) : Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
                            )
                            
                            if isEdit {
                                if !collab.isEmpty {
                                    VStack(spacing: 15) {
                                        HStack {
                                            Text(LocalizableText.invitedCreatorTitle)
                                                .font(.robotoMedium(size: 10))
                                                .foregroundColor(.black)
                                            
                                            Spacer()
                                            
                                            if collab.count > 3 {
                                                Button {
                                                    isShowSelectedTalent.toggle()
                                                } label: {
                                                    Text(LocalizableText.searchSeeAllLabel)
                                                        .font(.robotoMedium(size: 10))
                                                        .foregroundColor(.DinotisDefault.primary)
                                                        .underline()
                                                }
                                            }
                                        }
                                        
                                        VStack(spacing: 10) {
                                            ForEach(collab.prefix(3), id: \.id) { talent in
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
                                                        let index = self.collab.firstIndex {
                                                            $0.user?.id == talent.user?.id
                                                        }.orZero()
                                                        let usernameIndex = (self.meetingForm.collaborations ?? []).firstIndex(where: {
                                                            $0 == (talent.user?.username).orEmpty()
                                                        }).orZero()
                                                        
                                                        self.collab.remove(at: index)
                                                        self.meetingForm.collaborations?.remove(at: usernameIndex)
                                                        
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
                            } else {
                                if !talent.isEmpty {
                                    VStack(spacing: 15) {
                                        HStack {
                                            Text(LocalizableText.invitedCreatorTitle)
                                                .font(.robotoMedium(size: 10))
                                                .foregroundColor(.black)
                                            
                                            Spacer()
                                            
                                            if talent.count > 3 {
                                                Button {
                                                    isShowSelectedTalent.toggle()
                                                } label: {
                                                    Text(LocalizableText.searchSeeAllLabel)
                                                        .font(.robotoMedium(size: 10))
                                                        .foregroundColor(.DinotisDefault.primary)
                                                        .underline()
                                                }
                                            }
                                        }
                                        
                                        VStack(spacing: 10) {
                                            ForEach(talent.prefix(3), id: \.id) { talent in
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
                                                        let index = self.talent.firstIndex {
                                                            $0.user?.id == talent.user?.id
                                                        }.orZero()
                                                        let usernameIndex = (self.meetingForm.collaborations ?? []).firstIndex(where: {
                                                            $0 == (talent.user?.username).orEmpty()
                                                        }).orZero()
                                                        
                                                        self.talent.remove(at: index)
                                                        self.meetingForm.collaborations?.remove(at: usernameIndex)
                                                        
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
                        }
                    }
                  
                    if isShowAdditionalMenu {
                        VStack(spacing: 10) {
                            HStack {
                                Image("ic-pricetag")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 20)
                                
                                Text(LocalizableText.urlLinkText)
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Button {
                                    withAnimation(.spring(response: 0.2)) {
                                        meetingForm.urls.append(MeetingURLrequest(title: "", url: ""))
                                    }
                                } label: {
                                    Text(LocalizableText.addUrlLinkLabel)
                                        .font(.robotoBold(size: 11))
                                        .foregroundColor(.DinotisDefault.primary)
                                }
                                
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(meetingForm.urls.indices, id: \.self) { index in
                                    HStack {
                                        Text("\(LocalizableText.urlLinkText) \(index+1)")
                                            .font(.robotoMedium(size: 10))
                                            .foregroundColor(.black)
                                        
                                        Spacer()
                                        
                                        Button {
                                            meetingForm.urls.remove(at: index)
                                        } label: {
                                            Text(LocalizableText.deleteUrlLinkLabel)
                                                .font(.robotoBold(size: 10))
                                                .foregroundColor(.DinotisDefault.primary)
                                        }
                                    }
                                    
                                    TextField(LocalizableText.urlLinkTitlePlaceholder, text: $meetingForm.urls[index].title)
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
                                        TextField(LocalizableText.urlLinkText, text: $meetingForm.urls[index].url)
                                            .font(.robotoRegular(size: 12))
                                            .disableAutocorrection(true)
                                            .foregroundColor(.black)
                                            .accentColor(.black)
                                            .padding(.horizontal)
                                            .padding(.vertical, 15)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
                                            )
                                        
                                        if !meetingForm.urls[index].url.validateURL() {
                                            Text(LocalizableText.invalidUrlMessage)
                                                .foregroundColor(.red)
                                                .font(.robotoRegular(size: 10))
                                                .multilineTextAlignment(.leading)
                                        }
                                    }
                                    .padding(.bottom, 5)
                                    
                                }
                            }
                        }
                    }
                  
                  Button {
                    withAnimation(.spring(response: 0.2)) {
                      isShowAdditionalMenu.toggle()
                    }
                  } label: {
                    Text(isShowAdditionalMenu ? LocalizableText.hideAdditionalMenuLabel : LocalizableText.seeAdditionalMenuLabel)
                      .font(.robotoBold(size: 12))
                      .foregroundColor(.DinotisDefault.primary)
                      .padding(.top)
                  }

                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color("dinotis-shadow-1").opacity(0.07), radius: 10, x: 0.0, y: 0.0)
                .padding(.horizontal)
                
                Button {
                    onTapRemove()
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.red)
                        .frame(height: 25)
                }
                .padding(.trailing, 10)
                .isHidden(!isShowRemove, remove: !isShowRemove)
            }
            .sheet(isPresented: $isShowSelectedTalent, content: {
                if #available(iOS 16.0, *) {
                    SelectedCollabCreatorView(arrUsername: $meetingForm.collaborations, arrTalent: isEdit ? $collab : $talent) {
                        isShowSelectedTalent = false
                    }
                    .presentationDetents([.medium, .large])
                    .dynamicTypeSize(.large)
                } else {
                    SelectedCollabCreatorView(arrUsername: $meetingForm.collaborations, arrTalent: isEdit ? $collab : $talent) {
                        isShowSelectedTalent = false
                    }
                    .dynamicTypeSize(.large)
                }
            })
            .sheet(isPresented: $presentTalentPicker, content: {
                CreatorPickerView(arrUsername: $meetingForm.collaborations, arrTalent: isEdit ? $collab : $talent) {
                    presentTalentPicker = false
                }
                .dynamicTypeSize(.large)
            })
            .sheet(isPresented: $showsDatePicker) {
                if #available(iOS 16.0, *) {
                    ZStack {
                        VStack(alignment: .center, spacing: 0) {
                            DatePicker("", selection: $changedTimeStart, in: Date()..., displayedComponents: .date)
                                .datePickerStyle(WheelDatePickerStyle())
                                .labelsHidden()
                            
                            Spacer()
                            
                            Button(action: {
                                timeStart = changedTimeStart
                                meetingForm.startAt = DateUtils.dateFormatter(changedTimeStart, forFormat: .utcV2)
                                showsDatePicker = false
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
                            changedTimeStart = timeStart ?? Date().addingTimeInterval(3600)
                        }
                    }
                    .presentationDetents([.medium])
                    .dynamicTypeSize(.large)
                } else {
                    ZStack {
                        VStack(alignment: .center, spacing: 0) {
                            DatePicker("", selection: $changedTimeStart, in: Date()..., displayedComponents: .date)
                                .datePickerStyle(WheelDatePickerStyle())
                                .labelsHidden()
                            
                            Button(action: {
                                timeStart = changedTimeStart
                                meetingForm.startAt = DateUtils.dateFormatter(changedTimeStart, forFormat: .utcV2)
                                showsDatePicker = false
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
                            changedTimeStart = timeStart ?? Date().addingTimeInterval(3600)
                        }
                    }
                    .dynamicTypeSize(.large)
                }
            }
            .sheet(isPresented: $showsTimePicker) {
                if #available(iOS 16.0, *) {
                    ZStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Spacer()
                                
                                DatePicker("", selection: $changedTimeStart, in: Date()..., displayedComponents: .hourAndMinute)
                                    .datePickerStyle(WheelDatePickerStyle())
                                    .labelsHidden()
                                
                                Spacer()
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                timeStart = changedTimeStart
                                meetingForm.startAt = DateUtils.dateFormatter(changedTimeStart, forFormat: .utcV2)
                                showsTimePicker = false
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
                                if changedTimeStart < Date().addingTimeInterval(3600) {
                                    changedTimeStart = Date().addingTimeInterval(3600)
                                }
                            }
                        }
                        .padding()
                    }
                    .presentationDetents([.medium])
                    .dynamicTypeSize(.large)
                } else {
                    ZStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Spacer()
                                
                                DatePicker("", selection: $changedTimeStart, in: Date()..., displayedComponents: .hourAndMinute)
                                    .datePickerStyle(WheelDatePickerStyle())
                                    .labelsHidden()
                                
                                Spacer()
                            }
                            
                            Button(action: {
                                timeStart = changedTimeStart
                                meetingForm.startAt = DateUtils.dateFormatter(changedTimeStart, forFormat: .utcV2)
                                showsTimePicker = false
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
                                if changedTimeStart < Date().addingTimeInterval(3600) {
                                    changedTimeStart = Date().addingTimeInterval(3600)
                                }
                            }
                        }
                        .padding()
                    }
                    .dynamicTypeSize(.large)
                }
                
            }
            .sheet(isPresented: $showsTimeUntilPicker) {
                if #available(iOS 16.0, *) {
                    ZStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Spacer()
                                
                                DatePicker("", selection: $changedTimeEnd, in: timeStart.orCurrentDate()..., displayedComponents: .hourAndMinute)
                                    .datePickerStyle(WheelDatePickerStyle())
                                    .labelsHidden()
                                
                                Spacer()
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                timeEnd = changedTimeEnd
                                meetingForm.endAt = DateUtils.dateFormatter(changedTimeEnd, forFormat: .utcV2)
                                showsTimeUntilPicker = false
                                
                                if meetingForm.startAt.isEmpty {
                                    meetingForm.startAt = DateUtils.dateFormatter(timeStart.orCurrentDate(), forFormat: .utcV2)
                                }
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
                            if let timeStart = timeStart {
                                changedTimeEnd = timeStart.addingTimeInterval(3600)
                            } else {
                                changedTimeEnd = Date().addingTimeInterval(7200)
                            }
                        }
                    }
                    .presentationDetents([.medium])
                    .dynamicTypeSize(.large)
                } else {
                    ZStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Spacer()
                                
                                DatePicker("", selection: $changedTimeEnd, in: timeStart.orCurrentDate()..., displayedComponents: .hourAndMinute)
                                    .datePickerStyle(WheelDatePickerStyle())
                                    .labelsHidden()
                                
                                Spacer()
                            }
                            
                            Button(action: {
                                timeEnd = changedTimeEnd
                                meetingForm.endAt = DateUtils.dateFormatter(changedTimeEnd, forFormat: .utcV2)
                                showsTimeUntilPicker = false
                                
                                if meetingForm.startAt.isEmpty {
                                    meetingForm.startAt = DateUtils.dateFormatter(timeStart.orCurrentDate(), forFormat: .utcV2)
                                }
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
                            if let timeStart = timeStart {
                                changedTimeEnd = timeStart.addingTimeInterval(3600)
                            } else {
                                changedTimeEnd = Date().addingTimeInterval(7200)
                            }
                        }
                    }
                    .dynamicTypeSize(.large)
                }
                
            }
            
        }
        .disabled(isEdit && disableEdit)
    }
}

struct FormScheduleTalentCardView_Previews: PreviewProvider {
    static var previews: some View {
        FormScheduleTalentCardView(
            collab: .constant([]),
            managements: .constant([]),
            meetingForm: .constant(
                AddMeetingRequest(
                    title: "",
                    description: "",
                    price: 0, startAt: "",
                    endAt: "",
                    isPrivate: true,
                    slots: 0,
                    urls: [],
                    archiveRecording: false, collaboratorAudienceVisibility: false
                )
            ),
            onTapRemove: {},
            isEdit: false,
            maxEdit: .constant(0)
        )
    }
}
