import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.widgets.settings

ContentPage {
    id: page;
    readonly property int index: 4
    property bool register: parent.register ?? false
    forceWidth: true

    ContentSection {
        icon: "album"
        title: "Media"

        ContentSubsection {
            title: "Prioritized player"
            tooltip: "Automatically sets the active player to a newly detected player if its identifier matches the value specified in the priority player property so you dont have to manually set the active player"

            MaterialTextArea {
                Layout.fillWidth: true
                placeholderText: "Desktop entry name (e.g. spotify, google-chrome)"
                text: Config.options.media.priorityPlayer
                wrapMode: TextEdit.NoWrap
                onTextChanged: {
                    Config.options.media.priorityPlayer = text;
                }
            }
        }

        ConfigSwitch {
            buttonIcon: "filter_list"
            text: "Filter duplicate players"
            checked: Config.options.media.filterDuplicatePlayers
            onCheckedChanged: {
                Config.options.media.filterDuplicatePlayers = checked;
            }
            StyledToolTip {
                text: "Attempt to remove dupes (the aggregator playerctl one and browsers' native ones when there's plasma browser integration)"
            }
        }

    }

    ContentSection {
        icon: "cell_tower"
        title: "Networking"

        MaterialTextArea {
            Layout.fillWidth: true
            placeholderText: "User agent (for services that require it)"
            text: Config.options.networking.userAgent
            wrapMode: TextEdit.Wrap
            onTextChanged: {
                Config.options.networking.userAgent = text;
            }
        }
    }

    ContentSection {
        icon: "memory"
        title: "Resources"

        ConfigSpinBox {
            icon: "av_timer"
            text: "Polling interval (ms)"
            value: Config.options.resources.updateInterval
            from: 100
            to: 10000
            stepSize: 100
            onValueChanged: {
                Config.options.resources.updateInterval = value;
            }
        }
        
    }

    ContentSection {
        icon: "file_open"
        title: "Save paths"
        
        MaterialTextArea {
            Layout.fillWidth: true
            placeholderText: "Video Recording Path"
            text: Config.options.screenRecord.savePath
            wrapMode: TextEdit.Wrap
            onTextChanged: {
                Config.options.screenRecord.savePath = text;
            }
        }
        
        MaterialTextArea {
            Layout.fillWidth: true
            placeholderText: "Screenshot Path (leave empty to just copy)"
            text: Config.options.screenSnip.savePath
            wrapMode: TextEdit.Wrap
            onTextChanged: {
                Config.options.screenSnip.savePath = text;
            }
        }
    }

    ContentSection {
        icon: "search"
        title: "Search"

        ContentSubsection {
            title: "Prefixes"
            ConfigRow {
                uniform: true
                MaterialTextArea {
                    Layout.fillWidth: true
                    placeholderText: "Action"
                    text: Config.options.search.prefix.action
                    wrapMode: TextEdit.Wrap
                    onTextChanged: {
                        Config.options.search.prefix.action = text;
                    }
                }
                MaterialTextArea {
                    Layout.fillWidth: true
                    placeholderText: "Clipboard"
                    text: Config.options.search.prefix.clipboard
                    wrapMode: TextEdit.Wrap
                    onTextChanged: {
                        Config.options.search.prefix.clipboard = text;
                    }
                }
                MaterialTextArea {
                    Layout.fillWidth: true
                    placeholderText: "Emojis"
                    text: Config.options.search.prefix.emojis
                    wrapMode: TextEdit.Wrap
                    onTextChanged: {
                        Config.options.search.prefix.emojis = text;
                    }
                }
            }

            ConfigRow {
                uniform: true
                MaterialTextArea {
                    Layout.fillWidth: true
                    placeholderText: "Math"
                    text: Config.options.search.prefix.math
                    wrapMode: TextEdit.Wrap
                    onTextChanged: {
                        Config.options.search.prefix.math = text;
                    }
                }
                MaterialTextArea {
                    Layout.fillWidth: true
                    placeholderText: "Shell command"
                    text: Config.options.search.prefix.shellCommand
                    wrapMode: TextEdit.Wrap
                    onTextChanged: {
                        Config.options.search.prefix.shellCommand = text;
                    }
                }
                MaterialTextArea {
                    Layout.fillWidth: true
                    placeholderText: "Web search"
                    text: Config.options.search.prefix.webSearch
                    wrapMode: TextEdit.Wrap
                    onTextChanged: {
                        Config.options.search.prefix.webSearch = text;
                    }
                }
                MaterialTextArea {
                    Layout.fillWidth: true
                    placeholderText: "File search"
                    text: Config.options.search.prefix.fileSearch
                    wrapMode: TextEdit.Wrap
                    onTextChanged: {
                        Config.options.search.prefix.fileSearch = text;
                    }
                }
            }
        }
        ContentSubsection {
            title: "Web search"
            MaterialTextArea {
                Layout.fillWidth: true
                placeholderText: "Base URL"
                text: Config.options.search.engineBaseUrl
                wrapMode: TextEdit.Wrap
                onTextChanged: {
                    Config.options.search.engineBaseUrl = text;
                }
            }
        }
        ContentSubsection {
            title: "File search"

            MaterialTextArea {
                Layout.fillWidth: true
                placeholderText: "Search directory"
                text: Config.options.search.fileSearchDirectory
                wrapMode: TextEdit.Wrap
                onTextChanged: {
                    Config.options.search.fileSearchDirectory = text;
                }
            }

            ConfigSwitch {
                buttonIcon: "hide_image"
                text: "Blur file search result previews"
                checked: Config.options.search.blurFileSearchResultPreviews
                onCheckedChanged: {
                    Config.options.search.blurFileSearchResultPreviews = checked;
                }
            }

        }
    }

    // There's no update indicator in ii for now so we shouldn't show this yet
    // ContentSection {
    //     icon: "deployed_code_update"
    //     title: "System updates (Arch only)"

    //     ConfigSwitch {
    //         text: "Enable update checks"
    //         checked: Config.options.updates.enableCheck
    //         onCheckedChanged: {
    //             Config.options.updates.enableCheck = checked;
    //         }
    //     }

    //     ConfigSpinBox {
    //         icon: "av_timer"
    //         text: "Check interval (mins)"
    //         value: Config.options.updates.checkInterval
    //         from: 60
    //         to: 1440
    //         stepSize: 60
    //         onValueChanged: {
    //             Config.options.updates.checkInterval = value;
    //         }
    //     }
    // }

    ContentSection {
        icon: "weather_mix"
        title: "Weather"
        ConfigRow {
            ConfigSwitch {
                buttonIcon: "assistant_navigation"
                text: "Enable GPS based location"
                checked: Config.options.bar.weather.enableGPS
                onCheckedChanged: {
                    Config.options.bar.weather.enableGPS = checked;
                }
            }
            ConfigSwitch {
                buttonIcon: "thermometer"
                text: "Fahrenheit unit"
                checked: Config.options.bar.weather.useUSCS
                onCheckedChanged: {
                    Config.options.bar.weather.useUSCS = checked;
                }
                StyledToolTip {
                    text: "It may take a few seconds to update"
                }
            }
        }
        
        MaterialTextArea {
            Layout.fillWidth: true
            placeholderText: "City name"
            text: Config.options.bar.weather.city
            wrapMode: TextEdit.Wrap
            onTextChanged: {
                Config.options.bar.weather.city = text;
            }
        }
        ConfigSpinBox {
            icon: "av_timer"
            text: "Polling interval (m)"
            value: Config.options.bar.weather.fetchInterval
            from: 5
            to: 50
            stepSize: 5
            onValueChanged: {
                Config.options.bar.weather.fetchInterval = value;
            }
        }
    }
}