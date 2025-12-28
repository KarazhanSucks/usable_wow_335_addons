--[[
  MTarget - Macro Functions ($Id$)
  Written by gameldar
  http://www.wowace.com/projects/mtarget

  Thanks to:
    Ace3: Great lib framework
  ]]--

local L = LibStub("AceLocale-3.0"):GetLocale("MTarget", true);

function MTarget:Macro_OnInitialize()

end
function MTarget:Macro_OnEnable()
  if (not MTarget.db.char.templates) then
    MTarget.db.char.templates = {};
  end
  MTarget:RegisterEvent("ADDON_LOADED","AddOnLoaded");
end

function MTarget:Macro_CreateDialogs()
  StaticPopupDialogs["MTarget_ResetTemplateConfirm"] = {
    text = L["Reset macro to template value for: %s"],
    button1 = L["Reset"],
    button2 = L["Cancel"],
    whileDead = 1,
    hideOnEscape = 1,
    timeout = 0,
    OnAccept = function()
      MTarget:Macro_ResetTemplates(MTarget.resetTemplate, true);
    end
  };
  StaticPopupDialogs["MTarget_DeleteTemplateConfirm"] = {
    text = L["Delete template: %s"],
    button1 = L["Delete"],
    button2 = L["Cancel"],
    whileDead = 1,
    hideOnEscape = 1,
    timeout = 0,
    OnAccept = function()
      MTarget:Console_Cmd_deletetemplate(MTarget.deleteTemplate, true);
    end
  };
end

function MTarget:AddOnLoaded(event, name)
  if (name == "Blizzard_MacroUI") then
    MTarget:Macro_InitButton();
  end
end

function MTarget:Macro_InitButton()
  macroDelete = getglobal("MacroDeleteButton");
  MTarget.createTemplateButton = CreateFrame("Button", "MTarget_CreateTemplateButton", macroDelete:GetParent(), "UIPanelButtonGrayTemplate");
  MTarget.createTemplateButton:SetText(L["Template"]);
  MTarget.createTemplateButton:SetScript("OnClick", MTarget["CreateTemplateButtonOnClick"]);
  MTarget.createTemplateButton:SetHeight(22);
  MTarget.createTemplateButton:SetWidth(80);
  MTarget.createTemplateButton:ClearAllPoints();
  MTarget.createTemplateButton:SetPoint("BOTTOMLEFT", "MacroFrame", "BOTTOMLEFT", 97, 79);
  MTarget:SecureHook("MacroFrame_Update");
end

function MTarget:MacroFrame_Update()
  if (MacroFrame.selectedMacro ~= nil) then
    MTarget.createTemplateButton:Enable();
  else
    MTarget.createTemplateButton:Disable();
  end
end

function MTarget:CreateTemplateButtonOnClick(targ, button)
  if (MacroFrame.selectedMacro ~= nil) then
    MTarget:Macro_CreateTemplateFromIndex(MacroFrame.selectedMacro);
  end
end

function MTarget:Console_Cmd_createtemplate(input)
  -- create a macro template from an existing macro
  local macroIndex = GetMacroIndexByName(input);
  if (macroIndex == nil) then
    MTarget:Print(L["Error: no such macro 'X'"](input));
    return;
  end
  MTarget:Macro_CreateTemplateFromIndex(macroIndex);
end

function MTarget:Macro_CreateTemplateFromIndex(macroIndex)
  local macroText = GetMacroBody(macroIndex);
  local name, iconTexture, body, localVar = GetMacroInfo(macroIndex);
  MTarget.db.char.templates[name] = macroText;
  MTarget:Macro_GetVariableNamesFromTemplate(macroText);
  MTarget:PopupMenu_Update();
  MTarget:Print(L["Created template from macro[X]: Y"](macroIndex, name));
end

function MTarget:Macro_GetVariableNamesFromTemplate(txt)
  local variable;
  for variable in string.gmatch(txt, "\$(%w+)") do
    MTarget.db.char.vnames[variable] = true;
  end
end

function MTarget:Macro_GetVariableNamesFromTemplates()
  local name;
  local txt;
  for name,txt in pairs(MTarget.db.char.templates) do
    MTarget:Macro_GetVariableNamesFromTemplate(txt);
  end
  MTarget:PopupMenu_Update();
end


function MTarget:Console_Cmd_write(input)
  MTarget:Macro_WriteAll();
end

function MTarget:Macro_WriteAll(check, variables)
  -- write out the macros replacing all the values with the name/value mappings
  if (not check or MTarget.db.profile.autowrite) then
    for macroName,macroText in pairs(MTarget.db.char.templates) do
      MTarget:Macro_Write(macroName, macroText, variables or MTarget.db.char.variables);
    end
  end
end

function MTarget:Macro_Write(macroName, macroText, variables)
  -- can't write out macros when in combat
  if (UnitAffectingCombat("player")) then
    MTarget:Debug(L["Error: Cannot write macros while in combat"]);
    return;
  end
  for variable,name in pairs(variables) do
    macroText = string.gsub(macroText, "$" .. variable, name);
  end
  local macroIndex = GetMacroIndexByName(macroName)
  if (macroIndex ~= 0) then
    EditMacro(macroIndex, macroName, nil, macroText, 1, 1);
    MTarget:Print(L["Updated Macro X"](macroName));
  else
    CreateMacro(macroName, 1, macroText, 1, 1);
    MTarget:Print(L["Created Macro X"](macroName));
  end
end

function MTarget:Console_Cmd_listtemplates(input)
  -- print out the name of all the templates
  MTarget:Print(L["Templates"] .. ": ")
  for name,value in pairs(MTarget.db.char.templates) do
    MTarget:Print(name);
  end
end

function MTarget:Console_Cmd_resettemplate(input)
  MTarget:Macro_ResetTemplates(input);
end

function MTarget:Macro_ResetTemplates(input, confirmed)
  -- restore the macro to the template value
  if (input and not MTarget.db.char.templates[input] and input ~= L["all"]) then
    MTarget:Print(L["Error: no such template 'X'"](input));
    return
  end
  if (confirmed) then
    MTarget.resetTemplate = nil;
    variables = {};
    for variable,name in pairs(MTarget.db.char.variables) do
      variables[variable] = "$" .. variable;
    end
    if (not input or input == L["all"]) then
      MTarget:Macro_WriteAll(nil, variables);
    else
      MTarget:Macro_Write(input, MTarget.db.char.templates[input], variables);
    end
  else
    if (not input) then
      input = L["all"];
    end
    MTarget.resetTemplate = input;
    StaticPopup_Show("MTarget_ResetTemplateConfirm", input);
  end
end

function MTarget:Console_Cmd_showtemplate(input)
  -- print out the contents of the template
  if (not MTarget.db.char.templates[input]) then
    MTarget:Print(L["Error: no such template 'X'"](input));
    return
  end
  MTarget:Print(L["Macro Template"] .. ": " .. input);
  MTarget:Print(MTarget.db.char.templates[input]);
end

function MTarget:Console_Cmd_deletetemplate(input, confirmed)
  -- delete a template
  if (not MTarget.db.char.templates[input]) then
    MTarget:Print(L["Error: no such template 'X'"](input))
    return
  end
  if (confirmed) then
    MTarget.deleteTemplate = nil;
    MTarget.db.char.templates[input] = nil;
  else
    MTarget.deleteTemplate = input
    StaticPopup_Show("MTarget_DeleteTemplateConfirm", input);
  end
end
