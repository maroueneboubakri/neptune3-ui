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

import shared.Style 1.0
import shared.Sizes 1.0

Item {
    id: root
    width: parent.width
    height: complexItem.item ? complexItem.item.height : titleAndSubtitle.childrenRect.height

    property string title: ""
    property string subtitle: ""
    property alias complexContent: complexItem.sourceComponent

    Item {
        id: titleAndSubtitle
        height: root.subtitle !== "" ? Sizes.dp(96) + subTitle.lineCount * Sizes.dp(16) : Sizes.dp(96)
        visible: title !== "" || subtitle !== ""
        width: root.width

        Column {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: Sizes.dp(24)
            anchors.right: parent.right
            anchors.rightMargin: Sizes.dp(24)

            Label {
                id: title
                text: root.title
            }

            Label {
                id: subTitle
                font.pixelSize: Sizes.fontSizeS
                opacity: Style.opacityMedium
                text: root.subtitle
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                width: parent.width
            }
        }
    }

    Loader {
        id: complexItem
    }
}