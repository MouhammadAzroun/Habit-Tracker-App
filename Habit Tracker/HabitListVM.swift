//
//  HabitListVM.swift
//  Habit Tracker
//
//  Created by Mouhammad Azroun on 2023-04-24.
//

import Foundation
import Firebase

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
        
        if let id = habit.id{
            habitsRef.document(id).updateData(["done" : !habit.done])
        }
    }
    
    func saveToFireStore(habitName: String) {
        guard let user = auth.currentUser else {return}
        let habitsRef = db.collection("users").document(user.uid).collection("habits")
        let habit = Habit(name: habitName)
        
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
                        self.habits.append(habit)
                    }catch{
                        print("Error reading from FireStore")
                    }
                }
                
            }
        }
    }
}
