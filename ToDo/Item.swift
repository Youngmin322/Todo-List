//
//  Item.swift
//  ToDo
//
//  Created by 조영민 on 1/17/25.
//

import Foundation
import SwiftData

@Model
final class TodoItem {
    var id: UUID
    var title: String
    var itemDescription: String
    var isCompleted: Bool
    
    init(title: String, description: String = "", isCompleted: Bool = false) {
        self.id = UUID()
        self.title = title
        self.itemDescription = description
        self.isCompleted = isCompleted
    }
}
