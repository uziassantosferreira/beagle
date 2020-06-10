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

package br.com.zup.beagle.android.data.serializer.adapter

import br.com.zup.beagle.android.components.layout.Screen
import br.com.zup.beagle.core.ServerDrivenComponent
import br.com.zup.beagle.android.data.serializer.PolymorphicJsonAdapterFactory
import br.com.zup.beagle.android.setup.BeagleEnvironment
import br.com.zup.beagle.widget.Widget
import br.com.zup.beagle.widget.form.Form
import br.com.zup.beagle.widget.form.FormInput
import br.com.zup.beagle.widget.form.FormInputHidden
import br.com.zup.beagle.widget.form.FormSubmit
import br.com.zup.beagle.widget.form.InputWidget
import br.com.zup.beagle.widget.pager.PageIndicatorComponent
import br.com.zup.beagle.android.widget.ui.UndefinedWidget
import java.util.*

private const val BEAGLE_WIDGET_TYPE = "_beagleComponent_"
private const val BEAGLE_NAMESPACE = "beagle"

internal object ComponentJsonAdapterFactory {

    fun make(): PolymorphicJsonAdapterFactory<ServerDrivenComponent> {
        var factory = PolymorphicJsonAdapterFactory.of(
            ServerDrivenComponent::class.java, BEAGLE_WIDGET_TYPE
        )

        factory = registerBaseSubTypes(factory)
        factory = registerLayoutClass(factory)
        factory = registerUIClass(factory)
        factory = registerCustomWidget(factory)
        factory = registerUndefinedWidget(factory)

        return factory
    }

    private fun registerBaseSubTypes(
        factory: PolymorphicJsonAdapterFactory<ServerDrivenComponent>
    ): PolymorphicJsonAdapterFactory<ServerDrivenComponent> {
        return factory.withBaseSubType(PageIndicatorComponent::class.java)
            .withBaseSubType(InputWidget::class.java)
            .withBaseSubType(Widget::class.java)
    }

    private fun registerLayoutClass(
        factory: PolymorphicJsonAdapterFactory<ServerDrivenComponent>
    ): PolymorphicJsonAdapterFactory<ServerDrivenComponent> {
        return factory.withSubtype(Screen::class.java, createNamespaceFor<Screen>())
            .withSubtype(br.com.zup.beagle.android.components.layout.Container::class.java,
                createNamespaceFor<br.com.zup.beagle.android.components.layout.Container>())
            .withSubtype(br.com.zup.beagle.android.components.layout.Vertical::class.java,
                createNamespaceFor<br.com.zup.beagle.android.components.layout.Vertical>())
            .withSubtype(br.com.zup.beagle.android.components.layout.Horizontal::class.java,
                createNamespaceFor<br.com.zup.beagle.android.components.layout.Horizontal>())
            .withSubtype(br.com.zup.beagle.android.components.layout.Stack::class.java,
                createNamespaceFor<br.com.zup.beagle.android.components.layout.Stack>())
            .withSubtype(br.com.zup.beagle.android.components.Spacer::class.java,
                createNamespaceFor<br.com.zup.beagle.android.components.Spacer>())
            .withSubtype(br.com.zup.beagle.android.components.layout.ScrollView::class.java,
                createNamespaceFor<br.com.zup.beagle.android.components.layout.ScrollView>())
            .withSubtype(br.com.zup.beagle.android.components.LazyComponent::class.java,
                createNamespaceFor<br.com.zup.beagle.android.components.LazyComponent>())
            .withSubtype(br.com.zup.beagle.android.components.PageView::class.java,
                createNamespaceFor<br.com.zup.beagle.android.components.PageView>())
            .withSubtype(Form::class.java, createNamespaceFor<Form>())
    }

    private fun registerUIClass(
        factory: PolymorphicJsonAdapterFactory<ServerDrivenComponent>
    ): PolymorphicJsonAdapterFactory<ServerDrivenComponent> {
        return factory.withSubtype(br.com.zup.beagle.android.components.Text::class.java,
            createNamespaceFor<br.com.zup.beagle.android.components.Text>())
            .withSubtype(br.com.zup.beagle.android.components.Image::class.java,
                createNamespaceFor<br.com.zup.beagle.android.components.Image>())
            .withSubtype(br.com.zup.beagle.android.components.NetworkImage::class.java,
                createNamespaceFor<br.com.zup.beagle.android.components.NetworkImage>())
            .withSubtype(br.com.zup.beagle.android.components.Button::class.java,
                createNamespaceFor<br.com.zup.beagle.android.components.Button>())
            .withSubtype(br.com.zup.beagle.android.components.ListView::class.java,
                createNamespaceFor<br.com.zup.beagle.android.components.ListView>())
            .withSubtype(br.com.zup.beagle.android.components.TabView::class.java,
                createNamespaceFor<br.com.zup.beagle.android.components.TabView>())
            .withSubtype(br.com.zup.beagle.android.components.TabItem::class.java,
                createNamespaceFor<br.com.zup.beagle.android.components.TabItem>())
            .withSubtype(br.com.zup.beagle.android.components.WebView::class.java,
                createNamespaceFor<br.com.zup.beagle.android.components.WebView>())
            .withSubtype(br.com.zup.beagle.android.components.Touchable::class.java,
                createNamespaceFor<br.com.zup.beagle.android.components.Touchable>())
            .withSubtype(br.com.zup.beagle.android.components.PageIndicator::class.java,
                createNamespaceFor<br.com.zup.beagle.android.components.PageIndicator>())
            .withSubtype(FormInput::class.java, createNamespaceFor<FormInput>())
            .withSubtype(FormInputHidden::class.java, createNamespaceFor<FormInputHidden>())
            .withSubtype(FormSubmit::class.java, createNamespaceFor<FormSubmit>())
            .withSubtype(UndefinedWidget::class.java, createNamespaceFor<UndefinedWidget>())
    }

    private fun registerCustomWidget(
        factory: PolymorphicJsonAdapterFactory<ServerDrivenComponent>
    ): PolymorphicJsonAdapterFactory<ServerDrivenComponent> {
        val appName = "custom"
        val widgets = BeagleEnvironment.beagleSdk.registeredWidgets()

        var newFactory = factory

        widgets.forEach {
            newFactory = newFactory.withSubtype(it, createNamespace(appName, it))
        }

        return newFactory
    }

    private fun registerUndefinedWidget(
        factory: PolymorphicJsonAdapterFactory<ServerDrivenComponent>
    ): PolymorphicJsonAdapterFactory<ServerDrivenComponent> {
        return factory.withDefaultValue(UndefinedWidget())
    }

    private inline fun <reified T : ServerDrivenComponent> createNamespaceFor(): String {
        return createNamespace(BEAGLE_NAMESPACE, T::class.java)
    }

    private fun createNamespace(appNamespace: String, clazz: Class<*>): String {
        return "$appNamespace:${clazz.simpleName.toLowerCase(Locale.getDefault())}"
    }
}