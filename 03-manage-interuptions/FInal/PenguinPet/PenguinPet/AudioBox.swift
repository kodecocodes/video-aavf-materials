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
import AVFoundation

class AudioBox: NSObject, ObservableObject {

  @Published var status: AudioStatus = .stopped

  var audioRecorder: AVAudioRecorder?
  var audioPlayer: AVAudioPlayer?

  var urlForMemo: URL {
    let fileManager = FileManager.default
    let tempDir = fileManager.temporaryDirectory
    let filePath = "TempMemo.caf"
    return tempDir.appendingPathComponent(filePath)
  }

  override init() {
    super.init()
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(self, selector: #selector(handleRouteChange), name: AVAudioSession.routeChangeNotification, object: nil)
    notificationCenter.addObserver(self, selector: #selector(handleInteruption), name: AVAudioSession.interruptionNotification, object: nil)
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  @objc func handleRouteChange(notification: Notification) {
    if let info = notification.userInfo,
       let rawValue = info[AVAudioSessionRouteChangeReasonKey] as? UInt {
      let reason = AVAudioSession.RouteChangeReason(rawValue: rawValue)
      if reason == .oldDeviceUnavailable {
        guard let previousRoute = info[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription,
              let previousOutput = previousRoute.outputs.first else {
          return
        }
        if previousOutput.portType == .headphones {
          if status == .playing {
            stopPlayback()
          } else if status == .recording {
            stopRecording()
          }
        }
      }
    }
  }

  @objc func handleInteruption(notification: Notification) {
    if let info = notification.userInfo,
       let rawValue = info[AVAudioSessionInterruptionTypeKey] as? UInt {
      let type = AVAudioSession.InterruptionType(rawValue: rawValue)
      if type == .began {
        if status == .playing {
          stopPlayback()
          previousStatus = .playing
        } else if status == .recording {
          stopRecording()
          previousStatus = .recording
        }
      } else {
        if let rawValue = info[AVAudioSessionInterruptionOptionKey] as? UInt {
          let options = AVAudioSession.InterruptionOptions(rawValue: rawValue)
          if options == .shouldResume {
            // restart audio or restart recording
          }
        }
      }
    }
  }


  func setupRecorder() {
    let recordSettings: [String: Any] = [
      AVFormatIDKey: Int(kAudioFormatLinearPCM),
      AVSampleRateKey: 44100.0,
      AVNumberOfChannelsKey: 1,
      AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]
    do {
      audioRecorder = try AVAudioRecorder(url: urlForMemo, settings: recordSettings)
      audioRecorder?.delegate = self
    } catch {
      print("Error creating audioRecorder")
    }
  }

  func record() {
    audioRecorder?.record()
    status = .recording
  }

  func stopRecording() {
    audioRecorder?.stop()
    status = .stopped
  }

  func play() {
    do {
      audioPlayer = try AVAudioPlayer(contentsOf: urlForMemo)
    } catch {
      print(error.localizedDescription)
    }
    guard let audioPlayer = audioPlayer else { return }
    audioPlayer.delegate = self
    if audioPlayer.duration > 0.0 {
      audioPlayer.play()
      status = .playing
    }
  }

  func stopPlayback() {
    audioPlayer?.stop()
    status = .stopped
  }

}

extension AudioBox: AVAudioRecorderDelegate {
  func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
    status = .stopped
  }
}

extension AudioBox: AVAudioPlayerDelegate {
  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    status = .stopped
  }
}
