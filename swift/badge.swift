import Foundation
import Moderator
import SwiftShell

let arguments = Moderator(description: "Badge your app's icons (github link).")

let iconArg = arguments.add(Argument<String>.optionWithValue("i", name: "icon", description: "The icon to be added to your app icons.").required())

do {
    try arguments.parse()
    
    run("badge", "--custom", iconArg.value )
    
} catch {
    print("*** FAILURE!")
    print(error)
    exit(Int32(error._code))
}
