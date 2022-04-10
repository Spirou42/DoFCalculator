//
//  LensEditor.swift
//  DoFCalculator 
//
//  Created by Carsten Müller on 03.04.22.
//

import SwiftUI
import Combine
import DoFCalc
import Extensions

struct LensEditor: View{
  
  //#if canImport(UIKit)
  //  @State var localWindow: UIWindow?
  //#elseif canImport(AppKit)
  //  @State var localWindow: NSWindow?
  //#endif
  
  @ObservedObject var lens:Lens
  
  var backstore:Lens
  
  @State var calc:Double = LengthConvert.mm.rawValue
  
  @State var displayValue:Double
  @FocusState private var focalLengthIsFocused: Bool
  
  @EnvironmentObject private var application:DoFCalculatorApp
  
  var body: some View {
    let columns: [GridItem] = [GridItem(.fixed(100),alignment:.trailing),
                               GridItem(.fixed(270),alignment:.leading)]
    
    //    let columns2:[GridItem] = [GridItem(.fixed( 120),spacing:0,alignment: .trailing),
    //                               GridItem(.fixed(86),spacing:0,alignment: .leading),
    //                               GridItem(.fixed(120),spacing:0,alignment: .trailing)
    //    ]
    VStack(spacing:5){
      Text("Create Lens").font(.largeTitle).padding([.top],10)
      Divider().padding([.bottom],5)
      LazyVGrid(columns: columns, spacing: 3){
        Text("Manufacturer:")
        TextField("Manufacturer", text: $lens.manufacturer)
        
        Text("Model:")
        TextField("Model",text:$lens.modelName)
        
      }.padding([.leading, .trailing,.bottom],8)
      
      
      
      LazyVGrid(columns: columns,spacing: 6){
        Text("")
        //Text("")
        Text("Aperture").font(.title2).padding([.top],6).padding([.leading],-50)
        
        
        Text("max:")
        HStack(){
          Picker("", selection: $lens.maxAperture){
            Text("1.4").tag(1.4)
            Text("2").tag(2.0)
            Text("2.8").tag(2.8)
            Text("4").tag(4.0)
            Text("5.6").tag(5.6)
          }.frame(width:86)
          Text("min:").padding([.leading],10)
          Picker("",selection:$lens.minAperture){
            Text("16").tag(16.0)
            Text("20").tag(20.0)
            Text("22").tag(22.0)
          }.frame(width:86)
        }
      }.padding([.leading, .trailing,.bottom],8)
      
      
      LazyVGrid(columns: columns,spacing: 6){
        Text("")
        Text("Focal Settings").font(.title2).padding([.top],6).padding([.leading],-50)
        
        Text("Focal Length:")
        HStack{
          TextField("focal length",value: $lens.focalLength,format: .number).frame(width:80)
          //            .onReceive(Just(lens.focalLength)){
          //              newValue in
          //              print ("Got a value of \(newValue)")
          //            }.frame(width:80)
          Text("mm").padding([.leading],12)
        }
        
        Text("min. Distance:")
        HStack{
          TextField("focal distance",value: $displayValue,format:.number)
            .frame(width:80)
            .focused($focalLengthIsFocused)
            .onChange(of: displayValue) { _ in
              print("new distance: \(displayValue)")
              lens.minimalFocalDistance = displayValue * calc
              print("lens distance: \(lens.minimalFocalDistance)")
            }
          
          Picker("",selection:$calc){
            Text("mm").tag(LengthConvert.mm.rawValue)
            Text("cm").tag(LengthConvert.cm.rawValue)
            Text("m").tag(LengthConvert.m.rawValue)
          }.onChange(of: calc){ _ in
            focalLengthIsFocused = false
            displayValue = lens.minimalFocalDistance / calc
          }
          .frame(width:60)
        }
      }.padding([.leading,.trailing,.bottom],8)
      HStack{
        Button(action: {
          application.addLensIfNeeded(someLens: lens)
          application.saveLensData()
#if canImport(AppKit)
          NSApplication.shared.keyWindow?.close()
#endif
        }){
          Text("Save")
        }.buttonStyle(GradientGlyphButtonStyle(buttonColor:.lightGray, labelColor:.black, cornerRadius: 13, width:80, height:24, bevelSize:3))
        Spacer().frame(width:100)
        Button(action:{
          lens &= backstore
#if canImport(AppKit)
          NSApplication.shared.keyWindow?.close()
#endif
        }){
          Text("Cancel")
        }.buttonStyle(GradientGlyphButtonStyle(buttonColor:.lightGray, labelColor:.black, cornerRadius: 13, width:80, height:24, bevelSize:3))
      }.padding([.bottom])
    }.font(.title3)
      .frame(width: 450.0) // VStack
  }
  
  init(lens:Lens){
    self.lens = lens
    self.backstore = Lens(another: lens)
    self.displayValue = lens.minimalFocalDistance
  }

}

struct LensEditor_Previews: PreviewProvider {
  static let lens:Lens = Lens(manufacturer: "",
                              modelName: "",
                              maxAperture: 1.4,
                              minAperture: 22,
                              focalLength: 50.0.mm,
                              minimalFocalDistance: 38.0.cm)
  
  static var previews: some View {
    LensEditor(lens:lens)
  }
}
