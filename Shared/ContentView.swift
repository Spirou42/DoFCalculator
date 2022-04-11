/**
 
 ContentView.swift
 Shared

 Created by Carsten Müller on 03.04.22.
 Copyright © 2022 Carsten Müller. All rights reserved.
 */
import SwiftUI
import DoFCalc

struct ContentView: View {
  @EnvironmentObject var appData:ApplicationData

  var body: some View {
    DoFCalculator()
        .environmentObject(appData)
        .frame(height:.none)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        .environmentObject(ApplicationData(lenses: Lenses.dummyLenses()))
    }
}
