import Foundation
import SwiftCLI

let Alticns = CLI(name: "alticns")
Alticns.commands = [SetCommand(), ResetCommand(), ListCommand()]
Alticns.go()