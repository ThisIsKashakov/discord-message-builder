# discord-message-builder
---
This is kind of a useless abstraction for sending messages using Discord webhook, but I made this solution for my convenience.
---
## Requirements
---
[`gmsv_reqwest`](https://github.com/WilliamVenner/gmsv_reqwest) or [`gmsv_chttp`](https://github.com/timschumi/gmod-chttp)
---
## Examples of usage
---
**Simple example**
```lua
local logs = include("libs/message-builder.lua")
local url = "" -- enter webhook url
logs:new()
:Init(url)
:AddContent("hi!") -- add simple text message
:SetUsername("garry")
:SetAvatar("https://i.imgur.com/y7BOnm5.jpg")
:Embed() -- start build embed
:SetTitle("Embed title")
:SetDescription("Embed description")
:SetColor(Color(58, 134, 255))
:Author() -- start build author field
:SetName("idk")
:SetURL("https://steamcommunity.com/id/garry/")
:SetIcon("https://i.imgur.com/y7BOnm5.jpg")
:Build() -- end build author field
:Footer() -- start build footer field
:SetText("footer text")
:SetIcon("https://i.imgur.com/y7BOnm5.jpg")
:Build() -- end build footer field
:Field() -- start build embed field 1
:SetName("embed field name")
:SetValue("embed field value")
:Inline(true)
:Build() -- end build embed field 1
:Field() -- start build embed field 2
:SetName("embed field name 2")
:SetValue("embed field value 2")
:Inline(true)
:Build() -- end build embed field 2
:Image("https://i.imgur.com/Rj7LbDY.png")
:Thumbnail("https://i.imgur.com/Rj7LbDY.png")
:Timestamp()
:Build() -- end build embed
:Send()
```
**Relay chat**
```lua
local logs = include("libs/message-builder.lua")
local builder = logs:new()

local mt = FindMetaTable("Player")

function mt:GetAvatar(callback)
    local url = "https://steamcommunity.com/profiles/" .. self:SteamID64() .. "?xml=1"

    http.Fetch(url, function(content)
        local avatar = string.match(content, "<avatarFull><!%[CDATA%[(.-)%]%]></avatarFull>")

        if not avatar or #avatar < 1 then
            avatar = "https://i.imgur.com/5Bj3tOU.png"
        end

        callback(avatar)
    end)
end

local url = "" -- enter webhook url

hook.Add("PlayerSay", "say.log", function(pl, text)
    if not IsValid(pl) then return end
    local nick = pl:Nick()
    local message = builder:Init(url)
    message:AddContent(text)
    message:SetUsername(nick)

    if not pl.avatar then
        pl:GetAvatar(function(avatar)
            message:SetAvatar(avatar)
            message:Send()
            pl.avatar = avatar
        end)
    else
        message:SetAvatar(pl.avatar)
        message:Send()
    end
end)
```
**Connection logs**
```lua
local logs = include("libs/message-builder.lua")
local builder = logs:new()

local url = "" -- enter webhook url

gameevent.Listen("player_connect")

hook.Add("player_connect", "connect.logs", function(data)
    local bot = data["bot"]
    if bot == 1 then return end
    local steamid = data["networkid"]
    local ip = data["address"]
    local name = data["name"]
    local message = builder:Init(url)
    message:SetUsername("chad cat.")
    message:SetAvatar("https://i.imgur.com/nrlBK05.jpg")
    local embed = message:Embed()
    embed:SetTitle("`New connection!`")
    embed:SetColor(Color(58, 134, 255))
    :Field():SetName("**Name**"):SetValue("`" .. name .. "`"):Inline(true):Build()
    :Field():SetName("**SteamID**"):SetValue("[" .. steamid .. "](https://steamid.io/lookup/" .. steamid .. ")"):Inline(true):Build()
    :Field()
    :SetName("**SteamID64**"):SetValue("[" .. util.SteamIDTo64(steamid) .. "](https://steamid.io/lookup/" .. util.SteamIDTo64(steamid) .. ")"):Inline(true):Build()
    :Field():SetName("IP"):SetValue("||[" .. ip .. "](https://check-host.net/ip-info?host=" .. string.Explode(":", ip)[1] .. ")||"):Inline(true):Build()
    :Timestamp()
    :Build():Send()
end)
```
---