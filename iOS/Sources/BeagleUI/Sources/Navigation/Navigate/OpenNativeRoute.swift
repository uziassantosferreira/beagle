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

extension Navigate {
    func executeOpenNativeRoute(
        _ route: String,
        data: [String: String]?,
        resetApplication: Bool,
        context: BeagleContext,
        animated: Bool
    ) {
        do {
            guard let deepLinkHandler = context.dependencies.deepLinkHandler else { return }
            let viewController = try deepLinkHandler.getNativeScreen(with: route, data: data)

            if resetApplication {
                context.dependencies.windowManager.window?.replace(
                    rootViewController: viewController,
                    animated: true,
                    completion: nil
                )
            } else {
                context.screenController.navigationController?
                    .pushViewController(viewController, animated: animated)
            }
        } catch {
            context.dependencies.logger
                .log(Log.navigation(.didNotFindDeepLinkScreen(path: route)))
        }
    }
}
