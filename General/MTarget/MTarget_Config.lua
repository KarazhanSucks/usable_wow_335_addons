--[[
  MTarget - Config Functions ($Id$)
  Written by gameldar
  http://www.wowace.com/projects/mtarget

  Thanks to:
    Ace3: Great lib framework
  ]]--

local L = LibStub("AceLocale-3.0"):GetLocale("MTarget", true);

function MTarget:Config_OnInitialize()
local options = {
        name = "MTarget",
        handler = MTarget,
        hidden = false,
        type = 'group',
        args = {
	        autowrite = {
	            type = 'toggle',
	            name = L['Auto Write Macros'],
	            desc = L['Rewrite the macros when a variable is changed.'],
	            set = 'SetAutoWrite',
	            get = 'GetAutoWrite',
	        },
	        showtooltips = {
	            type = 'toggle',
	            name = L['Show Tooltips'],
	            desc = L['Show tooltips on menu items.'],
	            set = 'SetShowTooltips',
	            get = 'GetShowTooltips',
	        },
	        broadcast = {
	            type = 'toggle',
	            name = L['Broadcast variables'],
	            desc = L['Broadcast variables to party or raid'],
	            set = 'SetBroadcast',
	            get = 'GetBroadcast',
	        },
	        autoaccept = {
	            type = 'toggle',
	            name = L['Auto accept Broadcasts'],
	            desc = L['Always accept broadcast from party/raid members'],
	            set = 'SetAutoAccept',
	            get = 'GetAutoAccept',
	        },
	        raidtargets = {
	            type = 'toggle',
	            name = L['Assign Raid Icons'],
	            desc = L['Automatically assign raid icons to varibles when you set them ("$star","$circle","$diamond","$triangle","$moon","$square","$cross","$skull")'],
	            set = 'SetRaidTargets',
	            get = 'GetRaidTargets',
	        },
	        debug = {
	            type = 'toggle',
	            name = L['Debug'],
	            desc = L['Enable debug output'],
	            set = 'SetDebug',
	            get = 'GetDebug',
	        },
		hide = {
		    type = 'toggle',
		    name = L['Hide Minimap Icon'],
		    desc = L['Hide the minimap icon'],
		    set = 'SetMinimap',
		    get = 'GetMinimap',
		},
        },
    };
    
  options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(MTarget.db);
  
  config = LibStub("AceConfig-3.0");
  MTarget.configdialog = LibStub("AceConfigDialog-3.0");
  config:RegisterOptionsTable("MTarget", options, {"mtargconf"});
  MTarget.configdialog:SetDefaultSize("MTarget", 1000, 600);

  config:RegisterOptionsTable( "MTarget", options )
  MTarget.configdialog:AddToBlizOptions( "MTarget", "MTarget")
  
end

function MTarget:Config_OnEnable()
  if (not MTarget.db.char.variables) then
    MTarget.db.char.variables = {};
  end

  if (not MTarget.db.char.templates) then
    MTarget.db.char.templates = {};
  end
  
  if (not MTarget.db.char.vnames) then
    MTarget.db.char.vnames = {};
  end
  
  if (not MTarget.db.profile) then
    MTarget.db.profile = {}
    MTarget.db.profile.autowrite = true;
    MTarget.db.profile.debug = false;
    MTarget.db.profile.hide = false;
  end
end

function MTarget:SetAutoWrite(info, input)
  MTarget.db.profile.autowrite = input
end

function MTarget:GetAutoWrite(info)
  return MTarget.db.profile.autowrite
end

function MTarget:SetShowTooltips(info, input)
  MTarget.db.profile.showtooltips = input
end
function MTarget:GetShowTooltips(info)
  return MTarget.db.profile.showtooltips
end

function MTarget:SetBroadcast(info, input)
  MTarget.db.profile.broadcast = input
end
function MTarget:GetBroadcast(info)
  return MTarget.db.profile.broadcast
end
function MTarget:SetAutoAccept(info, input)
  MTarget.db.profile.autoaccept = input
end
function MTarget:GetAutoAccept(info)
  return MTarget.db.profile.autoaccept
end
function MTarget:SetRaidTargets(info, input)
  MTarget.db.profile.raidtargets = input
end
function MTarget:GetRaidTargets(info)
  return MTarget.db.profile.raidtargets
end
function MTarget:SetDebug(info, input)
  MTarget.db.profile.debug = input
end
function MTarget:GetDebug(info)
  return MTarget.db.profile.debug
end
function MTarget:SetMinimap(info, input)
  MTarget.db.profile.hide = input
  if input then
    MTarget.icon:Hide("MTargetDB")
  else
    MTarget.icon:Show("MTargetDB")
  end
end
function MTarget:GetMinimap(info)
  return MTarget.db.profile.hide
end

function MTarget:Console_Cmd_config(input)
  InterfaceOptionsFrame_OpenToCategory("MTarget");
end

