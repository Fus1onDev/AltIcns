//
//  extension.swift
//  alticns
//
//  Created by Fus1onDev on 2022/08/13.
//

import Foundation

extension URL {
    var isDirectory: Bool {
       (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}
