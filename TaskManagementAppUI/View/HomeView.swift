//
//  HomeView.swift
//  TaskManagementAppUI
//
//  Created by nakamura motoki on 2022/02/11.
//

import SwiftUI

struct HomeView: View {
    
    // TaskViewModelを監視
    @StateObject private var taskViewModel: TaskViewModel = TaskViewModel()
    
    // 名前空間
    @Namespace var animation
    
    var body: some View {
        // Our home view basically consists of a horizontal scrollview which will allows us to select a date from current week
        // Below that all the tasks of the selected date will be displayed and the if the current hour is having any task, that will be highlighted
        ScrollView(.vertical, showsIndicators: false){
            
            // MARK: Lazy Stack With Pinned Header
            // 引数のpinnedViewsは [sectionHeaders][sectionFooters]のどちらかを指定。
            // リストをスクロールした際に固定される要素を決めている
            LazyVStack(spacing: 15, pinnedViews: [.sectionHeaders]){
                
                Section{
                    // MARK: Current Week View
                    // ScrollViewは縦横にスクロール可能なViewを生成する
                    // 【引数】axis
                    //スクロール方向を .vertical（縦方向）か .horizontal（横方向）のいずれかで指定
                    //[.vertical, .horizontal] と配列形式で指定すると縦横両方へのスクロールが可能となる
                    //未指定の場合、デフォルト値は .vertial
                    // 【引数】showIndicators
                    //スクロールインジケーターの表示/非表示をBool値で指定
                    //未指定の場合、デフォルト値は true（表示）
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack(spacing: 10){
                            ForEach(taskViewModel.currentWeek, id: \.self){ day in
                                // 日付と曜日を表示
                                VStack(spacing: 10){
                                    Text(taskViewModel.extractDate(date: day, format: "dd"))
                                        .font(.system(size: 15))
                                        .fontWeight(.semibold)
                                    // EEE will return day as MON,TUE,.....etc
                                    // 日付のフォーマットはTaskViewModelにあるextractDateメソッドを呼び出して決める
                                    // 曜日で表示
                                    Text(taskViewModel.extractDate(date: day, format: "EEE"))
                                        .font(.system(size: 14))
                                    
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 8, height: 8)
                                    // TaskViewModelのisTodayメソッドを利用して今日の日付だけ白丸を表示する
                                        .opacity(taskViewModel.isToday(date: day) ? 1 : 0 )
                                }// VStack(spacing: 10)
                                // MARK: Foreground Style
                                .foregroundStyle(taskViewModel.isToday(date: day) ? .primary : .secondary)
                                // 今日の日付と曜日の文字色を白に　今日以外の日付と曜日の文字色を黒に
                                .foregroundColor(taskViewModel.isToday(date: day) ? .white : .black)
                                // MARK: Capsule Shape
                                .frame(width: 45, height: 90)
                                .background(
                                    ZStack{
                                        // MARK: Matched Geometry Effect
                                        // Adding Matched Geometry Animation when a Week day is changed
                                        // 今日の日付のみ日付・曜日・黒丸・白丸を表示
                                        if taskViewModel.isToday(date: day){
                                            Capsule()
                                                .fill(.black)
                                                .matchedGeometryEffect(id: "CURRNTDAY", in: animation)
                                        }
                                    }// ZStack
                                )// .background
                                .contentShape(Capsule())
                                // 日付をタップしたときに黒カプセルを移動させる
                                .onTapGesture {
                                    // Updating Current Day
                                    withAnimation{
                                        taskViewModel.currentDay = day
                                    }
                                }//  .onTapGesture
                            }//ForEach
                        }// HStack(spacing: 10)
                        .padding(.horizontal)
                    }// ScrollView(.horizontal, showsIndicators: false)
                    TasksView()
                }header: {
                    HeaderView()
                }// Section
            }// LazyVStack
        }// ScrollView(.vertical, showsIndicators: false)
        .ignoresSafeArea(.container, edges: .top)
    }// body
    
    // MARK: Tasks View
    // Let's build the Tasks View, which will update dynamically when ever user is tapped on another date
    func TasksView() -> some View {
        
        LazyVStack(spacing: 20){
            // 今日のタスクの有無を確認する
            if let tasks = taskViewModel.filteredTasks{
                // 今日のタスクがない場合
                if tasks.isEmpty{
                    Text("No tasks found!!!")
                        .font(.system(size: 16))
                        .fontWeight(.light)
                        .offset(x: 100)
                }// if tasks.isEmpty
                // 今日のタスクがある場合
                else{
                    // taskに今日のタスクを取り出して表示
                    ForEach(tasks){ task in
                        TaskCardView(task: task)
                    }
                }// if tasks.isEmpty else
            }// if let
            else{
                // MARK: Progress View
                ProgressView()
                    .offset(y: 100)
            }// if let else
        }// LazyVStack
        .padding()
        .padding(.top)
        // MARK: Updating Taks
        // You can see that the tasks are not updating when the date is changed, this is because we're not filtering the tasks when ever the date is changed
        // 選択されている日付が変わったら、表示するタスクを変更する
        .onChange(of: taskViewModel.currentDay){ newValue in
            taskViewModel.filterTodayTasks()
        }
    }// TasksView()
    
    
    // MARK: Task Card View
    func TaskCardView(task: TaskModel) -> some View{
        // Let's create the Card View for each Task
        HStack(alignment: .top, spacing: 30){
            // 黒丸と黒線を縦並びに
            VStack(spacing: 10){
                // 内側の黒丸
                Circle()
                //現在の日時と同じ日時のタスクのみタスク名の左側に表示している丸の色を黒にする
                    .fill(taskViewModel.isCurrentHour(date: task.taskDate) ? .black : .clear)
                    .frame(width: 15, height: 15)
                    .background(
                        // 外側の細い円
                        Circle()
                            .stroke(.black, lineWidth: 1)
                            .padding(-3)
                    )
                // 現在の日時と同じ日時のタスクのみ丸を大きくする
                // 引数の先頭に！をつけているので、現在の日時と違う日時のタスクの丸の大きさを0.5にする
                    .scaleEffect(!taskViewModel.isCurrentHour(date: task.taskDate) ? 0.5 : 1)
                Rectangle()
                    .fill(.black)
                    .frame(width: 3)
            }// VStack
            VStack{
                HStack(alignment: .top, spacing: 10){
                    VStack(alignment: .leading, spacing: 12){
                        Text(task.taskTitle)
                            .font(.title2.bold())
                        Text(task.taskDescription)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }// VStack(alignment: .leading, spacing: 12)
                    .hLeading()
                    Text(task.taskDate.formatted(date: .omitted, time: .shortened))
                }// HStack(alignment: .top, spacing: 10)
                // Highlighting Current Tasks
                // 現在の日時と同じ日時のタスクのみチームメンバーの画像とチェックマークを表示する
                if taskViewModel.isCurrentHour(date: task.taskDate){
                    // MARK: Team Members
                    // チームメンバーの画像を表示
                    HStack(spacing: 0){
                        HStack(spacing: -10){
                            ForEach(["User1","User2","User3"], id: \.self){ user in
                                Image(user)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 45, height: 45)
                                    .clipShape(Circle())
                                    .background(
                                        Circle()
                                            .stroke(.blue, lineWidth: 5)
                                    )
                            }// ForEach
                        }// HStack(spacing: -10)
                        .hLeading()
                        
                        // MARK: Check Button
                        Button{
                            
                        }label: {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.black)
                                .padding(10)
                                .background(.white, in: RoundedRectangle(cornerRadius: 10))
                        }
                    }// HStack(spacing: 0)
                    .padding(.top)
                }
            }// VStack
            // 現在の日時と同じ日時のタスクのみ文字色を白にする
            .foregroundColor(taskViewModel.isCurrentHour(date: task.taskDate) ? .white : .black)
            // 現在の日時と同じ日時のタスクのみ余白を空ける
            .padding(taskViewModel.isCurrentHour(date: task.taskDate) ? 15 : 0)
            // 現在の日時と違う日時のタスクの下の余白を10空ける
            .padding(.bottom, taskViewModel.isCurrentHour(date: task.taskDate) ? 0 : 10)
            .hLeading()
            .background(
                Color("Black")
                    .cornerRadius(25)
                // 現在の日時と同じ日時のタスクのみ背景色の黒色を不透明にする
                    .opacity(taskViewModel.isCurrentHour(date: task.taskDate) ? 1 : 0)
            )
        }// HStack
        // 左寄せにする
        .hLeading()
    } // TaskCardView()
    
    // MARK: Header
    func HeaderView() -> some View{
        HStack(spacing: 10){
            VStack(alignment: .leading, spacing: 10){
                Text(Date().formatted(date: .abbreviated, time: .omitted))
                    .foregroundColor(.gray)
                Text("Today")
                    .font(.largeTitle.bold())
            }// VStack
            // Textを左寄せ
            .hLeading()
            Button{
                
            }label: {
                Image("Profile")
                // 画像サイズをフレームサイズに合わせる
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 45, height: 45)
                    .clipShape(Circle())
            }// Profileボタン
        }// HStack
        .padding()
        .padding(.top, getSafeArea().top)
        .background(.white)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}


// MARK: UI Design Helper functions
// Viewの位置を決める
extension View{
    // 左寄せ
    func hLeading() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    // 右寄せ
    func hTrailing() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
    // 中央に
    func hCenter() -> some View {
        self
            .frame(maxHeight: .infinity, alignment: .center)
    }
    
    //MARK: Safe Area
    func getSafeArea() -> UIEdgeInsets{
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else{
            return .zero
        }
        guard let safeArea = screen.windows.first?.safeAreaInsets else {
            return .zero
        }
        return safeArea
    }
}
