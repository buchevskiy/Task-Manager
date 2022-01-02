//
//  Task.swift
//  To-Do Manager
//
//  Created by Андрей Бучевский on 03.08.2021.
//

import UIKit

enum TaskPriority {
    case normal
    case important
}

enum TaskStatus: Int {
    case planned 
    case completed
}

protocol TaskProtocol {
    var title: String {get set}
    var type: TaskPriority {get set}
    var status: TaskStatus {get set}
}

struct Task: TaskProtocol {
    var title: String
    var type: TaskPriority
    var status: TaskStatus
}
