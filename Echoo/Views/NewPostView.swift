//
//  NewPostView.swift
//  Echoo
//
//  Created by Kato Daito on 2025/08/05.
//

import SwiftUI

struct NewPostView: View {
    @StateObject private var viewModel = NewPostViewModel()
    @Binding var selectedTab: Int
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 投稿本文入力エリア
                VStack(alignment: .leading, spacing: 12) {
                    Text("投稿内容")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextEditor(text: $viewModel.text)
                        .frame(minHeight: 120)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // ターゲット設定エリア
                VStack(alignment: .leading, spacing: 16) {
                    Text("質問したい相手")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    // 性別選択
                    VStack(alignment: .leading, spacing: 8) {
                        Text("性別")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Picker("性別", selection: $viewModel.targetGender) {
                            ForEach(viewModel.genderOptions, id: \.0) { option in
                                Text(option.1).tag(option.0 as String?)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    // 年齢範囲設定
                    VStack(alignment: .leading, spacing: 8) {
                        Text("年齢範囲")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        HStack(spacing: 12) {
                            VStack {
                                Text("最小年齢")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Picker("最小年齢", selection: $viewModel.targetMinAge) {
                                    Text("指定なし").tag(nil as Int?)
                                    ForEach(viewModel.ageOptions, id: \.self) { age in
                                        Text("\(age)歳").tag(age as Int?)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(height: 100)
                            }
                            
                            Text("〜")
                                .font(.title2)
                                .foregroundColor(.secondary)
                            
                            VStack {
                                Text("最大年齢")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Picker("最大年齢", selection: $viewModel.targetMaxAge) {
                                    Text("指定なし").tag(nil as Int?)
                                    ForEach(viewModel.ageOptions, id: \.self) { age in
                                        Text("\(age)歳").tag(age as Int?)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(height: 100)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 24)
                
                Spacer()
                
                // 投稿ボタン
                Button(action: {
                    Task {
                        let success = await viewModel.uploadPost()
                        if success {
                            // 投稿成功時はタイムラインタブに切り替え
                            selectedTab = 0
                        }
                    }
                }) {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "paperplane.fill")
                        }
                        Text("投稿する")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(viewModel.isFormValid ? Color.blue : Color.gray)
                    .cornerRadius(12)
                }
                .disabled(!viewModel.isFormValid || viewModel.isLoading)
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .navigationTitle("新規投稿")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("リセット") {
                        viewModel.resetForm()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .alert("エラー", isPresented: $viewModel.showingAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

#Preview {
    NewPostView(selectedTab: .constant(1))
}
