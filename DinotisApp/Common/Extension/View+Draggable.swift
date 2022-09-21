//
//  ContentView+Draggable.swift
//  Agora-iOS-Tutorial-SwiftUI-1to1
//
//  Created by Gus Adi on 08/10/21.
//  Copyright © 2021 Agora. All rights reserved.
//

import Foundation
import SwiftUI

struct DraggableView: ViewModifier {
	@Binding var offset: CGPoint
	
	func body(content: Content) -> some View {
		GeometryReader { geo in
			content
				.gesture(DragGesture(minimumDistance: 0)
					.onChanged { value in
						self.offset.x += value.location.x - value.startLocation.x
						self.offset.y += value.location.y - value.startLocation.y
					}
					.onEnded({ _ in
						withAnimation(.spring()) {
                            if UIDevice.current.userInterfaceIdiom == .pad {
                                if self.offset.x < geo.frame(in: .local).midX {
                                    self.offset.x = geo.frame(in: .local).minX
                                } else {
                                    self.offset.x = geo.frame(in: .local).size.width - geo.size.width/3.45
                                }
                            } else {
                                if self.offset.x < geo.frame(in: .local).midX {
                                    self.offset.x = geo.frame(in: .local).minX
                                } else {
                                    self.offset.x = geo.frame(in: .local).size.width - 105
                                }
                            }
                            
                            if UIDevice.current.userInterfaceIdiom == .pad {
                                if self.offset.y < geo.frame(in: .local).midY {
                                    self.offset.y = geo.frame(in: .local).minY
                                } else {
                                    self.offset.y = geo.frame(in: .local).maxY - geo.size.height/4
                                }
                            } else {
                                if self.offset.y < geo.frame(in: .local).midY {
                                    self.offset.y = geo.frame(in: .local).minY
                                } else {
                                    self.offset.y = geo.frame(in: .local).maxY - 150
                                }
                            }
						}
					}))
				.offset(x: offset.x, y: offset.y)
                .onChange(of: UIDevice.current.orientation.isLandscape) { _ in
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        withAnimation {
                            self.offset.x = geo.frame(in: .local).minX
                            self.offset.y = geo.frame(in: .local).minY
                        }
                    }
                }
		}
	}
}

extension View {
	func draggable(by position: Binding<CGPoint>) -> some View {
		return modifier(DraggableView(offset: position))
	}
}
