import Foundation

struct TiltCoachMessage {
    enum MessageType {
        case warning
        case danger
    }

    let type: MessageType
    let headline: String
    let detail: String
}
