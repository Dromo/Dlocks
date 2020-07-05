import "Turbine"
import "Turbine.Gameplay"

strings = {
    ["rako"] = {"Challenge: Short Fuse"},
    ["embers"] = {"Sigils of Imlad Ithil for Embers"},
    ["quests"] = {"Imlad Morgul: The Reclamation"},
    ["instances"] = {"Imlad Morgul: Vale of Sorcery"},
    ["scourges"] = {"Imlad Morgul: Continued Threats"},
    ["questsn"] = {
        "Deep%-barrow: Bones of Sacrifice",
        "Deep%-barrow: Runes of Corruption",
        "Filth%-well: Lost Relics",
        "Filth%-well: Remnants of Rauniel",
        "Filth%-well: Restoring the Morgulduin",
        "Halls of Black Lore: Gordorian Scrolls",
        "Halls of Black Lore: Morgul Manuscripts",
        "Harrowing of Morgul: Brutal Instruments",
        "Harrowing of Morgul: Untainted Supplies",
        "Houses of Lamentation: Dark Rituals",
        "Houses of Lamentation: Roots of Evil",
        "Houses of Lamentation: The Reserves",
        "Shadow%-roost: Abandoned Eggs",
        "Wanted: Crafter's Steel, Worn Trinkets",
        "Wanted: Deep%-lichen, Smoothed Stones",
        "Wanted: Morgul Plaster, Treated Dowels",
        "Vales of Sorcery: The Trial of"
    },
    ["instancesn"] = {
        "The Harrowing of Morgul",
        "Gath Daeroval, the Shadow%-roost",
        "Gorthad N\195\187r, the Deep%-barrow",
        "Ghashan%-k\195\186tot, the Halls of Black Lore",
        "Eithel Gwaur, the Filth%-well",
        "B\195\162r N\195\173rnaeth, the Houses of Lamentation",
        "The Fallen Kings"
    },
    ["scourgesn"] = {
        "The Cursed Rider, Scourge of Mordor",
        "The Bane of Rh\195\187n, Scourge of Mordor",
        "The Black Blade of Lebennin, Scourge of Mordor",
        "The Forsaken Reaver, Scourge of Mordor",
        "The Gloom of Nurn, Scourge of Mordor",
        "The Grim Southron, Scourge of Mordor",
        "The High Sorcerer of Harad, Scourge of Mordor",
        "The Witch%-king, Lord of the Nazg\195\187l, Scourge of Mordor",
        "The Woe of Khand, Scourge of Mordor",
        "The Court of Song",
        "The Guarded Court",
        "The Joyous Court",
        "The Silver Court"
    },
    ["task"] = {"Completed tasks %((%d+)/10%)"},
    ["wells"] = {"Protectors of Wilderland: Bounties"},
    ["wellsn"] = {
        "Bounty: Goblin at Tithroz",
        "Bounty: Goblin at Scraper's Clough",
        "Bounty: Goblin in the Cabed Rhimdath",
        "Bounty: Goblin at the Forest's Edge",
        "Bounty: Goblin at Veithh\195\179l"
    }

}

day = {["sunday"] = 1, ["monday"] = 2, ["tuesday"] = 3, ["wednesday"] = 4,
    ["thursday"] = 5, ["friday"] = 6, ["saturday"] = 7}

function AddCallback(object, event, callback)
    if (object[event] == nil) then
        object[event] = callback;
    else
        if (type(object[event]) == "table") then
            table.insert(object[event], callback);
        else
            object[event] = {object[event], callback};
        end
    end
    return callback;
end

function RemoveCallback(object, event, callback)
    if (object[event] == callback) then
        object[event] = nil;
    else
        if (type(object[event]) == "table") then
            local size = table.getn(object[event]);
            for i = 1, size do
                if (object[event][i] == callback) then
                    table.remove(object[event], i);
                    break;
                end
            end
        end
    end
end

function dprint(text)
    Turbine.Shell.WriteLine("<rgb=#55AAFF>Dlocks:</rgb> "..text)
end

function derror(text)
    Turbine.Shell.WriteLine("<rgb=#FF0000>Error:</rgb> "..text)
end

if Turbine.Engine.GetLanguage() ~= Turbine.Language.English then
    derror("Dlocks works only on English client.")
    return
end

command = Turbine.ShellCommand()
Turbine.Shell.AddCommand("dlocks",command)
function command:GetShortHelp()
    return("Dlocks - usage: /dlocks setserver | show | reset | set ")
end

function command:GetHelp()
    return([[<rgb=#55AAFF>Dlocks:</rgb>
/dlocks show                   Show progress
         set x/10 x/4 x/8      Manually set progress of current character
         reset (|sunday)        Manually do a weekly reset
         sethour (0-23)        Set a hour at which daily reset happens
         setserver <name>    Set name of the server
         add                  Add this char
         remove <name> <server> Remove char
         set (embers|quests|instances|rako) (0|1|2)]])
end

function command:Execute(cmd, args)
    if args == "show" then
        ShowSettings()
    elseif string.sub(args,1,5) == "reset" then
        local d = string.match(args, "(%a+)",6)
        if d ~= nil then
            if string.lower(d) == "sunday" then
                ResetEmbers()
            end
        else
            ResetSettings()
        end
    elseif string.sub(args,1,7) == "sethour" then
        settings["resets"]["zone"] = string.match(args, "%d+",8)
        settings["resets"]["sunday"] = NextReset(1)
        settings["resets"]["thursday"] = NextReset(5)
        dprint("Automatic resets will hapen at "..settings["resets"]["zone"])
    elseif args == "add" then
        if server ~= nil then
            LoadSettings()
            if type(settings["locks"][server][name]) ~= "table" then
                settings["locks"][server][name] = {}
                mylocks = settings["locks"][server][name]
                mylocks["quests"] = 0
                mylocks["scourges"] = 0
                mylocks["instances"] = 0
                mylocks["questsn"] = 0
                mylocks["scourgesn"] = 0
                mylocks["instancesn"] = 0
                mylocks["embers"] = 0
                mylocks["rako"] = 0
                mylocks["task"]  = 0
                mylocks["wells"] = 0
                mylocks["wellsn"] = 0
            end
        end
    elseif string.sub(args,1,7) == "remove " then
        local ch,s = string.match(args,"(%a+) (%a+)",8)
        error_string = "Deleting "..ch.." from server "..s..": "
        if ch ~= nil then
            if type(settings) == "table" then
                if type(settings["locks"][s]) == "table" then
                    if type(settings["locks"][s][ch]) == "table" then
                        settings["locks"][s][ch] = nil
                        dprint(ch.." on "..s.." removed")
                    else
                        derror(error_string.."character not found.")
                    end
                else
                    derror(error_string.."server not found.")
                end
            end
        end
    elseif string.sub(args,1,4) == "set " then
        if mylocks == nil then
            derror("Character not defined")
            return
        end
        local w,p = string.match(args,"(%a+) (%d+)",5)
        local a,b,c = string.match(args,"(%d+)/10 (%d)/4 (%d)/8",5);
        if w ~= nil then
            mylocks[w] = p
            return
        end
        if a == nil then
            a,b,c = string.match(args,"(%d+) (%d) (%d)",5);
            if a == nil then
                derror("Invalid arguments for /dlocks set")
                return
            end
        end
        a,b,c = tonumber(a),tonumber(b),tonumber(c)
        if 0 <= a and 0 <= b and 0 <= c and a <= 10 and b <= 4 and c <= 8 then
            mylocks["questsn"] = a
            mylocks["instancesn"] = b
            mylocks["scourgesn"] = c
            if 0<a then mylocks["quests"] = 1 end
            if 0<b then mylocks["instances"] = 1 end
            if 0<c then mylocks["scourges"] = 1 end
            if 10==a then mylocks["quests"] = 2 end
            if 4==b then mylocks["instances"] = 2 end
            if 8==c then mylocks["scourges"] = 2 end
        else
            derror("Please enter correct numbers")
        end
    elseif string.sub(args,1,10) == "setserver " then
        server = string.sub(args,11);
        Turbine.PluginData.Save(Turbine.DataScope.Server,"ServerName",server);
        if settings ~= nil and settings["locks"][server] ~= nil then
            derror(server.." already exists!")
        else
            dprint("server set to "..server);
            settings = LoadSettings()
            SaveSettings()
        end
    else
        Turbine.Shell.WriteLine(self:GetHelp())
    end
end

function DeepTableCopy(sourceTable, destTable)
    if (destTable == nil) then
        destTable = {};
    end
    if (type(sourceTable) ~= "table") then
        error("DeepTableCopy(): sourceTable is " .. type(sourceTable), 2);
    elseif (type(destTable) ~= "table") then
        error("DeepTableCopy(): destTable is " .. type(destTable), 2);
    end
    for k, v in pairs(sourceTable) do
        if (type(v) == "table") then
            destTable[k] = { };
            DeepTableCopy(v, destTable[k]);
        else
            destTable[k] = v;
        end
    end
    return destTable;
end

function keys(tableVar)
    if (type(tableVar) ~= "table") then
        error("bad argument to 'keys' (table expected, got "
            .. type(tableVar) .. ")", 2);
    end
    local state = { ["tableVar"] = tableVar, ["index"] = nil };
    local function iterator(state)
        state.index = next(state.tableVar, state.index);
        return state.index;
    end
    return iterator, state, nil;
end

function sorted_keys(tableVar)
    if (type(tableVar) ~= "table") then
        error("bad argument to 'keys' (table expected, got "
            .. type(tableVar) .. ")", 2);
    end
    local state = { ["sortedKeys"] = {}, ["index"] = nil };
    for key in keys(tableVar) do
        table.insert(state.sortedKeys, key);
    end
    local sortFunc = function(a, b)
        if ((type(a) == type(b)) and ((type(a) == "number") or (type(a) == "string"))) then
            return a < b;
        else
            return tostring(a) < tostring(b);
        end
    end
    table.sort(state.sortedKeys, sortFunc);
    local function iterator(state)
        state.index, value = next(state.sortedKeys, state.index);
        return value;
    end
    return iterator, state, nil;
end

function LoadSettings()
    if type(settings) ~= "table" then
        settings = {}
        settings["locks"] = {}
        settings["resets"] = {}
        settings["resets"]["sunday"] = NextReset(1)
        settings["resets"]["thursday"] = NextReset(5)
    end
    if type(settings["locks"][server]) ~= "table" then
        settings["locks"][server] = {}
    end
    return settings
end

function SaveSettings()
    if settings == nil then
        derror("Settings are nil")
    end
    Turbine.PluginData.Save(Turbine.DataScope.Account,"Dlocks",settings);
end

function UpdateCurrency()
    ember = 0
    sigil = 0
    Player = Turbine.Gameplay.LocalPlayer.GetInstance();
    PlayerWallet = Player:GetWallet();
    for i = 1, Player:GetWallet():GetSize() do
        local curItem = Player:GetWallet():GetItem(i);
        if curItem:GetName() == "Embers of Enchantment" then
            ember = curItem:GetQuantity()
        elseif curItem:GetName() == "Sigil of Imlad Ithil" then
            sigil = curItem:GetQuantity()
        end
    end
    return ember, sigil
end

function CurrencyCheck()
    ember, sigil = UpdateCurrency()
    warning = ""
    if ember > 9000 then
        warning = warning .. " " .. ember .. " Embers"
    end
    if sigil > 900 then
        warning = warning .. " " .. sigil .. " Sigils"
    end
    if warning ~= "" then
        dprint("<rgb=#FF8800>Warning!</rgb> You have"..warning)
    end
end

function ShowSettings()
    ember, sigil = UpdateCurrency()
    text = ember.." Embers, "..sigil.." Sigils"
    ln = 0
    for s in sorted_keys(settings["locks"]) do
        for n in sorted_keys(settings["locks"][s]) do
            if ln < string.len(n) then ln = string.len(n) end
        end
    end
    for s in sorted_keys(settings["locks"]) do
        for n in sorted_keys(settings["locks"][s]) do
            t = settings["locks"][s][n]
            if t["wells"] == nil then
                t["wells"] = 0
                t["wellsn"] = 0
            end
            done = false
            tq = tonumber(t["quests"])
            ti = tonumber(t["instances"])
            ts = tonumber(t["scourges"])
            tw = tonumber(t["wells"])
            if tq > 1 and ti > 1 and ts > 1 and tw > 1 then done = true end
            text = text.."\n"
            if string.len(t["questsn"])<2 then text = text.." " end
            text = text..Decor(t["questsn"],tq==2)
            text = text.."/"..Decor2("10",tq).." "
            text = text..Decor(t["instancesn"],ti==2)
            text = text.."/"..Decor2("4",ti).." "
            text = text..Decor(t["scourgesn"],ts==2)
            text = text.."/"..Decor2("8",ts).." "
            text = text..Decor(t["wellsn"],tw==2)
            text = text.."/"..Decor2("5",tw).." "
            text = text..Decor("E",tonumber(t["embers"])==1).." "
            text = text..Decor("R",tonumber(t["rako"])==1).." "
            text = text..Decor(t["task"].."/10",tonumber(t["task"])==10).." "
            if n==name and s==server then
                text = text.."<rgb=#55AAFF>"..n.."</rgb> "
            else
                text = text..n.." "
            end
            for i = 1, ln-string.len(n) do text = text.." " end
            text = text..s
        end
    end
    dprint(text)
end

function Decor(text,condition)
    if condition then return "<rgb=#00FF00>"..text.."</rgb>"
    else return text end
end

function Decor2(text,condition)
    if condition > 1 then return "<rgb=#00FF00>"..text.."</rgb>" end
    if condition == 1 then return "<rgb=#FF7700>"..text.."</rgb>" end
    return text
end

function NextReset(day)
    local curTime = Turbine.Engine.GetLocalTime()
    local curDate = Turbine.Engine.GetDate()
    local zone =  tonumber(settings["resets"]["zone"])
    if zone > 20 then day = day - 1 end
    local reset = curTime + (day - curDate.DayOfWeek) * 24 * 60 * 60
    reset = reset + (zone - curDate.Hour) * 60 * 60
    reset = reset - (reset % 3600)
    if (reset <= curTime) then
        reset = reset + 7 * 24 * 60 * 60
    end
    return reset
end

function ResetSettings()
    for s,t in pairs(settings["locks"]) do
        for n,tt in pairs(t) do
            if tt["quests"] > 1 then
                tt["quests"] = 0
                tt["questsn"] = 0
            end
            if tt["instances"] > 1 then
                tt["instances"] = 0
                tt["instancesn"] = 0
            end
            if tt["scourges"] > 1 then
                tt["scourges"] = 0
                tt["scourgesn"] = 0
            end
            if tt["wells"] > 1 then
                tt["wells"] = 0
                tt["wellsn"] = 0
            end
            tt["rako"] = 0
            if tonumber(tt["task"]) == 10 then
               tt["task"] = 0
            end
        end
    end
    settings["resets"]["thursday"] = NextReset(5)
    dprint("Thursday reset performed.")
end

function ResetEmbers()
    for s,t in pairs(settings["locks"]) do
        for n,tt in pairs(t) do
            tt["embers"] = 0
        end
    end
    settings["resets"]["sunday"] = NextReset(1)
    dprint("Sunday reset performed.")
end

function ResetCheck()
    if type(settings) ~= "table" then return end
    if type(settings["resets"]) ~= "table" then return end
    local time = Turbine.Engine.GetLocalTime()
    if time > settings["resets"]["sunday"] then ResetEmbers() end
    if time > settings["resets"]["thursday"] then ResetSettings() end
end

server = Turbine.PluginData.Load(Turbine.DataScope.Server,"ServerName")
settings = Turbine.PluginData.Load(Turbine.DataScope.Account,"Dlocks")
LocalPlayer = Turbine.Gameplay.LocalPlayer.GetInstance();
name = LocalPlayer:GetName()
if server == nil then
    dprint("<rgb=#FF0000>no server name</rgb> - Please set server name!")
else
    settings = LoadSettings()
    if type(settings["locks"][server][name]) == "table" then
        mylocks = settings["locks"][server][name]
    end
    ResetCheck()
end
tmpLastMessage = ""
cb = AddCallback(Turbine.Chat, "Received", function(sender,args)
    if mylocks ~= nil then
       ResetCheck()
       if args.ChatType == Turbine.ChatType.Quest then
            CurrencyCheck()
            message = args.Message
            if message == tmpLastMessage then
                return
            else
                tmpLastMessage = message
            end
            for cat,tab in pairs(strings) do
                for k,v in pairs(tab) do
                    if string.match(message, v) then
                        if cat == "task" then
                            mylocks[cat] = string.match(message, v)
                        elseif cat == "rako" or cat == "embers" then
                            if string.match(message, "Completed:") then
                                mylocks[cat] = 1
                            end
                        elseif string.sub(cat,-1)=='s' then
                            if string.match(message, "New Quest:") then
                                mylocks[cat] = 1
                            elseif string.match(message, "Completed:") then
                                mylocks[cat] = 2
                            end
                        elseif string.match(message, "Completed:") then
                            qcat = string.sub(cat,1,-2)
                            if tonumber(mylocks[qcat]) == 1 then
                                mylocks[cat] = mylocks[cat] + 1
                            elseif tonumber(mylocks[qcat]) == 0 then
                                dprint("<rgb=#FF8800>Warning!</rgb>"
    .."You have made progress without having the "..strings[qcat][1])
                            end
                        end
                        return
                    end
                end
            end
        end
    end
end)

Plugins["Dlocks"].Unload = function(self,sender,args)
    RemoveCallback(Turbine.Chat, "Received", cb)
    SaveSettings();
end


