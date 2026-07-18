// idlegif: DVD Logo screensaver for webOS 9.x (Clock.qml override)
// Preserves the exact interface expected by the webOS screensaver framework.
// DVD logo animation ported from github.com/webosbrew/custom-screensaver (public domain logo).

import QtQuick 2.12
import "../Components"

Item {

    id: root

    readonly property int displayDurationTime: 5000
    readonly property int mainFadeInOutTime: 3000
    readonly property int guideTextFadeInTime: 3000
    readonly property int infoFadeInOutTime: 500

    property int hours
    property int minutes
    property int seconds
    property string currentTime
    property real shift
    property bool isPartial: false
    property string guideString: ""
    property bool playing: false
    property bool timeUpdated: false
    property bool dataReady: playing && root.timeUpdated
    property alias animation: anim

    signal looped()

    onDataReadyChanged: {
        if (dataReady) {
            visible = true;
            anim.start();
        } else {
            visible = false;
            anim.stop();
        }
    }

    SequentialAnimation {
        id: anim
        loops: Animation.Infinite
        PauseAnimation { duration: 5 * 60 * 1000 }
        ScriptAction { script: looped() }
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
    }

    Rectangle {
        id: boing

        width: 320
        height: 163

        function setRandomColor() {
            var colors = ['#f00', '#0f0', '#00f', '#ff0', '#f0f', '#0ff', '#fff'];
            boing.color = colors[(Math.random() * colors.length) | 0];
        }

        Image {
            anchors.fill: parent
            // webOS 9's QML runtime does not render base64 data: URIs, so load
            // the logo mask from disk (deployed by install.sh). The black
            // surround masks the coloured rectangle, leaving a coloured logo.
            source: "/var/lib/webosbrew/idlegif/dvd-logo.png"
            cache: true
            asynchronous: false
            smooth: false
        }

        Component.onCompleted: {
            boing.setRandomColor();
        }

        SequentialAnimation on x {
            running: root.dataReady
            loops: Animation.Infinite
            PropertyAnimation {
                easing.type: Easing.Linear
                duration: 1920 * 11
                to: 1920 - boing.width
            }
            ScriptAction { script: boing.setRandomColor(); }
            PropertyAnimation {
                easing.type: Easing.Linear
                duration: 1920 * 11
                to: 0
            }
            ScriptAction { script: boing.setRandomColor(); }
        }

        SequentialAnimation on y {
            running: root.dataReady
            loops: Animation.Infinite
            PropertyAnimation {
                easing.type: Easing.Linear
                duration: 1080 * 7
                to: 1080 - boing.height
            }
            ScriptAction { script: boing.setRandomColor(); }
            PropertyAnimation {
                easing.type: Easing.Linear
                duration: 1080 * 7
                to: 0
            }
            ScriptAction { script: boing.setRandomColor(); }
        }
    }

    Component.onCompleted: {
        updateTime();
        timeManager.currentTimeUpdated.connect(updateTime);
    }

    Component.onDestruction: {
        timeManager.currentTimeUpdated.disconnect(updateTime);
    }

    function updateTime() {
        if (!timeManager.isFactoryTime && timeManager.broadcastUtcTime) {
            currentTime = timeManager.dateTimeFormat(timeManager.broadcastUtcTime, "date", "dmy", "full");
            hours   = timeManager.broadcastUtcTime.getUTCHours() % 12;
            minutes = timeManager.broadcastUtcTime.getUTCMinutes() % 60;
            seconds = timeManager.broadcastUtcTime.getUTCSeconds() % 60;
        }
        timeUpdated = true;
    }
}
