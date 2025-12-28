--[[
  MTarget - Menu Functions ($Id$)
  Written by gameldar
  http://www.wowace.com/projects/mtarget

  Thanks to:
    Ace3: Great lib framework
  ]]--


MTarget.icon = LibStub("LibDBIcon-1.0");

local L = LibStub("AceLocale-3.0"):GetLocale("MTarget", true);

function MTarget:Menu_OnInitialize()
  local ldb = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("MTarget", {
	    type = "data source",
	    text = "MTarget",
	    icon = "Interface\\Icons\\Ability_Hunter_MasterMarksman",
	    OnClick = function(clickedframe, button)
	        MTarget:Menu_Show();
	    end,
	});
  MTarget.icon:Register("MTargetDB", ldb, MTarget.db.profile);
  self:Menu_Create();
end

function MTarget:Menu_CreateDialogs()
  StaticPopupDialogs["MTarget_SetVariableString"] = {
    text = L["Set variable name and value string (e.g. spell=Exorcism)"],
    button1 = L["Set"],
    button2 = L["Cancel"],
    hasEditBox = 1,
    whileDead = 1,
    hideOnEscape = 1,
    timeout = 0,
    OnShow = function(self)
      local this = self or _G.this;
      getglobal(this:GetName().."EditBox"):SetText("x=y");
    end,
    OnAccept = function(self)
      local this = self or _G.this;
      variable = getglobal(this:GetName().."EditBox"):GetText();
      MTarget:SetVariableString(variable);
    end
  };
  
end

function MTarget:Menu_Create()
  local menu = CreateFrame("Frame", "MTargetDropMenu", UIParent, "UIDropDownMenuTemplate");
  local menuList = {};

  -- Create a button
  for i = 1, #MTarget.commands do
    local item = MTarget.commands[i];
    if (item.menu) then
      local mitem = {};
      mitem.text = item.menu;
      local func = "Console_Cmd_" .. (item.func or item.id);
      if (item.dialog) then
        func = "MTarget_Dialog_" .. (item.func or item.id);
      end
      if (item.dialog) then
        mitem.func = function() StaticPopup_Show(func); end
      else
        mitem.func = function() MTarget[func](); end
      end
      table.insert(menuList, mitem);
    end
  end
  MTarget.menu = menu;
  MTarget.menuList = menuList;
end

function MTarget:Menu_Show()
  MTarget:Debug("Showing Menu...");
  --MTarget.menu:Show();
  EasyMenu(MTarget.menuList, MTarget.menu, "cursor", 0, 0, "MENU");
end
