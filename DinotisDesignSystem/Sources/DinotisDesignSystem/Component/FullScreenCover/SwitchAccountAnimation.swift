//
//  SwiftUIView.swift
//  
//
//  Created by Irham Naufal on 25/01/24.
//

import SwiftUI

public struct SwitchAccountAnimation: View {
    
    private let toCreator: Bool
    
    private var title: String {
        toCreator ? LocalizableText.welcomeToCreatorModeTitle : LocalizableText.welcomeToPersonalModeTitle
    }
    
    private var illustration: Image {
        toCreator ? Image.generalCreatorImage : Image.generalPersonalImage
    }
    
    private var animationName: String {
        toCreator ? LottieAssetName.personalToCreator : LottieAssetName.creatorToPersonal
    }
    
    public init(toCreator: Bool = false) {
        self.toCreator = toCreator
    }
    
    public var body: some View {
        VStack {
            Image.logoWithText
                .resizable()
                .scaledToFit()
                .frame(height: 33)
                .padding()
            
            Spacer()
            
            Text(title)
                .font(.robotoBold(size: 24))
                .foregroundColor(.DinotisDefault.black1)
                .padding()
            
            LottieView(name: animationName, contentMode: .scaleAspectFit)
                .frame(height: 54)
            
            Spacer()
            
            illustration
                .resizable()
                .scaledToFit()
                .frame(width: 460)
                .offset(y: 32)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

fileprivate struct Preview: View {
    
    @State var show = false
    @State var toCreator = false
    
    init() {
        FontInjector.registerFonts()
    }
    
    var body: some View {
        VStack {
            Button("To Creator") {
                toCreator = true
                show = true
            }
            
            Button("To Personal") {
                toCreator = false
                show = true
            }
        }
        .fullScreenCover(isPresented: $show, content: {
            SwitchAccountAnimation(toCreator: toCreator)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now()+3) {
                        self.show = false
                    }
                }
        })
    }
}

#Preview {
    Preview()
}
