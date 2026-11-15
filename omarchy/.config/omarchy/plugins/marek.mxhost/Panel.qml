import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// MX Master 4 Easy-Switch: bar icon for "here / away", a panel to send the
// mouse to another channel (via mx-host), and a switch for sharing the mouse
// with the Windows laptop over lan-mouse (via lan-mouse-auto).
Panel {
  id: root
  moduleName: "marek.mxhost"
  ipcTarget: "marek.mxhost"

  readonly property string helper: Quickshell.env("HOME") + "/.local/bin/mx-host"
  readonly property string shareHelper: Quickshell.env("HOME") + "/.local/bin/lan-mouse-auto"
  readonly property color foreground: root.bar ? root.bar.foreground : Commons.Color.foreground
  readonly property color dim: Qt.darker(foreground, 1.4)

  property bool connected: false
  property int current: 0
  property int here: 0
  property int awayTo: 0
  property int count: 3
  property var names: ({})
  property string error: ""
  property bool switching: false
  property bool shareEnabled: true
  property bool sharePresent: false
  property bool shareActive: false
  property string shareName: "Windows laptop"
  property int cursorIndex: 0
  property bool cursorActive: false

  readonly property string icon: connected ? "󰍽" : "󰍾"

  readonly property string statusText: {
    if (switching) return "Switching…"
    if (connected) return "On this computer · device " + current
    if (awayTo > 0) return "Away · on " + channelLabel(awayTo)
    return "Not connected"
  }

  readonly property string tooltip: connected
    ? "MX Master 4 · " + channelLabel(current)
    : "MX Master 4 · " + (awayTo > 0 ? "away on " + channelLabel(awayTo) : "not connected")
  readonly property string fullTooltip: tooltip + (shareActive ? "\nSharing with " + shareName + " (lan-mouse)" : "")

  function hostName(channel) {
    var name = names[String(channel)]
    return name ? String(name).slice(0, 48) : ""
  }

  function channelLabel(channel) {
    return hostName(channel) || "device " + channel
  }

  function buttonText(channel) {
    var text = hostName(channel) ? channel + "   " + hostName(channel) : "Device " + channel
    return channel === here ? text + "  (this computer)" : text
  }

  readonly property string shareText: {
    if (!shareEnabled) return "Off · the right screen edge is just an edge"
    if (shareActive) return "On · cross the right screen edge to reach " + shareName
    return "Waiting for " + shareName + " to join the network"
  }

  function applyShare(raw) {
    var state
    try { state = JSON.parse(String(raw || "")) } catch (e) { return }
    if (!state || typeof state !== "object") return
    shareEnabled = state.mode !== "off"
    sharePresent = state.present === true
    shareActive = state.active === true
    shareName = typeof state.name === "string" && state.name !== "" ? state.name.slice(0, 48) : "Windows laptop"
  }

  function toggleShare() {
    if (shareToggleProc.running) return
    shareEnabled = !shareEnabled
    shareToggleProc.command = [shareHelper, "set", shareEnabled ? "auto" : "off"]
    shareToggleProc.running = true
  }

  function activateCursor() {
    if (cursorIndex === count) toggleShare()
    else switchTo(cursorIndex + 1)
  }

  function apply(raw) {
    var state
    try { state = JSON.parse(String(raw || "")) } catch (e) { return }
    if (!state || typeof state !== "object") return
    connected = state.connected === true
    count = Math.max(1, Math.min(6, parseInt(state.count) || 3))
    current = parseInt(state.current) || 0
    here = parseInt(state.here) || 0
    awayTo = connected ? 0 : (parseInt(state.awayTo) || 0)
    names = state.names && typeof state.names === "object" ? state.names : ({})
    error = typeof state.error === "string" ? state.error.slice(0, 200) : ""
  }

  function refresh() {
    if (!statusProc.running) statusProc.running = true
    if (!shareStatusProc.running) shareStatusProc.running = true
  }

  function switchTo(channel) {
    if (!connected || switching || channel === current) return
    switching = true
    switchProc.command = [helper, "switch", String(channel)]
    switchProc.running = true
  }

  function moveCursor(delta) {
    if (!cursorActive) { cursorActive = true; return }
    cursorIndex = (cursorIndex + delta + count + 1) % (count + 1)
  }

  onOpenedChanged: {
    if (!opened) return
    refresh()
    cursorActive = false
    cursorIndex = Math.max(0, current - 1)
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Process {
    id: statusProc
    command: [root.helper, "status", "--json"]
    stdout: StdioCollector { waitForEnd: true; onStreamFinished: root.apply(text) }
  }

  Process {
    id: shareStatusProc
    command: [root.shareHelper, "status", "--json"]
    stdout: StdioCollector { waitForEnd: true; onStreamFinished: root.applyShare(text) }
  }

  Process {
    id: shareToggleProc
    onExited: root.refresh()
  }

  Process {
    id: switchProc
    onExited: {
      root.switching = false
      root.close()
      root.refresh()
    }
  }

  Timer {
    interval: root.opened ? 2000 : 6000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.icon
    opacity: root.connected ? 1.0 : 0.5
    labelText: vertical || !root.connected ? "" : String(root.current) + (root.shareActive ? " ⇄" : "")
    slotSize: Style.bar.iconSlot * (vertical || !root.connected ? 1 : root.shareActive ? 2.2 : 1.6)
    tooltipText: root.fullTooltip
    onPressed: root.toggle()
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: panel.loadedContent
    contentWidth: panel.fittedContentWidth(Style.space(340))
    contentHeight: panel.fittedContentHeight(panel.loadedContentHeight)

    content: PanelKeyCatcher {
      anchors.fill: parent
      implicitHeight: column.implicitHeight
      onMoveRequested: function(dx, dy) { root.moveCursor(dy !== 0 ? dy : dx) }
      onActivateRequested: if (root.cursorActive) root.activateCursor()
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: Style.space(14)

        PanelHero {
          width: parent.width
          title: "MX Master 4"
          meta: root.statusText.toUpperCase()
          foreground: root.foreground
          fontFamily: root.bar.fontFamily
          iconOpacity: root.connected ? 1.0 : 0.5
          iconComponent: Component {
            Text {
              textFormat: Text.PlainText
              text: root.icon
              color: root.foreground
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.display
            }
          }
        }

        PanelSeparator { foreground: root.foreground }

        Column {
          width: parent.width
          spacing: Style.space(8)

          PanelSectionHeader {
            text: "Easy-Switch"
            foreground: root.foreground
            fontFamily: root.bar.fontFamily
          }

          Repeater {
            model: root.count

            Button {
              required property int index
              readonly property int channel: index + 1
              width: parent.width
              leftAlign: true
              bordered: true
              enabled: root.connected && !root.switching
              opacity: enabled || active ? 1.0 : 0.55
              iconText: channel === root.here ? "󰌢" : "󰍹"
              iconSize: Style.font.title
              text: root.buttonText(channel)
              fontSize: Style.font.bodySmall
              foreground: root.foreground
              fontFamily: root.bar.fontFamily
              horizontalPadding: Style.spacing.controlPaddingX
              verticalPadding: Style.spacing.controlPaddingY + Style.space(2)
              active: channel === (root.connected ? root.current : root.awayTo)
              hasCursor: root.cursorActive && root.cursorIndex === index
              onClicked: root.switchTo(channel)
              onHovered: function(hovered) {
                if (!hovered) return
                root.cursorActive = true
                root.cursorIndex = index
              }
            }
          }
        }

        PanelSeparator { foreground: root.foreground }

        Column {
          width: parent.width
          spacing: Style.space(8)

          PanelSectionHeader {
            text: "Share with Windows"
            foreground: root.foreground
            fontFamily: root.bar.fontFamily
          }

          Toggle {
            width: parent.width
            label: root.shareName
            description: root.shareText
            checked: root.shareEnabled
            foreground: root.foreground
            fontFamily: root.bar.fontFamily
            titleSize: Style.font.bodySmall
            hasCursor: root.cursorActive && root.cursorIndex === root.count
            onClicked: root.toggleShare()
            onHovered: function(hovered) {
              if (!hovered) return
              root.cursorActive = true
              root.cursorIndex = root.count
            }
          }
        }

        Text {
          textFormat: Text.PlainText
          width: parent.width
          wrapMode: Text.Wrap
          text: {
            if (root.connected) return "Shortcut: MEH + 1 / 2 / 3"
            if (root.error.indexOf("permission") >= 0) return root.error
            return "The mouse is on another computer. Switch it back from there (or with its Easy-Switch button)."
          }
          color: root.dim
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.caption
        }
      }
    }
  }
}
