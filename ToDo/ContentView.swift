//
//  ContentView.swift
//  ToDo
//
//  Created by 조영민 on 1/17/25.
//

import SwiftUI
import SwiftData

// MARK: - Models

/// Todo 아이템을 나타내는 모델
struct TodoItem: Identifiable {
    let id = UUID()
    var title: String
    var description: String?
    var isCompleted: Bool = false
}

// MARK: - Views

/// 메인 컨텐츠 뷰
struct ContentView: View {
    // MARK: Properties
    
    /// Todo 아이템 배열
    @State private var todos: [TodoItem] = [
        TodoItem(title: "Todo 프로젝트 제작하기", description: "기능 구현 완료하기"),
        TodoItem(title: "Todo 프로젝트 발표 준비하기", description: "오후 4시 진행")
    ]
    
    /// 현재 편집 중인 아이템의 ID
    @State private var editingItemID: UUID? = nil
    
    private var sortedTodos: Binding<[TodoItem]> {
            Binding(
                get: {
                    self.todos.sorted { !$0.isCompleted && $1.isCompleted }
                },
                set: { newValue in
                    self.todos = newValue
                }
            )
        }
    
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    // MARK: Body
    var body: some View {
        NavigationView {
            List {
                ForEach(sortedTodos) { $todo in
                    TodoRowView(todo: $todo, editingItemID: $editingItemID)
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
    }
    
    // MARK: Methods
    
    /// 새로운 Todo 아이템 추가
    private func addItem() {
        let newNumber = todos.count + 1
        let newTaskTitle = "새로운 할 일 \(newNumber)"
        todos.append(TodoItem(title: newTaskTitle, description: ""))
    }
    
    /// 선택된 Todo 아이템 삭제
    private func deleteItems(offsets: IndexSet) {
        todos.remove(atOffsets: offsets)
    }
}

// MARK: - Supporting Views
/// Todo 아이템의 행을 표시하는 뷰
struct TodoRowView: View {
    @Binding var todo: TodoItem
    @Binding var editingItemID: UUID?
    
    var body: some View {
        HStack {
            CompletionButton(isCompleted: $todo.isCompleted)
            
            if editingItemID == todo.id {
                EditingTextField(title: $todo.title) {
                    editingItemID = nil
                }
            } else {
                TodoTitleView(
                    title: todo.title,
                    isCompleted: todo.isCompleted
                )
                .onTapGesture {
                    editingItemID = todo.id
                }
            }
        }
    }
}

/// 완료 상태를 토글하는 버튼
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
        .modelContainer(for: Item.self, inMemory: true)
}
