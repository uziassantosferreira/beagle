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

import XCTest
@testable import BeagleUI

final class FormLocalActionTests: XCTestCase {
    
    func test_mergeData_shouldPreferNewValues() {
        // Given
        let name = "test-action"
        let initialData = ["id": "123", "default": "old"]
        let inputs = ["default": "new", "name": "John"]
        let expectedData =  ["id": "123", "default": "new", "name": "John"]
        let sut = FormLocalAction(name: name, data: initialData)
        
        // When
        let merged = sut.merging(inputs)
        
        // Then
        XCTAssertEqual(merged.name, name)
        XCTAssertEqual(merged.data, expectedData)
    }
    
    func test_exec() {
        let formHandler = LocalFormHandling()
        let context = BeagleContextStub()
        context.dependencies = BeagleScreenDependencies(localFormHandler: formHandler)
        
        let resultAction = ActionSpy()
        formHandler["local-action"] = { context, action, listener in
            listener(.start)
            listener(.error(NSError.testError))
            listener(.success(action: resultAction))
        }
        let localAction = FormLocalAction(name: "local-action", data: [:])
        localAction.execute(context: context, sender: self)
        
        XCTAssertEqual(resultAction.executionCount, 1)
        XCTAssertEqual(context.screenStates.count, 3)
    }
}

class ActionSpy: Action {
    private(set) var executionCount = 0
    private(set) var lastContext: BeagleContext?
    private(set) var lastSender: Any?
    
    func execute(context: BeagleContext, sender: Any) {
        executionCount += 1
        lastContext = context
        lastSender = sender
    }
    
    init() {}
    required init(from decoder: Decoder) throws {}
}

extension NSError {
    static var testError: NSError {
        NSError(domain: "Testing", code: 1, description: "Error")
    }
}
