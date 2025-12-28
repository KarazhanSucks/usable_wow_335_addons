---- CONFIG ----
  
--[[
Commenting out:
if aUser~=UnitName("player") then return end
will result in everyone's interrupts being announced.

Changing:
    local intsaymsg = "Interrupted: "..destName.. "'s " ..GetSpellLink(spellID).. "."
will change the message. Variables are aUser, destName, and GetSpellLink(spellID)

Verbose Method: 
"=> I Interrupted "..destName.."'s "..GetSpellLink(spellID).."."

---------------------------------------------------------------- 
]]--

-- END CONFIG --
print("|c00bfffffI Interrupted That -- /iit for more.|r")

local InterruptSay = CreateFrame("Frame")

local function OnEvent(self, event, ...)
	local dispatch = self[event]

	if dispatch then
		dispatch(self, ...)
	end
end

--local InterruptSayDB = InterruptSayDB

InterruptSay:SetScript("OnEvent", OnEvent)
InterruptSay:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
InterruptSay:RegisterEvent("ADDON_LOADED")

function InterruptSay:ADDON_LOADED(...)
    if (event=="ADDON_LOADED") and (arg1=="InterruptSay") then
    --print("variables were loaded.")
    self:UnregisterEvent("ADDON_LOADED")
    --print("event was unregistered.")
    if not InterruptSayDB then
    InterruptSayDB= {
    intsayonoff = 1,
    INTSAYOUTPUT = 'Say',
    Verbose = 1,
    msg = ("=> I Interrupted That: MobName's [SpellLink]."),
    }
    end
end
end

function verbtog()
	if InterruptSayDB.Verbose==1 then
		InterruptSayDB.Verbose=0
		print("|c00bfffffI Interrupted That - Verbose is off.|r")
	else
		InterruptSayDB.Verbose=1
		print("|c00bfffffI Interrupted That - Verbose is on.|r")
	end
end

function InterruptSay:COMBAT_LOG_EVENT_UNFILTERED(...)
local inParty = GetNumPartyMembers()>=1
local inRaid = GetNumRaidMembers()>=5
local aEvent = select(2, ...)
local aUser = select(4, ...)
local destName = select(7, ...)
local spellID = select(12, ...)
	if InterruptSayDB.intsayonoff==1 then
if inParty then xxx="PARTY" end
if inRaid then xxx="RAID" end
    if aEvent=="SPELL_INTERRUPT" then
    if aUser~=UnitName("player") then return end 
if InterruptSayDB.Verbose~=1 then 
    intsaymsg = ("Interrupted: "..destName.. "'s " ..GetSpellLink(spellID).. ".")
    InterruptSayDB.msg = ("Interrupted: MobName's [SpellLink].")
    else
    intsaymsg = ("=> I Interrupted That: "..destName.. "'s " ..GetSpellLink(spellID).. ".")
    InterruptSayDB.msg = ("=> I Interrupted That: MobName's [SpellLink].")
    end
        if InterruptSayDB.INTSAYOUTPUT=='Self' then
            print(intsaymsg)
        elseif InterruptSayDB.INTSAYOUTPUT=='Say' then
            SendChatMessage(intsaymsg, "SAY")
        elseif InterruptSayDB.INTSAYOUTPUT=='Auto' then 
            if (not inParty) and (not inRaid) then
                print(intsaymsg)
            else SendChatMessage(intsaymsg, xxx)
            end
        end
    end
end end

function toggleon()
	if InterruptSayDB.intsayonoff==1 then
		InterruptSayDB.intsayonoff=0
		print("|c00bfffffI Interrupted That is now off.|r")
	else
		InterruptSayDB.intsayonoff=1
		print("|c00bfffffI Interrupted That is now on.|r")
	end
end

SLASH_IIT1="/iit"
SlashCmdList["IIT"] =
	function(msg)
		local a1 = gsub(msg, "%s*([^%s]+).*", "%1");
		local a2 = gsub(msg, "%s*([^%s]+)%s*(.*)", "%2");
        local outputlist = "|c00bfffff say [] self [] auto |r"
        local list = "|c00bfffffinfo [] toggle [] verbose []|r" ..outputlist
        local omgrly = "|c00bfffffOutput is: |r"
    --print("a1: "..a1.." a2: "..a2)
if (a1 == "") then print(list) end
if (a1 == "info") or (a1 == "Info") then print(list)
    if InterruptSayDB.intsayonoff~=1 then print("|c00bfffffI Interrupted That is off.|r") else print(omgrly, InterruptSayDB.INTSAYOUTPUT) 
    if InterruptSayDB.Verbose~=1 then print("|c00bfffffVerbose is: |rOFF") else print("|c00bfffffVerbose is: |rON") end end end
if (a1 == "toggle") then toggleon() end
    if (a1 == "Say") or (a1 == "say") then InterruptSayDB.INTSAYOUTPUT = 'Say' print(omgrly, InterruptSayDB.INTSAYOUTPUT)
    elseif (a1 == "Self") or (a1 == "self") then InterruptSayDB.INTSAYOUTPUT = 'Self' print(omgrly, InterruptSayDB.INTSAYOUTPUT)
    elseif (a1 == "Auto") or (a1 == "auto") then InterruptSayDB.INTSAYOUTPUT = 'Auto' print(omgrly, InterruptSayDB.INTSAYOUTPUT) end
if (a1 == "verbose") then verbtog()
    end
if (a1 == "msg") then print("|c00bfffff"..InterruptSayDB.msg)
    end
end   