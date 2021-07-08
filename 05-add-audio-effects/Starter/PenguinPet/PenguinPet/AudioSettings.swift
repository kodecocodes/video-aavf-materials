///// Copyright (c) 2020 Razeware LLC
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

struct AudioSettings: View {

  @Environment(\.presentationMode) var presentationMode

  @ObservedObject var audioBox: AudioBox

  init(audioBox: AudioBox) {
    self.audioBox = audioBox
  }

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        Image("bg")
          .resizable()
          .edgesIgnoringSafeArea(.all)
        VStack {
          VStack {
            HStack {
              Text("Pitch")
                .foregroundColor(.black)
              Slider(value: .constant(0.5))
            }
            .padding([.leading, .trailing], 20)
            .padding(.bottom)
            HStack {
              Text("Reverb:")
                .foregroundColor(.black)
              Slider(value: .constant(0.5))
            }
            .padding([.leading, .trailing], 20)
            .padding(.bottom)
          }
          Spacer()
            .frame(maxHeight: geometry.size.height * 0.5)
          HStack {
            Spacer()
            Button {
              // action
              audioBox.stopPlayback()
            } label: {
              Text("Reset")
                .padding(.all, 5)
                .frame(maxWidth: 85.0)
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(5.0)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.black, lineWidth: 2))
                .padding(.bottom)
            }
            Spacer()
            Button {
              // action
              audioBox.play()
            } label: {
              Text("Preview")
                .padding(.all, 5)
                .frame(maxWidth: 85.0)
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(5.0)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.black, lineWidth: 2))
                .padding(.bottom)
            }
            Spacer()
          }

          ZStack {
            Image("Overlay")
              .resizable()
              .edgesIgnoringSafeArea(.bottom)
            VStack {
              VStack {

              }
              Spacer()
              VStack {
                Button {
                  presentationMode.wrappedValue.dismiss()
                } label: {
                  Text("Done")
                    .font(.system(size: 26.0))
                    .padding(.all, 5)
                    .frame(maxWidth: 85.0)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(10.0)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2))
                }

              }
              .padding(.top, 50)
              Spacer()
            }
          }
        }
        .padding(.top)
      }.navigationBarHidden(true)
    }
  }
}

struct AudioSettingsAudioEffects_Previews: PreviewProvider {
  static var previews: some View {
    AudioSettings(audioBox: AudioBox())
  }
}

