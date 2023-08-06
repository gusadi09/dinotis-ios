//
//  ContentView.swift
//  DinotisApp
//
//  Created by Gus Adi on 06/09/21.
//

import SwiftUI
import DinotisDesignSystem

struct ContentView: View {

	init() {
		FontInjector.registerFonts()
	}
	
	var body: some View {
		NavigationView {
			OnboardingView()
		}
        .navigationViewStyle(.stack)
        .dynamicTypeSize(.large)
        .onAppear {
            UIScrollView.appearance().backgroundColor = .clear
        }
		
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
