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

import Foundation

public enum Route {
    case remote(String, shouldPrefetch: Bool = false, fallback: Screen? = nil)
    case declarative(Screen)
}

extension Route {
    
    public struct NewPath {
        public let route: String
        public let shouldPrefetch: Bool
        public let fallback: Screen?
        
        public init(route: String, shouldPrefetch: Bool = false, fallback: Screen? = nil) {
            self.route = route
            self.shouldPrefetch = shouldPrefetch
            self.fallback = fallback
        }
    }
    
    var path: NewPath? {
        switch self {
        case let .remote(route, shouldPrefetch, fallback):
            return NewPath(route: route, shouldPrefetch: shouldPrefetch, fallback: fallback)
        case .declarative:
            return nil
        }
    }
    
    func screenController(context: BeagleContext) -> BeagleScreenViewController {
        return BeagleScreenViewController(
            viewModel: .init(
                screenType: screenType,
                dependencies: context.dependencies
            )
        )
    }
    
    private var screenType: ScreenType {
        switch self {
        case let .remote(route, _, fallback):
            return .remote(.init(url: route, fallback: fallback))
        case .declarative(let screen):
            return .declarative(screen)
        }
    }
}

extension Route: Decodable {
    
    enum CodingKeys: CodingKey {
        case screen
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let screen = try? container.decode(ScreenComponent.self, forKey: .screen) {
            self = .declarative(screen.toScreen())
        } else {
            let newPath: Route.NewPath = try .init(from: decoder)
            self = .remote(newPath.route, shouldPrefetch: newPath.shouldPrefetch, fallback: newPath.fallback)
        }
    }
}

extension Route.NewPath: Decodable {
    
    enum CodingKeys: CodingKey {
        case route
        case shouldPrefetch
        case fallback
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.route = try container.decode(String.self, forKey: .route)
        self.shouldPrefetch = try container.decodeIfPresent(Bool.self, forKey: .shouldPrefetch) ?? false
        self.fallback = try container.decodeIfPresent(ScreenComponent.self, forKey: .fallback)?.toScreen()
    }
}
