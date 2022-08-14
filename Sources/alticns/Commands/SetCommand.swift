//
//  SetCommand.swift
//  alticns
//
//  Created by Fus1onDev on 2022/08/13.
//

import Cocoa
import SwiftCLI

class SetCommand: Command {
    let name = "set"
    let shortDescription = "Sets an alternate icon for the app"

    let storeDirUrl = URL(fileURLWithPath: NSHomeDirectory()+"/.alticns", isDirectory: true)
    
    @Param var app: String?
    @Param var icon: String?
    @Flag("-a", "--all", description: "Set all icons") var all: Bool
    @Flag("-r", "--remove", description: "Remove original file(s)") var remove: Bool
    @Flag("-s", "--stored", description: "Use the stored icon") var store: Bool

    func execute() {
        if all {
            checkChildren(storeDirUrl)
        } else if store {
            if let app = app {
                guard validate(app, nil) else {
                    exit(0)
                }
                checkDir()
                var path = URL(fileURLWithPath: app).deletingPathExtension().appendingPathExtension("icns").path
                if path.hasPrefix("/") {
                    path = String(path.dropFirst())
                }
                let storedIconUrl = storeDirUrl.appendingPathComponent(path, isDirectory: false)
                
                let fileManager: FileManager = FileManager.default
                var isDir: ObjCBool = false
                if fileManager.fileExists(atPath: storedIconUrl.path, isDirectory: &isDir) {
                    setIcon(app, storedIconUrl.path)
                } else {
                    let appName = storedIconUrl.deletingPathExtension().lastPathComponent
                    print("Error: Saved icon for \(appName) not found")
                }
                
            } else {
                print("Error: Missing arguments")
            }
        } else if let app = app, let icon = icon {
            guard validate(app, icon) else {
                exit(0)
            }
            
            checkDir()
            
            var path = URL(fileURLWithPath: app).deletingPathExtension().appendingPathExtension("icns").path
            if path.hasPrefix("/") {
                path = String(path.dropFirst())
            }
            let storedIconUrl = storeDirUrl.appendingPathComponent(path, isDirectory: false)
            
            copyIcon(icon, storedIconUrl)
            
            setIcon(app, storedIconUrl.path)
            
            if remove {
                remove(icon)
            }
        } else {
            print("Error: Missing arguments")
        }
    }
    
    func validate(_ app: String, _ icon: String?) -> Bool {
        let fileManager: FileManager = FileManager.default
        var isDir: ObjCBool = false
        guard fileManager.fileExists(atPath: app, isDirectory: &isDir) else {
            print("File does not exist at \(app)")
            return false
        }
        guard URL(fileURLWithPath: app).pathExtension == "app" else {
            print("It is not .app: \(app)")
            return false
        }
        if let icon = icon {
            guard fileManager.fileExists(atPath: icon, isDirectory: &isDir) else {
                print("File does not exist at \(icon)")
                return false
            }
            guard URL(fileURLWithPath: icon).pathExtension == "icns" else {
                print("It is not .icns: \(icon)")
                return false
            }
        }
        return true
    }
    
    func checkDir() {
        let fileManager: FileManager = FileManager.default
        var isDir: ObjCBool = true
        if fileManager.fileExists(atPath: ".alticns", isDirectory: &isDir) {
            print(".alticns directory already exists")
        } else {
            print(".alticns directory does not exist")
            do {
                try fileManager.createDirectory(atPath: ".alticns", withIntermediateDirectories: true, attributes: nil)
                print("Created .alticns directory")
            } catch {
                print("Failed to create directory")
            }
        }
    }
    
    func setIcon(_ app: String, _ icon: String) {
        let iconImage = NSImage(byReferencingFile: icon)
        NSWorkspace.shared.setIcon(iconImage, forFile: app, options: NSWorkspace.IconCreationOptions.excludeQuickDrawElementsIconCreationOption)
        let appName = URL(fileURLWithPath: app).lastPathComponent
        print("Successfully set the icon for \(appName)")
    }
    
    func copyIcon(_ icon: String, _ targetUrl: URL) {
        let fileManager: FileManager = FileManager.default
        do {
            var isDir: ObjCBool = false
            let iconDirectoryPath = targetUrl.deletingLastPathComponent().path
            if !fileManager.fileExists(atPath: iconDirectoryPath, isDirectory: &isDir) {
                try fileManager.createDirectory(atPath: iconDirectoryPath, withIntermediateDirectories: true, attributes: nil)
            }
            try fileManager.copyItem(at: URL(fileURLWithPath: icon), to: targetUrl)
            print("Copied \(icon)")
        } catch {
            print("Failed to copy \(icon)")
        }
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
                    setIcon(appPath, contentUrl.path)
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
}
