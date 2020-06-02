//
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

import UIKit

extension Navigate {
    func executePopToView(identifier: String, context: BeagleContext, animated: Bool) {
        let navigation = context.screenController.navigationController
        guard let viewControllers = navigation?.viewControllers else {
            assertionFailure("Trying to pop when there is nothing to pop"); return
        }
        let target = viewControllers.last {
            let screen = $0 as? BeagleScreenViewController
            return screen?.isIdentifiable(by: identifier) ?? false
        }
        
        guard let targetController = target else {
            context.dependencies.logger.log(Log.navigation(
                .cantPopToAlreadyCurrentScreen(identifier: identifier)
            ))
            return
        }
        navigation?.popToViewController(targetController, animated: animated)
    }
}

extension BeagleScreenViewController {
    fileprivate func isIdentifiable(by identifier: String) -> Bool {
        switch screenType {
        case .remote(let remote):
            return absoluteURL(for: remote.url) == absoluteURL(for: identifier)
        case .declarative(let screen):
            return screen.identifier == identifier
        case .declarativeText:
            return screen?.identifier == identifier
        }
    }
    
    private func absoluteURL(for url: String) -> String? {
        return dependencies.urlBuilder.build(path: url)?.absoluteString
    }
}
