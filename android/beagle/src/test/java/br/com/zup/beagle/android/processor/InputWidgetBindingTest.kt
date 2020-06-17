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

package br.com.zup.beagle.android.processor

// TODO After refactor annotation, remove comment

/*
class InputWidgetBindingTest {
    @InjectMockKs
    lateinit var widgetBinding: CustomInputWidgetBinding

    val text: Bind<String> = mockk<Bind.Expression<String>>(relaxed = true)

    @RelaxedMockK
    lateinit var view: View

    @RelaxedMockK
    lateinit var rootView: RootView

    @RelaxedMockK
    lateinit var widget: CustomInputWidget

    @Before
    fun setUp() {
        MockKAnnotations.init(this)

        widgetBinding.setPrivateField(WIDGET_INSTANCE_PROPERTY, widget)
        widgetBinding.setPrivateField(VIEW_PROPERTY, view)
    }

    fun after() {
        unmockkAll()
    }

    @Test
    fun widget_should_be_instance_of_BindingAdapter() {
        assertTrue(widgetBinding is BindingAdapter)
        assertTrue(widgetBinding is WidgetView)
    }

    @Test
    fun widget_should_have_1_elements_in_list() {
        val expectedSize = 1
        assertEquals(expectedSize, widgetBinding.getBindAttributes().size)
    }

    @Test
    fun widget_should_call_on_bind_at_least_once() {

        //when
        widgetBinding.buildView(rootView)

        //then
        verify(atLeast = once()) { widget.onBind(any(), any()) }
    }

    @Test
    fun widget_should_call_observe_on_parameters() {

        //when
        widgetBinding.buildView(rootView)

        //then
        verify(atLeast = once()) { widgetBinding.text.observes(any()) }
    }

    @Test
    fun widget_should_call_on_get_value() {
        // Given When
        widgetBinding.widgetInstance.getValue()

        //then
        verify(exactly = once()) { widget.getValue() }
    }

    @Test
    fun widget_should_call_on_error_message() {
        // Given
        val message = RandomData.string()

        //when
        widgetBinding.widgetInstance.onErrorMessage(message)

        //then
        verify(exactly = once()) { widget.onErrorMessage(message) }
    }
}

 */
