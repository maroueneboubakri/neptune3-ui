/****************************************************************************
**
** Copyright (C) 2019 Luxoft Sweden AB
** Copyright (C) 2018 Pelagicore AG
** Contact: https://www.qt.io/licensing/
**
** This file is part of the Neptune 3 IVI UI.
**
** $QT_BEGIN_LICENSE:GPL-QTAS$
** Commercial License Usage
** Licensees holding valid commercial Qt Automotive Suite licenses may use
** this file in accordance with the commercial license agreement provided
** with the Software or, alternatively, in accordance with the terms
** contained in a written agreement between you and The Qt Company.  For
** licensing terms and conditions see https://www.qt.io/terms-conditions.
** For further information use the contact form at https://www.qt.io/contact-us.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3 or (at your option) any later version
** approved by the KDE Free Qt Foundation. The licenses are as published by
** the Free Software Foundation and appearing in the file LICENSE.GPL3
** included in the packaging of this file. Please review the following
** information to ensure the GNU General Public License requirements will
** be met: https://www.gnu.org/licenses/gpl-3.0.html.
**
** $QT_END_LICENSE$
**
** SPDX-License-Identifier: GPL-3.0
**
****************************************************************************/

import QtQuick 2.10
import QtQuick.Controls 2.3

import shared.utils 1.0
import shared.Sizes 1.0

/*!
    \qmltype
    \inqmlmodule controls
    \inherits ListItemBasic
    \since 5.11
    \brief Flat button for list items and lists and notifications.

    ListItemFlatButton provides a type of a list item with a flat button and close button
    on the right side. The flat button supports text on one line and its width is aligned with
    text width. The visibility of close button can be defined with closeButtonVisible property.

    See \l{Neptune 3 UI Components and Interfaces} to see more available components in
    Neptune 3 UI.

    \section2 Example Usage

    The following example uses \l{ListItemBasic }:

    \qml
    import QtQuick 2.10
    import shared.controls 1.0

    Item {
        id: root
        ListView {
            model: 3
            delegate:  ListItemFlatButton {
                implicitWidth: Sizes.dp(765)
                implicitHeight: Sizes.dp(104)
                icon.name: "ic-update"
                symbolFlatButton: Style.image("ic-favorite")
                subText: "subtitle"
                text: "ListItem with button text"
                textFlatButton: "Text"
                closeButtonVisible: true
            }
        }
    }

    \endqml

 */

ListItemBasic {
    id: root

    /*!
        \qmlproperty string ListItemBasic::textFlatButton

        This property holds a flat button text.
    */
    property string textFlatButton: ""

    /*!
        \qmlproperty string ListItemBasic::symbolFlatButton

        This property holds a flat button icon path.
    */
    property string symbolFlatButton: ""

    /*!
        \qmlproperty string ListItemBasic::closeButtonVisible

        This property holds a visibility of close button. The default value is false.
    */
    property bool closeButtonVisible: false

    /*!
        \qmlsignal ListItemBasic::flatButtonClicked()

        The signal is emitted when flat button is clicked
    */
    signal flatButtonClicked()

    /*!
        \qmlsignal ListItemBasic::closeButtonClicked()

        The signal is emitted when close button is clicked
    */
    signal closeButtonClicked()


    accessoryDelegateComponent1: Button {
        implicitHeight: contentItem.implicitHeight + topPadding + bottomPadding
        implicitWidth: contentItem.implicitWidth + leftPadding + rightPadding
        leftPadding: Sizes.dp(30)
        rightPadding: Sizes.dp(30)
        topPadding: Sizes.dp(8)
        bottomPadding: Sizes.dp(8)
        text: root.textFlatButton
        font.pixelSize: Sizes.fontSizeS
        icon.source: root.symbolFlatButton
        visible: text !== "" || icon.source != ""
        onClicked: root.flatButtonClicked()
    }

    accessoryDelegateComponent2: ToolButton {
        implicitWidth: visible ? Sizes.dp(100) : 0
        implicitHeight: visible ? root.height : 0
        icon.name: "ic-close"
        visible: root.closeButtonVisible
        onClicked: root.closeButtonClicked()
    }
}
