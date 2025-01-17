//
//  ContentView.swift
//  ToDo
//
//  Created by 조영민 on 1/17/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\..modelContext) private var modelContext
    @Query private var items: [TodoItem]
    
    // 현재 편집 중인 아이템의 ID
    @State private var editingItemID: UUID? = nil
    
    // 초기 데이터가 이미 추가되었는지 확인
    @AppStorage("isInitialDataLoaded") private var isInitialDataLoaded = false
    
    // 검색 문자열
    @State private var searchText: String = ""

    private var initialTodos = [
        TodoItem(title: "Todo 프로젝트 제작하기", description: "기능 구현 완료하기"),
        TodoItem(title: "Todo 프로젝트 발표 준비하기", description: "오후 4시 진행"),
        TodoItem(title: "Todo 프로젝트 깃허브에 올리기", description: "")
    ]

    // MARK: Body
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText)
                List {
                    ForEach(filteredItems) { todo in
                        TodoRowView(todo: todo, editingItemID: $editingItemID, onCompletion: { completedTodo in
                            handleCompletion(for: completedTodo)
                        })
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
        .onAppear {
            // 앱이 처음 실행될 때만 초기 데이터 추가
            if !isInitialDataLoaded {
                for todo in initialTodos {
                    modelContext.insert(todo)
                }
                isInitialDataLoaded = true
            }
        }
    }

    // 필터링된 항목
    private var filteredItems: [TodoItem] {
        if searchText.isEmpty {
            return items
        } else {
            return items.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
    // Todo 추가
    private func addItem() {
        let newNumber = items.count + 1
        let newTaskTitle = "새로운 할 일 \(newNumber)"
        let newItem = TodoItem(title: newTaskTitle, description: "")
        modelContext.insert(newItem)
    }

    // Todo 삭제
    private func deleteItems(offsets: IndexSet) {
        for index in offsets {
            let todo = items[index]
            modelContext.delete(todo)
        }
    }

    // 완료 처리
    private func handleCompletion(for todo: TodoItem) {
        // 3초 후에 삭제
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation {
                modelContext.delete(todo)
            }
        }
    }
}

// MARK: - Supporting Views
// 검색 바 뷰
struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextField("검색", text: $text)
                .padding(7)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 10)

            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 10)
            }
        }
    }
}

// Todo 아이템 행 표시 뷰
struct TodoRowView: View {
    @Bindable var todo: TodoItem
    @Binding var editingItemID: UUID?
    var onCompletion: (TodoItem) -> Void

    var body: some View {
        HStack {
            CompletionButton(isCompleted: Binding(
                get: { todo.isCompleted },
                set: { newValue in
                    withAnimation {
                        todo.isCompleted = newValue
                        if newValue {
                            onCompletion(todo)
                        }
                    }
                }
            ))

            if editingItemID == todo.id {
                EditingTextField(title: $todo.title) {
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

/// Todo 제목 뷰
struct TodoTitleView: View {
    let title: String
    let isCompleted: Bool

    var body: some View {
        Text(title)
            .strikethrough(isCompleted, color: .gray)
            .foregroundColor(isCompleted ? .gray : .primary)
    }
}

/// todo 추가 버튼
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
