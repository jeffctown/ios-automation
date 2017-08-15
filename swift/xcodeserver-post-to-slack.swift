import Foundation
import Moderator
import SlackApi

class RunLoop {
    static var dispatchSemaphore = DispatchSemaphore(value: 0)
}

let arguments = Moderator(description: "Post Xcode Server Results to Slack.")

let botNameArg = arguments.add(Argument<String>.optionWithValue("n", name: "name", description: "The Xcode Server Bot's name.").required())
let integrationResultArg = arguments.add(Argument<String>.optionWithValue("r", name: "result", description: "The Xcode Server integration result.").required())
let errorChangeArg = arguments.add(Argument<Int>.optionWithValue("e", name: "errors", description: "The Xcode Server integration's change in errors.").required())
let warningChangeArg = arguments.add(Argument<Int>.optionWithValue("w", name: "warnings", description: "The Xcode Server integration's change in warnings.").required())
let urlSlugArg = arguments.add(Argument<String>.optionWithValue("p", name: "path", description: "The url path (the part after https://hooks.slack.com/services/).").required())

do {
    try arguments.parse()
    
    guard let errorChange = Int(errorChangeArg.value) else {
        throw ArgumentError(errormessage: "Errors value not an integer value.")
    }
    
    guard let warningChange = Int(warningChangeArg.value) else {
        throw ArgumentError(errormessage: "Warnings value not an integer value.")
    }
    
    print("*** Constructing Message.")
    
    // basic result
    var message = "\(botNameArg.value) was built with result *\(integrationResultArg.value)*"
    
    // add errors if the number of them changed
    if errorChange != 0 {
        message += " :no_entry_sign: Errors : \(errorChange)"
    }
    
    // add warnings if the number of them changed
    if warningChange != 0 {
        message += " :warning: Warnings: \(warningChange)"
    }
    print("*** Done Constructing Message. (\(message))")
    
    Slack.loggingEnabled = true
    try Slack().postMessage(urlSlug: urlSlugArg.value, message: message, completion: { (data, error) in
        if let error = error {
            exit(Int32(error._code))
        }
    
        RunLoop.dispatchSemaphore.signal()
    })
    
    RunLoop.dispatchSemaphore.wait()
    
} catch {
    print("*** FAILURE!")
    print(error)
    exit(Int32(error._code))
}
