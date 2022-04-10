/**
 
 DoFCalculatorApp.swift
 Shared
 
 Created by Carsten Müller on 03.04.22.
 Copyright © 2022 Carsten Müller. All rights reserved.
 */

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
  
  
  
  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }
  
  func applicationDidFinishLaunching(_ notification: Notification) {
  }
}
#endif
