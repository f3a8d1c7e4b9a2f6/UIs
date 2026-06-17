local cloneref = (cloneref or clonereference or function(instance: any) return instance end)
local httpService = cloneref(game:GetService("HttpService"))
local httprequest = (syn and syn.request) or request or http_request or (http and http.request)
local getassetfunc = getcustomasset or getsynasset
local isfolder, isfile, listfiles = isfolder, isfile, listfiles
local RunService = cloneref(game:GetService("RunService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local Players = cloneref(game:GetService("Players"))

if typeof(copyfunction) == "function" then
    -- Fix is_____ functions for shitsploits, those functions should never error, only return a boolean.

    local
        isfolder_copy,
        isfile_copy,
        listfiles_copy = copyfunction(isfolder), copyfunction(isfile), copyfunction(listfiles)

    local isfolder_success, isfolder_error = pcall(function()
        return isfolder_copy("test" .. tostring(math.random(1000000, 9999999)))
    end)

    if isfolder_success == false or typeof(isfolder_error) ~= "boolean" then
        isfolder = function(folder)
            local success, data = pcall(isfolder_copy, folder)
            return (if success then data else false)
        end

        isfile = function(file)
            local success, data = pcall(isfile_copy, file)
            return (if success then data else false)
        end

        listfiles = function(folder)
            local success, data = pcall(listfiles_copy, folder)
            return (if success then data else {})
        end
    end
end

local ThemeManager = {} do
    ThemeManager.Folder = "IntellectualLibSettings"
    -- if not isfolder(ThemeManager.Folder) then makefolder(ThemeManager.Folder) end
    ThemeManager.Library = nil
    ThemeManager.DefaultFontFace = "Jura"
    ThemeManager.DefaultFontSize = 14
    ThemeManager.CustomFonts = {
        ["ProggySquare"] = {
            name = "proggy-square",
            fileName = "proggySquare.ttf",
            dataFileName = "proggySquare.json",
            url = "https://github.com/sametexe001/luas/raw/refs/heads/main/fonts/proggy-square.ttf"
        },
        ["ProggyClean"] = {
            name = "proggy-clean",
            fileName = "proggyClean.ttf",
            dataFileName = "proggyClean.json",
            url = "https://github.com/sametexe001/luas/raw/refs/heads/main/fonts/proggy-clean.ttf"
        },
        ["ProggyTiny"] = {
            name = "proggy-tiny",
            fileName = "proggyTiny.ttf",
            dataFileName = "proggyTiny.json",
            url = "https://github.com/sametexe001/luas/raw/refs/heads/main/fonts/proggy-tiny.ttf"
        }
    }
    ThemeManager.BuiltInThemes = {
        ["ZalStore"]    = { 1, httpService:JSONDecode([[{"FontColor":"ffffff","MainColor":"191919","AccentColor":"1555e6","BackgroundColor":"0f0f0f","OutlineColor":"000000"}]]) },
        ["Default"] 		= { 2, httpService:JSONDecode([[{"FontColor":"ffffff","MainColor":"191919","AccentColor":"7d55ff","BackgroundColor":"0f0f0f","OutlineColor":"000000"}]]) },
        ["GameSense"]       = { 3, httpService:JSONDecode([[{"FontColor":"ffffff","MainColor":"101010","AccentColor":"9CB819","BackgroundColor":"111111","OutlineColor":"000000"}]]) },
        ["Comet.pub"]       = { 4, httpService:JSONDecode([[{"FontColor":"ffffff","MainColor":"0F0F0F","AccentColor":"5D589D","BackgroundColor":"0F0F0F","OutlineColor":"000000"}]]) },  
        ["Tokyohook.cc"]    = { 4, httpService:JSONDecode([[{"FontColor":"ffffff","MainColor":"191925","AccentColor":"6759b3","BackgroundColor":"16161f","OutlineColor":"000000"}]]) },
        ["White and black"]  = { 5, httpService:JSONDecode([[{"FontColor":"ffffff","MainColor":"060606","AccentColor":"FFFFFF","BackgroundColor":"09090a","OutlineColor":"000000"}]]) },
        ["Red and black"]  = { 7, httpService:JSONDecode([[{"FontColor":"ffffff","MainColor":"060606","AccentColor":"ff0000","BackgroundColor":"09090a","OutlineColor":"000000"}]]) },
        ["Green and black"]  = { 8, httpService:JSONDecode([[{"FontColor":"ffffff","MainColor":"060606","AccentColor":"00ff00","BackgroundColor":"09090a","OutlineColor":"000000"}]]) },                                
        ["Pink and black"]  = { 9, httpService:JSONDecode([[{"FontColor":"ffffff","MainColor":"0f0f0f","AccentColor":"ff0082","BackgroundColor":"121212","OutlineColor":"000000"}]]) },
        ["Purple and black"]  = { 10, httpService:JSONDecode([[{"FontColor":"ffffff","MainColor":"060606","AccentColor":"b500ff","BackgroundColor":"09090a","OutlineColor":"000000"}]]) },
        ["Modern Ui"]  = { 11, httpService:JSONDecode([[{"FontColor":"ffffff","MainColor":"060606","AccentColor":"ffd28f","BackgroundColor":"09090a","OutlineColor":"000000"}]]) },
        ["Blox fruit"]  = { 12, httpService:JSONDecode([[{"FontColor":"ffffff","MainColor":"060606","AccentColor":"9797f7","BackgroundColor":"09090a","OutlineColor":"000000"}]]) },
        ["Teal and black"]  = { 13, httpService:JSONDecode([[{"FontColor":"ffffff","MainColor":"060606","AccentColor":"00ffff","BackgroundColor":"09090a","OutlineColor":"000000"}]]) },
        ["Midnight blue"]  = { 14, httpService:JSONDecode([[{"FontColor":"ffffff","MainColor":"0f142b","AccentColor":"0000ff","BackgroundColor":"00001d","OutlineColor":"000000"}]]) },
        ["Midnight black and red"]  = { 15, httpService:JSONDecode([[{"FontColor":"ffffff","MainColor":"0b0b0b","AccentColor":"f60000","BackgroundColor":"080707","OutlineColor":"000000"}]]) },
        ["Yama cod theme"]  = { 15, httpService:JSONDecode([[{"FontColor":"000000","MainColor":"e2e2e2","AccentColor":"000000","BackgroundColor":"d4d4d4","OutlineColor":"000000"}]]) },
        ["Red ice"]  = { 15, httpService:JSONDecode([[{"FontColor":"ffffff","MainColor":"0e0e0e","AccentColor":"ffffff","BackgroundColor":"220000","OutlineColor":"000000"}]]) },
    }

    function ThemeManager:SetLibrary(library)
        self.Library = library
    end

    function ThemeManager:GetUiRoots()
        local roots = {}
        local seen = {}

        local function add(root)
            if typeof(root) == "Instance" and not seen[root] then
                seen[root] = true
                roots[#roots + 1] = root
            end
        end

        if self.Library then
            add(self.Library.ScreenGui)
            add(self.Library.Gui)
            add(self.Library.GUI)
            add(self.Library.MainFrame)
        end

        if typeof(gethui) == "function" then
            local success, hui = pcall(gethui)
            if success then
                add(hui)
            end
        end

        add(CoreGui)

        local localPlayer = Players.LocalPlayer
        if localPlayer then
            add(localPlayer:FindFirstChildOfClass("PlayerGui"))
        end

        return roots
    end

    function ThemeManager:GetScriptName()
        if typeof(getgenv) == "function" then
            local success, env = pcall(getgenv)
            if success and typeof(env) == "table" and typeof(env.IntScriptName) == "string" and env.IntScriptName ~= "" then
                return env.IntScriptName
            end
        end

        return ""
    end

    function ThemeManager:TextContainsScriptName(text)
        local scriptName = self:GetScriptName()
        return scriptName ~= "" and tostring(text):find(scriptName, 1, true) ~= nil
    end

    --// Folders \\--
    function ThemeManager:GetPaths()
        local paths = {}

        local parts = self.Folder:split("/")
        for idx = 1, #parts do
            paths[#paths + 1] = table.concat(parts, "/", 1, idx)
        end

        paths[#paths + 1] = self.Folder .. "/themes"
        
        return paths
    end

    function ThemeManager:BuildFolderTree()
        local paths = self:GetPaths()

        for i = 1, #paths do
            local str = paths[i]
            if isfolder(str) then continue end
            makefolder(str)
        end
    end

    function ThemeManager:CheckFolderTree()
        if isfolder(self.Folder) then return end
        self:BuildFolderTree()

        task.wait(0.1)
    end

    function ThemeManager:GetFontsFolder()
        return self.Folder .. "/fonts"
    end

    function ThemeManager:EnsureCustomFont(fontName)
        local font = self.CustomFonts[fontName]
        if not font or not getassetfunc then
            return nil
        end

        local fontsFolder = self:GetFontsFolder()
        if not isfolder(fontsFolder) then
            makefolder(fontsFolder)
        end

        local fontPath = fontsFolder .. "/" .. font.fileName
        local dataPath = fontsFolder .. "/" .. font.dataFileName

        if not isfile(fontPath) then
            local success, fontData = pcall(game.HttpGet, game, font.url)
            if not success then
                return nil
            end

            writefile(fontPath, fontData)
        end

        if not isfile(dataPath) then
            local data = {
                name = font.name,
                faces = {{
                    name = "Regular",
                    weight = 200,
                    style = "Regular",
                    assetId = getassetfunc(fontPath)
                }}
            }

            writefile(dataPath, httpService:JSONEncode(data))
        end

        local success, fontFace = pcall(Font.new, getassetfunc(dataPath))
        return if success then fontFace else nil
    end

    function ThemeManager:GetFont(fontName)
        return self:EnsureCustomFont(fontName) or Enum.Font[fontName] or Enum.Font.Code
    end

    function ThemeManager:IsCustomFont(fontName)
        return self.CustomFonts[fontName] ~= nil
    end

    function ThemeManager:GetDefaultFontSize(fontName)
        return if self:IsCustomFont(fontName) then 10 else self.DefaultFontSize
    end

    function ThemeManager:ApplyFontToTextObjects(font, excludedSize)
        local seen = {}
        self.OriginalTextFonts = self.OriginalTextFonts or {}
        self.OriginalTextSizes = self.OriginalTextSizes or {}
        local containerKeywords = {
            "dropdown",
            "input",
            "slider",
            "list",
            "menu",
            "popup",
            "option",
            "value"
        }

        local function ancestorNameHas(object, keywords)
            local ancestor = object.Parent
            while ancestor do
                local ancestorName = ancestor.Name:lower()
                for _, keyword in pairs(keywords) do
                    if ancestorName:find(keyword, 1, true) then
                        return true
                    end
                end

                ancestor = ancestor.Parent
            end

            return false
        end

        local function ShouldSkipTxtc(object)
            if typeof(object) ~= "Instance" then
                return false
            end

            local name = object.Name:lower()
            if object:IsA("TextBox") then
                return true
            end

            if name:find("title", 1, true) or name:find("tab", 1, true) or name:find("tabbox", 1, true) or name:find("watermark", 1, true) then
                return true
            end

            for _, keyword in pairs(containerKeywords) do
                if name:find(keyword, 1, true) then
                    return true
                end
            end

            if ancestorNameHas(object, containerKeywords) then
                return true
            end

            local parent = object.Parent
            if parent then
                local parentName = parent.Name:lower()
                if parentName:find("tab", 1, true) or parentName:find("tabbox", 1, true) or parentName:find("title", 1, true) or parentName:find("watermark", 1, true) then
                    return true
                end
            end

            if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
                local text = object.Text
                local lowerText = text:gsub("<[^>]+>", ""):lower()
                if text == "+" or text == "-" or tonumber(text) ~= nil then
                    return true
                end

                if lowerText:find("intellectual", 1, true) or lowerText == "int" or lowerText == "ellectual" or lowerText == "online" or self:TextContainsScriptName(text) then
                    return true
                end

                if lowerText == "main" or lowerText:find("tools", 1, true) or lowerText:find("settings", 1, true) or lowerText:find("configuration", 1, true) or lowerText:find("themes", 1, true) or lowerText:find("features", 1, true) then
                    return true
                end

                if lowerText == "local player" or lowerText == "misc" or lowerText == "movement" or lowerText == "combat" or lowerText == "visual" or lowerText == "other" or lowerText == "keybinds" or lowerText == "lemonade" or lowerText == "keystone" then
                    return true
                end

                if lowerText == "none" or lowerText == "head" then
                    return true
                end
            end

            return false
        end

        local function shouldForceDefaultExcludedSize(object)
            if typeof(object) ~= "Instance" then
                return false
            end

            if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
                local name = object.Name:lower()
                for _, keyword in pairs(containerKeywords) do
                    if name:find(keyword, 1, true) then
                        return false
                    end
                end

                if ancestorNameHas(object, containerKeywords) then
                    return false
                end

                local text = object.Text
                local lowerText = text:gsub("<[^>]+>", ""):lower()
                return lowerText == "int"
                    or lowerText == "ellectual"
                    or self:TextContainsScriptName(text)
            end

            return false
        end

        local function shouldUseTextBoxFontDefaultSize(object)
            if object:IsA("TextBox") then
                return true
            end

            if object:IsA("TextLabel") or object:IsA("TextButton") then
                local inputKeywords = { "input", "textbox", "placeholder" }
                local name = object.Name:lower()
                local text = object.Text:gsub("<[^>]+>", ""):lower()

                if text:sub(1, 6) == "enter " or text:find("...", 1, true) then
                    return true
                end

                for _, keyword in pairs(inputKeywords) do
                    if name:find(keyword, 1, true) then
                        return true
                    end
                end

                return ancestorNameHas(object, inputKeywords)
            end

            return false
        end

        local function ShouldUsefooterdont(object)
            if not (object:IsA("TextLabel") or object:IsA("TextButton")) then
                return false
            end

            local text = object.Text:gsub("<[^>]+>", "")
            local lowerText = text:lower()
            local footerKeywords = { "watermark", "footer", "status" }

            if self:TextContainsScriptName(text) then
                return true
            end

            if lowerText:find("intellectual", 1, true) then
                local name = object.Name:lower()
                for _, keyword in pairs(footerKeywords) do
                    if name:find(keyword, 1, true) then
                        return true
                    end
                end

                return ancestorNameHas(object, footerKeywords)
            end

            return false
        end

        local function setObjectFont(object, objectFont)
            if typeof(objectFont) == "Font" then
                object.FontFace = objectFont
            else
                object.Font = objectFont
            end
        end

        local function applyTextBoxDefaultSize(object)
            if typeof(object) ~= "Instance" then
                return
            end

            if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
                if shouldUseTextBoxFontDefaultSize(object) then
                    setObjectFont(object, font)
                    object.TextScaled = false
                    object.TextSize = excludedSize or self.DefaultFontSize
                end
            end
        end

        local function applyFooterDefaultSize(object)
            if typeof(object) ~= "Instance" then
                return
            end

            if ShouldUsefooterdont(object) then
                setObjectFont(object, font)
                object.TextScaled = false
                object.TextSize = excludedSize or self.DefaultFontSize
            end
        end

        local function applyObjectFont(object, cacheOnly)
            if object == nil then
                return
            end

            if seen[object] then
                return
            end

            seen[object] = true

            local objectType = typeof(object)
            if objectType == "Instance" then
                if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
                    if self.OriginalTextFonts[object] == nil then
                        self.OriginalTextFonts[object] = object.FontFace
                    end

                    if self.OriginalTextSizes[object] == nil then
                        self.OriginalTextSizes[object] = object.TextSize
                    end

                    if not cacheOnly then
                        if ShouldUsefooterdont(object) then
                            applyFooterDefaultSize(object)
                        elseif shouldUseTextBoxFontDefaultSize(object) then
                            applyTextBoxDefaultSize(object)
                        elseif ShouldSkipTxtc(object) then
                            object.TextSize = if shouldForceDefaultExcludedSize(object) then self.DefaultFontSize else (excludedSize or self.OriginalTextSizes[object])
                        elseif object:IsA("TextLabel") or object:IsA("TextButton") then
                            setObjectFont(object, font)
                        end
                    end
                end

                local success, descendants = pcall(object.GetDescendants, object)
                if success then
                    for _, descendant in pairs(descendants) do
                        applyObjectFont(descendant, cacheOnly)
                    end
                end
            elseif objectType == "table" then
                for _, value in pairs(object) do
                    applyObjectFont(value, cacheOnly)
                end
            end
        end

        applyObjectFont(self.Library.Registry, true)
        applyObjectFont(self.Library.ScreenGui, true)
        applyObjectFont(self.Library.Gui, true)
        applyObjectFont(self.Library.GUI, true)
        applyObjectFont(self.Library.MainFrame, true)

        self.Library:SetFont(font)

        seen = {}
        applyObjectFont(self.Library.Registry, false)
        applyObjectFont(self.Library.ScreenGui, false)
        applyObjectFont(self.Library.Gui, false)
        applyObjectFont(self.Library.GUI, false)
        applyObjectFont(self.Library.MainFrame, false)

        local function applyTextBoxDefaultsIn(root)
            if typeof(root) ~= "Instance" then
                return
            end

            applyTextBoxDefaultSize(root)
            applyFooterDefaultSize(root)

            local success, descendants = pcall(root.GetDescendants, root)
            if success then
                for _, descendant in pairs(descendants) do
                    applyTextBoxDefaultSize(descendant)
                    applyFooterDefaultSize(descendant)
                end
            end
        end

        for _, root in pairs(self:GetUiRoots()) do
            applyTextBoxDefaultsIn(root)
        end

        task.defer(function()
            for _, root in pairs(self:GetUiRoots()) do
                applyTextBoxDefaultsIn(root)
            end
        end)
    end

    function ThemeManager:ApplyFontFace(fontName)
        local size = self:GetDefaultFontSize(fontName)
        self.ExcludedFontSize = size
        self:ApplyFontToTextObjects(self:GetFont(fontName), size)

        if self.Library.Options.FontSize then
            self.Library.Options.FontSize:SetValue(size)
        end
    end

    function ThemeManager:SetFontSize(size)
        size = math.clamp(math.floor(tonumber(size) or self.DefaultFontSize), 7, 30)

        local seen = {}
        self.OriginalTextSizes = self.OriginalTextSizes or {}
        local containerKeywords = {
            "dropdown",
            "input",
            "slider",
            "list",
            "menu",
            "popup",
            "option",
            "value"
        }

        local function ancestorNameHas(object, keywords)
            local ancestor = object.Parent
            while ancestor do
                local ancestorName = ancestor.Name:lower()
                for _, keyword in pairs(keywords) do
                    if ancestorName:find(keyword, 1, true) then
                        return true
                    end
                end

                ancestor = ancestor.Parent
            end

            return false
        end

        local function ShouldSkipTxtc(object)
            if typeof(object) ~= "Instance" then
                return false
            end

            local name = object.Name:lower()
            if object:IsA("TextBox") then
                return true
            end

            if name:find("title", 1, true) or name:find("tab", 1, true) or name:find("tabbox", 1, true) or name:find("watermark", 1, true) then
                return true
            end

            for _, keyword in pairs(containerKeywords) do
                if name:find(keyword, 1, true) then
                    return true
                end
            end

            if ancestorNameHas(object, containerKeywords) then
                return true
            end

            local parent = object.Parent
            if parent then
                local parentName = parent.Name:lower()
                if parentName:find("tab", 1, true) or parentName:find("tabbox", 1, true) or parentName:find("title", 1, true) or parentName:find("watermark", 1, true) then
                    return true
                end
            end

            if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
                local text = object.Text
                local lowerText = text:gsub("<[^>]+>", ""):lower()
                if text == "+" or text == "-" or tonumber(text) ~= nil then
                    return true
                end

                if lowerText:find("intellectual", 1, true) or lowerText == "int" or lowerText == "ellectual" or lowerText == "online" or self:TextContainsScriptName(text) then
                    return true
                end

                if lowerText == "main" or lowerText:find("tools", 1, true) or lowerText:find("settings", 1, true) or lowerText:find("configuration", 1, true) or lowerText:find("themes", 1, true) or lowerText:find("features", 1, true) then
                    return true
                end

                if lowerText == "local player" or lowerText == "misc" or lowerText == "movement" or lowerText == "combat" or lowerText == "visual" or lowerText == "other" or lowerText == "keybinds" or lowerText == "lemonade" or lowerText == "keystone" then
                    return true
                end

                if lowerText == "none" or lowerText == "head" then
                    return true
                end
            end

            return false
        end

        local function shouldForceDefaultExcludedSize(object)
            if typeof(object) ~= "Instance" then
                return false
            end

            if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
                local name = object.Name:lower()
                for _, keyword in pairs(containerKeywords) do
                    if name:find(keyword, 1, true) then
                        return false
                    end
                end

                if ancestorNameHas(object, containerKeywords) then
                    return false
                end

                local text = object.Text
                local lowerText = text:gsub("<[^>]+>", ""):lower()
                return lowerText == "int"
                    or lowerText == "ellectual"
                    or self:TextContainsScriptName(text)
            end

            return false
        end

        local function shouldUseTextBoxFontDefaultSize(object)
            if object:IsA("TextBox") then
                return true
            end

            if object:IsA("TextLabel") or object:IsA("TextButton") then
                local inputKeywords = { "input", "textbox", "placeholder" }
                local name = object.Name:lower()
                local text = object.Text:gsub("<[^>]+>", ""):lower()

                if text:sub(1, 6) == "enter " or text:find("...", 1, true) then
                    return true
                end

                for _, keyword in pairs(inputKeywords) do
                    if name:find(keyword, 1, true) then
                        return true
                    end
                end

                return ancestorNameHas(object, inputKeywords)
            end

            return false
        end

        local function ShouldUsefooterdont(object)
            if not (object:IsA("TextLabel") or object:IsA("TextButton")) then
                return false
            end

            local text = object.Text:gsub("<[^>]+>", "")
            local lowerText = text:lower()
            local footerKeywords = { "watermark", "footer", "status" }

            if self:TextContainsScriptName(text) then
                return true
            end

            if lowerText:find("intellectual", 1, true) then
                local name = object.Name:lower()
                for _, keyword in pairs(footerKeywords) do
                    if name:find(keyword, 1, true) then
                        return true
                    end
                end

                return ancestorNameHas(object, footerKeywords)
            end

            return false
        end

        local function applyTextBoxDefaultSize(object)
            if typeof(object) ~= "Instance" then
                return
            end

            if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
                if shouldUseTextBoxFontDefaultSize(object) then
                    object.TextScaled = false
                    object.TextSize = self.ExcludedFontSize or self.DefaultFontSize
                end
            end
        end

        local function applyFooterDefaultSize(object)
            if typeof(object) ~= "Instance" then
                return
            end

            if ShouldUsefooterdont(object) then
                object.TextScaled = false
                object.TextSize = self.ExcludedFontSize or self.DefaultFontSize
            end
        end

        local function setObjectSize(object)
            if object == nil then
                return
            end

            if seen[object] then
                return
            end

            seen[object] = true

            local objectType = typeof(object)
            if objectType == "Instance" then
                if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
                    if self.OriginalTextSizes[object] == nil then
                        self.OriginalTextSizes[object] = object.TextSize
                    end

                    if ShouldUsefooterdont(object) then
                        applyFooterDefaultSize(object)
                    elseif shouldUseTextBoxFontDefaultSize(object) then
                        applyTextBoxDefaultSize(object)
                    elseif ShouldSkipTxtc(object) then
                        object.TextSize = if shouldForceDefaultExcludedSize(object) then self.DefaultFontSize else (self.ExcludedFontSize or self.OriginalTextSizes[object])
                    elseif object:IsA("TextLabel") or object:IsA("TextButton") then
                        object.TextSize = size
                    end
                end

                local success, descendants = pcall(object.GetDescendants, object)
                if success then
                    for _, descendant in pairs(descendants) do
                        setObjectSize(descendant)
                    end
                end
            elseif objectType == "table" then
                for _, value in pairs(object) do
                    setObjectSize(value)
                end
            end
        end

        setObjectSize(self.Library.Registry)
        setObjectSize(self.Library.ScreenGui)
        setObjectSize(self.Library.Gui)
        setObjectSize(self.Library.GUI)
        setObjectSize(self.Library.MainFrame)

        local function applyTextBoxDefaultsIn(root)
            if typeof(root) ~= "Instance" then
                return
            end

            applyTextBoxDefaultSize(root)
            applyFooterDefaultSize(root)

            local success, descendants = pcall(root.GetDescendants, root)
            if success then
                for _, descendant in pairs(descendants) do
                    applyTextBoxDefaultSize(descendant)
                    applyFooterDefaultSize(descendant)
                end
            end
        end

        for _, root in pairs(self:GetUiRoots()) do
            applyTextBoxDefaultsIn(root)
        end

        task.defer(function()
            for _, root in pairs(self:GetUiRoots()) do
                applyTextBoxDefaultsIn(root)
            end
        end)
    end

    function ThemeManager:SetFolder(folder)
        self.Folder = folder
        self:BuildFolderTree()
    end
    
    --// Apply, Update theme \\--
    function ThemeManager:ApplyTheme(theme)
        local customThemeData = self:GetCustomTheme(theme)
        local data = customThemeData or self.BuiltInThemes[theme]

        if not data then return end
        
        local scheme = data[2]
        for idx, val in pairs(customThemeData or scheme) do
            if idx == "VideoLink" then
                continue
            elseif idx == "FontFace" then
                self:ApplyFontFace(val)

                if self.Library.Options[idx] then
                    self.Library.Options[idx]:SetValue(val)
                end
            elseif idx == "FontSize" then
                self:SetFontSize(val)

                if self.Library.Options[idx] then
                    self.Library.Options[idx]:SetValue(val)
                end
            else
                self.Library.Scheme[idx] = Color3.fromHex(val)
            
                if self.Library.Options[idx] then
                    self.Library.Options[idx]:SetValueRGB(Color3.fromHex(val))
                end
            end
        end

        self:ThemeUpdate()
    end

    function ThemeManager:ThemeUpdate()
        local options = { "FontColor", "MainColor", "AccentColor", "BackgroundColor", "OutlineColor" }
        for i, field in pairs(options) do
            if self.Library.Options and self.Library.Options[field] then
                self.Library.Scheme[field] = self.Library.Options[field].Value
            end
        end

        self.Library:UpdateColorsUsingRegistry()
    end

    --// Get, Load, Save, Delete, Refresh \\--
    function ThemeManager:GetCustomTheme(file)
        local path = self.Folder .. "/themes/" .. file .. ".json"
        if not isfile(path) then
            return nil
        end

        local data = readfile(path)
        local success, decoded = pcall(httpService.JSONDecode, httpService, data)
        
        if not success then
            return nil
        end

        return decoded
    end

    function ThemeManager:LoadDefault()
        local theme = "Default"
        local content = isfile(self.Folder .. "/themes/default.txt") and readfile(self.Folder .. "/themes/default.txt")

        local isDefault = true
        if content then
            if self.BuiltInThemes[content] then
                theme = content
            elseif self:GetCustomTheme(content) then
                theme = content
                isDefault = false
            end
        elseif self.BuiltInThemes[self.DefaultTheme] then
            theme = self.DefaultTheme
        end

        if isDefault then
            self.Library.Options.ThemeManager_ThemeList:SetValue(theme)
        else
            self:ApplyTheme(theme)
        end
    end

    function ThemeManager:SaveDefault(theme)
        writefile(self.Folder .. "/themes/default.txt", theme)
    end

    function ThemeManager:SaveCustomTheme(file)
        if file:gsub(" ", "") == "" then
            return self.Library:Notify("Invalid file name for theme (empty)", 3)
        end

        local theme = {}
        local fields = { "FontColor", "MainColor", "AccentColor", "BackgroundColor", "OutlineColor" }

        for _, field in pairs(fields) do
            theme[field] = self.Library.Options[field].Value:ToHex()
        end
        theme["FontFace"] = self.Library.Options["FontFace"].Value
        theme["FontSize"] = self.Library.Options["FontSize"].Value

        writefile(self.Folder .. "/themes/" .. file .. ".json", httpService:JSONEncode(theme))
    end

    function ThemeManager:Delete(name)
        if (not name) then
            return false, "no config file is selected"
        end

        local file = self.Folder .. "/themes/" .. name .. ".json"
        if not isfile(file) then return false, "invalid file" end

        local success = pcall(delfile, file)
        if not success then return false, "delete file error" end
        
        return true
    end
    
    function ThemeManager:ReloadCustomThemes()
        local list = listfiles(self.Folder .. "/themes")

        local out = {}
        for i = 1, #list do
            local file = list[i]
            if file:sub(-5) == ".json" then
                -- i hate this but it has to be done ...

                local pos = file:find(".json", 1, true)
                local start = pos

                local char = file:sub(pos, pos)
                while char ~= "/" and char ~= "\\" and char ~= "" do
                    pos = pos - 1
                    char = file:sub(pos, pos)
                end

                if char == "/" or char == "\\" then
                    table.insert(out, file:sub(pos + 1, start - 1))
                end
            end
        end

        return out
    end

    --// GUI \\--
    function ThemeManager:CreateThemeManager(groupbox)
        groupbox:AddLabel("Background color"):AddColorPicker("BackgroundColor", { Default = self.Library.Scheme.BackgroundColor })
        groupbox:AddLabel("Main color"):AddColorPicker("MainColor", { Default = self.Library.Scheme.MainColor })
        groupbox:AddLabel("Accent color"):AddColorPicker("AccentColor", { Default = self.Library.Scheme.AccentColor })
        groupbox:AddLabel("Outline color"):AddColorPicker("OutlineColor", { Default = self.Library.Scheme.OutlineColor })
        groupbox:AddLabel("Font color"):AddColorPicker("FontColor", { Default = self.Library.Scheme.FontColor })

        groupbox:AddDropdown("FontFace", {
            Text = "Font Face",
            Default = self.DefaultFontFace,
            Values = {"BuilderSans", "Code", "Fantasy", "Gotham", "Jura", "Roboto", "RobotoMono", "SourceSans", "ProggySquare", "ProggyClean", "ProggyTiny"}
        })

        groupbox:AddSlider("FontSize", {
            Text = "Font Size",
            Default = self.DefaultFontSize,
            Min = 7,
            Max = 30,
            Rounding = 0,
            Compact = false
        })

        
        local ThemesArray = {}
        for Name, Theme in pairs(self.BuiltInThemes) do
            table.insert(ThemesArray, Name)
        end

        table.sort(ThemesArray, function(a, b) return self.BuiltInThemes[a][1] < self.BuiltInThemes[b][1] end)

        groupbox:AddDivider()

        groupbox:AddDropdown("ThemeManager_ThemeList", { Text = "Theme list", Values = ThemesArray, Default = 1 })
        groupbox:AddButton("Set as default", function()
            self:SaveDefault(self.Library.Options.ThemeManager_ThemeList.Value)
            self.Library:Notify(string.format("Set default theme to %q", self.Library.Options.ThemeManager_ThemeList.Value))
        end)

        self.Library.Options.ThemeManager_ThemeList:OnChanged(function()
            self:ApplyTheme(self.Library.Options.ThemeManager_ThemeList.Value)
        end)

        --[[
        groupbox:AddDivider()

        groupbox:AddInput("ThemeManager_CustomThemeName", { Text = "Custom theme name" })
        groupbox:AddButton("Create theme", function() 
            self:SaveCustomTheme(self.Library.Options.ThemeManager_CustomThemeName.Value)

            self.Library.Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes())
            self.Library.Options.ThemeManager_CustomThemeList:SetValue(nil)
        end)

        groupbox:AddDivider()
        

        groupbox:AddDropdown("ThemeManager_CustomThemeList", { Text = "Custom themes", Values = self:ReloadCustomThemes(), AllowNull = true, Default = 1 })
        ]]

        local MyButton = groupbox:AddButton({
            Text = 'Load theme',
            Func = function()
                local name = self.Library.Options.ThemeManager_CustomThemeList.Value

            self:ApplyTheme(name)
            self.Library:Notify(string.format("Loaded theme %q", name))
            end,
            DoubleClick = false,
        })

        local MyButton2 = MyButton:AddButton({
            Text = 'Overwrite theme',
            Func = function()
                local name = self.Library.Options.ThemeManager_CustomThemeList.Value

            self:SaveCustomTheme(name)
            self.Library:Notify(string.format("Overwrote config %q", name))
            end,
            DoubleClick = false,
        })

        local MyButton = groupbox:AddButton({
            Text = 'Delete theme',
            Func = function()
                local name = self.Library.Options.ThemeManager_CustomThemeList.Value

            local success, err = self:Delete(name)
            if not success then
                return self.Library:Notify("Failed to delete theme: " .. err)
            end

            self.Library:Notify(string.format("Deleted theme %q", name))
            self.Library.Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes())
            self.Library.Options.ThemeManager_CustomThemeList:SetValue(nil)
            end,
                DoubleClick = false,
        })

        local MyButton2 = MyButton:AddButton({
            Text = 'Refresh list',
            Func = function()
                self.Library.Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes())
            self.Library.Options.ThemeManager_CustomThemeList:SetValue(nil)
            end,
            DoubleClick = false,
        })

        local MyButton = groupbox:AddButton({
            Text = 'Set as default',
            Func = function()
                if self.Library.Options.ThemeManager_CustomThemeList.Value ~= nil and self.Library.Options.ThemeManager_CustomThemeList.Value ~= "" then
                self:SaveDefault(self.Library.Options.ThemeManager_CustomThemeList.Value)
                self.Library:Notify(string.format("Set default theme to %q", self.Library.Options.ThemeManager_CustomThemeList.Value))
            end
            end,
                DoubleClick = false,
        })

        local MyButton2 = MyButton:AddButton({
            Text = 'Reset default',
            Func = function()
                local success = pcall(delfile, self.Folder .. "/themes/default.txt")
            if not success then 
                return self.Library:Notify("Failed to reset default: delete file error")
            end
                
            self.Library:Notify("Set default theme to nothing")
            self.Library.Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes())
            self.Library.Options.ThemeManager_CustomThemeList:SetValue(nil)
            end,
            DoubleClick = false,
        })

        local OriginalUiColor = ThemeManager.Library.Scheme.AccentColor
        local RainbowUpdateInterval = 1 / 30

        groupbox:AddToggle("RainbowAccent", {
            Text = "Rainbow ui",
            ToolTip = "Dynamically changes the color of the Ui's accent color",
            Default = false,
            Callback = function(state)
                if state then
                    OriginalUiColor = ThemeManager.Library.Scheme.AccentColor

                    if ThemeManager.RainbowConnection then
                        ThemeManager.RainbowConnection:Disconnect()
                    end

                    local elapsed = 0
                    ThemeManager.RainbowConnection = RunService.Heartbeat:Connect(function(deltaTime)
                        elapsed = elapsed + deltaTime
                        if elapsed < RainbowUpdateInterval then
                            return
                        end

                        elapsed = 0
                        local t = tick() * 0.6
                        local color = Color3.fromHSV((t % 5) / 5, 1, 1)

                        ThemeManager.Library.Scheme.AccentColor = color
                        ThemeManager.Library:UpdateColorsUsingRegistry()
                    end)
                else
                    if ThemeManager.RainbowConnection then
                        ThemeManager.RainbowConnection:Disconnect()
                        ThemeManager.RainbowConnection = nil
                    end

                    ThemeManager.Library.Scheme.AccentColor = OriginalUiColor
                    if ThemeManager.Library.Options.AccentColor then
                        ThemeManager.Library.Options.AccentColor:SetValueRGB(OriginalUiColor)
                    end

                    ThemeManager.Library:UpdateColorsUsingRegistry()
                end
            end
        })

        self:LoadDefault()

        local function UpdateTheme() self:ThemeUpdate() end
        self.Library.Options.BackgroundColor:OnChanged(UpdateTheme)
        self.Library.Options.MainColor:OnChanged(UpdateTheme)
        self.Library.Options.AccentColor:OnChanged(UpdateTheme)
        self.Library.Options.OutlineColor:OnChanged(UpdateTheme)
        self.Library.Options.FontColor:OnChanged(UpdateTheme)
        self.Library.Options.FontFace:OnChanged(function(Value)
            self:ApplyFontFace(Value)
            self.Library:UpdateColorsUsingRegistry()
        end)
        self.Library.Options.FontSize:OnChanged(function(Value)
            self:SetFontSize(Value)
        end)

        local currentFont = self.Library.Options.FontFace.Value or self.DefaultFontFace
        self:ApplyFontFace(currentFont)
    end

    function ThemeManager:CreateGroupBox(tab)
        assert(self.Library, "Must set ThemeManager.Library first!")
        return tab:AddRightGroupbox("Ui Themes", 'paint-bucket')
    end

    function ThemeManager:ApplyToTab(tab)
        assert(self.Library, "Must set ThemeManager.Library first!")
        local groupbox = self:CreateGroupBox(tab)
        self:CreateThemeManager(groupbox)
    end

    function ThemeManager:ApplyToGroupbox(groupbox)
        assert(self.Library, "Must set ThemeManager.Library first!")
        self:CreateThemeManager(groupbox)
    end

    ThemeManager:BuildFolderTree()
end

getgenv().ObsidianThemeManager = ThemeManager
return ThemeManager
