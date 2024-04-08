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
        Settings() {
            SettingsScreen()
        }
    }
}


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
            statusButton.image = NSImage(systemSymbolName: "wand.and.stars", accessibilityDescription: "Pen Pal Menu button")
            statusButton.action = #selector(togglePopover)
        }
        

         
        self.popover = NSPopover()
        self.popover.contentSize = NSSize(width: 474, height: 300)

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
