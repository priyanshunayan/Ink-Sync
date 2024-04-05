//
//  ContentView.swift
//  WriteGPT
//
//  Created by Priyanshu Nayan on 31/03/24.
//

import SwiftUI
import OpenAI


struct ContentView: View {
    
    @State private var isLoading = false
    @State private var shouldShowClipboard = true

    
    @State private var search: String = ""
    @State private var response: String = ""
    // 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
    
    
    @AppStorage("openAIKey") private var openAIKey:String = "";
    @AppStorage("openAIModel") private var openAIModel:OpenAIModels = .gpt3Turbo;

    
    
    
    
    private var isFormValid: Bool {
        !search.isEmpty
    }
    
    private var isResponseFieldEditable: Bool {
        !response.isEmpty
    }
    
    private func improveWriting() {
        isLoading.toggle()
        let openAI = OpenAI(apiToken: openAIKey)

        let query = CompletionsQuery(model: .gpt3_5Turbo, prompt: "What is 42?", temperature: 0, maxTokens: 100, topP: 1, frequencyPenalty: 0, presencePenalty: 0, stop: ["\\n"])
        
            openAI.completions(query: query) { result in
                switch result {
                case .success(_):
                    do {
                        let reply = try result.get().choices.first?.text
                        response = reply ?? "Hello, how are you?"
                        isLoading.toggle()
                    } catch {
                        print("Error")
                        isLoading.toggle()
                    }
                   
                case .failure(_):
                    response = "Hello, how are you?"
                    isLoading.toggle()
                }
            }
    }
    
    
    private func fixSpellingAndGrammar() {
        
    }
    
    private func openSettingsScreen() {
        NSApp.sendAction(#selector(AppDelegate.openPreferencesWindow), to: nil, from:nil)
    }
    
    private func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
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

                    
                HStack {
                    Button(action: {
                        shouldShowClipboard.toggle()
                        copyToClipboard(response)
                        
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            shouldShowClipboard.toggle()
                                    }
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
                            improveWriting()
                        }, label: {
                            Text("Improve Writing")
                        }).padding(.bottom, 8)
                        Button(action: {
                            fixSpellingAndGrammar()
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
