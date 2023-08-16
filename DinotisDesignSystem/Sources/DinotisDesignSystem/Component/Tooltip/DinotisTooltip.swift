//
//  SwiftUIView.swift
//  
//
//  Created by Irham Naufal on 14/08/23.
//

import SwiftUI

public struct DinotisTooltip<Context: View>: ViewModifier {
    @Binding var show: Bool
    var width: CGFloat?
    var height: CGFloat?
    var alignment: Alignment = .top
    var id: String
    @ViewBuilder var context: Context
    
    public init(
        show: Binding<Bool>,
        alignment: Alignment = .bottom,
        id: String,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        @ViewBuilder context: () -> Context = { EmptyView() }
    ) {
        self._show = show
        self.width = width
        self.height = height
        self.alignment = alignment
        self.context = context()
        self.id = id
    }
    
    public func body(content: Content) -> some View {
        content
            .overlay(alignment: alignment) {
                context
                    .padding(12)
                    .frame(width: (width != nil) ? width : 200, height: (height != nil) ? height : 44)
                    .background(
                        ZStack(alignment: triangleAlignment()) {
                            RoundedRectangle(cornerRadius: 10)
                            
                            Triangle()
                                .frame(width: 52, height: 16)
                                .offset(y: triangleOffsetY())
                                .rotationEffect(isBottom() ? .degrees(180) : .zero, anchor: .top)
                        }
                            .foregroundColor(.DinotisDefault.secondary)
                    )
                    .offset(y: bgOffsetY())
                    .transition(.asymmetric(
                        insertion: .opacity.animation(
                            .spring(
                                response: 0.4,
                                dampingFraction: 0.6
                            )
                        ),
                        removal: .scale.animation(
                            .spring(
                                response: 0.4,
                                dampingFraction: 0.6
                            )
                        )
                    ))
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: show)
                    .isHidden(!show, remove: !show)
            }
            .anchorPreference(key: BoundsPreference.self, value: .bounds) { anchor in
                return [id : anchor]
            }
    }
    
    private func isBottom() -> Bool {
        switch alignment {
        case .bottom, .bottomLeading, .bottomTrailing:
            return true
        default:
            return false
        }
    }
    
    private func bgOffsetY() -> CGFloat {
        isBottom() ? ((height ?? 44) + 14) : -((height ?? 44) + 14)
    }
    
    private func triangleOffsetY() -> CGFloat {
        isBottom() ? -10 : 6
    }
    
    private func triangleAlignment() -> Alignment {
        switch alignment {
        case .bottom:
            return .top
        case .bottomLeading:
            return .topLeading
        case .bottomTrailing:
            return .topTrailing
        case .topLeading:
            return .bottomLeading
        case .topTrailing:
            return .bottomTrailing
        default:
            return .bottom
        }
    }
}

public extension View {
    func dinotisTooltip<Context: View>(
        _ show: Binding<Bool>,
        alignment: Alignment = .top,
        id: String,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        context: () -> Context = { EmptyView()}
    ) -> some View {
        modifier(DinotisTooltip(
            show: show,
            alignment: alignment,
            id: id,
            width: width,
            height: height,
            context: context
        ))
    }
}
