import QtQuick
import Qt5Compat.GraphicalEffects
import org.kde.plasma.plasma5support as Plasma5Support

Image {
    id: root

    property string logoData: ""
    property string infoData: ""

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            var stdout = data["stdout"] || "";
            var cleaned = stdout.replace(/\x1B\[[0-9;]*[A-GJKSTfmny]/g, "").trim();
            
            if (sourceName.indexOf("structure L") !== -1) {
                root.logoData = cleaned;
            } else {
                root.infoData = cleaned;
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
        opacity: 1

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
                
                // Logoyu biraz aşağı kaydırma
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
        running: true
        target: content
        from: 0
        to: 1
        duration: 5000 
        easing.type: Easing.InOutQuad
    }

    Component.onCompleted: {
        executable.exec("fastfetch --structure L --pipe")
        executable.exec("fastfetch --logo none --pipe")
    }
}
