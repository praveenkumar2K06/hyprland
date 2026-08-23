import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.widgets.settings

ContentPage {
    id: page
    readonly property int index: 6
    forceWidth: true

    ContentSection {
        icon: "more"
        title: "Extra"

        ConfigSwitch {
            buttonIcon: "buttons_alt"
            text: "Toggle Hyprland window rounding with rounding style"
            checked: Config.options.appearance.toggleWindowRounding
            onCheckedChanged: {
                Config.options.appearance.toggleWindowRounding = checked;
            }
            StyledToolTip {
                text: "Changes the window rounding to match the selected rounding style\nSo window rounding does not look cursed on 'no rounding' mode"
            }
        }   
    }

    ContentSection {
        icon: "text_format"
        title: "Fonts"

        ConfigSwitch {
            buttonIcon: "custom_typography"
            text: "Enable custom fonts"
            checked: Config.options.appearance.fonts.enableCustom
            onCheckedChanged: {
                Config.options.appearance.fonts.enableCustom = checked;
                if (checked) {
                    Config.options.appearance.fonts.main = Persistent.states.settings.fonts.main;
                    Config.options.appearance.fonts.numbers = Persistent.states.settings.fonts.numbers;
                    Config.options.appearance.fonts.title = Persistent.states.settings.fonts.title;
                    Config.options.appearance.fonts.monospace = Persistent.states.settings.fonts.monospace;
                    Config.options.appearance.fonts.iconNerd = Persistent.states.settings.fonts.iconNerd;
                    Config.options.appearance.fonts.reading = Persistent.states.settings.fonts.reading;
                    Config.options.appearance.fonts.expressive = Persistent.states.settings.fonts.expressive;
                } else {
                    Config.options.appearance.fonts.main = "Google Sans Flex";
                    Config.options.appearance.fonts.numbers = "Google Sans Flex";
                    Config.options.appearance.fonts.title = "Google Sans Flex";
                    Config.options.appearance.fonts.iconNerd = "JetBrains Mono NF";
                    Config.options.appearance.fonts.monospace = "JetBrains Mono NF";
                    Config.options.appearance.fonts.reading = "Readex Pro";
                    Config.options.appearance.fonts.expressive = "Space Grotesk";
                }
            }
        }

        ContentSubsection {
            title: "Main font"
            tooltip: "Used for general UI text"

            MaterialTextArea {
                enabled: Config.options.appearance.fonts.enableCustom
                Layout.fillWidth: true
                placeholderText: "Font family name (e.g., Google Sans Flex)"
                text: Persistent.states.settings.fonts.main
                wrapMode: TextEdit.NoWrap
                onTextChanged: {
                    if (!enabled) return
                    Persistent.states.settings.fonts.main = text;
                    Config.options.appearance.fonts.main = text;
                }
            }
        }

        ContentSubsection {
            title: "Numbers font"
            tooltip: "Used for displaying numbers"

            MaterialTextArea {
                enabled: Config.options.appearance.fonts.enableCustom
                Layout.fillWidth: true
                placeholderText: "Font family name"
                text: Persistent.states.settings.fonts.numbers
                wrapMode: TextEdit.NoWrap
                onTextChanged: {
                    if (!enabled) return
                    Persistent.states.settings.fonts.numbers = text;
                    Config.options.appearance.fonts.numbers = text;
                }
            }
        }

        ContentSubsection {
            title: "Title font"
            tooltip: "Used for headings and titles"

            MaterialTextArea {
                enabled: Config.options.appearance.fonts.enableCustom
                Layout.fillWidth: true
                placeholderText: "Font family name"
                text: Persistent.states.settings.fonts.title
                wrapMode: TextEdit.NoWrap
                onTextChanged: {
                    if (!enabled) return
                    Persistent.states.settings.fonts.title = text;
                    Config.options.appearance.fonts.title = text;
                }
            }
        }

        ContentSubsection {
            title: "Monospace font"
            tooltip: "Used for code and terminal"

            MaterialTextArea {
                enabled: Config.options.appearance.fonts.enableCustom
                Layout.fillWidth: true
                placeholderText: "Font family name (e.g., JetBrains Mono NF)"
                text: Persistent.states.settings.fonts.monospace
                wrapMode: TextEdit.NoWrap
                onTextChanged: {
                    if (!enabled) return
                    Persistent.states.settings.fonts.monospace = text;
                    Config.options.appearance.fonts.monospace = text;
                }
            }
        }

        ContentSubsection {
            title: "Nerd font icons"
            tooltip: "Font used for Nerd Font icons"

            MaterialTextArea {
                enabled: Config.options.appearance.fonts.enableCustom
                Layout.fillWidth: true
                placeholderText: "Font family name (e.g., JetBrains Mono NF)"
                text: Persistent.states.settings.fonts.iconNerd
                wrapMode: TextEdit.NoWrap
                onTextChanged: {
                    if (!enabled) return
                    Persistent.states.settings.fonts.iconNerd = text;
                    Config.options.appearance.fonts.iconNerd = text;
                }
            }
        }

        ContentSubsection {
            title: "Reading font"
            tooltip: "Used for reading large blocks of text"

            MaterialTextArea {
                enabled: Config.options.appearance.fonts.enableCustom
                Layout.fillWidth: true
                placeholderText: "Font family name (e.g., Readex Pro)"
                text: Persistent.states.settings.fonts.reading
                wrapMode: TextEdit.NoWrap
                onTextChanged: {
                    if (!enabled) return
                    Persistent.states.settings.fonts.reading = text;
                    Config.options.appearance.fonts.reading = text;
                }
            }
        }

        ContentSubsection {
            title: "Expressive font"
            tooltip: "Used for decorative/expressive text"

            MaterialTextArea {
                enabled: Config.options.appearance.fonts.enableCustom
                Layout.fillWidth: true
                placeholderText: "Font family name (e.g., Space Grotesk)"
                text: Persistent.states.settings.fonts.expressive
                wrapMode: TextEdit.NoWrap
                onTextChanged: {
                    if (!enabled) return
                    Persistent.states.settings.fonts.expressive = text;
                    Config.options.appearance.fonts.expressive = text;
                }
            }
        }
    }
}