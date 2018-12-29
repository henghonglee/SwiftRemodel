import XCTest
import class Foundation.Bundle
import Files
@testable import SwiftRemodelLib

final class swift_remodelTests: XCTestCase {
  func testCreatingFile() throws {
    // Some of the APIs that we use below are available in macOS 10.13 and above.
    guard #available(macOS 10.13, *) else {
      return
    }

    // Setup a temp test folder that can be used as a sandbox
    let fileSystem = FileSystem()
    let tempFolder = fileSystem.temporaryFolder
    let testFolder = try tempFolder.createSubfolderIfNeeded(
      withName: "swift-remodel-tests"
    )
    
    // Empty the test folder to ensure a clean state
    try testFolder.empty()
    
    // Make the temp folder the current working folder
    let fileManager = FileManager.default
    fileManager.changeCurrentDirectoryPath(testFolder.path)
    let newfilePath = URL(fileURLWithPath: testFolder.path).appendingPathComponent("sample.swift")
    let resultfilePath = URL(fileURLWithPath: testFolder.path).appendingPathComponent(RemodelConstants.enumMatchFileName)
    fileManager.createFile(atPath: newfilePath.path, contents: nil, attributes: nil)
    try swift_remodelTests.testText.write(to: newfilePath, atomically: false, encoding: .utf8)
    
    let arguments = [testFolder.path]
    let tool = CommandLineTool.init(arguments: arguments)
    try! tool.run()
    
    XCTAssertNotNil(try? testFolder.file(named: "sample.swift"))
    XCTAssertNotNil(try? testFolder.file(named: RemodelConstants.enumMatchFileName))
    
    let sampleText = try String(contentsOf: newfilePath, encoding: .utf8)
    XCTAssertEqual(sampleText, swift_remodelTests.testText)
    let resultTextOut = try String(contentsOf: resultfilePath, encoding: .utf8)
    XCTAssertEqual(resultTextOut, swift_remodelTests.resultText)
  }

  static var allTests = [
      ("testCreatingFile", testCreatingFile),
  ]
  
  static let testText = """
  Struct someStruct {
    let someProperty: Int
    enum Action {
      case fighter(F)
      case weapon(W)

      enum F {
          case attack(A)
          case defend(D)
          case hurt(H)

          enum A {
              case fail
              case success
          }
          enum D {
              case fail
              case success
          }
          enum H {
              case none
              case some
          }
      }
      enum W {
          case swing
          case back
      }
      case anotherWeapon(W)
    }
  }

  """
  static let resultText = """
  import Foundation
  
  extension A {
    func match(fail:()->Void, success:()->Void) {
      switch self {
      case .fail:
        fail()
      case .success:
        success()
      }
    }
  }
  extension Action {
    func match(fighter:(F)->Void, weapon:(W)->Void, anotherWeapon:(W)->Void) {
      switch self {
      case .fighter(let param0):
        fighter(param0)
      case .weapon(let param0):
        weapon(param0)
      case .anotherWeapon(let param0):
        anotherWeapon(param0)
      }
    }
  }
  extension D {
    func match(fail:()->Void, success:()->Void) {
      switch self {
      case .fail:
        fail()
      case .success:
        success()
      }
    }
  }
  extension F {
    func match(attack:(A)->Void, defend:(D)->Void, hurt:(H)->Void) {
      switch self {
      case .attack(let param0):
        attack(param0)
      case .defend(let param0):
        defend(param0)
      case .hurt(let param0):
        hurt(param0)
      }
    }
  }
  extension H {
    func match(none:()->Void, some:()->Void) {
      switch self {
      case .none:
        none()
      case .some:
        some()
      }
    }
  }
  extension W {
    func match(swing:()->Void, back:()->Void) {
      switch self {
      case .swing:
        swing()
      case .back:
        back()
      }
    }
  }
  
  """
}
