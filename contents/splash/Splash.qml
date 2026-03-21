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
    property bool errorOccurred: false
    property int stage: 0
    property bool minDurationMet: false

    Timer {
        id: minDurationTimer
        interval: 4000
        running: false
        onTriggered: {
            minDurationMet = true;
            if (root.stage >= 5) {
                exitAnimation.start();
            }
        }
    }

    // Güvenlik Zamanlayıcısı: Eğer 3 saniye içinde veri gelmezse hata göster ve devam et
    Timer {
        id: safetyTimer
        interval: 3000
        running: true
        onTriggered: {
            if (!root.logoLoaded || !root.infoLoaded) {
                root.errorOccurred = true;
                root.infoData = "Error: 'fastfetch' not found on your system.\nPlease make sure the package is installed.";
                introAnimation.start();
                // Hata olsa bile 2 saniye sonra açılışa devam et
                errorExitTimer.start();
            }
        }
    }

    Timer {
        id: errorExitTimer
        interval: 2000
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
            // ANSI kaçış kodlarını temizle
            var cleaned = stdout.replace(/\x1B\[[0-9;]*[A-GJKSTfmny]/g, "");
            
            // Satır sonlarındaki boşlukları temizle (Fastfetch'in info kısmı için eklediği sağ padding)
            var lines = cleaned.split('\n');
            for (var i = 0; i < lines.length; i++) {
                lines[i] = lines[i].replace(/\s+$/, "");
            }
            // Baş ve sondaki boş satırları (!sadece satır atlamalarını!) temizle, normal .trim() sol hizalamayı bozar
            cleaned = lines.join('\n').replace(/^[\r\n]+|[\r\n]+$/g, "");
            
            if (sourceName.indexOf("structure L") !== -1) {
                root.logoData = cleaned;
                root.logoLoaded = true;
            } else {
                root.infoData = cleaned;
                root.infoLoaded = true;
            }
            
            if (root.logoLoaded && root.infoLoaded) {
                safetyTimer.stop();
                introAnimation.start();
                minDurationTimer.start();
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
        opacity: 0 

        Row {
            id: mainLayout
            anchors.centerIn: parent
            spacing: 50
            
            // LOGO
            Text {
                text: root.logoData
                color: "#ff0000"
                font.family: "Monospace"
                font.pointSize: 13
                font.weight: Font.Normal
                textFormat: Text.PlainText
                renderType: Text.NativeRendering
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.NoWrap
                
                anchors.verticalCenter: parent.verticalCenter
                
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
                font.pointSize: 13
                textFormat: Text.PlainText
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                
                anchors.verticalCenter: parent.verticalCenter
                
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
