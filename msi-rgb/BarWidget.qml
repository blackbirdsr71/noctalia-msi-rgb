import QtQuick
import Quickshell
import qs.Commons
import qs.Services.UI
import qs.Widgets

Item {
    id: root

    // Propiedades inyectadas por Noctalia
    property var pluginApi: null
    property ShellScreen screen
    property string widgetId: ""
    property string section: ""
    property int sectionWidgetIndex: -1
    property int sectionWidgetsCount: 0

    // Layout de la barra
    readonly property string screenName: screen?.name ?? ""
    readonly property string barPosition: Settings.getBarPositionForScreen(screenName)
    readonly property bool isVertical: barPosition === "left" || barPosition === "right"
    readonly property real capsuleHeight: Style.getCapsuleHeightForScreen(screenName)

    // Config
    readonly property var cfg: pluginApi?.pluginSettings || ({})
    readonly property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})
    readonly property string currentColor: cfg.color ?? defaults.color ?? "#ff00ff"
    readonly property bool colorIcon: cfg.colorIcon ?? defaults.colorIcon ?? true

    // Estado desde Main.qml
    readonly property var mainInstance: pluginApi?.mainInstance
    readonly property bool isApplying: mainInstance?.isApplying ?? false

    implicitWidth: isVertical ? capsuleHeight : contentWidth
    implicitHeight: isVertical ? contentHeight : capsuleHeight

    readonly property real iconSize: Style.toOdd(capsuleHeight * 0.55)
    readonly property real contentWidth: Style.marginM * 2 + iconSize
    readonly property real contentHeight: capsuleHeight

    Rectangle {
        id: capsule
        x: Style.pixelAlignCenter(parent.width, width)
        y: Style.pixelAlignCenter(parent.height, height)
        width: root.contentWidth
        height: root.contentHeight
        radius: Style.radiusL
        color: Style.capsuleColor
        border.color: Style.capsuleBorderColor
        border.width: Style.capsuleBorderWidth

        NIcon {
            id: mainIcon
            visible: !root.isApplying
            anchors.centerIn: parent
            icon: "keyboard"
            pointSize: root.iconSize
            color: root.colorIcon ? Qt.color(root.currentColor) : Color.mPrimary
        }

        NBusyIndicator {
            visible: root.isApplying
            running: root.isApplying
            anchors.centerIn: parent
            implicitWidth: root.iconSize
            implicitHeight: root.iconSize
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onClicked: mouse => {
                if (mouse.button === Qt.LeftButton) {
                    // Click izquierdo: abre settings (color picker + efectos)
                    BarService.openPluginSettings(root.screen, pluginApi.manifest)
                } else if (mouse.button === Qt.RightButton) {
                    // Click derecho: menu rapido de efectos y apagar
                    PanelService.showContextMenu(contextMenu, root, screen)
                }
            }

            onEntered: {
                let text = pluginApi?.tr("bar.tooltip") ?? "Teclado RGB"
                if (mainInstance?.lastError) text += "\n" + mainInstance.lastError
                TooltipService.show(root, text, BarService.getTooltipDirection(root.screen?.name))
            }
            onExited: TooltipService.hide()
        }
    }

    // Menu rapido con click derecho: efectos + apagar
    NPopupContextMenu {
        id: contextMenu
        model: [
            { "label": "Rainbow", "action": "fx:rainbow-split", "icon": "palette" },
            { "label": "Aqua", "action": "fx:aqua", "icon": "palette" },
            { "label": "Disco", "action": "fx:disco", "icon": "palette" },
            { "label": "Drain", "action": "fx:drain", "icon": "palette" },
            { "label": "Roulette", "action": "fx:roulette", "icon": "palette" },
            { "label": pluginApi?.tr("menu.off") ?? "Apagar", "action": "off", "icon": "power" },
            { "label": pluginApi?.tr("menu.settings") ?? "Configuracion", "action": "settings", "icon": "settings" }
        ]
        onTriggered: action => {
            contextMenu.close()
            PanelService.closeContextMenu(screen)
            if (action === "settings") {
                BarService.openPluginSettings(root.screen, pluginApi.manifest)
            } else if (action === "off") {
                mainInstance?.turnOff()
            } else if (action.startsWith("fx:")) {
                mainInstance?.applyEffect(action.substring(3))
            }
        }
    }
}
