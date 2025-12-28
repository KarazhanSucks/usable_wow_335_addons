local UnderAchiever,UA = ...;

UA.advanced = CreateFrame("Frame","UnderAchieverAdvanced",UA.frame);
UA.advanced:Hide();
UA.advanced:SetAllPoints(UA.frame);


UA.achi = 46;
UA.crits = {};
UA.day = date("%d");
UA.month = date("%m");
UA.year = date("%y");


UA.advanced.achievement = CreateFrame("Frame","UnderAchieverAdvancedAchievement",UA.advanced);
UA.advanced.achievement:SetPoint("TOPLEFT", UA.advanced, 15, -30);
UA.advanced.achievement:SetWidth(250);
UA.advanced.achievement:SetHeight(85);
UA.advanced.achievement:SetBackdrop({ 
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, 
	insets = { left = 5, right = 5, top = 5, bottom = 5 }
});

UA.advanced.player = CreateFrame("Frame","UnderAchieverAdvancedPlayer",UA.advanced);
UA.advanced.player:SetPoint("TOPLEFT", UA.advanced.achievement, "BOTTOMLEFT", 0, -5);
UA.advanced.player:SetPoint("RIGHT", UA.advanced.achievement, "RIGHT", 0, 0);
UA.advanced.player:SetHeight(40);
UA.advanced.player:SetBackdrop({ 
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, 
	insets = { left = 5, right = 5, top = 5, bottom = 5 }
});

UA.advanced.complete = CreateFrame("Frame","UnderAchieverAdvancedComplete",UA.advanced);
UA.advanced.complete:SetPoint("TOPLEFT", UA.advanced.achievement, "TOPRIGHT", 5, 0);
UA.advanced.complete:SetPoint("RIGHT", UA.advanced, "RIGHT", -15, 0);
UA.advanced.complete:SetPoint("BOTTOM", UA.advanced.player, "BOTTOM");
UA.advanced.complete:SetBackdrop({ 
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, 
	insets = { left = 5, right = 5, top = 5, bottom = 5 }
});

UA.advanced.scroll = CreateFrame("Frame","UnderAchieverAdvancedScroll",UA.advanced);
UA.advanced.scroll:SetPoint("TOPLEFT", UA.advanced.player, "BOTTOMLEFT", 0, -5);
UA.advanced.scroll:SetPoint("RIGHT", UA.advanced, "RIGHT", -15, 0);
UA.advanced.scroll:SetHeight(160);
UA.advanced.scroll:SetBackdrop({ 
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, 
	insets = { left = 5, right = 5, top = 5, bottom = 5 }
});


-- Achievement
UA.advanced.achievement.label = UA.advanced.achievement:CreateFontString("UnderAchieverAdvancedAchievementLabel", "ARTWORK", "GameFontHighlight");
UA.advanced.achievement.label:SetPoint("TOPLEFT", UA.advanced.achievement, 10, -10);
UA.advanced.achievement.label:SetText("Achievement ID:");

UA.advanced.achievement.edit = CreateFrame("EditBox","UnderAchieverAdvancedAchievementEdit",UA.advanced.achievement,"InputBoxTemplate");
UA.advanced.achievement.edit:SetPoint("TOPLEFT",UA.advanced.achievement.label,"TOPRIGHT",12,8);
UA.advanced.achievement.edit:SetWidth(60);
UA.advanced.achievement.edit:SetHeight(28);
UA.advanced.achievement.edit:SetHistoryLines(1);
UA.advanced.achievement.edit:SetAutoFocus(false);
UA.advanced.achievement.edit:SetText(UA.achi);

UA.advanced.achievement.set = CreateFrame("Button","UnderAchieverAdvancedAchievementSet",UA.advanced.achievement,"OptionsButtonTemplate");
UA.advanced.achievement.set:SetPoint("TOPLEFT",UA.advanced.achievement.edit,"TOPRIGHT",6,-4);
UA.advanced.achievement.set:SetWidth(50);
UA.advanced.achievement.set:SetText("Set");

UA.advanced.achievement.selected = CreateFrame("Button","UnderAchieverAdvancedAchievementSelected",UA.advanced.achievement,"OptionsButtonTemplate");
UA.advanced.achievement.selected:SetPoint("TOPLEFT",UA.advanced.achievement.label,"BOTTOMLEFT",0,-10);
UA.advanced.achievement.selected:SetPoint("RIGHT",UA.advanced.achievement.set,"RIGHT");
UA.advanced.achievement.selected:SetText("Selection in achievement list");

UA.advanced.achievement.current = CreateFrame("Button","UnderAchieverAdvancedAchievementCurrent",UA.advanced.achievement,"OptionsButtonTemplate");
UA.advanced.achievement.current:SetPoint("TOPLEFT",UA.advanced.achievement.selected,"BOTTOMLEFT",0,-2);
UA.advanced.achievement.current:SetPoint("RIGHT",UA.advanced.achievement.set,"RIGHT");
UA.advanced.achievement.current:SetText("Get from link in current message");


-- Player
UA.advanced.player.label = UA.advanced.player:CreateFontString("UnderAchieverAdvancedPlayerLabel", "ARTWORK", "GameFontHighlight");
UA.advanced.player.label:SetPoint("TOPLEFT",UA.advanced.player,"TOPLEFT",10,-12);
UA.advanced.player.label:SetText("Player:");

UA.advanced.player.dropdown = CreateFrame("Frame", "UnderAchieverAdvancedPlayerDropdown", UA.advanced.player, "UIDropDownMenuTemplate");
UA.advanced.player.dropdown:ClearAllPoints();
UA.advanced.player.dropdown:SetPoint("TOPLEFT", UA.advanced.player.label, "TOPRIGHT", 0, 6);
UA.advanced.player.dropdown:Show();
UIDropDownMenu_SetWidth(UnderAchieverAdvancedPlayerDropdown, 100);
UIDropDownMenu_SetButtonWidth(UnderAchieverAdvancedPlayerDropdown, 124);
UIDropDownMenu_JustifyText(UnderAchieverAdvancedPlayerDropdown, "LEFT");

UA.advanced.player.edit = CreateFrame("EditBox","UnderAchieverAdvancedPlayerEdit",UA.advanced.player,"InputBoxTemplate");
UA.advanced.player.edit:SetWidth(30);
UA.advanced.player.edit:SetHeight(28);
UA.advanced.player.edit:SetHistoryLines(1);
UA.advanced.player.edit:SetPoint("TOPLEFT",UA.advanced.player.dropdown,"TOPRIGHT",5,0);
UA.advanced.player.edit:SetAutoFocus(false);
UA.advanced.player.edit:SetText(1);
UA.advanced.player.edit:Hide();


-- Scroll
UA.advanced.scroll.label = UA.advanced.scroll:CreateFontString("UnderAchieverAdvancedScrollLabel", "ARTWORK", "GameFontNormal");
UA.advanced.scroll.label:SetPoint("TOPLEFT",UA.advanced.scroll,"TOPLEFT",10,-10);
UA.advanced.scroll.label:SetPoint("RIGHT",UA.advanced.scroll,"RIGHT",-10,-10);
UA.advanced.scroll.label:SetJustifyH("LEFT");

UA.advanced.containers = {};
for i=1,5 do
	UA.advanced.containers[i] = CreateFrame("Frame","UnderAchieverAdvancedScrollContainer"..i,UA.advanced.scroll);
	UA.advanced.containers[i]:SetWidth(340);
	UA.advanced.containers[i]:SetHeight(24);
	if i==1 then
		UA.advanced.containers[i]:SetPoint("TOPLEFT",UA.advanced.scroll.label,"BOTTOMLEFT",0,-5);
	else
		UA.advanced.containers[i]:SetPoint("TOPLEFT",UA.advanced.containers[i-1],"BOTTOMLEFT",0,0);
	end
	UA.advanced.containers[i].check = CreateFrame("CheckButton","UnderAchieverAdvancedScrollContainer"..i.."Check",UA.advanced.containers[i],"UICheckButtonTemplate");
	UA.advanced.containers[i].check:SetPoint("TOPLEFT",UA.advanced.containers[i],"TOPLEFT");
	UA.advanced.containers[i].label = UA.advanced.containers[i]:CreateFontString("UnderAchieverAdvancedScrollContainer"..i.."Label", "ARTWORK", "GameFontHighlight");
	UA.advanced.containers[i].label:SetPoint("TOPLEFT",UA.advanced.containers[i].check,"TOPRIGHT",2,-8);
	UA.advanced.containers[i].label:SetPoint("RIGHT",UA.advanced.containers[i],"RIGHT");
	UA.advanced.containers[i].label:SetText(" ");
	UA.advanced.containers[i].label:SetJustifyH("LEFT");
	UA.advanced.containers[i].check:SetScript("OnClick",function(self)
		self = self:GetParent();
		UA.crits[self.id] = not UA.crits[self.id];
		self.check:SetChecked(UA.crits[self.id]);
		self.label:SetTextColor(1,1,1,UA.crits[self.id] and 1 or 0.5);
	end);
end

UA.advanced.scroll.frame = CreateFrame("ScrollFrame","UnderAchieverAdvancedScrollFrame",UA.advanced.scroll,"FauxScrollFrameTemplate");
UA.advanced.scroll.frame:SetPoint("TOPRIGHT",UA.advanced.containers[1],"TOPRIGHT",0,0);
UA.advanced.scroll.frame:SetPoint("BOTTOMLEFT",UA.advanced.containers[5],"BOTTOMLEFT",0,0);

UA.advanced.scroll.buttons = CreateFrame("Frame","UnderAchieverAdvancedScrollButtons",UA.advanced.scroll);
UA.advanced.scroll.buttons:SetAllPoints(UA.advanced.scroll);

UA.advanced.scroll.buttons.all = CreateFrame("Button","UnderAchieverAdvancedScrollButtonsAll",UA.advanced.scroll.buttons,"OptionsButtonTemplate");
UA.advanced.scroll.buttons.all:SetPoint("TOPLEFT",UA.advanced.scroll.frame,"TOPRIGHT",25,0);
UA.advanced.scroll.buttons.all:SetPoint("RIGHT",UA.advanced.scroll.buttons,"RIGHT",-10,0);
UA.advanced.scroll.buttons.all:SetText("Select All");

UA.advanced.scroll.buttons.none = CreateFrame("Button","UnderAchieverAdvancedScrollButtonsNone",UA.advanced.scroll.buttons,"OptionsButtonTemplate");
UA.advanced.scroll.buttons.none:SetPoint("TOPLEFT",UA.advanced.scroll.buttons.all,"BOTTOMLEFT",0,0);
UA.advanced.scroll.buttons.none:SetPoint("RIGHT",UA.advanced.scroll.buttons,"RIGHT",-10,0);
UA.advanced.scroll.buttons.none:SetText("Select None");

UA.advanced.scroll.buttons.invert = CreateFrame("Button","UnderAchieverAdvancedScrollButtonsInvert",UA.advanced.scroll.buttons,"OptionsButtonTemplate");
UA.advanced.scroll.buttons.invert:SetPoint("TOPLEFT",UA.advanced.scroll.buttons.none,"BOTTOMLEFT",0,0);
UA.advanced.scroll.buttons.invert:SetPoint("RIGHT",UA.advanced.scroll.buttons,"RIGHT",-10,0);
UA.advanced.scroll.buttons.invert:SetText("Invert Selection");

UA.advanced.scroll.buttons.real = CreateFrame("Button","UnderAchieverAdvancedScrollButtonsReal",UA.advanced.scroll.buttons,"OptionsButtonTemplate");
UA.advanced.scroll.buttons.real:SetPoint("TOPLEFT",UA.advanced.scroll.buttons.invert,"BOTTOMLEFT",0,0);
UA.advanced.scroll.buttons.real:SetPoint("RIGHT",UA.advanced.scroll.buttons,"RIGHT",-10,0);
UA.advanced.scroll.buttons.real:SetText("Real Completed");

UA.advanced.scroll.buttons.data = CreateFrame("Button","UnderAchieverAdvancedScrollButtonsData",UA.advanced.scroll.buttons,"OptionsButtonTemplate");
UA.advanced.scroll.buttons.data:SetPoint("TOPLEFT",UA.advanced.scroll.buttons.real,"BOTTOMLEFT",0,0);
UA.advanced.scroll.buttons.data:SetPoint("RIGHT",UA.advanced.scroll.buttons,"RIGHT",-10,0);
UA.advanced.scroll.buttons.data:SetText("Get from link");


-- Complete
UA.advanced.complete.check = CreateFrame("CheckButton","UnderAchieverAdvancedCompleteCheck",UA.advanced.complete,"UICheckButtonTemplate");
UA.advanced.complete.check:SetPoint("TOPLEFT",UA.advanced.complete,"TOPLEFT",10,-6);
UA.advanced.complete.check:SetChecked(true);

UA.advanced.complete.label = UA.advanced.complete:CreateFontString("UnderAchieverAdvancedCompleteLabel", "ARTWORK", "GameFontHighlight");
UA.advanced.complete.label:SetPoint("TOPLEFT",UA.advanced.complete.check,"TOPRIGHT",2,-8);
UA.advanced.complete.label:SetText("Completed");

UA.advanced.complete.options = CreateFrame("Frame","UnderAchieverAdvancedCompleteOptions",UA.advanced.complete);
UA.advanced.complete.options:SetAllPoints(UA.advanced.complete);

UA.advanced.complete.options.dayLabel = UA.advanced.complete.options:CreateFontString("UnderAchieverAdvancedCompleteOptionsDayLabel", "ARTWORK", "GameFontHighlight");
UA.advanced.complete.options.dayLabel:SetText("Day:");
UA.advanced.complete.options.dayLabel:SetPoint("TOPLEFT", UA.advanced.complete.check, "TOPLEFT", 8, -42);
UA.advanced.complete.options.dayLabel:SetWidth(50);
UA.advanced.complete.options.dayLabel:SetJustifyH("RIGHT");

UA.advanced.complete.options.dayEdit = CreateFrame("EditBox","UnderAchieverAdvancedCompleteOptionsDayEdit",UA.advanced.complete.options,"InputBoxTemplate");
UA.advanced.complete.options.dayEdit:SetWidth(30);
UA.advanced.complete.options.dayEdit:SetHeight(28);
UA.advanced.complete.options.dayEdit:SetHistoryLines(1);
UA.advanced.complete.options.dayEdit:SetPoint("TOPLEFT",UA.advanced.complete.options.dayLabel,"TOPLEFT",60,7);
UA.advanced.complete.options.dayEdit:SetAutoFocus(false);
UA.advanced.complete.options.dayEdit:SetText(UA.day);

UA.advanced.complete.options.monthLabel = UA.advanced.complete.options:CreateFontString("UnderAchieverAdvancedCompleteOptionsMonthLabel", "ARTWORK", "GameFontHighlight");
UA.advanced.complete.options.monthLabel:SetText("Month:");
UA.advanced.complete.options.monthLabel:SetPoint("TOPLEFT", UA.advanced.complete.options.dayLabel, "BOTTOMLEFT", 0, -10);
UA.advanced.complete.options.monthLabel:SetWidth(50);
UA.advanced.complete.options.monthLabel:SetJustifyH("RIGHT");

UA.advanced.complete.options.monthEdit = CreateFrame("EditBox","UnderAchieverAdvancedCompleteOptionsMonthEdit",UA.advanced.complete.options,"InputBoxTemplate");
UA.advanced.complete.options.monthEdit:SetWidth(30);
UA.advanced.complete.options.monthEdit:SetHeight(28);
UA.advanced.complete.options.monthEdit:SetHistoryLines(1);
UA.advanced.complete.options.monthEdit:SetPoint("TOPLEFT",UA.advanced.complete.options.monthLabel,"TOPLEFT",60,7);
UA.advanced.complete.options.monthEdit:SetAutoFocus(false);
UA.advanced.complete.options.monthEdit:SetText(UA.month);

UA.advanced.complete.options.yearLabel = UA.advanced.complete.options:CreateFontString("UnderAchieverAdvancedCompleteOptionsYearLabel", "ARTWORK", "GameFontHighlight");
UA.advanced.complete.options.yearLabel:SetText("Year:");
UA.advanced.complete.options.yearLabel:SetPoint("TOPLEFT", UA.advanced.complete.options.monthLabel, "BOTTOMLEFT", 0, -10);
UA.advanced.complete.options.yearLabel:SetWidth(50);
UA.advanced.complete.options.yearLabel:SetJustifyH("RIGHT");

UA.advanced.complete.options.yearEdit = CreateFrame("EditBox","UnderAchieverAdvancedCompleteOptionsYearEdit",UA.advanced.complete.options,"InputBoxTemplate");
UA.advanced.complete.options.yearEdit:SetWidth(30);
UA.advanced.complete.options.yearEdit:SetHeight(28);
UA.advanced.complete.options.yearEdit:SetHistoryLines(1);
UA.advanced.complete.options.yearEdit:SetPoint("TOPLEFT",UA.advanced.complete.options.yearLabel,"TOPLEFT",60,7);
UA.advanced.complete.options.yearEdit:SetAutoFocus(false);
UA.advanced.complete.options.yearEdit:SetText(UA.year);

UA.advanced.complete.options.random = CreateFrame("Button","UnderAchieverAdvancedCompleteOptionsRandom",UA.advanced.complete.options,"OptionsButtonTemplate");
UA.advanced.complete.options.random:SetPoint("TOPLEFT",UA.advanced.complete.options.dayLabel,"TOPRIGHT",50,15);
UA.advanced.complete.options.random:SetPoint("RIGHT",UA.advanced.complete.options,"RIGHT",-10,0);
UA.advanced.complete.options.random:SetText("Randomise Date");

UA.advanced.complete.options.today = CreateFrame("Button","UnderAchieverAdvancedCompleteOptionsToday",UA.advanced.complete.options,"OptionsButtonTemplate");
UA.advanced.complete.options.today:SetPoint("TOPLEFT",UA.advanced.complete.options.random,"BOTTOMLEFT",0,0);
UA.advanced.complete.options.today:SetPoint("RIGHT",UA.advanced.complete.options,"RIGHT",-10,0);
UA.advanced.complete.options.today:SetText("Today's Date");

UA.advanced.complete.date = CreateFrame("Button","UnderAchieverAdvancedCompleteDate",UA.advanced.complete,"OptionsButtonTemplate");
UA.advanced.complete.date:SetPoint("TOPLEFT",UA.advanced.complete.options.today,"BOTTOMLEFT",0,0);
UA.advanced.complete.date:SetPoint("RIGHT",UA.advanced.complete,"RIGHT",-10,0);
UA.advanced.complete.date:SetText("Real Date");

UA.advanced.complete.link = CreateFrame("Button","UnderAchieverAdvancedCompleteLink",UA.advanced.complete,"OptionsButtonTemplate");
UA.advanced.complete.link:SetPoint("TOPLEFT",UA.advanced.complete.date,"BOTTOMLEFT",0,0);
UA.advanced.complete.link:SetPoint("RIGHT",UA.advanced.complete,"RIGHT",-10,0);
UA.advanced.complete.link:SetText("Get from link");


-- Creation
UA.advanced.chat = CreateFrame("Button","UnderAchieverAdvancedChat",UA.advanced,"OptionsButtonTemplate");
UA.advanced.chat:SetPoint("TOPLEFT",UA.advanced.scroll,"BOTTOMLEFT",-1,-5);
UA.advanced.chat:SetWidth(125);
UA.advanced.chat:SetText("Add to message");

UA.advanced.print = CreateFrame("Button","UnderAchieverAdvancedPrint",UA.advanced,"OptionsButtonTemplate");
UA.advanced.print:SetPoint("TOPLEFT",UA.advanced.chat,"TOPRIGHT",0,0);
UA.advanced.print:SetWidth(125);
UA.advanced.print:SetText("Test this link");

UA.advanced.save = CreateFrame("Button","UnderAchieverAdvancedSave",UA.advanced,"OptionsButtonTemplate");
UA.advanced.save:SetPoint("TOPLEFT",UA.advanced.print,"TOPRIGHT",10,0);
UA.advanced.save:SetWidth(80);
UA.advanced.save:SetText("Save");

UA.advanced.load = CreateFrame("Button","UnderAchieverAdvancedLoad",UA.advanced,"OptionsButtonTemplate");
UA.advanced.load:SetPoint("TOPLEFT",UA.advanced.save,"TOPRIGHT",0,0);
UA.advanced.load:SetWidth(80);
UA.advanced.load:SetText("Load");

UA.advanced.delete = CreateFrame("Button","UnderAchieverAdvancedDelete",UA.advanced,"OptionsButtonTemplate");
UA.advanced.delete:SetPoint("TOPLEFT",UA.advanced.load,"TOPRIGHT",0,0);
UA.advanced.delete:SetWidth(80);
UA.advanced.delete:SetText("Delete");


-- Scroll script
function UA.advanced_scroll_update()
	local line;
	local offset = FauxScrollFrame_GetOffset(UnderAchieverAdvancedScrollFrame);
	local lineplusoffset;
	local total = #UA.crits;
	FauxScrollFrame_Update(UnderAchieverAdvancedScrollFrame,total,5,24);
	for line=1,5 do
		lineplusoffset = line + offset;
		if lineplusoffset <= total then
			UA.advanced.containers[line].label:SetText(GetAchievementCriteriaInfo(UA.achi,lineplusoffset));
			UA.advanced.containers[line].label:SetTextColor(1,1,1,UA.crits[lineplusoffset] and 1 or 0.5);
			UA.advanced.containers[line].check:SetChecked(UA.crits[lineplusoffset]);
			UA.advanced.containers[line].id = lineplusoffset;
			UA.advanced.containers[line]:Show();
		else
			UA.advanced.containers[line]:Hide();
		end
	end
end

UA.advanced.scroll.frame:SetScript("OnVerticalScroll",function(self, offset)
	FauxScrollFrame_OnVerticalScroll(self, offset, 24, UA.advanced_scroll_update);
end);


-- Achievement scripts
function UA.achi_update()
	UA.crits = {};
	if GetAchievementInfo(UA.achi) then
		for i=1,GetAchievementNumCriteria(UA.achi) do
			UA.crits[i] = true;
		end
	end
	local name = select(2,GetAchievementInfo(UA.achi));
	if name then
		UA.advanced.scroll.label:SetTextColor(1.0,0.82,0,1);
		UA.advanced.scroll.buttons:Show();
	else
		UA.advanced.scroll.label:SetTextColor(1,0,0,1);
		UA.advanced.scroll.buttons:Hide();
	end
	UA.advanced.scroll.label:SetText(name or "Achievement doesn't exist");
	if UA_Saves[UA.achi] then
		UA.advanced.load:Enable();
		UA.advanced.delete:Enable();
	else
		UA.advanced.load:Disable();
		UA.advanced.delete:Disable();
	end
	UA.advanced_scroll_update();
end
UA.achi_update();

UA.advanced.achievement.edit:SetScript("OnEscapePressed",function(self) 
	self:ClearFocus();
	self:SetText(UA.achi);
end);

UA.advanced.achievement.edit:SetScript("OnEnterPressed",function(self) 
	self:ClearFocus();
	UA.achi = tonumber(self:GetText() or "") or 0;
	UA.achi_update();
end);

UA.advanced.achievement.set:SetScript("OnClick",function()
	UA.advanced.achievement.edit:ClearFocus();
	UA.achi = tonumber(UA.advanced.achievement.edit:GetText() or "") or 0;
	UA.achi_update();
end);

UA.advanced.achievement.selected:SetScript("OnClick",function()
	UA.advanced.achievement.edit:ClearFocus();
	if AchievementFrame then
		AchievementFrameAchievements_FindSelection();
		local selected;
		for k,v in pairs(AchievementFrameAchievementsContainer.buttons) do
			if v.selected then
				selected = v.id;
				break;
			end
		end
		if selected then
			UA.advanced.achievement.edit:SetText(selected);
			UA.achi = selected;
			UA.achi_update();
		else
			UA.print("Cannot find a selected achievement in the achievements list.",true);
		end
	else
		UA.print("Achievement list not loaded, therefore no achievement is selected.",true);
	end
end);

UA.advanced.achievement.current:SetScript("OnClick",function()
	UA.advanced.achievement.edit:ClearFocus();
	local active = ChatEdit_GetActiveWindow();
	if active then
		local msg = " "..active:GetText();
		local id = msg:match("^.+\124c%w%w%w%w%w%w%w%w\124Hachievement:(%-?%d-):%w-:%d-:%d-:%d-:%-?%d-:%d-:%d-:%d-:%d-\124h%[.-%]\124h\124r");
		if id then
			id = tonumber(id);
			UA.advanced.achievement.edit:SetText(id);
			UA.achi = id;
			UA.achi_update();
		else
			UA.print("Cannot find an achievement link in the chat edit box.",true);
		end
	end
end);


-- Player scripts
UA.advanced.player.edit:SetScript("OnEnterPressed",function(self)
	self:ClearFocus();
end);

function UA.player_click(self)
	local id = self:GetID();
	UIDropDownMenu_SetSelectedID(UnderAchieverAdvancedPlayerDropdown, id);
	if id == 4 or id == 5 then
		UA.advanced.player.edit:Show();
	else
		UA.advanced.player.edit:Hide();
	end
end

function UA.player_init(self, level)
	local info;
	for k,v in ipairs(UA.player_list) do
		info = UIDropDownMenu_CreateInfo();
		info.text = v;
		info.value = v;
		info.func = UA.player_click;
		UIDropDownMenu_AddButton(info, level);
	end
end
UIDropDownMenu_Initialize(UnderAchieverAdvancedPlayerDropdown, UA.player_init);
UIDropDownMenu_SetSelectedID(UnderAchieverAdvancedPlayerDropdown, 1);


-- Complete scripts
UA.advanced.complete.check:SetScript("OnClick",function(self)
	self:SetChecked(self:GetChecked() == 1 and true or false);
	if self:GetChecked() then
		UA.advanced.complete.options:Show();
	else
		UA.advanced.complete.options:Hide();
	end
end);

UA.advanced.complete.options.dayEdit:SetScript("OnEnterPressed",function(self)
	self:ClearFocus();
end);

UA.advanced.complete.options.monthEdit:SetScript("OnEnterPressed",function(self)
	self:ClearFocus();
end);

UA.advanced.complete.options.yearEdit:SetScript("OnEnterPressed",function(self)
	self:ClearFocus();
end);

UA.advanced.complete.options.random:SetScript("OnClick",function()
	local current = time();
	current = random(current - UA_Settings.max_value * 60 * 60 * 24 * (UA_Settings.max_type == 2 and 7 or UA_Settings.max_type == 3 and 30 or UA_Settings.max_type == 4 and 364 or 1), current - UA_Settings.min_value * 60 * 60 * 24 * (UA_Settings.min_type == 2 and 7 or UA_Settings.min_type == 3 and 30 or UA_Settings.min_type == 4 and 364 or 1));
	local day,month,year,year_check = date("%d",current), date("%m",current), date("%y",current), tonumber(date("%Y",current));
	UA.advanced.complete.options.dayEdit:SetText(day);
	UA.advanced.complete.options.monthEdit:SetText(month);
	UA.advanced.complete.options.yearEdit:SetText(year_check >= 2000 and year or 0);
end);

UA.advanced.complete.options.today:SetScript("OnClick",function()
	UA.advanced.complete.options.dayEdit:SetText(UA.day);
	UA.advanced.complete.options.monthEdit:SetText(UA.month);
	UA.advanced.complete.options.yearEdit:SetText(UA.year);
end);

UA.advanced.complete.date:SetScript("OnClick",function()
	local _, name, _, complete, month, day, year = GetAchievementInfo(UA.achi);
	if name then
		if complete then
			UA.advanced.complete.check:SetChecked(true);
			UA.advanced.complete.options:Show();
			UA.advanced.complete.options.dayEdit:SetText(day);
			UA.advanced.complete.options.monthEdit:SetText(month);
			UA.advanced.complete.options.yearEdit:SetText(year);
		else
			UA.advanced.complete.check:SetChecked(false);
			UA.advanced.complete.options:Hide();
		end
	else
		UA.print("Achievement doesn't exist.",true);
	end
end);


UA.advanced.complete.link:SetScript("OnClick",function()
	local active = ChatEdit_GetActiveWindow();
	if active then
		local msg = " "..active:GetText();
		local id,completed,month,day,year = msg:match("^.+\124c%w%w%w%w%w%w%w%w\124Hachievement:(%-?%d-):%w-:(%d-):(%d-):(%d-):(%-?%d-):%d-:%d-:%d-:%d-\124h%[.-%]\124h\124r");
		if id and completed and day and month and year then
			if completed == "1" then
				UA.advanced.complete.check:SetChecked(true);
				UA.advanced.complete.options:Show();
				UA.advanced.complete.options.dayEdit:SetText(day);
				UA.advanced.complete.options.monthEdit:SetText(month);
				UA.advanced.complete.options.yearEdit:SetText(year);
			else
				UA.advanced.complete.check:SetChecked(false);
				UA.advanced.complete.options:Hide();
			end
		else
			UA.print("Cannot find an achievement link in the chat edit box.",true);
		end
	end
end);


-- Select scripts
UA.advanced.scroll.buttons.all:SetScript("OnClick",function()
	for i=1,#UA.crits do
		UA.crits[i] = true;
	end
	UA.advanced_scroll_update();
end);

UA.advanced.scroll.buttons.none:SetScript("OnClick",function()
	for i=1,#UA.crits do
		UA.crits[i] = false;
	end
	UA.advanced_scroll_update();
end);

UA.advanced.scroll.buttons.invert:SetScript("OnClick",function()
	for i=1,#UA.crits do
		UA.crits[i] = not UA.crits[i];
	end
	UA.advanced_scroll_update();
end);

UA.advanced.scroll.buttons.real:SetScript("OnClick",function()
	if GetAchievementInfo(UA.achi) then
		for i=1,#UA.crits do
			UA.crits[i] = select(3,GetAchievementCriteriaInfo(UA.achi,i));
		end
		UA.advanced_scroll_update();
	else
		UA.print("Achievement doesn't exist.",true);
	end
end);

UA.advanced.scroll.buttons.data:SetScript("OnClick",function()
	local active = ChatEdit_GetActiveWindow();
	if active then
		local msg = " "..active:GetText();
		local id,num1,num2,num3,num4 = msg:match("^.+\124c%w%w%w%w%w%w%w%w\124Hachievement:(%-?%d-):%w-:%d-:%d-:%d-:%-?%d-:(%d-):(%d-):(%d-):(%d-)\124h%[.-%]\124h\124r");
		if id and num1 and num2 and num3 and num4 then
			for k,v in pairs(UA.crits) do
				local value = 0;
				local data = 0;
				if k <= 32 then
					value = 2^(k-1);
					data = num1;
				elseif k <= 64 then
					value = 2^(k-1-32);
					data = num2;
				elseif k <= 96 then
					value = 2^(k-1-64);
					data = num3;
				elseif k <= 128 then
					value = 2^(k-1-96);
					data = num4
				end
				UA.crits[k] = bit.band(value, data) > 0 and true or false;
			end
			UA.advanced_scroll_update();
		else
			UA.print("Cannot find an achievement link in the chat edit box.",true);
		end
	end
end);


-- Creation scripts
function UA.link(arg)
	local name = select(2,GetAchievementInfo(UA.achi));
	if name then
		local unit = UA.player_list[UIDropDownMenu_GetSelectedID(UnderAchieverAdvancedPlayerDropdown)];
		if unit == "Party" or unit == "Raid" then
			unit = unit..UA.advanced.player.edit:GetText();
		end
		local guid;
		if unit ~= "None" then
			guid = UnitGUID(unit);
		else
			guid = "FFFFFFFFFFFFFFFFFF";
		end
		if guid then
			local num1,num2,num3,num4 = 0,0,0,0;
			for i=1,#UA.crits do
				if UA.crits[i] then
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
			local day,month,year = tonumber(UA.advanced.complete.options.dayEdit:GetText()), tonumber(UA.advanced.complete.options.monthEdit:GetText()), tonumber(UA.advanced.complete.options.yearEdit:GetText());
			if not day then
				day = UA.day;
				UA.advanced.complete.options.dayEdit:SetText(day);
			end
			if not month then
				month = UA.month;
				UA.advanced.complete.options.monthEdit:SetText(month);
			end
			if not year then
				year = UA.year;
				UA.advanced.complete.options.yearEdit:SetText(year);
			end
			local complete = UA.advanced.complete.check:GetChecked();
			local link = "\124cffffff00\124Hachievement:"..UA.achi..":"..strsub(guid,3)..":"..(complete and "1" or "0")..":"..(complete and UnderAchieverAdvancedCompleteOptionsMonthEdit:GetText() or "0")..":"..(complete and UnderAchieverAdvancedCompleteOptionsDayEdit:GetText() or "0")..":"..(complete and UnderAchieverAdvancedCompleteOptionsYearEdit:GetText() or "0")..":"..num1..":"..num2..":"..num3..":"..num4.."\124h["..name.."]\124h\124r";
			if arg then
				local active = ChatEdit_GetActiveWindow();
				if not active then
					active = ChatEdit_GetLastActiveWindow();
					ChatEdit_ActivateChat(active);
				end
				active:Insert(link);
			else
				UA.print(link);
			end
		else
			UA.print("Invalid player.",true);
		end
	else
		UA.print("Invalid achievement.",true);
	end
end

UA.advanced.chat:SetScript("OnClick",function()
	UA.link(true);
end);

UA.advanced.print:SetScript("OnClick",function()
	UA.link(false);
end);

UA.advanced.save:SetScript("OnClick",function()
	local name = select(2,GetAchievementInfo(UA.achi));
	if name then
		UA_Saves[UA.achi] = {
			crits = {},
			complete = UA.advanced.complete.check:GetChecked() and true or false,
			day = UA.advanced.complete.options.dayEdit:GetText(),
			month = UA.advanced.complete.options.monthEdit:GetText(),
			year = UA.advanced.complete.options.yearEdit:GetText(),
			player = UIDropDownMenu_GetSelectedID(UnderAchieverAdvancedPlayerDropdown),
			unit = UA.advanced.player.edit:GetText(),
		};
		for k,v in pairs(UA.crits) do
			UA_Saves[UA.achi].crits[k] = v;
		end
		UA.advanced.load:Enable();
		UA.advanced.delete:Enable();
		UA.print("Link saved.");
	else
		UA.print("Invalid achievement.",true);
	end
end);

UA.advanced.load:SetScript("OnClick",function()
	if UA_Saves[UA.achi] then
		UA.crits = {};
		for k,v in pairs(UA_Saves[UA.achi].crits) do
			UA.crits[k] = v;
		end
		UA.advanced_scroll_update();
		UA.advanced.complete.check:SetChecked(UA_Saves[UA.achi].complete);
		if UA.advanced.complete.check:GetChecked() then
			UA.advanced.complete.options:Show();
		else
			UA.advanced.complete.options:Hide();
		end
		if UA_Saves[UA.achi].player == 4 or UA_Saves[UA.achi].player == 5 then
			UA.advanced.player.edit:Show();
		else
			UA.advanced.player.edit:Hide();
		end
		UA.advanced.complete.options.dayEdit:SetText(UA_Saves[UA.achi].day);
		UA.advanced.complete.options.monthEdit:SetText(UA_Saves[UA.achi].month);
		UA.advanced.complete.options.yearEdit:SetText(UA_Saves[UA.achi].year);
		UIDropDownMenu_SetSelectedID(UnderAchieverAdvancedPlayerDropdown, UA_Saves[UA.achi].player);
		UIDropDownMenu_SetText(UnderAchieverAdvancedPlayerDropdown, UA.player_list[UA_Saves[UA.achi].player]);
		UA.advanced.player.edit:SetText(UA_Saves[UA.achi].unit);
	else
		UA.print("You have no save for the current achievement.",true);
	end
end);

UA.advanced.delete:SetScript("OnClick",function(self)
	if UA_Saves[UA.achi] then
		UA_Saves[UA.achi] = nil;
		UA.advanced.load:Disable();
		UA.advanced.delete:Disable();
	else
		UA.print("Save doesn't exist.",true);
	end
end);

UA.advanced:SetScript("OnShow",function()
	UIDropDownMenu_SetText(UnderAchieverAdvancedPlayerDropdown, UA.player_list[UIDropDownMenu_GetSelectedID(UnderAchieverAdvancedPlayerDropdown)]);
	if UA_Saves[UA.achi] then
		UA.advanced.load:Enable();
		UA.advanced.delete:Enable();
	else
		UA.advanced.load:Disable();
		UA.advanced.delete:Disable();
	end
end);