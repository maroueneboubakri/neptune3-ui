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

import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.2

import shared.controls 1.0
import shared.utils 1.0

import shared.Sizes 1.0

Item {
    id: root

    property alias leftDoorOpened: doorsPanel.leftDoorOpened
    property alias rightDoorOpened: doorsPanel.rightDoorOpened
    property alias trunkOpened: doorsPanel.trunkOpened
    property alias menuModel: toolsColumn.model
    property alias controlModel: supportPanel.model

    signal leftDoorClicked()
    signal rightDoorClicked()
    signal trunkClicked()
    signal roofOpenProgressChanged(var value)

    ToolsColumn {
        id: toolsColumn
        anchors.top: parent.top
        anchors.left: parent.left
        width: Sizes.dp(264)
        height: Sizes.dp(460)
        translationContext: "VehicleToolsColumn"
    }

    StackLayout {
        anchors.left: toolsColumn.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: root.width - toolsColumn.width

        currentIndex: toolsColumn.currentIndex

        SupportPanel { id: supportPanel }
        EnergyPanel {}
        DoorsPanel {
            id: doorsPanel
            onLeftDoorClicked: root.leftDoorClicked()
            onRightDoorClicked: root.rightDoorClicked()
            onTrunkClicked: root.trunkClicked()
            onRoofOpenProgressChanged: root.roofOpenProgressChanged(value)
        }
        TiresPanel {}
    }
}
