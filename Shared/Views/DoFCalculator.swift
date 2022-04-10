//
//  DoFCalculator.swift
//  DoFCalculator
//
//  Created by Carsten Müller on 05.04.22.
//

import SwiftUI
import Extensions
import DoFCalc


struct DoFCalculator: View {
  
  @State var selectedLens:Int
  @State var selectedSensor:String
  @State var selectedZeiss:Int
  @State var selectedAperture:Double
  @State var focalDistance:Double
  
  @State var calc:Double = LengthConvert.cm.rawValue
  @State var focalDistanceDisplayValue:Double
  @FocusState private var focalDistanceFieldFocused: Bool
  
  @EnvironmentObject var appData:ApplicationData
  @EnvironmentObject var application:DoFCalculatorApp
  
  var lensFromSelection:Lens{
    get {
      return appData.lensData.lenses[selectedLens]
    }
  }
  
  var sensorFromSelection:Sensor{
    get {
      return appData.sensorData.knownSensors[selectedSensor]!
    }
  }
  
  
  
  var columns: [GridItem] = [.init(.fixed(70),spacing:0.5,alignment:.trailing ),
                             .init(.fixed(300),spacing:0.5,alignment:.leading ),
                             .init(.fixed(200),spacing:0.5,alignment:.trailing )
  ]
  var body: some View {
    VStack(spacing: 20){
      Text("DoF Calculator").font(.largeTitle).frame(alignment:.center)
      Collapsible(label: {
        Text("Sensor").font(.title)
      }){
 //     }
        
        
        // Sensor settings
        LazyVGrid(columns:columns,spacing:5){
//          Text("")
//          Text("Sensor").font(.title).padding([.leading],-30)
//          Text("")
          
          Text("Size:")
          Picker("",selection: $selectedSensor){
            ForEach( Array(appData.sensorData.knownSensors.keys).sorted(by: {(lhs:String, rhs:String) in return lhs<rhs }), id:\.self){k in
              Text(k).tag(k)
            }
          }
          
          Text( (appData.sensorData.knownSensors[selectedSensor])?.sizeString ?? "").frame(width:200,alignment:.center)
          
          Text("Zeiss:")
          Picker("",selection: $selectedZeiss){
            Text("Traditional").tag(Sensor.ZeissRatio.traditional.rawValue)
            Text("Classic").tag(Sensor.ZeissRatio.classic.rawValue)
            Text("Modern").tag(Sensor.ZeissRatio.modern.rawValue)
          }
          Text("")
        }
        
        LazyVGrid(columns:columns,spacing:5){
          
          Text("")
          Text("Lens").font(.title).padding([.leading],-30)
          Text("")
          
          
          Text("Model:")
          
          Picker("",selection: $selectedLens){
            ForEach(0..<appData.lensData.lenses.count, id:\.self ){ t in
              Text(appData.lensData.lenses[t].manufacturer + " - " + appData.lensData.lenses[t].modelName).tag(t)
            }
          }.pickerStyle(MenuPickerStyle())
          
          HStack{
            Button(action:{
              LensEditor(lens: self.lensFromSelection).environmentObject(application).openNewWindow(with:"Lens Editor")
            }){
              Text("Edit").font(.title3)
            }.buttonStyle(GradientGlyphButtonStyle(buttonColor:.lightGray, labelColor:.black, cornerRadius: 13, width:80, height:24, bevelSize:3))
            
            Button(action:{
              let lens = Lens()
              LensEditor(lens: lens).environmentObject(application).openNewWindow(with:"Lens Editor")
            }){
              Text("Create").font(.title3)
            }.buttonStyle(GradientGlyphButtonStyle(buttonColor:.lightGray, labelColor:.black, cornerRadius: 13, width:80, height:24,bevelSize:3))
          }
        }
      }// Collapsible
      
      
      
      LazyVGrid(columns:columns,spacing:5){
        Text("")
        Text("Settings").font(.title).padding([.leading],-30)
        Text("")
        
        Text("Aperture:")
        Picker("", selection:$selectedAperture){
          ForEach(lensFromSelection.apertureList(),id:\.self ){ description in
            Text(description.label).tag(description.aperture)
            if description.isStepEnd {
              Divider()
            }
          }
          //          ForEach(lensFromSelection.getMaxApertureIndex()...lensFromSelection.getMinApertureIndex()
          //                  ,id:\.self){ index in
          //            Text(String(format:"𝒇 %0.1f",Lens.apertureForIndex(Double(index)))).tag(Lens.apertureForIndex(Double(index)))
          //            Text(String(format:"𝒇 %0.1f",Lens.apertureForIndex(Double(index)+0.33))).tag(Lens.apertureForIndex(Double(index)+0.33))
          //            Text(String(format:"𝒇 %0.1f",Lens.apertureForIndex(Double(index)+0.66))).tag(Lens.apertureForIndex(Double(index)+0.66))
          //            Divider()
          //          }
        }
        //        .frame(width:60)
        Text("")
        
        Text("Distance:")
        HStack{
          TextField("focal distance",value: $focalDistanceDisplayValue,format:.number)
          //            .frame(width:80)
            .focused($focalDistanceFieldFocused)
            .padding([.leading],8)
            .onChange(of: focalDistanceDisplayValue) { _ in
              print("new distance: \(focalDistanceDisplayValue)")
              focalDistance = focalDistanceDisplayValue * calc
              print("lens distance: \(focalDistance)")
            }
          
          Picker("",selection:$calc){
            Text("mm").tag(LengthConvert.mm.rawValue)
            Text("cm").tag(LengthConvert.cm.rawValue)
            Text("m").tag(LengthConvert.m.rawValue)
          }.onChange(of: calc){ _ in
            focalDistanceFieldFocused = false
            focalDistanceDisplayValue = focalDistance / calc
          }
          .frame(width:60)
        }
        
        Text("")
      }
      
      Spacer()
    }.padding().frame(height:680)
  }
  
}

struct DoFCalculator_Previews: PreviewProvider {
  static var previews: some View {
    DoFCalculator(selectedLens: 1,
                  selectedSensor: "1. Full Frame",
                  selectedZeiss: Sensor.ZeissRatio.modern.rawValue,
                  selectedAperture: 5.6,
                  focalDistance: 380,
                  focalDistanceDisplayValue: 380)
    .environmentObject(ApplicationData(lenses: Lenses.dummyLenses()))
  }
}
