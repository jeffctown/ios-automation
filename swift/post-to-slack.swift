import Foundation
import Moderator
import SlackApi

class RunLoop {
    static var dispatchSemaphore = DispatchSemaphore(value: 0)
}

let arguments = Moderator(description: "Post a message to Slack.")

let messageArg = arguments.add(Argument<String>.optionWithValue("m", name: "message", description: "The message to post.").required())
let urlSlugArg = arguments.add(Argument<String>.optionWithValue("p", name: "path", description: "The url path (the part after https://hooks.slack.com/services/).").required())

do {
    try arguments.parse()
    
    Slack.loggingEnabled = true
    try Slack().postMessage(urlSlug: urlSlugArg.value, message: messageArg.value, completion: { (data, error) in
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
