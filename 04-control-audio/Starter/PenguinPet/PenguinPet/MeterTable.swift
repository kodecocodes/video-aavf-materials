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

import Foundation

class MeterTable {
  let minDb: Float = -60.0
  var tableSize: Int // 300
  
  let scaleFactor: Float
  var meterTable = [Float]()
  
  init (tableSize: Int) {
    self.tableSize = tableSize
    
    let dbResolution = Float(minDb / Float(tableSize - 1))
    scaleFactor = 1.0 / dbResolution
    
    let minAmp = dbToAmp(dB: minDb)
    let ampRange = 1.0 - minAmp
    let invAmpRange = 1.0 / ampRange
    
    for i in 0..<tableSize {
      let decibels = Float(i) * dbResolution
      let amp = dbToAmp(dB: decibels)
      let adjAmp = (amp - minAmp) * invAmpRange
      meterTable.append(adjAmp)
    }
  }
  
  private func dbToAmp(dB: Float) -> Float {
    return powf(10.0, 0.05 * dB)
  }

  func valueFor(power: Float) -> Float {
    if power < minDb {
      return 0.0
    } else if power >= 0.0 {
      return 1.0
    } else {
      let index = Int(power * scaleFactor)
      return meterTable[index]
    }
  }
}
