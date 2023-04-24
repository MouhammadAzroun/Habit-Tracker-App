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
    let db = Firestore.firestore()
    @StateObject var habitListVM = HabitListVM()
    @State var showingAddAlert = false
    @State var newHabitName = ""
    
    var body: some View {
        ZStack{
            VStack{
                List {
                    ForEach(habitListVM.habits) { habit in
                        RowView(habit: habit, vm: habitListVM)
                    }
                    .onDelete() { indexSet in
                        for index in indexSet {
                            habitListVM.delete(index: index)
                        }
                    }
                }
            }
            VStack{
                Spacer()
                HStack{
                    Spacer()
                    Button(action: {
                        showingAddAlert = true
                    }, label: {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                    })
                    .frame(width: 50, height: 50)
                    .offset(x: -25)
                    .alert("Add habit",isPresented: $showingAddAlert) {
                        TextField("Habits name", text: $newHabitName)
                        Button(action: {
                            showingAddAlert = false
                        }, label: {
                            Text("Cancel")
                        })
                        
                        Button(action: {
                            habitListVM.saveToFireStore(habitName: newHabitName)
                            newHabitName = ""
                        }, label: {
                            Text("Add habit")
                        })
                    }
                }
            }
        }
        .onAppear{
            habitListVM.listenToFireStore()
        }
    }
}

struct RowView: View {
    let habit: Habit
    let vm: HabitListVM
    
    var body: some View {
        HStack{
            Text(habit.name)
            
            Spacer()
            
            Button(action: {
                vm.toggel(habit: habit)
            }, label: {
                Image(systemName: habit.done ? "checkmark.square" : "square")
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
