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
import QtQuick.Controls 2.3

import shared.Sizes 1.0

import "../helpers"  1.0
import "../3d/materials" 1.0
import "../3d/entities" 1.0
import "../3d/settings" 1.0

Item {
    id: root

    property real cameraPanAngleOutput: 0.0
    property real cameraPanAngleInput: 0.0

    //ToDo: This is a part of a work around for the Scene3D windows&macOS bug
    property real roofOpenProgress: 0.0
    property bool leftDoorOpen: false
    property bool rightDoorOpen: false
    property bool trunkOpen: false
    property bool clusterView: false

    //ToDo: This is a part of a work around for the Scene3D windows&macOS bug
    Loader {
        anchors.fill: parent
        active: root.visible
        sourceComponent: sceneComponent
    }

    Component {
        id: sceneComponent
        Item {
            anchors.fill: parent
            Image {
                anchors.fill: parent
                source: Paths.getImagePath("back.png")

                //ToDo: Replace later with an actual splash screen
                BusyIndicator {
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: Sizes.dp(80)
                    running: !body.loaded
                }
            }

            QtObject {
                id: d
                readonly property vector2d base2d : Qt.vector2d(0.0, -15.0)
                property real pixelAndTimeMagicCoeff: 0.5
                property var trajectory: []
                property var trajectoryV: []
            }

            function getCurrentAngle() {
                var cameraPos = camera.position;
                var vec2d = Qt.vector2d(-cameraPos.x, cameraPos.z);
                var angle = 0.0;
                angle = -Math.atan2(vec2d.x, vec2d.y);
                angle = angle < 0 ? angle + 2*Math.PI : angle;
                return angle * 180 / Math.PI;
            }

            MouseArea {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: Sizes.dp(652)
                z: 40

                onReleased: {
                    d.trajectory = []
                }


                onPositionChanged: {
                    if (pressed) {
                        d.trajectory.push(mouseX);
                        d.trajectoryV.push(mouseY);
                        if (d.trajectory.length > 2) {
                            var dx = 0
                            for (var i = 1; i < d.trajectory.length; ++i) {
                                dx += d.trajectory[i] - d.trajectory[i - 1];
                            }

                            if (dx !== 0) {
                                camera.panAboutViewCenter(-dx * d.pixelAndTimeMagicCoeff
                                                               , Qt.vector3d(0, 1, 0));
                                root.cameraPanAngleInput = getCurrentAngle();
                            }

                            d.trajectory = []
                        }
                    }
                }
            }

            Connections {
                target: root
                onCameraPanAngleOutputChanged: {
                    var angle = getCurrentAngle()
                    if (root.clusterView && angle !== root.cameraPanAngleOutput) {
                     camera.panAboutViewCenter(root.cameraPanAngleOutput - angle
                                               , Qt.vector3d(0, 1, 0));
                    }
                }
            }

            Scene3D {
                anchors.fill: parent
                aspects: ["input", "logic"]
                focus: false

                Entity {
                    RenderSettings {
                        id: renderSettings
                        activeFrameGraph: FrameGraph {
                            clearColor: "transparent"
                            camera: camera
                        }
                        // NB: this should work once https://codereview.qt-project.org/#/c/208218/ is merged
                        renderPolicy: RenderSettings.OnDemand
                    }

                    InputSettings {
                        id: inputSettings
                    }

                    components: [inputSettings, renderSettings]

                    Camera {
                        id: camera
                        projectionType: CameraLens.PerspectiveProjection
                        fieldOfView: 25
                        nearPlane: 0.1
                        farPlane: 100.0
                        position:   Qt.vector3d(0.0, 5.0, 18.0)
                        viewCenter: Qt.vector3d(0.0, 1.6, 0.0)
                        upVector:   Qt.vector3d(0.0, 1.0, 0.0)
                    }

                    CookTorranceMaterial {
                        id: blackMaterial
                        albedo: "black"
                        metalness: 0.5
                        roughness: 0.8
                    }

                    CookTorranceMaterial {
                        id: rubberMaterial
                        albedo: "black"
                        metalness: 0.9
                        roughness: 0.5
                    }

                    CookTorranceMaterial {
                        id: whiteHood
                        albedo: "white"
                        metalness: 0.1
                        roughness: 0.35
                    }

                    CookTorranceMaterial {
                        id: chromeMaterial
                        albedo: "black"
                        metalness: 0.1
                        roughness: 0.2
                    }

                    CookTorranceMaterial {
                        id: wheelChromeMaterial
                        albedo: "black"
                        metalness: 0.1
                        roughness: 0.7
                    }

                    CookTorranceMaterial {
                        id: taillightsMaterial
                        albedo: "red"
                        metalness: 0.1
                        roughness: 0.2
                        alpha: 0.5
                    }

                    CookTorranceMaterial {
                        id: interiorMaterial
                        albedo: "gray"
                        metalness: 1.0
                        roughness: 0.1
                    }

                    CookTorranceMaterial {
                        id: whiteMaterial
                        albedo: "white"
                        metalness: 0.5
                        roughness: 0.5
                    }

                    CookTorranceMaterial {
                        id: glassMaterial
                        albedo: "black"
                        metalness: 0.1
                        roughness: 0.1
                        alpha: 0.8
                    }

                    Shadow {}
                    AxisFront {}
                    AxisRear {}
                    Seats {}
                    RearDoor {
                        id: trunk
                        open: root.trunkOpen
                    }
                    LeftDoor {
                        id: leftDoor
                        open: root.leftDoorOpen
                    }
                    RightDoor {
                        id: rightDoor
                        open: root.rightDoorOpen
                    }
                    Roof {
                        id: roof
                        openProgress: root.roofOpenProgress
                    }
                    Body { id: body }
                }
            }
        }
    }
}
