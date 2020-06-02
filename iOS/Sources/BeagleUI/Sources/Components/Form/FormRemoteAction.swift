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

public struct FormRemoteAction: Action, AutoInitiable {
    public let path: String
    public let method: Method

    public enum Method: String, Decodable, CaseIterable {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }

// sourcery:inline:auto:FormRemoteAction.Init
    public init(
        path: String,
        method: Method
    ) {
        self.path = path
        self.method = method
    }
// sourcery:end
    
    public func execute(context: BeagleContext, sender: Any) {
        execute(context: context, inputs: [:], sender: sender)
    }
    
    func execute(context: BeagleContext, inputs: [String: String], sender: Any) {
        context.screenState = .loading
        
        let data = Request.FormData(
            method: method,
            values: inputs
        )
        
        context.dependencies.repository.submitForm(url: path, additionalData: nil, data: data) {
            [weak context] result in guard let context = context else { return }
            switch result {
            case .success(let action):
                context.screenState = .success
                action.execute(context: context, sender: sender)
            case .failure(let error):
                context.screenState = .failure(.submitForm(error))
            }
        }
        context.dependencies.logger.log(Log.form(.submittedValues(values: inputs)))
    }
}
