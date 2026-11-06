local addonName = ...
local defaults = {
    ResampleAlwaysSharpen = true,
    groundEffectDensityEnabled = true,
    groundEffectDensity = 256,
    groundEffectFadeEnabled = true,
    groundEffectFade = 370,
    groundEffectDistEnabled = true,
    groundEffectDist = 500,
    cameraDistanceMaxZoomFactorEnabled = true,
    cameraDistanceMaxZoomFactor = 4.0,
    HDROutput = true,
    HDRFactorEnabled = true,
    HDRFactor = 1,
}

local numericSettings = {
    {
        key = "groundEffectDensity",
        enabledKey = "groundEffectDensityEnabled",
        label = "Ground effect density",
        cvar = "groundEffectDensity",
    },
    {
        key = "groundEffectFade",
        enabledKey = "groundEffectFadeEnabled",
        label = "Ground effect fade",
        cvar = "groundEffectFade",
    },
    {
        key = "groundEffectDist",
        enabledKey = "groundEffectDistEnabled",
        label = "Ground effect distance",
        cvar = "groundEffectDist",
    },
    {
        key = "cameraDistanceMaxZoomFactor",
        enabledKey = "cameraDistanceMaxZoomFactorEnabled",
        label = "Maximum camera zoom factor",
        cvar = "cameraDistanceMaxZoomFactor",
    },
    {
        key = "HDRFactor",
        enabledKey = "HDRFactorEnabled",
        label = "HDR factor",
        cvar = "HDRFactor",
    },
}

local optionsPanel
local optionsCategory

local function report(message)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99Forever Graphics:|r " .. message)
    end
end

local function setCVar(name, value)
    if not C_CVar or not C_CVar.SetCVar then
        report("This client does not expose C_CVar.SetCVar; unable to set " .. name .. ".")
        return false
    end

    local success, errorMessage = pcall(C_CVar.SetCVar, name, tostring(value))
    if not success then
        report("Could not set " .. name .. ": " .. tostring(errorMessage))
        return false
    end

    if C_CVar.GetCVar then
        local readSuccess, actualValue = pcall(C_CVar.GetCVar, name)
        if not readSuccess then
            report("Could not verify " .. name .. ": " .. tostring(actualValue))
            return false
        end
        if actualValue == nil then
            report(name .. " is not available in this client.")
            return false
        end

        local actualNumber = tonumber(actualValue)
        local expectedNumber = tonumber(value)
        if actualNumber and expectedNumber and math.abs(actualNumber - expectedNumber) < 0.000001 then
            return true
        elseif tostring(actualValue) ~= tostring(value) then
            report(name .. " was not changed by the client (current value: " .. tostring(actualValue) .. ").")
            return false
        end
    end

    return true
end

local function applySettings()
    local applied, total = 0, 0
    local function apply(name, value)
        total = total + 1
        if setCVar(name, value) then
            applied = applied + 1
        end
    end

    apply("ResampleAlwaysSharpen", ForeverGraphicsDB.ResampleAlwaysSharpen and 1 or 0)
    apply("HDROutput", ForeverGraphicsDB.HDROutput and 1 or 0)

    for _, setting in ipairs(numericSettings) do
        if ForeverGraphicsDB[setting.enabledKey] then
            apply(setting.cvar, ForeverGraphicsDB[setting.key])
        end
    end

    return applied, total
end

local function makeCheckButton(parent, label, checked, onClick)
    local button = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    button:SetSize(26, 26)

    local text = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    text:SetPoint("LEFT", button, "RIGHT", 4, 0)
    text:SetText(label)
    button.label = text

    button:SetChecked(checked)
    button:SetScript("OnClick", function(self)
        onClick(self:GetChecked())
    end)

    return button
end

local function makeNumericInput(parent, value, onCommit)
    local input = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    input:SetSize(80, 24)
    input:SetAutoFocus(false)
    input:SetNumeric(false)
    input:SetText(tostring(value))

    local function commit()
        local number = tonumber(input:GetText())
        if not number or number ~= number or number == math.huge or number == -math.huge or number < 0 then
            report("Enter a finite, non-negative number.")
            input:SetText(tostring(value))
            return
        end

        value = number
        onCommit(number)
        input:SetText(tostring(number))
    end

    input:SetScript("OnEnterPressed", function(self)
        commit()
        self:ClearFocus()
    end)
    input:SetScript("OnEscapePressed", function(self)
        self:SetText(tostring(value))
        self:ClearFocus()
    end)

    return input
end

local function createOptionsPanel()
    local panel = CreateFrame("Frame")
    panel.name = "Forever Graphics"

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Forever Graphics")

    local description = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    description:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    description:SetText("Choose which graphics settings the addon applies. Disabled numeric settings are left unchanged.")

    local yOffset = -76
    local rowSpacing = 42

    local sharpen = makeCheckButton(panel, "Resample always sharpen", ForeverGraphicsDB.ResampleAlwaysSharpen, function(checked)
        ForeverGraphicsDB.ResampleAlwaysSharpen = checked
        setCVar("ResampleAlwaysSharpen", checked and 1 or 0)
    end)
    sharpen:SetPoint("TOPLEFT", 16, yOffset)
    yOffset = yOffset - rowSpacing

    local hdr = makeCheckButton(panel, "HDR output", ForeverGraphicsDB.HDROutput, function(checked)
        ForeverGraphicsDB.HDROutput = checked
        setCVar("HDROutput", checked and 1 or 0)
    end)
    hdr:SetPoint("TOPLEFT", 16, yOffset)
    yOffset = yOffset - rowSpacing

    for _, setting in ipairs(numericSettings) do
        local checkbox = makeCheckButton(panel, "Manage", ForeverGraphicsDB[setting.enabledKey], function(checked)
            ForeverGraphicsDB[setting.enabledKey] = checked
            if checked then
                setCVar(setting.cvar, ForeverGraphicsDB[setting.key])
            end
        end)

        local label = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        label:SetPoint("LEFT", checkbox, "RIGHT", 76, 0)
        label:SetText(setting.label)

        local input = makeNumericInput(panel, ForeverGraphicsDB[setting.key], function(number)
            ForeverGraphicsDB[setting.key] = number
            if ForeverGraphicsDB[setting.enabledKey] then
                setCVar(setting.cvar, number)
            end
        end)
        input:SetPoint("LEFT", label, "RIGHT", 12, 0)
        checkbox:SetPoint("TOPLEFT", 16, yOffset)
        yOffset = yOffset - rowSpacing
    end

    local applyButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    applyButton:SetSize(120, 26)
    applyButton:SetPoint("TOPLEFT", 16, yOffset - 8)
    applyButton:SetText("Apply settings")
    applyButton:SetScript("OnClick", function()
        local applied, total = applySettings()
        if applied == total then
            report("Applied " .. applied .. " settings.")
        else
            report("Applied " .. applied .. " of " .. total .. " settings; see earlier messages for details.")
        end
    end)

    return panel
end

local function openOptions()
    if Settings and Settings.OpenToCategory and optionsCategory then
        Settings.OpenToCategory(optionsCategory:GetID())
    elseif InterfaceOptionsFrame_OpenToCategory and optionsPanel then
        InterfaceOptionsFrame_OpenToCategory(optionsPanel)
        InterfaceOptionsFrame_OpenToCategory(optionsPanel)
    else
        report("The Settings panel is not available yet.")
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function(_, event, loadedAddon)
    if event == "ADDON_LOADED" and loadedAddon == addonName then
        ForeverGraphicsDB = ForeverGraphicsDB or {}
        for key, value in pairs(defaults) do
            if ForeverGraphicsDB[key] == nil then
                ForeverGraphicsDB[key] = value
            end
        end

        optionsPanel = createOptionsPanel()
        if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
            optionsCategory = Settings.RegisterCanvasLayoutCategory(optionsPanel, "Forever Graphics")
            Settings.RegisterAddOnCategory(optionsCategory)
        elseif InterfaceOptions_AddCategory then
            InterfaceOptions_AddCategory(optionsPanel)
        end

        SLASH_FOREVERGRAPHICS1 = "/forevergraphics"
        SLASH_FOREVERGRAPHICS2 = "/fg"
        SlashCmdList.FOREVERGRAPHICS = openOptions
    elseif event == "PLAYER_LOGIN" then
        applySettings()
    end
end)
