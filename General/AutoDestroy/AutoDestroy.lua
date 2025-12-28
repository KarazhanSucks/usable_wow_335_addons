--[[
					Auto Destroy
			written by Torrid of Black Dragonflight
]]

AUTODESTROY_COLORS = {
	[-1] = "|c00ffffff",
	[0] = "|c00888888",
	[1] = "|c00ffffff",
	[2] = "|c0000ff00",
	[3] = "|c000000ff",
	[4] = "|c00ff00ff",
};

AutoDestroyEnable = false;

AutoDestroyCFG = {
	zone = "",
	minlevel = 1,
	weapons = 1,		-- 0 = gray, 1 = white, 2 = green, 3 = blue, 4 = purple
	armor = 1,
	list = "",
};

AutoDestroyLoot = {};

AutoDestroyHistory = {};

function AutoDestroyFrame_OnLoad(self)
	SlashCmdList["AD"] = AutoDestroyCmdLine;
	SLASH_AD1 = "/AD"; 

	self:RegisterEvent("LOOT_CLOSED");
	self:RegisterEvent("CHAT_MSG_LOOT");
	self:RegisterEvent("VARIABLES_LOADED");

	if (DEFAULT_CHAT_FRAME) then
		DEFAULT_CHAT_FRAME:AddMessage(AUTODESTROY_LOGIN);
	end
end

function AutoDestroyCmdLine(arg)
	AutoDestroyOptionsFrame:Show();
end

function AutoDestroyEvaluate(bag, slot, quality)

	if (quality > 3) then
		return
	end

	local size, itemqty, itemname, match, type, typeline, i, level, haystack;

	AutoDestroyTooltipTextLeft2:SetText(nil);
	AutoDestroyTooltipTextLeft3:SetText(nil);
	AutoDestroyTooltipTextRight2:SetText(nil);
	AutoDestroyTooltipTextRight3:SetText(nil);

	AutoDestroyTooltip:SetBagItem(bag, slot);
	itemname = AutoDestroyTooltipTextLeft1:GetText();

	local s, q;

	for _, s in pairs(AutoDestroyLoot) do
		if (s == itemname) then


--			This code checks item level
--			but lots of junk has low levels, so this is impractical

--			i = 1;
--			haystack = AutoDestroyTooltipTextLeft1:GetText();
--			while (haystack) do
--				haystack = getglobal("AutoDestroyTooltipTextLeft"..i):GetText();
--				if (haystack) then
--					_, _, level = string.find(haystack, "^Requires Level (%d+)$");
--					if (level) then
--						break;
--					end
--				end
--				i = i + 1;
--			end
--			if (level and tonumber(level) < AutoDestroyCFG.minlevel) then
--				return
--			end


			-- paranoia
			_, _, _, q = GetContainerItemInfo(bag, slot);
			if (q > 3) then
				return
			end

			-- get the text color values, and turn the long ass floats into two digit
			-- ints to compare
			local r, g, b = AutoDestroyTooltipTextLeft1:GetTextColor();
			r = math.floor(r * 100);
			g = math.floor(g * 100);
			b = math.floor(b * 100);

			-- if quality is epic or greater, don't add
			-- some items have -1 for quality, but have colored names (i.e. mounts)
			-- so disallow items with purple text
			if (q > 3 or (r == 63 and g == 20 and b == 93)) then
				DEFAULT_CHAT_FRAME:AddMessage(AUTODESTROY_REFUSING..itemname, 1, 0, 0);
				return
			end

			DEFAULT_CHAT_FRAME:AddMessage(AUTODESTROY_DESTROYING..AUTODESTROY_COLORS[quality].."["..itemname.."]|r", 1, .25, .25);

			PickupContainerItem(bag, slot);
			if ( CursorHasItem() ) then
				DeleteCursorItem();
			end
			return
		end
	end

	-- return if item not looted in this zone
	if (not AutoDestroyHistory[itemname]) then
		return
	end

	if (quality == 0) then
		-- gray
		typeline = 2;
	elseif (quality == 1) then
		-- white
		typeline = 2;
	elseif (quality == 2) then
		-- green
		typeline = 3;
	elseif (quality == 3) then
		-- blue
		typeline = 3;
--	elseif (quality == 4) then
		-- purple
--		typeline = 3;
	else
		return
	end

	if (typeline) then
		type = getglobal("AutoDestroyTooltipTextRight"..typeline):GetText();
		if (not type or type == nil) then
			type = getglobal("AutoDestroyTooltipTextLeft"..typeline):GetText();
		end
		if ( AUTODESTROY_WEAPONS[type] ) then
			-- item is weapon

			-- set to destroy none
			if (AutoDestroyCFG.weapons == -1) then
				return
			end

			-- destroy if item below threshold
			if (quality <= AutoDestroyCFG.weapons) then

				i = 1;
				haystack = AutoDestroyTooltipTextLeft1:GetText();
				while (haystack) do
					haystack = getglobal("AutoDestroyTooltipTextLeft"..i):GetText();
					if (haystack) then
						_, _, level = string.find(haystack, "^"..AUTODESTROY_REQUIRESLEVEL.." (%d+)$");
						if (level and tonumber(level) < AutoDestroyCFG.minlevel) then

							DEFAULT_CHAT_FRAME:AddMessage(AUTODESTROY_DESTROYING..AUTODESTROY_COLORS[quality].."["..itemname.."]|r", 1, .25, .25);

							PickupContainerItem(bag, slot);
							if ( CursorHasItem() ) then
								DeleteCursorItem();
							end

							return
						end
					end
					i = i + 1;
				end

			end
		elseif ( AUTODESTROY_ARMOR[type] ) then
			-- item is armor

			-- set to destroy none
			if (AutoDestroyCFG.armor == -1) then
				return
			end

			-- destroy if item below threshold
			if (quality <= AutoDestroyCFG.armor) then
				i = 1;
				haystack = AutoDestroyTooltipTextLeft1:GetText();
				while (haystack) do
					haystack = getglobal("AutoDestroyTooltipTextLeft"..i):GetText();
					if (haystack) then
						_, _, level = string.find(haystack, "^"..AUTODESTROY_REQUIRESLEVEL.." (%d+)$");
						if (level and tonumber(level) < AutoDestroyCFG.minlevel) then

							DEFAULT_CHAT_FRAME:AddMessage(AUTODESTROY_DESTROYING..AUTODESTROY_COLORS[quality].."["..itemname.."]|r", 1, .25, .25);

							PickupContainerItem(bag, slot);
							if ( CursorHasItem() ) then
								DeleteCursorItem();
							end

							return

						end
					end
					i = i + 1;
				end
			end
		end
	end

end

function AutoDestroyFrame_OnEvent(event, arg1)
	if (AutoDestroyEnable and AutoDestroyCFG.zone == GetZoneText()) then
		if (event == "LOOT_CLOSED") then

			local bag, size, slot, quality;

			for bag = 0, 4 do
				size = GetContainerNumSlots(bag);
				for slot = 1, size do
					_, _, _, quality = GetContainerItemInfo(bag, slot);
					if (quality) then
						AutoDestroyEvaluate(bag, slot, quality);
					end
				end
			end

		elseif (event == "CHAT_MSG_LOOT") then
			local _, _, item = string.find(arg1, "^"..AUTODESTROY_RECEIVELOOT.." .+%[(.+)%]%|h%|r%.$");
			if (item) then
				AutoDestroyHistory[item] = true;
			end
		elseif (event == "VARIABLES_LOADED") then
			AutoDestroyGetList();
		end
	end
end

-- get item list from CFG string and convert to array for use
function AutoDestroyGetList()
	local item;
	AutoDestroyLoot = {};
	for item in string.gmatch(AutoDestroyCFG.list, "[^\n]+") do
		if (item and item ~= "") then
			table.insert(AutoDestroyLoot, item);
		end
	end
end

function AutoDestroy_newPickupContainerItem(self, button)
	if ( button == "LeftButton" and IsAltKeyDown() and AutoDestroyOptionsFrame:IsVisible() and not CursorHasItem() ) then
		local _, _, _, quality = GetContainerItemInfo(self:GetParent():GetID(), self:GetID());

		-- get the text color values, and turn the long ass floats into two digit
		-- ints to compare
		local r, g, b = GameTooltipTextLeft1:GetTextColor();
		r = math.floor(r * 100);
		g = math.floor(g * 100);
		b = math.floor(b * 100);

		-- if quality is epic or greater, don't add
		-- some items have -1 for quality, but have colored names (i.e. mounts)
		-- so disallow items with purple text
		if (quality > 3 or (r == 63 and g == 20 and b == 93)) then
			DEFAULT_CHAT_FRAME:AddMessage(AUTODESTROY_REFUSETOADD, 1, 0, 0);
			return
		end
		
		local itemName = GameTooltipTextLeft1:GetText();
		local editBoxText = AutoDestroyListEditFrameEditBox:GetText();

		-- is item not in list?
		if (not string.find(editBoxText, itemName, 1, true)) then
			-- is the last character not \n?
--			if (string.sub(editBoxText, -1, -1) ~= "\n") then
--			if (not string.find(editBoxText, ".*\n$")) then
--				AutoDestroyListEditFrameEditBox:SetText(editBoxText.."\n");
--			end
			DEFAULT_CHAT_FRAME:AddMessage(itemName..AUTODESTROY_ADDEDTOLIST, 1, 0, 0);
			AutoDestroyListEditFrameEditBox:SetText(editBoxText..itemName.."\n");
		end
	else
		--AutoDestroy_oldPickupContainerItem(bag, item, special);
	end
end
