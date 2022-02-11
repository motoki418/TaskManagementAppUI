//
//  TaskViewModel.swift
//  TaskManagementAppUI
//
//  Created by nakamura motoki on 2022/02/11.
//

import SwiftUI

class TaskViewModel: ObservableObject{
    
    // Sample Tasks
    // [Task]はstruct TaskModelを配列で保持するという意味
    // .init(timeIntervalSince1970: 1644551369　←ここの値は今日の数値に変える必要があります。
    // 動画内では2022/1/9の日付になっているので、動画内の値をそのまま使うと今日のタスクがないということになります。
    // 今日の日付の値を調べるにはPlaygroundで
    // let t = Int(Date().timeIntervalSince1970)
    // print(t)
    // と入力すると出てきます。
    // 現在の時間から一時間前を表示するには、Playgroundで所得した現在の時間を表す10桁の数字の、末尾4桁から5000くらい引く
    // 現在の時間から一時間後を表示するには、Playgroundで所得した現在の時間を表す10桁の数字の、末尾4桁に5000くらい足す　とうまくいきます。
    @Published var storedTasks: [TaskModel] = [
        TaskModel(taskTitle: "Meeting", taskDescription: "Discuss team task for the day", taskDate: .init(timeIntervalSince1970: 1644545029)),
        TaskModel(taskTitle: "Icon Set", taskDescription: "Edit icons for team task for next week", taskDate: .init(timeIntervalSince1970: 1644551029)),
        TaskModel(taskTitle: "prototype", taskDescription: "Make and send prototype", taskDate: .init(timeIntervalSince1970: 1644557283)),
        TaskModel(taskTitle: "Check asset", taskDescription: "Start checking the assets", taskDate: .init(timeIntervalSince1970: 1644563100)),
        TaskModel(taskTitle: "Team party", taskDescription: "Make fun with team mates", taskDate: .init(timeIntervalSince1970: 1644569000)),
        TaskModel(taskTitle: "Client Meeting", taskDescription: "Explain project to clinet", taskDate: .init(timeIntervalSince1970: 1644575011)),
        TaskModel(taskTitle: "Next Project", taskDescription: "Discuss next project with team", taskDate: .init(timeIntervalSince1970: 1644651369)),
        TaskModel(taskTitle: "App Proposal", taskDescription: "Meet clinet for next App Prososal", taskDate: .init(timeIntervalSince1970: 1644655000)),
    ]
    
    // MARK: Current Week Days
    //Let's write a code which will fetch the current week dates(Erom SUn to Sat)
    @Published var currentWeek: [Date] = []
    
    // MARK: Current Day
    // Storing the currentDay(This will be updated when ever user tapped on another date, basedon that tasks will be displayed)
    //currentは現在という意味　今日の日付
    @Published var currentDay: Date = Date()
    
    // MARK: Filtering Today Tasks
    // Filtering the tasks for the date user is selected
    @Published var filteredTasks: [TaskModel]?
    
    // MARK: Intializing
    // 一番最初に現在の週の日付（日〜土）を取得するfetchCurrentWeekを呼び出す
    init(){
        fetchCurrentWeek()
        filterTodayTasks()
    }
    
    // MARK: Filter Today Tasks
    // 今日のタスクの有無を判定する
    func filterTodayTasks(){
        DispatchQueue.global(qos: .userInteractive).async {
            
            let calender = Calendar.current
            
            // Filtering tasks based on the user selected Date
            let filtered  = self.storedTasks.filter{
                return calender.isDate($0.taskDate, inSameDayAs: self.currentDay)
            }
            // You can see that filtered tasks are not sorted by date,so sorting it vased on date and time
            // 時刻が遅いタスクを上から並べる
                .sorted{ task1, task2 in
                    return task2.taskDate < task1.taskDate
                    
                }
            
            DispatchQueue.main.async {
                withAnimation{
                    self.filteredTasks = filtered
                }
            }
        }
    }
    
    // 今日を起点に一週間を取得するメソッド
    func fetchCurrentWeek(){
        // 現在の日時を取得
        let today = Date()
        // カレンダーを生成
        let calender = Calendar.current
        
        let week = calender.dateInterval(of: .weekOfMonth, for: today)
        
        guard let firstWeekDay = week?.start else{
            return
        }
        // 7日間を生成
        (1...7).forEach{ day in
            
            if let weekday = calender.date(byAdding: .day, value: day, to: firstWeekDay){
                currentWeek.append(weekday)
            }
        }
    }
    
    // MARK: Extracting Date
    // 日付のフォーマットを定義
    func extractDate(date: Date, format: String) -> String{
        let formatter = DateFormatter()
        
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    // MARK: Checking if current Date is Today
    // When the app is opened we need highlight the currentDay in week days scrollview,
    // In order to do that we need to wirte a function which will verify if the week day is today
    // 今日かどうかを判定して、今日であればtrue、今日以外であればfalseを返すメソッド
    func isToday(date: Date) -> Bool {
        
        let calender = Calendar.current
        
        return calender.isDate(currentDay, inSameDayAs: date)
    }
    
    // MARK: Checking if the currentHour is
    //Writing a code which will verify whether the given task date and time is same as current Date and time(To highlight the Current Hour Tasks)
    // 現在の日時のタスクをハイライト表示するためのメソッド
    func isCurrentHour(date: Date) -> Bool{
        let calender = Calendar.current
        let hour = calender.component(.hour, from: date)
        let currentHour = calender.component(.hour, from: Date())
        // タスクの日時と現在の日時が同じ場合にtrueを返す
        return hour == currentHour
    }
}
