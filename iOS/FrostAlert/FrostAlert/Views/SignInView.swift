//
//  SignInView.swift
//  FrostAlert
//
//  Created by Andrew James on 4/21/21.
//

import SwiftUI
import GoogleSignIn

struct SignInView: View {
    var body: some View {
        ZStack {
            Color.gray
                .ignoresSafeArea()
            VStack {
                Spacer(minLength: 50)
                Text("Sign in with Google to register your endpoints across devices")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                Spacer(minLength: 100)
                Image(systemName: "snow")
                    .font(.custom("Symbol", size: 150, relativeTo: .largeTitle))
                    .padding()
                Spacer(minLength: 100)
                SignInButton()
                    .padding(30)
            }
            .padding()
            .foregroundColor(Color.white)
        }
    }
}

struct SignInButton: UIViewRepresentable {
    
    func makeUIView(context: Context) -> GIDSignInButton {
        let button = GIDSignInButton()
        // Customize button here
        button.colorScheme = .light
        GIDSignIn.sharedInstance()?.presentingViewController = UIApplication.shared.windows.last?.rootViewController
        return button
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

//struct SignInView_Previews: PreviewProvider {
//    static var previews: some View {
//        SignInView()
//    }
//}
