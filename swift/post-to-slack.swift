import Foundation
import Moderator
import SwiftShell

let arguments = Moderator(description: "Post a message to Slack.")

let messageArg = arguments.add(Argument<String?>.optionWithValue("m", name: "message", description: "The message to post."))

do {
    try arguments.parse()
    
    print("*** MessageArg.value: \(messageArg.value ?? "nil")")
    
    guard let message = messageArg.value else {
        throw ArgumentError(errormessage: "Slack message not found.", usagetext: "use -m Message")
    }
    
    print("*** Message: \(message)")    
    
} catch {
    print("*** FAILURE!")
    print(error)
    exit(Int32(error._code))
}


//xcode-server user top-build channel
//T063JHF8T/B57H8R62F/jeAKWiwzpvxpBQqYJ40kSuUG
//automation bot user ios-automation channel
//T063JHF8T/B34MRS0KB/hUY204wbpnmulJUkuBHN0EC8

//API_URL=https://hooks.slack.com/services/

//let integrationResultArg = arguments.add(Argument<String?>.optionWithValue("x", name: "xcoderesult", description: "The integration result from Xcode Server."))
//let errorsArg = arguments.add(Argument<String?>.optionWithValue("e", name: "errors", description: "The number of build errors."))
//let warningsArg = arguments.add(Argument<String?>.optionWithValue("w", name: "warnings", description: "The number of build warnings."))


//    guard let urlSlug = urlSlugArg.value else {
//        throw ArgumentError(errormessage: "Slack URL path not found.", usagetext: "use -p T000000/B000000/XXXXXXX")
//    }
//
//    guard let botName = botNameArg.value else {
//        throw ArgumentError(errormessage: "Bot name not found.", usagetext: "use -n BotName")
//    }


//let botNameArg = arguments.add(Argument<String?>.optionWithValue("n", name: "name", description: "The name of the bot."))
//let urlSlugArg = arguments.add(Argument<String>.optionWithValue("p", name: "path", description: "The url path (the part after https://hooks.slack.com/services/)."))

//    print("*** Constructing Slack URL.")
//    let apiUrl = "https://hooks.slack.com/services/" + urlSlug
//    print("*** Done constructing Slack URL. (\(apiUrl))")
