//
//  ContentView.swift
//  WriteGPT
//
//  Created by Priyanshu Nayan on 31/03/24.
//

import SwiftUI
import OpenAIKit


struct ContentView: View {
    
    @State private var isLoading = false
    @State private var shouldShowClipboard = true

    
    @State private var search: String = ""
    @State private var response: String = ""
    
    @AppStorage("openAIKey") private var openAIKey:String = "";
    @AppStorage("openAIModel") private var openAIModel:OpenAIModels = .gpt3Turbo;


    
    
    private var isFormValid: Bool {
        !search.isEmpty
    }
    
    private var isResponseFieldEditable: Bool {
        !response.isEmpty
    }
    
    private func improveWriting() async {
        isLoading.toggle()
        let urlSession = URLSession(configuration: .default)
        let configuration = Configuration(apiKey: openAIKey)
        
        
        let openAIClient = OpenAIKit.Client(session: urlSession, configuration: configuration)
        
        let modelToUse: OpenAIKit.ModelID  = openAIModel == .gpt3Turbo ? OpenAIKit.Model.GPT3.gpt3_5Turbo  :  OpenAIKit.Model.GPT4.gpt4
        
        do {
            
            let messages: [Chat.Message] = [
                .system(content: IMPROVE_WRITING_PROMPT),
                .user(content: response)
            ]
            
            let completion = try await openAIClient.chats.create(
                model: modelToUse,
                messages: messages
            )
            response = completion.choices.first?.message.content ?? ""
            copyToClipboard(response)
            isLoading.toggle()
        } catch let error as APIErrorResponse {
            response = error.localizedDescription
            isLoading.toggle()
        } catch(let error) {
            response = error.localizedDescription
            isLoading.toggle()
        }
    }
    
    
    private func fixSpellingAndGrammar() async {
        isLoading.toggle()
        print("Fixing spelling and grammar")
        let urlSession = URLSession(configuration: .default)
        let configuration = Configuration(apiKey: openAIKey)
        
        
        let openAIClient = OpenAIKit.Client(session: urlSession, configuration: configuration)
        
        
        let modelToUse: OpenAIKit.ModelID  = openAIModel == .gpt3Turbo ? OpenAIKit.Model.GPT3.gpt3_5Turbo  :  OpenAIKit.Model.GPT4.gpt4
        
        do {
            let messages: [Chat.Message] = [
                .system(content: FIX_SPELLING_AND_GRAMMAR_PROMPT),
                .user(content: response)
            ]
            
            let completion = try await openAIClient.chats.create(
                model: modelToUse,
                messages: messages
            )
            response = completion.choices.first?.message.content ?? ""
            copyToClipboard(response)
            isLoading.toggle()
        } catch let error as APIErrorResponse {
            response = error.localizedDescription
            isLoading.toggle()
        } catch(let error) {
            response = error.localizedDescription
            isLoading.toggle()
        }
    }
    
    private func openSettingsScreen() {
        NSApp.sendAction(#selector(AppDelegate.openPreferencesWindow), to: nil, from:nil)
    }
    
    private func copyToClipboard(_ text: String) {
        shouldShowClipboard.toggle()
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            shouldShowClipboard.toggle()
        }
    }
    
    
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    openSettingsScreen()
                }) {
                    Image(systemName: "gearshape.fill")
                        .imageScale(.medium)
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding(.top, 4)
                
            }.padding(8)
            
            
            TextEditor(text: $response)
                .font(.body)
                .frame(maxWidth:.infinity, maxHeight: .infinity)
                .lineSpacing(8)
                .textEditorStyle(.automatic)
                .accessibilityLabel("Paste your text here")
                .onAppear {
                    if let clipboardString = NSPasteboard.general.string(forType: .string) {
                        response = clipboardString
                    }
                }

                    
                HStack {
                    Button(action: {
                        copyToClipboard(response)
                    }) {
                        Image(systemName: shouldShowClipboard ? "clipboard.fill" : "checkmark.circle.fill")
                            .imageScale(.large)
                    }.padding(.bottom, 8)
                    .buttonStyle(BorderlessButtonStyle())
                    
                    HStack {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.6)
                               
                                
                            }
                    }.padding(.bottom, 8)
                        Spacer()
                    
                    
                        Button(action: {
                            Task {
                                await improveWriting()
                            }
                        }, label: {
                            Text("Improve Writing")
                        }).padding(.bottom, 8)
                    
                    
                    
                        Button(action: {
                            Task {
                                await fixSpellingAndGrammar()
                            }
                            
                        }, label: {
                            Text("Fix spelling and grammar")
                        }).padding(.bottom, 8)
                        
                    }.padding(6)
                .frame(height: 36)
                    
                }
        
        }
    }


#Preview {
    ContentView()
}
