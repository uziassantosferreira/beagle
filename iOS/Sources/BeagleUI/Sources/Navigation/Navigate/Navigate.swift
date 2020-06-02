/*
 * Copyright 2020 ZUP IT SERVICOS EM TECNOLOGIA E INOVACAO SA
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

public enum Navigate: Action {
    
    case openExternalURL(String)
    case openNativeRoute(String, data: [String: String]? = nil, shouldResetApplication: Bool = false)

    case resetApplication(Route)
    case resetStack(Route)
        
    case pushStack(Route)
    case popStack

    case pushView(Route)
    case popView
    case popToView(String)
    
    public func execute(context: BeagleContext, sender: Any) {
        execute(context: context, sender: sender, animated: true)
    }
    
    func execute(context: BeagleContext, sender: Any, animated: Bool) {
        switch self {
        case .openExternalURL(let url):
            executeOpenExternalURL(url, context: context)
        case let .openNativeRoute(route, data, resetApplication):
            executeOpenNativeRoute(route, data: data, resetApplication: resetApplication, context: context, animated: animated)
        case .resetApplication(let route):
            executeResetApplication(route: route, context: context, animated: animated)
        case .resetStack(let route):
            executeResetStack(route: route, context: context, animated: animated)
        case .pushStack(let route):
            executePushStack(route: route, context: context, animated: animated)
        case .popStack:
            executePopStack(context: context, animated: animated)
        case .pushView(let route):
            executePushView(route: route, context: context, animated: animated)
        case .popView:
            executePopView(context: context, animated: animated)
        case .popToView(let route):
            executePopToView(identifier: route, context: context, animated: animated)
        }
    }
}

// MARK: Decodable

extension Navigate: Decodable {
    
    enum CodingKeys: CodingKey {
        case _beagleAction_
        case route
        case url
    }
    
    struct DeepLink: Decodable {
        var route: String
        var data: [String: String]?
        var shouldResetApplication: Bool = false
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: ._beagleAction_)
        switch type.lowercased() {
        case "beagle:openexternalurl":
            self = .openExternalURL(try container.decode(String.self, forKey: .url))
        case "beagle:opennativeroute":
            let deepLink: DeepLink = try .init(from: decoder)
            self = .openNativeRoute(deepLink.route,
                                    data: deepLink.data,
                                    shouldResetApplication: deepLink.shouldResetApplication)
        case "beagle:resetapplication":
            self = .resetApplication(try container.decode(Route.self, forKey: .route))
        case "beagle:resetstack":
            self = .resetStack(try container.decode(Route.self, forKey: .route))
        case "beagle:pushstack":
            self = .pushStack(try container.decode(Route.self, forKey: .route))
        case "beagle:popstack":
            self = .popStack
        case "beagle:pushview":
            self = .pushView(try container.decode(Route.self, forKey: .route))
        case "beagle:popview":
            self = .popView
        case "beagle:poptoview":
            self = .popToView(try container.decode(String.self, forKey: .route))
        default:
            throw DecodingError.dataCorruptedError(forKey: ._beagleAction_,
                                                   in: container,
                                                   debugDescription: "Can't decode '\(type)'")
        }
    }
}

extension Navigate {
    var newPath: Route.NewPath? {
        switch self {
        case let .resetApplication(route),
             let .resetStack(route),
             let .pushStack(route),
             let .pushView(route):
            return route.path
        default:
            return nil
        }
    }
}
