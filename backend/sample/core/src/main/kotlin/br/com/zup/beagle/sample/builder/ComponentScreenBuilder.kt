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

package br.com.zup.beagle.sample.builder

import br.com.zup.beagle.annotation.RegisterWidget
import br.com.zup.beagle.core.Bind
import br.com.zup.beagle.core.ContextData
import br.com.zup.beagle.core.DynamicObject
import br.com.zup.beagle.ext.applyFlex
import br.com.zup.beagle.ext.unitReal
import br.com.zup.beagle.sample.constants.BUTTON_STYLE_TITLE
import br.com.zup.beagle.widget.Widget
import br.com.zup.beagle.widget.action.Navigate
import br.com.zup.beagle.widget.action.Route
import br.com.zup.beagle.widget.core.EdgeValue
import br.com.zup.beagle.widget.core.Flex
import br.com.zup.beagle.widget.layout.Container
import br.com.zup.beagle.widget.layout.NavigationBar
import br.com.zup.beagle.widget.layout.Screen
import br.com.zup.beagle.widget.layout.ScreenBuilder
import br.com.zup.beagle.widget.ui.Button

object ComponentScreenBuilder : ScreenBuilder {
    override fun build() = Screen(
        navigationBar = NavigationBar(
            title = "Choose a Component",
            showBackButton = true
        ),
        child = Container(
            children = emptyList(),
            context = ContextData(id = "test", value = listOf(
                DynamicObject.Int(30),
                null,
                20.0,
                "Lorem Ipsum",
                Bind.Expression<TestExpression>("@{person.name}"),
                true,
                mapOf("one" to DynamicObject.String("value"), "two" to false, "three" to 10)
            ))
        )
    )

    private fun createMenu(text: String, path: String) = Button(
        text = text,
        onPress = listOf(Navigate.PushView(Route.Remote(path))
        ),
        styleId = BUTTON_STYLE_TITLE
    ).applyFlex(
        flex = Flex(
            margin = EdgeValue(
                top = 8.unitReal()
            )
        )
    )
}

data class Person(
    val name: String,
    val age: Int
)

@RegisterWidget
data class TestExpression(
    val person: Person
) : Widget()