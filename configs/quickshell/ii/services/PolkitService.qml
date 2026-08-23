pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Polkit

Singleton {
    id: root
    property alias active: polkitAgent.isActive
    property alias flow: polkitAgent.flow
    property bool interactionAvailable: false
    property bool isError: false
    readonly property string supplementaryMessage: flow?.supplementaryMessage ?? ""
    readonly property bool supplementaryIsError: flow?.supplementaryIsError ?? false
    property string cleanMessage: {
        if (!root.flow) return "";
        return root.flow.message.endsWith(".")
            ? root.flow.message.slice(0, -1)
            : root.flow.message
    }
    property string cleanPrompt: {
        const inputPrompt = PolkitService.flow?.inputPrompt.trim() ?? "";
        const cleanedInputPrompt = inputPrompt.endsWith(":") ? inputPrompt.slice(0, -1) : inputPrompt;
        const usePasswordChars = !PolkitService.flow?.responseVisible ?? true
        return cleanedInputPrompt || (usePasswordChars ? "Password" : "Input")
    }

    function cancel() {
        root.isError = false;
        root.flow.cancelAuthenticationRequest()
    }

    function submit(string) {
        root.isError = false;
        root.flow.submit(string)
        root.interactionAvailable = false
    }

    Connections {
        target: root.flow
        function onAuthenticationFailed() {
            root.interactionAvailable = true;
            root.isError = true;
        }
    }

    PolkitAgent {
        id: polkitAgent
        onAuthenticationRequestStarted: {
            root.interactionAvailable = true;
            root.isError = false;
        }
    }
}
