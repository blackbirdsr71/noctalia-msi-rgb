import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

ColumnLayout {
    id: root
    property var pluginApi: null

    readonly property var cfg: pluginApi?.pluginSettings || ({})
    readonly property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

    property string valueModel: cfg.model ?? defaults.model ?? "GS65"
    property string valueColor: cfg.color ?? defaults.color ?? "#ff00ff"
    property string valueMode: cfg.mode ?? defaults.mode ?? "steady"
    property string valueEffect: cfg.effect ?? defaults.effect ?? "rainbow-split"
    property bool valueColorIcon: cfg.colorIcon ?? defaults.colorIcon ?? true

    readonly property var mainInstance: pluginApi?.mainInstance

    // Lista de efectos disponibles (presets de msi-perkeyrgb para GS65)
    readonly property var effectList: [
        "aqua", "chakra", "default", "disco", "drain",
        "freeway", "plain", "rainbow-split", "roulette"
    ]

    spacing: Style.marginL

    // --- Seccion COLOR FIJO ---
    NText {
        text: "Color fijo"
        pointSize: Style.fontSizeM
        font.weight: Font.Bold
        color: Color.mOnSurface
    }

    NColorPicker {
        Layout.fillWidth: true
        selectedColor: root.valueColor
        onColorSelected: color => {
            root.valueColor = color
            root.valueMode = "steady"
            // Aplica en vivo
            mainInstance?.applySteady(color)
        }
    }

    NDivider { Layout.fillWidth: true }

    // --- Seccion EFECTOS ---
    NText {
        text: "Efectos"
        pointSize: Style.fontSizeM
        font.weight: Font.Bold
        color: Color.mOnSurface
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 3
        rowSpacing: Style.marginS
        columnSpacing: Style.marginS

        Repeater {
            model: root.effectList
            delegate: NButton {
                required property string modelData
                Layout.fillWidth: true
                text: modelData
                // Resalta el efecto activo
                highlighted: root.valueMode === "effect" && root.valueEffect === modelData
                onClicked: {
                    root.valueEffect = modelData
                    root.valueMode = "effect"
                    // Aplica en vivo
                    mainInstance?.applyEffect(modelData)
                }
            }
        }
    }

    NDivider { Layout.fillWidth: true }

    // --- Boton APAGAR ---
    NButton {
        Layout.fillWidth: true
        text: "Apagar teclado"
        icon: "power"
        onClicked: {
            root.valueColor = "#000000"
            root.valueMode = "steady"
            mainInstance?.turnOff()
        }
    }

    NDivider { Layout.fillWidth: true }

    // --- Ajustes ---
    NText {
        text: "Ajustes"
        pointSize: Style.fontSizeM
        font.weight: Font.Bold
        color: Color.mOnSurface
    }

    NToggle {
        Layout.fillWidth: true
        label: "Icono coloreado"
        description: "El icono de la barra toma el color actual"
        checked: root.valueColorIcon
        onToggled: checked => root.valueColorIcon = checked
    }

    // Modelo (por si el default GS65 no anda, se puede cambiar)
    NText {
        text: "Modelo msi-perkeyrgb: " + root.valueModel
        pointSize: Style.fontSizeS
        color: Color.mSecondary
    }

    NBox {
        Layout.fillWidth: true
        implicitHeight: infoCol.implicitHeight + Style.marginXL

        ColumnLayout {
            id: infoCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Style.marginM
            spacing: Style.marginS

            NText {
                text: "Requiere msi-perkeyrgb instalado y permiso sudo NOPASSWD para /usr/bin/msi-perkeyrgb."
                pointSize: Style.fontSizeS
                color: Color.mOnSurface
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }
            NText {
                text: "Teclado SteelSeries per-key. Modelo GS65 funciona en MSI Stealth 16."
                pointSize: Style.fontSizeS
                color: Color.mSecondary
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }
        }
    }

    // Guardado (lo llama Noctalia al cerrar/guardar)
    function saveSettings() {
        if (!pluginApi) return
        pluginApi.pluginSettings.model = root.valueModel
        pluginApi.pluginSettings.color = root.valueColor
        pluginApi.pluginSettings.mode = root.valueMode
        pluginApi.pluginSettings.effect = root.valueEffect
        pluginApi.pluginSettings.colorIcon = root.valueColorIcon
        pluginApi.saveSettings()
        // Reaplica lo elegido
        mainInstance?.applySaved()
    }
}
