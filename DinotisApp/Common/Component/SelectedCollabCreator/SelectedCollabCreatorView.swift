//
//  SelectedCollabCreatorView.swift
//  DinotisApp
//
//  Created by Gus Adi on 26/04/23.
//

import SwiftUI
import DinotisData
import DinotisDesignSystem

struct SelectedCollabCreatorView: View {
    
    @State var searchText = ""
    let isEdit: Bool
    @Binding var arrUsername: [String]?
    @Binding var arrTalent: [MeetingCollaborationData]
    
    var back: () -> Void
    
    init(isEdit: Bool = true, arrUsername: Binding<[String]?>, arrTalent: Binding<[MeetingCollaborationData]>, back: @escaping () -> Void) {
        self.isEdit = isEdit
        self._arrUsername = arrUsername
        self._arrTalent = arrTalent
        self.back = back
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(LocalizableText.creatorInvitedCollabTitle)
                    .font(.robotoMedium(size: 14))

                Spacer()
                Button(action: {
                    back()
                }, label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 10)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                })
            }
            .padding(.horizontal)
            .padding(.top)

            Group {
                if isEdit {
                    HStack(spacing: 15) {
                        Image.Dinotis.magnifyingIcon
                        
                        TextField(LocalizableText.searchCreatorPlaceholder, text: $searchText)
                            .font(.robotoRegular(size: 12))
                            .autocapitalization(.words)
                            .disableAutocorrection(true)
                            .accentColor(.black)
                    }
                    .padding()
                    .background(Color.backgroundProfile)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1.0)
                    )
                    .padding(.horizontal)
                }
            }
            .padding(.top, 10)
            
            ScrollView(.vertical, showsIndicators: false, content: {
                LazyVStack {
                    ForEach(arrTalent.filter({
                        (
                            $0.user?.name
                        ).orEmpty().lowercased().contains(searchText.lowercased()) ||
                        (
                            $0.user?.username
                        ).orEmpty().lowercased().contains(searchText.lowercased()) ||
                        searchText.isEmpty
                    }), id: \.id) { items in
                        HStack {
                            ImageLoader(url: (items.user?.profilePhoto).orEmpty(), width: 30, height: 30)
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text((items.user?.name).orEmpty())
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(.black)
                                
                                Text((items.user?.stringProfessions?.first).orEmpty())
                                    .font(.robotoMedium(size: 10))
                                    .foregroundColor(.gray)
                            }
                            .multilineTextAlignment(.leading)
                            
                            Spacer()
                            
                            if items.declinedAt != nil && items.approvedAt == nil {
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
                            } else if items.declinedAt == nil && items.approvedAt != nil {
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
                            
                            if isEdit {
                                Button {
                                    let index = self.arrTalent.firstIndex {
                                        $0.user?.id == items.user?.id
                                    }.orZero()
                                    let usernameIndex = (self.arrUsername ?? []).firstIndex(where: {
                                        $0 == (items.user?.username).orEmpty()
                                    }).orZero()
                                    
                                    self.arrTalent.remove(at: index)
                                    self.arrUsername?.remove(at: usernameIndex)
                                    
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
                .padding()
            })
        }
    }
}

struct SelectedCollabCreatorView_Previews: PreviewProvider {
    static var previews: some View {
        SelectedCollabCreatorView(arrUsername: .constant([]), arrTalent: .constant([]), back: {})
    }
}
