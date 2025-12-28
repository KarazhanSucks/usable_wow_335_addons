local UnderAchiever,UA = ...;

UA.exceptions = CreateFrame("Frame","UnderAchieverExceptions",UA.frame);
UA.exceptions:Hide();
UA.exceptions:SetAllPoints(UA.frame);


-- While off, fake
UA.exceptions.disabled = CreateFrame("Frame","UnderAchieverExceptionsDisabled",UA.exceptions);
UA.exceptions.disabled:SetPoint("TOPLEFT", UA.exceptions, 15, -30);
UA.exceptions.disabled:SetPoint("RIGHT", UA.exceptions, "RIGHT", -15, 0);
UA.exceptions.disabled:SetHeight(145);
UA.exceptions.disabled:SetBackdrop({ 
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, 
	insets = { left = 5, right = 5, top = 5, bottom = 5 }
});

UA.exceptions.disabled.label = UA.exceptions.disabled:CreateFontString("UnderAchieverExceptionsDisabledLabel", "ARTWORK", "GameFontHighlight");
UA.exceptions.disabled.label:SetPoint("TOPLEFT", UA.exceptions.disabled, 10, -10);
UA.exceptions.disabled.label:SetText("Whilst auto-faking is disabled, keep faking these achievements:");

UA.disabled = {};
for i=1,5 do
	UA.disabled[i] = CreateFrame("Frame","UnderAchieverExceptionsDisabledContainer"..i,UA.exceptions.disabled);
	UA.disabled[i]:SetWidth(365);
	UA.disabled[i]:SetHeight(24);
	if i==1 then
		UA.disabled[i]:SetPoint("TOPLEFT",UA.exceptions.disabled.label,"BOTTOMLEFT",10,-5);
	else
		UA.disabled[i]:SetPoint("TOPLEFT",UA.disabled[i-1],"BOTTOMLEFT",0,0);
	end
	UA.disabled[i].achi = UA.disabled[i]:CreateFontString("UnderAchieverExceptionsDisabledContainer"..i.."Achi", "ARTWORK", "GameFontNormal");
	UA.disabled[i].achi:SetPoint("TOPLEFT",UA.disabled[i],"TOPLEFT",0,0);
	UA.disabled[i].achi:SetWidth(50);
	UA.disabled[i].achi:SetText(" ");
	UA.disabled[i].achi:SetJustifyH("CENTER");
	UA.disabled[i].label = UA.disabled[i]:CreateFontString("UnderAchieverExceptionsDisabledContainer"..i.."Label", "ARTWORK", "GameFontHighlight");
	UA.disabled[i].label:SetPoint("TOPLEFT",UA.disabled[i].achi,"TOPRIGHT",10,0);
	UA.disabled[i].label:SetPoint("RIGHT",UA.disabled[i],"RIGHT");
	UA.disabled[i].label:SetText(" ");
	UA.disabled[i].label:SetJustifyH("LEFT");
end

UA.exceptions.disabled.scroll = CreateFrame("ScrollFrame","UnderAchieverExceptionsDisabledScroll",UA.exceptions.disabled,"FauxScrollFrameTemplate");
UA.exceptions.disabled.scroll:SetPoint("TOPLEFT",UA.disabled[1],"TOPLEFT",0,0);
UA.exceptions.disabled.scroll:SetPoint("BOTTOMRIGHT",UA.disabled[5],"BOTTOMRIGHT",-30,10);

UA.exceptions.disabled.IDLabel = UA.exceptions.disabled:CreateFontString("UnderAchieverExceptionsDisabledIDLabel", "ARTWORK", "GameFontHighlight");
UA.exceptions.disabled.IDLabel:SetPoint("TOPLEFT", UA.exceptions.disabled.scroll, "TOPRIGHT", 25, 0);
UA.exceptions.disabled.IDLabel:SetText("ID:");
UA.exceptions.disabled.IDLabel:SetWidth(20);

UA.exceptions.disabled.IDEdit = CreateFrame("EditBox","UnderAchieverExceptionsDisabledIDEdit",UA.exceptions.disabled,"InputBoxTemplate");
UA.exceptions.disabled.IDEdit:SetPoint("TOPLEFT",UA.exceptions.disabled.IDLabel,"TOPRIGHT",12,8);
UA.exceptions.disabled.IDEdit:SetPoint("RIGHT",UA.exceptions.disabled,"RIGHT",-5,0);
UA.exceptions.disabled.IDEdit:SetHeight(28);
UA.exceptions.disabled.IDEdit:SetHistoryLines(1);
UA.exceptions.disabled.IDEdit:SetAutoFocus(false);

UA.exceptions.disabled.selected = CreateFrame("Button","UnderAchieverExceptionsDisabledSelected",UA.exceptions.disabled,"OptionsButtonTemplate");
UA.exceptions.disabled.selected:SetPoint("TOPLEFT",UA.exceptions.disabled.IDLabel,"BOTTOMLEFT",0,-5);
UA.exceptions.disabled.selected:SetPoint("RIGHT",UA.exceptions.disabled,"RIGHT",-5,0);
UA.exceptions.disabled.selected:SetText("Selection in list");

UA.exceptions.disabled.current = CreateFrame("Button","UnderAchieverExceptionsDisabledCurrent",UA.exceptions.disabled,"OptionsButtonTemplate");
UA.exceptions.disabled.current:SetPoint("TOPLEFT",UA.exceptions.disabled.selected,"BOTTOMLEFT",0,0);
UA.exceptions.disabled.current:SetPoint("RIGHT",UA.exceptions.disabled,"RIGHT",-5,0);
UA.exceptions.disabled.current:SetText("Get from link");

UA.exceptions.disabled.add = CreateFrame("Button","UnderAchieverExceptionsDisabledAdd",UA.exceptions.disabled,"OptionsButtonTemplate");
UA.exceptions.disabled.add:SetPoint("TOPLEFT",UA.exceptions.disabled.current,"BOTTOMLEFT",0,-10);
UA.exceptions.disabled.add:SetPoint("RIGHT",UA.exceptions.disabled,"RIGHT",-5,0);
UA.exceptions.disabled.add:SetText("Add");

UA.exceptions.disabled.delete = CreateFrame("Button","UnderAchieverExceptionsDisabledDelete",UA.exceptions.disabled,"OptionsButtonTemplate");
UA.exceptions.disabled.delete:SetPoint("TOPLEFT",UA.exceptions.disabled.add,"BOTTOMLEFT",0,0);
UA.exceptions.disabled.delete:SetPoint("RIGHT",UA.exceptions.disabled,"RIGHT",-5,0);
UA.exceptions.disabled.delete:SetText("Delete");

function UA.disabled_scroll_update()
	local line;
	local offset = FauxScrollFrame_GetOffset(UnderAchieverExceptionsDisabledScroll);
	local lineplusoffset;
	local total, tbl = 0, {};
	for k,v in pairs(UA_Exceptions_Disabled) do
		total = total + 1;
		tbl[total] = k;
	end
	table.sort(tbl,function(a,b) return a < b end);
	FauxScrollFrame_Update(UnderAchieverExceptionsDisabledScroll,total,5,24);
	for line=1,5 do
		lineplusoffset = line + offset;
		if lineplusoffset <= total then
			UA.disabled[line].achi:SetText(tbl[lineplusoffset]);
			UA.disabled[line].label:SetText(select(2,GetAchievementInfo(tbl[lineplusoffset])));
			UA.disabled[line]:Show();
		else
			UA.disabled[line]:Hide();
		end
	end
end

UA.exceptions.disabled.scroll:SetScript("OnVerticalScroll",function(self, offset)
	FauxScrollFrame_OnVerticalScroll(self, offset, 24, UA.disabled_scroll_update);
end);

UA.exceptions.disabled.IDEdit:SetScript("OnEnterPressed",function(self)
	self:ClearFocus();
end);

UA.exceptions.disabled.selected:SetScript("OnClick",function()
	UA.exceptions.disabled.IDEdit:ClearFocus();
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
			UA.exceptions.disabled.IDEdit:SetText(selected);
		else
			UA.print("Cannot find a selected achievement in the achievements list.",true);
		end
	else
		UA.print("Achievement list not loaded, therefore no achievement is selected.",true);
	end
end);

UA.exceptions.disabled.current:SetScript("OnClick",function()
	UA.exceptions.disabled.IDEdit:ClearFocus();
	local active = ChatEdit_GetActiveWindow();
	if active then
		local msg = " "..active:GetText();
		local id = msg:match("^.+\124c%w%w%w%w%w%w%w%w\124Hachievement:(%-?%d-):%w-:%d-:%d-:%d-:%-?%d-:%d-:%d-:%d-:%d-\124h%[.-%]\124h\124r");
		if id then
			UA.exceptions.disabled.IDEdit:SetText(id);
		else
			UA.print("Cannot find an achievement link in the chat edit box.",true);
		end
	end
end);

UA.exceptions.disabled.add:SetScript("OnClick",function()
	local id = tonumber(UA.exceptions.disabled.IDEdit:GetText() or "") or 0;
	if GetAchievementInfo(id) then
		UA_Exceptions_Disabled[id] = true;
		UA.disabled_scroll_update();
	else
		UA.print("Achievement doesn't exist.",true);
	end
end);

UA.exceptions.disabled.delete:SetScript("OnClick",function()
	local id = tonumber(UA.exceptions.disabled.IDEdit:GetText() or "") or 0;
	if UA_Exceptions_Disabled[id] then
		UA_Exceptions_Disabled[id] = nil;
		UA.disabled_scroll_update();
	else
		UA.print("Exception doesn't exist.",true);
	end
end);


-- While on, dont fake
UA.exceptions.enabled = CreateFrame("Frame","UnderAchieverExceptionsEnabled",UA.exceptions);
UA.exceptions.enabled:SetPoint("TOPLEFT", UA.exceptions.disabled, "BOTTOMLEFT", 0, -5);
UA.exceptions.enabled:SetPoint("RIGHT", UA.exceptions, "RIGHT", -15, 0);
UA.exceptions.enabled:SetHeight(145);
UA.exceptions.enabled:SetBackdrop({ 
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, 
	insets = { left = 5, right = 5, top = 5, bottom = 5 }
});

UA.exceptions.enabled.label = UA.exceptions.enabled:CreateFontString("UnderAchieverExceptionsEnabledLabel", "ARTWORK", "GameFontHighlight");
UA.exceptions.enabled.label:SetPoint("TOPLEFT", UA.exceptions.enabled, 10, -10);
UA.exceptions.enabled.label:SetText("Whilst auto-faking is enabled, do not fake these achievements:");

UA.enabled = {};
for i=1,5 do
	UA.enabled[i] = CreateFrame("Frame","UnderAchieverExceptionsEnabledContainer"..i,UA.exceptions.enabled);
	UA.enabled[i]:SetWidth(365);
	UA.enabled[i]:SetHeight(24);
	if i==1 then
		UA.enabled[i]:SetPoint("TOPLEFT",UA.exceptions.enabled.label,"BOTTOMLEFT",10,-5);
	else
		UA.enabled[i]:SetPoint("TOPLEFT",UA.enabled[i-1],"BOTTOMLEFT",0,0);
	end
	UA.enabled[i].achi = UA.enabled[i]:CreateFontString("UnderAchieverExceptionsEnabledContainer"..i.."Achi", "ARTWORK", "GameFontNormal");
	UA.enabled[i].achi:SetPoint("TOPLEFT",UA.enabled[i],"TOPLEFT",0,0);
	UA.enabled[i].achi:SetWidth(50);
	UA.enabled[i].achi:SetText(" ");
	UA.enabled[i].achi:SetJustifyH("CENTER");
	UA.enabled[i].label = UA.enabled[i]:CreateFontString("UnderAchieverExceptionsEnabledContainer"..i.."Label", "ARTWORK", "GameFontHighlight");
	UA.enabled[i].label:SetPoint("TOPLEFT",UA.enabled[i].achi,"TOPRIGHT",10,0);
	UA.enabled[i].label:SetPoint("RIGHT",UA.enabled[i],"RIGHT");
	UA.enabled[i].label:SetText(" ");
	UA.enabled[i].label:SetJustifyH("LEFT");
end

UA.exceptions.enabled.scroll = CreateFrame("ScrollFrame","UnderAchieverExceptionsEnabledScroll",UA.exceptions.enabled,"FauxScrollFrameTemplate");
UA.exceptions.enabled.scroll:SetPoint("TOPLEFT",UA.enabled[1],"TOPLEFT",0,0);
UA.exceptions.enabled.scroll:SetPoint("BOTTOMRIGHT",UA.enabled[5],"BOTTOMRIGHT",-30,10);

UA.exceptions.enabled.IDLabel = UA.exceptions.enabled:CreateFontString("UnderAchieverExceptionsEnabledIDLabel", "ARTWORK", "GameFontHighlight");
UA.exceptions.enabled.IDLabel:SetPoint("TOPLEFT", UA.exceptions.enabled.scroll, "TOPRIGHT", 25, 0);
UA.exceptions.enabled.IDLabel:SetText("ID:");
UA.exceptions.enabled.IDLabel:SetWidth(20);

UA.exceptions.enabled.IDEdit = CreateFrame("EditBox","UnderAchieverExceptionsEnabledIDEdit",UA.exceptions.enabled,"InputBoxTemplate");
UA.exceptions.enabled.IDEdit:SetPoint("TOPLEFT",UA.exceptions.enabled.IDLabel,"TOPRIGHT",12,8);
UA.exceptions.enabled.IDEdit:SetPoint("RIGHT",UA.exceptions.enabled,"RIGHT",-5,0);
UA.exceptions.enabled.IDEdit:SetHeight(28);
UA.exceptions.enabled.IDEdit:SetHistoryLines(1);
UA.exceptions.enabled.IDEdit:SetAutoFocus(false);

UA.exceptions.enabled.selected = CreateFrame("Button","UnderAchieverExceptionsEnabledSelected",UA.exceptions.enabled,"OptionsButtonTemplate");
UA.exceptions.enabled.selected:SetPoint("TOPLEFT",UA.exceptions.enabled.IDLabel,"BOTTOMLEFT",0,-5);
UA.exceptions.enabled.selected:SetPoint("RIGHT",UA.exceptions.enabled,"RIGHT",-5,0);
UA.exceptions.enabled.selected:SetText("Selection in list");

UA.exceptions.enabled.current = CreateFrame("Button","UnderAchieverExceptionsEnabledCurrent",UA.exceptions.enabled,"OptionsButtonTemplate");
UA.exceptions.enabled.current:SetPoint("TOPLEFT",UA.exceptions.enabled.selected,"BOTTOMLEFT",0,0);
UA.exceptions.enabled.current:SetPoint("RIGHT",UA.exceptions.enabled,"RIGHT",-5,0);
UA.exceptions.enabled.current:SetText("Get from link");

UA.exceptions.enabled.add = CreateFrame("Button","UnderAchieverExceptionsEnabledAdd",UA.exceptions.enabled,"OptionsButtonTemplate");
UA.exceptions.enabled.add:SetPoint("TOPLEFT",UA.exceptions.enabled.current,"BOTTOMLEFT",0,-10);
UA.exceptions.enabled.add:SetPoint("RIGHT",UA.exceptions.enabled,"RIGHT",-5,0);
UA.exceptions.enabled.add:SetText("Add");

UA.exceptions.enabled.delete = CreateFrame("Button","UnderAchieverExceptionsEnabledDelete",UA.exceptions.enabled,"OptionsButtonTemplate");
UA.exceptions.enabled.delete:SetPoint("TOPLEFT",UA.exceptions.enabled.add,"BOTTOMLEFT",0,0);
UA.exceptions.enabled.delete:SetPoint("RIGHT",UA.exceptions.enabled,"RIGHT",-5,0);
UA.exceptions.enabled.delete:SetText("Delete");

function UA.enabled_scroll_update()
	local line;
	local offset = FauxScrollFrame_GetOffset(UnderAchieverExceptionsEnabledScroll);
	local lineplusoffset;
	local total, tbl = 0, {};
	for k,v in pairs(UA_Exceptions_Enabled) do
		total = total + 1;
		tbl[total] = k;
	end
	table.sort(tbl,function(a,b) return a < b end);
	FauxScrollFrame_Update(UnderAchieverExceptionsEnabledScroll,total,5,16);
	for line=1,5 do
		lineplusoffset = line + offset;
		if lineplusoffset <= total then
			UA.enabled[line].achi:SetText(tbl[lineplusoffset]);
			UA.enabled[line].label:SetText(select(2,GetAchievementInfo(tbl[lineplusoffset])));
			UA.enabled[line]:Show();
		else
			UA.enabled[line]:Hide();
		end
	end
end

UA.exceptions.enabled.scroll:SetScript("OnVerticalScroll",function(self, offset)
	FauxScrollFrame_OnVerticalScroll(self, offset, 24, UA.enabled_scroll_update);
end);

UA.exceptions.enabled.IDEdit:SetScript("OnEnterPressed",function(self)
	self:ClearFocus();
end);

UA.exceptions.enabled.selected:SetScript("OnClick",function()
	UA.exceptions.enabled.IDEdit:ClearFocus();
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
			UA.exceptions.enabled.IDEdit:SetText(selected);
		else
			UA.print("Cannot find a selected achievement in the achievements list.",true);
		end
	else
		UA.print("Achievement list not loaded, therefore no achievement is selected.",true);
	end
end);

UA.exceptions.enabled.current:SetScript("OnClick",function()
	UA.exceptions.enabled.IDEdit:ClearFocus();
	local active = ChatEdit_GetActiveWindow();
	if active then
		local msg = " "..active:GetText();
		local id = msg:match("^.+\124c%w%w%w%w%w%w%w%w\124Hachievement:(%-?%d-):%w-:%d-:%d-:%d-:%-?%d-:%d-:%d-:%d-:%d-\124h%[.-%]\124h\124r");
		if id then
			UA.exceptions.enabled.IDEdit:SetText(id);
		else
			UA.print("Cannot find an achievement link in the chat edit box.",true);
		end
	end
end);

UA.exceptions.enabled.add:SetScript("OnClick",function()
	local id = tonumber(UA.exceptions.enabled.IDEdit:GetText() or "") or 0;
	if GetAchievementInfo(id) then
		UA_Exceptions_Enabled[id] = true;
		UA.enabled_scroll_update();
	else
		UA.print("Achievement doesn't exist.",true);
	end
end);

UA.exceptions.enabled.delete:SetScript("OnClick",function()
	local id = tonumber(UA.exceptions.enabled.IDEdit:GetText() or "") or 0;
	if UA_Exceptions_Enabled[id] then
		UA_Exceptions_Enabled[id] = nil;
		UA.enabled_scroll_update();
	else
		UA.print("Exception doesn't exist.",true);
	end
end);


UA.exceptions.label = UA.exceptions:CreateFontString("UnderAchieverExceptionsLabel", "ARTWORK", "GameFontHighlight");
UA.exceptions.label:SetPoint("TOPLEFT", UA.exceptions.enabled, "BOTTOMLEFT", 5, 5);
UA.exceptions.label:SetPoint("BOTTOMRIGHT", UA.exceptions, "BOTTOMRIGHT", -15, 5);
UA.exceptions.label:SetJustifyH("LEFT");
UA.exceptions.label:SetText("Note: By default, UnderAchiever will always use the real date if you have completed the achievement");


UA.exceptions:SetScript("OnShow",function()
	UA.disabled_scroll_update();
	UA.enabled_scroll_update();
end);