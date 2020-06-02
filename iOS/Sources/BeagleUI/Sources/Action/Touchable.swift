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

public struct Touchable: ServerDrivenComponent, ClickedOnComponent, AutoInitiableAndDecodable {
    // MARK: - Public Properties
    public let action: Action
    public let clickAnalyticsEvent: AnalyticsClick?
    public let child: ServerDrivenComponent

// sourcery:inline:auto:Touchable.Init
    public init(
        action: Action,
        clickAnalyticsEvent: AnalyticsClick? = nil,
        child: ServerDrivenComponent
    ) {
        self.action = action
        self.clickAnalyticsEvent = clickAnalyticsEvent
        self.child = child
    }
// sourcery:end
}

extension Touchable: Renderable {
    public func toView(context: BeagleContext, dependencies: RenderableDependencies) -> UIView {
        let childView = child.toView(context: context, dependencies: dependencies)
        var events: [Event] = [.action(action)]
        if let clickAnalyticsEvent = clickAnalyticsEvent {
            events.append(.analytics(clickAnalyticsEvent))
        }
        
        context.screenController.register(events: events, in: childView, context: context)
        prefetchComponent(context: context, dependencies: dependencies)
        return childView
    }
    
    private func prefetchComponent(context: BeagleContext, dependencies: RenderableDependencies) {
        guard let newPath = (action as? Navigate)?.newPath else { return }
        dependencies.preFetchHelper.prefetchComponent(newPath: newPath)
    }
}

extension UIViewController {
    
    fileprivate func register(events: [Event], in view: UIView, context: BeagleContext) {
        let eventsGestureRecognizer = EventsGestureRecognizer(
            events: events,
            context: context,
            target: self,
            selector: #selector(handleEvents(_:))
        )
        view.addGestureRecognizer(eventsGestureRecognizer)
        view.isUserInteractionEnabled = true
    }

    @objc func handleEvents(_ sender: EventsGestureRecognizer) {
        guard let context = sender.context else { return }
        sender.events.forEach {
            switch $0 {
            case .action(let action):
                action.execute(context: context, sender: sender.view as Any)

            case .analytics(let analyticsClick):
                context.dependencies.analytics?.trackEventOnClick(analyticsClick)
            }
        }
    }
}

final class EventsGestureRecognizer: UITapGestureRecognizer {
    let events: [Event]
    weak var context: BeagleContext?
    
    init(events: [Event], context: BeagleContext, target: Any?, selector: Selector?) {
        self.events = events
        self.context = context
        super.init(target: target, action: selector)
    }
}
