//
//  TalentTransactionFeeView.swift
//  DinotisApp
//
//  Created by Gus Adi on 09/09/21.
//

import SwiftUI
import SwiftUITrackableScrollView
import CurrencyFormatter
import DinotisDesignSystem

struct TalentTransactionFeeView: View {
	@State var colorTab = Color.clear
	@State var contentOffset: CGFloat = 0
	
	@Binding var data: BalanceDetails?
	
	@Environment(\.presentationMode) var presentationMode
	
	var body: some View {
		ZStack {
			Image("user-type-bg")
				.resizable()
				.edgesIgnoringSafeArea(.all)
			
			VStack(spacing: 0) {
				VStack(spacing: 0) {
					colorTab
						.frame(height: 20)
					
					HStack {
						Button(action: {
							presentationMode.wrappedValue.dismiss()
						}, label: {
							Image("ic-chevron-back")
								.padding()
								.background(Color.white)
								.clipShape(Circle())
						})
						
						Spacer()
						
						Text(NSLocalizedString("revenue", comment: ""))
							.font(.robotoBold(size: 14))
							.padding(.horizontal)
						
						Spacer()
						Spacer()
					}
					.padding()
					.background(colorTab)
				}
				
				TrackableScrollView(.vertical, showIndicators: false, contentOffset: $contentOffset) {
					VStack {
						VStack(alignment: .leading) {
							HStack {
								Image("ic-fee-talent")
									.resizable()
									.scaledToFit()
									.frame(height: 40)
								
								VStack(alignment: .leading, spacing: 5) {
									Text(NSLocalizedString("revenue", comment: ""))
										.font(.robotoBold(size: 14))
										.foregroundColor(.black)
									
									if let dateISO = data?.createdAt {
                                        Text(DateUtils.dateFormatter(dateISO, forFormat: .EEEEddMMMMyyyy))
											.font(.robotoRegular(size: 12))
											.foregroundColor(.black)
									}
								}
								
								Spacer()
								
								Text("+ \((data?.amount?.numberString).orEmpty().toCurrency())")
									.font(.robotoBold(size: 14))
									.foregroundColor(.green)
							}
							
							Divider()
								.padding(.vertical, 10)
							
							HStack {
								Text("Ngobrol seru bareng kamu")
									.font(.robotoBold(size: 14))
									.foregroundColor(.black)
								
								Spacer()
							}
							.padding(.bottom, 5)
							
							VStack(alignment: .leading) {
								HStack(spacing: 10) {
									Image("ic-calendar")
										.resizable()
										.scaledToFit()
										.frame(height: 18)
									
									Text("date")
                                        .font(.robotoRegular(size: 12))
										.foregroundColor(.black)
								}
								
								HStack(spacing: 10) {
									Image("ic-clock")
										.resizable()
										.scaledToFit()
										.frame(height: 18)
									
									Text("time")
                                        .font(.robotoRegular(size: 12))
										.foregroundColor(.black)
								}
								
								VStack(alignment: .leading, spacing: 20) {
									HStack(spacing: 10) {
										Image("ic-people-circle")
											.resizable()
											.scaledToFit()
											.frame(height: 18)
										
										Text("0/1 \(NSLocalizedString("participant", comment: ""))")
                                            .font(.robotoRegular(size: 12))
											.foregroundColor(.black)
										
										//                                        if 0 > 1 {
										//											Text("group")
										//                                                .font(Font.custom(FontManager.Montserrat.regular, size: 12))
										//                                                .foregroundColor(.black)
										//                                                .padding(.vertical, 5)
										//                                                .padding(.horizontal)
										//                                                .background(Color("btn-color-1"))
										//                                                .clipShape(Capsule())
										//                                                .overlay(
										//                                                    Capsule()
										//                                                        .stroke(Color("btn-stroke-1"), lineWidth: 1.0)
										//                                                )
										//                                        } else {
										//											Text("private")
										//                                                .font(Font.custom(FontManager.Montserrat.regular, size: 12))
										//                                                .foregroundColor(.black)
										//                                                .padding(.vertical, 5)
										//                                                .padding(.horizontal)
										//                                                .background(Color("btn-color-1"))
										//                                                .clipShape(Capsule())
										//                                                .overlay(
										//                                                    Capsule()
										//                                                        .stroke(Color("btn-stroke-1"), lineWidth: 1.0)
										//                                                )
										//                                        }
									}
								}
							}
						}
						.padding()
						.background(Color.white)
						.clipShape(RoundedRectangle(cornerRadius: 12))
						.shadow(color: Color("dinotis-shadow-1").opacity(0.1), radius: 10, x: 0.0, y: 0.0)
						.padding(.top, 10)
					}
					.padding()
					.valueChanged(value: contentOffset) { val in
						colorTab = val > 0 ? Color.white : Color.clear
					}
				}
			}
			.edgesIgnoringSafeArea(.vertical)
		}
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
	}
}
