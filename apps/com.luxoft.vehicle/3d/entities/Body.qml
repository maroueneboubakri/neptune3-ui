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
import QtQuick 2.0
import Qt3D.Core 2.0
import Qt3D.Render 2.9
import Qt3D.Extras 2.9
import Qt3D.Input 2.0
import QtQuick.Scene3D 2.0

import "../../helpers" 1.0
import "../materials" 1.0

Entity {
    id: root

    property bool loaded: chromeReady && shellReady && matt_blackReady && glassReady
            && license_platesReady && frontLightsReady && taillightsReady && interiorReady

    property bool chromeReady: mesh.status === Mesh.Ready
    property bool shellReady: shell.status === Mesh.Ready
    property bool matt_blackReady: matt_black.status === Mesh.Ready
    property bool glassReady: glass.status === Mesh.Ready
    property bool license_platesReady: license_plates.status === Mesh.Ready
    property bool frontLightsReady: interior.status === Mesh.Ready
    property bool taillightsReady: taillights.status === Mesh.Ready
    property bool interiorReady: interior.status === Mesh.Ready

    Transform {
        id: transform
        property real userAngle: 0.0
    }

    components: [transform]

    Entity {
        Mesh {
            id: mesh
            source: Paths.getModelPath("chrome.obj")
            //ToDo: this has to be replaced with an actual loading signal or something more clear
            onGeometryChanged: root.loaded = true
        }
        components: [mesh, chromeMaterial]
    }

    Entity {
        Mesh {
            id: shell
            source: Paths.getModelPath("shell.obj")
        }
        components: [shell, whiteHood]
    }

    Entity {
        Mesh {
            id: matt_black
            source: Paths.getModelPath("matt_black.obj")
        }
        components: [matt_black, blackMaterial]
    }

    Entity {
        Mesh {
            id: glass
            source: Paths.getModelPath("glass_4.obj")
        }
        components: [glass, glassMaterial]
    }

    Entity {
        Mesh {
            id: license_plates
            source: Paths.getModelPath("licence_plates.obj")
        }
        components: [license_plates, whiteMaterial]
    }

    Entity {
        Mesh {
            id: frontLights
            source: Paths.getModelPath("front_ights.obj")
        }
        CookTorranceMaterial {
            id: frontLightsMaterial
            albedo: "black"
            metalness: 1.0
            roughness: 0.1
            alpha: 0.7
        }
        components: [frontLights, frontLightsMaterial]
    }

    Entity {
        Mesh {
            id: taillights
            source: Paths.getModelPath("taillights.obj")
        }
        components: [taillights, taillightsMaterial]
    }

    Entity {
        Mesh {
            id: interior
            source: Paths.getModelPath("interior.obj")
        }
        components: [interior, interiorMaterial]
    }

}
