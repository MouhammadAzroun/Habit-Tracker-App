//
//  ContentView.swift
//  Habit Tracker
//
//  Created by Mouhammad Azroun on 2023-04-23.
//

import SwiftUI
import Firebase

struct ContentView: View {
    @State var signedIn = false
    
    var body: some View {
        if !signedIn {
            SigningIn(signedIn: $signedIn)
        }else {
            MainView()
        }
    }
}

struct SigningIn: View {
    @Binding var signedIn: Bool
    var auth = Auth.auth()
    
    var body: some View {
        ZStack{
            Color(red: 60/365, green: 160/365, blue: 245/365)
                .ignoresSafeArea()
            
            VStack{
                Spacer()
                
                Text("Habit Tracker")
                    .font(.largeTitle)
                    .bold()
                
                Spacer()
                
                Button(action: {
                    auth.signInAnonymously{ result, error in
                        if let error = error{
                            print("error signing in \(error)")
                        }else{
                            signedIn = true
                        }
                    }
                }, label: {
                    Text("Start")
                        .foregroundColor(.white)
                        .font(.title)
                        .bold()
                        .padding()
                })
                .background(.black)
                .cornerRadius(25)
                .padding()
            }
        }
    }
}

struct MainView: View {
    var body: some View {
        ZStack{
            Color(red: 60/365, green: 160/365, blue: 245/365)
                .ignoresSafeArea()
            VStack{
                Text("Signed in")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
