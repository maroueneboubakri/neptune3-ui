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

import QtQuick 2.8
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import shared.utils 1.0
import shared.animations 1.0
import shared.controls 1.0
import shared.Style 1.0
import shared.Sizes 1.0

import "../controls" 1.0

ListView {
    id: root
    clip: true

    opacity: visible ? 1 : 0
    Behavior on opacity { DefaultNumberAnimation { } }

    property var store

    delegate: ItemDelegate { // FIXME right component?
        width: ListView.view.width
        height: Sizes.dp(70)
        padding: 0
        contentItem: Item {
            RowLayout {
                anchors.fill: parent
                spacing: Sizes.dp(45 * .5)
                RoundImage {
                    Layout.preferredHeight: Sizes.dp(64)
                    Layout.preferredWidth: Sizes.dp(64)
                    source: "../assets/profile_photos/%1.png".arg(model.handle)
                }
                Label {
                    text: model.firstName + " " + model.surname
                    font.weight: Font.Light
                }
                Item { // spacer
                    Layout.fillWidth: true
                }
                ToolButton {
                    icon.name: "ic-message-contrast"
                }
                ToolButton {
                    icon.name: "ic-call-contrast"
                    onClicked: root.store.startCall(model.handle)
                }
            }
            Image {
                anchors.bottom: parent.bottom
                width: parent.width
                source: Style.image("list-divider")
            }
        }
    }
}
