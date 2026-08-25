pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common.functions as CF
import qs.modules.common
import qs.services
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import qs.services.ai

/**
 * Basic service to handle LLM chats. Supports Google's and OpenAI's API formats.
 * Supports Gemini and OpenAI models.
 * Limitations:
 * - For now functions only work with Gemini API format
 */
Singleton {
    id: root

    property Component aiMessageComponent: AiMessageData {}
    property Component aiModelComponent: AiModel {}
    property Component geminiApiStrategy: GeminiApiStrategy {}
    property Component openaiApiStrategy: OpenAiApiStrategy {}
    readonly property string interfaceRole: "interface"
    readonly property string apiKeyEnvVarName: "API_KEY"

    property string systemPrompt: {
        let prompt = Config.options?.ai?.systemPrompt ?? "";
        for (let key in root.promptSubstitutions) {
            prompt = prompt.split(key).join(root.promptSubstitutions[key]);
        }
        return prompt;
    }
    property var messageIDs: []
    property var messageByID: ({})
    readonly property var apiKeys: KeyringStorage.keyringData?.apiKeys ?? {}
    readonly property var apiKeysLoaded: KeyringStorage.loaded
    readonly property bool currentModelHasApiKey: {
        const model = models[currentModelId];
        if (!model || !model.requires_key) return true;
        if (!apiKeysLoaded) return false;
        const key = apiKeys[model.key_id];
        return (key?.length > 0);
    }
    property var postResponseHook
    property real temperature: Persistent.states?.ai?.temperature ?? 0.5
    property QtObject tokenCount: QtObject {
        property int input: -1
        property int output: -1
        property int total: -1
    }

    function idForMessage(message) {
        return Date.now().toString(36) + Math.random().toString(36).substr(2, 8);
    }

    function safeModelName(modelName) {
        return modelName.replace(/:/g, "_").replace(/ /g, "-").replace(/\//g, "-")
    }

    property list<var> savedChats: []

    property var promptSubstitutions: {
        "{DISTRO}": SystemInfo.distroName,
        "{DATETIME}": `${DateTime.time}, ${DateTime.collapsedCalendarFormat}`,
        "{WINDOWCLASS}": ToplevelManager.activeToplevel?.appId ?? "Unknown",
        "{DE}": `${SystemInfo.desktopEnvironment} (${SystemInfo.windowingSystem})` 
    }

    // Gemini: https://ai.google.dev/gemini-api/docs/function-calling
    // OpenAI: https://platform.openai.com/docs/guides/function-calling
    property string currentTool: Config?.options.ai.tool ?? "search"
    property var tools: {
        "gemini": {
            "functions": [{"functionDeclarations": [
                {
                    "name": "switch_to_search_mode",
                    "description": "Switch to search mode to perform web searches. Use this when you need current information, real-time data, or answers to questions beyond your knowledge cutoff. After switching, continue with the user's original request.",
                },
                {
                    "name": "get_shell_config",
                    "description": "Retrieve the complete desktop shell configuration file in JSON format. Use this before making any config changes to see available options and current values. Returns the full config structure. Dont ask for permission, run directly.",
                },
                {
                    "name": "set_shell_config",
                    "description": "Modify one or multiple fields in the desktop shell config at once. CRITICAL: You MUST call get_shell_config first to see available keys - never guess key names. Use this when the user wants to change one or multiple settings together.",
                    "parameters": {
                        "type": "object",
                        "properties": {
                            "changes": {
                                "type": "array",
                                "description": "Array of config changes to apply",
                                "items": {
                                    "type": "object",
                                    "properties": {
                                        "key": {
                                            "type": "string",
                                            "description": "The key to set (e.g., 'bar.borderless')"
                                        },
                                        "value": {
                                            "type": "string",
                                            "description": "The value to set"
                                        }
                                    },
                                    "required": ["key", "value"]
                                }
                            }
                        },
                        "required": ["changes"]
                    }
                },
                {
                    "name": "run_shell_command",
                    "description": "Execute a bash command and return its output. IMPORTANT: This requires user approval before execution. Only use for quick, non-interactive commands (queries, checks, simple operations). For interactive commands, long-running processes, or dangerous operations, ask the user to run them manually instead. The command will be shown to the user for approval.",
                    "parameters": {
                        "type": "object",
                        "properties": {
                            "command": {
                                "type": "string",
                                "description": "The bash command to run",
                            },
                        },
                        "required": ["command"]
                    }
                },
            ]}],
            "search": [{
                "google_search": {}
            }],
            "none": []
        },
        "openai": {
            "functions": [
                {
                    "type": "function",
                    "function": {
                        "name": "get_shell_config",
                        "description": "Get the desktop shell config file contents",
                        "parameters": {}
                    },
                },
                {
                    "type": "function",
                    "function": {
                        "name": "set_shell_config",
                        "description": "Set a field in the desktop graphical shell config file. Must only be used after `get_shell_config`.",
                        "parameters": {
                            "type": "object",
                            "properties": {
                                "key": {
                                    "type": "string",
                                    "description": "The key to set, e.g. `bar.borderless`. MUST NOT BE GUESSED, use `get_shell_config` to see what keys are available before setting.",
                                },
                                "value": {
                                    "type": "string",
                                    "description": "The value to set, e.g. `true`"
                                }
                            },
                            "required": ["key", "value"]
                        }
                    }
                },
                {
                    "type": "function",
                    "function": {
                        "name": "run_shell_command",
                        "description": "Run a shell command in bash and get its output. Use this only for quick commands that don't require user interaction. For commands that require interaction, ask the user to run manually instead.",
                        "parameters": {
                            "type": "object",
                            "properties": {
                                "command": {
                                    "type": "string",
                                    "description": "The bash command to run",
                                },
                            },
                            "required": ["command"]
                        }
                    },
                },
            ],
            "search": [],
            "none": [],
        },
    }
    property list<var> availableTools: Object.keys(root.tools[models[currentModelId]?.api_format]) ?? []
    property var toolDescriptions: {
        "functions": "Commands, edit configs, search.\nTakes an extra turn to switch to search mode if that's needed",
        "search": "Gives the model search capabilities (immediately)",
        "none": "Disable tools"
    }

    readonly property string currentModel: Persistent.states.ai.model
    property var models: {
        "openrouter": aiModelComponent.createObject(this, {
            "name": `OpenRouter - ${currentModel}`,
            "icon": "openrouter-symbolic",
            "description": `Online via OpenRouter | ${getModelProvider(Persistent.states.ai.provider, currentModel) ?? "community"}'s model`,
            "homepage": `https://openrouter.ai/${getModelProvider(Persistent.states.ai.provider, currentModel) ?? ""}/${currentModel}`, 
            "endpoint": "https://openrouter.ai/api/v1/chat/completions",
            "model": `${getModelProvider(Persistent.states.ai.provider,currentModel)}/${currentModel}`,
            "requires_key": true,
            "key_id": "openrouter",
            "key_get_link": "https://openrouter.ai/settings/keys",
            "key_get_description": "**Pricing**: Pay-as-you-go (token based).\n\n" +
                "**Instructions**: Log into your OpenRouter account, " +
                "go to Keys in the top-right menu, and create an API key.",
        }),
        "google": aiModelComponent.createObject(this, {
            "name": `Google - ${currentModel}`,
            "icon": "google-gemini-symbolic",
            "description": "Online | Google's model\nNewer model that's slower than its predecessor but should deliver higher quality answers",
            "homepage": "https://aistudio.google.com",
            "endpoint": `https://generativelanguage.googleapis.com/v1beta/models/${currentModel}:streamGenerateContent`,
            "model": `${currentModel}`,
            "requires_key": true,
            "key_id": "gemini",
            "key_get_link": "https://aistudio.google.com/app/apikey",
            "key_get_description": "**Pricing**: free. Data used for training.\n\n**Instructions**: Log into Google account, allow AI Studio to create Google Cloud project or whatever it asks, go back and click Get API key",
            "api_format": "gemini",
        }),
    }

    property var modelList: Object.keys(root.models)
    property var currentModelId: {
        const provider = Persistent.states?.ai?.provider;
        return (provider && root.models[provider] !== undefined) ? provider : modelList[0];
    }

    property var baseModels: {
        "openrouter": [
            {title: "Ox Alpha (Free)", value: "ox-alpha", modelProvider: "stealth"},
            {title: "Gemini 3.7 Flash", value: "gemini-3.7-flash", modelProvider: "google"},
            {title: "Gemini 3.6 Flash", value: "gemini-3.6-flash", modelProvider: "google"},
            {title: "Gemini 3.5 Flash", value: "gemini-3.5-flash", modelProvider: "google"},
            {title: "Gemini 3.5 Flash-Lite", value: "gemini-3.5-flash-lite", modelProvider: "google"},
            {title: "Gemini 3.1 Pro Preview", value: "gemini-3.1-pro-preview", modelProvider: "google"},
            {title: "GLM 5.2 (Free)", value: "glm-5.2:free", modelProvider: "z-ai"},
            {title: "Inkling (Free)", value: "inkling:free", modelProvider: "thinkingmachines"},
            {title: "Inkling Small (Free)", value: "inkling-small:free", modelProvider: "thinkingmachines"},
            {title: "Nemotron 3 Ultra (Free)", value: "nemotron-3-ultra-550b-a55b:free", modelProvider: "nvidia"},
            {title: "Nemotron 3 Super (Free)", value: "nemotron-3-super-120b-a12b:free", modelProvider: "nvidia"},
            {title: "Nemotron 3 Nano Omni (Free)", value: "nemotron-3-nano-omni-30b-a3b-reasoning:free", modelProvider: "nvidia"},
            {title: "Nemotron 3.5 Lightning (Free)", value: "nemotron-3.5-lightning:free", modelProvider: "nvidia"},
            {title: "Gemma 4 31B (Free)", value: "gemma-4-31b-it:free", modelProvider: "google"},
            {title: "Gemma 4 26B A4B (Free)", value: "gemma-4-26b-a4b-it:free", modelProvider: "google"},
            {title: "LFM 2.5 (Free)", value: "lfm-2.5-2.6b:free", modelProvider: "liquid"},
            {title: "North Mini Code (Free)", value: "north-mini-code:free", modelProvider: "cohere"},
            {title: "Laguna S 2.1 (Free)", value: "laguna-s-2.1:free", modelProvider: "poolside"},
            {title: "Laguna XS 2.1 (Free)", value: "laguna-xs-2.1:free", modelProvider: "poolside"},
            {title: "Dots3 Note Preview (Free)", value: "dots-3-note-preview:free", modelProvider: "dots-studio"}
        ],
        "google": [
            { title: "Gemini 3.7 Flash", value: "gemini-3.7-flash" },
            { title: "Gemini 3.6 Flash", value: "gemini-3.6-flash" },
            { title: "Gemini 3.5 Flash", value: "gemini-3.5-flash" },
            { title: "Gemini 3.5 Flash-Lite", value: "gemini-3.5-flash-lite" },
            { title: "Gemini 3.1 Pro Preview", value: "gemini-3.1-pro-preview" }
        ]
    }

    property var modelsOfProviders: {
        let providers = {}
        for (let key in baseModels) {
            providers[key] = baseModels[key].slice()
        }
        if (Config.options.ai.models.length > 0) {
            return mergeModelsFromList(providers, Config.options.ai.models)
        } else {
            return providers;
        }
    }

    function mergeModelsFromList(base, extraList) {
        var result = {}
        for (var provider in base) {
            result[provider] = base[provider].slice()
        }
        
        if (extraList) {
            for (var i = 0; i < extraList.length; i++) {
                var item = extraList[i]
                for (var provider in item) {
                    if (result[provider]) {
                        result[provider] = result[provider].concat(item[provider])
                    } else {
                        result[provider] = item[provider].slice()
                    }
                }
            }
        }
        
        return result
    }

    function getModelProvider(providerKey, modelValue) {
        if (!modelsOfProviders[providerKey]) {
            return null
        }
        
        var models = modelsOfProviders[providerKey]
        for (var i = 0; i < models.length; i++) {
            if (models[i].value === modelValue) {
                return models[i].modelProvider || null
            }
        }
        
        return null
    }

    property var apiStrategies: {
        "openai": openaiApiStrategy.createObject(this),
        "gemini": geminiApiStrategy.createObject(this),
    }
    property ApiStrategy currentApiStrategy: apiStrategies[models[currentModelId]?.api_format || "openai"]

    property string requestScriptFilePath: "/tmp/quickshell/ai/request.sh"
    property string pendingFilePath: ""

    Component.onCompleted: {
        setModel(currentModelId, false, false);
    }

    function guessModelLogo(model) {
        if (model.includes("llama")) return "ollama-symbolic";
        if (model.includes("gemma")) return "google-gemini-symbolic";
        if (model.includes("deepseek")) return "deepseek-symbolic";
        if (/^phi\d*:/i.test(model)) return "microsoft-symbolic";
        return "ollama-symbolic";
    }

    function guessModelName(model) {
        const replaced = model.replace(/-/g, ' ').replace(/:/g, ' ');
        let words = replaced.split(' ');
        words[words.length - 1] = words[words.length - 1].replace(/(\d+)b$/, (_, num) => `${num}B`)
        words = words.map((word) => {
            return (word.charAt(0).toUpperCase() + word.slice(1))
        });
        if (words[words.length - 1] === "Latest") words.pop();
        else words[words.length - 1] = `(${words[words.length - 1]})`;
        const result = words.join(' ');
        return result;
    }

    function addModel(modelName, data) {
        root.models = Object.assign({}, root.models, {
            [modelName]: aiModelComponent.createObject(this, data)
        });
    }

    Process {
        id: getOllamaModels
        running: true
        command: ["bash", "-c", `${Directories.scriptPath}/ai/show-installed-ollama-models.sh`.replace(/file:\/\//, "")]
        stdout: SplitParser {
            onRead: data => {
                try {
                    if (data.length === 0) return;
                    const dataJson = JSON.parse(data);
                    root.modelList = [...root.modelList, ...dataJson];
                    dataJson.forEach(model => {
                        const safeModelName = root.safeModelName(model);
                        root.addModel(safeModelName, {
                            "name": guessModelName(model),
                            "icon": guessModelLogo(model),
                            "description": `Local Ollama model | ${model}`,
                            "homepage": `https://ollama.com/library/${model}`,
                            "endpoint": "http://localhost:11434/v1/chat/completions",
                            "model": model,
                            "requires_key": false,
                        })
                    });

                    root.modelList = Object.keys(root.models);

                } catch (e) {
                    console.log("Could not fetch Ollama models:", e);
                }
            }
        }
    }

    Process {
        id: getSavedChats
        running: true
        command: ["ls", "-1", Directories.aiChats]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.length === 0) return;
                root.savedChats = text.split("\n")
                    .filter(fileName => fileName.endsWith(".json"))
                    .map(fileName => `${Directories.aiChats}/${fileName}`)
            }
        }
    }

    function addMessage(message, role) {
        if (message.length === 0) return;
        const aiMessage = aiMessageComponent.createObject(root, {
            "role": role,
            "content": message,
            "rawContent": message,
            "thinking": false,
            "done": true,
        });
        const id = idForMessage(aiMessage);
        root.messageIDs = [...root.messageIDs, id];
        root.messageByID[id] = aiMessage;
    }

    function removeMessage(index) {
        if (index < 0 || index >= messageIDs.length) return;
        const id = root.messageIDs[index];
        root.messageIDs.splice(index, 1);
        root.messageIDs = [...root.messageIDs];
        delete root.messageByID[id];
    }

    function addApiKeyAdvice(model) {
        root.addMessage(
            `To set an API key, pass it with the /key command\n\nTo view the key, pass "get" with the command<br/>\n\n### For ${model.name}:\n\n**Link**: ${model.key_get_link}\n\n${model.key_get_description ?? "<i>No further instruction provided</i>"}`, 
            Ai.interfaceRole
        );
    }

    function getModel() {
        return models[currentModelId];
    }

    function setModel(modelId, feedback = true, setPersistentState = true) {
        if (!modelId) modelId = ""
        modelId = modelId.toLowerCase()
        if (modelList.indexOf(modelId) !== -1) {
            const model = models[modelId]
            if (setPersistentState) Persistent.states.ai.model = modelId;
            if (feedback) root.addMessage(`Model set to ${model.name}`, root.interfaceRole);
            if (model.requires_key) {
                if (root.apiKeysLoaded && (!root.apiKeys[model.key_id] || root.apiKeys[model.key_id].length === 0)) {
                    root.addApiKeyAdvice(model)
                }
            }
        } else {
            if (feedback) root.addMessage("Invalid model. Supported: \n```\n" + modelList.join("\n```\n```\n"), Ai.interfaceRole) + "\n```"
        }
    }

    function setTool(tool) {
        if (!root.tools[models[currentModelId]?.api_format] || !(tool in root.tools[models[currentModelId]?.api_format])) {
            root.addMessage(`Invalid tool. Supported tools:\n- ${root.availableTools.join("\n- ")}`, root.interfaceRole);
            return false;
        }
        Config.options.ai.tool = tool;
        return true;
    }
    
    function setTemperature(value) {
        if (value == NaN || value < 0 || value > 2) {
            root.addMessage("Temperature must be between 0 and 2", Ai.interfaceRole);
            return;
        }
        Persistent.states.ai.temperature = value;
        root.temperature = value;
        root.addMessage(`Temperature set to ${value}`, Ai.interfaceRole);
    }

    function setApiKey(key) {
        const model = models[currentModelId];
        if (!model.requires_key) {
            root.addMessage(`${model.name} does not require an API key`, Ai.interfaceRole);
            return;
        }
        if (!key || key.length === 0) {
            const model = models[currentModelId];
            root.addApiKeyAdvice(model)
            return;
        }
        KeyringStorage.setNestedField(["apiKeys", model.key_id], key.trim());
        root.addMessage(`API key set for ${model.name}`, Ai.interfaceRole);
    }

    function printApiKey() {
        const model = models[currentModelId];
        if (model.requires_key) {
            const key = root.apiKeys[model.key_id];
            if (key) {
                root.addMessage(`API key:\n\n\`\`\`txt\n${key}\n\`\`\``, Ai.interfaceRole);
            } else {
                root.addMessage(`No API key set for ${model.name}`, Ai.interfaceRole);
            }
        } else {
            root.addMessage(`${model.name} does not require an API key`, Ai.interfaceRole);
        }
    }

    function printTemperature() {
        root.addMessage(`Temperature: ${root.temperature}`, Ai.interfaceRole);
    }

    function clearMessages() {
        root.messageIDs = [];
        root.messageByID = ({});
        root.tokenCount.input = -1;
        root.tokenCount.output = -1;
        root.tokenCount.total = -1;
    }

    FileView {
        id: requesterScriptFile
    }

    Process {
        id: requester
        property list<string> baseCommand: ["bash"]
        property AiMessageData message
        property ApiStrategy currentStrategy

        function markDone() {
            requester.message.done = true;
            if (root.postResponseHook) {
                root.postResponseHook();
                root.postResponseHook = null;
            }
            root.saveChat("lastSession")
        }

        function makeRequest() {
            const model = models[currentModelId];

            if (model?.requires_key && !KeyringStorage.loaded) KeyringStorage.fetchKeyringData();
            
            requester.currentStrategy = root.currentApiStrategy;
            requester.currentStrategy.reset();

            if (model.requires_key) requester.environment[`${root.apiKeyEnvVarName}`] = root.apiKeys ? (root.apiKeys[model.key_id] ?? "") : ""

            const endpoint = root.currentApiStrategy.buildEndpoint(model);
            const messageArray = root.messageIDs.map(id => root.messageByID[id]);
            const filteredMessageArray = messageArray.filter(message => message.role !== Ai.interfaceRole);
            const tools = (model.endpoint.includes("localhost")) ? null : root.tools[model.api_format][root.currentTool];

            const data = root.currentApiStrategy.buildRequestData(
                model,
                filteredMessageArray,
                root.systemPrompt,
                root.temperature,
                tools,
                root.pendingFilePath
            );

            let requestHeaders = {
                "Content-Type": "application/json",
            }
            
            requester.message = root.aiMessageComponent.createObject(root, {
                "role": "assistant",
                "model": currentModelId,
                "content": "",
                "rawContent": "",
                "thinking": true,
                "done": false,
            });
            const id = idForMessage(requester.message);
            root.messageIDs = [...root.messageIDs, id];
            root.messageByID[id] = requester.message;

            let headerString = Object.entries(requestHeaders)
                .filter(([k, v]) => v && v.length > 0)
                .map(([k, v]) => `-H '${k}: ${v}'`)
                .join(' ');

            const authHeader = requester.currentStrategy.buildAuthorizationHeader(root.apiKeyEnvVarName);
            
            const scriptShebang = "#!/usr/bin/env bash\n";

            let scriptFileSetupContent = ""
            if (root.pendingFilePath && root.pendingFilePath.length > 0) {
                requester.message.localFilePath = root.pendingFilePath;
                scriptFileSetupContent = requester.currentStrategy.buildScriptFileSetup(root.pendingFilePath);
                root.pendingFilePath = ""
            }

            let scriptRequestContent = ""
            scriptRequestContent += `curl --no-buffer "${endpoint}"`
                + ` ${headerString}`
                + (authHeader ? ` ${authHeader}` : "")
                + ` --data '${CF.StringUtils.shellSingleQuoteEscape(JSON.stringify(data))}'`
                + "\n"
            
            const scriptContent = requester.currentStrategy.finalizeScriptContent(scriptShebang + scriptFileSetupContent + scriptRequestContent)
            const shellScriptPath = CF.FileUtils.trimFileProtocol(root.requestScriptFilePath)
            requesterScriptFile.path = Qt.resolvedUrl(shellScriptPath)
            requesterScriptFile.setText(scriptContent)
            requester.command = baseCommand.concat([shellScriptPath]);
            requester.running = true
        }

        stdout: SplitParser {
            onRead: data => {
                if (data.length === 0) return;
                if (requester.message.thinking) requester.message.thinking = false;

                try {
                    const result = requester.currentStrategy.parseResponseLine(data, requester.message);

                    if (result.functionCall) {
                        requester.message.functionCall = result.functionCall;
                        root.handleFunctionCall(result.functionCall.name, result.functionCall.args, requester.message);
                    }
                    if (result.tokenUsage) {
                        root.tokenCount.input = result.tokenUsage.input;
                        root.tokenCount.output = result.tokenUsage.output;
                        root.tokenCount.total = result.tokenUsage.total;
                    }
                    if (result.finished) {
                        requester.markDone();
                    }
                    
                } catch (e) {
                    console.log("[AI] Could not parse response: ", e);
                    requester.message.rawContent += data;
                    requester.message.content += data;
                }
            }
        }

        onExited: (exitCode, exitStatus) => {
            const result = requester.currentStrategy.onRequestFinished(requester.message);
            
            if (result.finished) {
                requester.markDone();
            } else if (!requester.message.done) {
                requester.markDone();
            }

            if (requester.message.content.includes("API key not valid")) {
                root.addApiKeyAdvice(models[requester.message.model]);
            }
        }
    }

    function sendUserMessage(message) {
        if (message.length === 0) return;
        root.addMessage(message, "user");
        requester.makeRequest();
    }

    Process {
        id: decodeImageAndAttachProc
        property string imageDecodePath: Directories.cliphistDecode
        property string imageDecodeFileName: "image"
        property string imageDecodeFilePath: `${imageDecodePath}/${imageDecodeFileName}`
        function handleEntry(entry: string) {
            imageDecodeFileName = parseInt(entry.match(/^(\d+)\t/)[1]);
            decodeImageAndAttachProc.exec(["bash", "-c", `[ -f ${imageDecodeFilePath} ] || echo '${CF.StringUtils.shellSingleQuoteEscape(entry)}' | ${Cliphist.cliphistBinary} decode > '${imageDecodeFilePath}'`]);
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                Ai.attachFile(imageDecodeFilePath);
            } else {
                console.error("[Ai] Failed to decode image in clipboard content");
            }
        }
    }
    
    function handleClipboardAndAttach() {
        handleClipboardTimer.start()
    }
    Timer {
        id: handleClipboardTimer
        interval: 450
        onTriggered: {
            const currentClipboardEntry = Cliphist.entries[0];
            const cleanCliphistEntry = CF.StringUtils.cleanCliphistEntry(currentClipboardEntry);
            if (/^\d+\t\[\[.*binary data.*\d+x\d+.*\]\]$/.test(currentClipboardEntry)) {
                decodeImageAndAttachProc.handleEntry(currentClipboardEntry);
                return;
            } else if (cleanCliphistEntry.startsWith("file://")) {
                const fileName = decodeURIComponent(cleanCliphistEntry);
                Ai.attachFile(fileName);
                return;
            }
        }
    }

    function attachFile(filePath: string) {
        root.pendingFilePath = CF.FileUtils.trimFileProtocol(filePath);
    }

    function regenerate(messageIndex) {
        if (messageIndex < 0 || messageIndex >= messageIDs.length) return;
        const id = root.messageIDs[messageIndex];
        const message = root.messageByID[id];
        if (message.role !== "assistant") return;
        for (let i = root.messageIDs.length - 1; i >= messageIndex; i--) {
            root.removeMessage(i);
        }
        requester.makeRequest();
    }

    function createFunctionOutputMessage(name, output, includeOutputInChat = true) {
        return aiMessageComponent.createObject(root, {
            "role": "user",
            "content": `[[ Output of ${name} ]]${includeOutputInChat ? ("\n\n<think>\n" + output + "\n</think>") : ""}`,
            "rawContent": `[[ Output of ${name} ]]${includeOutputInChat ? ("\n\n<think>\n" + output + "\n</think>") : ""}`,
            "functionName": name,
            "functionResponse": output,
            "thinking": false,
            "done": true,
        });
    }

    function addFunctionOutputMessage(name, output) {
        const aiMessage = createFunctionOutputMessage(name, output);
        const id = idForMessage(aiMessage);
        root.messageIDs = [...root.messageIDs, id];
        root.messageByID[id] = aiMessage;
    }

    function rejectCommand(message: AiMessageData) {
        if (!message.functionPending) return;
        message.functionPending = false;
        addFunctionOutputMessage(message.functionName, "Command rejected by user")
    }

    function approveCommand(message: AiMessageData) {
        if (!message.functionPending) return;
        message.functionPending = false;

        const responseMessage = createFunctionOutputMessage(message.functionName, "", false);
        const id = idForMessage(responseMessage);
        root.messageIDs = [...root.messageIDs, id];
        root.messageByID[id] = responseMessage;

        commandExecutionProc.message = responseMessage;
        commandExecutionProc.baseMessageContent = responseMessage.content;
        commandExecutionProc.shellCommand = message.functionCall.args.command;
        commandExecutionProc.running = true;
    }

    Process {
        id: commandExecutionProc
        property string shellCommand: ""
        property AiMessageData message
        property string baseMessageContent: ""
        command: ["bash", "-c", shellCommand]
        stdout: SplitParser {
            onRead: (output) => {
                commandExecutionProc.message.functionResponse += output + "\n\n";
                const updatedContent = commandExecutionProc.baseMessageContent + `\n\n<think>\n<tt>${commandExecutionProc.message.functionResponse}</tt>\n</think>`;
                commandExecutionProc.message.rawContent = updatedContent;
                commandExecutionProc.message.content = updatedContent;
            }
        }
        onExited: (exitCode, exitStatus) => {
            commandExecutionProc.message.functionResponse += `[[ Command exited with code ${exitCode} (${exitStatus}) ]]\n`;
            requester.makeRequest();
        }
    }

    function handleFunctionCall(name, args: var, message: AiMessageData) {
        if (name === "switch_to_search_mode") {
            const modelId = root.currentModelId;
            root.currentTool = "search"
            root.postResponseHook = () => { root.currentTool = "functions" }
            addFunctionOutputMessage(name, "Switched to search mode. Continue with the user's request.")
            requester.makeRequest();
        } else if (name === "get_shell_config") {
            const configJson = CF.ObjectUtils.toPlainObject(Config.options)
            addFunctionOutputMessage(name, JSON.stringify(configJson));
            requester.makeRequest();
        } else if (name === "set_shell_config") {
            if (!args.changes || !Array.isArray(args.changes)) {
                addFunctionOutputMessage(name, "Invalid arguments. Must provide `changes` array.");
                return;
            }
            let results = [];
            for (const change of args.changes) {
                if (!change.key || !change.value) {
                    results.push(`❌ Skipped invalid change: ${JSON.stringify(change)}`);
                    continue;
                }
                try {
                    Config.setNestedValue(change.key, change.value);
                    results.push(`✓ ${change.key} = ${change.value}`);
                } catch (e) {
                    results.push(`❌ Failed to set ${change.key}: ${e}`);
                }
            }
            addFunctionOutputMessage(name, results.join("\n"));
            requester.makeRequest();
        } else if (name === "run_shell_command") {
            if (!args.command || args.command.length === 0) {
                addFunctionOutputMessage(name, "Invalid arguments. Must provide `command`.");
                return;
            }
            const contentToAppend = `\n\n**Command execution request**\n\n\`\`\`command\n${args.command}\n\`\`\``;
            message.rawContent += contentToAppend;
            message.content += contentToAppend;
            message.functionPending = true;
        }
        else root.addMessage(`Unknown function call: ${name}`, "assistant");
    }

    function chatToJson() {
        return root.messageIDs.map(id => {
            const message = root.messageByID[id]
            return ({
                "role": message.role,
                "rawContent": message.rawContent,
                "fileMimeType": message.fileMimeType,
                "fileUri": message.fileUri,
                "localFilePath": message.localFilePath,
                "model": message.model,
                "thinking": false,
                "done": true,
                "annotations": message.annotations,
                "annotationSources": message.annotationSources,
                "functionName": message.functionName,
                "functionCall": message.functionCall,
                "functionResponse": message.functionResponse,
                "visibleToUser": message.visibleToUser,
            })
        })
    }

    FileView {
        id: chatSaveFile
        property string chatName: ""
        path: chatName.length > 0 ? `${Directories.aiChats}/${chatName}.json` : ""
        blockLoading: true
        preload: false // Avoid auto-reading nonexistent files on save
    }

    /**
     * Saves chat to a JSON list of message objects.
     * @param chatName name of the chat
     */
    function saveChat(chatName) {
        chatSaveFile.chatName = chatName.trim()
        const saveContent = JSON.stringify(root.chatToJson())
        chatSaveFile.setText(saveContent)
        getSavedChats.running = true;
    }

    /**
     * Loads chat from a JSON list of message objects.
     * @param chatName name of the chat
     */
    function loadChat(chatName) {
        try {
            chatSaveFile.chatName = chatName.trim()
            chatSaveFile.reload()
            const saveContent = chatSaveFile.text()
            const saveData = JSON.parse(saveContent)
            root.clearMessages()
            root.messageIDs = saveData.map((_, i) => {
                return i
            })
            for (let i = 0; i < saveData.length; i++) {
                const message = saveData[i];
                root.messageByID[i] = root.aiMessageComponent.createObject(root, {
                    "role": message.role,
                    "rawContent": message.rawContent,
                    "content": message.rawContent,
                    "fileMimeType": message.fileMimeType,
                    "fileUri": message.fileUri,
                    "localFilePath": message.localFilePath,
                    "model": message.model,
                    "thinking": message.thinking,
                    "done": message.done,
                    "annotations": message.annotations,
                    "annotationSources": message.annotationSources,
                    "functionName": message.functionName,
                    "functionCall": message.functionCall,
                    "functionResponse": message.functionResponse,
                    "visibleToUser": message.visibleToUser,
                });
            }
        } catch (e) {
            console.log("[AI] Could not load chat: ", e);
        } finally {
            getSavedChats.running = true;
        }
    }
}