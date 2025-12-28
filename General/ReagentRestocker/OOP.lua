-- This was going to be a full fledged OOP library, but due to some limitations
-- and due to a lack of time, I decided against it. Right now it's mostly
-- helper and debugging functions.
local addonName, addonTable = ...;

addonTable.ReagentRestockerDB=ReagentRestockerDB

if(WoW_OOP == nil) then
WoW_OOP = true;

-- Import packages
addonTable.packages = packages;

-- For some reason, many basic Lua functions are lost when loading a new
-- environment.
addonTable.pairs = pairs;
addonTable.print = print;
addonTable.table = table;
addonTable.type = type;
addonTable.tostring = tostring;
addonTable.string = string;
addonTable.loadBlizzard = loadBlizzard;
addonTable.error = error;
addonTable.GameTooltip = GameTooltip;
addonTable.GetAddOnMetadata=GetAddOnMetadata;
addonTable.getPlayerBagIDList=getPlayerBagIDList;
addonTable.getIDFromItemLink=getIDFromItemLink;
addonTable.GetContainerNumSlots=GetContainerNumSlots;
addonTable.GetContainerItemLink=GetContainerItemLink;
addonTable.GetContainerItemInfo=GetContainerItemInfo;
addonTable.UseContainerItem=UseContainerItem;
addonTable.BANK_CONTAINER=BANK_CONTAINER;
addonTable.SlashCmdList=SlashCmdList;
addonTable.InterfaceOptions_AddCategory=InterfaceOptions_AddCategory;
addonTable.RaidRollHasLoaded=RaidRollHasLoaded;
addonTable.WorldFrame = WorldFrame;
addonTable.GameTooltip=GameTooltip;
addonTable.GameTooltip_SetDefaultAnchor=GameTooltip_SetDefaultAnchor;
addonTable.SetItemRef=SetItemRef;
addonTable.UIParent=UIParent;
addonTable.setfenv=setfenv;
addonTable.setmetatable=setmetatable;
addonTable.ceil=ceil;
addonTable.tonumber=tonumber;
addonTable.time=time;
addonTable.max = max;
addonTable.min = min;
addonTable.floor = floor;
addonTable.strlen=strlen;
addonTable.abs=abs;
addonTable.GetBuildInfo=GetBuildInfo;

-- Load Mik's scrolling Battle text, if available. Used for displaying messages.
addonTable.MikSBT = MikSBT;
addonTable.UIErrorsFrame = UIErrorsFrame;

-- Load basic WoW functions. Very incomplete.
--[[addonTable.SlashCmdList = SlashCmdList;
addonTable.CreateFrame = CreateFrame;
addonTable.InterfaceOptions_AddCategory=InterfaceOptions_AddCategory;
addonTable.GetCursorInfo=GetCursorInfo;
addonTable.GetItemInfo=GetItemInfo;]]--

--COMMAND LIST:
-- PLAYER_LEAVING_WORLD is triggered on leaving the world
-- UPDATE_INVENTORY_ALERTS called first, then UPDATE_INVENTORY_DURABILITY
-- then BAG_UPDATE is called several times
-- BAG_UPDATE_COOLDOWN is called much later, but called twice. Does seem reliable.

-- ZONE_CHANGED_NEW_AREA called when changing zones.


-- Load LibStub and Ace, if available

if LibStub ~= nil then
	addonTable.LibStub = LibStub;
end

local _GLOBAL=_G;

-- Okay, we're just uncluding _G now. Eventually, I'm switching out of this mess.
addonTable._G=_G;

debugRR = false;
addonTable.debugRR = debugRR;

errToPrint = "\n";
addonTable.errToPrint = errToPrint;

-- Recursive print for tables
local function rprint(depth, ...)
--	if debug==false then
--		error("Debug print called when not debugging! Please report this error.");
--	end
	
	local temp = "";
	if depth > 5 then return end;
	spaces = "";
	for x=0,depth do
	 spaces = spaces.." ";
	end

	if ... == nil then
		dprint("nil");
	end
	
	for i,v in pairs ({...}) do
--     print (i,v)
--  	printer:JPrint(v);
	if type(v) == "table" then
		if getmetatable(i) == nil then
			print("(no metatable)");
		else
			print("(metatable: "..getmetatable(i)..")");
		end
		if(type(i)=="string") then
			print(spaces.."[\""..i.."\"]={");
		else
			print(spaces.."["..i.."]={");
		end
		for x, y in pairs (v) do
			-- Don't recurse global!
			if x == "_G" then
				print(spaces.."_G");
				return
			end
--			if x == "package" then
--				printer:JPrintln(spaces.." (package)");
--				return
--			end
			if type(y)=="table" then
				if type(x)=="string" then
					rprint(depth+1,spaces.."\""..x.."\"=",y);
				else
					rprint(depth+1,spaces..x.."=",y);
				end
			else
				if type(x)=="string" then
					rprint(depth+1,spaces.."\""..x.."\"=",y," (type: "..type(y)..")");
				else
					rprint(depth+1,spaces..x.."=",y," (type: "..type(y)..")");
				end
			end
		end
		print(spaces.."}");
	elseif type(v) == "string" then
		print(v);
	elseif type(v) == "number" then
		print(v);
	elseif type(v) == "boolean" then
		print(v);
	else
		print("type: "..type(v));
     end
   end
   --print();
end

function addToError(...)
	for i,v in pairs ({...}) do
		if type(v) == "table" then
			errToPrint = errToPrint .. "(table begin) " .. i .. "\n";
			for i2,v2 in pairs(v) do
				if (type(v2) == "string") or (type(v2) == "number") then
					errToPrint = errToPrint .. "  " .. i2 .. "=" ..v2.."\n";
				elseif (type(v2) == "boolean") then
					if v2==true then
						errToPrint = errToPrint .. "  " .. i2 .. "=" .."true\n"
					else
						errToPrint = errToPrint .. "  " .. i2 .. "=" .."false\n"
					end
				else
					errToPrint = errToPrint .. "  " .. i2 .. "=" ..type(v2).."\n";
				end
			end
			errToPrint = errToPrint .. "(table end)\n"
		elseif (type(v) == "string") or (type(v) == "number") or (type(v) == "boolean") then
			errToPrint = errToPrint .. "  " .. i .. "=" .. v .. "\n";
		else
			errToPrint = errToPrint .. "  " .. i .. "=" .. type(v).."\n";
		end
	end
end

-- Debug print
function dprint(...)
	if debugRR then
		if rprint ~= nil then
			rprint(4,...);
			if  addToError ~= nil then
				addToError(...);
			end
		else
			print(...);
		end
	else
		if  addToError ~= nil then
			addToError(...);
		end
	end
end

--Debug print and error
function derror(...)
	addToError(...);
	error(errToPrint);
end

addonTable.rprint = rprint;
addonTable.addToError = addToError;
addonTable.derror = derror;
addonTable.dprint = dprint;

-- Environment set! ------------------------------------------------------------
setfenv(1,addonTable);






--WoW OOP library

-- To use in an addon --

-- -- Set up package.
-- local addonName, addonTable = ...;
-- -- After this point, nothing is truly global, and it acts like a library.
-- setfenv(1,addonTable);

-------------------------------

-- WoW reloads the global environment between files, so I can't set environments
-- in the library

-- I'm a bit fed up with global namespaces and polluting the global namespace
-- accidentally. Therefore, it's time to write a decent packaging system for Lua.

-- Here's where the list of package names is stored. Package names should be
-- written very carefully, as to avoid name clashes.

-- Root "package" for addons is "packages." Each package can contain a series of
-- classes. When you set a package, you put yourself in its namespace.
if packages ~= nil then
	error("WoW_OOP requires packages to be clean.");
end
packages = {}

local currentPackage = {}
local packageName = nil;

-- Package names.
-- I'm gonna be flexible here: A package can refer to part of an addon, an
-- entire addon, or even several addons. Packages can contain other packages
-- or classes.

-- For the convenience of the developer, I'm also providing "global", "public,"
-- "package" tables, which control the scope of the variables.

-- global:  Placed in the _G value (globally visible, still available after
--          package is closed). Does NOT override existing values!
-- public:  Visible outside of the package, in the _G.packages[name] field.
-- All other variables are local to the package.

-- Sets the current package - will create a new one if it doesn't exist.
function package(name)
	packageName = name;
	-- Check package integrity
	if type(packages) ~= "table" then
		error("(WoW_OOP) packages corrupted!");
	end
	
	if name == nil then
		error("(WoW_OOP) packages must have names!");
	end
	
	-- Start by going back to global namespace.
	--setfenv(1,_G);
	
	if packages[name]==nil then
		packages[name]={};
	end
	currentPackage = packages[name];

	-- Make global anything in the "global" table.
	if currentPackage.global ~= nil and type(currentPackage.global)=="table" then
		for k, v in pairs(currentPackage.global) do
			if _G[k] == nil then
				_G[k]=v;
			end
		end
	end
	
	-- Make visible anything in the "public" table.
	if currentPackage.public ~= nil and type(currentPackage.public)=="table" then
		for k, v in pairs(currentPackage.public) do
			_G.packages[name][k]=v;
		end
	end

	-- Allow access to globals from inside the package.
	local _G = _G
	setmetatable(currentPackage, {__index = _G})
	--local packages=packages;

	-- Pull us into the environment.
--	setfenv(1, currentPackage);

end

-- loads another package in. Reserved packagte names:
-- GLOBAL: Global namespace (_G)
-- LUA: Native Lua functions. 
-- BLIZZARD: Global Blizzard functions, taken from an automated scan of the
-- global namespace.
function include(name)

	if packages == nil then
		error("nil package.");
		return;
	end
	

	if name == "GLOBAL" then
		dprint("Loading global into package.");
		for k, v in pairs(_GLOBAL) do
			dprint(k);
			addonTable[k]=v;
		end
		return;
	end
	
--	if name == "BLIZZARD" then
--		loadBlizzard(_GLOBAL);
--		return;
--	end
	
	if packages[name] == nil then
		error("Name " .. name .. " not found in packages.");
		return;
	end
	
	for k, v in pairs(packages[name]) do
		getfenv(1)[k]=v;
	end

end

-- Imports listed global variables into addon.
function includeGlobal(...)
	--dprint("includeGlobal called.");
	if _GLOBAL == nil then
		error("Globals not found!");
	end
	
	if type(...)=="nil" then
		error("... nil in includeGlobal!");
	end

	for k, v in pairs({...}) do
		--dprint(v);
		if _GLOBAL[v]==nil then
			error(v .. " is nil!");
		end
		addonTable[v]=_GLOBAL[v];
	end
end

else
-- OOP library already loaded, do nothing.
end

dprint("OOP.lua loaded");
