--[[
  MTarget - Console Functions ($Id$)
  Written by gameldar
  http://www.wowace.com/projects/mtarget

  Thanks to:
    Ace3: Great lib framework
  ]]--
  
  local L = LibStub("AceLocale-3.0"):GetLocale("MTarget", true);
  
  function MTarget:Console_OnInitialize()
    MTarget.commands = {
      {
        id = "set",
        args = L["<variable>{=<value>}"],
        desc = L["Set the specified variable. If no value is supplied then the value is set to the current target's name"], 
      },
      {
        id = "setstring",
        func = "set",
        menu = L["Set Variable..."],
        args = "<variable>",
        desc = L["Set a variable to an arbitrary string value"],
        dialog = true,
        nocmd = true,
      },
      {
        id = "list", 
        menu = L["List Variables"],
        desc = L["Print out the currently set variables."],
      },
      {
        id = "clear",
        args = "{<variable>}",
        menu = L["Clear Variables"],
        desc = L["Clear currently set variable(s)."],
        cmd_desc = L["Without an argument it clears all variables."],
      },
      {
        id = "listtemplates",
        menu = L["List Templates"],
        desc = L["List all the templates."],
      },
      {
        id = "resettemplate",
        args = "{<macroname>}",
        menu = L["Reset Templates"],
        desc = L["Reset the macro(s) to the template values."],
        cmd_desc = L["Without an argument it will reset all macros with templates"],
      }, 
      {
        id = "showtemplate",
        args = "<templatename>",
        desc = L["Show the contents of the template"],
      },
      {
        id = "createtemplate",
        args = "<macroname>",
        desc = L["Create a template from a macro"],
      },
      {
        id = "deletetemplate",
        args = "<templatename>",
        desc = L["Delete the template"],
      },
      {
        id = "write",
        menu = L["Write Macros"],
        desc = L["Write out all the macros from the templates with the currently set of variables."],
      },
      {
        id = "broadcast",
        args = "{<variable>}",
        menu = L["Broadcast Variables"],
        desc = L["Broadcast variables to all party/raid members"],
        cmd_desc = L["Without an argument it broadcasts all variables"],
      },
      {
        id = "resetbc",
        menu = L["Reset Broadcast"],
        desc = L["Reset the broadcast variables (accept list, batch flag)"],
      },
      {
        id = "config",
        menu = L["Configure..."],
        desc = L["Open up the addon configuration interface"],
      },
      {
        id = "help",
--        func = "PrintHelp",
        menu = L["Help"],
        desc = L["Print help information"],
      },
    };
    
    MTarget:RegisterChatCommand("mtarget", "Console_Parser");
    local i;
    for i = 1, #MTarget.commands do
      local item = MTarget.commands[i];
      MTarget:RegisterChatCommand("mt" .. item.id, "Console_Cmd_" .. (item.func or item.id));  
    end
  end
  
  function MTarget:Console_Parser(input)
    local command, args = MTarget:GetArgs(input, 2);
    MTarget:Debug("command='" .. (command or "") .. "' args='" .. (args or "") .. "'");
    
    if (not command or not MTarget["Console_Cmd_" .. command]) then
      MTarget:Print(L["Error: invalid command '%s'"](input));
      MTarget:Console_Cmd_help();
    else
      MTarget["Console_Cmd_" .. command](command, args);
    end
    
  end

  local function trim(input)
    if (input == nil)
      then return;
    end;
    return string.gsub(input, "^(%s+)(.*)(%s+)$", "%2");
  end

  local function validateVariableName(input)
    -- trim off any white space
    input = trim(input);
    -- if the input contains any spaces throw an error
    if (string.find(input, "%s") ~= nil) then
      MTarget:Print(L["Error: invalid variable name 'X'. Cannot contain spaces."](input));
      return nil;
    end
    -- if the input contains a $ character throw an error
    if (string.find(input, "$", 0, true) ~= nil) then
      MTarget:Print(L["Error: invalid variable name 'X'. Cannot contain $."](input));
      return nil;
    end
    return input;
  end

  function MTarget:Console_Cmd_set(input)
    local variable, name;
    MTarget:Debug("set input = '" .. (input or "nil") .. "'");
    local b, e = string.find(input, "=");
    if (not b) then
      name = UnitName("playertarget");
      variable = input;
    else
      variable = trim(string.sub(input, 0, b - 1));
      name = string.sub(input, e + 1);  
    end
    -- set the target variable to the name of the unit
    local validInput = validateVariableName(input)
    if (validInput == nil) then
      return;
    end
    
    MTarget:SetVariable(variable, name, "");
  end
  
  function MTarget:Console_Cmd_help(input)
    local i;
    for i = 1, #MTarget.commands do
      local cmd = MTarget.commands[i];
      if (not cmd.nocmd) then
        MTarget:Print(string.format("  %s %s - %s", cmd.id, cmd.args or "", cmd.desc .. " " .. (cmd.cmd_desc or "")));
      end
    end
  end
