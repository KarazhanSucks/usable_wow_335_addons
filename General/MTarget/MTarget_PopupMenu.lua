--[[
  MTarget - PopupMenu Integration Functions ($Id$)
  Written by gameldar
  http://www.wowace.com/projects/mtarget

  Thanks to:
    Ace3: Great lib framework
  ]]--


local L = LibStub("AceLocale-3.0"):GetLocale("MTarget", true);

function MTarget:PopupMenu_OnInitialize()
  UnitPopupButtons["MTARGET"] = {text = "MTarget", dist = 0, tooltipText = L["Set MTarget variables"], nested = 1};
  tinsert(UnitPopupMenus["PLAYER"], #UnitPopupMenus["PLAYER"] - 1, "MTARGET");
  tinsert(UnitPopupMenus["FRIEND"], #UnitPopupMenus["FRIEND"] - 1, "MTARGET");
  tinsert(UnitPopupMenus["TARGET"], #UnitPopupMenus["TARGET"] - 1, "MTARGET");
  tinsert(UnitPopupMenus["SELF"], #UnitPopupMenus["SELF"] - 1, "MTARGET");
  tinsert(UnitPopupMenus["PET"], #UnitPopupMenus["PET"] - 1, "MTARGET");
  tinsert(UnitPopupMenus["PARTY"], #UnitPopupMenus["PARTY"] - 1, "MTARGET");
  tinsert(UnitPopupMenus["RAID"], #UnitPopupMenus["RAID"] - 1, "MTARGET");
  
  UnitPopupButtons["MTARGET_NEWDOTDOTDOT"] = {text = L["New..."], dist = 0, tooltipText = L["Create a new variable assigned to this name"]};
  MTarget:SecureHook("UnitPopup_OnClick");
  MTarget:SecureHook("UnitPopup_ShowMenu");
end

function MTarget:PopupMenu_OnEnable()
  MTarget:PopupMenu_Update();
end

function MTarget:PopupMenu_CreateDialogs()
  StaticPopupDialogs["MTarget_Dialog_SetVariable"] = {
    text = L["Set variable for %s"],
    button1 = L["Save"],
    button2 = L["Cancel"],
    hasEditBox = 1,
    whileDead = 1,
    hideOnEscape = 1,
    timeout = 0,
    OnShow = function(self)
      local this = self or _G.this;
      getglobal(this:GetName().."EditBox"):SetText("");
    end,
    OnAccept = function(self)
      local this = self or _G.this;
      local variable = getglobal(this:GetName().."EditBox"):GetText();
      MTarget:SetVariable(variable, MTarget.currentTarget.name);
    end,
  };
  StaticPopupDialogs["MTarget_Dialog_set"] = {
    text = L["Set variable in the form x=y"],
    button1 = L["Save"],
    button2 = L["Cancel"],
    hasEditBox = 1,
    whileDead = 1,
    hideOnEscape = 1,
    timeout = 0,
    OnShow = function(self)
      local this = self or _G.this;
      getglobal(this:GetName().."EditBox"):SetText("");
    end,
    OnAccept = function(self)
      local this = self or _G.this;
      local variable = getglobal(this:GetName().."EditBox"):GetText();
      MTarget:Console_Cmd_set(variable);
    end,
  };
end

function MTarget:UnitPopup_ShowMenu(dropdownMenu, which, unit, name, userData)
  if ( unit ) then
    name, server = UnitName(unit);
  elseif ( name ) then
    local n, s = strmatch(name, "^([^-]+)-(.*)");
    if ( n ) then
      name = n;
      server = s;
    end
  end
  if (not MTarget.currentTarget) then
    MTarget.currentTarget = {};
  end
  MTarget.currentTarget.name = name;
  MTarget:Debug(L["Current target: X"](name));
end

function MTarget:PopupMenu_Update()
  local popupnames = { "MTARGET_NEWDOTDOTDOT" };
  local variable;
  for variable, set in pairs(MTarget.db.char.vnames) do
    menuname = "MTARGET_" .. variable;
    MTarget:Debug("Menuname: " .. menuname);
    UnitPopupButtons[menuname] = { text = variable, dist = 0, tooltipTtext = L["Set variable X"](variable) };
    tinsert(popupnames, #popupnames, menuname);
  end
  for index = 1,#popupnames do
    MTarget:Debug("[" .. index .. "]: " .. popupnames[index]);
  end
  UnitPopupMenus["MTARGET"] = popupnames;
end

function MTarget:UnitPopup_OnClick(self)
  local button = self.value;
  if (button == "MTARGET_NEWDOTDOTDOT") then
    StaticPopup_Show("MTarget_Dialog_SetVariable", MTarget.currentTarget.name);
  elseif (string.sub(button,1,8)=="MTARGET_" and button ~= "MTARGET") then
    MTarget:SetVariable(string.sub(button,9), MTarget.currentTarget.name);
  end
end
