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
    DoFCalculator(selectedLens: 0,
                  selectedSensor: "1. Full Frame",
                  selectedZeiss: Sensor.ZeissRatio.modern.rawValue,
                  selectedAperture: 8.0,
    							focalDistance: 380,
    							focalDistanceDisplayValue: 380)
        .environmentObject(appData)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        .environmentObject(ApplicationData(lenses: Lenses.dummyLenses()))
    }
}
