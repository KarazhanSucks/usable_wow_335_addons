local L = LibStub("AceLocale-3.0"):NewLocale("MTarget", "enUS", true);

local function String_valueOf(val)
  if (val) then
    return val;
  else
    return "nil";
  end
end

if L then
  L["Accept"] = true;
  L["all"] = true;
  L['Always accept broadcast from party/raid members'] = true;
  L["Always"] = true;
  L["arguments"] = true;
  L['Assign Raid Icons'] = true;
  L['Auto accept Broadcasts'] = true;
  L['Automatically assign raid icons to varibles when you set them ("$star","$circle","$diamond","$triangle","$moon","$square","$cross","$skull")'] = true;
  L['Auto Write Macros'] = true;
  L["Broadcast"] = true;
  L["Broadcast Set $X='Y'"] = function(X, Y)
    return "Broadcast Set $" .. String_valueOf(X) .. "='" .. String_valueOf(Y) .. "'";
  end;
  L["Broadcast variables to all party/raid members"] = true;
  L['Broadcast variables to party or raid'] = true;
  L['Broadcast variables'] = true;
  L["Broadcast Variables"] = true;
  L["broadcast your variable to your party/raid. Without an argument it broadcasts all variables"] = true;
  L["Cancel"] = true;
  L["Clear all currently set variables."] = true;
  L["clear any broadcast variables (sender accept, and batch flags)"] = true;
  L["Clear currently set variable(s)."] = true;
  L["clear the assigned variable. Without an argument all the assigned variables are cleared."] = true;
  L["Clear Variables"] = true;
  L["Cleared all variables"] = true;
  L["Cleared variable: '%s'"] = function(X)
    return string.format("Cleared variable: '%s'", String_valueOf(X));
  end
  L["commands"] = true;
  L["command"] = true;
  L["Configure..."] = true;
  L["Create a new variable assigned to this name"] = true;
  L["Create a template from a macro"] = true;
  L["Created Macro X"] = function(X)
    return "Created Macro " .. String_valueOf(X);
  end;
  L["Created template from macro[X]: Y"] = function (X, Y)
    return "Created template from macro[" .. String_valueOf(X) .. "]: " .. String_valueOf(Y);
  end;
  L["create the macros from all the templates filling in the variables"] = true;
  L["Current target: X"] = function(X)
    return "Current target: " .. String_valueOf(X);
  end
  L['Debug'] = true;
  L["Delete template: %s"] = true;
  L["Delete the template"] = true;
  L["Delete"] = true;
  L['Enable debug output'] = true;
  L["Error: Cannot write macros while in combat"] = true;
  L["Error: failed to deserialize broadcast message: 'X'"] = function (X)
    return "Error: failed to deserialize broadcast message: '" .. String_valueOf(X) .. "'";
  end
  L["Error: invalid command '%s'"] = function (X)
    return string.format("Error: invalid command '%s'", String_valueOf(X));
  end
  L["Error: invalid variable name 'X'. Cannot contain $."] = function (X)
    return "Error: invalid variable name '" .. String_valueOf(X) .. "'. Cannot contain $.";
  end;
  L["Error: invalid variable name 'X'. Cannot contain $."] = function(X)
  end;
  L["Error: invalid variable name 'X'. Cannot contain spaces."] = function (X)
    return "Error: invalid variable name '" .. String_valueOf(X) .. "'. Cannot contain spaces.";
  end;
  L["Error: invalid Variable String format. Must be x=y"] = true;
  L["Error: no such macro 'X'"] = function (X)
    return "Error: no such macro '" .. String_valueOf(X) .. "'";
  end;
  L["Error: no such template 'X'"] = function (X)
    return "Error: no such template '" .. String_valueOf(X) .. "'";
  end;
  L["Error: no unit targeted"] = true;
  L["Error: Variable 'X' not assigned"] = function (X)
    return "Error: Variable '" .. String_valueOf(X) .. "' not assigned";
  end
  L["Help"] = true;
  L["Ignore"] = true;
  L["Initialized X"] = function(X)
    return "Initialized " .. String_valueOf(X);
  end;
  L["list all the currently assigned variables and values"] = true;
  L["list all the templates"] = true;
  L["List all the templates."] = true;
  L["List Templates"] = true;
  L["List Variables"] = true;
  L["Macro Template"] = true;
  L['Hide Minimap Icon'] = true;
  L["Minimap is Square"] = true;
  L["New..."] = true;
  L["No name for current menu"] = true;
  L["No such variable: '%s'"] = function(X)
    return string.format("No such variable: '%s'", String_valueOf(X));
  end
  L["Open up the addon configuration interface"] = true;
  L["Print help information"] = true;
  L["Print out the currently set variables."] = true;
  L["Reset Broadcast"] = true;
  L["Reset macro to template value for: %s"] = true;
  L["Reset Templates"] = true;
  L["Reset the broadcast variables (accept list, batch flag)"] = true;
  L["Reset the macros to the template values."] = true;
  L["Reset the macro(s) to the template values."] = true;
  L["Reset"] = true;
  L['Rewrite the macros when a variable is changed.'] = true;
  L["Save"] = true;
  L["Set a variable to an arbitrary string value"] = true;
  L["Set by Name"] = true;
  L["Set targeting variables."] = true;
  L["Set MTarget variables"] = true;
  L["Set Target Variable..."] = true;
  L["set the current target name to the specified variable"] = true;
  L["Set the specified variable. If no value is supplied then the value is set to the current target's name"] = true;
  L["set the macro to have the template text. Without an argument it will reset all macros with templates"] = true;
  L["set the variable to the specified value"] = true;
  L["Set"] = true;
  L["Set variable for %s"] = true;
  L["Set variable in the form x=y"] = true;
  L["Set variable X"] = function(X)
    return "Set variable " .. String_valueOf(X);
  end
  L["Set variable name and value string (e.g. spell=Exorcism)"] = true;
  L["Set Variable..."] = true;
  L["Set $X='Y'"] = function(X, Y)
    return "Set $" .. String_valueOf(X) .. "='" .. String_valueOf(Y) .. "'";
  end;
  L["%sSet $%s='%s'"] = function(X, Y, Z)
    return string.format("%sSet $%s='%s'", String_valueOf(Z), String_valueOf(X), String_valueOf(Y));
  end
  L['Show Minimap button'] = true;
  L['Show Minimap'] = true;
  L['Hide the minimap icon'] = true;
  L["Show the contents of the template"] = true;
  L['Show tooltips on menu items.'] = true;
  L['Show Tooltips'] = true;
  L['Square Minimap'] = true;
  L["%s wants to set %s."] = true;
  L["Templates"] = true;
  L["Template"] = true;
  L["Updated Macro X"] = function(X)
    return "Updated Macro " .. String_valueOf(X);
  end;
  L["Using target[Y] X"] = function(X, Y)
    return "Using target[" .. String_valueOf(Y) .. "] " .. String_valueOf(X);
  end
  L["<variable>{=<value>}"] = true;
  L["Without an argument it broadcasts all variables"] = true;
  L["Without an argument it clears all variables."] = true;
  L["Without an argument it will reset all macros with templates"] = true;
  L["Write Macros"] = true;
  
  L["Write out all the macros from the templates with the currently set of variables."] = true;
end
