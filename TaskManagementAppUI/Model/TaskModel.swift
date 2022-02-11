//
//  TaskModel.swift
//  TaskManagementAppUI
//
//  Created by nakamura motoki on 2022/02/11.
//

import SwiftUI

struct TaskModel: Identifiable{
    var id = UUID().uuidString
    var taskTitle: String
    var taskDescription: String
    var taskDate: Date
}
