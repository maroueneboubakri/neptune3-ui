/****************************************************************************
** PATCH: Marouene Boubakri
****************************************************************************/

import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
//import QtQuick.Extras 1.4
//import Qt.SafeRenderer 1.0
import "../controls" 1.0
import "../helpers" 1.0
import shared.Sizes 1.0

import QtApplicationManager 2.0
import QtApplicationManager 2.0

Item {
    id: root
    width: Sizes.dp(444)
    height: Sizes.dp(58)
	
    //public
    property string warnToast
	
RowLayout {
	anchors.fill: parent

/*****************/

Rectangle {

    /**
      * Public
      */

    /**
      * @brief Shows this Toast
      *
      * @param {string} text Text to show
      * @param {real} duration Duration to show in milliseconds, defaults to 3000
      */
    function show(text, duration) {
        message.text = text;
        if (typeof duration !== "undefined") { // checks if parameter was passed
            time = Math.max(duration, 2 * fadeTime);
        }
        else {
            time = defaultTime;
        }
        animation.start();
    }

    property bool selfDestroying: false  // whether this Toast will self-destroy when it is finished

    /**
      * Private
      */

    id: toaast

    readonly property real defaultTime: 3000
    property real time: defaultTime
    readonly property real fadeTime: 300

    property real margin: 10

    anchors {
        left: parent.left
        right: parent.right
        margins: margin
    }

    height: message.height + margin
    radius: margin

    opacity: 0
    color: "#222222"

    Text {
        id: message
        color: "white"
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: margin / 2
        }
    }

    SequentialAnimation on opacity {
        id: animation
        running: false


        NumberAnimation {
            to: .9
            duration: fadeTime
        }

        PauseAnimation {
            duration: time - 2 * fadeTime
        }

        NumberAnimation {
            to: 0
            duration: fadeTime
        }

        onRunningChanged: {
            if (!running && selfDestroying) {
                root.destroy();
            }
        }
    }

}

  

/*****************/

     Button {
            id: simpleNotiButton
            implicitWidth: Sizes.dp(500)
            implicitHeight: Sizes.dp(64)
            text: warnToast
            onClicked: {
                toaast.show("⚠ HOHOHOHOH !", 5000);
				/*var notification1 = ApplicationInterface.createNotification();
                notification1.summary = qsTr("Summary text: simple notification");
                notification1.body = qsTr("Body text: simple notification");
                notification1.showActionsAsIcons = true;
                notification1.actions = [{"actionText": qsTr("Action Text")}];
                notification1.show();
				*/
            }
        }
/*	
    Label {
        text: warnToast
        font.pixelSize: 32
        color: "black"
    }
 */  
  
}

	onWarnToastChanged: {
        toaast.show("⚠ HOHOHOHOH !!!", 5000);
    }
	
}
