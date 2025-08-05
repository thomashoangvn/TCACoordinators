//
//  AppSplashView.swift
//  MyApp
//
//  Created by Thomas Hoang on 8/5/25.
//


import SwiftUI
import ComposableArchitecture

struct AppSplashView: View {
    let store: StoreOf<AppSplashFeature>
    
    var body: some View {
        ZStack {
            Color.accentColor.ignoresSafeArea()
            
            VStack {
                Image(systemName: "paperplane.circle.fill")
                    .font(.system(size: 120))
                    .foregroundColor(.white)
                
                Text("MyApp")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                if store.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                        .padding(.top, 40)
                }
            }
        }
        .task {
            await store.send(.task).finish()
        }
    }
}

#if DEBUG
struct AppSplashView_Previews: PreviewProvider {
    static var previews: some View {
        AppSplashView(
            store: Store(initialState: AppSplashFeature.State()) {
                AppSplashFeature()
            }
        )
    }
}
#endif
