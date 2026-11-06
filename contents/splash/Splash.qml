import QtQuick
import Qt5Compat.GraphicalEffects
import org.kde.plasma.plasma5support as Plasma5Support

Rectangle {
    id: root
    color: bgColor 

    // =========================================================================
    // CONFIGURATION
    // These values are automatically modified by the 'install.sh' script.
    // =========================================================================

    // The main color used for the text and drop shadow glow (HEX code, e.g., "#ff0000").
    property string themeColor: "#ffffff" 

    // Layout mode. "logo" shows only the OS logo. "full" shows the logo + system information. "info" shows only system information.
    property string displayMode: "logo" 

    // Background color of the splash screen. Use a HEX code (e.g., "#000000") or "transparent".
    property string bgColor: "#000000" 

    // =========================================================================
    // ANIMATION SPEED SETTINGS
    // These settings do not change the overall splash duration. The splash
    // ends as soon as the KDE desktop is loaded.
    // =========================================================================

    // The interval (in milliseconds) for the character reveal glitch timer. Smaller = faster.
    property int glitchInterval: 30       

    // Duration (in milliseconds) of the fade-in animation when the splash starts.
    property int introDuration: 800       

    // Duration (in milliseconds) of the fade-out animation before the desktop appears.
    property int exitDuration: 1500       

    // The minimum amount of time (in milliseconds) the splash screen will stay visible.
    property int minSplashDuration: 4000  

    // Divisor used to calculate how many characters reveal per frame. Smaller = faster.
    property int frameDivisor: 50         
    
    // =========================================================================
    // END OF CONFIGURATION
    // From this point onwards, internal variables are defined. Do not modify.
    // =========================================================================

    // Raw string data received from fastfetch.
    property string logoData: ""
    property string infoData: ""
    
    // Current strings being displayed (revealed characters).
    property string displayedLogoData: ""
    property string displayedInfoData: ""
    
    // Animation state and index tracking variables.
    property var logoIndices: []
    property var infoIndices: []
    property int logoAnimStep: 0
    property int infoAnimStep: 0
    property int charsPerFrameLogo: 1
    property int charsPerFrameInfo: 1

    // Status flags for loading and errors.
    property bool logoLoaded: false
    property bool infoLoaded: false
    property bool errorOccurred: false
    property int stage: 0
    property bool minDurationMet: false

    // Fisher-Yates character shuffling function

    function shuffleArray(array) {
        for (var i = array.length - 1; i > 0; i--) {
            var j = Math.floor(Math.random() * (i + 1));
            var temp = array[i];
            array[i] = array[j];
            array[j] = temp;
        }
    }

    // Create transparent string
    function initDisplayString(length) {
        var str = "";
        for (var i = 0; i < length; i++) {
            str += " ";
        }
        return str;
    }

    // Set character at specific index in string
    function setCharAt(str, index, chr) {
        if (index > str.length - 1) return str;
        return str.substring(0, index) + chr + str.substring(index + 1);
    }

    Timer {
        id: minDurationTimer
        interval: minSplashDuration
        running: false
        onTriggered: {
            minDurationMet = true;
            if (root.stage >= 5) {
                exitAnimation.start();
            }
        }
    }

    // Random text reveal effect timer
    Timer {
        id: glitchAnimTimer
        interval: glitchInterval
        running: false
        repeat: true
        onTriggered: {
            var finished = true;

            // Logo animation
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

            // Info animation
            if ((root.displayMode === "full" || root.displayMode === "info") && root.infoAnimStep < root.infoIndices.length) {
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

    // Safety timer
    Timer {
        id: safetyTimer
        interval: 3000
        running: true
        onTriggered: {
            var isReady = root.displayMode === "logo" ? root.logoLoaded : (root.displayMode === "info" ? root.infoLoaded : (root.logoLoaded && root.infoLoaded));
            if (!isReady) {
                showError("'fastfetch' not found or could not be executed.\nPlease make sure the package is installed.");
            }
        }
    }

    function showError(msg) {
        if (root.errorOccurred) return;
        root.errorOccurred = true;
        root.logoData = "";
        root.infoData = "Error: " + msg + "\n\nVisit GitHub for installation & details:\nhttps://github.com/herzane52/fastfetch-kde-splash";
        root.displayMode = "full";
        safetyTimer.stop();
        startEffects();
        errorExitTimer.start();
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
        // Logo settings
        root.logoIndices = [];
        for (var i = 0; i < root.logoData.length; i++) {
            if (root.logoData.charAt(i) !== ' ' && root.logoData.charAt(i) !== '\n' && root.logoData.charAt(i) !== '\r') {
                root.logoIndices.push(i);
            }
        }
        shuffleArray(root.logoIndices);
        root.displayedLogoData = root.logoData.replace(/[^\r\n]/g, " ");
        root.charsPerFrameLogo = Math.max(1, Math.ceil(root.logoIndices.length / root.frameDivisor)); 

        // Info settings
        if (root.displayMode === "full" || root.displayMode === "info") {
            root.infoIndices = [];
            for (var j = 0; j < root.infoData.length; j++) {
                if (root.infoData.charAt(j) !== ' ' && root.infoData.charAt(j) !== '\n' && root.infoData.charAt(j) !== '\r') {
                    root.infoIndices.push(j);
                }
            }
            shuffleArray(root.infoIndices);
            root.displayedInfoData = root.infoData.replace(/[^\r\n]/g, " "); 
            root.charsPerFrameInfo = Math.max(1, Math.ceil(root.infoIndices.length / root.frameDivisor));
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

            if (cleaned === "") {
                showError("'fastfetch' returned an empty output.");
                return;
            }
            
            if (sourceName.indexOf("structure L") !== -1) {
                root.logoData = cleaned;
                root.logoLoaded = true;
            } else {
                root.infoData = cleaned;
                root.infoLoaded = true;
            }
            
            var isReady = root.displayMode === "logo" ? root.logoLoaded : (root.displayMode === "info" ? root.infoLoaded : (root.logoLoaded && root.infoLoaded));
            
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
            
            // LOGO SECTION
            Item {
                visible: root.displayMode !== "info"
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
                    radius: 8   // Inner glow (Sharp)
                    samples: 16
                }

                DropShadow {
                    anchors.fill: logoText
                    source: logoText
                    transparentBorder: true
                    color: root.themeColor
                    radius: 25  // Outer glow (Aura)
                    samples: 30
                    opacity: 0.6
                }
            }

            // INFO SECTION
            Item {
                visible: root.displayMode === "full" || root.displayMode === "info"
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
                    radius: 6   // Inner glow
                    samples: 12
                }

                DropShadow {
                    anchors.fill: infoText
                    source: infoText
                    transparentBorder: true
                    color: root.themeColor
                    radius: 20  // Outer glow
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
        duration: introDuration // Faster fade in
        easing.type: Easing.InOutQuad
    }

    OpacityAnimator {
        id: exitAnimation
        target: root
        from: 1
        to: 0
        duration: exitDuration // Smoother fade out
        easing.type: Easing.InOutQuad
    }

    Component.onCompleted: {
        executable.exec("fastfetch --structure L --pipe")
        if (root.displayMode === "full" || root.displayMode === "info") {
            executable.exec("fastfetch --logo none --pipe")
        }
    }
}
