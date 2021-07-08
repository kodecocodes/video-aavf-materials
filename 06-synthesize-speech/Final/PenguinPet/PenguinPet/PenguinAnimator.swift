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

import Foundation
import UIKit

class PenguinAnimator: NSObject, ObservableObject {

  @Published var frame = "penguin_01"
  @Published var time = "00:00:00"

  let audioBox: AudioBox
  var updateTimer: CADisplayLink?
  var speechTimer: CFTimeInterval = 0.0
  var recordingTimer: CFTimeInterval = 0.0
  let totalFrames = 5

  init(audioBox: AudioBox) {
    self.audioBox = audioBox
  }

  func startUpdateLoop() {
    if let updateTimer = updateTimer {
      updateTimer.invalidate()
    }
    updateTimer = CADisplayLink(target: self, selector: #selector(updateLoop))
    updateTimer?.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
  }

  @objc func updateLoop() {
    if audioBox.status == .playing {
      if CFAbsoluteTimeGetCurrent() - speechTimer > 0.1 {
        speechTimer = CFAbsoluteTimeGetCurrent()
        animatePenguinTo(frameNumber: Int.random(in: 1...5))
        time = formattedCurrentTime(time: UInt(audioBox.audioPlayer?.currentTime ?? 0))
      }
    }
    if audioBox.status == .recording {
      if CFAbsoluteTimeGetCurrent() - recordingTimer > 0.5 {
        time = formattedCurrentTime(time: UInt(audioBox.audioRecorder?.currentTime ?? 0))
        recordingTimer = CFAbsoluteTimeGetCurrent()
      }
    }
  }

  func stopUpdateLoop() {
    updateTimer?.invalidate()
    updateTimer = nil
    animatePenguinTo(frameNumber: 1)
    time = "00:00:00"
  }

  private func formattedCurrentTime(time: UInt) -> String {
    let hours = time / 3600
    let minutes = (time / 60) % 50
    let seconds = time % 60

    return String(format: "%02i:%02i:%02i", arguments: [hours, minutes, seconds])
  }

  func meterLevelsToFrame() -> Int {
    audioBox.audioPlayer?.updateMeters()
    let avgPower = audioBox.audioPlayer?.averagePower(forChannel: 0) ?? 0
    let linearLevel = audioBox.meterTable.valueFor(power: avgPower)
    let powerPercentage = Int(round(linearLevel * 100))
    let frame = (powerPercentage / totalFrames) + 1
    return min(frame, totalFrames)
  }

  private func animatePenguinTo(frameNumber: Int) {
    frame = "penguin_0\(frameNumber)"
  }

}
