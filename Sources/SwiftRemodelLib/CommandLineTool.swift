//
//  CommandLineTool.swift
//  Files
//
//  Created by Lee Heng Hong on 29/12/18.
//

import Foundation
import SwiftSyntax

@available(OSX 10.11, *)
public final class CommandLineTool {
  private let arguments: [String]
  
  public init(arguments: [String] = CommandLine.arguments) {
    self.arguments = arguments
  }
  
  public func run() throws {
    guard arguments.count > 1 else {
      throw Error.missingRootDirectoryOrFileName
    }
    // root directory to generate the new file, also searches all swift files starting from here
    let rootDirectoryUrl = URL(fileURLWithPath: arguments[1])
    
    var swiftFileUrls = [URL]()
    if rootDirectoryUrl.hasDirectoryPath {
      let contents = try! FileManager.default.contentsOfDirectory(at: rootDirectoryUrl,
                                                                  includingPropertiesForKeys: nil,
                                                                  options: [.skipsHiddenFiles])
      
      swiftFileUrls = contents.recFlatMap(contents)
    } else {
      swiftFileUrls.append(rootDirectoryUrl)
    }
    
    let factory = EnumMatchFactory()
    let nonGeneratedFiles = swiftFileUrls.filter { return !$0.lastPathComponent.contains(RemodelConstants.enumMatchFileName) }
    for (index, swiftFile) in nonGeneratedFiles.enumerated() {
      print("\(index)/\(nonGeneratedFiles.count) files")
      let sourceFile = try! SyntaxTreeParser.parse(swiftFile)
      let _ = factory.visit(sourceFile)
      factory.createEnumMatchFile(swiftFile)
    }
  }
}

@available(OSX 10.11, *)
public extension CommandLineTool {
  enum Error: Swift.Error {
    case missingRootDirectoryOrFileName
  }
}
