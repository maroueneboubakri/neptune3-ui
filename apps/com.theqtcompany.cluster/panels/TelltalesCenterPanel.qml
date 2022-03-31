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
	
ColumnLayout  {
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

    id: toastPopup

    readonly property real defaultTime: 3000
    property real time: defaultTime
    readonly property real fadeTime: 300

    property real margin: 10

    anchors {
        left: parent.left
        right: parent.right
        margins: margin
    }

    height: message.height + icon.height + margin
    radius: margin

    opacity: 0
    color: "#5E5954"

	Image {
		id: icon
		// Support only emergency vehicle approaching notification
		source: Utils.localAsset("emergency")
		width:265
		height:265
		//anchors.centerIn: parent
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		//anchors.topMargin: margin
	}

    Text {
        id: message
        color: "white"
		font.pointSize: 9
		//text: "Emergency vehicle approaching\nin 500m"
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        anchors {
            top: icon.bottom
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
  
}

	onWarnToastChanged: {
		if(warnToast != ""){
			// 0 -> warning type, to set icon accordingly
			// 1 -> message to display
			// 2 -> timestamp, unused yet
			icon.source  = Utils.localAsset(warnToast.split(';')[0])
			toastPopup.show(warnToast.split(';')[1], 5000);
		}
    }	
	
}
