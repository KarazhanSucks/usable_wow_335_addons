--[[
  MTarget ($Id: MTarget.lua 59 2010-09-16 22:34:40Z gameldar $)
  Written by gameldar
  http://www.wowace.com/projects/mtarget

  Thanks to:
    Ace3: Great lib framework
  ]]--

local version = {};
version.major = 2;
version.minor = 1.7;
version.build = "$Id: MTarget.lua 59 2010-09-16 22:34:40Z gameldar $";
version.version = version.major .. "." .. version.minor .. " (" .. version.build .. ")";
version.fullversion = "MTarget " .. version.version;

MTarget = LibStub("AceAddon-3.0"):NewAddon("MTarget", 
                                           "AceConsole-3.0",
                                           "AceHook-3.0",
                                           "AceComm-3.0",
                                           "AceEvent-3.0",
                                           "AceSerializer-3.0");
                                           
local L = LibStub("AceLocale-3.0"):GetLocale("MTarget", true);



function MTarget:OnInitialize()
  -- initialize the MTarget addon when first loaded
  MTarget.db = LibStub("AceDB-3.0"):New("MTargetDB");
  
  MTarget:Console_OnInitialize();
  MTarget:Config_OnInitialize();
  MTarget:Menu_OnInitialize();
  MTarget:PopupMenu_OnInitialize();
  MTarget:Macro_OnInitialize();
  MTarget:Broadcast_OnInitialize();
  MTarget:RaidIcons_OnInitialize();
  
  --MTarget:Console_CreateDialogs();
  --MTarget:Config_CreateDialogs();
  MTarget:Menu_CreateDialogs();
  MTarget:PopupMenu_CreateDialogs();
  MTarget:Macro_CreateDialogs();
  MTarget:Broadcast_CreateDialogs();
  --MTarget:RaidIcons_CreateDialogs();
  MTarget:Print(L["Initialized X"](version.version));
end

function MTarget:OnEnable()
  --MTarget:Console_OnEnable();
  MTarget:Config_OnEnable();
  --MTarget:Menu_OnEnable();
  MTarget:PopupMenu_OnEnable();
  MTarget:Macro_OnEnable();
  MTarget:Broadcast_OnEnable();
  --MTarget:RaidIcons_OnEnable();
  
  MTarget:Debug("Enabled");
end

function MTarget:Debug(format, ...)
  if (MTarget.db.profile.debug) then
    MTarget:Print(format, ...);
  end
end

function MTarget:SetVariable(variable, name, context)
  if (not context) then
    context = "";
  else
    context = context .. " ";
  end
  
  MTarget.db.char.variables[variable] = name;
  
  MTarget.db.char.vnames[variable] = true;
  
  MTarget:Print(L["%sSet $%s='%s'"](variable, name, context));
  
  MTarget:Macro_WriteAll(true);
  
  if (MTarget.db.profile.broadcast) then
    MTarget:Broadcast_Target(variable, name);
  end
  MTarget:PopupMenu_Update();
end

function MTarget:Console_Cmd_list()
  -- print out the current name=value pairs
  for variable,name in pairs(MTarget.db.char.variables) do
    MTarget:Print(variable .. "=" .. name);
  end
end

function MTarget:Console_Cmd_clear(input)
  if (input) then
    if (MTarget.db.char.variables[input]) then
      MTarget.db.char.variables[input] = nil;
      MTarget:Print(L["Cleared variable: '%s'"](input));
    else
      MTarget:Print(L["No such variable: '%s'"](input));
    end
  else
    MTarget.db.char.variables = {};
    MTarget.db.char.vnames = {};
    MTarget:Macro_GetVariableNamesFromTemplates();
    MTarget:Print(L["Cleared all variables"]);
  end
  MTarget:PopupMenu_Update();
end
