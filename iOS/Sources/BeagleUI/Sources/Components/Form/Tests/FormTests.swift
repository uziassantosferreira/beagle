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
import SnapshotTesting
@testable import BeagleUI

final class FormTests: XCTestCase {

    func test_whenDecodingJson_thenItShouldReturnAForm() throws {
        let component: Form = try componentFromJsonFile(fileName: "formComponent")
        assertSnapshot(matching: component, as: .dump)
    }
    
    func test_whenSubmitFormRemoteAction_itShouldSubmitTheRequest() {
        let remoteAction = FormRemoteAction(path: "remote-form", method: .post)
        let form = simpleForm(action: remoteAction)
        let resultAction = ActionSpy()
        let context = BeagleContextStub()
        context.dependencies = BeagleScreenDependencies(
            repository: RepositoryStub(formResult: .success(resultAction))
        )
        
        let view = form.toView(context: context, dependencies: context.dependencies)
        triggerFormSubmit(in: view, controller: context.screenController)
        
        XCTAssertEqual(resultAction.executionCount, 1)
        XCTAssertTrue(resultAction.lastContext === context)
    }
    
    func test_whenSubmitFormLocalAction_itShouldSubmitTheRequest() {
        let actionName = "form-test"
        let localAction = FormLocalAction(name: actionName, data: [:])
        let form = simpleForm(action: localAction)
        let formHandler = LocalFormHandling()
        let context = BeagleContextStub()
        context.dependencies = BeagleScreenDependencies(
            localFormHandler: formHandler
        )
        
        var resultAction: FormLocalAction?
        formHandler[actionName] = { _, action, _ in
            resultAction = action
        }
        let view = form.toView(context: context, dependencies: context.dependencies)
        triggerFormSubmit(in: view, controller: context.screenController)
        
        XCTAssertEqual(resultAction?.name, actionName)
        XCTAssertEqual(resultAction?.data, ["id": "42"])
    }
    
    func test_SubmitCustomAction() {
        let action = ActionSpy()
        let form = Form(action: action, child: Container(children: [
            FormSubmit(child: Text("Submit"))
        ]))
        let context = BeagleContextDummy()
        
        let view = form.toView(context: context, dependencies: context.dependencies)
        triggerFormSubmit(in: view, controller: context.screenController)
        
        XCTAssertEqual(action.executionCount, 1)
    }
    
    func test_whenSomeInputValidatorIsNotFound_itShouldNotExecuteTheAction() {
        let action = ActionSpy()
        let form = Form(action: action, child: Container(children: [
            FormInput(
                name: "input",
                required: true,
                validator: "unknown-validator",
                child: InputStub()
            ),
            FormSubmit(child: Text("Submit"))
        ]))
        let context = BeagleContextDummy()
        
        let view = form.toView(context: context, dependencies: context.dependencies)
        triggerFormSubmit(in: view, controller: context.screenController)
        
        XCTAssertEqual(action.executionCount, 0)
    }
    
    func test_whenValidateInputs_itShouldNotifyErrors() {
        let action = ActionSpy()
        let form = Form(
            action: action,
            child: Container(children: [
                requiredInput(name: "A", value: "valid", message: "error A"),
                requiredInput(name: "B", value: "12345", message: "error B"),
                requiredInput(name: "C", value: "abcde", message: "error C"),
                FormSubmit(child: Button(text: "Submit"))
            ])
        )
        let validatorProvider = ValidatorProviding()
        let context = BeagleContextStub()
        context.dependencies = BeagleScreenDependencies(
            validatorProvider: validatorProvider
        )
        
        validatorProvider["test-validator"] = { value in
            (value as? String) == "valid"
        }
        let view = form.toView(context: context, dependencies: context.dependencies)
        triggerFormSubmit(in: view, controller: context.screenController)
        
        let errorMessages = view.allSubviews.compactMap { subview in
            (subview as? InputStubView)?.errorMessage
        }
        
        XCTAssertEqual(action.executionCount, 0)
        XCTAssertEqual(errorMessages, ["error B", "error C"])
    }
    
    private func triggerFormSubmit(in view: UIView, controller: UIViewController) {
        view.gestureRecognizers?
            .compactMap { $0 as? SubmitFormGestureRecognizer }
            .forEach { submitGesture in
                submitGesture.state = .ended
                controller.handleSubmitFormGesture(submitGesture)
            }
        view.subviews.forEach { subview in
            triggerFormSubmit(in: subview, controller: controller)
        }
    }
    
    private func simpleForm(action: Action) -> Form {
        return Form(
            action: action,
            child: Container(children: [
                FormInput(name: "id", child: InputStub(value: "42")),
                FormSubmit(child: Text("Submit"))
            ])
        )
    }
    
    private func requiredInput(name: String, value: String, message: String) -> FormInput {
        return FormInput(
            name: name,
            required: true,
            validator: "test-validator",
            errorMessage: message,
            child: InputStub(value: value)
        )
    }
}

// MARK: - Stubs

private struct InputStub: ServerDrivenComponent {
    var value: String = ""

    func toView(context: BeagleContext, dependencies: RenderableDependencies) -> UIView {
        return InputStubView(value: value)
    }
}

private class InputStubView: UIView, InputValue, ValidationErrorListener {

    let value: String
    private(set) var errorMessage: String?

    init(value: String = "") {
        self.value = value
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        BeagleUI.fatalError("init(coder:) has not been implemented")
    }

    func getValue() -> Any {
        return value
    }

    func onValidationError(message: String?) {
        errorMessage = message
    }
}
