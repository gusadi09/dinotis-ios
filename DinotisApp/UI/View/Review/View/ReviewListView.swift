//
//  ReviewListView.swift
//  DinotisApp
//
//  Created by Irham Naufal on 06/10/23.
//

import DinotisDesignSystem
import SwiftUI

struct ReviewListView: View {
    
    @EnvironmentObject var viewModel: ReviewListViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(
                type: .textHeader,
                title: LocalizableText.talentDetailReviews,
                headerColor: .white,
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
                                    .shadow(color: /*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/.opacity(0.05), radius: 10, x: 0, y: 0)
                            )
                    }
                })
            
            FilterReviewView(viewModel: viewModel)
            
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(viewModel.data, id: \.id) { item in
                        ReviewCellView(data: item)
                    }
                }
            }
            .background(Color.white.ignoresSafeArea())
        }
        .navigationBarTitle(Text(""))
        .navigationBarHidden(true)
    }
}

extension ReviewListView {
    struct FilterReviewView: View {
        
        @ObservedObject var viewModel: ReviewListViewModel
        
        var body: some View {
            VStack(spacing: 0) {
                Divider()
                
                ScrollViewReader { scrollView in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(viewModel.tabSections, id: \.self) { tab in
                                Button {
                                    withAnimation {
                                        viewModel.currentSection = tab
                                        scrollView.scrollTo(tab, anchor: .center)
                                    }
                                } label: {
                                    Text(headerText(for: tab))
                                        .font(tab == viewModel.currentSection ? .robotoBold(size: 14) : .robotoRegular(size: 14))
                                        .foregroundColor(tab == viewModel.currentSection ? .DinotisDefault.primary : .DinotisDefault.black1)
                                        .frame(maxWidth: .infinity)
                                        .padding(12)
                                        .frame(maxHeight: 38)
                                        .cornerRadius(20)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(tab == viewModel.currentSection ? Color.DinotisDefault.lightPrimary : .white)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .inset(by: 0.5)
                                                .stroke(Color.DinotisDefault.lightPrimary, lineWidth: 1)
                                        )
                                }
                                .id(tab)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        
        private func headerText(for filter: ReviewFilter) -> String {
            switch filter {
            case .latest:
                return LocalizableText.sortLatest
            case .earliest:
                return LocalizableText.sortEarliest
            case .highest:
                return LocalizableText.reviewFilterHighestStar
            case .lowest:
                return LocalizableText.reviewFilterLowestStar
            }
        }
    }
    
    struct ReviewCellView: View {
        
        @State var data: DummyReviewModel
        @State var isShowFull = false
        
        var body: some View {
            VStack(spacing: 0) {
                Divider()
                
                HStack(alignment: .top, spacing: 12) {
                    DinotisImageLoader(urlString: data.profilePicture)
                        .scaledToFill()
                        .frame(width: 48, height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top, spacing: 8) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(data.name)
                                    .font(.robotoBold(size: 12))
                                
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(data.review.review.orEmpty())
                                        .font(.robotoRegular(size: 12))
                                        .lineLimit(isShowFull ? nil : 2)
                                        .isHidden(data.review.review.orEmpty().isEmpty, remove: data.review.review.orEmpty().isEmpty)
                                    
                                    Button(action: {
                                        withAnimation {
                                            isShowFull.toggle()
                                        }
                                    }, label: {
                                        Text(isShowFull ?
                                             LocalizableText.bookingRateCardHideFullText :
                                                LocalizableText.bookingRateCardShowFullText
                                        )
                                        .font(.robotoBold(size: 12))
                                        .foregroundColor(.DinotisDefault.primary)
                                    })
                                    .isHidden(
                                        data.review.review.orEmpty().count < 150,
                                        remove: data.review.review.orEmpty().count < 150
                                    )
                                }
                            }
                            .foregroundColor(.DinotisDefault.black1)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack(spacing: 6) {
                                Image.feedbackStarYellow
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 14, height: 14)
                                
                                Text("\(data.review.rating.orZero())")
                                    .font(.robotoBold(size: 12))
                                    .foregroundColor(.DinotisDefault.primary)
                            }
                            .padding(7)
                            .padding(.horizontal, 3)
                            .background(
                                Capsule()
                                    .foregroundColor(.DinotisDefault.lightPrimary)
                            )
                            .overlay(
                                Capsule()
                                    .inset(by: 0.5)
                                    .stroke(Color.DinotisDefault.primary.opacity(0.4), lineWidth: 1)
                            )
                        }
                        
                        Text("+ \(data.review.tip.orZero().toDecimal()) Tip")
                            .font(.robotoBold(size: 12))
                            .foregroundColor(.DinotisDefault.green)
                            .isHidden(data.review.tip.orZero() == 0, remove: data.review.tip.orZero() == 0)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(data.title)
                                    .font(.robotoBold(size: 12))
                                    .foregroundColor(.DinotisDefault.black2)
                                
                                Text(data.description)
                                    .font(.robotoRegular(size: 12))
                                    .foregroundColor(.DinotisDefault.black3)
                            }
                            .lineLimit(1)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundColor(.DinotisDefault.black3.opacity(0.2))
                            )
                            
                            Text(countHourTime(time: data.review.createdAt.orCurrentDate()))
                                .font(.robotoRegular(size: 12))
                                .foregroundColor(.DinotisDefault.black3)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(16)
            }
        }
        
        private func countHourTime(time: Date) -> String {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            formatter.locale = Locale.current
            return formatter.localizedString(for: time, relativeTo: Date())
        }
    }
}

#Preview {
    ReviewListView()
        .environmentObject(ReviewListViewModel())
}
