//
//  ContentView.swift
//  ToDo
//
//  Created by 조영민 on 1/17/25.
//

import SwiftUI
import SwiftData

// MARK: - Views

// 메인 컨텐츠 뷰
struct ContentView: View {
    // MARK: Properties
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [TodoItem]
    
    // 현재 편집 중인 아이템의 ID
    @State private var editingItemID: UUID? = nil
    
    // 초기 데이터가 이미 추가되었는지 확인하는 플래그
    @AppStorage("isInitialDataLoaded") private var isInitialDataLoaded = false
    
    private var initialTodos = [
        TodoItem(title: "Todo 프로젝트 제작하기", description: "기능 구현 완료하기"),
        TodoItem(title: "Todo 프로젝트 발표 준비하기", description: "오후 4시 진행"),
        TodoItem(title: "Todo 프로젝트 깃허브에 올리기", description: "")
    ]
    
    private var sortedItems: [TodoItem] {
        items.sorted { !$0.isCompleted && $1.isCompleted }
    }
    
    // MARK: Body
    var body: some View {
        NavigationView {
            List {
                ForEach(sortedItems) { todo in
                    TodoRowView(todo: todo, editingItemID: $editingItemID)
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Todo List")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    AddButton(action: addItem)
                }
            }
        }
        .onAppear {
            // 앱이 처음 실행될 때만 초기 데이터 추가
            if items.isEmpty {
                for todo in initialTodos {
                    modelContext.insert(todo)
                }
            }
        }
    }
    
    // MARK: Methods
    /// Todo 추가
    private func addItem() {
        let newNumber = items.count + 1
        let newTaskTitle = "새로운 할 일 \(newNumber)"
        let newItem = TodoItem(title: newTaskTitle, description: "")
        modelContext.insert(newItem)
    }
    
    /// Todo 삭제
    private func deleteItems(offsets: IndexSet) {
        for index in offsets {
            let todo = sortedItems[index]
            modelContext.delete(todo)
        }
    }
}

// MARK: - Supporting Views
/// Todo 아이템의 행을 표시하는 뷰
struct TodoRowView: View {
    @Environment(\.modelContext) private var modelContext
    let todo: TodoItem
    @Binding var editingItemID: UUID?
    
    var body: some View {
        HStack {
            CompletionButton(isCompleted: Binding(
                get: { todo.isCompleted },
                set: { todo.isCompleted = $0 }
            ))
            
            if editingItemID == todo.id {
                EditingTextField(title: Binding(
                    get: { todo.title },
                    set: { todo.title = $0 }
                )) {
                    editingItemID = nil
                }
            } else {
                TodoTitleView(title: todo.title, isCompleted: todo.isCompleted)
                    .onTapGesture {
                        editingItemID = todo.id
                    }
            }
        }
    }
}

/// 완료 버튼
struct CompletionButton: View {
    @Binding var isCompleted: Bool
    
    var body: some View {
        Button(action: { isCompleted.toggle() }) {
            Image(systemName: isCompleted ? "smallcircle.filled.circle" : "circle")
                .foregroundColor(isCompleted ? .green : .gray)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// 편집 모드의 텍스트 필드
struct EditingTextField: View {
    @Binding var title: String
    var onCommit: () -> Void
    
    var body: some View {
        TextField("할 일", text: $title, onCommit: onCommit)
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}

/// Todo 아이템의 제목을 표시하는 뷰
struct TodoTitleView: View {
    let title: String
    let isCompleted: Bool
    
    var body: some View {
        Text(title)
            .strikethrough(isCompleted, color: .gray)
            .foregroundColor(isCompleted ? .gray : .primary)
    }
}

/// 새로운 할 일을 추가하는 버튼
struct AddButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: TodoItem.self, inMemory: true)
}
