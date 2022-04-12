/**
 
 DoFCalculatorApp.swift
 Shared
 
 Created by Carsten Müller on 03.04.22.
 Copyright © 2022 Carsten Müller. All rights reserved.
 */

import Cocoa
import Combine
import SwiftUI
import DoFCalc

class ApplicationData:ObservableObject{
  var lensData:Lenses
  var sensorData:Sensors = Sensors()
  
  public init(lenses:Lenses){
    lensData = lenses
  }
}

@main
class DoFCalculatorApp: App, ObservableObject {
  @StateObject var appData:ApplicationData
  
#if os(macOS)
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
#endif
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(appData)
        .environmentObject(self)
    }
  }
  
  static func loadLensData() -> Lenses {
    var url = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    var lensData = Lenses()
    if (url != nil) {
      url?.appendPathComponent("LensDatabase.json")
      let path = url!.path
      if !FileManager.default.fileExists(atPath: path){
        let lensDatabase = Bundle.main.url(forResource: "LensDatabase", withExtension: "json")
        try? FileManager.default.copyItem(at: lensDatabase!, to: url!)
      }
      
      let data = FileManager.default.contents(atPath: url!.path)
      let jsonString = String(bytes: data!, encoding: .utf8)
      
      print("Datat" + jsonString!)
      
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .secondsSince1970
      lensData = try! decoder.decode(Lenses.self, from: data!)
    }
    return lensData
  }
  func saveLensData() {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let data = (try? encoder.encode(appData.lensData)) ?? Data()
    print(String(data: data, encoding: .utf8)!)
    var url = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    url?.appendPathComponent("LensDatabase.json")
    FileManager.default.createFile(atPath: url!.path, contents: data)
  }
  
  func addLensIfNeeded(someLens:Lens){
    if !appData.lensData.lenses.contains(someLens){
      appData.lensData.lenses.append(someLens)
    }
  }
  required init (){
    let lensData = DoFCalculatorApp.loadLensData()
    _appData = StateObject(wrappedValue: ApplicationData(lenses:lensData))
  }
}

#if os(macOS)
class AppDelegate: NSObject, NSApplicationDelegate {
  
  
  var window: NSWindow?
  var subscribers = Set<AnyCancellable>()
  
  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }
  
  func applicationDidBecomeActive(_ notification: Notification) {
    self.window = NSApp.mainWindow
  }
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    setupResizeNotification()
  }
  
  private func setupResizeNotification() {
    NotificationCenter.default.publisher(for: ContentView.needsNewSize)
      .sink(receiveCompletion: {_ in}) { [unowned self] notificaiton in
        if let size = notificaiton.object as? CGSize, self.window != nil {
          var frame = self.window!.frame
          let old = self.window!.contentRect(forFrameRect: frame).size
          let dX = size.width - old.width
          let dY = size.height - old.height
          frame.origin.y -= dY // origin in flipped coordinates
          frame.size.width += dX
          frame.size.height += dY
//          window!.setFrame(frame,display: true)
          NSAnimationContext.runAnimationGroup({ context in
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            window!.animator().setFrame(frame, display: true, animate: true)
          }, completionHandler: {
          })
        }
      }
      .store(in: &subscribers)
  }}
#endif
