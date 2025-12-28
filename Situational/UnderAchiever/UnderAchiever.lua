local UnderAchiever,UA = ...;
UA.frame = CreateFrame("Frame","UnderAchieverFrame",UIParent);
UA.previous = {};
UA.player_list = {
	"Player",
	"Target",
	"Focus",
	"Party",
	"Raid",
	"None",
};

UA_Settings = {
	min_value = 7,
	min_type = 1,
	max_value = 14,
	max_type = 1,
	state = true,
	default = 1,
	saves = false,
	date = true,
	real = false,
	disable = false,
};

UA_Saves = {};

UA_Replacements = {
	epic = 556,
	naxx10 = 576,
	naxx25 = 577,
	os10 = 1876,
	os25 = 625,
	eoe10 = 622,
	eoe25 = 623,
	uld10 = 2894,
	uld25 = 2895,
	toc10 = 3917,
	toc25 = 3916,
	togc10 = 3918,
	togc25 = 3812,
	ony10 = 4396,
	ony25 = 4397,
	voa10 = 4585,
	voa25 = 4586,
	icc10 = 4532,
	icc10hc = 4636,
	icc25 = 4608,
	icc25hc = 4637,
	ewf10 = 4016,
	ewf25 = 4017,
	rs10 = 4817,
	rs10hc = 4818,
	rs25 = 4815,
	rs25hc = 4816,
	bwd = 4842,
	totfw = 4851,
	bot = 4850,
	tb = 5416,
	cepic = 5372,
};

UA_Exceptions_Disabled = {};

UA_Exceptions_Enabled = {};


function UA.print(msg,err)
	DEFAULT_CHAT_FRAME:AddMessage("\124cFFFFAD00[UnderAchiever]"..(err and " [Error]" or "")..": "..msg);
end


UA.frame:Hide();
UA.frame:SetWidth(530);
UA.frame:SetHeight(368);
UA.frame:SetPoint("CENTER",0,0);
table.insert(UISpecialFrames,"UnderAchieverFrame");
UA.frame:EnableMouse(true);
UA.frame:SetMovable(true);
UA.frame:SetFrameStrata("HIGH");
UA.frame:SetBackdrop({ 
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 32, edgeSize = 32, 
	insets = { left = 11, right = 11, top = 12, bottom = 10 }
});
UA.frame:SetScript("OnMouseDown",function(self) 
	self:StartMoving();
end);
UA.frame:SetScript("OnMouseUp",function(self) 
	self:StopMovingOrSizing();
end);
UA.frame.header = UA.frame:CreateTexture(nil, "ARTWORK");
UA.frame.header:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header");
UA.frame.header:SetWidth(300);
UA.frame.header:SetHeight(68);
UA.frame.header:SetPoint("TOP",0,12);
UA.frame.text = UA.frame:CreateFontString(nil, "ARTWORK", "GameFontNormal");
UA.frame.text:SetText("UnderAchiever");
UA.frame.text:SetPoint("TOP",UA.frame.header,0,-14);
UA.frame.close = CreateFrame("Button",nil,UA.frame,"UIPanelCloseButton");
UA.frame.close:SetPoint("TOPRIGHT",UA.frame,"TOPRIGHT",-4,-4);


UA.frame.tab1 = CreateFrame("Button","UnderAchieverFrameTab1",UA.frame,"CharacterFrameTabButtonTemplate");
UA.frame.tab1:SetPoint("TOPLEFT",UA.frame,"BOTTOMLEFT",0,6);
UA.frame.tab1:SetText("Options");
UA.frame.tab1.id = 1;
UA.frame.tab1:SetScript("OnClick",function()
	UA.frame.selectedTab = 1;
	PanelTemplates_UpdateTabs(UA.frame);
	UA.options:Show();
	UA.advanced:Hide();
	UA.replacements:Hide();
	UA.exceptions:Hide();
	UA.about:Hide();
end);

UA.frame.tab2 = CreateFrame("Button","UnderAchieverFrameTab2",UA.frame,"CharacterFrameTabButtonTemplate");
UA.frame.tab2:SetPoint("TOPLEFT",UA.frame.tab1,"TOPRIGHT",-12,0);
UA.frame.tab2:SetText("Advanced Faking");
UA.frame.tab2.id = 2;
UA.frame.tab2:SetScript("OnClick",function()
	UA.frame.selectedTab = 2;
	PanelTemplates_UpdateTabs(UA.frame);
	UA.options:Hide();
	UA.advanced:Show();
	UA.replacements:Hide();
	UA.exceptions:Hide();
	UA.about:Hide();
end);

UA.frame.tab3 = CreateFrame("Button","UnderAchieverFrameTab3",UA.frame,"CharacterFrameTabButtonTemplate");
UA.frame.tab3:SetPoint("TOPLEFT",UA.frame.tab2,"TOPRIGHT",-12,0);
UA.frame.tab3:SetText("Replacements");
UA.frame.tab3.id = 3;
UA.frame.tab3:SetScript("OnClick",function()
	UA.frame.selectedTab = 3;
	PanelTemplates_UpdateTabs(UA.frame);
	UA.options:Hide();
	UA.advanced:Hide();
	UA.replacements:Show();
	UA.exceptions:Hide();
	UA.about:Hide();
end);

UA.frame.tab4 = CreateFrame("Button","UnderAchieverFrameTab4",UA.frame,"CharacterFrameTabButtonTemplate");
UA.frame.tab4:SetPoint("TOPLEFT",UA.frame.tab3,"TOPRIGHT",-12,0);
UA.frame.tab4:SetText("Exceptions");
UA.frame.tab4.id = 4;
UA.frame.tab4:SetScript("OnClick",function()
	UA.frame.selectedTab = 4;
	PanelTemplates_UpdateTabs(UA.frame);
	UA.options:Hide();
	UA.advanced:Hide();
	UA.replacements:Hide();
	UA.exceptions:Show();
	UA.about:Hide();
end);

UA.frame.tab5 = CreateFrame("Button","UnderAchieverFrameTab5",UA.frame,"CharacterFrameTabButtonTemplate");
UA.frame.tab5:SetPoint("TOPLEFT",UA.frame.tab4,"TOPRIGHT",-12,0);
UA.frame.tab5:SetText("About");
UA.frame.tab5.id = 5;
UA.frame.tab5:SetScript("OnClick",function()
	UA.frame.selectedTab = 5;
	PanelTemplates_UpdateTabs(UA.frame);
	UA.options:Hide();
	UA.advanced:Hide();
	UA.replacements:Hide();
	UA.exceptions:Hide();
	UA.about:Show();
end);

PanelTemplates_SetNumTabs(UA.frame, 5);
UA.frame.selectedTab = 1;
PanelTemplates_UpdateTabs(UA.frame);


function UA.OnEvent(self, event, ...)
	if event == "ADDON_LOADED" then
		local name = ...;
		if name == "UnderAchiever" then
			if not UA_Settings.CA then
				UA.print("Welcome to UnderAchiever! Type \"/ua\" to see the options and other features.");
				UA_Settings.CA = true;
			end
			
			if UA_Settings.default == 1 then
				UA_Settings.state = true;
			elseif UA_Settings.default == 2 then
				UA_Settings.state = false;
			end
			UA.print("Automatic link faking is "..(UA_Settings.state and "enabled" or "disabled")..".");
			
			UA.frame:UnregisterEvent("ADDON_LOADED");
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		UA.GUID = strsub(UnitGUID("player"),3);
		UA.frame:UnregisterEvent("PLAYER_ENTERING_WORLD");
	end
end
UA.frame:SetScript("OnEvent",UA.OnEvent);
UA.frame:RegisterEvent("ADDON_LOADED");
UA.frame:RegisterEvent("PLAYER_ENTERING_WORLD");


function UA.OnSlash(msg)
	msg = msg and string.lower(msg) or "";
	if msg:find("on") or msg:find("enable") then
		UA_Settings.state = true;
		UA.print("Auto-faking enabled.");
	elseif msg:find("off") or msg:find("disable") then
		UA_Settings.state = false;
		UA.print("Auto-faking disabled.");
	else
		if UA.frame:IsShown() then
			HideUIPanel(UA.frame);
		else
			ShowUIPanel(UA.frame);
		end
	end
end
SLASH_UNDERACHIEVER1 = "/ua";
SLASH_UNDERACHIEVER2 = "/underachiever";
SlashCmdList["UNDERACHIEVER"] = UA.OnSlash;


function UA.fake(id)
	if (UA_Settings.state and not UA_Exceptions_Enabled[id]) or UA_Exceptions_Disabled[id] then
		if UA_Settings.real then
			return GetAchievementLink(id);
		else
			local _, name, _, complete = GetAchievementInfo(id);
			if complete and UA_Settings.date then
				return GetAchievementLink(id);
			elseif UA_Settings.saves and UA_Saves[id] then
				local unit = UA.player_list[UA_Saves[id].player];
				if unit == "Party" or unit == "Raid" then
					unit = unit..UA_Saves[id].unit;
				end
				if unit ~= "None" then
					guid = UnitGUID(unit);
				else
					guid = "FFFFFFFFFFFFFFFFFF";
				end
				if guid then 
					guid = strsub(guid,3);
				else
					guid = UA.GUID;
				end
				local num1,num2,num3,num4 = 0,0,0,0;
				for i=1,#UA_Saves[id].crits do
					if UA_Saves[id].crits[i] then
						if i <= 32 then
							num1 = num1 + 2^(i-1);
						elseif i <= 64 then
							num2 = num2 + 2^(i-1-32);
						elseif i <= 96 then
							num3 = num3 + 2^(i-1-64);
						elseif i <= 128 then
							num4 = num4 + 2^(i-1-96);
						end
					end
				end
				return "\124cffffff00\124Hachievement:"..id..":"..guid..":"..(UA_Saves[id].complete and "1" or "0")..":"..(UA_Saves[id].complete and UA_Saves[id].month or "0")..":"..(UA_Saves[id].complete and UA_Saves[id].day or "0")..":"..(UA_Saves[id].complete and UA_Saves[id].year or "0")..":"..num1..":"..num2..":"..num3..":"..num4.."\124h["..name.."]\124h\124r";
			else
				if not UA.previous[id] then
					local current = time();
					current = random(current - UA_Settings.max_value * 60 * 60 * 24 * (UA_Settings.max_type == 2 and 7 or UA_Settings.max_type == 3 and 30 or UA_Settings.max_type == 4 and 364 or 1), current - UA_Settings.min_value * 60 * 60 * 24 * (UA_Settings.min_type == 2 and 7 or UA_Settings.min_type == 3 and 30 or UA_Settings.min_type == 4 and 364 or 1));
					UA.previous[id] = {
						date("%d",current),
						date("%m",current),
						tonumber(date("%Y",current)) >= 2000 and date("%y",current) or 0,
					};
				end
				local num = GetAchievementNumCriteria(id);
				return "\124cffffff00\124Hachievement:"..id..":"..UA.GUID..":1:"..UA.previous[id][2]..":"..UA.previous[id][1]..":"..UA.previous[id][3]..":4294967295:"..(num > 32 and "4294967295" or "0")..":"..(num > 64 and "4294967295" or "0")..":"..(num > 96 and "4294967295" or "0").."\124h["..name.."]\124h\124r";
			end
		end
	end
end


local old_ChatEdit_InsertLink = ChatEdit_InsertLink;
function ChatEdit_InsertLink(link, ...)
	if link then
		local id = link:match("\124c%w%w%w%w%w%w%w%w\124Hachievement:(%-?%d-):%w-:%d-:%d-:%d-:%-?%d-:%d-:%d-:%d-:%d-\124h%[.-%]\124h\124r");
		if id and not(UA_Settings.disable and UnderAchieverAdvanced:IsShown()) then
			id = tonumber(id);
			link = UA.fake(id) or link;
		end
	end
	return old_ChatEdit_InsertLink(link, ...);
end


function UA.gsub(msg, ex)
	if UA_Replacements[msg] then
		ex = ex or "";
		return (UA.fake(UA_Replacements[msg]) or GetAchievementLink(UA_Replacements[msg]))..ex;
	end
end


local old_SendChatMessage = SendChatMessage;
function SendChatMessage(msg, ...)
	msg = msg:gsub("%%([^%s%%]+)",UA.gsub);
	return old_SendChatMessage(msg, ...);
end

local i=1;
while _G["ChatFrame"..i.."EditBox"] do
	local f = _G["ChatFrame"..i.."EditBox"];
	f:HookScript("OnChar",function(self)
		f:SetText(f:GetText():gsub("%%([^%s%%]+)([%s%%])",UA.gsub));
	end);
	i = i + 1;
end

UA.interface = CreateFrame("Frame");
UA.interface.name = "UnderAchiever";
UA.interface.launch = CreateFrame("Button","UnderAchieverInterfaceLaunch",UA.interface,"OptionsButtonTemplate");
UA.interface.launch:SetPoint("TOPLEFT",UA.interface,"TOPLEFT",15,-15);
UA.interface.launch:SetWidth(260);
UA.interface.launch:SetText("Click here to open UnderAchiever");
UA.interface.launch:SetScript("OnClick",function()
	InterfaceOptionsFrame.lastFrame = nil;
	HideUIPanel(InterfaceOptionsFrame);
	ShowUIPanel(UA.frame);
end);
InterfaceOptions_AddCategory(UA.interface);