//
//  LensEditor.swift
//  DoFCalculator 
//
//  Created by Carsten Müller on 03.04.22.
//

import SwiftUI
import DoFCalc


struct LensEditor: View {
  @ObservedObject var lens:Lens
  
  var body: some View {
    VStack{
      Text("Lens Editor").font(.largeTitle)
      Form{
        TextField(text: $lens.manufacturer){
          Text("Manufacturer:")
        }
        TextField(text:$lens.modelName){
          Text("Model:")
        }
      }.font(.title3)
      .padding()
      .border(.secondary)
    }
  }
}

struct LensEditor_Previews: PreviewProvider {
  static let lens:Lens = Lens(manufacturer: "Test",
                              modelName: "Model",
                              maxAperture: 2.8,
                              minAperture: 22,
                              focalLength: 50.0.mm,
                              minimalFocalDistance: 38.0.cm)
  static var previews: some View {
    LensEditor(lens:lens)
  }
}
