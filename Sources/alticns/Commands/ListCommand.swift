//
//  ListCommand.swift
//  alticns
//
//  Created by Fus1onDev on 2022/08/13.
//

import Foundation
import SwiftCLI

class ListCommand: Command {
    let name = "list"
    let shortDescription = "Shows list of stored icons"

    let storeDirUrl = URL(fileURLWithPath: NSHomeDirectory()+"/.alticns", isDirectory: true)
    
    func execute() throws {
        let fileManager: FileManager = FileManager.default
        var isDir: ObjCBool = true
        if !fileManager.fileExists(atPath: storeDirUrl.path, isDirectory: &isDir) {
          print("Warn: .alticns directory does not exist")
          exit(0)
        } 

        printChildren(storeDirUrl, 0)
    }

    func printChildren(_ url: URL, _ level: Int) {
        let fileManager: FileManager = FileManager.default
        if let contentUrls = try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil) {
            for contentUrl in contentUrls {
                if contentUrl.isDirectory {
                    let indent = String(repeating: "  ", count: level)
                    let dirName = contentUrl.lastPathComponent
                    print(indent + dirName)
                    printChildren(contentUrl, level + 1)
                } else if contentUrl.lastPathComponent != ".DS_Store" {
                    let indent = String(repeating: "  ", count: level)
                    let appName = contentUrl.deletingPathExtension().lastPathComponent
                    print(indent + appName)
                }
            }
        }
    }
}
