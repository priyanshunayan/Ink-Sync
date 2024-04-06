//
//  ContentView.swift
//  WriteGPT
//
//  Created by Priyanshu Nayan on 31/03/24.
//

import SwiftUI
import OpenAIKit
import AxisTooltip


struct ContentView: View {
    
    
    @State private var isLoading = false
    @State private var shouldShowClipboard = true
    @State private var response: String = ""
    @State private var corrections: String?
    @State private var shouldShowCorrectionTooltip = false

    
    
    @AppStorage("openAIKey") private var openAIKey:String = "";
    @AppStorage("openAIModel") private var openAIModel:OpenAIModels = .gpt3Turbo;

    
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
            let components = completion.choices.first?.message.content.components(separatedBy: "---")
            
            response = components?[0] ?? ""
            corrections = components?.count ?? 0 > 1 ? components?[1] : nil
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
            let components = completion.choices.first?.message.content.components(separatedBy: "---")
            
            response = components?[0] ?? ""
            corrections = components?.count ?? 0 > 1 ? components?[1] : nil
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
    
    private func clearInput() {
        response = ""
    }
    

    
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    clearInput()
                }) {
                    Image(systemName: "clear.fill")
                        .imageScale(.medium)
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding(.top, 4)
                .help("Clear Input")
                
                
                Button(action: {
                    openSettingsScreen()
                }) {
                    Image(systemName: "gearshape.fill")
                        .imageScale(.medium)
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding(.top, 4)
                .help("Open Settings")
                
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
                    HStack {
                        Button(action: {
                            copyToClipboard(response)
                        }) {
                            Image(systemName: shouldShowClipboard ? "clipboard.fill" : "checkmark.circle.fill")
                                .imageScale(.large)
                        }.padding(.bottom, 8)
                        .buttonStyle(BorderlessButtonStyle())
                        
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.6)
                                .padding(.bottom, 8)
                        } else if let corrections = corrections {
                            Button(action: {
                                shouldShowCorrectionTooltip.toggle()
                            }) {
                                Image(systemName: "sparkles")
                                    .imageScale(.large)
                            }
                            .padding(.bottom, 8)
                            .buttonStyle(BorderlessButtonStyle())
                            .offset(x: -52)
                            .offset(y: -4)
                            .axisToolTip(isPresented: $shouldShowCorrectionTooltip, constant: ATConstant(axisMode: .top, arrow: ATArrowConstant(width: 0)), foreground: {
                                ScrollView {
                                    VStack {
                                        Text("Corrections applied")
                                            .font(.title2)
                                            .padding(.top, 20)
                                        Text(corrections)
                                            .padding(.horizontal, 20)
                                            .padding(.bottom, 20)
                                            .font(.body)
                                    }
                                }
                                .frame(width: 400, height: 200)
                               
                                
                            })

                            Spacer()
                        
                        
                    }
                        Spacer()
                }
                    
                    
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
