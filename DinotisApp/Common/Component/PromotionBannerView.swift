//
//  PromotionBannerView.swift
//  DinotisApp
//
//  Created by Gus Adi on 16/04/22.
//

import SwiftUI
import SDWebImageSwiftUI
import DinotisData

struct PromotionBannerView: View {
	
	@Binding var content: [BannerImage]
	var geo: GeometryProxy
	
	var body: some View {
		Group {
			PageView(content, geo: geo)
		}
	}
}

struct BannerImage: View {
	var content: BannerData?
	var action: (() -> Void)
	var geo: GeometryProxy
	
	private let config = Configuration.shared
	
	var body: some View {
		Button {
			action()
		} label: {
			WebImage(url: URL(string: (content?.imgUrl).orEmpty()))
				.resizable()
				.customLoopCount(1)
				.playbackRate(2.0)
				.placeholder {RoundedRectangle(cornerRadius: 12).foregroundColor(Color(.systemGray3))}
				.indicator(.activity)
				.frame(width: abs(geo.size.width-40), height: abs(geo.size.width/2.2))
				.clipShape(RoundedRectangle(cornerRadius: 12))
				.padding()
		}
		.buttonStyle(.plain)
	}
}

struct PageViewController: UIViewControllerRepresentable {
	var controllers: [UIViewController]
	@Binding var currentPage: Int?
    @State private var previousPage: Int? = 0
	
	init(
		controllers: [UIViewController],
		currentPage: Binding<Int?>
	) {
		self.controllers = controllers
		self._currentPage = currentPage
		self.previousPage = currentPage.wrappedValue
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}
	
	func makeUIViewController(context: Context) -> UIPageViewController {
		let pageViewController = UIPageViewController(
			transitionStyle: .scroll,
			navigationOrientation: .horizontal
		)
		
		pageViewController.view.backgroundColor = .clear
		pageViewController.dataSource = context.coordinator
		pageViewController.delegate = context.coordinator
		
		return pageViewController
	}
	
	func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
		guard !controllers.isEmpty else {
			return
		}
		context.coordinator.parent = self
		
		pageViewController.setViewControllers(
            [controllers[currentPage.orZero()]], direction: .forward, animated: true)
	}
	
	class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
		var parent: PageViewController
		
		init(_ pageViewController: PageViewController) {
			self.parent = pageViewController
		}
		
		func pageViewControllerSupportedInterfaceOrientations(_ pageViewController: UIPageViewController) -> UIInterfaceOrientationMask {
			.portrait
		}
		
		func pageViewControllerPreferredInterfaceOrientationForPresentation(_ pageViewController: UIPageViewController) -> UIInterfaceOrientation {
			.portrait
		}
		
		func pageViewController(
			_ pageViewController: UIPageViewController,
			viewControllerBefore viewController: UIViewController) -> UIViewController? {
				guard let index = parent.controllers.firstIndex(of: viewController) else {
					return nil
				}
				if index == 0 && parent.controllers.count <= 1 {
					return nil
				} else if index == 0 && parent.controllers.count > 1 {
					return parent.controllers.last
				} else {
					return parent.controllers[index-1]
				}
			}
		
		func pageViewController(
			_ pageViewController: UIPageViewController,
			viewControllerAfter viewController: UIViewController) -> UIViewController? {
				guard let index = parent.controllers.firstIndex(of: viewController) else {
					return nil
				}
				if index+1 == parent.controllers.count && parent.controllers.count <= 1 {
					return nil
				} else if index+1 == parent.controllers.count && parent.controllers.count > 1 {
					return parent.controllers.first
				} else {
					return parent.controllers[index+1]
				}
			}
		
		func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
			if completed,
				 let visibleViewController = pageViewController.viewControllers?.first,
				 let index = parent.controllers.firstIndex(of: visibleViewController) {
				parent.currentPage = index
			}
		}
	}
}

struct PageControl: UIViewRepresentable {
	var numberOfPages: Int
	@Binding var currentPage: Int?
	
	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}
	
	func makeUIView(context: Context) -> UIPageControl {
		let control = UIPageControl()
		control.numberOfPages = numberOfPages
		control.pageIndicatorTintColor = UIColor.systemGray5
		control.currentPageIndicatorTintColor = UIColor(named: "btn-stroke-1")
		control.addTarget(
			context.coordinator,
			action: #selector(Coordinator.updateCurrentPage(sender:)),
			for: .valueChanged)
		
		return control
	}
	
	func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.currentPage = currentPage.orZero()
		uiView.numberOfPages = numberOfPages
	}
	
	class Coordinator: NSObject {
		var control: PageControl
		
		init(_ control: PageControl) {
			self.control = control
		}
		@objc
		func updateCurrentPage(sender: UIPageControl) {
			control.currentPage = sender.currentPage
		}
	}
}

struct PageControlPromotion: UIViewRepresentable {
    var numberOfPages: Int
    @Binding var currentPage: Int
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UIPageControl {
        let control = UIPageControl()
        control.numberOfPages = numberOfPages
        control.pageIndicatorTintColor = UIColor.systemGray5
        control.currentPageIndicatorTintColor = UIColor(named: "btn-stroke-1")
        control.addTarget(
            context.coordinator,
            action: #selector(Coordinator.updateCurrentPage(sender:)),
            for: .valueChanged)
        
        return control
    }
    
    func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.currentPage = currentPage
        uiView.numberOfPages = numberOfPages
    }
    
    class Coordinator: NSObject {
        var control: PageControlPromotion
        
        init(_ control: PageControlPromotion) {
            self.control = control
        }
        @objc
        func updateCurrentPage(sender: UIPageControl) {
            control.currentPage = sender.currentPage
        }
    }
}

struct PageView<Page: View>: View {
	var viewControllers: [UIHostingController<Page>]
	var geo: GeometryProxy
    var view: [Page]
    @State var currentPage = 0
	init(_ views: [Page], geo: GeometryProxy) {
		self.viewControllers = views.map { UIHostingController(rootView: $0) }
		self.geo = geo
        self.view = views
	}
	
	var body: some View {
        VStack(alignment: .center) {
            Group {
                if view.count <= 1 {
                    ScrollView(.horizontal, showsIndicators: false) {
                        ForEach(view.indices, id: \.self) {
                            view[$0]
                                .tag($0)
                        }
                    }
                } else {
                    TabView(selection: $currentPage) {
                        ForEach(view.indices, id: \.self) {
                            view[$0]
                                .tag($0)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .frame(height: geo.size.width/2.2)
            
            PageControlPromotion(numberOfPages: view.count, currentPage: $currentPage)
        }
        .frame(height: geo.size.width/2)
        .onAppear {
            currentPage = 0
        }
	}
}

struct ProfileBannerView: View {

    @Binding var content: [ProfileBannerImage]
    var geo: GeometryProxy
    
    var body: some View {
        Group {
            ProfilePageView(content, geo: geo)
        }
        .padding(.bottom, -20)
    }
}

struct ProfileBannerImage: View {
    var content: HighlightData?
    
    private let config = Configuration.shared
    
    var body: some View {
			Group {
            if content?.imgUrl?.prefix(5) != "https" {
                WebImage(url: URL(string: "\(config.environment.baseURL)/uploads/" + (content?.imgUrl).orEmpty()))
                    .resizable()
                    .customLoopCount(1)
                    .playbackRate(2.0)
                    .placeholder {RoundedRectangle(cornerRadius: 12).foregroundColor(Color(.systemGray3))}
                    .indicator(.activity)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding()
            } else {
                WebImage(url: URL(string: (content?.imgUrl).orEmpty()))
                    .resizable()
                    .customLoopCount(1)
                    .playbackRate(2.0)
                    .placeholder {RoundedRectangle(cornerRadius: 12).foregroundColor(Color(.systemGray3))}
                    .indicator(.activity)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding()
            }
        }
        .background(Color.clear)
        .buttonStyle(.plain)
    }
}

struct ProfileBannerImageTemp: View {
    var content: HighlightData?
    
    private let config = Configuration.shared
    
    var body: some View {
            Group {
            if content?.imgUrl?.prefix(5) != "https" {
                WebImage(url: URL(string: "\(config.environment.baseURL)/uploads/" + (content?.imgUrl).orEmpty()))
                    .resizable()
                    .customLoopCount(1)
                    .playbackRate(2.0)
                    .placeholder {RoundedRectangle(cornerRadius: 12).foregroundColor(Color(.systemGray3))}
                    .indicator(.activity)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding()
            } else {
                WebImage(url: URL(string: (content?.imgUrl).orEmpty()))
                    .resizable()
                    .customLoopCount(1)
                    .playbackRate(2.0)
                    .placeholder {RoundedRectangle(cornerRadius: 12).foregroundColor(Color(.systemGray3))}
                    .indicator(.activity)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding()
            }
        }
        .background(Color.clear)
        .buttonStyle(.plain)
    }
}

struct ProfilePageView<Page: View>: View {
    var viewControllers: [UIHostingController<Page>]
    var geo: GeometryProxy
    @State var currentPage: Int? = 0
    init(_ views: [Page], geo: GeometryProxy) {
        self.viewControllers = views.map { UIHostingController(rootView: $0) }
        self.geo = geo
    }
    
    var body: some View {
        VStack(alignment: .center) {
            PageViewController(controllers: viewControllers, currentPage: $currentPage)
                .frame(height: geo.size.width)
                .padding(.top, -10)
            PageControl(numberOfPages: viewControllers.count, currentPage: $currentPage)
                .padding(.top, -20)
        }
        .onAppear {
            currentPage = 0
        }
    }
}

struct SingleProfileImageBanner: View {
    @Binding var profilePhoto: String?
    @Binding var name: String?
	var width: Double
    var height: Double
    
    var isChatBox: Bool = false
    
    private let config = Configuration.shared
    
    var body: some View {
        if isChatBox {
            WebImage(
                url: (profilePhoto != nil ?
                            "\(config.environment.openURL)" + profilePhoto.orEmpty() : "https://avatar.oxro.io/avatar.svg?name=" +
                            (name?.replacingOccurrences(of: " ", with: "+")).orEmpty()).toURL()
            )
            .resizable()
            .customLoopCount(1)
            .playbackRate(2.0)
            .placeholder {RoundedRectangle(cornerRadius: 12).foregroundColor(Color(.systemGray3))}
            .indicator(.activity)
						.scaledToFill()
						.frame(width: width, height: height)
						.clipShape(RoundedRectangle(cornerRadius: 12))
            .padding()
        } else {
            if profilePhoto?.prefix(5) != "https" {
                WebImage(
                    url: (profilePhoto != nil ?
                                "\(config.environment.baseURL)/uploads/" + (profilePhoto.orEmpty()) : "https://avatar.oxro.io/avatar.svg?name=" +
                                (name?.replacingOccurrences(of: " ", with: "+")).orEmpty()).toURL()
                )
                .resizable()
                .customLoopCount(1)
                .playbackRate(2.0)
                .placeholder {RoundedRectangle(cornerRadius: 12).foregroundColor(Color(.systemGray3))}
                .indicator(.activity)
								.scaledToFill()
								.frame(width: width, height: height)
								.clipShape(RoundedRectangle(cornerRadius: 12))
                .padding()
            } else if name.orEmpty().isEmpty && profilePhoto.orEmpty().isEmpty {
                WebImage(
                    url: "https://www.kindpng.com/picc/m/105-1055656_account-user-profile-avatar-avatar-user-profile-icon.png".toURL()
                )
                .resizable()
                .customLoopCount(1)
                .playbackRate(2.0)
                .placeholder {RoundedRectangle(cornerRadius: 12).foregroundColor(Color(.systemGray3))}
                .indicator(.activity)
								.scaledToFill()
								.frame(width: width, height: height)
								.clipShape(RoundedRectangle(cornerRadius: 12))
                .padding()
            } else {
                WebImage(
                    url: (
                        profilePhoto != nil ?
                        profilePhoto.orEmpty() : "https://avatar.oxro.io/avatar.svg?name=" + (name?.replacingOccurrences(of: " ", with: "+")).orEmpty()
                    ).toURL()
                )
                .resizable()
                .customLoopCount(1)
                .playbackRate(2.0)
                .placeholder {RoundedRectangle(cornerRadius: 12).foregroundColor(Color(.systemGray3))}
                .indicator(.activity)
								.scaledToFill()
								.frame(width: width, height: height)
								.clipShape(RoundedRectangle(cornerRadius: 12))
                .padding()
            }
        }
    }
}

struct PagesView: View {
	var geo: GeometryProxy
	var pages: [AnyView]
	@State var currentPage: Int? = 0
	init(geo: GeometryProxy, @PagesBuilder pages: () -> [AnyView]) {
		self.pages = pages()
		self.geo = geo
	}

	var body: some View {
		ZStack(alignment: .bottom) {
			PageViewController(controllers: pages.map {
				let h = UIHostingController(rootView: $0)
				h.view.backgroundColor = .clear
				return h
			}, currentPage: $currentPage)

			PageControl(numberOfPages: pages.count, currentPage: $currentPage)
		}
		.onAppear {
			currentPage = 0
		}
	}
}

@available(iOS 13.0, *)
@resultBuilder
public struct PagesBuilder {


	public static func buildBlock<C0: View>(
		_ c0: C0) -> [AnyView] {
			[AnyView(c0)]
		}

	public static func buildBlock<C0: View, C1: View>(_ c0: C0, _ c1: C1) -> [AnyView] {
		[AnyView(c0), AnyView(c1)]
	}

	public static func buildBlock<C0: View, C1: View, C2: View>(
		_ c0: C0,
		_ c1: C1,
		_ c2: C2) -> [AnyView] {
			[AnyView(c0), AnyView(c1), AnyView(c2)]
		}

	public static func buildBlock<C0: View, C1: View, C2: View, C3: View>(
		_ c0: C0,
		_ c1: C1,
		_ c2: C2,
		_ c3: C3) -> [AnyView] {
			[AnyView(c0), AnyView(c1), AnyView(c2), AnyView(c3)]
		}

	public static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View>(
		_ c0: C0,
		_ c1: C1,
		_ c2: C2,
		_ c3: C3,
		_ c4: C4) -> [AnyView] {
			[AnyView(c0), AnyView(c1), AnyView(c2), AnyView(c3), AnyView(c4)]
		}

	public static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View>(
		_ c0: C0,
		_ c1: C1,
		_ c2: C2,
		_ c3: C3,
		_ c4: C4,
		_ c5: C5) -> [AnyView] {
			[AnyView(c0), AnyView(c1), AnyView(c2), AnyView(c3), AnyView(c4), AnyView(c5)]
		}

	public static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View>(
		_ c0: C0,
		_ c1: C1,
		_ c2: C2,
		_ c3: C3,
		_ c4: C4,
		_ c5: C5,
		_ c6: C6) -> [AnyView] {
			[AnyView(c0), AnyView(c1), AnyView(c2), AnyView(c3), AnyView(c4), AnyView(c5), AnyView(c6)]
		}

	public static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View>(
		_ c0: C0,
		_ c1: C1,
		_ c2: C2,
		_ c3: C3,
		_ c4: C4,
		_ c5: C5,
		_ c6: C6,
		_ c7: C7) -> [AnyView] {
			[AnyView(c0), AnyView(c1), AnyView(c2), AnyView(c3), AnyView(c4), AnyView(c5), AnyView(c6), AnyView(c7)]
		}

	public static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View>(
		_ c0: C0,
		_ c1: C1,
		_ c2: C2,
		_ c3: C3,
		_ c4: C4,
		_ c5: C5,
		_ c6: C6,
		_ c7: C7,
		_ c8: C8) -> [AnyView] {
			[AnyView(c0), AnyView(c1), AnyView(c2), AnyView(c3), AnyView(c4), AnyView(c5), AnyView(c6), AnyView(c7), AnyView(c8)]
		}

	public static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View, C9: View>(
		_ c0: C0,
		_ c1: C1,
		_ c2: C2,
		_ c3: C3,
		_ c4: C4,
		_ c5: C5,
		_ c6: C6,
		_ c7: C7,
		_ c8: C8,
		_ c9: C9) -> [AnyView] {
			[AnyView(c0), AnyView(c1), AnyView(c2), AnyView(c3), AnyView(c4), AnyView(c5), AnyView(c6), AnyView(c7), AnyView(c8), AnyView(c9)]
		}
}
