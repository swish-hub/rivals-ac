-- github.com/swish-hub/rivals-ac
-- this is a BETA anti-cheat. If you wish to contribute on this, add jckie_swish on Discord
-- open source because i felt like it
--[[ old ac
local plrs = game:GetService("Players")
local rf = game:GetService("ReplicatedFirst")
local lp = plrs.LocalPlayer

print("bypass started")

-- Fake ClientAlert RemoteEvent the game tries to use upon loading
local fake = Instance.new("RemoteEvent")
fake.Name = "ClientAlert"
fake.Parent = lp

-- Spoof WaitForChild("ClientAlert") which the result from the LoadingScreen wanted to get
-- this is important because anti-cheat also uses LoadingScreen
local pmt = getrawmetatable(lp)
local oldnc = pmt.__namecall
setreadonly(pmt, false)
pmt.__namecall = newcclosure(function(self, ...)
    if getnamecallmethod() == "WaitForChild" and select(1, ...) == "ClientAlert" then
        return fake
    end
    return oldnc(self, ...)
end)
setreadonly(pmt, true)

-- Block :Kick and ClientAlert:FireServer in case it gets used (keep it it might be useful)
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local m = getnamecallmethod()
    
    if self == lp and (m == "Kick" or m == "kick") then return end
    if m:lower():find("kick") or m == "Shutdown" then return end
    if m == "FireServer" and self == fake then
        print("Blocked ClientAlert:FireServer")
        return
    end
    return old(self, ...)
end)
setreadonly(mt, true)

-- Neutered anti-cheat functions in LoadingScreen and LocalScript3 >> LocalScript3 is the anti-cheat
local ls3 = rf:WaitForChild("LocalScript3", 10)
local c = 0
for _, f in getgc(false) do
    if typeof(f) == "function" then
        local ok, e = pcall(getfenv, f)
        if ok and e then
            local scr = rawget(e, "script")
            if scr and (scr == ls3 or tostring(scr):find("LoadingScreen")) then
                local ok2, cs = pcall(debug.getconstants, f)
                if ok2 then
                    for _, k in cs do
                        if typeof(k) == "string" and (k:find("TakeTheL") or k:find("ban") or k:find("kick")) then -- TakeTheL is found in the decompiled LocalScript3 result
                            hookfunction(f, function() end)
                            c = c + 1
                            print("killed", tostring(scr), "→", k)
                            break
                        end
                    end
                end
            end
        end
    end
end

print("neutered", c, "funcs")
print("bypass done") ]]--

-- many people say this still works so try this
local oldtable; oldtable = hookfunction(getrenv().setmetatable, newcclosure(function(Table, Metatable)
    if Metatable and typeof(Metatable) == "table" and rawget(Metatable, "__mode") == "kv" then
        local trace = debug.traceback()
        if trace:find("LocalScript3") or trace:find("MiscellaneousController") then
            return oldtable({1, 2, 3}, {})
        end
    end
    return oldtable(Table, Metatable)
end)) -- milkyboys shit ( he mightve skidded it idk )

local oldgc = getgc; getgc = function(...)
    local gc = oldgc(...)
    local filtered = {}
    for _, v in ipairs(gc) do
        if typeof(v) == "function" then
            local src = debug.info(v, "s")
            if not (src and (src:find("LocalScript3") or src:find("MiscellaneousController"))) then
                table.insert(filtered, v)
            end
        else
            table.insert(filtered, v)
        end
    end
    return filtered
end

for _, v in getgc() do -- lowk not needed
    if typeof(v) == "function" then
        local src = debug.info(v, "s")
        if src and (src:find("LocalScript3") or src:find("MiscellaneousController")) then
            hookfunction(v, newcclosure(function()
                return task.wait(9e9)
            end))
        end
    end
end
