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
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0

import shared.controls 1.0
import shared.utils 1.0
import shared.Sizes 1.0

ListView {
    id: root

    property var store

    signal toolClicked(string appId, string appName)

    model: root.store.applicationModel
    currentIndex: -1
    delegate: ListItemProgress {
        id: delegatedItem
        readonly property bool isInstalled: root.store.installedApps.indexOf(model.id) !== -1

        width: Sizes.dp(675)
        height: Sizes.dp(80)
        icon.source: root.store.appServerUrl + "/app/icon?id=" + model.id
        text: model.name
        secondaryText: delegatedItem.isInstalled ? root.store.getInstalledApplicationSize(model.id)
                                                 : ""
        cancelSymbol: delegatedItem.isInstalled ? "ic-close" : "ic-download_OFF"
        value: root.store.currentInstallationProgress
        onValueChanged: {
            if (value === 1.0) {
                root.currentIndex = -1;
            }
        }
        progressVisible: root.currentIndex === index && root.store.currentInstallationProgress < 1.0
        onProgressCanceled: {
            if (!delegatedItem.isInstalled) {
                root.currentIndex = index;
            }
            root.toolClicked(model.id, model.name);
        }
    }
}
