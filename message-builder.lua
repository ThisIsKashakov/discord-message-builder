do
    if not reqwest and not CHTTP then
        local suffix = ({"osx64", "osx", "linux64", "linux", "win64", "win32"})[(system.IsWindows() and 4 or 0) + (system.IsLinux() and 2 or 0) + (jit.arch == "x86" and 1 or 0) + 1]

        local fmt = "lua/bin/gmsv" .. "_%s_%s.dll"

        local function installed(name)
            if file.Exists(string.format(fmt, name, suffix), "GAME") then return true end
            if jit.versionnum ~= 20004 and jit.arch == "x86" and system.IsLinux() then return file.Exists(string.format(fmt, name, "linux32"), "GAME") end

            return false
        end

        if installed("reqwest") then
            require("reqwest")
        end

        if not reqwest and installed("chttp") then
            require("chttp")
        end

        if not reqwest and not CHTTP then
            error("reqwest or CHTTP is required to use this!")
        end
    end
end

local request = reqwest or CHTTP

local function hexdec(r, g, b)
    r = bit.band(bit.lshift(r, 16), 0xFF0000)
    g = bit.band(bit.lshift(g, 8), 0x00FF00)
    b = bit.band(b, 0x0000FF)

    return bit.bor(bit.bor(r, g), b)
end

local meta = {}

function meta:Init(url)
    self.url = url
    self.body = {}

    return self
end

function meta:AddContent(text)
    self.body.content = text

    return self
end

function meta:Embed()
    if not self.body.embeds then
        self.body.embeds = {}
    end

    self.body.embeds[#self.body.embeds + 1] = {}
    local embed = self.body.embeds[#self.body.embeds]
    local mt = self

    function embed:SetTitle(text)
        self.title = text

        return self
    end

    function embed:SetDescription(text)
        self.description = text

        return self
    end

    function embed:SetColor(col)
        local dec = hexdec(col.r, col.g, col.b)
        self.color = dec

        return self
    end

    function embed:Author()
        self.author = {}
        local author = self.author

        function author:SetName(name)
            self.name = name

            return self
        end

        function author:SetURL(url)
            self.url = url

            return self
        end

        function author:SetIcon(icon)
            self.icon_url = icon

            return self
        end

        function author:Build()
            return embed
        end

        return author
    end

    function embed:Footer()
        self.footer = {}
        local footer = self.footer

        function footer:SetText(text)
            self.text = text

            return self
        end

        function footer:SetIcon(icon)
            self.icon_url = icon

            return self
        end

        function footer:Build()
            return embed
        end

        return footer
    end

    function embed:Field()
        if not self.fields then
            self.fields = {}
        end

        self.fields[#self.fields + 1] = {}
        local field = self.fields[#self.fields]

        function field:SetName(name)
            self.name = name

            return self
        end

        function field:SetValue(value)
            self.value = value

            return self
        end

        function field:Inline(value)
            self.inline = value

            return self
        end

        function field:Build()
            return embed
        end

        return field
    end

    function embed:Image(url)
        self.image = {}
        self.image.url = url

        return self
    end

    function embed:Thumbnail(url)
        self.thumbnail = {}
        self.thumbnail.url = url

        return self
    end

    function embed:Timestamp()
        local hour = os.date("!%H")
        local day = os.date("!%d")
        self.timestamp = os.date("%Y-%m-" .. day .. "T" .. hour .. ":%M:00.000Z")

        return self
    end

    function embed:Build()
        return mt
    end

    return embed
end

function meta:SetUsername(name)
    self.body.username = name

    return self
end

function meta:SetAvatar(url)
    self.body.avatar_url = url

    return self
end

function meta:Send()
    self.body = istable(self.body) and util.TableToJSON(self.body) or self.body
    request(self)
end

local lib = {}

function lib:new()
    if not self.instances then
        self.instances = {}
    end

    local object = {
        method = "post",
        type = "application/json;charset=utf-8",
        headers = {
            ["User-Agent"] = "",
        },
        url = "",
        body = {},
        failed = function(err)
            print("Error", err)
        end,
        success = function(code, response)
            if code ~= 204 then
                print("Error code", code)
                print("Error response", response)
            end
        end,
    }

    setmetatable(object, {
        __index = meta
    })

    self.instances[#self.instances + 1] = object

    return self.instances[#self.instances]
end

return lib