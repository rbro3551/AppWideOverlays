//
//  ContentView.swift
//  AppWideOverlays
//
//  Created by Riley Brookins on 10/29/24.
//

import SwiftUI
import AVKit

struct ContentView: View {
    
    @State private var show: Bool = false
    @State private var showSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                Button("Floating Video Player") {
                    show.toggle()
                }
                .universalOverlay(show: $show) {
                    FloatingVideoPlayerView(show: $show)
                }
                
                Button("Show Dummy Sheet") {
                    showSheet.toggle()
                }
            }
            .navigationTitle("Universal Overlay")
        }
        .sheet(isPresented: $showSheet) {
            Text("Hello from sheets!")
        }
    }
}


struct FloatingVideoPlayerView: View {
    @Binding var show: Bool
    // View properties
    @State private var player: AVPlayer?
    @State private var offset: CGSize = .zero
    @State private var lastStoredOffset: CGSize = .zero
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            Group {
                if let videoURL {
                    VideoPlayer(player: player)
                        .background(.black)
                        .clipShape(.rect(cornerRadius: 25))
                } else {
                    RoundedRectangle(cornerRadius: 25)
                }
            }
            .frame(height: 250)
            .offset(offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let translation = value.translation + lastStoredOffset
                        offset = translation
                    }.onEnded { value in
                        withAnimation(.bouncy) {
                            // limiting to not move away from the screen
                            offset.width = 0
                            
                            if offset.height < 0 {
                                offset.height = 0
                            }
                            
                            if offset.height > (size.height - 250) {
                                offset.height = (size.height - 250)
                            }
                            
                        }
                        lastStoredOffset = offset
                    }
            )
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .padding(.horizontal, 15)
        .transition(.blurReplace)
        .onAppear {
            if let videoURL {
                player = AVPlayer(url: videoURL)
                player?.play()
            }
        }
    }
    
    var videoURL: URL? {
        if let bundle = Bundle.main.path(forResource: "abdemo", ofType: "mp4") {
            return .init(filePath: bundle)
        }
        
        return nil
    }
}

extension CGSize {
    static func +(lhs: CGSize, rhs: CGSize) -> CGSize {
        return .init(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
}

#Preview {
    RootView {
        ContentView()
    }
}
