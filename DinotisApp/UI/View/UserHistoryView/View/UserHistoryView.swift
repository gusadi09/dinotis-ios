//
//  UserHistoryView.swift
//  DinotisApp
//
//  Created by Gus Adi on 27/10/21.
//

import SwiftUI
import SwiftUINavigation
import OneSignal

struct UserHistoryView: View {
	@State var colorTab = Color.clear
	
	@Environment(\.presentationMode) var presentationMode
	
	@ObservedObject var usersVM = UsersViewModel.shared
	@ObservedObject var bookingVm = UserBookingViewModel.shared
	@ObservedObject var stateObservable = StateObservable.shared
	@ObservedObject var viewModel: UserHistoryViewModel
	
	@State var isShowConnection = false
	
	@State var isLoading = false

	@Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
	
	@State var meetings = UserMeeting(
		id: "",
		title: "",
		meetingDescription: "",
		price: "",
		startAt: "",
		endAt: "",
		isPrivate: false,
		slots: 0, userID: "",
		startedAt: nil,
		endedAt: nil,
		createdAt: "",
		updatedAt: "",
		deletedAt: nil,
		bookings: [],
		user: User(
			id: nil,
			name: nil,
			username: nil,
			email: nil,
			profilePhoto: nil,
			isVerified: nil
		)
	)
	
	@State var payments = UserBookingPayment(
		id: "",
		amount: "",
		bookingID: "",
		paymentMethodID: 0,
		externalId: nil,
		redirectUrl: nil,
		qrCodeUrl: nil
	)
	
	private var viewController: UIViewController? {
		self.viewControllerHolder.value
	}
	
	var body: some View {
		ZStack {
			Image("linear-gradient-bg")
				.resizable()
				.edgesIgnoringSafeArea(.all)
				.alert(isPresented: $isShowConnection) {
					Alert(
						title: Text(NSLocalizedString("attention", comment: "")),
						message: Text(NSLocalizedString("connection_warning", comment: "")),
						dismissButton: .cancel(Text(NSLocalizedString("return", comment: "")))
					)
				}
			
			VStack(spacing: 0) {
				VStack(spacing: 0) {
					colorTab
						.frame(height: 20)
					
					ZStack {
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
						}
						
						HStack {
							Spacer()
							Text(NSLocalizedString("video_call_history", comment: ""))
								.font(.custom(FontManager.Montserrat.bold, size: 14))
								.padding(.horizontal)
							Spacer()
						}
					}
					.padding()
					.background(colorTab)
					.alert(isPresented: $bookingVm.isRefreshFailed) {
						Alert(
							title: Text(NSLocalizedString("attention", comment: "")),
							message: Text(NSLocalizedString("session_expired", comment: "")),
							dismissButton: .default(Text(NSLocalizedString("return", comment: "")), action: {
								viewModel.backToRoot()
								stateObservable.userType = 0
								stateObservable.isVerified = ""
								stateObservable.refreshToken = ""
								stateObservable.accessToken = ""
								stateObservable.isAnnounceShow = false
								OneSignal.setExternalUserId("")
							}))
					}
				}
				
				ScrollViews(axes: .vertical, showsIndicators: false) { value in
					if value.y < -2 {
						colorTab = Color.white
					} else if value.y > 5 {
						colorTab = Color.clear
						bookingVm.getBookings()
					} else {
						colorTab = Color.clear
					}
				} content: {
					if isLoading {
						ActivityIndicator(isAnimating: $isLoading, color: .black, style: .medium)
					}
					
					if let data = bookingVm.data?.data.filter({ value in
						value.doneAt != nil ||
						value.canceledAt != nil ||
						(value.bookingPayment.failedAt != nil && value.meeting.startedAt != nil) ||
						(value.bookingPayment.failedAt != nil && !isStillShowing(date: (value.meeting.endAt?.toDate(format: .utcV2)).orCurrentDate())) ||
						value.meeting.endedAt != nil
					}) {
						if data.isEmpty {
							HStack {
								Spacer()
								
								VStack(spacing: 10) {
									Image("empty-schedule-img")
										.resizable()
										.scaledToFit()
										.frame(
											minWidth: 0,
											idealWidth: 203,
											maxWidth: 203,
											minHeight: 0,
											idealHeight: 137,
											maxHeight: 137,
											alignment: .center
										)
									
									Text(NSLocalizedString("history_call_empty", comment: ""))
										.font(Font.custom(FontManager.Montserrat.bold, size: 14))
										.foregroundColor(.black)
									
									Text(NSLocalizedString("history_call_empty_label", comment: ""))
										.font(Font.custom(FontManager.Montserrat.regular, size: 12))
										.multilineTextAlignment(.center)
										.foregroundColor(.black)
								}
								
								Spacer()
							}
							.padding()
							.padding(.vertical)
							.background(Color.white)
							.cornerRadius(12)
							.padding(.horizontal)
							.shadow(color: Color("dinotis-shadow-1").opacity(0.1), radius: 15, x: 0.0, y: 0.0)
							.padding(.top, 15)
							
							Spacer()
						} else {
							ForEach(data, id: \.id) { items in
								if let user = items.meeting.user {
									HistoryCard(
										user: .constant(user),
										meeting: .constant(items.meeting),
										payment: .constant(items.bookingPayment),
										onTapDetail: {
											meetings = items.meeting
											payments = items.bookingPayment
											viewModel.bookingId = items.id.orEmpty()
											
											viewModel.routeToScheduleDetail()
										}
									)
								}
							}
							.padding(.vertical, 15)
							
						}
					}
				}
			}

			NavigationLink(
				unwrapping: $viewModel.route,
				case: /HomeRouting.userScheduleDetail) { viewModel in
					UserScheduleDetail(viewModel: viewModel.wrappedValue)
				} onNavigate: { _ in

				} label: {
					EmptyView()
				}
		}
		.edgesIgnoringSafeArea(.vertical)
		.onAppear {
			bookingVm.getBookings()
		}
		.valueChanged(value: bookingVm.success, onChange: { value in
			DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
				withAnimation(.spring()) {
					if value {
						self.isLoading = false
					}
				}
			})
		})
		.valueChanged(value: bookingVm.isLoading) { value in
			DispatchQueue.main.async {
				withAnimation(.spring()) {
					if value {
						self.isLoading = true
					}
				}
			}
		}
		
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
	}
	
	private func isStillShowing(date: Date) -> Bool {
		let order = Calendar.current.compare(date, to: Date(), toGranularity: .day)
		
		switch order {
		case .orderedSame:
			return true
		case .orderedDescending:
			return true
		default:
			return false
		}
	}
}

struct UserHistoryView_Previews: PreviewProvider {
	static var previews: some View {
		UserHistoryView(viewModel: UserHistoryViewModel(backToRoot: {}, backToHome: {}))
	}
}
