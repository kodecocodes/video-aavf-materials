///// Copyright (c) 2021 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI
import AVFoundation

struct ContentView: View {

  @ObservedObject var audioBox: AudioBox
  @ObservedObject var penguinAnimator: PenguinAnimator

  init() {
    let theAudioBox = AudioBox()
    audioBox = theAudioBox
    penguinAnimator = .init(audioBox: theAudioBox)
  }

  @State var hasMicAccess = false
  @State var displayNotification = false

  var body: some View {
    NavigationView {
      GeometryReader { geometry in
        ZStack {
          Image("bg")
            .resizable()
            .edgesIgnoringSafeArea(.all)
          VStack {
            Image(penguinAnimator.frame)
              .padding(.top, geometry.size.height * 0.1)
            ZStack {
              Image("Overlay")
                .resizable()
                .edgesIgnoringSafeArea(.bottom)
              VStack {
                Text(penguinAnimator.time)
                  .font(Font.custom("Menlo Bold", size: 24.0))
                .foregroundColor(Color(red: 0.1, green: 0.28, blue: 0.52))
                  .padding(.top)
                Spacer()
                VStack {
                  HStack {
                    Button {
                      // record audio
                      if audioBox.status == .stopped {
                        if hasMicAccess {
                          audioBox.record()
                          penguinAnimator.startUpdateLoop()
                        } else {
                          requestMicrophoneAccess()
                        }
                      } else {
                        audioBox.stopRecording()
                        penguinAnimator.stopUpdateLoop()
                      }
                    } label: {
                      Image(audioBox.status == .recording ? "button-record-active" : "button-record-inactive")
                    }
                    Button {
                      // play audio
                      if audioBox.status == .playing {
                        audioBox.stopPlayback()
                        penguinAnimator.stopUpdateLoop()
                      } else {
                        audioBox.play()
                        penguinAnimator.startUpdateLoop()
                      }
                    } label: {
                      Image(audioBox.status == .playing ? "button-play-active" : "button-play-inactive")
                    }
                  }
                   .padding([.leading, .trailing])
                }
                .padding(.top, 50)
                Spacer()
              }
            }
          }
        }
        .onAppear {
          audioBox.setupRecorder()
        }
        .alert(isPresented: $displayNotification) {
          Alert(title: Text("Requires Microphone Access"), message: Text("Go to Settings > PenguinPet > Allow PenguinPet to Access Microphone.\nSet switch to enable."), dismissButton: .default(Text("OK")))
        }
      }.navigationBarHidden(true)
    }
  }

  private func requestMicrophoneAccess() {
    let session = AVAudioSession.sharedInstance()
    session.requestRecordPermission { granted in
      hasMicAccess = granted
      if granted {
        audioBox.record()
        penguinAnimator.startUpdateLoop()
      } else {
        displayNotification = true
      }
    }
  }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
