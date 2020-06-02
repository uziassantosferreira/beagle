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

public struct Form: ServerDrivenComponent, AutoInitiableAndDecodable {
    
    // MARK: - Public Properties

    public let action: Action
    public let child: ServerDrivenComponent

// sourcery:inline:auto:Form.Init
    public init(
        action: Action,
        child: ServerDrivenComponent
    ) {
        self.action = action
        self.child = child
    }
// sourcery:end
}

extension Form: Renderable {
    public func toView(context: BeagleContext, dependencies: RenderableDependencies) -> UIView {
        let childView = child.toView(context: context, dependencies: dependencies)
        var hasFormSubmit = false
        
        func registerFormSubmit(view: UIView) {
            if view.beagleFormElement is FormSubmit {
                hasFormSubmit = true
                context.screenController.register(
                    form: self,
                    formView: childView,
                    submitView: view,
                    context: context
                )
            }
            for subview in view.subviews {
                registerFormSubmit(view: subview)
            }
        }
        
        registerFormSubmit(view: childView)
        if !hasFormSubmit {
            dependencies.logger.log(Log.form(.submitNotFound(form: self)))
        }
        return childView
    }
}

extension UIViewController {
    
    fileprivate func register(
        form: Form,
        formView: UIView,
        submitView: UIView,
        context: BeagleContext
    ) {
        let gestureRecognizer = SubmitFormGestureRecognizer(
            form: form,
            formView: formView,
            formSubmitView: submitView,
            context: context,
            target: self,
            action: #selector(handleSubmitFormGesture(_:))
        )
        if let control = submitView as? UIControl,
           let formSubmit = submitView.beagleFormElement as? FormSubmit,
           let enabled = formSubmit.enabled {
            control.isEnabled = enabled
        }

        submitView.addGestureRecognizer(gestureRecognizer)
        submitView.isUserInteractionEnabled = true
        gestureRecognizer.updateSubmitView()
    }

    @objc func handleSubmitFormGesture(_ sender: SubmitFormGestureRecognizer) {
        guard let context = sender.context else { return }
        let isSubmitEnabled = (sender.formSubmitView as? UIControl)?.isEnabled ?? true
        guard isSubmitEnabled && sender.state == .ended else { return }

        let inputViews = sender.formInputViews()
        if inputViews.isEmpty {
            context.dependencies.logger.log(
                Log.form(.inputsNotFound(form: sender.form))
            )
        }
        let values = inputViews.reduce(into: [:]) { result, inputView in
            self.validate(
                formInput: inputView,
                formSubmit: sender.formSubmitView,
                context: context,
                result: &result
            )
        }
        guard inputViews.count == values.count else {
            context.dependencies.logger.log(
                Log.form(.divergentInputViewAndValueCount(form: sender.form))
            )
            return
        }

        submitAction(sender.form.action, inputs: values, sender: sender, context: context)
    }
    
    private func submitAction(
        _ action: Action,
        inputs: [String: String],
        sender: Any,
        context: BeagleContext
    ) {
        switch action {
        case let action as FormRemoteAction:
            action.execute(context: context, inputs: inputs, sender: sender)
            
        case let action as FormLocalAction:
            action.merging(inputs).execute(context: context, sender: sender)
            
        default:
            action.execute(context: context, sender: sender)
        }
    }

    private func validate(
        formInput view: UIView,
        formSubmit submitView: UIView?,
        context: BeagleContext,
        result: inout [String: String]
    ) {
        guard
            let formInput = view.beagleFormElement as? FormInputComponent,
            let inputValue = view as? InputValue
        else { return }

        if let defaultFormInput = formInput as? FormInput, defaultFormInput.required ?? false {
            guard
                let validatorName = defaultFormInput.validator,
                let handler = context.dependencies.validatorProvider,
                let validator = handler.getValidator(name: validatorName) else {
                    if let validatorName = defaultFormInput.validator {
                        context.dependencies.logger.log(
                            Log.form(.validatorNotFound(named: validatorName))
                        )
                    }
                    return
            }
            let value = inputValue.getValue()
            let isValid = validator.isValid(input: value)

            if isValid {
                result[formInput.name] = String(describing: value)
            } else {
                if let errorListener = inputValue as? ValidationErrorListener {
                    errorListener.onValidationError(message: defaultFormInput.errorMessage)
                }
                context.dependencies.logger.log(
                    Log.form(.validationInputNotValid(inputName: defaultFormInput.name))
                )
            }
        } else {
            result[formInput.name] = String(describing: inputValue.getValue())
        }
    }
    
}

extension UIView {
    private struct AssociatedKeys {
        static var FormElement = "beagleUI_FormElement"
    }
    
    private class ObjectWrapper<T> {
        let object: T?
        
        init(_ object: T?) {
            self.object = object
        }
    }
    
    var beagleFormElement: ServerDrivenComponent? {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.FormElement) as? ObjectWrapper)?.object
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.FormElement, ObjectWrapper(newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
