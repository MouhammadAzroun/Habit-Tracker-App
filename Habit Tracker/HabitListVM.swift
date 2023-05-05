//
//  HabitListVM.swift
//  Habit Tracker
//
//  Created by Mouhammad Azroun on 2023-04-24.
//

import Foundation
import Firebase
import SwiftUI
import FirebaseFirestoreSwift


class HabitListVM : ObservableObject {
    @Published var habits = [Habit]()
    let db = Firestore.firestore()
    let auth = Auth.auth()
    
    func delete (index: Int) {
        guard let user = auth.currentUser else {return}
        let habitsRef = db.collection("users").document(user.uid).collection("habits")
        
        let habit = habits[index]
        if let id = habit.id{
            habitsRef.document(id).delete()
        }
    }
    
    func toggel (habit: Habit){
        guard let user = auth.currentUser else {return}
        let habitsRef = db.collection("users").document(user.uid).collection("habits")
        let today = Calendar.current.startOfDay(for: Date())
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!

        
        if let id = habit.id {
            habitsRef.document(id).updateData(["done" : !habit.done])
            
            if !habit.done && habit.latestdate == today{
                habitsRef.document(id).updateData(["streak": FieldValue.increment(Int64(1))])
            }else if habit.done && habit.latestdate == today{
                habitsRef.document(id).updateData(["streak": FieldValue.increment(Int64(-1))])
            }
            else if (!habit.done && habit.latestdate < yesterday){
                habitsRef.document(id).updateData(["streak": 1])
                habitsRef.document(id).updateData(["latestdate" : Calendar.current.startOfDay(for: Date())])
            }else if !habit.done && habit.latestdate >= yesterday{
                habitsRef.document(id).updateData(["streak": FieldValue.increment(Int64(1))])
                habitsRef.document(id).updateData(["latestdate" : Calendar.current.startOfDay(for: Date())])
            }
        }
    }
    
    func saveToFireStore(habitName: String) {
        guard let user = auth.currentUser else {return}
        let habitsRef = db.collection("users").document(user.uid).collection("habits")
        let lastestdate = Calendar.current.startOfDay(for: Date())
        let habit = Habit(name: habitName, latestdate: lastestdate)
        
        do{
            try habitsRef.addDocument(from: habit)
        }catch{
            print("Error saving to db")
        }
    }
    
    func listenToFireStore(){
        guard let user = auth.currentUser else {return}
        let habitsRef = db.collection("users").document(user.uid).collection("habits")
        
        
        habitsRef.addSnapshotListener() {
            snapshot, error in
            
            guard let snapshot = snapshot else {return}
            if let error = error {
                print("Error listning to FireStore \(error)")
            }else{
                self.habits.removeAll()
                for document in snapshot.documents{
                    do{
                        let habit = try document.data(as: Habit.self)
                        self.resetDoneStatus(habit: habit)
                        self.habits.append(habit)
                    }catch{
                        print("Error reading from FireStore")
                    }
                }
                
            }
        }
    }
    
    func resetDoneStatus(habit: Habit){
        guard let user = auth.currentUser else {return}
        let habitsRef = db.collection("users").document(user.uid).collection("habits")
        let today = Calendar.current.startOfDay(for: Date())
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        if let id = habit.id {
            if habit.latestdate < today && habit.latestdate > yesterday{
                habitsRef.document(id).updateData(["done" : false])
                habitsRef.document(id).updateData(["latestdate" : Calendar.current.startOfDay(for: Date())])
            }else if (habit.latestdate < yesterday){
                habitsRef.document(id).updateData(["streak": 0])
                habitsRef.document(id).updateData(["done" : false])
                habitsRef.document(id).updateData(["latestdate" : Calendar.current.startOfDay(for: Date())])
            }
        }
    }
}
