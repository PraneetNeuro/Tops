//
//  ContentView.swift
//  Tops
//
//  Created by Praneet S on 11/03/21.
//

import SwiftUI

struct ContentView: View {
    
    @State var runningApps: [NSRunningApplication] = []
    var appPolicy = ["Regular", "Accessory", "Prohibited"]
    @State private var appPolicyIndex = 0
    @State var cpuUsage: Double = 0
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack{
            VStack(alignment: .leading) {
                Text("CPU UTILIZATION")
                    .bold()
                    .font(.title)
                    .padding()
                CPUView(value: $cpuUsage)
                    .padding(.leading)
                Text("Note: If your CPU utilization is crossing 100%,\nmacOS reports CPU utilization for each core at 100%")
                    .bold()
                    .lineLimit(3)
                    .padding()
            }
            VStack(alignment: .leading) {
            HStack {
                Text("Active apps")
                    .bold()
                Spacer()
                Picker(selection: $appPolicyIndex, label: Text("App policy")) {
                    ForEach(0 ..< appPolicy.count) {
                        Text(self.appPolicy[$0])
                    }
                }.frame(width: 160)
            }.padding([.horizontal, .top])
            List(runningApps, id: \.bundleIdentifier){ appInstance in
                VStack(alignment: .leading){
                    HStack{
                        Image(nsImage: appInstance.icon!)
                        Text(appInstance.localizedName ?? "Rogue app instance")
                        Spacer()
                        Group {
                            if appInstance.localizedName != "Finder" && appPolicyIndex == 0 {
                                Button("Make active") {
                                    appInstance.activate(options: .activateIgnoringOtherApps)
                                }
                            }
                            Button(appInstance.localizedName == "Finder" ? "Relaunch" : "Kill") {
                                appInstance.terminate()
                            }
                        }
                    }
                    if appInstance.activationPolicy == .regular {
                        Text(getMemoryStats(pid: appInstance.processIdentifier))
                            .lineLimit(2)
                    }
                }.padding(.bottom)
            }.listStyle(SidebarListStyle())
        }
        }
        .onAppear {
            runningApps = getRunningProcesses()
        }
        .onReceive(timer, perform: { _ in
            cpuUsage = getCPUUsage()
            if appPolicyIndex > 0 {
                runningApps = getRunningProcesses(policy: appPolicyIndex == 1 ? .accessory : .prohibited)
            } else {
                runningApps = getRunningProcesses()
            }
        })
        .frame(width: 700, height: 400, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
