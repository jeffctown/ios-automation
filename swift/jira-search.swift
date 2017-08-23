import Foundation
import JiraApi
import Moderator
import SlackApi

class RunLoop {
    static var dispatchSemaphore = DispatchSemaphore(value: 0)
}

let arguments = Moderator(description: "Perform a search using Jira's Search API.")

let hostArg = arguments.add(Argument<String>.optionWithValue("h", name: "host", description: "The host to Jira.").required())
let jqlArg = arguments.add(Argument<String>.optionWithValue("j", name: "jql", description: "The JQL to use to search.").required())
let slackArg = arguments.add(Argument<String>.optionWithValue("s", name: "slack", description: "The Slack room URL (TXXXXXXX/BXXXXXXX/XXXXXXXXXXX).").required())

do {
    try arguments.parse()
    try Jira().search(host: hostArg.value, jql: jqlArg.value) { (data, error) in
        if let error = error {
            print("*** Error Searching Jira: \(String(describing:error))")
            exit(Int32(error._code))
        }
        
        guard let data = data else {
            print("*** No Data Received!")
            exit(1)
        }
        
        do {
            guard let json = try JSONSerialization.jsonObject(with: data) as? [AnyHashable: Any] else {
                print("Could Not Parse Data!")
                exit(Int32(1))
            }
            
            guard let issues = json["issues"] as? [[AnyHashable: Any]] else {
                print("Could Not Parse issues!")
                exit(Int32(1))
            }
            
            print("*** Found \(issues.count) issues.")
            
            guard issues.count > 0 else {
                print("*** No tickets found!  Exiting.")
                exit(Int32(0))
            }
            
            var fullIssueString = ""
            for issue in issues {
                guard let fields = issue["fields"] as? [AnyHashable: Any] else {
                    print("No Fields found for issue.")
                    continue
                }
                
                guard let key = issue["key"] as? String else {
                    print("No Key found for issue.")
                    continue
                }
                
                guard let summary = fields["summary"] as? String else {
                    print("No summary found for issue.")
                    continue
                }
                
                guard let assignee = fields["assignee"] as? [AnyHashable: Any] else {
                    print("No Assignee found for issue.")
                    continue
                }
                
                guard let displayName = assignee["displayName"] as? String else {
                    print("No display name found for assignee.")
                    continue
                }
                
                guard let emailAddress = assignee["emailAddress"] as? String else {
                    print("No email address found for assignee.")
                    continue
                }
                
                //replace with hostArg
                let issueString = ("*\(displayName)* has a ticket waiting for product review: \(summary) - http://tickets.turner.com/browse/\(key) \n")
                fullIssueString += issueString
            }
            
            print("*** Issues: \n\(fullIssueString)")
            
            print("*** Posting to Slack...")
            Slack.loggingEnabled = true
            try Slack().postMessage(urlSlug: slackArg.value, message: fullIssueString, completion: { (data, error) in
                print("*** Done Posting to Slack.")
                
                if let error = error {
                    exit(Int32(error._code))
                }
                
                RunLoop.dispatchSemaphore.signal()
                
            })
            
            
        } catch let e {
            print("*** FAILURE!")
            print(e)
            exit(Int32(e._code))
        }
        
    }
    
    RunLoop.dispatchSemaphore.wait()
    
} catch let e {
    print("*** FAILURE!")
    print(e)
    exit(Int32(e._code))
}
