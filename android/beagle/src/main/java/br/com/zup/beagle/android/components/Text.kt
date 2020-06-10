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

package br.com.zup.beagle.android.components

import android.content.Context
import android.view.Gravity
import android.view.View
import androidx.appcompat.widget.AppCompatTextView
import androidx.core.widget.TextViewCompat
import br.com.zup.beagle.android.setup.BeagleEnvironment
import br.com.zup.beagle.android.utils.toAndroidColor
import br.com.zup.beagle.android.widget.core.ViewConvertable
import br.com.zup.beagle.widget.ui.Text
import br.com.zup.beagle.widget.ui.TextAlignment

data class Text(override val text: String,
                override val style: String? = null,
                override val textColor: String? = null,
                override val alignment: TextAlignment? = null)
    : br.com.zup.beagle.widget.ui.Text(text, style, textColor, alignment), ViewConvertable {


    override fun buildView(context: Context): View {
        val textView = AppCompatTextView(context)
        textView.setTextWidget(this)
        return textView
    }


    private fun AppCompatTextView.setTextWidget(text: Text) {
        this.text = text.text
        this.setStyle(text.style ?: "")
        this.setTextColor(text.textColor)
        this.setAlignment(text.alignment)
    }

    private fun AppCompatTextView.setAlignment(alignment: TextAlignment?) {
        when (alignment) {
            TextAlignment.CENTER -> this.gravity = Gravity.CENTER
            TextAlignment.RIGHT -> this.gravity = Gravity.END
            else -> this.gravity = Gravity.START
        }
    }

    private fun AppCompatTextView.setStyle(style: String) {
        val designSystem = BeagleEnvironment.beagleSdk.designSystem
        designSystem?.textAppearance(style)?.let {
            TextViewCompat.setTextAppearance(this, it)
        }
    }

    private fun AppCompatTextView.setTextColor(color: String?) {
        color?.let {
            this.setTextColor(color.toAndroidColor())
        }
    }
}