//
//  ResetCommand.swift
//  alticns
//
//  Created by Fus1onDev on 2022/08/13.
//

import Cocoa
import SwiftCLI

class ResetCommand: Command {
    let name = "reset"
    let shortDescription = "Resets icon changes"
    
    @Param var app: String?
    @Flag("-a", "--all", description: "Reset all icons") var all: Bool
    @Flag("-r", "--remove", description: "Remove stored icons at the same time") var remove: Bool

    func execute() throws {
        if all {
            let storeDirUrl = URL(fileURLWithPath: ".alticns", isDirectory: true)
            checkChildren(storeDirUrl)
        } else if let app = app {
            guard validate(app) else {
                exit(0)
            }
            
            reset(app)
            if remove {
                var path = URL(fileURLWithPath: app).deletingPathExtension().appendingPathExtension("icns").path
                if path.hasPrefix("/") {
                    path = String(path.dropFirst())
                }
                let storeDirUrl = URL(fileURLWithPath: ".alticns", isDirectory: true)
                let storedIconUrl = storeDirUrl.appendingPathComponent(path, isDirectory: false)
                remove(storedIconUrl.path)
            }
        } else {
            print("Error: Missing arguments")
        }
    }
    
    func validate(_ app: String) -> Bool {
        let fileManager: FileManager = FileManager.default
        // Verify the file actually exists.
        var isDir: ObjCBool = false
        guard fileManager.fileExists(atPath: app, isDirectory: &isDir) else {
            print("File does not exist at \(app)")
            return false
        }
        // Check path extension
        guard URL(fileURLWithPath: app).pathExtension == "app" else {
            print("It is not .app: \(app)")
            return false
        }
        return true
    }
    
    func checkChildren(_ url: URL) {
        let fileManager: FileManager = FileManager.default
        if let contentUrls = try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil) {
            for contentUrl in contentUrls {
                if contentUrl.isDirectory {
                    checkChildren(contentUrl)
                } else if contentUrl.lastPathComponent != ".DS_Store" {
                    let storePath = URL(fileURLWithPath: ".alticns", isDirectory: true).path
                    var appPath = contentUrl.deletingPathExtension().appendingPathExtension("app").path
                    appPath = appPath.suffix(appPath.count - storePath.count).description
                    reset(appPath)
                    if remove {
                        remove(contentUrl.path)
                    }
                }
            }
        } else {
            print("Warn: \"\(url.path)\" does not exist or has no contents")
        }
    }
    
    func remove(_ path: String) {
        let fileManager: FileManager = FileManager.default
        var isDir: ObjCBool = false
        if fileManager.fileExists(atPath: path, isDirectory: &isDir) {
            do {
                try fileManager.removeItem(atPath: path)
                print("Removed \(path)")
            } catch {
                print("Failed to remove \(path)")
            }
        }
    }
    
    func reset(_ path: String) {
        NSWorkspace.shared.setIcon(nil, forFile: path, options: NSWorkspace.IconCreationOptions.excludeQuickDrawElementsIconCreationOption)
        
        let appName = URL(fileURLWithPath: path).lastPathComponent
        print("Successfully reset the icon of \(appName)")
    }
}
