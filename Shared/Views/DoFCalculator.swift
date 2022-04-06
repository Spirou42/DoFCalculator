//
//  DoFCalculator.swift
//  DoFCalculator
//
//  Created by Carsten Müller on 05.04.22.
//

import SwiftUI

struct DoFCalculator: View {
  
  @State var selectedLens:Int

  var body: some View {
    VStack{
      Text("DoF Calculator").font(.largeTitle)
      HStack{
        
        Picker("Lens:",selection: $selectedLens){
          Text("Dada").tag(0)
          Text("DuDu").tag(1)
          Text("HuHu").tag(2)
        }.frame(width: 300)
        
        Button("Edit Lens"){
        }.buttonStyle(.bordered)
        
        Button("Create Lens"){
        }.buttonStyle(.bordered)
        
      }
    }.padding()
  }
}

struct DoFCalculator_Previews: PreviewProvider {
  static var previews: some View {
    DoFCalculator(selectedLens: 1)
  }
}
