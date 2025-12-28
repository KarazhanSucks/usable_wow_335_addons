--[[
The MIT License

Copyright (c) 2009

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]--

-- Grab AddOn info, place into its own environment. ----------------------------
local addonName, addonTable = ...;

local oldEnv = getfenv();

addonTable.NUM_BAG_SLOTS=NUM_BAG_SLOTS
addonTable.NUM_BANKBAGSLOTS=NUM_BANKBAGSLOTS

setfenv(1,addonTable);
dprint("Loading " .. addonName);
--include("BLIZZARD");

-- Custom print function from a separate project. ------------------------------

--print("Loading Reagent Restocker");

printedG=true;



function jprint(...)
	rprint(0,...);
end

-- Vars -------------------------------------------------------------------
--ReagentRestocker = AceLibrary("AceAddon-2.0"):new("AceConsole-2.0","AceEvent-2.0")
ReagentRestocker = LibStub("AceAddon-3.0"):NewAddon("Reagent Restocker", "AceEvent-3.0","AceConsole-3.0");

local moduleName = 'ReagentRestocker'

-- Item property labels
ITEM_NAME = "0"
ITEM_LINK = "1"
ITEM_RARITY = "2"
ITEM_LEVEL = "3"
ITEM_MIN_LEVEL = "4"
ITEM_TYPE = "5"
ITEM_SUB_TYPE = "6"
ITEM_STACK_COUNT = "7"
ITEM_EQUIP_LOC = "8"
ITEM_TEXTURE = "9"
ITEM_SELL_PRICE="item_sell"
QUANTITY_TO_STOCK = "qty"
LOW_WARNING="low_warning"

-- Shared variables
local LockedBagSlotIDList = {}

local TransactionLock = false

-- Events waiting to be performed
local QueuedActions = {}

-- Static variables
SHOPPING_TYPE = "shopping"
SELLING_TYPE = "selling"

-- Event IDs
PLAYER_MONEY_EVENT = "PLAYER_MONEY"
ITEM_LOCK_CHANGED_EVENT = "ITEM_LOCK_CHANGED"
MERCHANT_SHOW_EVENT = "MERCHANT_SHOW"
MERCHANT_UPDATE_EVENT = "MERCHANT_UPDATE"
BANKFRAME_OPENED_EVENT = "BANKFRAME_OPENED"
VARIABLES_LOADED_EVENT = "VARIABLES_LOADED"
BAG_UPDATE_EVENT = "BAG_UPDATE"
PLAYER_LEAVING_WORLD_EVENT = "PLAYER_LEAVING_WORLD"
PLAYER_ENTERING_WORLD_EVENT = "PLAYER_ENTERING_WORLD"
BAG_UPDATE_COOLDOWN_EVENT = "BAG_UPDATE_COOLDOWN"
UPDATE_INVENTORY_DURABILITY_EVENT = "UPDATE_INVENTORY_DURABILITY"

-- Helpers
local map = table.foreach

-- UI
local Menu = { 
	type="group",
	args = {
		shoppingOptions = {
			type = "group",
			name = "Shopping",
			desc = "Change how Reagent Restocker shops",
			args = {
				addTitle = {
					type = "header",
					name = "Add to Shopping List",
					order = 1
				},
			
				addReagent = {
					type = "input",
					name = "Type the item's name and hit enter",
					desc = "Adds a new item to your Shopping List",
					--get = "",
					usage = "<reagent name>",
					set = function (x) ReagentRestocker:addItemToShoppingList(x); end,
					order = 2
				},

				
				addReagentDropText = {
					type = "header",
					name = "Drag item into drop target.",
					order = 3
				},

				addReagentTwo = {
					type = "execute",
--					type = "execute",
--					text = "Grad item here to add to list.",
--					1desc = "Adds a new item to your Shopping List!",
					name = "Stuff goes here.",
--					get = "",
--					usage = "<reagent name>",
					func = function (x)
						local infoType, info1, info2 = GetCursorInfo();
						print(infoType);
						if (infoType == "item") then
							print(info1);
							print(info2);
							ReagentRestocker:addToListByID(info1,0);
							_G.ClearCursor();
						end
--						--self:synchronizeOptionsTable();
					end,
					order = 4
				},

				discountSpacerTwo = {
					type = "header",
					name = "Required Faction Discount",
					order = 6
				},

				none = {
					type = "toggle",
					name = "None (0%)",
					desc = "Reagent Restocker will purchase Shopping List items from any vendors",
					get = function () return (ReagentRestockerDB.Options.RequiredDiscount == 0) end,
					set = function (x) ReagentRestockerDB.Options.RequiredDiscount = 0 end,
					order = 7
				},
				friendly = {
					type = "toggle",
					name = "Friendly (5%)",
					desc = "Reagent Restocker will only purchase Shopping List items from vendors with a 5% (or better) discount",
					get = function () return (ReagentRestockerDB.Options.RequiredDiscount == 5) end,
					set = function (x) ReagentRestockerDB.Options.RequiredDiscount = 5 end,
					order = 8
				},
				honored = {
					type = "toggle",
					name = "Honored (10%)",
					desc = "Reagent Restocker will only purchase Shopping List items from vendors with a 10% (or better) discount",
					get = function () return (ReagentRestockerDB.Options.RequiredDiscount == 10) end,
					set = function (x) ReagentRestockerDB.Options.RequiredDiscount = 10 end,
					order = 9
				},
				revered = {
					type = "toggle",
					name = "Revered (15%)",
					desc = "Reagent Restocker will only purchase Shopping List items from vendors with a 15% (or better) discount",
					get = function () return (ReagentRestockerDB.Options.RequiredDiscount == 15) end,
					set = function (x) ReagentRestockerDB.Options.RequiredDiscount = 15 end,
					order = 10
				},						
				exalted = {
					type = "toggle",
					name = "Exalted (20%)",
					desc = "Reagent Restocker will only purchase Shopping List items from vendors with a 20% discount",
					get = function () return (ReagentRestockerDB.Options.RequiredDiscount == 20) end,
					set = function (x) ReagentRestockerDB.Options.RequiredDiscount = 20 end,
					order = 11
				},
				
				AutoBuy = {
					type = "toggle",
					name = "Enable auto-shop",
					desc = "Enables auto-shopping; if you turn this option off, Reagent Restocker will not purchase items automatically",
					get = function () return ReagentRestockerDB.Options.AutoBuy end,
					set = function (x) ReagentRestockerDB.Options.AutoBuy = x end,
					order = 14
				},
				Overstock = {
					type = "toggle",
					name = "Overstock",
					desc = "If this option is disabled, Reagent Restocker will never stock more than the quantity you specify (otherwise, overstocking may occur when a vendor sells an item in stacks instead of one-by-one)",
					get = function () return not ReagentRestockerDB.Options.NotOverstock; end,
					set = function (x) ReagentRestockerDB.Options.NotOverstock = not x; end,
					order = 15
				}				
			},
			order = 1
		},
		sellingOptions = {
			type = "group",
			name = "Selling",
			desc = "Options for automatically selling items",
			args = {
				addTitle = {
					type = "header",
					name = "Add to Selling List",
					order = 1				
				},				
				addSellingList = {
					type = "input",
					name = "Type the item's name and hit enter",
					desc = "Adds an item to your Selling List",
					--get = false,
					usage = "<reagent name>",
					set = function (x) ReagentRestocker:addItemToSellingList(x); end,
					order = 2
				},
				
				sellReagentDropText = {
					type = "header",
					name = "Drag item into drop target.",
					order = 3
				},
				sellReagentTwo = {
					type = "execute",
--					text = "Grad item here to add to list.",
--					desc = "Adds a new item to your Shopping List!",
					name = "Stuff goes here.",
--					get = "",
--					usage = "<reagent name>",
					func = function (x)
						local infoType, info1, info2 = GetCursorInfo();
						print(infoType);
						if (infoType == "item") then
							print(info1);
							print(info2);
							ReagentRestocker:addToListByID(info1,-1);
							_G.ClearCursor();
						end
						--self:synchronizeOptionsTable();
					end,
					order = 4
				},
				
				otherTitle = {
					type = "header",
					name = "Other",
					order = 7					
				},	
				AutoPopulate = {
					type = "toggle",
					name = "Auto-populate Selling List",
					desc = "With this option enabled, Reagent Restocker will watch what items you sell to the vendor and automatically add them to the Selling List",
					get = function() return ReagentRestockerDB.Options.AutoPopulate end,
					set = function(x) ReagentRestockerDB.Options.AutoPopulate = x end,
					order = 8
				},					
				AutoSellGrays = {
					type = "toggle",
					name = "Sell gray items",
					desc = "Do you want Reagent Restocker to automatically sell gray (usless) items from your inventory?  (This is like adding all gray items to your Selling List)",
					get = function() return ReagentRestockerDB.Options.AutoSellGrays end,
					set = function(x) ReagentRestockerDB.Options.AutoSellGrays = x end,
					order = 9
				},
				AutoSell = {
					type = "toggle",
					name = "Enable auto-sell",
					desc = "Enable auto-selling; if you turn this option off, Reagent Restocker will not sell items automatically",
					get = function () return ReagentRestockerDB.Options.AutoSell end,
					set = function (x) ReagentRestockerDB.Options.AutoSell = x end,
					order = 10
				},			
			},
			order = 2
		},
		BankOptions = {
			type = "group",
			name = "Bank",
			desc = "Options for interacting with your bank",
			order = 3,
			args = {
				pullFromBank = {
					type = "toggle",
					name = "Stock items from bank",
					desc = "Pulls items on your Shopping List from your bank if you need them",
					get = function () return ReagentRestockerDB.Options.PullFromBank end,
					set = function (x) ReagentRestockerDB.Options.PullFromBank = x end
				},
				overstockToBank = {
					type = "toggle",
					name = "Overstock to bank",
					desc = "Puts 'extra' Shopping List items (i.e., more than the quantity you keep stocked) into your bank",
					get = function() return ReagentRestockerDB.Options.OverstockToBank end,
					set = function(x) ReagentRestockerDB.Options.OverstockToBank = x end
				}				
			}
		},
		RepairOptions = {
			type = "group",
			name = "Repair",
			desc = "Options for interacting with your bank",
			order = 4,
			args = {
				AutoRepair = {
					type = "toggle",
					name = "Auto-repair",
					desc = "Automatically repair your gear when you visit a repair-able vendor",
					get = function () return ReagentRestockerDB.Options.AutoRepair end,
					set = function (x) ReagentRestockerDB.Options.AutoRepair = x end
				},
				UseGuildBankFunds = {
					type = "toggle",
					name = "Use guild bank funds",
					desc = "Use guild bank funds when auto-repairing, if possible",
					get = function() return ReagentRestockerDB.Options.UseGuildBankFunds end,
					set = function(x) ReagentRestockerDB.Options.UseGuildBankFunds = x end
				},
				RequireDiscount = {
					type = "toggle",
					name = "Require discount (see Shopping options)",
					desc = "Only repair if the repair vendor meets the required vendor discounts (as chosen in the Shopping options)",
					get = function() return ReagentRestockerDB.Options.RepairDiscount end,
					set = function(x) ReagentRestockerDB.Options.RepairDiscount = x end
				}					
			}
		},
		MiscOptions = {
			type = "group",
			name = "Misc.",
			desc = "Other Reagent Restocker options",
			order = 5,
			args = {
				QuietMode = {
					type = "toggle",
					name = "Quiet mode",
					desc = "Disable Reagent Restocker messages",
					get = function() return ReagentRestockerDB.Options.QuietMode end,
					set = function(x) ReagentRestockerDB.Options.QuietMode = x end
				},
				SingleLDB = {
					type = "toggle",
					name = "Single LDB item (Requires UI reload)",
					desc = "Reduces LDB to one button, instead of one button per item. Requires UI reload.",
					get = function() return ReagentRestockerDB.Options.SingleLDB end,
					set = function(x) ReagentRestockerDB.Options.SingleLDB = x; end
				}
			}
		}
	}
}


--=========--
-- Helpers --
--=========--

-- Returns the "difference" between two tables with numerical values
local function tDiff(ta, tb, onlyInA)
	local diff = {}
	for k,v in pairs(ta) do
		if tb[k] then
			diff[k] = ta[k] - tb[k]
		else
			diff[k] = ta[k]
		end
	end
	if not onlyInA then
		for k,v in pairs(tb) do
			if not diff[k] then -- Don't use keys we've already used; also, anything in a is already in diff
				diff[k] = -1 * tb[k]		
			end
		end
	end
	return diff
end

-- Returns true if the provided item info indicates the item should be included in the offset list for bank stocking
local function bankOffset(itemID, qty)
	if qty > 0 then 
		return ReagentRestockerDB.Options.PullFromBank
	else
		return ReagentRestockerDB.Options.OverstockToBank
	end
end

-- Returns the number of all items table t; #<table> returns array count only
local function tcount(t)
	local i = 0
	map(t,function () i = i + 1; end)
	return i
end

-- Returns true if item is a value in the table; false otherwise
local function inT(tab,item)
	for _,v in pairs(tab) do
		if v == item then
			return true
		end
	end
	return false
end

-- Returns a string representation of a price (in copper)
local function nCTS(price)
	if price < 100 then
		return price .. "|cFFB87333c|r"
	elseif price < 10000 then
		return price/100 .. "|cFFC0C0C0s|r"
	else
		return ceil(price/100 - 0.005)/100 .. "|cFFCDAD00g|r"
	end
end

-- Returns a string representation of a table
local function strT (tab)
	if type(tab) == type({}) then
		local mystr = ""
		for k,v in pairs(tab) do
			mystr = mystr .. "[" .. tostring(k) .. " = '" .. strT(v) .. "']"
		end
		return mystr
	else
		return tostring(tab)
	end
end

-- Returns the item id of parsed from the provided item link
local function getIDFromItemLink(itemLink)
	if itemLink then
		return tonumber(string.match(itemLink, "|c[0-9a-fA-F]+|Hitem:([0-9]+):.*"))
	end
end

-- Returns the item name from the provided item link
local function getNameFromItemLink(itemLink)
	return string.match(itemLink, ".+%[([^%]]+)%].+")
end

-- Returns true if the 'clue' is found in the item name
local function isItemNameInLink(clue,link)
	-- Remember to escape any -s in the string
		return string.find(string.lower(clue),string.gsub(string.lower(getNameFromItemLink(link)),"-","%%-"))
end

-- Returns a table array containing the bag IDs for bank bags
local function getBankBagIDList()
	local bankBagIDList = {}
	
	-- Add the bank container
	table.insert(bankBagIDList, BANK_CONTAINER)
	
	-- Add the remaining bags
	for bagID=NUM_BAG_SLOTS+1, NUM_BAG_SLOTS+NUM_BANKBAGSLOTS do
		table.insert(bankBagIDList, bagID)
	end
	
	return bankBagIDList
end

-- Returns a table array containing the bag IDs for player bags
local function getPlayerBagIDList()
	return {0,1,2,3,4}
end

-- Prints the message if messages are enabled
function ReagentRestocker:say(msg)
	if not ReagentRestockerDB.Options.QuietMode and msg ~= "" then
		self:Print(tostring(msg))
	end
end


--========================--
-- Reagent Restocker Core --
--========================--

-- If the items in cache, update the stored values and return it; otherwise, return what is in cache, if it exists; otherwise return nil
function ReagentRestocker:safeGetItemInfo(itemID)
	if ReagentRestockerDB.Items[itemID] then
		if not _G.GetItemInfo(itemID) then	
			return ReagentRestockerDB.Items[itemID][ITEM_NAME],ReagentRestockerDB.Items[itemID][ITEM_LINK],ReagentRestockerDB.Items[itemID][ITEM_RARITY],ReagentRestockerDB.Items[itemID][ITEM_LEVEL],ReagentRestockerDB.Items[itemID][ITEM_MIN_LEVEL],ReagentRestockerDB.Items[itemID][ITEM_TYPE],ReagentRestockerDB.Items[itemID][ITEM_SUB_TYPE],ReagentRestockerDB.Items[itemID][ITEM_STACK_COUNT],ReagentRestockerDB.Items[itemID][ITEM_EQUIP_LOC],ReagentRestockerDB.Items[itemID][ITEM_TEXTURE],ReagentRestockerDB.Items[itemID][ITEM_SELL_PRICE]
		else
			ReagentRestockerDB.Items[itemID][ITEM_NAME],ReagentRestockerDB.Items[itemID][ITEM_LINK],ReagentRestockerDB.Items[itemID][ITEM_RARITY],ReagentRestockerDB.Items[itemID][ITEM_LEVEL],ReagentRestockerDB.Items[itemID][ITEM_MIN_LEVEL],ReagentRestockerDB.Items[itemID][ITEM_TYPE],ReagentRestockerDB.Items[itemID][ITEM_SUB_TYPE],ReagentRestockerDB.Items[itemID][ITEM_STACK_COUNT],ReagentRestockerDB.Items[itemID][ITEM_EQUIP_LOC],ReagentRestockerDB.Items[itemID][ITEM_TEXTURE],ReagentRestockerDB.Items[itemID][ITEM_SELL_PRICE] = _G.GetItemInfo(itemID)
			return ReagentRestockerDB.Items[itemID][ITEM_NAME],ReagentRestockerDB.Items[itemID][ITEM_LINK],ReagentRestockerDB.Items[itemID][ITEM_RARITY],ReagentRestockerDB.Items[itemID][ITEM_LEVEL],ReagentRestockerDB.Items[itemID][ITEM_MIN_LEVEL],ReagentRestockerDB.Items[itemID][ITEM_TYPE],ReagentRestockerDB.Items[itemID][ITEM_SUB_TYPE],ReagentRestockerDB.Items[itemID][ITEM_STACK_COUNT],ReagentRestockerDB.Items[itemID][ITEM_EQUIP_LOC],ReagentRestockerDB.Items[itemID][ITEM_TEXTURE],ReagentRestockerDB.Items[itemID][ITEM_SELL_PRICE]
		end
	else
		return _G.GetItemInfo(itemID)
	end
end

function ReagentRestocker:getSellPrice(itemID)
	_,_,_,_,_,_,_,_,_,_,price=ReagentRestocker:safeGetItemInfo(itemID);
	return price;
end

-- Given an item's name, return the item's ID if it is found; nil on failure
function ReagentRestocker:discoverItemID(itemClue)
	-- Look in the player's backpack/bank
	local bagIDList = {}
	map(getBankBagIDList(),function (_,bagID) table.insert(bagIDList,bagID) end)
	map(getPlayerBagIDList(),function (_,bagID) table.insert(bagIDList,bagID) end)
	for _,bagID in pairs(bagIDList) do
		for bagSlotID=1,_G.GetContainerNumSlots(bagID) do
			currentItemLink = _G.GetContainerItemLink(bagID,bagSlotID)
			if currentItemLink then 
				if isItemNameInLink(itemClue,currentItemLink) then
					return getIDFromItemLink(currentItemLink)
				end
			end
		end
	end
	
	-- Look in the merchant window, if it is open
	if _G.GetMerchantNumItems() then
		for i=1, _G.GetMerchantNumItems() do
			currentItemLink = _G.GetMerchantItemLink(i)
			if currentItemLink then
				if isItemNameInLink(itemClue,currentItemLink) then
					return getIDFromItemLink(currentItemLink)
				end	
			end
		end
	end
	
	-- Look in the items list
	for itemID,data in pairs(ReagentRestockerDB.Items) do
		_, currentItemLink = self:safeGetItemInfo(itemID)
		if currentItemLink then
			if isItemNameInLink(itemClue,currentItemLink) then
				return getIDFromItemLink(currentItemLink)
			end	
		end				
	end
	
	-- If we don't find the item, return nil
	return nil
end

-- Adds a value to the ReagentRestockerDB.Items table
function ReagentRestocker:addToItems(itemID, var, value, list)
	if not ReagentRestockerDB.Items[itemID] then
		ReagentRestockerDB.Items[itemID] = {}
		ReagentRestockerDB.Items[itemID]["tags"]={}
	end
	
	if ReagentRestockerDB.Items[itemID]["tags"]==nil then
		ReagentRestockerDB.Items[itemID]["tags"]={}
	end
	
	ReagentRestockerDB.Items[itemID][var] = value
	self:safeGetItemInfo(itemID)
	if list ~= nil then
		tagObject(list, itemID)
	end
end 

-- Add an item to the shopping list with a starting value of 0
function ReagentRestocker:addItemToShoppingList(reagent)
	self:addToList(reagent,0)
end

-- Add an item to the selling list
function ReagentRestocker:addItemToSellingList(reagent)
	self:addToList(reagent,-1)
end

-- Add an item to a generic list
function ReagentRestocker:addItemToList(reagent, list)
	self:addToListByID(reagent,0,list)
end

-- Remove an item from a list
function ReagentRestocker:removeItemFromList(reagent, list)
	-- If no lists are indocated, remove it from the database. Otherwise, remove
	-- it from the specified list.
	if list==nil then
		removeAllTags(reagent);
		ReagentRestockerDB.Items[reagent] = nil;
	else
		untagObject(list, reagent);
		
		-- TODO: Removing from the list completely is required for now.
		-- The selling and buying lists are not tagged, so right now if all
		-- of the tags are removed, it gets moved to one of them!
		ReagentRestockerDB.Items[reagent] = nil;
	end	
	ReagentRestocker:synchronizeOptionsTable();
end

-- Returns a table of the form {itemID = qtyOff}, indicating how far "off" the player's current stock of items is from "ideal"
function ReagentRestocker:getOffsetList(filter)
	local sl = {}
	for itemID, data in pairs (ReagentRestockerDB.Items) do
		if (self:listType(itemID) == SHOPPING_TYPE) then
			if not filter then
				sl[itemID] = data[QUANTITY_TO_STOCK] - self:countItemInBags(getPlayerBagIDList(),itemID)
			else
				local count = data[QUANTITY_TO_STOCK] - self:countItemInBags(getPlayerBagIDList(),itemID)
				if filter(itemID,count) then
					sl[itemID] = count				
				end
			end			
		end
	end
	
	return sl
end

-- Returns shoppping if the item ID is on the shopping list; selling if it is on the selling list; nil if it is not on any list
function ReagentRestocker:listType(itemID)
	if not ReagentRestockerDB.Items[itemID] then
		return nil
	else
		if ReagentRestockerDB.Items[itemID][QUANTITY_TO_STOCK] > -1 then
			return SHOPPING_TYPE
		else
			return SELLING_TYPE
		end
	end
end

-- Attempts to add an item to the appropriate list
function ReagentRestocker:addToList(reagent,qty)
	-- Make sure something was entered
	if (reagent == "") then
		self:say("Please enter an item name.")
	else
		-- Attempt to find the item; if we do, add it to items
		local itemID
		if type(reagent) == type(1) then
			itemID = reagent
		else
			itemID = self:discoverItemID(reagent)
		end
		
		if itemID then
			local _, itemLink = self:safeGetItemInfo(itemID)
			if ReagentRestockerDB.Items[itemID] then
				-- The item already exists in the item list
				self:say(string.format("%s is already on your %s list.", itemLink, self:listType(itemID)))
			else
				self:addToItems(itemID, QUANTITY_TO_STOCK, qty)
				local msg = string.format("%s has been added to your %s list.", itemLink, self:listType(itemID))
				if listType == SHOPPING_TYPE then
					msg = msg .. "  |cffff8000You must choose a stock quantity before ReagentRestocker will purchase this item.|r"
				end
				self:say(msg)
			end
		else
			self:say(string.format("Reagent Restocker cannot find %q; try adding it when you have the item in your bags, bank, or while visiting a vendor selling it.", reagent))
		end
		
		-- Now that the list is changed, update the options with the changes
		self:synchronizeOptionsTable()
		
	end

	-- Turn off notifier, since the user performed an action
	ReagentRestockerDB.Options.UnusedNotification = false
end

-- Attempts to add an item to the appropriate list
-- If "list"==nil, than add to one of old lists.
function ReagentRestocker:addToListByID(itemID,qty,list)
		if itemID then
			local _, itemLink = self:safeGetItemInfo(itemID)
			if ReagentRestockerDB.Items[itemID] then
				-- The item already exists in the item list
				if list == nil then
					self:say(string.format("%s is already on your %s list.", itemLink, self:listType(itemID)))
				else
					self:say(string.format("%s is already on your %s list.", itemLink, list))
				end
			else
				self:addToItems(itemID, QUANTITY_TO_STOCK, qty, list)
				local msg=""
				if list == nil then
					msg = string.format("%s has been added to your %s list.", itemLink, self:listType(itemID))
				else
					msg = string.format("%s has been added to your %s list.", itemLink, list)
				end
				if listType == SHOPPING_TYPE then
					msg = msg .. "  |cffff8000You must choose a stock quantity before ReagentRestocker will purchase this item.|r"
				end
				self:say(msg)
			end
		else
			self:say("Item not found; try adding it when you have the item in your bags, bank, or while visiting a vendor selling it.")
		end
		
		-- Now that the list is changed, update the options with the changes
		self:synchronizeOptionsTable()

	-- Turn off notifier, since the user performed an action
	ReagentRestockerDB.Options.UnusedNotification = false
end

-- Synchronizes the options table with the current settings
function ReagentRestocker:synchronizeOptionsTable()
	-- TODO: This is really quite hackish, and relies on not creating more groups at a certain level!
	-- Clear the items out of the options
	for _,t in pairs({Menu.args.shoppingOptions.args,Menu.args.sellingOptions.args}) do
		for k,l in pairs(t) do
			if l.type=="group" then
	
			t[k] = nil;
			end
		end
	end	

--	for _,t in pairs({Menu.args.shoppingOptions.args,Menu.args.sellingOptions.args}) do
--		for k,_ in pairs(t) do
--			if type(k) == type(1) then
--			if 
--				t[k] = nil
--			end
--		end
--	end	
	
	-- Populate the lists
	for itemID,data in pairs(ReagentRestockerDB.Items) do
		local itemName, _, _, _, _, _, _, itemStackCount, _, itemTexture = self:safeGetItemInfo(itemID)
		if (self:listType(itemID) == SHOPPING_TYPE) then
			-- Helper: Returns a suggested maximum-to-be-stocked quantity based on provided stack size
			-- Common stack sizes are 1, 5, 10, 20, 200
			local maxFromSC = function (stack)	
				if stack >= 1000 then
					return 28000
				elseif stack > 100 then
					return 6400
				elseif stack > 20 then
					return 3200
				elseif stack > 10 then
					return 640
				elseif stack > 1 then
					return 320
				else
					return 32
				end
			end	
			
			-- Add this item to the shopping section of the menu
			-- TODO: Check for bugs, as tostring(itemID) is new!
			Menu.args.shoppingOptions.args[tostring(itemID)] = {
				type = "group",
				name = itemName .. " (" .. tostring(ReagentRestockerDB.Items[itemID][QUANTITY_TO_STOCK]) .. ")",
				desc = "Currently stocking " .. tostring(ReagentRestockerDB.Items[itemID][QUANTITY_TO_STOCK]),
				icon = itemTexture,
				args = {		
					range = {	
						type = "range",
						step = ceil(itemStackCount/20),
						bigStep = itemStackCount,
						min = 0,
						max = maxFromSC(itemStackCount),
						name = "Stock how many?",
						desc = "Quantity of " .. itemName .. " you wish to keep stocked; Reagent Restocker will purchase enough so that you will have this many after leaving the vendor",
						get = function()
							--print("B4");
							return ReagentRestockerDB.Items[itemID][QUANTITY_TO_STOCK];
						end,
						set = function(x) ReagentRestockerDB.Items[itemID][QUANTITY_TO_STOCK] = x; self:synchronizeOptionsTable(); end,
						order = 1,
					},
					deleteTitle = {
						type = "header",
						name = "Remove this item from your Shopping List?",
						order = 3
					},
					
					delete = {
						type = "execute",
						desc = "Click to remove " .. itemName .. " from your Shopping List",
						name = "Remove",
						func = function() ReagentRestockerDB.Items[itemID] = nil; dataobj=nil; self:synchronizeOptionsTable();	end,
						order = 5
					}
				}
			}
		elseif (self:listType(itemID) == SELLING_TYPE) then	
			-- Add the item to the selling list
			Menu.args.sellingOptions.args[tostring(itemID)] = {	
				type = "group",
				name = itemName,
				desc = itemName,
				icon = itemTexture,
				args = {		
					deleteTitle = {
						type = "header",
						name = "Remove this item from your Selling List?",
						icon = itemTexture,
						order = 3
					},
					delete = {
						type = "execute",
						desc = "Click to remove " .. itemName .. " from your Shopping List",						
						name = "Remove",
						func = function() ReagentRestockerDB.Items[itemID] = nil; dataobj=nil; self:synchronizeOptionsTable(); end,
						order = 6
					}
				}
			}
		end
	end
	
	-- Update global for Blizzard to store.
	oldEnv.ReagentRestockerDB=ReagentRestockerDB;
	-- Tell Ace to update
	LibStub("AceConfigRegistry-3.0"):NotifyChange("ReagentRestocker");
	setfenv(1, oldEnv);
	addonTable.ReagentRestockerDB=ReagentRestockerDB
end

-- Locks out transactions to avoid multi-click problems; returns true if the transaction is has been locked; false if it is already locked
function ReagentRestocker:lockTransaction(sec)
	if not TransactionLock then
		TransactionLock = time()
		self:queueAction(function() return time() > TransactionLock + sec end, function() TransactionLock = false end)
		return true
	else
		-- It is already locked
		return false
	end
end

-- Prints a message letting the player know usage
function ReagentRestocker:notifyPlayer()
	if (tcount(ReagentRestockerDB.Items) == 0 and ReagentRestockerDB.Options.UnusedNotification) then
		self:say("Your Shopping List is currently empty.  |cffff8000Type /rr to get started (and get rid of this annoying message).|r")
	end
end


--======================--
-- Merchant Interaction --
--======================--

-- Handles auto-population of the selling list; adds new items in the buyback list to the selling list, if appropriate
function ReagentRestocker:MERCHANT_UPDATE()
	self:triggerAction(MERCHANT_UPDATE_EVENT)
	
	if ReagentRestockerDB.Options.AutoPopulate then
		for i=1,_G.GetNumBuybackItems() do
			local itemLink = _G.GetBuybackItemLink(i)
			if itemLink then 
				local itemID = getIDFromItemLink(itemLink)
				if not ReagentRestockerDB.Items[itemID] then
					-- Doesn't apply this rule to blue or better items; also doesn't apply to items that are to be sold
					local _, _, rarity = self:safeGetItemInfo(itemID)			
					if rarity < 3 and not self:isToBeSold(itemID) then
						self:addItemToSellingList(itemID)
					end
				end
			end
		end
	end
end

-- Handles auto-purching, -selling, and -repairing when the vendor window is opened
function ReagentRestocker:MERCHANT_SHOW()
	self:triggerAction(MERCHANT_SHOW_EVENT)

	if not self:lockTransaction(2) then
		self:say("You are attempting to begin too many transactions in a short time; ignoring ...")
		return
	end	
		
	-- Remind the player how to open RR
	self:notifyPlayer()
	
	-- Do the purchasing, selling, and repairing
	local endMoney, msgs, soldItemsInfo, queueReport = _G.GetMoney(), {}, {}, false
	if ReagentRestockerDB.Options.AutoBuy and self:isReagentVendor() then
		local cost, msg = self:buy()
		endMoney = endMoney - cost
		table.insert(msgs,msg)
		if cost > 0 then queueReport = true; end
	end
	if ReagentRestockerDB.Options.AutoRepair and _G.CanMerchantRepair() then
		local cost, msg = self:repair()
		endMoney = endMoney - cost
		table.insert(msgs,msg)
		-- TODO - Potential bug: Cost can be 0 if guild bank repair occured, but transction is occuring
		if cost > 0 then queueReport = true; end
	end
	if ReagentRestockerDB.Options.AutoSell then
		soldItemsInfo = self:sell()
	end
	
	--table.insert(msgs,string.format("Sold items for a profit of %s.",nCTS(GetMoney() - endMoney)));
	-- If we're waiting on a transaction to complete, let the player know
	if not queueReport and #soldItemsInfo == 0 then
		--self:say("Working, please wait ...")
		--if (GetMoney() - endMoney) > 0 then table.insert(msgs,string.format("Sold items for a profit of %s.",nCTS(GetMoney() - endMoney))); end
		self:say(table.concat(msgs))
	else
		self:say("Working, please wait ...")
		self:queueAction(
			function() return self:areSlotsUnlocked(soldItemsInfo); end,
			function() 
				if #soldItemsInfo > 0 then
					table.insert(msgs,"\n==== RECEIPT ====\n");
					for k, y in pairs(soldItemsInfo) do
						if soldItemsInfo[k][5] == true then
							table.insert(msgs,"Sold " .. soldItemsInfo[k][4] .. "x " .. soldItemsInfo[k][6] .. ".\n");
						else
							dprint(soldItemsInfo[k][4]);
							dprint(soldItemsInfo[k][6]);
							table.insert(msgs,"Destroyed " .. soldItemsInfo[k][4] .. "x " .. soldItemsInfo[k][6] .. ".\n");
						end
					end
					table.insert(msgs,string.format("Sold " .. #soldItemsInfo .. " items for a profit of %s.\n",nCTS(_G.GetMoney() - endMoney)));
					table.insert(msgs,"=================");
				else
					table.insert(msgs,"\n= No items sold =");
				end
				self:say(table.concat(msgs," ")); 
			end,
			PLAYER_MONEY_EVENT
		);
	end
end

-- Purchases as close to as possible the specified quantity of the item
function ReagentRestocker:purchaseItems(itemID, toBuy)
	local itemIndex
	for i=1,_G.GetMerchantNumItems() do
		local merchantItem = _G.GetMerchantItemLink(i)
		if merchantItem then
			if getIDFromItemLink(_G.GetMerchantItemLink(i)) == itemID then
				itemIndex = i
				break
			end
		end
	end
	
	if not itemIndex then
		return
	end
	
	-- Purchases only allow for 1 stack at maximum per "click"; iteratively buy stacks, then buy the last bit if any remain
	local _, _, _, _, _, _, _, itemStackSize = self:safeGetItemInfo(itemID)
	local _, _, _, qtyPerPurchase = _G.GetMerchantItemInfo(itemIndex)
	
	local _, _, _, tocversion = GetBuildInfo();
	if tocversion >= 40000 then
		-- BuyMerchantItem behavior changes in Cataclysm
		-- It now always buys the amount listed, and not the number of stacks. 
		-- Although it appears to be rounded up to the stack size :(.
		while toBuy > itemStackSize do
			_G.BuyMerchantItem(itemIndex, floor(itemStackSize))
			toBuy = toBuy - itemStackSize
		end
		if toBuy > 0 then
			_G.BuyMerchantItem(itemIndex, floor(toBuy))
		end
		
	else
	
		while toBuy > itemStackSize do
			_G.BuyMerchantItem(itemIndex, floor(itemStackSize/qtyPerPurchase))
			toBuy = toBuy - itemStackSize
		end
		if toBuy > 0 then
			_G.BuyMerchantItem(itemIndex, floor(toBuy/qtyPerPurchase))
		end
	end
end	

-- Returns true if the item is able to be sold and if preferences dictate it should be; false otherwise
function ReagentRestocker:isToBeSold(itemID)
	local _, _, quality = self:safeGetItemInfo(itemID)
	if ReagentRestockerDB.Items[itemID] ~= nil then
		--dprint("Item name: " .. ReagentRestockerDB.Items[itemID]["0"])
		--dprint("Sell price: " .. nCTS(ReagentRestocker:getSellPrice(itemID)))
	end
		--[[
		 IF:
		 	--We are automatically selling greys and it is in fact a grey, or
			--It's on the selling list
			
			-and it can be sold.
			
			Then sell it.
		]]--
	if ((ReagentRestockerDB.Options.AutoSellGrays and quality == 0) or (self:listType(itemID) == SELLING_TYPE)) and ReagentRestocker:getSellPrice(itemID) > 0 then
		-- Except when it's on the exception list.
		if type(ReagentRestockerDB.Items[itemID]) ~= "nil" and
		type(ReagentRestockerDB.Items[itemID].tags) ~= "nil" and
		ReagentRestockerDB.Items[itemID].tags.Exception ~= nil then
			return false
		end
		return true
	else
		return false
	end
end

function ReagentRestocker:isToBeDestroyed(itemID)
	if ReagentRestockerDB.Options.AutoDestroyGrays == true then
		local _, _, quality = self:safeGetItemInfo(itemID)
		--[[
		 IF:
		 	--We are automatically destroying greys and it is in fact a grey, or
			--It's on the selling list
			
			-and it can't be sold.
			
			Then destroy it.
		]]--
			if ((ReagentRestockerDB.Options.AutoDestroyGrays and quality == 0) or (self:listType(itemID) == SELLING_TYPE)) and ReagentRestocker:getSellPrice(itemID) == 0 then
				-- Except when it's on the exception list.
				if type(ReagentRestockerDB.Items[itemID]) ~= "nil" and
				type(ReagentRestockerDB.Items[itemID].tags) ~= "nil" and
				ReagentRestockerDB.Items[itemID].tags.Exception ~= nil then
					return false
				end
				return true
			else
				return false
			end
	else
		-- Never detroy if we don't have the option on.
		return false
	end
end

-- Returns true if the merchant sells items on the player's shopping list; false otherwise
function ReagentRestocker:isReagentVendor()
	for i=1,_G.GetMerchantNumItems() do
		local merchantItem = _G.GetMerchantItemLink(i)
		if merchantItem then
			if (self:listType(getIDFromItemLink(merchantItem)) == SHOPPING_TYPE) then
				return true
			end
		end
	end	
	return false
end

-- Repairs the character's equipment, if necessary; returns the cost and a report string
function ReagentRestocker:repair()
	if _G.CanMerchantRepair() then
		local msg, cost = "", _G.GetRepairAllCost()
		
		if ReagentRestockerDB.Options.RepairDiscount and not self:meetsDiscountRequirements() and cost > 0 then
			return 0, string.format("This vendor is not offering a %d%% or better discount; your items will not be repaired.",ReagentRestockerDB.Options.RequiredDiscount)
		end		
		
		-- Warn the player if he's not capable of making guild bank repairs
		if not _G.CanGuildBankRepair() and ReagentRestockerDB.Options.UseGuildBankFunds then
			msg = "You are not authorized to make repairs via the guild bank.  "
		end
	
		-- Do the repairing
		if cost > 0 then 
			if _G.CanGuildBankRepair() and ReagentRestockerDB.Options.UseGuildBankFunds then
				-- TODO: If the repair is only partially from the guild, the cost is not actually 0
				msg = msg .. string.format("Your gear has been repaired using the guild bank's funds, costing it %s.", nCTS(cost))
				cost = 0
				_G.RepairAllItems(1)
			elseif _G.GetRepairAllCost() <= _G.GetMoney() then
				msg = msg .. string.format("Your gear has been repaired, costing you %s.", nCTS(cost))
				_G.RepairAllItems()
			elseif _G.GetRepairAllCost() > _G.GetMoney() then
				msg = msg .. string.format("Insufficient funds to repair (%s required).", nCTS(cost))
				cost = 0
			end
		else
			msg = "You are already fully repaired."
			cost = 0
		end
		
		return cost, msg
	else
		return 0, "This merchant cannot repair gear."
	end
end

-- Buys the necessary reagents based on those that are currently in the player's inventory; returns the cost and a reporting string
function ReagentRestocker:buy()
	-- Keep track of what items will actually be bought
	local buyingList, cost, shoppingList = {}, 0, self:getOffsetList()
	
	-- Grab only the items that we need from the shopping list
	map(shoppingList, function(itemID,qty) if qty < 1 then shoppingList[itemID] = nil; end end)
	
	-- Look through all of the merchant's items
	for i=1,_G.GetMerchantNumItems() do
		local merchantItem = _G.GetMerchantItemLink(i)
		if merchantItem then
			local itemID = getIDFromItemLink(merchantItem)
			local numDesired = shoppingList[itemID]
			local _, _, itemPrice, qtyPerPurchase, itemQtyAvailable = _G.GetMerchantItemInfo(i)
			if numDesired then
				local buyQty
				if itemQtyAvailable == -1 then -- Unlimited quantity
					buyQty = numDesired
				else -- Limited quantity; take at most the number that are available
					buyQty = min(numDesired, itemQtyAvailable)
				end
				-- Round down to quantity to an integer multiple of the quantity in which they can be purchased (some items can't be purchased 1 by 1)
				if ReagentRestockerDB.Options.NotOverstock then
					buyingList[itemID] = floor(buyQty/qtyPerPurchase)*qtyPerPurchase
				else
					buyingList[itemID] = ceil(buyQty/qtyPerPurchase)*qtyPerPurchase
				end
				cost = cost + (buyingList[itemID]/qtyPerPurchase) * itemPrice
			end
		end
	end
	
	-- Filter out useless purchases
	for k,v in pairs(buyingList) do
		if v == 0 then
			buyingList[k] = nil
		end
	end
	
	-- Is there actually anything to be purchased?
	if tcount(buyingList) == 0 then
		return 0, "Already stocked on this vendor's items."
	end	
	
	-- Make sure the player has enough money
	if cost > _G.GetMoney() then
		return 0, string.format("Insufficient funds to purchase reagents (%s required).",nCTS(cost))
	end
	
	-- Make sure the vendor is offering the appropriate discount
	if not self:meetsDiscountRequirements() then
		return 0, string.format("This vendor is not offering a %d%% or better discount; no items will be purchased.",ReagentRestockerDB.Options.RequiredDiscount)
	end
		
	-- Purchase the items
	for itemID,qty in pairs(buyingList) do
		self:purchaseItems(itemID,qty)
	end
	
	-- Builds a readable list of strings and quantities
	local purchasedItemLinkList = {}
	map(buyingList,function(itemID,qty) local _, l = self:safeGetItemInfo(itemID); table.insert(purchasedItemLinkList,string.format("%d %s",qty,l)); end)
	
	-- Build the message to report
	return cost, string.format("Purchased %s, costing a total of %s.",table.concat(purchasedItemLinkList,", "),nCTS(cost))
end

-- Sells the appropriate item from the player's inventory; returns list of items sold
function ReagentRestocker:sell()
	local soldItemsInfo = {} -- {bagID, bagSlotID} list
	for _,bagID in pairs(getPlayerBagIDList()) do
		for bagSlotID=1,GetContainerNumSlots(bagID) do
			local itemLink = GetContainerItemLink(bagID,bagSlotID)
			if itemLink then
			
				-- If if can and should be sold, sell it
				if self:isToBeSold(getIDFromItemLink(itemLink)) then
					local _, qty = GetContainerItemInfo(bagID, bagSlotID)
					UseContainerItem(bagID,bagSlotID)
					
					-- Bag ID, BagSlot ID, Item link, quantity, (true=sold, false=destroyed), item name.
					table.insert(soldItemsInfo,{bagID,bagSlotID,getIDFromItemLink(itemLink),qty,true, getNameFromItemLink(itemLink)})

				-- If if can and should be destroyed, destroy it
				elseif self:isToBeDestroyed(getIDFromItemLink(itemLink)) then
					local _, qty = GetContainerItemInfo(bagID, bagSlotID)
					dprint("Destroy" .. itemLink);
					_G.PickupContainerItem(bagID, bagSlotID);
					quickDialog("Do you really want to destroy " .. getNameFromItemLink(itemLink) .. "?\nWARNING: Destroyed items cannot be recovered.",
						function()
							dprint("OK");
							_G.DeleteCursorItem();
							self:say(getNameFromItemLink(itemLink) .. " destroyed!")
						end, function()
							dprint("CANCEL");
							_G.ClearCursor();
						end, "Destroy", "Keep");
					-- Bag ID, BagSlot ID, Item link, quantity, (true=sold, false=destroyed), item name.
					--table.insert(soldItemsInfo,{bagID,bagSlotID,getIDFromItemLink(itemLink),qty,false, getNameFromItemLink(itemLink)})
				end
				
				
			end
		end
	end
	return soldItemsInfo
end

-- Returns true if the player has required reputation with current merchant window; false otherwise
function ReagentRestocker:meetsDiscountRequirements()
	-- Return true if the available discount is anywhere from required to 20%
	if self:getMerchantDiscount() >= ReagentRestockerDB.Options.RequiredDiscount then
		return true
	end
	return false
end

-- Returns the integer percentage that the merchant is offering
function ReagentRestocker:getMerchantDiscount()

	-- Test code that is hopefully more accurate at getting the discount
	local reaction = _G.UnitReaction("target", "player")
	
	if reaction then
		return max((reaction-4) * 5, 0);
	end
	
	-- The old code is below
	
	-- Helper: Returns true if removing the discount from the price results in more 0s than the original price
	local isDiscounted = function (price, discountPercent)
		-- Helper: Returns the number of 0s in the [decimal] number
		local numZeroes = function (num)
			local zeroCount = 0
			while floor(num/10) == num/10 and num > 9 do
				num = num/10
				zeroCount = zeroCount + 1
			end
			
			return zeroCount
		end
		
		return numZeroes(price) < numZeroes(floor(price/(1 - discountPercent/100) + 0.5))
	end

	local merchantPriceList = {}
	for i=1, _G.GetMerchantNumItems() do
		local _, _, price = _G.GetMerchantItemInfo(i)
		if price then
			table.insert(merchantPriceList,price)
		end
	end	

	-- Check every multiple of 5% from under the required discount (or lower) to 20%
	for discountPercent = floor(ReagentRestockerDB.Options.RequiredDiscount/5)*5, 20, 1 do
		local numDiscounted = 0
		for _,price in ipairs(merchantPriceList) do
			if isDiscounted(price, discountPercent) then
				numDiscounted = numDiscounted + 1
			end
		end
		
		if (0.4 < numDiscounted/#merchantPriceList) then
			return discountPercent
		end
	end
	
	-- At this point, can't assess discount; assume no discount
	return 0
end

function ReagentRestocker:getVersion()
	return GetAddOnMetadata(addonName, "Version");
end

-- WARNING: Completely untested!!!!
--TODO: untested
function ReagentRestocker:deleteItem(item)
		ReagentRestockerDB.Items[item] = nil;
		dataobj=nil;
		ReagentRestocker:synchronizeOptionsTable();
		refreshShoppingList();
		selectTree:RefreshTree();
end

--========--
-- Events --
--========--

function ReagentRestocker:OnInitialize()
	self:RegisterEvent(MERCHANT_SHOW_EVENT)	-- Buying and selling items
	self:RegisterEvent(MERCHANT_UPDATE_EVENT)	-- Adding items to selling list
	self:RegisterEvent(BANKFRAME_OPENED_EVENT)	-- Initiate bank transfers
	self:RegisterEvent(VARIABLES_LOADED_EVENT)	-- Initializing variables
	self:RegisterEvent(ITEM_LOCK_CHANGED_EVENT)	-- Queued events
	self:RegisterEvent(PLAYER_MONEY_EVENT)
	self:RegisterEvent(BAG_UPDATE_EVENT)
	self:RegisterEvent(PLAYER_LEAVING_WORLD_EVENT) -- Player leaving world (stop updating bag info).
	self:RegisterEvent(BAG_UPDATE_COOLDOWN_EVENT) -- Bags ready to start updating.
	self:RegisterEvent(UPDATE_INVENTORY_DURABILITY_EVENT)
	self:RegisterEvent(PLAYER_ENTERING_WORLD_EVENT)
	
	-- Try to detect Raid Roll, and do not override its slash command if it has set one.
	if RaidRollHasLoaded ~= true then
		self:RegisterChatCommand("rr", function ()
			ReagentRestockerDB.Options.UnusedNotification = false;
			ReagentRestocker:showFrame();
		end)
	end

	-- Always register /rrstock and /reagentrestocker.
	self:RegisterChatCommand("rrstock", function ()
		ReagentRestockerDB.Options.UnusedNotification = false;
		ReagentRestocker:showFrame();
	end)

	self:RegisterChatCommand("reagentrestocker", function ()
		ReagentRestockerDB.Options.UnusedNotification = false;
		ReagentRestocker:showFrame();
	end)

	self:RegisterChatCommand("rrbuy", function(input) ReagentRestocker:addToList(input,0) end );
	self:RegisterChatCommand("rrsell", function(input) ReagentRestocker:addToList(input,-1) end );

	LibStub("AceConfig-3.0"):RegisterOptionsTable("Reagent Restocker", Menu);
	
	dprint("Connected to Ace.");
	
end


-- Adds an action to action queue
function ReagentRestocker:queueAction(evaluator, action, eventID)
	table.insert(QueuedActions,{evaluator,action,eventID})
end

function ReagentRestocker:triggerAction(eventID)
	dprint(string.format("A [%s] event has been triggered.",tostring(eventID)))

	for i=#QueuedActions,1,-1 do
		-- Only run the action if the correct eventID is specified -or- if there is no event specified
		if not QueuedActions[i][3] or QueuedActions[i][3] == eventID then
			if QueuedActions[i][1]() then
				-- If the evaluator for an action is true, then its associated action is performed; then the action is deleted			
				local theAction = QueuedActions[i][2]
				table.remove(QueuedActions,i)
				theAction()
			end			
		end
	end
end

function ReagentRestocker:PLAYER_MONEY()
	self:triggerAction(PLAYER_MONEY_EVENT)
end

function ReagentRestocker:BAG_UPDATE()
	self:triggerAction(BAG_UPDATE_EVENT)
end

function ReagentRestocker:ITEM_LOCK_CHANGED(bagID, bagSlotID)
	self:triggerAction(ITEM_LOCK_CHANGED_EVENT)	
end

--===============--
-- Database load --
--===============--

-- Helper method to fix a database problem: Apparently, some previous versions
-- put a table in where there should be a boolean - which works, but
-- blows up the file size and affects the load time.
function ReagentRestocker:fixBoolean(var)
	if type(var)=="table" then
		return true;
	else
		return var;
	end
end


function ReagentRestocker:VARIABLES_LOADED()

	setfenv(1, oldEnv)
	
	-- Activate debugging, if neccesary.
	if ReagentRestockerDB and ReagentRestockerDB.Options.Debug ~= nil and ReagentRestockerDB.Options.Debug == true then
		debugRR=true;
	else
		debugRR=false;
	end
	
	-- Initialize variables.
	if not ReagentRestockerDB then
		dprint("New database.");
		ReagentRestockerDB = {}
		ReagentRestockerDB.Options = {}
		ReagentRestockerDB.Options.UnusedNotification = true
		ReagentRestockerDB.Options.AutoBuy = true
		ReagentRestockerDB.Options.AutoSell = true
		ReagentRestockerDB.Options.RequiredDiscount = 0
		ReagentRestockerDB.Options.UseTextLDB = false
		ReagentRestockerDB.Options.SingleLDB = true
		ReagentRestockerDB.Options.ReagentWarning = true
		ReagentRestockerDB.Options.AutoDestroyGrays = false
		ReagentRestockerDB.Items = {}
		ReagentRestockerDB.Tags = {}
		ReagentRestockerDB.Version = GetAddOnMetadata(addonName, "Version");
		
		-- Database version, so I don't have to parse the addon's version, which is a string.
		ReagentRestockerDB.DataVersion = 6;
	end
	
	-- Initialize variables new to 2.0.
	if ReagentRestockerDB.DataVersion == nil then
		ReagentRestockerDB.Options.UseTextLDB = false
		ReagentRestockerDB.Options.SingleLDB = true
		ReagentRestockerDB.Version = GetAddOnMetadata(addonName, "Version");
		ReagentRestockerDB.version = nil;
		ReagentRestockerDB.DataVersion = 1;
	end
	
	-- Add LOW_WARNING to items
	if ReagentRestockerDB.DataVersion == 1 then
		for k, v in pairs(ReagentRestockerDB["Items"]) do
			if ReagentRestockerDB["Items"][k]["qty"] >= 0 then
				ReagentRestockerDB["Items"][k]["low_warning"] = ReagentRestockerDB["Items"][k]["qty"];
			end
		end
		ReagentRestockerDB.DataVersion = 2;
	end
	
	-- Add option to disable low reagent warnings.
	if ReagentRestockerDB.DataVersion == 2 then
		ReagentRestockerDB.Options.ReagentWarning = true
		ReagentRestockerDB.DataVersion = 3;
	end
	
	-- Add LOW_WARNING to ALL items
	if ReagentRestockerDB.DataVersion == 3 then
		for k, v in pairs(ReagentRestockerDB["Items"]) do
			if type(ReagentRestockerDB["Items"][k]["low_warning"]) == "nil" then
				ReagentRestockerDB["Items"][k]["low_warning"] = 0;
			end
		end
		ReagentRestockerDB.DataVersion = 4;
	end
	
	if ReagentRestockerDB.DataVersion == 4 then
		-- Make absolutely sure we have the tags database.
		if ReagentRestockerDB.Tags == nil then
			ReagentRestockerDB.Tags = {}
		end
		
		-- Make sure all items have tags
		for k, v in pairs(ReagentRestockerDB["Items"]) do
			if type(ReagentRestockerDB["Items"][k]["tags"]) == "nil" then
				ReagentRestockerDB["Items"][k]["tags"] = {}
			end
		end
		ReagentRestockerDB.DataVersion = 5;
	end
	
	-- Add option to disable low reagent warnings.
	if ReagentRestockerDB.DataVersion == 5 then
		ReagentRestockerDB.Options.AutoDestroyGrays = false
		ReagentRestockerDB.DataVersion = 6;
	end
	
	-- Fix any booleans that became tables.
	ReagentRestockerDB.Options.UnusedNotification = ReagentRestocker:fixBoolean(ReagentRestockerDB.Options.UnusedNotification)
	ReagentRestockerDB.Options.AutoBuy = ReagentRestocker:fixBoolean(ReagentRestockerDB.Options.AutoBuy)
	ReagentRestockerDB.Options.AutoSell = ReagentRestocker:fixBoolean(ReagentRestockerDB.Options.AutoSell)
	ReagentRestockerDB.Options.UseTextLDB = ReagentRestocker:fixBoolean(ReagentRestockerDB.Options.UseTextLDB)
	ReagentRestockerDB.Options.SingleLDB = ReagentRestocker:fixBoolean(ReagentRestockerDB.Options.SingleLDB)
	ReagentRestockerDB.Options.ReagentWarning = ReagentRestocker:fixBoolean(ReagentRestockerDB.Options.ReagentWarning)
		
		
	dprint(addonName .. " version: " .. ReagentRestockerDB.Version);
	dprint(addonName .. " database version: " .. ReagentRestockerDB.DataVersion);
	

	-- Load RR's version from the TOC file.
	ReagentRestockerDB.Version = GetAddOnMetadata(addonName, "Version");
	
	addonTable.ReagentRestockerDB = ReagentRestockerDB
	setfenv(1, addonTable)
	self:synchronizeOptionsTable()
	self:notifyPlayer()
	
	-- Init tags.
	if debugRR then
		tagsInit();
	end
	
end

-- Are we updating?
local isUpdating = false;
function ReagentRestocker:PLAYER_LEAVING_WORLD()
	isUpdating = false;
end

function ReagentRestocker:BAG_UPDATE_COOLDOWN()
	isUpdating = true;
end

function ReagentRestocker:UPDATE_INVENTORY_DURABILITY()
	isUpdating = true;
end

function ReagentRestocker:PLAYER_ENTERING_WORLD()
	playerEnteredTime=_G.GetTime();
end


--==========--
-- Bank/Bags --
--==========--

function ReagentRestocker:BANKFRAME_OPENED()
	self:triggerAction(BANKFRAME_OPENED_EVENT)
	
	if ReagentRestockerDB.Options.PullFromBank or ReagentRestockerDB.Options.OverstockToBank then
		if not self:lockTransaction(2) then
			self:say("You are attempting to begin too many transactions in a short time; ignoring ...")
			return
		end

		if self:recursiveMove(self:getOffsetList(bankOffset),getPlayerBagIDList(),getBankBagIDList()) then
			self:say("Working, please wait ...")
		end
	end
end

-- Returns true if the item in the specified slot is locked; false otherwise
function ReagentRestocker:isSlotUnlocked(bagID,bagSlotID)
	local _, _, isLocked = GetContainerItemInfo(bagID, bagSlotID)
	return not isLocked
end

-- Returns true if all of the items in the specified slot are unlocked; false otherwise
function ReagentRestocker:areSlotsUnlocked(bagIDSlotPairs)
	for i=1,#bagIDSlotPairs do
		if not self:isSlotUnlocked(bagIDSlotPairs[i][1],bagIDSlotPairs[i][2]) then
			return false
		end
	end

	return true
end

-- Returns the number of the specified item in the specified bag
function ReagentRestocker:countItemInBag(bagID,itemID)
	local count = 0
	for bagSlotID=1,GetContainerNumSlots(bagID) do
		local itemLink = GetContainerItemLink(bagID,bagSlotID)
		if itemLink then	
			if getIDFromItemLink(itemLink) == itemID then	
				local _, slotCount = GetContainerItemInfo(bagID,bagSlotID)
					count = count + slotCount
			end
		end
	end
	
	return count
end

-- Returns the number of the specified item in the specified bags
function ReagentRestocker:countItemInBags(bagIDList,itemID)
	local count = 0
	for _,bagID in pairs(bagIDList) do
		count = count + self:countItemInBag(bagID,itemID)
	end
	
	return count
end

-- Attempts to safely move an item from one slot to another; splitting often causes problems unless it is 100% necessary
function ReagentRestocker:safeContainerMove(fromBagID, fromBagSlotID, toBagID, toBagSlotID, qty)
	local _, sourceStackCount = GetContainerItemInfo(fromBagID,fromBagSlotID)
	local _, destStackCount = GetContainerItemInfo(toBagID,toBagSlotID)
	
	if not sourceStackCount then sourceStackCount = 0 end
	if not destStackCount then destStackCount = 0 end			
	
	local doMove = false
	if destStackCount > 0 then
		local _, _, _, _, _, _, _, destStackableCount = self:safeGetItemInfo(getIDFromItemLink(GetContainerItemLink(toBagID,toBagSlotID)))
		if destStackCount + qty >= destStackableCount then
			doMove = true
		end
	end
	
	_G.ClearCursor()
	if sourceStackCount > qty and not doMove then
		_G.SplitContainerItem(fromBagID,fromBagSlotID,qty)
	else
		_G.PickupContainerItem(fromBagID,fromBagSlotID)
	end
	_G.PickupContainerItem(toBagID,toBagSlotID)	
end

-- Attempts to move items from one baglist to another, based on shopping list
function ReagentRestocker:recursiveMove(startOffsetList, fromBags, toBags)
	-- Attempt to find an appropriate move
	local offsetList = self:getOffsetList(bankOffset)
	local fromBagID, fromBagSlotID, toBagID, toBagSlotID, qty, itemID = self:findNecessaryMove(offsetList,fromBags,toBags)	
	if fromBagID then -- If there is one, perform the move, and queue up another recursiveMove
		self:safeContainerMove(fromBagID, fromBagSlotID,toBagID, toBagSlotID, qty)
		local _, pSSC = GetContainerItemInfo(fromBagID,fromBagSlotID)
		local _, pDSC = GetContainerItemInfo(toBagID,toBagSlotID)
		self:queueAction(
			function()
				local _, sSC = GetContainerItemInfo(fromBagID,fromBagSlotID)
				local _, dSC = GetContainerItemInfo(toBagID,toBagSlotID)
				return self:areSlotsUnlocked({{fromBagID, fromBagSlotID},{toBagID, toBagSlotID}}) and pSSC ~= sSC and pDSC ~= dSC
			end,
			function() 
				self:recursiveMove(startOffsetList, fromBags, toBags)
			end
			)
		return true
	else -- If there isn't one, return false, and report our findings from movesThusFar
		local withdrawList, depositList, msgs = {}, {}, {} 
		for itemID, qty in pairs(tDiff(startOffsetList, offsetList)) do
			local _, itemLink = self:safeGetItemInfo(itemID)
			if qty > 0 then table.insert(depositList,string.format("%d %s",qty,itemLink)); else if qty < 0 then table.insert(withdrawList,string.format("%d %s",-1*qty,itemLink)); end end
		end		
		if #withdrawList == 0 and #depositList == 0 then
			self:say("No bank transactions are necessary.")
		else	
			if #withdrawList > 0 then 
				table.insert(msgs,string.format("Deposited %s.",table.concat(withdrawList,", ")))
			end
			if #depositList > 0 then
				table.insert(msgs,string.format("Withdrew %s.",table.concat(depositList,", ")))
			end
			self:say(table.concat(msgs,"  "))
		end
	end
end

-- Returns a necessary move; nil if there are none
function ReagentRestocker:findNecessaryMove(offsetList, fromBags, toBags)
	map(offsetList,function(itemID, qty) if qty == 0 then offsetList[itemID] = nil; end end)
	for itemID, qty in pairs(offsetList) do
		local lFromBags, lToBags = fromBags, toBags
		if qty < 0 then -- We are moving FROM the TOBAGS to TO the FROMBAGS, so switch 'em
			lToBags, lFromBags, qty = fromBags, toBags, -1*qty
		end
		local fromBagID, fromBagSlotID, fromQty = self:findOptimalItemsToMove(lToBags, itemID)
		if fromBagID then -- fromBagID will be nil if fOITM was unsuccessful
			local toBagID, toBagSlotID, toQty = self:findOptimalDestinationInBags(lFromBags, itemID)
			if toBagID then -- toBagID will be nil if fODIB was unsuccessful
				return fromBagID, fromBagSlotID, toBagID, toBagSlotID, min(fromQty, toQty, qty), itemID				
			end
		end
	end
	return nil
end

-- Returns the location and quantity of an item that should be moved; nil if there are none
function ReagentRestocker:findOptimalItemsToMove(bagIDList, itemID)
	-- Find the optimal bag to remove the item from (least of that item)
	local itemInBagCountList = {}
	map(bagIDList,function(_,bagID) local count = self:countItemInBag(bagID,itemID); if count > 0 then table.insert(itemInBagCountList,{bagID,count}); end end)
	table.sort(itemInBagCountList,	function(x, y) if (x[2] ~= y[2]) then return x[2] < y[2]; else return (x[1] > y[1]); end end)
	for _, data in pairs(itemInBagCountList) do
		local bagSlotItemCount = {}
		for bagSlotID=1,GetContainerNumSlots(data[1]) do
			local itemLink = GetContainerItemLink(data[1], bagSlotID)
			if itemLink then
				local _, itemCount = GetContainerItemInfo(data[1], bagSlotID)
				local sourceItemID = getIDFromItemLink(itemLink)
				if sourceItemID == itemID then
					table.insert(bagSlotItemCount,{bagSlotID,itemCount})
				end
			end
		end
		-- Find the slot with the lowest value and return it
		table.sort(bagSlotItemCount, function(x,y) return x[2] < y[2]; end)
		for i=1,#bagSlotItemCount do
			return data[1], bagSlotItemCount[i][1], bagSlotItemCount[i][2]
		end
	end	
	return nil
end

-- Returns the "optimal" slot in the bags for the item to be placed and the number that can be moved there; nil if impossible
function ReagentRestocker:findOptimalDestinationInBags(bagIDList, itemID)
	-- First, find the optimal bag to place the item in (the once with the most of it)
	local itemInBagCountList = {}
	map(bagIDList,function(_,bagID) table.insert(itemInBagCountList,{bagID,self:countItemInBag(bagID,itemID)}); end)
	table.sort(itemInBagCountList,	function(x, y) if (x[2] ~= y[2]) then return x[2] > y[2]; else return (x[1] < y[1]); end end)
	for _, data in pairs(itemInBagCountList) do
		-- TODO: We're mostly avoiding special bag types
		if data[2] > 0 or not self:isSpecialBagType(data[1]) then
			local bagID, bagSlotID, qty = self:findOptimalDestinationInBag(data[1],itemID)
			if bagID then -- bagID is nil if fODIB returns a negative result (no space)
				return data[1], bagSlotID, qty
			end
		end
	end
	return nil
end

-- Returns the "optimal" slot in the bag for the item to be placed and the number that can be moved there; nil if impossible
function ReagentRestocker:findOptimalDestinationInBag(bagID, sourceItemID)
	-- First, look for any stacks of the item that are not full
	local _, _, _, _, _, _, _, itemStackSize = self:safeGetItemInfo(sourceItemID)
	local slotStatusList, OPEN, CLOSED, SAME = {}, 0, -1, 1
	for bagSlotID=1,GetContainerNumSlots(bagID) do
		local itemLink = GetContainerItemLink(bagID, bagSlotID)
		if itemLink then
			local _, itemCount = GetContainerItemInfo(bagID, bagSlotID)
			local itemID = getIDFromItemLink(itemLink)
			if sourceItemID == itemID then
				slotStatusList[bagSlotID] = SAME
				if itemCount < itemStackSize then
					return bagID, bagSlotID, itemStackSize - itemCount
				end
			else
				slotStatusList[bagSlotID] = CLOSED
			end
		else
			slotStatusList[bagSlotID] = OPEN
		end
	end
	
	-- No un-full stacks were found; look for a pattern in the full ones
	local emptySlotList, sameItemSlotList, hopSizeList, bestDiffVal = {}, {}, {}, 1
	map(slotStatusList,function(slotID, status) if status == SAME then table.insert(sameItemSlotList,slotID); end end)
	map(slotStatusList,function(slotID, status) if status == OPEN then table.insert(emptySlotList,slotID); end end)
	
	-- If there are no empty slots, return nil
	if #emptySlotList == 0 then
		return
	end
	
	if #sameItemSlotList > 1 then
		-- We have more than 1 stack of the item in the bag; find the modal difference in slot IDs
		for i=1,#sameItemSlotList-1 do
			local diff = abs(sameItemSlotList[i+1] - sameItemSlotList[i])
			if hopSizeList[diff] then
				hopSizeList[diff] = hopSizeList[diff] + 1
			else
				hopSizeList[diff] = 1	
			end
		end
		local bestDiffCount = 0
		map(hopSizeList, function (diffVal, diffCount) if diffCount > bestDiffCount then bestDiffVal = diffVal; bestDiffCount = diffCount; end end)
	end
	
	-- Look in each slot "diff" away from the slot in which the same item exists; if it is available, use it
	for _, slot in pairs(sameItemSlotList) do
		if inT(emptySlotList,slot-bestDiffVal) then
			return bagID, slot-bestDiffVal, itemStackSize
		elseif inT(emptySlotList,slot+bestDiffVal) then
			return bagID, slot+bestDiffVal, itemStackSize		
		end
	end
	
	-- No good places to put the item; just return the [at least] one we know exists
	return bagID, emptySlotList[1], itemStackSize
end

-- Returns true if the bag is of a special bag type; false otherwise
function ReagentRestocker:isSpecialBagType(bagID)
	-- Every item can go in the backpack (0) or bank slots (-1)
	if bagID == 0 or bagID == -1 then
		return false
	end

	local inventoryID = _G.ContainerIDToInventoryID(bagID)
	local itemLink = _G.GetInventoryItemLink("player",inventoryID)

	-- If there's no bag, it's not compatible
	if not itemLink then
		return true
	end
	
	local _, _, _, _, _, _, itemSubType = self:safeGetItemInfo(getIDFromItemLink(itemLink))
	
	-- No way to check the type without localizing; if the name is long, it's a special bag, so NO
	if strlen(itemSubType) < 8 then	
		return false
	else		
		return true
	end
end


---------
-- LDB --
---------
local ldb = LibStub:GetLibrary("LibDataBroker-1.1", true)

local UPDATEPERIOD, elapsed = 0.5, 0
local f = _G.CreateFrame("frame")
f:RegisterEvent("BAG_UPDATE");
local dataobj = nil;

addonTable.checkLow = function(self, event, ...)
	if dataobj==nil then dataobj={} end;
	for itemID, numItems in pairs(ReagentRestockerDB.Items) do
		if itemID==nil then derror("itemID == nil!") end
		if (ReagentRestocker:listType(itemID) == SHOPPING_TYPE) then
			if type(dataobj[itemID]) == "nil" then
			dataobj[itemID] = {};
				dataobj[itemID].warned = true;
			end
			if type(dataobj[itemID].warned) == "nil" then
				dataobj[itemID].warned = true;
			end
			if type(ReagentRestockerDB["Items"][itemID][LOW_WARNING])=="nil" then
				ReagentRestockerDB["Items"][itemID][LOW_WARNING] = 0;
			end
			
			if playerEnteredTime + 2 < _G.GetTime() and ReagentRestocker:countItemInBags(getPlayerBagIDList(),itemID) <  ReagentRestockerDB["Items"][itemID][LOW_WARNING] and dataobj[itemID].warned == false and ReagentRestockerDB.Options.ReagentWarning == true then
				if type(MikSBT) ~= "nil" then
					MikSBT.DisplayMessage(ReagentRestockerDB["Items"][itemID][ITEM_NAME] .. " is low!");
					dprint(ReagentRestockerDB["Items"][itemID][ITEM_NAME] .. " is low: " .. ReagentRestocker:countItemInBags(getPlayerBagIDList(),itemID) .. " < " .. ReagentRestockerDB["Items"][itemID][LOW_WARNING]);
				else
					UIErrorsFrame:AddMessage(ReagentRestockerDB["Items"][itemID][ITEM_NAME] .. " is low!", nil, nil, nil, nil, 5);
					dprint(ReagentRestockerDB["Items"][itemID][ITEM_NAME] .. " is low: " .. ReagentRestocker:countItemInBags(getPlayerBagIDList(),itemID) .. " < " .. ReagentRestockerDB["Items"][itemID][LOW_WARNING]);
				end
				dataobj[itemID].warned = true;
			elseif ReagentRestockerDB["Items"][itemID][LOW_WARNING] ~= nil and ReagentRestocker:countItemInBags(getPlayerBagIDList(),itemID) >  ReagentRestockerDB["Items"][itemID][LOW_WARNING] then
				dataobj[itemID].warned = false;
			end
		end
	end
end

if(ldb) then

	addonTable.updateLDB = function(self, event, ...)
			--[[elapsed = elapsed + elap
		if elapsed < UPDATEPERIOD then return end
		elapsed = 0]]--
		if dataobj==nil then dataobj={} end;
		
		-- Sometimes LDB is called before all variables are loaded.
		-- Ignore when that happens.
		if ReagentRestockerDB==nil then return end
		if ReagentRestocker.listType==nil then return end;
		if ReagentRestocker.safeGetItemInfo==nil then return end;
		-- Library loaded, add stuff
		if ReagentRestockerDB.Options.SingleLDB then
			ldb:NewDataObject("Reagent Restocker", {
				type = "launcher",
				icon = "Interface\\Icons\\INV_Alchemy_EndlessFlask_01",
				OnClick = function(self)
					ReagentRestockerDB.Options.UnusedNotification = false;
					ReagentRestocker:showFrame();
					--LibStub("AceConfigDialog-3.0"):Open("Reagent Restocker");
				end
				})

		else
			-- sl = how off from ideal we are . . .
			local sl = ReagentRestocker:getOffsetList(nil);
			for itemID, numItems in pairs(ReagentRestockerDB.Items) do
				if (ReagentRestocker:listType(itemID) == SHOPPING_TYPE) then
					if dataobj[itemID]==nil then
						local sName, sLink, iRarity, iLevel, iMinLevel, sType, sSubType, iStackCount, iEquipLoc, iTexture = ReagentRestocker:safeGetItemInfo(itemID);
						if sName==nil then return end;
						if ReagentRestockerDB.Options.UseTextLDB then
							dataobj[itemID] = ldb:NewDataObject("RR_"..sName, {type = "data source", text = sName .. ReagentRestocker:countItemInBags(getPlayerBagIDList(),itemID), icon=iTexture})
						else
							dataobj[itemID] = ldb:NewDataObject("RR_"..sName, {type = "data source", text = ReagentRestocker:countItemInBags(getPlayerBagIDList(),itemID), icon=iTexture})
						end
						if dataobj[itemID]~=nil then
							if ReagentRestockerDB.Options.UseTextLDB then
								dataobj[itemID].label = "";
							else
								dataobj[itemID].label = sName;
							end
							dataobj[itemID].icon=iTexture;
							dataobj[itemID].sName=sName;
							dataobj[itemID].OnTooltipShow = function (self)
								self:AddLine(dataobj[itemID].label);
							end
							
							dataobj[itemID].OnEnter = function (self)
								GameTooltip:SetOwner(self, "ANCHOR_NONE")
								GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
								GameTooltip:ClearLines()
								dataobj[itemID].OnTooltipShow(GameTooltip)
								GameTooltip:Show()
							end
						
							dataobj[itemID].OnLeave = function (self)
								if GameTooltip then
									GameTooltip:Hide()
								end
							end
							
							
							dataobj[itemID].OnClick = function (self)
								ReagentRestockerDB.Options.UnusedNotification = false;
								ReagentRestocker:showFrame();
								--LibStub("AceConfigDialog-3.0"):Open("Reagent Restocker");
							end
						end
						
						if ReagentRestockerDB["Items"][itemID][LOW_WARNING] == nil then
							ReagentRestockerDB["Items"][itemID][LOW_WARNING] = 0;
						end
					
						if sl[itemID] >= (ReagentRestockerDB["Items"][itemID][QUANTITY_TO_STOCK] - ReagentRestockerDB["Items"][itemID][LOW_WARNING]) then
							dataobj[itemID].warned = true;
						else
							dataobj[itemID].warned = false;
						end
					end
					if sl[itemID]==nil then return end;
					
					-- Display warning.
					--if playerEnteredTime + 2 < GetTime() and ReagentRestocker:countItemInBags(getPlayerBagIDList(),itemID) <  ReagentRestockerDB["Items"][itemID][LOW_WARNING] and dataobj[itemID].warned == false and ReagentRestockerDB.Options.ReagentWarning == true then
					--	if type(MikSBT) ~= "nil" then
					--		MikSBT.DisplayMessage(ReagentRestockerDB["Items"][itemID][ITEM_NAME] .. " is low!");
					--		dprint(ReagentRestockerDB["Items"][itemID][ITEM_NAME] .. " is low: " .. ReagentRestockerDB["Items"][itemID][QUANTITY_TO_STOCK].."-"..ReagentRestockerDB["Items"][itemID][LOW_WARNING].."<"..sl[itemID]);
					--	else
					--		UIErrorsFrame:AddMessage(ReagentRestockerDB["Items"][itemID][ITEM_NAME] .. " is low!", nil, nil, nil, nil, 5);
					--		dprint(ReagentRestockerDB["Items"][itemID][ITEM_NAME] .. " is low: " .. ReagentRestockerDB["Items"][itemID][QUANTITY_TO_STOCK].."-"..ReagentRestockerDB["Items"][itemID][LOW_WARNING].."<"..sl[itemID]);
					--	end
					--	dataobj[itemID].warned = true;
					--end

					if sl[itemID] > 0 then
						if sl[itemID] > (ReagentRestockerDB["Items"][itemID][QUANTITY_TO_STOCK] - ReagentRestockerDB["Items"][itemID][LOW_WARNING]) then
							color = "|cFFFF7070"
						else
							color = "|cFFFFFF70"
							dataobj[itemID].warned = false;
						end
					else
						color = "|cFF70FF70"
						dataobj[itemID].warned = false;
					end
					
					if ReagentRestockerDB.Options.UseTextLDB then
						dataobj[itemID].label="";
						dataobj[itemID].text = dataobj[itemID].sName .. ": "..color..ReagentRestocker:countItemInBags(getPlayerBagIDList(),itemID);
					else
						dataobj[itemID].label=dataobj[itemID].sName;
						dataobj[itemID].text = color..ReagentRestocker:countItemInBags(getPlayerBagIDList(),itemID);
					end
--					else
--						if ReagentRestockerDB.Options.UseTextLDB then
--							dataobj[itemID].label="";
--							dataobj[itemID].text = dataobj[itemID].sName .. ": |cFF70FF70"..ReagentRestocker:countItemInBags(getPlayerBagIDList(),itemID);
--						else
--							dataobj[itemID].label=dataobj[itemID].sName;
--							dataobj[itemID].text = "|cFF70FF70"..ReagentRestocker:countItemInBags(getPlayerBagIDList(),itemID);
--						end
--					end
				end
				--end
			end

		end
		checkLow(self, event, ...)
	end
	f:SetScript("OnEvent", addonTable.updateLDB);
	
	
--	f:SetScript("OnUpdate", function(self, elap)
--	end)
else
	-- Need to display warning even when there's no LDB.
	f:SetScript("OnEvent", addonTable.checkLow);
	
end

addonTable.ReagentRestocker=ReagentRestocker
dprint("Core.lua loaded");
setfenv(1, oldEnv);

-- Expose some of RR's functions to a public API.
ReagentRestocker=addonTable.ReagentRestocker

