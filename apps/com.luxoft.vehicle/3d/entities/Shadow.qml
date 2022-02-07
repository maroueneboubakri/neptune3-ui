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
import "../../3d/materials" 1.0

Entity {
    CookTorranceMaterial {
        id: shadowMaterial
        albedo: "black"
        metalness: 0.0
        roughness: 1
        alpha: 0.1
    }

    CookTorranceMaterial {
        id: shadowMaterial2
        albedo: "black"
        metalness: 0.0
        roughness: 1
        alpha: 0.2
    }

    CookTorranceMaterial {
        id: shadowMaterial3
        albedo: "black"
        metalness: 0.0
        roughness: 1
        alpha: 0.3
    }

    Mesh {
        id: shadowMesh
        source: Paths.getModelPath("shadow.obj")
    }

    components: [shadowMesh, shadowMaterial ]

    Entity {
        Mesh {
            id: shadowMesh2
            source: Paths.getModelPath("shadow.obj")
        }

        Transform {
            id: transform
            scale: 0.97
            translation: Qt.vector3d(0, 0.01, 0)
        }

        components: [shadowMesh2, shadowMaterial2, transform]

        Entity {
            Mesh {
                id: shadowMesh3
                source: Paths.getModelPath("shadow.obj")
            }

            Transform {
                id: transform2
                scale: 0.97
                translation: Qt.vector3d(0, 0.01, 0)
            }

            components: [shadowMesh3, shadowMaterial3, transform2]
        }
    }
}
