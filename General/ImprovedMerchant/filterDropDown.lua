-- constants
local ImprovedMerchant_NOTHING    = 0
local ImprovedMerchant_AFFORDABLE = 1
local ImprovedMerchant_TRAINABLE  = 2
local ImprovedMerchant_USABLE     = 4

function ImprovedMerchant_PopulateFilter(typeList)
	local level = 1
	local info
	-- LNOTHING filter (show all elements)
	info = UIDropDownMenu_CreateInfo()
	info.text = LNOTHING
	info.value = ImprovedMerchant_NOTHING
	info.owner = this:GetParent()
	info.func = function()
		UIDropDownMenu_SetSelectedValue(this.owner, this.value)
		ImprovedMerchant_DepopulateMerchantList()
		if ImprovedMerchantSearchBox:GetText() ~= "" then
			ImprovedMerchant_PopulateList(ImprovedMerchantSearchBox:GetText(), nil)
		else
			ImprovedMerchant_PopulateList(nil, nil)
		end
		ImprovedMerchantSortListText:SetText(LNOTHING)
	end
	UIDropDownMenu_AddButton(info, level)
	
	-- LAFFORDABLE filter (show only items that can be purchased)
	info = UIDropDownMenu_CreateInfo()
	info.text = LAFFORDABLE
	info.value = ImprovedMerchant_AFFORDABLE
	info.owner = this:GetParent()
	info.func = function()
		UIDropDownMenu_SetSelectedValue(this.owner, this.value)
		ImprovedMerchant_DepopulateMerchantList()
		if ImprovedMerchantSearchBox:GetText() ~= "" then
			ImprovedMerchant_PopulateList(ImprovedMerchantSearchBox:GetText(), ImprovedMerchant_AFFORDABLE)
		else
			ImprovedMerchant_PopulateList(nil, ImprovedMerchant_AFFORDABLE)
		end
		ImprovedMerchantSortListText:SetText(LAFFORDABLE)
	end
	UIDropDownMenu_AddButton(info, level)
	
	-- LUSABLE filter (show only items that has no red lines in thier tooltip)
	info = UIDropDownMenu_CreateInfo()
	info.text = LUSABLE
	info.value = ImprovedMerchant_USABLE
	info.owner = this:GetParent()
	info.func = function()
		UIDropDownMenu_SetSelectedValue(this.owner, this.value)
		ImprovedMerchant_DepopulateMerchantList()
		if ImprovedMerchantSearchBox:GetText() ~= "" then
			ImprovedMerchant_PopulateList(ImprovedMerchantSearchBox:GetText(), ImprovedMerchant_USABLE)
		else
			ImprovedMerchant_PopulateList(nil, ImprovedMerchant_USABLE)
		end
		ImprovedMerchantSortListText:SetText(LUSABLE)
	end
	UIDropDownMenu_AddButton(info, level)
	
	-- LTRAINABLE filter (show only items that has no red lines in thier tooltip AND only if the item is a LRECIPE)
	info = UIDropDownMenu_CreateInfo()
	info.text = LTRAINABLE
	info.value = ImprovedMerchant_TRAINABLE
	info.owner = this:GetParent()
	info.func = function()
		UIDropDownMenu_SetSelectedValue(this.owner, this.value)
		ImprovedMerchant_DepopulateMerchantList()
		if ImprovedMerchantSearchBox:GetText() ~= "" then
			ImprovedMerchant_PopulateList(ImprovedMerchantSearchBox:GetText(), ImprovedMerchant_TRAINABLE)
		else
			ImprovedMerchant_PopulateList(nil, ImprovedMerchant_TRAINABLE)
		end
		ImprovedMerchantSortListText:SetText(LTRAINABLE)
	end
	UIDropDownMenu_AddButton(info, level)
	
	-- itemtyp filter (armor, weapon, trading-goods etc.)
	if typeList then
		info = UIDropDownMenu_CreateInfo()
		info.text = ""
		info.isTitle = true

		UIDropDownMenu_AddButton(info, level)
		
		
		for vals,state in pairs(typeList) do
			if state == true then
				info = UIDropDownMenu_CreateInfo()
				info.text = vals
				info.value = vals
				info.owner = this:GetParent()
				info.func = function()
					UIDropDownMenu_SetSelectedValue(this.owner, this.value)
					ImprovedMerchant_DepopulateMerchantList()

					if ImprovedMerchantSearchBox:GetText() ~= "" then
					
						ImprovedMerchant_PopulateList(ImprovedMerchantSearchBox:GetText(),vals)
					else
						ImprovedMerchant_PopulateList(nil, vals)
					end
					ImprovedMerchantSortListText:SetText(vals)
				end
				UIDropDownMenu_AddButton(info, level)
			end
		end
		
		
		
	end
	
	
	
	
end 