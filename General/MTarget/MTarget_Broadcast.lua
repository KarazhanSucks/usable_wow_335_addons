--[[
  MTarget - Broadcast Functions ($Id$)
  Written by gameldar
  http://www.wowace.com/projects/mtarget

  Thanks to:
    Ace3: Great lib framework
  ]]--

local L = LibStub("AceLocale-3.0"):GetLocale("MTarget", true);
  
function MTarget:Broadcast_OnInitialize()
  MTarget:RegisterComm("MTarget");

end

function MTarget:Broadcast_OnEnable()
  if (not MTarget.batchSend) then
    MTarget.batchSend = {};
  end
  if (not MTarget.acceptlist) then
    MTarget.acceptlist = {};
  end
end

function MTarget:Broadcast_CreateDialogs()
  StaticPopupDialogs["MTarget_AcceptBroadcast"] = {
    text = L["%s wants to set %s."],
    button1 = L["Accept"],
    button3 = L["Always"],
    button2 = L["Ignore"],
    whileDead = 1,
    hideOnEscape = 1,
    timeout = 0,
    OnAccept = function()
      MTarget:Broadcast_Set(false);
    end,
    OnAlt = function()
      MTarget:Broadcast_Set(true);
    end
  };
end
  
function MTarget:Console_Cmd_broadcast(variable)
  -- broadcast the variable(s) to the party/raid
  local targ;

  if (IsInRaid()) then
    targ = "RAID";
  elseif (IsInGroup()) then
    targ = "PARTY";
  end
  if (targ) then
    if (variable) then
      local name = MTarget.db.char.variables[variable];
      if (name) then
        MTarget:Broadcast_Target(variable, name);
      else
        MTarget:Print(L["Error: Variable 'X' not assigned"](variable));
      end
    else
      MTarget:SendCommMessage("MTarget", "batchstart", targ);
      for variable,name in pairs(MTarget.db.char.variables) do
        MTarget:Broadcast_Target(variable, name);
      end
      MTarget:SendCommMessage("MTarget", "batchend", targ);
    end
  end
end

function MTarget:Broadcast_Set(remember)
  if (remember) then
    if (not MTarget.acceptlist) then
      MTarget.acceptlist = {};
    end
    MTarget.acceptlist[MTarget.currentTarget.sender] = true;
  end
  
  MTarget:SetVariable(MTarget.currentTarget.variable, MTarget.currentTarget.name, L["Broadcast"]);
end

function MTarget:Console_Cmd_resetbc(input)
  -- reset the broadcast variables
  MTarget.acceptlist = {};
  MTarget.batchSend = {};
end

function MTarget:Broadcast_Target(variable, name)
  local targ;

  if (IsInRaid()) then
    targ = "RAID";
  elseif (IsInGroup()) then
    targ = "PARTY";
  end
  MTarget:Debug("Broadcasting to " .. targ or "nil");
  if (targ) then
    local msg = MTarget:Serialize(variable, name);
    MTarget:Debug("Broadcasting to " .. targ .. ": " .. msg);
    MTarget:SendCommMessage("MTarget", msg, targ);
  end
end

function MTarget:OnCommReceived(prefix, message, distribution, sender)
  MTarget:Debug("Received on " .. prefix .. " from " .. sender .. " msg=" .. message);
  if (prefix == "MTarget" and sender ~= UnitName("player")) then
    if (message == "batchstart") then
      MTarget.batchSend[sender] = true;
    elseif (message == "batchend") then
      MTarget.batchSend[sender] = nil;
      MTarget:Macro_Write(true);
    else
      success, variable, name = MTarget:Deserialize(message);
      if (not success) then
        MTarget:Print(L["Error: failed to deserialize broadcast message: 'X'"](message));
        return;
      end
      MTarget.currentTarget = {};
      MTarget.currentTarget.variable = variable;
      MTarget.currentTarget.name = name;
      MTarget.currentTarget.sender = sender;

      if (MTarget.db.profile.autoaccept or MTarget.acceptlist[sender]) then
        MTarget.db.char.variables[variable] = name;
        if (not MTarget.batchSend[sender]) then
          MTarget:Print(L["Broadcast Set $X='Y'"](variable, name))
          MTarget:Macro_WriteAll(true);
        end
      else
        StaticPopup_Show("MTarget_AcceptBroadcast", sender, variable .. "='" .. name .."'");
      end
    end
  end
end
