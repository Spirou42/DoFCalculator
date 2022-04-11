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
  
  @State var calculator:DoFCalc = DoFCalc()
  
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
  
  init(){
    selectedLens = 0
    selectedSensor="1. Full Frame"
    selectedZeiss=1500
    selectedAperture=2.8
    focalDistanceDisplayValue = 380
    focalDistance = 380
    calc = LengthConvert.mm.rawValue
  }
  
  var columns: [GridItem] = [.init(.fixed(70),spacing:0.5,alignment:.trailing ),
                             .init(.fixed(300),spacing:0.5,alignment:.leading ),
                             .init(.fixed(200),spacing:0.5,alignment:.trailing )
  ]
  public func checkFocalDistance() -> String{
    var result:String = ""
    if focalDistance < lensFromSelection.minimalFocalDistance {
      result = "Focal distance to small"
    }
    return result
  }
  
  public func updateCalculator(){
    calculator.lens = self.lensFromSelection
    calculator.sensor = self.sensorFromSelection
  }
  
  var body: some View {
    VStack(spacing: 5){
      Text("DoF Calculator").font(.largeTitle).frame(alignment:.center)
      Collapsible(label: {
        Text("Sensor").font(.title)
      }){
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
          }.onChange(of: selectedSensor){_ in
            updateCalculator()
          }
          
          Text( (appData.sensorData.knownSensors[selectedSensor])?.sizeString ?? "").frame(width:200,alignment:.center)
          
          Text("Zeiss:")
          Picker("",selection: $selectedZeiss){
            Text("Traditional").tag(Sensor.ZeissRatio.traditional.rawValue)
            Text("Classic").tag(Sensor.ZeissRatio.classic.rawValue)
            Text("Modern").tag(Sensor.ZeissRatio.modern.rawValue)
          }.onChange(of: selectedZeiss){_ in
            updateCalculator()
          }
          Text("")
        }
      }// Collapsible
      
      Collapsible(label: {
        Text("Lens").font(.title)
      }){
        
        LazyVGrid(columns:columns,spacing:5){
          
          Text("Model:")
          
          Picker("",selection: $selectedLens){
            ForEach(0..<appData.lensData.lenses.count, id:\.self ){ t in
              Text(appData.lensData.lenses[t].manufacturer + " - " + appData.lensData.lenses[t].modelName).tag(t)
            }
          }.pickerStyle(MenuPickerStyle())
            .onChange(of: selectedLens){_ in
              updateCalculator()
            }
          
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
      }
      
      Collapsible(label: {
        Text("Settings").font(.title)
      }){
        
        LazyVGrid(columns:columns,spacing:5){
          Text("Aperture:")
          Picker("", selection:$selectedAperture){
            ForEach(lensFromSelection.apertureList(),id:\.self ){ description in
              Text(description.label).tag(description.aperture)
              if description.isStepEnd {
                Divider()
              }
            }
          }.onChange(of: selectedAperture){_ in
            updateCalculator()
          }
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
                updateCalculator()
              }
            
            Picker("",selection:$calc){
              Text("mm").tag(LengthConvert.mm.rawValue)
              Text("cm").tag(LengthConvert.cm.rawValue)
              Text("m").tag(LengthConvert.m.rawValue)
            }.onChange(of: calc){ _ in
              focalDistanceFieldFocused = false
              focalDistanceDisplayValue = focalDistance / calc
              updateCalculator()
            }
            .frame(width:60)
          }
          
          Text(checkFocalDistance())
        }
      }
      Divider()

      LazyVGrid(columns:columns,spacing:5){
        Group{
          Text("Hyper: ")
          Text("\(calculator.hyperFocalDistance(aperture: selectedAperture, zeissQuotient: Double(selectedZeiss)).formatted())")
          Text("")
        }
        Group {
          Text("Near:")
          Text("\(calculator.nearFocalDistance(objectDistance:focalDistance ,aperture: selectedAperture, zeissQuotient: Double(selectedZeiss)).formatted())")
          Text("")
        }
        
        Group {
          Text("Far:")
          Text("\(calculator.farFocalDistance(objectDistance:focalDistance ,aperture: selectedAperture, zeissQuotient: Double(selectedZeiss)).formatted())")
          Text("")
        }
        Group {
          Text("DoF:")
          Text("\( (calculator.farFocalDistance(objectDistance:focalDistance ,aperture: selectedAperture, zeissQuotient: Double(selectedZeiss)) - calculator.nearFocalDistance(objectDistance:focalDistance ,aperture: selectedAperture, zeissQuotient: Double(selectedZeiss))).formatted())")
          Text("")
        }
      }.font(.title)
      
      Spacer()
    }.padding()
      .frame(minHeight: 300, idealHeight: .none, maxHeight:600)
      .fixedSize(horizontal:true, vertical:false)
      .animation(.easeOut)
  }
  
}

struct DoFCalculator_Previews: PreviewProvider {
  static var previews: some View {
    DoFCalculator()
    .environmentObject(ApplicationData(lenses: Lenses.dummyLenses()))
  }
}
