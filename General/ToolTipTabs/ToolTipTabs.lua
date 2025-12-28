ToolTipTabs = LibStub("AceAddon-3.0"):NewAddon("ToolTipTabs")

local registryTab = {}
local registryTooltip = {}
local TOTAL_TOOLTIPS = 0
local TOTAL_TABS = 0
local BUTTON_HEIGHT = 44
local BUTTON_WIDTH = 44
local oldSetItemRef
local enabled = 0
local _G = _G
local pairs = _G.pairs
local questTabs = {}
local isDragging = false
local dragTab = nil
local dummyFrame = CreateFrame("Frame")

local LBF = LibStub("LibButtonFacade", true)
ToolTipTabs.LBF = LBF
ToolTipTabs.BF = function()
	if LBF then
		if ToolTipTabs.db.profile.BF.SkinID and ToolTipTabs.db.profile.BF.SkinID ~= "Blizzard" then
			return 1
		end
	else
		return nil
	end
end

local function getIconColor(link, type)
	if ToolTipTabs.db.profile.colors[type].preset then
		if type == "achievement" then
			if select(4,strsplit(":",link)) == "1" then
				return 0, 1, 0
			end
			return 1, 0, 0
		--[[elseif type == "spell" then
			return 0,0,0
		elseif type == "enchant" then
			return 0,0,0]]
		elseif type == "quest" then
			local lvl = tonumber(select(3,strsplit(":", link)))
			if lvl == -1 then lvl = UnitLevel("player") end
			local c = GetQuestDifficultyColor(lvl)
			return c.r, c.g, c.b
		elseif type == "item" then
			local cr, cg, cb = GetItemQualityColor(select(3,GetItemInfo(link)) or 1) 
			return cr, cg, cb
		else
			if not ToolTipTabs.db.profile.BF.Colors.Normal then
				return 1, 1, 1
			else
				return ToolTipTabs.db.profile.BF.Colors.Normal[1],ToolTipTabs.db.profile.BF.Colors.Normal[2],ToolTipTabs.db.profile.BF.Colors.Normal[3]
			end
		end
	elseif ToolTipTabs.db.profile.colors[type].bf then
		if not ToolTipTabs.db.profile.BF.Colors.Normal then
			return 1, 1, 1
		else
			return ToolTipTabs.db.profile.BF.Colors.Normal[1],ToolTipTabs.db.profile.BF.Colors.Normal[2],ToolTipTabs.db.profile.BF.Colors.Normal[3]
		end
	end
	if not ToolTipTabs.db.profile.BF.Colors.Normal then
		return 1, 1, 1
	else
		return ToolTipTabs.db.profile.BF.Colors.Normal[1],ToolTipTabs.db.profile.BF.Colors.Normal[2],ToolTipTabs.db.profile.BF.Colors.Normal[3]
	end
end
local function getIcon(link, type)
	if type == "achievement" then
		return select(10,GetAchievementInfo(tonumber(link:match("^[^:]+:(%d+)"))))
	elseif type == "spell" then
		return select(3,GetSpellInfo(tonumber(link:match("^[^:]+:(%d+)"))))
	elseif type == "enchant" then
		return select(3,GetSpellInfo(tonumber(link:match("^[^:]+:(%d+)"))))	
	elseif type == "quest" then
		return "Interface\\Icons\\INV_MISC_QuestionMark"
	elseif type == "item" then
		return GetItemIcon(link)
	else
		return "Interface\\Icons\\Trade_Engineering"
	end
end

local function redrawTabs(tooltip, recolor, oldTab)
	registryTooltip[tooltip].numTabs = 0
	local currentCount = 0
	local column = 0
	local row = 0
	if recolor and recolor == true then
		registryTooltip[tooltip].currentTab.overlay:SetVertexColor(1.0, 1.0, 1.0)
		if ToolTipTabs.BF() then 
			LBF:SetNormalVertexColor(registryTooltip[tooltip].currentTab, getIconColor(registryTab[registryTooltip[tooltip].currentTab].link, registryTab[registryTooltip[tooltip].currentTab].type))
		end	
		if oldTab then
			if oldTab ~= registryTooltip[tooltip].currentTab then
				oldTab.overlay:SetVertexColor(0.4, 0.4, 0.4)
				if ToolTipTabs.BF() then 
					local cr, cg, cb = getIconColor(registryTab[oldTab].link, registryTab[oldTab].type)
					LBF:SetNormalVertexColor(oldTab, cr*0.4, cg*0.4, cb*0.4)
				end
			end
		end
	end
	for i=1, TOTAL_TABS do
		local k = _G["ToolTipTabs"..i]
		if k and registryTab[k].link then
			if registryTab[k].tooltip == tooltip then
				registryTooltip[tooltip].numTabs = registryTooltip[tooltip].numTabs + 1
				k:ClearAllPoints()
				k:SetPoint("TOPRIGHT", tooltip, "TOPLEFT", -(column*(BUTTON_WIDTH+ToolTipTabs.db.profile.hspacing))-ToolTipTabs.db.profile.xoffset, -(row*(BUTTON_HEIGHT+ToolTipTabs.db.profile.vspacing))-ToolTipTabs.db.profile.yoffset)
				if not k:IsShown() then
					k:Show()
				end
				row = row + 1
				if row == (ToolTipTabs.db.profile.columnsize) then
					row = 0
					column = column + 1
				end
			end
		end
	end
end

function ToolTipTabs:RedrawAll()
	for k in pairs(registryTooltip) do
		redrawTabs(k, false)
	end
end

function ToolTipTabs:RecolorAll()
	if ToolTipTabs.BF() then
		local cr, cg, cb
		for i=1, TOTAL_TABS do
			local k = _G["ToolTipTabs"..i]
			if k and registryTab[k].link then
				LBF:SetNormalVertexColor(k, getIconColor(registryTab[k].link, registryTab[k].type))			
			end
		end
	end
end

local function findNextTab(tooltip)
	for i=1, TOTAL_TABS do
		local k = _G["ToolTipTabs"..i]
		if registryTab[k].link then
			if registryTab[k].tooltip == tooltip and k ~= registryTooltip[tooltip].currentTab then
				return k
			end
		end
	end
	return nil
end

local function switchToTab(tab)
	if not tab then return end
	local tooltip = registryTab[tab].tooltip
	local x, y = tooltip:GetLeft(), tooltip:GetTop()
	local oldTab = registryTooltip[tooltip].currentTab

	HideUIPanel(tooltip)
	ShowUIPanel(tooltip)
	if not tooltip:IsShown() then
		tooltip:SetOwner(UIParent, "ANCHOR_PRESERVE")
	end
	
	if tab ~= registryTooltip[tooltip].currentTab then 
		tooltip:SetHyperlink(registryTab[tab].link)
		registryTooltip[tooltip].currentTab = tab
	end
	
	if not tooltip:IsShown() then
		tooltip:SetHyperlink(registryTab[tab].link)
	end

	redrawTabs(tooltip, true, oldTab)
	if x and y then
		tooltip:ClearAllPoints()
		tooltip:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
	end
end

local function clearIcons(tooltip)
	registryTooltip[tooltip].cleared(tooltip)
	for k in pairs(registryTab) do
		if registryTab[k].link then
			if registryTab[k].tooltip == tooltip then
				if LBF then
					LBF:Group("ToolTipTabs", "Tabs"):RemoveButton(k)	
				end
				k:Hide()
				registryTab[k] = {}
				if questTabs[k] then 
					questTabs[k] = nil 
				end
			end
		end
	end
	registryTooltip[tooltip].currentTab = nil
	registryTooltip[tooltip].numTabs = 0
end

local function closeTab(tooltip, tab)
	if registryTooltip[tooltip].currentTab == tab then
		switchToTab(findNextTab(tooltip))
	end
	if LBF then
		LBF:Group("ToolTipTabs", "Tabs"):RemoveButton(tab)	
	end
	tab:Hide()
	registryTab[tab] = {}
	if questTabs[tab] then questTabs[tab] = nil end
	registryTooltip[tooltip].numTabs = registryTooltip[tooltip].numTabs - 1
	if registryTooltip[tooltip].numTabs == 0 then
		registryTooltip[tooltip].currentTab = nil
		HideUIPanel(tooltip)
		return
	end
	redrawTabs(tooltip)
end

local function closeAllTabs()
	for k in pairs(registryTooltip) do
		clearIcons(k)
		HideUIPanel(k)
	end
end

local function closeCurrent(self)
	closeTab(self:GetParent(), registryTooltip[self:GetParent()].currentTab)
end

local function newTooltip()
	local id = TOTAL_TOOLTIPS+1
	TOTAL_TOOLTIPS = TOTAL_TOOLTIPS + 1
	local name = "ItemRefTooltip"..id
	local tooltip = CreateFrame("GameTooltip", name, UIParent, "TTT_ItemRefTooltipTemplate")
	tooltip:SetScript("OnDragStop", tooltip.StopMovingOrSizing)
	tinsert(UISpecialFrames, name)
	registryTooltip[tooltip] = {}
	registryTooltip[tooltip].numTabs = 0
	registryTooltip[tooltip].currentTab = nil
	registryTooltip[tooltip].closeCurrent = CreateFrame("Button", nil, tooltip, "UIPanelCloseButton")
	registryTooltip[tooltip].closeCurrent:SetScript("OnClick", closeCurrent)
	registryTooltip[tooltip].closeCurrent:SetPoint("BOTTOMLEFT",tooltip, "TOPLEFT", 18, -5)
	registryTooltip[tooltip].closeAll = CreateFrame("Button", nil, tooltip, "UIPanelCloseButton")
	registryTooltip[tooltip].closeAll:SetScript("OnClick", closeAllTabs)
	registryTooltip[tooltip].closeAll:SetPoint("BOTTOMLEFT", tooltip, "TOPLEFT", -5, -5)
	tooltip:SetOwner(UIParent, "ANCHOR_PRESERVE")
    registryTooltip[tooltip].cleared = tooltip:GetScript("OnTooltipCleared")
	return tooltip
end

local function getTooltip()
	for k in pairs(registryTooltip) do
		if registryTooltip[k].numTabs == 0 then
			return k
		end
	end
	return newTooltip()
end

local function click(tab)
	if registryTab[tab].link then
		if IsModifiedClick("CHATLINK") then
			local edit = ChatEdit_GetActiveWindow()
			if edit and edit:IsVisible() then
				edit:Insert(registryTab[tab].text)
			end
		elseif IsModifiedClick("DRESSUP") then
			if registryTab[tab].type == "achievement" then 
				if not (AchievementFrame and AchievementFrame:IsShown()) then
					ToggleAchievementFrame()
				end
				local id = tonumber(registryTab[tab].link:match("achievement:(%d+)"))
				if not id then return end
				AchievementFrame_SelectAchievement(id)
			elseif registryTab[tab].type == "item" then
				DressUpItemLink(registryTab[tab].link)
			end
		else
			switchToTab(tab)
		end
	end
end

local function moveTabToTooltip(tab, tooltip)
	if registryTab[tab].tooltip == tooltip then return end
	local oldTooltip = registryTab[tab].tooltip
	registryTab[tab].tooltip = tooltip
	registryTooltip[oldTooltip].numTabs = registryTooltip[oldTooltip].numTabs - 1
	if tab == registryTooltip[oldTooltip].currentTab then
		registryTooltip[oldTooltip].currentTab = nil
		if registryTooltip[oldTooltip].numTabs > 0 then
			switchToTab(findNextTab(oldTooltip))
		else
			registryTooltip[oldTooltip].currentTab = nil
			HideUIPanel(oldTooltip)
		end	
	else
		redrawTabs(oldTooltip)
	end
	registryTooltip[tooltip].numTabs = registryTooltip[tooltip].numTabs + 1
	tab:SetParent(tooltip)
	switchToTab(tab)
end

local function dragStart(self)
	isDragging = true
	dragTab = self	
end

local function isAvailableTooltip()
	for k in pairs(registryTooltip) do
		if registryTooltip[k].numTabs == 0 then
			return true
		end
	end
	if (TOTAL_TOOLTIPS-1) < ToolTipTabs.db.profile.maxtooltips then
		return true
	end
	return false
end

local function dragStop(self) 
	if ToolTipTabs.db.profile.multitooltip == true then
		local focus = GetMouseFocus()
		if focus then
			if registryTooltip[focus] then
				moveTabToTooltip(dragTab, focus)
				SetCursor("POINT_CURSOR")
			else
				if registryTooltip[registryTab[self].tooltip].numTabs > 1 and isAvailableTooltip() then
					local newTooltip = getTooltip()
					newTooltip:ClearAllPoints()
					local x, y = GetCursorPosition()
					local scale = UIParent:GetEffectiveScale()
					local framescale = newTooltip:GetScale()
					x = x / framescale / scale
					y = y / framescale / scale
					newTooltip:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x+(BUTTON_WIDTH/2), y+(BUTTON_HEIGHT/2))
					moveTabToTooltip(dragTab, newTooltip)
				else
					registryTab[self].tooltip:ClearAllPoints()
					local x, y = GetCursorPosition()
					local scale = UIParent:GetEffectiveScale()
					local framescale = registryTab[self].tooltip:GetScale()
					x = x / framescale / scale
					y = y / framescale / scale
					registryTab[self].tooltip:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x+(BUTTON_WIDTH/2), y+(BUTTON_HEIGHT/2))
				end
			end
		end
	else
		registryTab[self].tooltip:ClearAllPoints()
		local x, y = GetCursorPosition()
		local scale = UIParent:GetEffectiveScale()
		local framescale = registryTab[self].tooltip:GetScale()
		x = x / framescale / scale
		y = y / framescale / scale
		registryTab[self].tooltip:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x+(BUTTON_WIDTH/2), y+(BUTTON_HEIGHT/2))
	end
	isDragging = false
	dragTab = nil		
	SetCursor(nil)		
end

function ToolTipTabs:TabScale(scale)
	for k in pairs(registryTab) do
		if registryTab[k].link then
			k:SetScale(scale or self.db.profile.scale)
		end
	end
end

function ToolTipTabs:AddTab(tooltip, link, type, text)
	TOTAL_TABS = TOTAL_TABS+1
	registryTooltip[tooltip].numTabs = registryTooltip[tooltip].numTabs + 1
	
	local tab_name = "ToolTipTabs"..TOTAL_TABS
	local tab = CreateFrame("Button", tab_name, tooltip)
	tab:SetWidth(BUTTON_WIDTH)
    tab:SetHeight(BUTTON_HEIGHT)
	tab:SetScript("OnDragStart", dragStart)
	tab:SetScript("OnDragStop", dragStop)
    tab:RegisterForDrag("LeftButton")
	tab:SetScript("OnClick", click)
	tab:SetScale(self.db.profile.scale)

 	tab.overlay = tab:CreateTexture(nil,"ARTWORK")
	tab.overlay:SetAllPoints()
	tab.overlay:SetTexture(getIcon(link, type))

	registryTab[tab] = {}
	registryTab[tab].link = link
	registryTab[tab].type = type
	registryTab[tab].tooltip = tooltip
	registryTab[tab].text = text
	if type == "quest" then questTabs[tab] = true end
	if LBF then LBF:Group("ToolTipTabs", "Tabs"):AddButton(_G[tab_name], {Icon=_G[tab_name].overlay}) end
	switchToTab(tab)
	return tab	
end
local function returnStrippedLink(link)
	local tbl = {strsplit(":", link)}
	if tbl[1] == "item" then
		if tbl[10] then -- Some links are purely item:id :S (Namely the emote printed when using Titanium Seal of Dalaran, the link printed is simply item:id
			if select(3, GetItemInfo(link)) ~= 7 then -- Heirloom item, keep the given level
				tbl[10] = MAX_PLAYER_LEVEL
			end
			if tonumber(tbl[8]) >= 0 then -- Has a non-negative suffixID, ignore the uniqueID
				tbl[9] = 0
			end
		else -- if the link is incomplete, fill it in!
			for i=1, 9 do
				if not tbl[i] then
					tbl[i] = 0
				end
			end
			tbl[10] = MAX_PLAYER_LEVEL
		end
	end
	link = strjoin(":", unpack(tbl))
	return link, tbl[1]
end

function ToolTipTabs:ShowAll()
	for k in pairs(registryTooltip) do
		if registryTooltip[k].numTabs > 0 then	
			switchToTab(registryTooltip[k].currentTab)
		end
	end
end

function ToolTipTabs:EnableAdditionalTT()
	for k in pairs(registryTooltip) do
		if k ~= ItemRefTooltip then
			registryTooltip[k].numTabs = 0
			registryTooltip[k].currentTab = nil
			registryTooltip[k].closeAll:Show()
			registryTooltip[k].closeCurrent:Show()
		end		
	end
end

function ToolTipTabs:DisableAdditionalTT()
	for k in pairs(registryTooltip) do
		if k ~= ItemRefTooltip then
			registryTooltip[k].numTabs = 0
			registryTooltip[k].currentTab = nil
			registryTooltip[k].closeAll:Hide()
			registryTooltip[k].closeCurrent:Hide()
			k:Hide()
		end
	end
	for k in pairs(registryTab) do
		if registryTab[k].link then
			if registryTab[k].tooltip ~= ItemRefTooltip then
				k:Hide()
				registryTab[k] = {}
				if questTabs[k] then questTabs[k] = nil end
			end
		end
	end
end

function ToolTipTabs:CloseExtraTabs()
	local maxtabs = self.db.profile.maxcolumns*self.db.profile.columnsize
	local tabcount = {}
	for k in pairs(registryTooltip) do
		tabcount[k] = 0
	end
	for i=1, TOTAL_TABS do
		local k = _G["ToolTipTabs"..i]
		if k and registryTab[k].link then
			if tabcount[registryTab[k].tooltip] >= maxtabs then
				if registryTooltip[registryTab[k].tooltip].currentTab == k then
					switchToTab(findNextTab(registryTab[k].tooltip))
				end
				k:Hide()
				registryTooltip[registryTab[k].tooltip].numTabs = registryTooltip[registryTab[k].tooltip].numTabs - 1
				registryTab[k] = {}
				if questTabs[k] then questTabs[k] = nil end	
			else
				tabcount[registryTab[k].tooltip] = tabcount[registryTab[k].tooltip] + 1
			end
		end
	end
end

function ToolTipTabs:CloseExtraTT()
	local cur = 0
	for i=2, TOTAL_TOOLTIPS do
		local k = _G["ItemRefTooltip"..i]
		if k then 
			cur = cur + 1
			if cur > self.db.profile.maxtooltips then
				clearIcons(k)
				k:Hide()
			end
		else
			break
		end
	end
end

function ToolTipTabs:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("ToolTipTabsDB", {
		profile = {
			enable = true,
			multitooltip = true,
			maxtooltips = 3,
			columnsize = 4,
			maxcolumns = 4,
			maxxedbehaviour = 1,
			scale = 1,
			vspacing = 0,
			hspacing = 0,
			xoffset = 0,
			yoffset = 0,
			colors = {
				item = {
					r = 0.3,
					g = 0.3,
					b = 0.7,
					preset = true,
					bf = false,
				},	
				spell = {
					r = 0.3,
					g = 0.3,
					b = 0.7,
					preset = false,				
				},
				achievement = {
					r = 0.3,
					g = 0.3,
					b = 0.7,
					preset = true,
					bf = false,
				},
				talent = {
					r = 0.3,
					g = 0.3,
					b = 0.7,
					preset = false,				
				},
				quest = {
					r = 0.3,
					g = 0.3,
					b = 0.7,
					preset = true,
					bf = false,
				},	
				enchant = {
					r = 0.3,
					g = 0.3,
					b = 0.7,
					preset = false,				
				},
				glyph = {
					r = 0.3,
					g = 0.3,
					b = 0.7,
					preset = false,				
				},				
			},
		},
	}, "Default")

	LibStub("AceConfig-3.0"):RegisterOptionsTable("ToolTipTabs", ToolTipTabs.options, {"ttt","tooltiptabs"})
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("ToolTipTabs")

	TOTAL_TOOLTIPS = 1
	registryTooltip[ItemRefTooltip] = {}
	registryTooltip[ItemRefTooltip].closeCurrent = CreateFrame("Button", nil, ItemRefTooltip, "UIPanelCloseButton")
	registryTooltip[ItemRefTooltip].closeCurrent:SetScript("OnClick", closeCurrent)
	registryTooltip[ItemRefTooltip].closeCurrent:SetPoint("BOTTOMLEFT", ItemRefTooltip, "TOPLEFT", 18, -5)
	registryTooltip[ItemRefTooltip].closeAll = CreateFrame("Button", nil, ItemRefTooltip, "UIPanelCloseButton")
	registryTooltip[ItemRefTooltip].closeAll:SetScript("OnClick", closeAllTabs)
	registryTooltip[ItemRefTooltip].closeAll:SetPoint("BOTTOMLEFT", ItemRefTooltip, "TOPLEFT", -5, -5)
	registryTooltip[ItemRefTooltip].numTabs = 0
	registryTooltip[ItemRefTooltip].currentTab = nil
	registryTooltip[ItemRefTooltip].cleared = ItemRefTooltip:GetScript("OnTooltipCleared")

	if ToolTipTabs.BF() then 
		dummyFrame:RegisterEvent("PLAYER_LEVEL_UP") 
		dummyFrame:SetScript("OnEvent", function(self)
			for k in pairs(questTabs) do
				if ToolTipTabs.BF() then 
					LBF:SetNormalVertexColor(k, getIconColor(registryTab[k].link, registryTab[k].type))
				end
			end
		end)
	end
	dummyFrame:SetScript("OnUpdate", function(self, elapsed)
		if isDragging == true then
			if dragTab then
				SetCursor(dragTab.overlay:GetTexture())
			end
		end
	end)	
end

function ToolTipTabs:OnEnable()
	if enabled == 1 then
		return
	else
		enabled = 1
	end

	if LBF then
		self.db.profile.BF = self.db.profile.BF or {} 
		LBF:Group("ToolTipTabs", "Tabs"):Skin(self.db.profile.BF.SkinID, self.db.profile.BF.Gloss, self.db.profile.BF.Backdrop, self.db.profile.BF.Colors)
		LBF:RegisterSkinCallback("ToolTipTabs", function(_, SkinID, Gloss, Backdrop, Group, _, Colors)
			self.db.profile.BF.SkinID = SkinID
			self.db.profile.BF.Gloss = Gloss
			self.db.profile.BF.Backdrop = Backdrop
			self.db.profile.BF.Colors = Colors
			if Group == "Tabs" and SkinID ~= "Blizzard" then
				self.RecolorAll()
			end
		end, self)
	end	
	
	oldSetItemRef = SetItemRef
	SetItemRef = function(link, text, button, chatframe)
		if not link then return end
		if IsModifiedClick() then
			return oldSetItemRef(link, text, button, chatframe)
		end
		local type
		link, type = returnStrippedLink(link)
		if type == "trade" then
			oldSetItemRef(link, text, button, chatframe)
			if registryTooltip[ItemRefTooltip].numTabs > 0 and ItemRefTooltip:IsShown() then
				local oldTab = registryTooltip[ItemRefTooltip].currentTab
				registryTooltip[ItemRefTooltip].currentTab = nil
				switchToTab(oldTab)
			end
			return
		end	
		if not ToolTipTabs.db.profile.colors[type] then
			return oldSetItemRef(link, text, button, chatframe)
		end
		for k in pairs(registryTab) do
			if registryTab[k].link == link then
				if registryTooltip[registryTab[k].tooltip].currentTab == k then
					if registryTab[k].tooltip:IsShown() then
						HideUIPanel(registryTab[k].tooltip)
					else
						switchToTab(k)
					end
				else
					switchToTab(k)
				end
				return
			end
		end
		if ToolTipTabs.db.profile.multitooltip == false then
			if registryTooltip[ItemRefTooltip].numTabs < ToolTipTabs.db.profile.maxcolumns*ToolTipTabs.db.profile.columnsize then
				ToolTipTabs:AddTab(ItemRefTooltip, link, type, text)
			else
				if ToolTipTabs.db.profile.maxxedbehaviour == 1 then
					local firstTab = findNextTab(ItemRefTooltip) or registryTooltip[ItemRefTooltip].currentTab
					firstTab.overlay:SetTexture(getIcon(link, type))
					registryTab[firstTab].link = link
					registryTab[firstTab].text = text
					registryTab[firstTab].type = type
					if type == "quest" then questTabs[firstTab] = true else questTabs[firstTab] = nil end
					switchToTab(firstTab)
				elseif ToolTipTabs.db.profile.maxxedbehaviour == 2 then
					clearIcons(ItemRefTooltip)
					HideUIPanel(ItemRefTooltip)
					ToolTipTabs:AddTab(ItemRefTooltip, link, type, text)
				end
			end
		else
			local tooltip
			if registryTooltip[ItemRefTooltip].numTabs < (ToolTipTabs.db.profile.maxcolumns*ToolTipTabs.db.profile.columnsize) then
				tooltip = ItemRefTooltip
			else
				for i=2, TOTAL_TOOLTIPS do
					local k = _G["ItemRefTooltip"..i]
					if k then 
						if registryTooltip[k].numTabs < (ToolTipTabs.db.profile.maxcolumns*ToolTipTabs.db.profile.columnsize) then
							tooltip = k
						end
					else
						break
					end
				end
			end
			if tooltip then
				ToolTipTabs:AddTab(tooltip, link, type, text)
			else
				if TOTAL_TOOLTIPS < ToolTipTabs.db.profile.maxtooltips then
					ToolTipTabs:AddTab(newTooltip(), link, type, text)
				else
					if ToolTipTabs.db.profile.maxxedbehaviour == 1 then
						local firstTab = findNextTab(ItemRefTooltip) or registryTooltip[ItemRefTooltip].currentTab
						firstTab.overlay:SetTexture(getIcon(link, type))
						registryTab[firstTab].link = link
						registryTab[firstTab].text = text
						registryTab[firstTab].type = type
						if type == "quest" then questTabs[firstTab] = true else questTabs[firstTab] = nil end						
						switchToTab(firstTab)
					elseif ToolTipTabs.db.profile.maxxedbehaviour == 2 then
						clearIcons(ItemRefTooltip)
						HideUIPanel(ItemRefTooltip)
						ToolTipTabs:AddTab(ItemRefTooltip, link, type, text)
					end
				end
			end
		end
	end	
	if ItemRefTooltip:IsShown() then
		HideUIPanel(ItemRefTooltip)
	end
	for k in pairs(registryTooltip) do
		registryTooltip[k].closeCurrent:Show()
		registryTooltip[k].closeAll:Show()
	end
	if not self.db.profile.enable then
		self:OnDisable()
	end
end

function ToolTipTabs:OnDisable()
	if enabled == 0 then
		return
	else
		enabled = 0
	end
	for k in pairs(registryTab) do
		if registryTab[k].link then
			k:Hide()
			registryTab[k] = {}
			if questTabs[k] then questTabs[k] = nil end	
		end
	end
	for k in pairs(registryTooltip) do
		registryTooltip[k].numTabs = 0
		registryTooltip[k].currentTab = nil
		registryTooltip[k].closeAll:Hide()
		registryTooltip[k].closeCurrent:Hide()
		k:Hide()
	end
	SetItemRef = oldSetItemRef
	oldSetItemRef = nil
end

