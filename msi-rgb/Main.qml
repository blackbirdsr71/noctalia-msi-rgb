import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

Item {
    id: root

    property var pluginApi: null

    property bool isApplying: false
    property string lastError: ""

    readonly property var cfg: pluginApi?.pluginSettings || ({})
    readonly property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})
    readonly property string model: cfg.model ?? defaults.model ?? "GS65"

    // Aplica un color solido (hex "#rrggbb" o "rrggbb")
    function applySteady(hex) {
        const clean = String(hex).replace("#", "")
        isApplying = true
        lastError = ""
        rgbProcess.command = ["msi-perkeyrgb", "-m", root.model, "-s", clean]
        rgbProcess.running = true
    }

    // Aplica un efecto (preset) por nombre
    function applyEffect(effectName) {
        isApplying = true
        lastError = ""
        rgbProcess.command = ["msi-perkeyrgb", "-m", root.model, "-p", String(effectName)]
        rgbProcess.running = true
    }

    // Apaga el teclado (color negro)
    function turnOff() {
        applySteady("000000")
    }

    Process {
        id: rgbProcess
        stderr: StdioCollector { id: rgbStderr }
        running: false

        onExited: function(exitCode, exitStatus) {
            if (exitCode !== 0) {
                root.lastError = (rgbStderr.text || "").trim() || ("exit " + exitCode)
                Logger.e("MSI RGB", "msi-perkeyrgb fallo: " + root.lastError)
            } else {
                Logger.d("MSI RGB", "Aplicado OK")
            }
            root.isApplying = false
        }
    }

    // Aplica la configuracion guardada
    function applySaved() {
        const c = pluginApi?.pluginSettings
        if (!c) return
        if ((c.mode ?? "steady") === "effect") {
            applyEffect(c.effect ?? defaults.effect ?? "rainbow-split")
        } else {
            applySteady(c.color ?? defaults.color ?? "#ff00ff")
        }
    }

    // IPC: permite controlar desde atajos de Niri (qs -c noctalia-shell ipc call plugin:msi-rgb ...)
    IpcHandler {
        target: "plugin:msi-rgb"

        function setColorHex(hex: string): void {
            root.applySteady(hex)
        }
        function setEffect(name: string): void {
            root.applyEffect(name)
        }
        function off(): void {
            root.turnOff()
        }
        function applySaved(): void {
            root.applySaved()
        }
    }

    Component.onCompleted: {
        // Al iniciar, aplica lo ultimo guardado
        if (pluginApi) root.applySaved()
    }
}
