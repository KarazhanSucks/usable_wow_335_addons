local UnderAchiever,UA = ...;

UA.replacements = CreateFrame("Frame","UnderAchieverReplacements",UA.frame);
UA.replacements:Hide();
UA.replacements:SetAllPoints(UA.frame);


UA.replacements.scroll = CreateFrame("Frame","UnderAchieverReplacementsScroll",UA.replacements);
UA.replacements.scroll:SetPoint("TOPLEFT", UA.replacements, 15, -30);
UA.replacements.scroll:SetPoint("BOTTOM", UA.replacements, "BOTTOM", 0, 20);
UA.replacements.scroll:SetWidth(365);
UA.replacements.scroll:SetBackdrop({ 
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, 
	insets = { left = 5, right = 5, top = 5, bottom = 5 }
});


UA.replacements.controls = CreateFrame("Frame","UnderAchieverReplacementsControls",UA.replacements);
UA.replacements.controls:SetPoint("TOPLEFT", UA.replacements.scroll, "TOPRIGHT", 5, 0);
UA.replacements.controls:SetPoint("BOTTOM", UA.replacements, "BOTTOM", 0, 20);
UA.replacements.controls:SetPoint("RIGHT", UA.replacements, "RIGHT", -15, 0);
UA.replacements.controls:SetBackdrop({ 
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, 
	insets = { left = 5, right = 5, top = 5, bottom = 5 }
});

UA.replacements.controls.text = UA.replacements.controls:CreateFontString("UnderAchieverReplacementsControlsText", "ARTWORK", "GameFontNormal");
UA.replacements.controls.text:SetPoint("TOPLEFT", UA.replacements.controls, 5, -10);
UA.replacements.controls.text:SetPoint("RIGHT", UA.replacements.controls, "RIGHT", -5, 0);
UA.replacements.controls.text:SetText("Replacement");

UA.replacements.controls.text.label = UA.replacements.controls:CreateFontString("UnderAchieverReplacementsControlsTextLabel", "ARTWORK", "GameFontHighlight");
UA.replacements.controls.text.label:SetPoint("TOPLEFT", UA.replacements.controls.text, "TOPLEFT", 0, -20);
UA.replacements.controls.text.label:SetText("%");
UA.replacements.controls.text.label:SetWidth(12);
UA.replacements.controls.text.label:SetJustifyH("LEFT");

UA.replacements.controls.text.edit = CreateFrame("EditBox","UnderAchieverReplacementsControlsTextEdit",UA.replacements.controls,"InputBoxTemplate");
UA.replacements.controls.text.edit:SetPoint("TOPLEFT",UA.replacements.controls.text.label,"TOPRIGHT",5,8);
UA.replacements.controls.text.edit:SetPoint("RIGHT", UA.replacements.controls.text, "RIGHT", -2, 0);
UA.replacements.controls.text.edit:SetHeight(28);
UA.replacements.controls.text.edit:SetHistoryLines(1);
UA.replacements.controls.text.edit:SetAutoFocus(false);

UA.replacements.controls.ID = UA.replacements.controls:CreateFontString("UnderAchieverReplacementsControlsID", "ARTWORK", "GameFontNormal");
UA.replacements.controls.ID:SetPoint("TOPLEFT", UA.replacements.controls.text, "BOTTOMLEFT", 0, -40);
UA.replacements.controls.ID:SetPoint("RIGHT", UA.replacements.controls.text, "RIGHT", 0, 0);
UA.replacements.controls.ID:SetText("Achievement");

UA.replacements.controls.ID.label = UA.replacements.controls:CreateFontString("UnderAchieverReplacementsControlsIDLabel", "ARTWORK", "GameFontHighlight");
UA.replacements.controls.ID.label:SetPoint("TOPLEFT", UA.replacements.controls.ID, "TOPLEFT", 0, -20);
UA.replacements.controls.ID.label:SetText("ID:");
UA.replacements.controls.ID.label:SetWidth(20);

UA.replacements.controls.ID.edit = CreateFrame("EditBox","UnderAchieverReplacementsControlsIDEdit",UA.replacements.controls,"InputBoxTemplate");
UA.replacements.controls.ID.edit:SetPoint("TOPLEFT",UA.replacements.controls.ID.label,"TOPRIGHT",12,8);
UA.replacements.controls.ID.edit:SetPoint("RIGHT",UA.replacements.controls.ID,"RIGHT",-2,0);
UA.replacements.controls.ID.edit:SetHeight(28);
UA.replacements.controls.ID.edit:SetHistoryLines(1);
UA.replacements.controls.ID.edit:SetAutoFocus(false);

UA.replacements.controls.selected = CreateFrame("Button","UnderAchieverReplacementsControlsSelected",UA.replacements.controls,"OptionsButtonTemplate");
UA.replacements.controls.selected:SetPoint("TOPLEFT",UA.replacements.controls.ID.label,"BOTTOMLEFT",0,-5);
UA.replacements.controls.selected:SetPoint("RIGHT",UA.replacements.controls.ID,"RIGHT",0,0);
UA.replacements.controls.selected:SetText("Selection in list");

UA.replacements.controls.current = CreateFrame("Button","UnderAchieverReplacementsControlsCurrent",UA.replacements.controls,"OptionsButtonTemplate");
UA.replacements.controls.current:SetPoint("TOPLEFT",UA.replacements.controls.selected,"BOTTOMLEFT",0,0);
UA.replacements.controls.current:SetPoint("RIGHT",UA.replacements.controls.ID,"RIGHT",0,0);
UA.replacements.controls.current:SetText("Get from link");

UA.replacements.controls.add = CreateFrame("Button","UnderAchieverReplacementsControlsAdd",UA.replacements.controls,"OptionsButtonTemplate");
UA.replacements.controls.add:SetPoint("TOPLEFT",UA.replacements.controls.current,"BOTTOMLEFT",0,-20);
UA.replacements.controls.add:SetPoint("RIGHT",UA.replacements.controls.ID,"RIGHT",0,0);
UA.replacements.controls.add:SetText("Add");

UA.replacements.controls.delete = CreateFrame("Button","UnderAchieverReplacementsControlsDelete",UA.replacements.controls,"OptionsButtonTemplate");
UA.replacements.controls.delete:SetPoint("TOPLEFT",UA.replacements.controls.add,"BOTTOMLEFT",0,0);
UA.replacements.controls.delete:SetPoint("RIGHT",UA.replacements.controls.ID,"RIGHT",0,0);
UA.replacements.controls.delete:SetText("Delete");


UA.replacements.containers = {};
for i=1,13 do
	UA.replacements.containers[i] = CreateFrame("Frame","UnderAchieverReplacementsScrollContainer"..i,UA.replacements.scroll);
	UA.replacements.containers[i]:SetPoint("RIGHT",UA.replacements.scroll,0,0);
	UA.replacements.containers[i]:SetHeight(24);
	if i==1 then
		UA.replacements.containers[i]:SetPoint("TOPLEFT",UA.replacements.scroll,"TOPLEFT",10,-10);
	else
		UA.replacements.containers[i]:SetPoint("TOPLEFT",UA.replacements.containers[i-1],"BOTTOMLEFT",0,0);
	end
	UA.replacements.containers[i].achi = UA.replacements.containers[i]:CreateFontString("UnderAchieverReplacementsScrollContainer"..i.."Achi", "ARTWORK", "GameFontNormal");
	UA.replacements.containers[i].achi:SetPoint("TOPLEFT",UA.replacements.containers[i],"TOPLEFT",0,0);
	UA.replacements.containers[i].achi:SetWidth(50);
	UA.replacements.containers[i].achi:SetText(" ");
	UA.replacements.containers[i].achi:SetJustifyH("CENTER");
	UA.replacements.containers[i].label = UA.replacements.containers[i]:CreateFontString("UnderAchieverReplacementsScrollContainer"..i.."Label", "ARTWORK", "GameFontHighlight");
	UA.replacements.containers[i].label:SetPoint("TOPLEFT",UA.replacements.containers[i].achi,"TOPRIGHT",10,0);
	UA.replacements.containers[i].label:SetPoint("RIGHT",UA.replacements.containers[i],"RIGHT");
	UA.replacements.containers[i].label:SetText(" ");
	UA.replacements.containers[i].label:SetJustifyH("LEFT");
end

UA.replacements.scroll.frame = CreateFrame("ScrollFrame","UnderAchieverReplacementsScrollFrame",UA.replacements.scroll,"FauxScrollFrameTemplate");
UA.replacements.scroll.frame:SetPoint("TOPLEFT",UA.replacements.scroll,"TOPLEFT",10,-10);
UA.replacements.scroll.frame:SetPoint("BOTTOMRIGHT",UA.replacements.scroll,"BOTTOMRIGHT",-30,10);

function UA.replacements_scroll_update()
	local line;
	local offset = FauxScrollFrame_GetOffset(UnderAchieverReplacementsScrollFrame);
	local lineplusoffset;
	local total, tbl = 0, {};
	for k,v in pairs(UA_Replacements) do
		total = total + 1;
		tbl[total] = k;
	end
	table.sort(tbl,function(a,b) return UA_Replacements[a] < UA_Replacements[b] end);
	FauxScrollFrame_Update(UnderAchieverReplacementsScrollFrame,total,13,24);
	for line=1,13 do
		lineplusoffset = line + offset;
		if lineplusoffset <= total then
			UA.replacements.containers[line].achi:SetText(UA_Replacements[tbl[lineplusoffset]]);
			UA.replacements.containers[line].label:SetText("%"..tbl[lineplusoffset]);
			UA.replacements.containers[line]:Show();
		else
			UA.replacements.containers[line]:Hide();
		end
	end
end

UA.replacements.scroll.frame:SetScript("OnVerticalScroll",function(self, offset)
	FauxScrollFrame_OnVerticalScroll(self, offset, 24, UA.replacements_scroll_update);
end);

UA.replacements.controls.text.edit:SetScript("OnEnterPressed",function(self)
	self:ClearFocus();
end);

UA.replacements.controls.ID.edit:SetScript("OnEnterPressed",function(self)
	self:ClearFocus();
end);

UA.replacements.controls.selected:SetScript("OnClick",function()
	UA.replacements.controls.ID.edit:ClearFocus();
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
			UA.replacements.controls.ID.edit:SetText(selected);
		else
			UA.print("Cannot find a selected achievement in the achievements list.",true);
		end
	else
		UA.print("Achievement list not loaded, therefore no achievement is selected.",true);
	end
end);

UA.replacements.controls.current:SetScript("OnClick",function()
	UA.replacements.controls.ID.edit:ClearFocus();
	local active = ChatEdit_GetActiveWindow();
	if active then
		local msg = " "..active:GetText();
		local id = msg:match("^.+\124c%w%w%w%w%w%w%w%w\124Hachievement:(%-?%d-):%w-:%d-:%d-:%d-:%-?%d-:%d-:%d-:%d-:%d-\124h%[.-%]\124h\124r");
		if id then
			UA.replacements.controls.ID.edit:SetText(id);
		else
			UA.print("Cannot find an achievement link in the chat edit box.",true);
		end
	end
end);

UA.replacements.controls.add:SetScript("OnClick",function()
	local id = tonumber(UA.replacements.controls.ID.edit:GetText() or "") or 0;
	if GetAchievementInfo(id) then
		local text = UA.replacements.controls.text.edit:GetText() or "";
		text = text:match("^([^%s%%]+)");
		if text and text > "" then
			UA_Replacements[text] = id;
			UA.replacements_scroll_update();
		else
			UA.print("Invalid replacement text.",true);
		end
	else
		UA.print("Achievement doesn't exist.",true);
	end
end);

UA.replacements.controls.delete:SetScript("OnClick",function()
	local text = UA.replacements.controls.text.edit:GetText() or "";
	text = text:match("^(%S+)");
	if text and text > "" and UA_Replacements[text] then
		UA_Replacements[text] = nil;
		UA.replacements_scroll_update();
	else
		UA.print("Replacement doesn't exist.",true);
	end
end);

UA.replacements:SetScript("OnShow",function()
	UA.replacements_scroll_update();
end);