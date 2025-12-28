function ImprovedMerchant_Update(button, id, r, g, b, a)

	local itemName, itemTexture, price, quantity, numAvailable, isLUSABLE, extendedCost = GetMerchantItemInfo(id)
	local _, _, itemRarity, _, _, itemType, itemSubType = GetItemInfo(GetMerchantItemLink(id))
	local honorPoints, arenaPoints, itemCount = GetMerchantItemCostInfo(id)
	local currency1Texture, currency1Amount, currency1 = GetMerchantItemCostItem(id, 1)
	local currency2Texture, currency2Amount, currency2 = GetMerchantItemCostItem(id, 2)
	local currency3Texture, currency3Amount, currency3 = GetMerchantItemCostItem(id, 3)

	
	local baseName = button:GetName()
	button:Show()
	button:SetID(id)
	button:Enable()
	button.link = GetMerchantItemLink(id)
	button.texture = itemTexture
	button.extendedCost = extendedCost
	_G[baseName.."Texture"]:SetTexture(itemTexture)
	_G[baseName.."Texture"]:SetVertexColor(r,g,b,a) -- LRECIPEBook support
	_G[baseName.."Name"]:SetText(itemName)
	_G[baseName.."Name"]:SetVertexColor(GetItemQualityColor(itemRarity or 1))
	if numAvailable > 0 then
		_G[baseName.."Stock"]:SetText("x"..numAvailable)
		_G[baseName.."Stock"]:Show()
	else
		_G[baseName.."Stock"]:Hide()
	end
	if quantity > 1 and numAvailable == -1 then
		_G[baseName.."Count"]:SetText(quantity)
		_G[baseName.."Count"]:Show()
	else
		_G[baseName.."Count"]:Hide()
	end
	if itemType ~= "Money" then
		_G[baseName.."Type"]:SetText((itemType or "") .. " ("..(itemSubType or "")..")")
	else
		_G[baseName.."Type"]:SetText("")
	end
	-- update cost info boxes
	if price > 0 then
		MoneyFrame_SetType(_G[baseName.."MoneyFrame"],"STATIC")
		MoneyFrame_Update(_G[baseName.."MoneyFrame"],price)
		_G[baseName.."MoneyFrame"]:Show()
	else
		_G[baseName.."MoneyFrame"]:Hide()
	end
	if honorPoints > 0 then
		_G[baseName.."HonorFrameValue"]:SetText(honorPoints)
		_G[baseName.."HonorFrameIcon"]:SetTexture("Interface\\PVPFrame\\PVP-Currency-"..UnitFactionGroup("player"))
		_G[baseName.."HonorFrame"]:Show()
	else
		_G[baseName.."HonorFrame"]:Hide()
	end
	if arenaPoints > 0 then
		_G[baseName.."ArenaFrameValue"]:SetText(arenaPoints)
		_G[baseName.."ArenaFrameIcon"]:SetTexture("Interface\\PVPFrame\\PVP-ArenaPoints-Icon")
		_G[baseName.."ArenaFrame"]:Show()
	else
		_G[baseName.."ArenaFrame"]:Hide()
	end
	if currency1Amount > 0 then
		_G[baseName.."ItemCost1FrameValue"]:SetText(currency1Amount)
		_G[baseName.."ItemCost1FrameIcon"]:SetTexture(currency1Texture)
		_G[baseName.."ItemCost1Frame"].link = currency1
		_G[baseName.."ItemCost1Frame"]:Show()
	else
		_G[baseName.."ItemCost1Frame"]:Hide()
	end
	if currency2Amount > 0 then
		_G[baseName.."ItemCost2FrameValue"]:SetText(currency2Amount)
		_G[baseName.."ItemCost2FrameIcon"]:SetTexture(currency2Texture)
		_G[baseName.."ItemCost2Frame"].link = currency2
		_G[baseName.."ItemCost2Frame"]:Show()
	else
		_G[baseName.."ItemCost2Frame"]:Hide()
	end
	if currency3Amount > 0 then
		_G[baseName.."ItemCost3FrameValue"]:SetText(currency3Amount)
		_G[baseName.."ItemCost3FrameIcon"]:SetTexture(currency3Texture)
		_G[baseName.."ItemCost3Frame"].link = currency3
		_G[baseName.."ItemCost3Frame"]:Show()
	else
		_G[baseName.."ItemCost3Frame"]:Hide()
	end
	
	-- realign boxes
    --[[ so it will look like this
	  
	  [ItemCost3Frame] [ItemCost2Frame] [ItemCost1Frame] [ArenaFrame | HonorFrame | MoneyFrame]
	  
	--]]
	if price > 0 then
		_G[baseName.."MoneyFrame"]:ClearAllPoints()
		_G[baseName.."MoneyFrame"]:SetPoint("BOTTOMRIGHT", 10, 0)
	end
	
	if honorPoints > 0 and price > 0 then
		_G[baseName.."HonorFrame"]:ClearAllPoints()
		_G[baseName.."HonorFrame"]:SetPoint("BOTTOMRIGHT", _G[baseName.."MoneyFrame"], "BOTTOMLEFT", 0, 0)
	elseif honorPoints > 0 then
		_G[baseName.."HonorFrame"]:ClearAllPoints()
		_G[baseName.."HonorFrame"]:SetPoint("BOTTOMRIGHT")
	end
	
	if arenaPoints > 0 and honorPoints > 0 then
		_G[baseName.."ArenaFrame"]:ClearAllPoints()
		_G[baseName.."ArenaFrame"]:SetPoint("BOTTOMRIGHT", _G[baseName.."HonorFrame"], "BOTTOMLEFT", 0, 0)
	elseif arenaPoints > 0 and price > 0 then
		_G[baseName.."ArenaFrame"]:ClearAllPoints()
		_G[baseName.."ArenaFrame"]:SetPoint("BOTTOMRIGHT", _G[baseName.."MoneyFrame"], "BOTTOMLEFT", 0, 0)
	elseif arenaPoints > 0 then
		_G[baseName.."ArenaFrame"]:ClearAllPoints()
		_G[baseName.."ArenaFrame"]:SetPoint("BOTTOMRIGHT")
	end
	
	if currency3Amount > 0 then
		_G[baseName.."ItemCost3Frame"]:ClearAllPoints()
		_G[baseName.."ItemCost3Frame"]:SetPoint("BOTTOMRIGHT", _G[baseName.."ItemCost2Frame"], "BOTTOMLEFT", 0, 0)
	end
	
	if currency2Amount > 0 then
		_G[baseName.."ItemCost2Frame"]:ClearAllPoints()
		_G[baseName.."ItemCost2Frame"]:SetPoint("BOTTOMRIGHT", _G[baseName.."ItemCost1Frame"], "BOTTOMLEFT", 0, 0)
	end
	
	if currency1Amount > 0 and arenaPoints > 0 then
		_G[baseName.."ItemCost1Frame"]:ClearAllPoints()
		_G[baseName.."ItemCost1Frame"]:SetPoint("BOTTOMRIGHT", _G[baseName.."ArenaFrame"], "BOTTOMLEFT", 0, 0)
	elseif currency1Amount > 0 and honorPoints > 0 then
		_G[baseName.."ItemCost1Frame"]:ClearAllPoints()
		_G[baseName.."ItemCost1Frame"]:SetPoint("BOTTOMRIGHT", _G[baseName.."HonorFrame"], "BOTTOMLEFT", 0, 0)
	elseif currency1Amount > 0 and price > 0 then
		_G[baseName.."ItemCost1Frame"]:ClearAllPoints()
		_G[baseName.."ItemCost1Frame"]:SetPoint("BOTTOMRIGHT", _G[baseName.."MoneyFrame"], "BOTTOMLEFT", 0, 0)
	elseif currency1Amount > 0 then
		_G[baseName.."ItemCost1Frame"]:SetPoint("BOTTOMRIGHT")
	end
end 