import QtQuick
import Qt5Compat.GraphicalEffects
import org.kde.plasma.plasma5support as Plasma5Support

Rectangle {
    id: root
    color: bgColor 

    // Bu değerler install.sh tarafından değiştirilebilir
    property string themeColor: "#ff0000" //text metin rengi
    property string displayMode: "logo" // "logo" veya "full"
    property string bgColor: "#000000" // Arkaplan rengi veya şeffaf

    property string logoData: ""
    property string infoData: ""
    
    // Ekranda gösterilen anlık veriler
    property string displayedLogoData: ""
    property string displayedInfoData: ""
    
    // Animasyon durum değişkenleri
    property var logoIndices: []
    property var infoIndices: []
    property int logoAnimStep: 0
    property int infoAnimStep: 0
    property int charsPerFrameLogo: 1
    property int charsPerFrameInfo: 1

    property bool logoLoaded: false
    property bool infoLoaded: false
    property bool errorOccurred: false
    property int stage: 0
    property bool minDurationMet: false

    // Karakterleri karıştırma fonksiyonu (Fisher-Yates) // ...

    function shuffleArray(array) {
        for (var i = array.length - 1; i > 0; i--) {
            var j = Math.floor(Math.random() * (i + 1));
            var temp = array[i];
            array[i] = array[j];
            array[j] = temp;
        }
    }

    // Şeffaf karakterler oluşturma
    function initDisplayString(length) {
        var str = "";
        for (var i = 0; i < length; i++) {
            str += " ";
        }
        return str;
    }

    // String üzerinde belirli indeksteki karakteri değiştirme
    function setCharAt(str, index, chr) {
        if (index > str.length - 1) return str;
        return str.substring(0, index) + chr + str.substring(index + 1);
    }

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

    // Rastgele metin belirme efekti Timer'ı
    Timer {
        id: glitchAnimTimer
        interval: 30
        running: false
        repeat: true
        onTriggered: {
            var finished = true;

            // Logo animasyonu
            if (root.logoAnimStep < root.logoIndices.length) {
                finished = false;
                var currentLogoData = root.displayedLogoData;
                for (var i = 0; i < root.charsPerFrameLogo && root.logoAnimStep < root.logoIndices.length; i++) {
                    var idx = root.logoIndices[root.logoAnimStep];
                    currentLogoData = setCharAt(currentLogoData, idx, root.logoData.charAt(idx));
                    root.logoAnimStep++;
                }
                root.displayedLogoData = currentLogoData;
            }

            // Info animasyonu
            if (root.displayMode === "full" && root.infoAnimStep < root.infoIndices.length) {
                finished = false;
                var currentInfoData = root.displayedInfoData;
                for (var j = 0; j < root.charsPerFrameInfo && root.infoAnimStep < root.infoIndices.length; j++) {
                    var jdx = root.infoIndices[root.infoAnimStep];
                    currentInfoData = setCharAt(currentInfoData, jdx, root.infoData.charAt(jdx));
                    root.infoAnimStep++;
                }
                root.displayedInfoData = currentInfoData;
            }

            if (finished) {
                glitchAnimTimer.stop();
            }
        }
    }

    // Güvenlik Zamanlayıcısı
    Timer {
        id: safetyTimer
        interval: 3000
        running: true
        onTriggered: {
            var isReady = root.displayMode === "logo" ? root.logoLoaded : (root.logoLoaded && root.infoLoaded);
            if (!isReady) {
                root.errorOccurred = true;
                root.logoData = "";
                root.infoData = "Error: 'fastfetch' not found on your system.\nPlease make sure the package is installed.";
                root.displayMode = "full";
                startEffects();
                
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

    function startEffects() {
        // Logo Ayarları
        root.logoIndices = [];
        for (var i = 0; i < root.logoData.length; i++) {
            if (root.logoData.charAt(i) !== ' ' && root.logoData.charAt(i) !== '\n' && root.logoData.charAt(i) !== '\r') {
                root.logoIndices.push(i);
            }
        }
        shuffleArray(root.logoIndices);
        root.displayedLogoData = root.logoData.replace(/[^\r\n]/g, " ");
        root.charsPerFrameLogo = Math.max(1, Math.ceil(root.logoIndices.length / 50)); 

        // Info Ayarları
        if (root.displayMode === "full") {
            root.infoIndices = [];
            for (var j = 0; j < root.infoData.length; j++) {
                if (root.infoData.charAt(j) !== ' ' && root.infoData.charAt(j) !== '\n' && root.infoData.charAt(j) !== '\r') {
                    root.infoIndices.push(j);
                }
            }
            shuffleArray(root.infoIndices);
            root.displayedInfoData = root.infoData.replace(/[^\r\n]/g, " "); 
            root.charsPerFrameInfo = Math.max(1, Math.ceil(root.infoIndices.length / 50));
        }

        introAnimation.start();
        glitchAnimTimer.start();
        minDurationTimer.start();
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
            var cleaned = stdout.replace(/\x1B\[[0-9;]*[A-GJKSTfmny]/g, "");
            
            var lines = cleaned.split('\n');
            for (var i = 0; i < lines.length; i++) {
                lines[i] = lines[i].replace(/\s+$/, "");
            }
            cleaned = lines.join('\n').replace(/^[\r\n]+|[\r\n]+$/g, "");
            
            if (sourceName.indexOf("structure L") !== -1) {
                root.logoData = cleaned;
                root.logoLoaded = true;
            } else {
                root.infoData = cleaned;
                root.infoLoaded = true;
            }
            
            var isReady = root.displayMode === "logo" ? root.logoLoaded : (root.logoLoaded && root.infoLoaded);
            
            if (isReady && !root.errorOccurred) {
                safetyTimer.stop();
                startEffects();
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
            
            // LOGO BÖLÜMÜ
            Item {
                width: logoText.implicitWidth
                height: logoText.implicitHeight
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: logoText
                    text: root.displayedLogoData
                    color: root.themeColor
                    font.family: "Monospace"
                    font.pointSize: 13
                    font.weight: Font.Normal
                    textFormat: Text.PlainText
                    renderType: Text.NativeRendering
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.NoWrap
                }

                DropShadow {
                    anchors.fill: logoText
                    source: logoText
                    transparentBorder: true
                    color: root.themeColor
                    radius: 8   // İç parlama (Keskin)
                    samples: 16
                }

                DropShadow {
                    anchors.fill: logoText
                    source: logoText
                    transparentBorder: true
                    color: root.themeColor
                    radius: 25  // Dış parlama (Aura)
                    samples: 30
                    opacity: 0.6
                }
            }

            // BİLGİ BÖLÜMÜ
            Item {
                visible: root.displayMode === "full"
                width: infoText.implicitWidth
                height: infoText.implicitHeight
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: infoText
                    text: root.displayedInfoData
                    color: root.themeColor
                    font.family: "Monospace"
                    font.pointSize: 13
                    textFormat: Text.PlainText
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }

                DropShadow {
                    anchors.fill: infoText
                    source: infoText
                    transparentBorder: true
                    color: root.themeColor
                    radius: 6   // İç parlama
                    samples: 12
                }

                DropShadow {
                    anchors.fill: infoText
                    source: infoText
                    transparentBorder: true
                    color: root.themeColor
                    radius: 20  // Dış parlama
                    samples: 24
                    opacity: 0.6
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
        if (root.displayMode === "full") {
            executable.exec("fastfetch --logo none --pipe")
        }
    }
}
