import QtQuick
import Qt5Compat.GraphicalEffects
import org.kde.plasma.plasma5support as Plasma5Support

Rectangle {
    id: root
    color: "#0a0a0a" // Dark background

    property string logoData: ""
    property string infoData: ""
    property bool logoLoaded: false
    property bool infoLoaded: false
    property int stage: 0
    property bool minDurationMet: false

    Timer {
        id: minDurationTimer
        interval: 4000 // Keep it visible for at least 4 seconds
        running: false
        onTriggered: {
            minDurationMet = true;
            if (root.stage >= 5) {
                exitAnimation.start();
            }
        }
    }

    onStageChanged: {
        if (stage >= 5 && minDurationMet) {
            exitAnimation.start();
        }
    }

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            var stdout = data["stdout"] || "";
            var cleaned = stdout.replace(/\x1B\[[0-9;]*[A-GJKSTfmny]/g, "").trim();
            
            if (sourceName.indexOf("structure L") !== -1) {
                root.logoData = cleaned;
                root.logoLoaded = true;
            } else {
                root.infoData = cleaned;
                root.infoLoaded = true;
            }
            
            // Wait for both logo and info to be ready before showing
            if (root.logoLoaded && root.infoLoaded) {
                introAnimation.start();
                minDurationTimer.start(); // Start the timer here
            }
            disconnectSource(sourceName);
        }
        function exec(cmd) {
            connectSource(cmd);
        }
    }

    Item {
        id: content
        anchors.fill: parent
        opacity: 0 // Start hidden

        Row {
            id: mainLayout
            anchors.centerIn: parent
            spacing: 120 
            
            // LOGO
            Text {
                text: root.logoData
                color: "#ff0000"
                font.family: "Monospace"
                font.pointSize: 15
                font.weight: Font.Normal
                textFormat: Text.PlainText
                renderType: Text.NativeRendering
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.NoWrap
                
                topPadding: 90
                
                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    color: "#ff0000"
                    radius: 20
                    samples: 24
                }
            }

            // BİLGİLER 
            Text {
                text: root.infoData
                color: "#ff0000"
                font.family: "Monospace"
                font.pointSize: 14 
                textFormat: Text.PlainText
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                
                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    color: "#ff0000"
                    radius: 12
                    samples: 16
                }
            }
        }
    }

    OpacityAnimator {
        id: introAnimation
        target: content
        from: 0
        to: 1
        duration: 800 // Faster fade in
        easing.type: Easing.InOutQuad
    }

    OpacityAnimator {
        id: exitAnimation
        target: root
        from: 1
        to: 0
        duration: 1500 // Smoother fade out
        easing.type: Easing.InOutQuad
    }

    Component.onCompleted: {
        executable.exec("fastfetch --structure L --pipe")
        executable.exec("fastfetch --logo none --pipe")
    }
}
