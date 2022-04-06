/**
 
 DoFCalculatorApp.swift
 Shared
 
 Created by Carsten Müller on 03.04.22.
 Copyright © 2022 Carsten Müller. All rights reserved.
 */

import SwiftUI

@main
class DoFCalculatorApp: App {
#if os(macOS)
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
#endif
  
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
  
  required init (){
  }
}

#if os(macOS)
class AppDelegate: NSObject, NSApplicationDelegate {
  
  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }
  
  func applicationDidFinishLaunching(_ notification: Notification) {
  }
}
#endif
