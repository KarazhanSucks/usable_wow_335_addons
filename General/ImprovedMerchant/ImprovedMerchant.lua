-- constants
local ImprovedMerchant_NOTHING    = 0
local ImprovedMerchant_AFFORDABLE = 1
local ImprovedMerchant_TRAINABLE  = 2
local ImprovedMerchant_USABLE     = 4

-- default setting : filter options are hidden
local ImprovedMerchant_filterToggled = true

-- item types and sub types, those will be reused
-- a type/subtype marked as true is available at this current merchant
-- a type/subtype marked as false is not available at this current merchant 
local ImprovedMerchant_typeList = {}
	
-- hide every child (item buttons) from the ScrollChild
function ImprovedMerchant_DepopulateMerchantList()
	for _, child in pairs({ImprovedMerchantScrollChild:GetChildren()}) do
		child:Hide()
	end
	for val in pairs(ImprovedMerchant_typeList) do
		ImprovedMerchant_typeList[val] = false
	end

end

function ImprovedMerchant_SearchTooltip(searchText, i)
	local result = false
	GameTooltip:ClearLines()
	if searchText then
		GameTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
		GameTooltip:SetMerchantItem(i)
		GameTooltip:Show()
		for line=1,GameTooltip:NumLines() do
			local mytext = _G["GameTooltipTextLeft" .. line]
			local text = mytext:GetText()
			if text and string.find(text, LRATINGBUSTER) then
				break
			end
			if text and string.find(string.lower(text), string.lower(searchText)) then
				result= true
			end
			local mytext = _G["GameTooltipTextRight" .. line]
			local text = mytext:GetText()
			if text and string.find(string.lower(text), string.lower(searchText)) then
				result = true
			end
		end
	end
	GameTooltip:Hide()
	return result
end

-- scan through all merchant items and filter those by set options and or by search text
function ImprovedMerchant_PopulateList(searchText, filterOption)
	local iter = 0 -- this value represent the current merchantitem id
	local num = 10 -- items per page
	local items = GetMerchantNumItems() -- total items
	local iterator = 1 -- a id name for my custom buttons
	
	-- reset the merchantframe to page 1
	for pages = 1, GetMerchantNumItems(), 10 do 
		MerchantPrevPageButton:Click()
	end
	-- for every page
	for i = 1, items, num do
		-- and very item in this page
		for itemNum = 1, num do 
			-- increase the Merchant Item Id value
			iter = iter + 1
			-- basic information about an item
			local itemName = GetMerchantItemInfo(iter)
			local price = select(3, GetMerchantItemInfo(iter))
			local isUsable, extendedCost = select(6, GetMerchantItemInfo(iter))
		
			if itemName then
				-- additional information
				local itemType, itemSubType = select(6, GetItemInfo(GetMerchantItemLink(iter)))
				local honorPoints, arenaPoints = GetMerchantItemCostInfo(iter)
				local currency1Amount, currency1 = select(2, GetMerchantItemCostItem(iter, 1))
				local currency2Amount, currency2 = select(2, GetMerchantItemCostItem(iter, 2))
				local currency3Amount, currency3 = select(2, GetMerchantItemCostItem(iter, 3))
				-- add information for the DropdownList
				ImprovedMerchant_typeList[itemType] = true
				ImprovedMerchant_typeList[itemSubType] = true
				
				-- if this is true the item information will be added
				local IsNotFiltered = true
									
					if searchText and searchText ~= "" then
						-- split up the searchstring and scan for every splitted up keyword
						for _, keyword in pairs({strsplit(";", searchText)}) do
							IsNotFiltered = ImprovedMerchant_SearchTooltip(keyword, iter)
							
						end

					end
					
					-- if it does not yet filtered out go along and check if the option is set to filter "LAFFORDABLE"
					if IsNotFiltered == true and filterOption == ImprovedMerchant_AFFORDABLE then
						-- if the player money/honor tokens and arena tokens are equal or above the required value
						IsNotFiltered = (GetMoney() >= price and 
						              GetHonorCurrency() >= honorPoints and
									  GetArenaCurrency() >= arenaPoints)
						-- if the player has the needed items
						if currency1 then
							IsNotFiltered = GetItemCount(currency1) >= currency1Amount
						end
						-- if the player has the needed items
						if currency2 then
							IsNotFiltered = GetItemCount(currency2) >= currency2Amount
						end
						-- if the player has the needed items
						if currency3 then
							IsNotFiltered = GetItemCount(currency3) >= currency3Amount
						end
						
					-- if the item is not LUSABLE
					elseif IsNotFiltered == true and filterOption == ImprovedMerchant_USABLE then
						IsNotFiltered = (isUsable and true or false)

					-- if the item (it must have the itemType "LRECIPE") isUsable and it does not contain
					-- ITEM_SPELL_KNOWN (from GlobalStrings.lua) in its tooltip
					elseif IsNotFiltered == true and filterOption and filterOption == ImprovedMerchant_TRAINABLE then
						IsNotFiltered = (isUsable and true or false) and 
										itemType == LRECIPE and 
										not(ImprovedMerchant_SearchTooltip(ITEM_SPELL_KNOWN,iter))

					-- show only items of the selected itemType
					elseif IsNotFiltered == true and filterOption and filterOption == ImprovedMerchant_NOTHING then
							IsNotFiltered = true
					elseif IsNotFiltered == true and filterOption then
					
						IsNotFiltered = filterOption == itemType or filterOption == itemSubType
					
					end
				
				-- So if it is not filtered out add it now
				if IsNotFiltered == true then
										
					-- LRECIPE book coloring should also be stored
					local r,g,b,a = _G["MerchantItem"..itemNum.."ItemButtonIconTexture"]:GetVertexColor()
					
					-- add to the typeList-List every occured itemType and itemSubType
							
					
					local button = _G["itemInfo"..iterator] or CreateFrame("Button", "itemInfo"..iterator, ImprovedMerchantScrollChild, "ImprovedMerchantItemInfoTemplate")
					button:SetFrameLevel(ImprovedMerchantScrollChild:GetFrameLevel() + 1)
					
					ImprovedMerchant_Update(button, iter, r,g,b,a)
					-- the first button will be aligned topleft
					if iterator == 1 then
						button:SetPoint("TOPLEFT", ImprovedMerchantScrollChild, "TOPLEFT", 4, 0)
					else
					-- anyone else will be aligned below the previous button
						button:SetPoint("TOPLEFT", _G["itemInfo"..iterator-1], "BOTTOMLEFT", 0, 0)
					end
					button:SetPoint("RIGHT", ImprovedMerchantScrollChild)
					iterator = iterator + 1
				end
				
			end
		end
		MerchantNextPageButton:Click()
	end
	
		-- adjust the Scrollchild Height to fit every button
	if iterator > 1 then
		ImprovedMerchantScrollChild:SetHeight((32) * (iterator-1))
	else
		ImprovedMerchantScrollChild:SetHeight(32)
	end
	-- populate filter dropdown list
	UIDropDownMenu_Initialize(ImprovedMerchantSortList, function()
			ImprovedMerchant_PopulateFilter(ImprovedMerchant_typeList)
		end)
	
end 

-- OnEvent Handler 
function ImprovedMerchant_OnEvent(self, event)

	if event == "MERCHANT_UPDATE" then
		if MerchantFrame.selectedTab == 2 then
		end
		if MerchantFrame.selectedTab == 1 then
			for pages = 1, GetMerchantNumItems(), 10 do
				MerchantPrevPageButton:Click()
			end
			
			ImprovedMerchant_DepopulateMerchantList()
			
			ImprovedMerchant_PopulateList(ImprovedMerchantSearchBox:GetText(), UIDropDownMenu_GetSelectedValue(ImprovedMerchantSortList))
	
		end
	end
	
	if event == "MERCHANT_SHOW" then
		if CanMerchantRepair() then
			ImprovedMerchantAutoRepairCheckBox:Enable()
			ImprovedMerchantAutoRepairCheckBoxText:SetFontObject("GameFontNormalSmall")
		else
			ImprovedMerchantAutoRepairCheckBox:Disable()
			ImprovedMerchantAutoRepairCheckBoxText:SetFontObject("GameFontDisableSmall")
		end
		ImprovedMerchantAutoRepairCheckBox:SetChecked(AUTOREPAIR)
		
		if AUTOREPAIR then
				RepairAllItems()
		end
			
		for i = 1, 12 do
			_G["MerchantItem"..i]:Hide()
		end
		-- put the scrollarena to the topmost
		ImprovedMerchant:SetVerticalScroll(0)
		-- remove all elements
		ImprovedMerchant_DepopulateMerchantList()
		-- add all elements (based upon filter)
		ImprovedMerchant_PopulateList()
		-- apply no filter
		UIDropDownMenu_SetSelectedValue(ImprovedMerchantSortList, ImprovedMerchant_NOTHING)
		ImprovedMerchantSortListText:SetText(LNOTHING)
		
		-- hide the orignal buttons and remove thier functions
		MerchantPrevPageButton:Hide()
		MerchantNextPageButton:Hide()
		MerchantPageText:Hide()
		MerchantPrevPageButton.Show = function() end
		MerchantNextPageButton.Show = function() end
		MerchantPageText.Show = function() end
		
		-- expand the filter (and search) box
		if not ImprovedMerchant_filterToggled then
			ImprovedMerchantFilter:Show()
		end
		ImprovedMerchantToggleFilter:Show()
	end
end

-- repopulate merchant items according the selected filter and searchtext
local function ImprovedMerchant_Tab1Hook()
	ImprovedMerchant_DepopulateMerchantList()

	ImprovedMerchant_PopulateList(ImprovedMerchantSearchBox:GetText(), UIDropDownMenu_GetSelectedValue(ImprovedMerchantSortList))
		
	if ImprovedMerchantSearchBox:GetText() == "" then
		ImprovedMerchantSearchBoxInfo:Show()
	else
		ImprovedMerchantSearchBoxInfo:Hide()
	end
	
	if not ImprovedMerchant_filterToggled then
		ImprovedMerchantFilter:Show()
	end
	
	ImprovedMerchantToggleFilter:Show()
	
	ImprovedMerchant:Show()
	for i = 1, 12 do
		_G["MerchantItem"..i]:Hide()
	end
end
-- hide the Scrollable Frame and show the original MerchantItems
local function ImprovedMerchant_Tab2Hook()
	ImprovedMerchant_DepopulateMerchantList()
	ImprovedMerchantFilter:Hide()
	ImprovedMerchantToggleFilter:Hide()
	
	ImprovedMerchant:Hide()
	for i = 1, 12 do
		_G["MerchantItem"..i]:Show()
	end
end

-- hook the 2 functions above
MerchantFrameTab1:HookScript("OnClick", ImprovedMerchant_Tab1Hook)
MerchantFrameTab2:HookScript("OnClick", ImprovedMerchant_Tab2Hook)

-- Handler to toggle hide/show state of filter/search pane
function ImprovedMerchant_ToggleFilter(self, button)
	if ImprovedMerchantFilter:IsShown() then
		ImprovedMerchantFilter:Hide()
		self:SetNormalTexture("Interface\\MoneyFrame\\Arrow-Right-Up")
		self:SetPushedTexture("Interface\\MoneyFrame\\Arrow-Right-Down")
		filterToggled = true
	else
		ImprovedMerchantFilter:Show()
		self:SetNormalTexture("Interface\\MoneyFrame\\Arrow-Left-Up")
		self:SetPushedTexture("Interface\\MoneyFrame\\Arrow-Left-Down")
		filterToggled = nil
	end
end

-- Handler (self explaination)
function ImprovedMerchantSearchBox_OnEditFocusGained()
	ImprovedMerchantSearchBoxInfo:Hide()
end

-- Handler to search in the items with considering the selected value of the dropdown object
function ImprovedMerchantSearchBox_OnEnterPressed(self)
	ImprovedMerchant_DepopulateMerchantList()
	ImprovedMerchant_PopulateList(self:GetText(), UIDropDownMenu_GetSelectedValue(ImprovedMerchantSortList))
	self:ClearFocus()
	
	if self:GetText() == "" then
		ImprovedMerchantSearchBoxInfo:Show()
	end
end

-- Handler to remove searchtext on ESC pressing
function ImprovedMerchantSearchBox_OnEscapePressed(self)
	ImprovedMerchant_DepopulateMerchantList()
	ImprovedMerchant_PopulateList()
	self:SetText("")
	self:ClearFocus()
	ImprovedMerchantSearchBoxInfo:Show()
end

-- Handler to hide "SEARCH" Text when entering something in the box
function ImprovedMerchantSearchBox_OnChar(self)
	ImprovedMerchantSearchBoxInfo:Hide()
end

-- Handler to register Events and fix the scrollbar-background
-- ( I do not know why but the background is broken when using in xml
function ImprovedMerchant_OnLoad(self)
	self:RegisterEvent("MERCHANT_UPDATE")
	self:RegisterEvent("MERCHANT_SHOW")
	self:RegisterEvent("CHAT_MSG_SYSTEM")
	-- this is a fix for the Scrollbar background
	MerchantBuyBackItem:SetPoint("TOPLEFT", ImprovedMerchant, "BOTTOM", 23,-12)
	ImprovedMerchantTop:SetPoint("TOPLEFT", ImprovedMerchant, "TOPRIGHT", -2 , 4)
	ImprovedMerchantBottom:SetPoint("BOTTOMLEFT", ImprovedMerchant, "BOTTOMRIGHT", -2 , -2)
end
