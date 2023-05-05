//
//  Habit.swift
//  Habit Tracker
//
//  Created by Mouhammad Azroun on 2023-04-24.
//

import Foundation
import FirebaseFirestoreSwift

struct Habit: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var done: Bool = false
    var streak: Int = 0
    var latestdate : Date
}
