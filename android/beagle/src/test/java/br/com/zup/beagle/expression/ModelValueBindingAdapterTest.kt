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

package br.com.zup.beagle.expression

import br.com.zup.beagle.BaseTest
import br.com.zup.beagle.expression.cache.CacheProvider
import br.com.zup.beagle.expression.config.BindingSetup
import br.com.zup.beagle.testutil.CoroutineTestRule
import br.com.zup.beagle.widget.layout.Container
import br.com.zup.beagle.widget.navigation.Touchable
import io.mockk.every
import io.mockk.impl.annotations.InjectMockKs
import io.mockk.impl.annotations.RelaxedMockK
import io.mockk.mockk
import io.mockk.mockkObject
import io.mockk.unmockkObject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.TestCoroutineDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.setMain
import org.junit.After
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import kotlin.test.assertEquals

@ExperimentalCoroutinesApi
class ModelValueBindingAdapterTest : BaseTest() {
    private var currentText = ""

    @InjectMockKs
    private lateinit var modelValueBindingAdapter: ModelValueBindingAdapter

    @RelaxedMockK
    private lateinit var value: Value

    private val dataBindingComponent: WidgetBindingSampleTest = WidgetBindingSampleTest(
        intValue = BindingExpr(expression = "@{b}", initialValue = 0),
        stringValue = BindingExpr("@{a}", initialValue = "loading...")
    )

    @RelaxedMockK
    private lateinit var container: Container

    @RelaxedMockK
    private lateinit var touchable: Touchable

    private val modelJson = """
        {
  "a" : "Beagle 2",
  "b" : 2
}
"""

    @get:Rule
    val scope = CoroutineTestRule()

    private val bindingConfig = mockk<BindingSetup.BindingConfig>(relaxed = true)

    private val cacheProvider = mockk<CacheProvider<String, Binding>>(relaxed = true)

    @Before
    override fun setUp() {
        super.setUp()
        Dispatchers.setMain(TestCoroutineDispatcher())
        every { cacheProvider.get(any()) } returns null
        every { bindingConfig.cacheProvider } returns cacheProvider
        mockkObject(BindingSetup)
        every { BindingSetup.bindingConfig } returns bindingConfig
        BindingSetup.bindingConfig = BindingSetup.bindingConfig
        every { container.children } returns listOf(touchable)
        every { touchable.child } returns dataBindingComponent
        dataBindingComponent.modelJson = modelJson
        dataBindingComponent.apply {
            intValue.observes { value ->
                currentText = formatString(currentText, valorInt = value)
            }

            stringValue.observes { value ->
                currentText = formatString(currentText, nome = value)
            }
        }
        currentText = ""
    }

    @After
    override fun tearDown() {
        super.tearDown()
        Dispatchers.resetMain()
        unmockkObject(BindingSetup)
    }

    @Test
    fun should_evaluateBinding_with_value_for_success() {
        every { container.modelJson } returns modelJson
        modelValueBindingAdapter.evaluateBinding(container)

        assertEquals("2 - Beagle 2", currentText)
    }

    @Test
    fun should_evaluateInitialValue_with_value_for_success() {
        dataBindingComponent.modelJson = modelJson
        modelValueBindingAdapter.evaluateInitialValue(dataBindingComponent)

        assertEquals("0 - loading...", currentText)
    }

    private fun formatString(
        currentValue: CharSequence, valorInt: Int = -1,
        nome: String = ""
    ): String {
        var valorIntOld = ""
        var nomeOld = ""
        if (currentValue.isEmpty()) {
            return "$valorInt - $nome"
        }
        if (valorInt != -1 || nome.isNotEmpty()) {
            val values = currentValue.split(" - ")
            valorIntOld = values.first()
            nomeOld = values.last()

            if (valorInt != -1) {
                valorIntOld = valorInt.toString()
            }

            if (nome.isNotEmpty()) {
                nomeOld = nome
            }

        }

        return "$valorIntOld - $nomeOld"
    }
}