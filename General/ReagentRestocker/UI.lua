local addonName, addonTable = ...;
local GUI = LibStub("AceGUI-3.0");

local oldEnv = getfenv();
setfenv(1,addonTable);

local frame = GUI:Create("Frame", "Reagent Restocker");
frame:SetTitle("Reagent Restocker")

-- Frame for blizzard's dialog box. Needed because Blizzard will eventually
-- clobber its parents. Duplicate ALL types of frames, in fact!
local bFrame = GUI:Create("BlizOptionsGroup", "Reagent Restocker");
local myGroup = GUI:Create("ScrollFrame", "Reagent Restocker");

-- current Frame, used for creating new frames and such.
local currentFrame = nil;

bFrame:SetName("Reagent Restocker", nil)
bFrame:SetTitle("Reagent Restocker")

--frame:SetTitle("Reagent Restocker");
frame:SetLayout("Fill");
bFrame:SetLayout("Fill");

frame:SetFullWidth(true);
frame:SetFullHeight(true);

myGroup:SetFullWidth(true);
myGroup:SetFullHeight(true);

myGroup:SetLayout("Fill");

frame:SetCallback("OnClose", function() ReagentRestocker:hideFrame(); end);

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

--include("BLIZZARD");

local defaultStatus = "Reagent Restocker is a simple addon for automatically purchasing items, selling unwanted items, and repairing.";


local Menu = {
	{
		text = "Shopping",
		value = "shop",
		func=function() print"FUNC!" end
	},
	{
		text = "Selling",
		value = "sell"
	},
	{
		text="Exceptions",
		value = "exclude"
	},
	{
		text = "Bank",
		value = "bank"
	},
	{
		text = "Repair",
		value = "repair"
	},
	{
		text = "Misc",
		value = "misc"
	},
	{
		text = "About",
		value = "about"
	},
}

shopList = {
}

sellList = {
}

excludeList = {
}

Menu[1].children=shopList;
Menu[2].children=sellList;
Menu[3].children=excludeList;

local selectTree = GUI:Create("TreeGroup");

selectTree:SetFullWidth(true);
--selectTree:SetFullHeight(true);
selectTree:SetLayout("List");
selectTree:SetTree(Menu);

local head = GUI:Create("Heading");

head:SetFullWidth(true);
selectTree:AddChild(head);

--Tooltip code
function displayTooltip(self, text)
	if self == nil then
		self = UIParent;
	end
	GameTooltip_SetDefaultAnchor(GameTooltip, WorldFrame);
	--GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR");
	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT");
	GameTooltip:ClearAllPoints()
	--GameTooltip:SetMinimumWidth(256, 1);
	--GameTooltip:SetPoint("BOTTOM",nil,nil,0,0)
	GameTooltip:SetText(text, nil, nil, nil,  nil, 1)
	GameTooltip:Show()
end

function hideTooltip()
	GameTooltip:Hide()
end

-- Helper functions for one-line additions to the panel.
local function addHeader(text)
	local head = GUI:Create("Heading");
	head:SetText(text);
	head:SetFullWidth(true);
	selectTree:AddChild(head);
end

local function addButton(title, click)
	local button = GUI:Create("Button");
	button:SetText(title);
	button:SetCallback("OnClick", click);
	button:SetFullWidth(true);
	selectTree:AddChild(button);
end

local function addSlider(step, bigStep, min, max, name, desc, get, set)
	local slider = GUI:Create("Slider");
	slider:SetSliderValues(min, max, bigStep);
	slider:SetLabel(name);
	if get ~= nil then
		slider:SetValue(get());
	end
	slider:SetCallback("OnValueChanged", set);
	
	-- Strangely enough, OnMouseUp fires when the enter key is pressed.
	slider:SetCallback("OnMouseUp", function(self, name, value) set(self, name, value); slider:SetValue(value) end);
	slider:SetFullWidth(true);
	selectTree:AddChild(slider);
end

local function addInput(name, desc, usage, set)
	local input = GUI:Create("EditBox");
	input:SetText(usage);
	input:SetLabel(name);
	--input:SetCallback("OnEnter", function() frame:SetStatusText(desc); end);
	--input:SetCallback("OnLeave", function() frame:SetStatusText(defaultStatus); end);
	input:SetCallback("OnEnter", function() displayTooltip(input.frame,desc) end);
	input:SetCallback("OnLeave", function() hideTooltip() end);
	input:SetCallback("OnEnterPressed", set);
	-- TODO: Tooltips
	--input:SetCallback("OnEnter", set);
	selectTree:AddChild(input);
end

local function addDropTarget(name, func)

	local dummyButton =  GUI:Create("DragDropTarget");
	if name == nil then
		error("NIL name!");
	end
	dummyButton:SetText(name);
	dummyButton:SetCallback("OnClick", func);
	dummyButton:SetCallback("OnReceiveDrag", func);
	dummyButton:SetCallback("OnMouseUp", func);
	selectTree:AddChild(dummyButton);
end

local function addCheckBox(name, desc, get, set)
	local box = GUI:Create("CheckBox");
	box:SetLabel(name);
--	box:SetCallback("OnEnter", function() frame:SetStatusText(desc) end);
--	box:SetCallback("OnLeave", function() frame:SetStatusText(defaultStatus) end);
	box:SetCallback("OnEnter", function() displayTooltip(box.frame,desc) end);
	box:SetCallback("OnLeave", function() hideTooltip() end);
	box:SetCallback("OnValueChanged", function(self,name,x) if x~= nil then set(x) else set(false) end end);
	
	if get~=nil then
		box:SetValue(get());
	end
	
	-- Fill width to show all of the text.
	box:SetFullWidth(true);
	selectTree:AddChild(box);
end

local function addLabel(text)
	local label = GUI:Create("InteractiveLabel");
	label:SetText(text);
	label:SetFullWidth(true);
	selectTree:AddChild(label);
end

local function addCopyBox(labelText, text)
	local label = GUI:Create("EditBox");
	label:SetLabel(labelText);
	label:SetText(text);
	label:SetFullWidth(true);
	selectTree:AddChild(label);
end

--------------------------------------------------------------------------------

function loadShopping()
	-- create new frame.
	currentFrame = GUI:Create("BlizOptionsGroup", "Reagent Restocker");
	defaultStatus = "Change how Reagent Restocker shops";
	
	addHeader("Add to Shopping List");
	addInput("Type the item's name and hit enter",
		"Adds a new item to your Shopping List",
		"<reagent name>",
		function (x) ReagentRestocker:addItemToShoppingList(x); end);
		
	addHeader("Drag item into drop target.");
	addDropTarget("Stuff goes here.",
		function (x)
			local infoType, info1, info2 = _G.GetCursorInfo();
			if (infoType == "item") then
				ReagentRestocker:addToListByID(info1,0);
				_G.ClearCursor();
				refreshShoppingList();
				selectTree:RefreshTree();
				bTree:RefreshTree();
			end
		end);
		
	addHeader("Required Faction Discount");
	addCheckBox("None (0%)",
		"Reagent Restocker will only purchase Shopping List items from vendors with a 20% discount",
		function () return (ReagentRestockerDB.Options.RequiredDiscount == 0) end,
		function (x) ReagentRestockerDB.Options.RequiredDiscount = 0 end);
	
	addCheckBox("Friendly (5%)",
		"Reagent Restocker will only purchase Shopping List items from vendors with a 5% (or better) discount",
		function () return (ReagentRestockerDB.Options.RequiredDiscount == 5) end,
		function (x) ReagentRestockerDB.Options.RequiredDiscount = 5 end);
	
	addCheckBox("Honored (10%)",
		"Reagent Restocker will only purchase Shopping List items from vendors with a 10% (or better) discount",
		function () return (ReagentRestockerDB.Options.RequiredDiscount == 10) end,
		function (x) ReagentRestockerDB.Options.RequiredDiscount = 10 end);
	
	addCheckBox("Revered (15%)",
		"Reagent Restocker will only purchase Shopping List items from vendors with a 15% (or better) discount",
		function () return (ReagentRestockerDB.Options.RequiredDiscount == 15) end,
		function (x) ReagentRestockerDB.Options.RequiredDiscount = 15 end);
	
	addCheckBox("Exalted (20%)",
		"Reagent Restocker will only purchase Shopping List items from vendors with a 20% (or better) discount",
		function () return (ReagentRestockerDB.Options.RequiredDiscount == 20) end,
		function (x) ReagentRestockerDB.Options.RequiredDiscount = 20 end);
		
	addHeader("Other shopping options");
	
	addCheckBox("Enable auto-shop",
		"Enables auto-shopping; if you turn this option off, Reagent Restocker will not purchase items automatically",
		function () return ReagentRestockerDB.Options.AutoBuy end,
		function (x) ReagentRestockerDB.Options.AutoBuy = x end);

	addCheckBox("Overstock",
		"Reagent Restocker will only purchase Shopping List items from vendors with a 20% discount",
		function () return not ReagentRestockerDB.Options.NotOverstock; end,
		function (x) ReagentRestockerDB.Options.NotOverstock = not x; end);
end

function showShopping()
	selectTree:ReleaseChildren();
	defaultStatus = "Change how Reagent Restocker shops";
	
	addHeader("Add to Shopping List");
	addInput("Type the item's name and hit enter",
		"Adds a new item to your Shopping List",
		"<reagent name>",
		function (x)
			if type(x)=="table" and type(x.lasttext) ~="nil" then
				-- Called from Ace, have to get text from a table.
				ReagentRestocker:addItemToShoppingList(x.lasttext);
			elseif type(x)=="string" then
				ReagentRestocker:addItemToShoppingList(x);
			else
				derror(x);
			end
		end);
		
	addHeader("Drag item into drop target.");
	addDropTarget("Stuff goes here.",
		function (x)
			local infoType, info1, info2 = _G.GetCursorInfo();
			if (infoType == "item") then
				ReagentRestocker:addToListByID(info1,0);
				_G.ClearCursor();
				refreshShoppingList();
				selectTree:RefreshTree();
				showShoppingItem(info1);
			end
		end);
		
	addHeader("Required Faction Discount");
	addCheckBox("None (0%)",
		"Reagent Restocker will only purchase Shopping List items from vendors with a 20% discount",
		function () return (ReagentRestockerDB.Options.RequiredDiscount == 0) end,
		function (x) ReagentRestockerDB.Options.RequiredDiscount = 0 end);
	
	addCheckBox("Friendly (5%)",
		"Reagent Restocker will only purchase Shopping List items from vendors with a 5% (or better) discount",
		function () return (ReagentRestockerDB.Options.RequiredDiscount == 5) end,
		function (x) ReagentRestockerDB.Options.RequiredDiscount = 5 end);
	
	addCheckBox("Honored (10%)",
		"Reagent Restocker will only purchase Shopping List items from vendors with a 10% (or better) discount",
		function () return (ReagentRestockerDB.Options.RequiredDiscount == 10) end,
		function (x) ReagentRestockerDB.Options.RequiredDiscount = 10 end);
	
	addCheckBox("Revered (15%)",
		"Reagent Restocker will only purchase Shopping List items from vendors with a 15% (or better) discount",
		function () return (ReagentRestockerDB.Options.RequiredDiscount == 15) end,
		function (x) ReagentRestockerDB.Options.RequiredDiscount = 15 end);
	
	addCheckBox("Exalted (20%)",
		"Reagent Restocker will only purchase Shopping List items from vendors with a 20% (or better) discount",
		function () return (ReagentRestockerDB.Options.RequiredDiscount == 20) end,
		function (x) ReagentRestockerDB.Options.RequiredDiscount = 20 end);
		
	addHeader("Other shopping options");
	
	addCheckBox("Enable auto-shop",
		"Enables auto-shopping; if you turn this option off, Reagent Restocker will not purchase items automatically",
		function () return ReagentRestockerDB.Options.AutoBuy end,
		function (x) ReagentRestockerDB.Options.AutoBuy = x end);

	addCheckBox("Overstock",
		"Reagent Restocker will only purchase Shopping List items from vendors with a 20% discount",
		function () return not ReagentRestockerDB.Options.NotOverstock; end,
		function (x) ReagentRestockerDB.Options.NotOverstock = not x; end);
		
	-----------------
	selectTree:RefreshTree();
end

function showSelling()
	selectTree:ReleaseChildren();
	defaultStatus = "Options for automatically selling items";
	
	addHeader("Add to Selling List");
	
	addInput("Type the item's name and hit enter",
		"Adds an item to your Selling List",
		"<reagent name>",
		function (x) ReagentRestocker:addItemToSellingList(x); end);

	addHeader("Drag item into drop target.");
	addDropTarget("Stuff goes here.",
		function (x)
			local infoType, info1, info2 = _G.GetCursorInfo();
			if (infoType == "item") then
				ReagentRestocker:addToListByID(info1,-1);
				_G.ClearCursor();
				refreshShoppingList();
				selectTree:RefreshTree();
				showSellingItem(info1);
			end
		end);
		addHeader("Other selling options");
		
	addCheckBox("Auto-populate Selling List",
		"With this option enabled, Reagent Restocker will watch what items you sell to the vendor and automatically add them to the Selling List",
		function() return ReagentRestockerDB.Options.AutoPopulate end,
		function(x) ReagentRestockerDB.Options.AutoPopulate = x end);

	addCheckBox("Sell gray items",
		"Do you want Reagent Restocker to automatically sell gray (usless) items from your inventory?  (This is like adding all gray items to your Selling List)",
		function() return ReagentRestockerDB.Options.AutoSellGrays end,
		function(x) ReagentRestockerDB.Options.AutoSellGrays = x end);

	addCheckBox("Destroy unsellable gray items",
		"Destroys gray items that can't be sold.\nWARNING: Destroyed items cannot be recovered!",
		function() return ReagentRestockerDB.Options.AutoDestroyGrays end,
		function(x) ReagentRestockerDB.Options.AutoDestroyGrays = x end);

	addCheckBox("Enable auto-sell",
		"Enable auto-selling; if you turn this option off, Reagent Restocker will not sell items automatically",
		function () return ReagentRestockerDB.Options.AutoSell end,
		function (x) ReagentRestockerDB.Options.AutoSell = x end);
end

function showExclusion()
	selectTree:ReleaseChildren();
	defaultStatus = "Exclude items you don't want to sell/buy";
	addHeader("Add to Exceptions List");
		addDropTarget("Stuff goes here.",
		function (x)
			local infoType, info1, info2 = _G.GetCursorInfo();
			if (infoType == "item") then
				ReagentRestocker:addItemToList(info1,"Exception");
			--	ReagentRestocker:addToListByID(info1,-1);
				ClearCursor();
				_G.refreshShoppingList();
				selectTree:RefreshTree();
				--showListItem(excludeList[info1].itemID, "Exception");
			end
		end);
end

function showBank()
	selectTree:ReleaseChildren();
	defaultStatus = "Options for interacting with your bank";

	addCheckBox("Stock items from bank",
		"Pulls items on your Shopping List from your bank if you need them",
		function () return ReagentRestockerDB.Options.PullFromBank end,
		function (x) ReagentRestockerDB.Options.PullFromBank = x end);

	addCheckBox("Overstock to bank",
		"Puts 'extra' Shopping List items (i.e., more than the quantity you keep stocked) into your bank",
		function() return ReagentRestockerDB.Options.OverstockToBank end,
		function(x) ReagentRestockerDB.Options.OverstockToBank = x end);
end

function showRepair()
	selectTree:ReleaseChildren();
	defaultStatus = "Options for repairing";
	
	addCheckBox("Auto-repair",
		"Automatically repair your gear when you visit a repair-able vendor",
		function () return ReagentRestockerDB.Options.AutoRepair end,
		function (x) ReagentRestockerDB.Options.AutoRepair = x end);
		
	addCheckBox("Use guild bank funds",
		"Use guild bank funds when auto-repairing, if possible",
		function() return ReagentRestockerDB.Options.UseGuildBankFunds end,
		function(x) ReagentRestockerDB.Options.UseGuildBankFunds = x end);
		
	addCheckBox("Require discount (see Shopping options)",
		"Only repair if the repair vendor meets the required vendor discounts (as chosen in the Shopping options)",
		function() return ReagentRestockerDB.Options.RepairDiscount end,
		function(x) ReagentRestockerDB.Options.RepairDiscount = x end);
end

function showMisc()
	selectTree:ReleaseChildren();
	defaultStatus = "Other Reagent Restocker options";
	
	addCheckBox("Quiet mode",
		"Disable Reagent Restocker messages",
		function() return ReagentRestockerDB.Options.QuietMode end,
		function(x) ReagentRestockerDB.Options.QuietMode = x end);

	addCheckBox("Single LDB item (Requires UI reload)",
		"Reduces LDB to one button, instead of one button per item. Requires UI reload.",
		function() return ReagentRestockerDB.Options.SingleLDB end,
		function(x) ReagentRestockerDB.Options.SingleLDB = x; end);

	addCheckBox("LDB: Use text instead of label",
		"Uses LDB's text for everything instead of a separate label. Useful for some brokers like NinjaPanel.",
		function() return ReagentRestockerDB.Options.UseTextLDB end,
		function(x) ReagentRestockerDB.Options.UseTextLDB = x; addonTable:updateLDB(); end);

	addCheckBox("Low reagent warning",
		"Show a warning when you don't have enough of an item.",
		function() return ReagentRestockerDB.Options.ReagentWarning end,
		function(x) ReagentRestockerDB.Options.ReagentWarning = x end);
	addCheckBox("Debug",
		"Turns on debug info.",
		function() return ReagentRestockerDB.Options.Debug end,
		function(x) ReagentRestockerDB.Options.Debug = x; debugRR=x end);
	addButton("Toggle new UI", function() merchantFrame:ToggleHide() end)
end

function showAbout()
	selectTree:ReleaseChildren();
	addLabel("Reagent Restocker version " .. GetAddOnMetadata(addonName, "Version") .. "\n");
	addLabel("Author: " .. GetAddOnMetadata(addonName, "Author") .. "\n");
	addLabel("Thanks to " .. GetAddOnMetadata(addonName, "X-Credits") .. " for the creation of and contributions to this addon.\n");
	addLabel("License: " .. GetAddOnMetadata(addonName, "X-License") .. "\n");
	addCopyBox("Website: ",GetAddOnMetadata(addonName, "X-Website") .. "\n");
	addCopyBox("Bug reports and feature requests: ",GetAddOnMetadata(addonName, "X-Bugs") .. "\n");

	local version, build, date, tocversion = GetBuildInfo();
	addLabel("\nDesigned for UI version " .. GetAddOnMetadata(addonName, "X-Interface") .. ", current UI vesrion is " .. tostring(tocversion) .. ".\n");
	

end
--------------------------------------------------------------------------------
function refreshShoppingList()
	for k, v in pairs(shopList) do
		shopList[k]=nil
	end
	for k, v in pairs(sellList) do
		sellList[k]=nil
	end
	for k, v in pairs(excludeList) do
		excludeList[k]=nil
	end
	
	if ReagentRestockerDB==nil then
		error("Database not found!");
	end
	
	local shopNum=1;
	local sellNum=1;
	local excludeNum=1;
	for k, v in pairs(ReagentRestockerDB.Items) do
		local info = ReagentRestocker:safeGetItemInfo(k);
		--jprint(v["0"]);
		--jprint("shopList["..num.."].text="..v[ITEM_NAME]);
		if(hasTag(k,"Exception")) then
			excludeList[excludeNum]={};
			excludeList[excludeNum].value=excludeNum;
			excludeList[excludeNum].text=v["0"];
			excludeList[excludeNum].icon=v["9"];
			excludeList[excludeNum].itemID=k;
			excludeNum=excludeNum+1;
		elseif v["qty"] > -1 then
			shopList[shopNum]={};
			shopList[shopNum].value=shopNum;
			shopList[shopNum].text=v["0"];
			shopList[shopNum].icon=v["9"];
			shopList[shopNum].itemID=k;
			shopNum=shopNum+1;
		else
			sellList[sellNum]={};
			sellList[sellNum].value=sellNum;
			sellList[sellNum].text=v["0"];
			sellList[sellNum].icon=v["9"];
			sellList[sellNum].itemID=k;
			sellNum=sellNum+1;
		end

	end
	table.sort(shopList, function(x, y) return x.text < y.text end);
	num=1;
	for k, v in pairs(shopList) do
		shopList[num].value=num;
		num = num + 1;
	end
	
	table.sort(sellList, function(x, y) return x.text < y.text end);
	num=1;
	for k, v in pairs(sellList) do
		sellList[num].value=num;
		num = num + 1;
	end

	table.sort(excludeList, function(x, y) return x.text < y.text end);
	num=1;
	for k, v in pairs(excludeList) do
		excludeList[num].value=num;
		num = num + 1;
	end

	--Menu[1].
end

-- Show menu for individual item in shopping list.
function showShoppingItem(item)
	selectTree:ReleaseChildren();
	defaultStatus = "Adjust shopping options for this item.";
	local itemName, _, _, _, _, _, _, itemStackCount, _, itemTexture = ReagentRestocker:safeGetItemInfo(item);
	
	addHeader(ReagentRestockerDB.Items[item]["0"]);
	
	addSlider(
		ceil(itemStackCount/20),
		itemStackCount,
		0,
		maxFromSC(itemStackCount),
		"Stock how many?",
		"nothing",
		function()
			return ReagentRestockerDB.Items[item][QUANTITY_TO_STOCK];
		end,
		function(self, name, x) if type(x)~="number" then error("x must be a number!") end; ReagentRestockerDB.Items[item][QUANTITY_TO_STOCK] = x; ReagentRestocker:synchronizeOptionsTable(); end
	);
	
	addSlider(
		ceil(itemStackCount/20),
		floor(itemStackCount/4),
		0,
		maxFromSC(itemStackCount),
		"Low item warning",
		"nothing",
		function()
			if type(ReagentRestockerDB.Items[item][LOW_WARNING]) == "nil" then
				ReagentRestockerDB.Items[item][LOW_WARNING] = ReagentRestockerDB.Items[item][QUANTITY_TO_STOCK]
			end
			
			if ReagentRestockerDB.Items[item][LOW_WARNING] > ReagentRestockerDB.Items[item][QUANTITY_TO_STOCK] then
				ReagentRestockerDB.Items[item][LOW_WARNING] = ReagentRestockerDB.Items[item][QUANTITY_TO_STOCK]
			end
			return ReagentRestockerDB.Items[item][LOW_WARNING];
		end,
		function(self, name, x)
			if type(x)~="number" then error("x must be a number!") end;
			ReagentRestockerDB.Items[item][LOW_WARNING] = x;
			if ReagentRestockerDB.Items[item][LOW_WARNING] > ReagentRestockerDB.Items[item][QUANTITY_TO_STOCK] then
				ReagentRestockerDB.Items[item][LOW_WARNING] = ReagentRestockerDB.Items[item][QUANTITY_TO_STOCK]
			end
			ReagentRestocker:synchronizeOptionsTable();
		end
	);
	
	addButton("Remove item from Shopping list", function()
		ReagentRestocker:removeItemFromList(item);
		dataobj=nil;
		refreshShoppingList();
		selectTree:RefreshTree();
		-- Clear UI
		selectTree:ReleaseChildren();
	end);
end

function showSellingItem(item)
	selectTree:ReleaseChildren();
	defaultStatus = "Adjust selling options for this item.";

	addHeader(ReagentRestockerDB.Items[item]["0"]);
	addButton("Remove item from Selling list", function()
		ReagentRestocker:removeItemFromList(item);
		dataobj=nil;
		refreshShoppingList();
		selectTree:RefreshTree();
		-- Clear UI
		selectTree:ReleaseChildren();
	end);
end

-- TODO: This currently just deletes it from all lists.
function showListItem(item, list)
	selectTree:ReleaseChildren();
	defaultStatus = string.format("Adjust %s options for this item.", list);
	
	addHeader(ReagentRestockerDB.Items[item]["0"]);
	addButton(string.format("Remove item from %s list", list), function()
		ReagentRestocker:removeItemFromList(item, list);
		dataobj=nil;
		refreshShoppingList();
		selectTree:RefreshTree();
		-- Clear UI
		selectTree:ReleaseChildren();
	end);
	
--	if list == "Exception" then
--		addCheckBox("Never sell this item.",
--			"Prevents selling this item",
--			function() return ReagentRestockerDB.Items[item].neverSell end,
--			function(x) ReagentRestockerDB.Items[item].neverSell = x end);
--	end
end


selectTree:SetCallback("OnGroupSelected",
	function(_widget, nothing, group)
		if group == "shop" then
			showShopping();
		elseif group=="sell" then
			showSelling();
		elseif group == "exclude" then
			showExclusion();
		elseif group=="bank" then
			showBank();
		elseif group=="repair" then
			showRepair();
		elseif group=="misc" then
			showMisc();
		elseif group=="about" then
			showAbout();
		elseif string.find(group, "^shop\001") then
			-- dynamically created list, get item number.
			number = tonumber(string.sub(group,6));
			-- Display menu
			showShoppingItem(shopList[number].itemID);
			
		elseif string.find(group, "^sell\001") then
			-- dynamically created list, get item number.
			number = tonumber(string.sub(group,6));
			showSellingItem(sellList[number].itemID);
		elseif string.find(group, "^exclude\001") then
			-- dynamically created list, get item number.
			number = tonumber(string.sub(group,9));
			showListItem(excludeList[number].itemID, "Exception");
		else
				addInput("Type the item's name and hit enter",
			"Adds an item to your Selling List",
			group,
			function (x) ReagentRestocker:addItemToSellingList(x); end);
		end
		
		--print(group);
		--rprint(3,Menu);
		--shopshop1
		
		-- Refresh shopping/selling lists
		refreshShoppingList();
		selectTree:RefreshTree();
		
		-- add some filler to the height so it's not ridiculously small.
		filler = GUI:Create("SimpleGroup");
		filler:SetLayout("Fill");
		filler:SetFullWidth(true);
		filler:SetFullHeight(true);
		selectTree:AddChild(filler);

	end
)

selectTree:RefreshTree();


myGroup:AddChild(selectTree);

bFrame:AddChild(myGroup);
frame:AddChild(myGroup);

bFrame.frame.refresh = function()
	dprint("Showing frame");
	ReagentRestocker:synchronizeOptionsTable();
	refreshShoppingList();
	selectTree:RefreshTree();
	showShopping();
	myGroup:AddChild(selectTree);
	bFrame:AddChild(myGroup);
end

InterfaceOptions_AddCategory(bFrame.frame);
dprint("WoW addon should be added.");

function ReagentRestocker:hideFrame()
	frame:Hide();
end

function ReagentRestocker:showFrame()
	if firstTime == true then
		showShopping();
		firstTime = false;
	end

	dprint("Showing frame");
	ReagentRestocker:synchronizeOptionsTable();
	refreshShoppingList();
	selectTree:RefreshTree();
	frame:AddChild(myGroup);
	myGroup:AddChild(selectTree);
	frame:Show();
end

menuu= createNewMenu(frame);

firstTime = true;
frame:Hide();

dprint("UI.lua loaded");
dprint(type(RRTooltip))
addonTable.RRTooltip=RRTooltip;
setfenv(1, oldEnv);
ReagentRestockerDB=addonTable.ReagentRestockerDB


