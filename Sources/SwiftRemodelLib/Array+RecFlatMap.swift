//
//  Array+RecFlatMap.swift
//  SwiftSyntax
//
//  Created by Lee Heng Hong on 28/12/18.
//

import Foundation

public extension Array {
  func recFlatMap(_ arr:[URL]) -> [URL]{
    var result:[URL] = []
    try! arr.forEach{
      if #available(OSX 10.11, *) {
        if($0.hasDirectoryPath){
          let contents = try FileManager.default.contentsOfDirectory(at: $0,
                                                                     includingPropertiesForKeys: nil,
                                                                     options: [.skipsHiddenFiles])
          result += recFlatMap(contents)
        }else{
          if $0.lastPathComponent.contains(".swift") { result.append($0) }
        }
      } else {
        assertionFailure("min 10.11")
      }
    }
    return result
  }
}
