local UnderAchiever,UA = ...;

UA.options = CreateFrame("Frame","UnderAchieverOptions",UA.frame);
UA.options:Show();
UA.options:SetAllPoints(UA.frame);


-- Auto-Faking
UA.options.faking = CreateFrame("Frame","UnderAchieverOptionsFaking",UA.options);
UA.options.faking:SetPoint("TOPLEFT", UA.options, 15, -30);
UA.options.faking:SetPoint("RIGHT", UA.options, "RIGHT", -15, 0);
UA.options.faking:SetHeight(190);
UA.options.faking:SetBackdrop({ 
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, 
	insets = { left = 5, right = 5, top = 5, bottom = 5 }
});

UA.options.faking.check = CreateFrame("CheckButton","UnderAchieverOptionsFakingCheck",UA.options.faking,"UICheckButtonTemplate");
UA.options.faking.check:SetPoint("TOPLEFT",UA.options.faking,"TOPLEFT",12,-8);

UA.options.faking.label = UA.options.faking:CreateFontString("UnderAchieverOptionsFakingLabel", "ARTWORK", "GameFontHighlight");
UA.options.faking.label:SetPoint("TOPLEFT",UA.options.faking.check,"TOPRIGHT",2,-8);
UA.options.faking.label:SetText("Auto-Faking");

UA.options.faking.text = UA.options.faking:CreateFontString("UnderAchieverOptionsFakingText", "ARTWORK", "GameFontHighlight");
UA.options.faking.text:SetPoint("TOP", UA.options.faking.check, "BOTTOM", 0, -4);
UA.options.faking.text:SetPoint("LEFT", UA.options.faking, "LEFT", 15, 0);
UA.options.faking.text:SetWidth(160);
UA.options.faking.text:SetJustifyH("LEFT");
UA.options.faking.text:SetText("Start with auto-faking:");

UA.options.faking.dropdown = CreateFrame("Frame", "UnderAchieverOptionsFakingDropdown", UA.options.faking, "UIDropDownMenuTemplate");
UA.options.faking.dropdown:ClearAllPoints();
UA.options.faking.dropdown:SetPoint("TOPLEFT", UA.options.faking.text, "TOPRIGHT", 0, 6);
UA.options.faking.dropdown:Show();
UIDropDownMenu_SetWidth(UnderAchieverOptionsFakingDropdown, 130);
UIDropDownMenu_SetButtonWidth(UnderAchieverOptionsFakingDropdown, 154);
UIDropDownMenu_JustifyText(UnderAchieverOptionsFakingDropdown, "LEFT");
UA.faking_list = {
	"Enabled",
	"Disabled",
	"Same as last session",
};
function UA.faking_click(self)
	local id = self:GetID();
	UIDropDownMenu_SetSelectedID(UnderAchieverOptionsFakingDropdown, id);
end
function UA.faking_init(self, level)
	local info;
	for k,v in ipairs(UA.faking_list) do
		info = UIDropDownMenu_CreateInfo();
		info.text = v;
		info.value = v;
		info.func = UA.faking_click;
		UIDropDownMenu_AddButton(info, level);
	end
end
UIDropDownMenu_Initialize(UnderAchieverOptionsFakingDropdown, UA.faking_init);

UA.options.faking.saveCheck = CreateFrame("CheckButton","UnderAchieverOptionsFakingSaveCheck",UA.options.faking,"UICheckButtonTemplate");
UA.options.faking.saveCheck:SetPoint("TOPLEFT",UA.options.faking.check,"BOTTOMLEFT",0,-26);

UA.options.faking.saveLabel = UA.options.faking:CreateFontString("UnderAchieverOptionsFakingSaveLabel", "ARTWORK", "GameFontHighlight");
UA.options.faking.saveLabel:SetPoint("TOPLEFT",UA.options.faking.saveCheck,"TOPRIGHT",2,-8);
UA.options.faking.saveLabel:SetText("Use advanced saves in auto-faking");

UA.options.faking.dateCheck = CreateFrame("CheckButton","UnderAchieverOptionsFakingDateCheck",UA.options.faking,"UICheckButtonTemplate");
UA.options.faking.dateCheck:SetPoint("TOPLEFT",UA.options.faking.saveCheck,"BOTTOMLEFT",0,4);

UA.options.faking.dateLabel = UA.options.faking:CreateFontString("UnderAchieverOptionsFakingDateLabel", "ARTWORK", "GameFontHighlight");
UA.options.faking.dateLabel:SetPoint("TOPLEFT",UA.options.faking.dateCheck,"TOPRIGHT",2,-8);
UA.options.faking.dateLabel:SetText("Use the real date/link if I have completed the achievement");

UA.options.faking.disableCheck = CreateFrame("CheckButton","UnderAchieverOptionsFakingDisableCheck",UA.options.faking,"UICheckButtonTemplate");
UA.options.faking.disableCheck:SetPoint("TOPLEFT",UA.options.faking.dateCheck,"BOTTOMLEFT",0,4);

UA.options.faking.disableLabel = UA.options.faking:CreateFontString("UnderAchieverOptionsFakingDisableLabel", "ARTWORK", "GameFontHighlight");
UA.options.faking.disableLabel:SetPoint("TOPLEFT",UA.options.faking.disableCheck,"TOPRIGHT",2,-8);
UA.options.faking.disableLabel:SetText("Don't auto-fake whilst the Advanced Faking page is open");

UA.options.faking.realCheck = CreateFrame("CheckButton","UnderAchieverOptionsFakingRealCheck",UA.options.faking,"UICheckButtonTemplate");
UA.options.faking.realCheck:SetPoint("TOPLEFT",UA.options.faking.disableCheck,"BOTTOMLEFT",0,4);

UA.options.faking.realLabel = UA.options.faking:CreateFontString("UnderAchieverOptionsFakingRealLabel", "ARTWORK", "GameFontHighlight");
UA.options.faking.realLabel:SetPoint("TOPLEFT",UA.options.faking.realCheck,"TOPRIGHT",2,-5);
UA.options.faking.realLabel:SetPoint("RIGHT",UA.options.faking,"RIGHT",-5,0);
UA.options.faking.realLabel:SetPoint("BOTTOM",UA.options.faking,"BOTTOM",0,5);
UA.options.faking.realLabel:SetJustifyH("LEFT");
UA.options.faking.realLabel:SetJustifyV("TOP");
UA.options.faking.realLabel:SetText("Whilst auto-faking is enabled, change links to my real achievement data (instead of faking)");



-- Min / Max
UA.options.date = CreateFrame("Frame","UnderAchieverOptionsDate",UA.options);
UA.options.date:SetPoint("TOPLEFT", UA.options.faking, "BOTTOMLEFT", 0, -5);
UA.options.date:SetPoint("RIGHT", UA.options, "RIGHT", -15, 0);
UA.options.date:SetHeight(100);
UA.options.date:SetBackdrop({ 
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, 
	insets = { left = 5, right = 5, top = 5, bottom = 5 }
});

UA.options.date.text = UA.options.date:CreateFontString("UnderAchieverOptionsDateText", "ARTWORK", "GameFontHighlight");
UA.options.date.text:SetPoint("TOPLEFT", UA.options.date, "TOPLEFT", 15, -10);
UA.options.date.text:SetPoint("RIGHT", UA.options.date, "RIGHT", -15, 0);
UA.options.date.text:SetJustifyH("LEFT");
UA.options.date.text:SetText("Pick random dates between the following times:");

UA.options.date.min = CreateFrame("EditBox","UnderAchieverOptionsDateMin",UA.options.date,"InputBoxTemplate");
UA.options.date.min:SetWidth(60);
UA.options.date.min:SetHeight(28);
UA.options.date.min:SetHistoryLines(1);
UA.options.date.min:SetPoint("TOPLEFT",UA.options.date.text,"BOTTOMLEFT",12,-6);
UA.options.date.min:SetAutoFocus(false);
UA.options.date.min:SetText(UA_Settings.min_value);
UA.options.date.min:SetScript("OnEnterPressed",function(self)
	self:ClearFocus();
end);

UA.options.date.min.dropdown = CreateFrame("Frame", "UnderAchieverOptionsDateMinDropdown", UA.options.date, "UIDropDownMenuTemplate");
UA.options.date.min.dropdown:ClearAllPoints();
UA.options.date.min.dropdown:SetPoint("TOPLEFT", UnderAchieverOptionsDateMin, "TOPRIGHT", -4, 0);
UA.options.date.min.dropdown:Show();
UIDropDownMenu_SetWidth(UnderAchieverOptionsDateMinDropdown, 90);
UIDropDownMenu_SetButtonWidth(UnderAchieverOptionsDateMinDropdown, 114);
UIDropDownMenu_JustifyText(UnderAchieverOptionsDateMinDropdown, "LEFT");
UA.date_list = {
	"Days",
	"Weeks",
	"Months",
	"Years",
};
function UA.min_click(self)
	local id = self:GetID();
	UIDropDownMenu_SetSelectedID(UnderAchieverOptionsDateMinDropdown, id);
end
function UA.min_init(self, level)
	local info;
	for k,v in ipairs(UA.date_list) do
		info = UIDropDownMenu_CreateInfo();
		info.text = v;
		info.value = v;
		info.func = UA.min_click;
		UIDropDownMenu_AddButton(info, level);
	end
end
UIDropDownMenu_Initialize(UnderAchieverOptionsDateMinDropdown, UA.min_init);

UA.options.date.min.text = UA.options.date:CreateFontString("UnderAchieverOptionsDateMinText", "ARTWORK", "GameFontHighlight");
UA.options.date.min.text:SetPoint("TOPLEFT", UA.options.date.min.dropdown, "TOPRIGHT", -6, -6);
UA.options.date.min.text:SetWidth(50);
UA.options.date.min.text:SetJustifyH("LEFT");
UA.options.date.min.text:SetText("ago");

UA.options.date.max = CreateFrame("EditBox","UnderAchieverOptionsDateMax",UA.options.date,"InputBoxTemplate");
UA.options.date.max:SetWidth(60);
UA.options.date.max:SetHeight(28);
UA.options.date.max:SetHistoryLines(1);
UA.options.date.max:SetPoint("TOPLEFT",UA.options.date.min,"BOTTOMLEFT",0,-6);
UA.options.date.max:SetAutoFocus(false);
UA.options.date.max:SetText(UA_Settings.max_value);
UA.options.date.max:SetScript("OnEnterPressed",function(self)
	self:ClearFocus();
end);

UA.options.date.max.dropdown = CreateFrame("Frame", "UnderAchieverOptionsDateMaxDropdown", UA.options.date, "UIDropDownMenuTemplate");
UA.options.date.max.dropdown:ClearAllPoints();
UA.options.date.max.dropdown:SetPoint("TOPLEFT", UA.options.date.max, "TOPRIGHT", -4, 0);
UA.options.date.max.dropdown:Show();
UIDropDownMenu_SetWidth(UnderAchieverOptionsDateMaxDropdown, 90);
UIDropDownMenu_SetButtonWidth(UnderAchieverOptionsDateMaxDropdown, 114);
UIDropDownMenu_JustifyText(UnderAchieverOptionsDateMaxDropdown, "LEFT");
function UA.max_click(self)
	local id = self:GetID();
	UIDropDownMenu_SetSelectedID(UnderAchieverOptionsDateMaxDropdown, id);
end
function UA.max_init(self, level)
	local info;
	for k,v in ipairs(UA.date_list) do
		info = UIDropDownMenu_CreateInfo();
		info.text = v;
		info.value = v;
		info.func = UA.max_click;
		UIDropDownMenu_AddButton(info, level);
	end
end
UIDropDownMenu_Initialize(UnderAchieverOptionsDateMaxDropdown, UA.max_init);

UA.options.date.max.text = UA.options.date:CreateFontString("UnderAchieverOptionsDateMaxText", "ARTWORK", "GameFontHighlight");
UA.options.date.max.text:SetPoint("TOPLEFT", UA.options.date.max.dropdown, "TOPRIGHT", -6, -6);
UA.options.date.max.text:SetWidth(50);
UA.options.date.max.text:SetJustifyH("LEFT");
UA.options.date.max.text:SetText("ago");


UA.options.save = CreateFrame("Button","UnderAchieverOptionsSave",UA.options,"OptionsButtonTemplate");
UA.options.save:SetPoint("TOPRIGHT",UA.options.date,"BOTTOMRIGHT",0,-5);
UA.options.save:SetWidth(120);
UA.options.save:SetText("Save Changes");
UA.options.save:SetScript("OnClick",function()
	UA_Settings.state = UA.options.faking.check:GetChecked() and true or false;
	UA_Settings.default = UIDropDownMenu_GetSelectedID(UnderAchieverOptionsFakingDropdown);
	UA_Settings.saves = UA.options.faking.saveCheck:GetChecked() and true or false;
	UA_Settings.date = UA.options.faking.dateCheck:GetChecked() and true or false;
	UA_Settings.real = UA.options.faking.realCheck:GetChecked() and true or false;
	UA_Settings.disable = UA.options.faking.disableCheck:GetChecked() and true or false;
	local min_value, min_type = tonumber(UA.options.date.min:GetText() or "") or 1, UIDropDownMenu_GetSelectedID(UnderAchieverOptionsDateMinDropdown);
	local max_value, max_type = tonumber(UA.options.date.max:GetText() or "") or 1, UIDropDownMenu_GetSelectedID(UnderAchieverOptionsDateMaxDropdown);
	local real_min = min_value * 60 * 60 * 24 * (min_type == 2 and 7 or min_type == 3 and 30 or min_type == 4 and 364 or 1);
	local real_max = max_value * 60 * 60 * 24 * (max_type == 2 and 7 or max_type == 3 and 30 or max_type == 4 and 364 or 1);
	local final_min, final_max = min(real_min, real_max), max(real_min, real_max);
	UA_Settings.min_value = final_min == real_min and min_value or max_value;
	UA_Settings.min_type = final_min == real_min and min_type or max_type;
	UA_Settings.max_value = final_max == real_max and max_value or min_value; 
	UA_Settings.max_type = final_max == real_max and max_type or min_type;
	UA.print("Options saved.");
end);

UA.options:SetScript("OnShow",function()
	UA.options.faking.check:SetChecked(UA_Settings.state);
	UIDropDownMenu_SetSelectedID(UnderAchieverOptionsFakingDropdown, UA_Settings.default);
	UIDropDownMenu_SetText(UnderAchieverOptionsFakingDropdown, UA.faking_list[UA_Settings.default]);
	UA.options.faking.saveCheck:SetChecked(UA_Settings.saves);
	UA.options.faking.dateCheck:SetChecked(UA_Settings.date);
	UA.options.faking.realCheck:SetChecked(UA_Settings.real);
	UA.options.faking.disableCheck:SetChecked(UA_Settings.disable);
	UA.options.date.min:SetText(UA_Settings.min_value);
	UIDropDownMenu_SetSelectedID(UnderAchieverOptionsDateMinDropdown, UA_Settings.min_type);
	UIDropDownMenu_SetText(UnderAchieverOptionsDateMinDropdown, UA.date_list[UA_Settings.min_type]);
	UA.options.date.max:SetText(UA_Settings.max_value);
	UIDropDownMenu_SetSelectedID(UnderAchieverOptionsDateMaxDropdown, UA_Settings.max_type);
	UIDropDownMenu_SetText(UnderAchieverOptionsDateMaxDropdown, UA.date_list[UA_Settings.max_type]);
end);