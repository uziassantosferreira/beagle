@file:Suppress("TooManyFunctions", "LongParameterList")

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

package br.com.zup.beagle.widget.core

class FlexBuilder {
    private var positionType: FlexPositionType? = null
    private var flexDirection: FlexDirection? = null
    private var display: FlexDisplay? = null
    private var flexWrap: FlexWrap? = null
    private var shrink: Double? = null
    private var grow: Double? = null
    private var flex: Double? = null
    private var alignSelf: AlignSelf? = null
    private var alignItems: AlignItems? = null
    private var alignContent: AlignContent? = null
    private var justifyContent: JustifyContent? = null
    private var basis: UnitValue? = null

    fun build() = Flex(
        positionType = this.positionType,
        shrink = this.shrink,
        justifyContent = this.justifyContent,
        grow = this.grow,
        flexWrap = this.flexWrap,
        flexDirection = this.flexDirection,
        flex = this.flex,
        display = this.display,
        basis = this.basis,
        alignSelf = this.alignSelf,
        alignItems = this.alignItems,
        alignContent = this.alignContent
    )

    fun alignContent(type: AlignContent) = this.apply { this.alignContent = type }

    fun alignItems(type: AlignItems) = this.apply { this.alignItems = type }

    fun alignSelf(type: AlignSelf) = this.apply { this.alignSelf = type }

    fun display(type: FlexDisplay) = this.apply { this.display = type }

    fun flex(value: Double) = this.apply { this.flex = value }

    fun flexDirection(type: FlexDirection) = this.apply { this.flexDirection = type }

    fun flexWrap(type: FlexWrap) = this.apply { this.flexWrap = type }

    fun grow(value: Double) = this.apply { this.grow = value }

    fun justifyContent(type: JustifyContent) = this.apply { this.justifyContent = type }

    fun shrink(value: Double) = this.apply { this.shrink = value }

    fun positionType(type: FlexPositionType? = null) = this.apply { this.positionType = type }

    fun basis(value: UnitValue) = this.apply { this.basis = value }
    
}
