//
//  WriteGPTApp.swift
//  WriteGPT
//
//  Created by Priyanshu Nayan on 31/03/24.
//

import SwiftUI


@main
struct WriteGPTApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    
    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
        Settings {
            SettingsScreen()
        }
    }
}

//extension AXUIElement {
//  static var focusedElement: AXUIElement? {
//    systemWide.element(for: kAXFocusedUIElementAttribute)
//  }
//  
//  var selectedText: String? {
//    rawValue(for: kAXSelectedTextAttribute) as? String
//  }
//  
//  private static var systemWide = AXUIElementCreateSystemWide()
//  
//  private func element(for attribute: String) -> AXUIElement? {
//    guard let rawValue = rawValue(for: attribute), CFGetTypeID(rawValue) == AXUIElementGetTypeID() else { return nil }
//    return (rawValue as! AXUIElement)
//  }
//  
//  private func rawValue(for attribute: String) -> AnyObject? {
//    var rawValue: AnyObject?
//    let error = AXUIElementCopyAttributeValue(self, attribute as CFString, &rawValue)
//    return error == .success ? rawValue : nil
//  }
//}


//private func getSelectedText() -> String? {
//    // Press command + C, read the text, replace in the clipboard, press command + V
//
//    
//    return AXUIElement.focusedElement?.selectedText
//}


//@MainActor
//final class AppState: ObservableObject {
//    init() {
//        KeyboardShortcuts.onKeyUp(for: .captureImproveWritingCommand) { [] in
//            print(getSelectedText() ?? "An error occurred")
//        }
//    }
//}

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    
    
    
    var window: NSWindow!
    var preferencesWindow: NSWindow!
    
    @objc func openPreferencesWindow() {
        if nil == preferencesWindow {      // create once !!
            let preferencesView = SettingsScreen()
            // Create the preferences window and set content
            preferencesWindow = NSWindow(
                contentRect: NSRect(x: 20, y: 20, width: 880, height: 300),
                styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                backing: .buffered,
                defer: false)
            preferencesWindow.center()
            preferencesWindow.setFrameAutosaveName("Preferences")
            preferencesWindow.isReleasedWhenClosed = false
            preferencesWindow.contentView = NSHostingView(rootView: preferencesView)
            preferencesWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
        preferencesWindow.makeKeyAndOrderFront(nil)

    }
       
    
    
    
    @MainActor func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let statusButton = statusItem.button {
            statusButton.image = NSImage(systemSymbolName: "square.and.pencil.circle.fill", accessibilityDescription: "Improve Writing")
            statusButton.action = #selector(togglePopover)
        }
        
        self.popover = NSPopover()
        self.popover.contentSize = NSSize(width: 464, height: 300)
        self.popover.contentViewController = NSHostingController(rootView: ContentView())
        self.popover.behavior = .transient
    }
    
    @objc func togglePopover() {
        if let button = statusItem.button {
            if popover.isShown {
                self.popover.performClose(nil)
            } else {
                self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
            
        }
    }
    
}
