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

package br.com.zup.beagle.android.components.layout

import android.content.Context
import android.view.View
import br.com.zup.beagle.analytics.ScreenEvent
import br.com.zup.beagle.android.setup.BeagleEnvironment
import br.com.zup.beagle.android.utils.ToolbarManager
import br.com.zup.beagle.android.utils.configureSupportActionBar
import br.com.zup.beagle.android.view.BeagleActivity
import br.com.zup.beagle.android.view.ViewFactory
import br.com.zup.beagle.android.widget.core.ViewConvertable
import br.com.zup.beagle.core.Appearance
import br.com.zup.beagle.core.ServerDrivenComponent
import br.com.zup.beagle.widget.core.Flex
import br.com.zup.beagle.widget.layout.NavigationBar
import br.com.zup.beagle.widget.layout.SafeArea
import br.com.zup.beagle.widget.layout.Screen

data class Screen(
    override var id: String? = null,
    override val safeArea: SafeArea? = null,
    override val navigationBar: NavigationBar? = null,
    override val child: ServerDrivenComponent,
    override var appearance: Appearance? = null,
    override val screenAnalyticsEvent: ScreenEvent? = null
) : Screen(id, safeArea, navigationBar, child, appearance, screenAnalyticsEvent), ViewConvertable {


    private val viewFactory: ViewFactory = ViewFactory()
    private val toolbarManager: ToolbarManager = ToolbarManager()

    override fun buildView(context: Context): View {
        addNavigationBarIfNecessary(context, navigationBar)

        val container = viewFactory.makeBeagleFlexView(context, Flex(grow = 1.0))

//        container.addServerDrivenComponent(child, rootView)

        screenAnalyticsEvent?.let {
            container.addOnAttachStateChangeListener(object : View.OnAttachStateChangeListener {
                override fun onViewAttachedToWindow(v: View?) {
                    BeagleEnvironment.beagleSdk.analytics?.sendViewWillAppearEvent(it)
                }

                override fun onViewDetachedFromWindow(v: View?) {
                    BeagleEnvironment.beagleSdk.analytics?.sendViewWillDisappearEvent(it)
                }
            })
        }

        return container
    }


    private fun addNavigationBarIfNecessary(context: Context, navigationBar: NavigationBar?) {
        if (context is BeagleActivity) {
            if (navigationBar != null) {
                configNavigationBar(context, navigationBar)
            } else {
                hideNavigationBar(context)
            }
        }
    }

    private fun hideNavigationBar(context: BeagleActivity) {
        context.supportActionBar?.apply {
            hide()
        }

        context.getToolbar().visibility = View.GONE
    }

    private fun configNavigationBar(
        context: BeagleActivity,
        navigationBar: NavigationBar
    ) {
        context.configureSupportActionBar()
        toolbarManager.configureNavigationBarForScreen(context, navigationBar)
        toolbarManager.configureToolbar(context, navigationBar)
    }
}