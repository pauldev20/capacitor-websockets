import Foundation

@objc public class WebSockets: NSObject {
    @objc public func echo(_ value: String) -> String {
        print(value)
        return value
    }
}
