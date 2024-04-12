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
    
    
    @State private var isImprovingWriting = false
    @State private var isFixingGrammar = false
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
        isImprovingWriting.toggle()
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
            isImprovingWriting.toggle()
        } catch let error as APIErrorResponse {
            response = error.localizedDescription
            isImprovingWriting.toggle()
        } catch(let error) {
            response = error.localizedDescription
            isImprovingWriting.toggle()
        }
    }
    
    
    private func fixSpellingAndGrammar() async {
        isFixingGrammar.toggle()
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
            isFixingGrammar.toggle()
        } catch let error as APIErrorResponse {
            response = error.localizedDescription
            isFixingGrammar.toggle()
        } catch(let error) {
            response = error.localizedDescription
            isFixingGrammar.toggle()
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
    
    struct Star: View {
        var color = Color.yellow


        var body: some View {
            Image(systemName: "dot.circle.fill")
                .foregroundStyle(color)
                .frame(width: 5, height: 5)
        }
    }
    

    
    
    var body: some View {
        VStack {
            HStack {
                Label {
                    Text("Ink Sync")
                        .foregroundStyle(.primary)
                        .fontWeight(.thin)
                        .font(.title2)
                        .padding(.top, 4)
                        
                } icon: {
                    Image(systemName: "wand.and.stars")
                }
                
                


                Spacer()
                
                Button(action: {
                    clearInput()
                }) {
                    Image(systemName: "arrow.clockwise")
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
                        .overlay(alignment: .topTrailing) {
                            if openAIKey.isEmpty {
                                Star(color: .red) }
                            }
                            
                            


                }
                .buttonStyle(BorderlessButtonStyle())
                .padding(.top, 4)
                .help("Open Settings")
                
                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.medium)
                }
                .padding(.top, 4)
                .help("Open Settings")
                .buttonStyle(BorderlessButtonStyle())
                .keyboardShortcut("q")
                
                
            }.padding(8)
            
            
            TextEditor(text: $response)
                .font(.body)
                .frame(maxWidth:.infinity, maxHeight: .infinity)
                .lineSpacing(8)
                
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
                        
                        if let corrections = corrections {
                            Button(action: {
                                shouldShowCorrectionTooltip.toggle()
                            }) {
                                Image(systemName: "sparkles")
                                    .imageScale(.large)
                            }
                            .padding(.bottom, 8)
                            .buttonStyle(BorderlessButtonStyle())
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
                            if isImprovingWriting {
                                withAnimation {
                                    ProgressView()
                                        .scaleEffect(0.6)
                                }
                                
                                    
                            } else {
                                Text("Improve Writing")
                            }
                            
                            
                        }).padding(.bottom, 8)
                        .buttonStyle(.borderedProminent)
                              .controlSize(.large)
                              .disabled(isImprovingWriting)
                              
                    
                    
                    
                        Button(action: {
                            Task {
                                await fixSpellingAndGrammar()
                            }
                            
                        }, label: {
                            if isFixingGrammar {
                                ProgressView()
                                    .scaleEffect(0.6)
                                    
                            } else {
                                Text("Fix grammar")
                            }
                            
                        }).padding(.bottom, 8)
                                                      .controlSize(.large)
                                                      .disabled(isFixingGrammar)
                        
                    }.padding(6)
                .frame(height: 36)
                    
                }
        
        }
    }


#Preview {
    ContentView()
}
