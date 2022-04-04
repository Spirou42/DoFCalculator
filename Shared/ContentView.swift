/**
 
 ContentView.swift
 Shared

 Created by Carsten Müller on 03.04.22.
 Copyright © 2022 Carsten Müller. All rights reserved.
 */
import SwiftUI
import DoFCalc

struct ContentView: View {
    var body: some View {
      LensEditor(lens:Lens())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
