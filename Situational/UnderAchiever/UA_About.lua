local UnderAchiever,UA = ...;

UA.about = CreateFrame("Frame","UnderAchieverAbout",UA.frame);
UA.about:Hide();
UA.about:SetAllPoints(UA.frame);


-- UnderAchiever
UA.about.addon = CreateFrame("Frame","UnderAchieverAboutAddon",UA.about);
UA.about.addon:SetPoint("TOPLEFT", UA.about, 15, -30);
UA.about.addon:SetPoint("RIGHT", UA.about, "RIGHT", -15, 0);
UA.about.addon:SetHeight(160);
UA.about.addon:SetBackdrop({ 
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, 
	insets = { left = 5, right = 5, top = 5, bottom = 5 }
});

UA.about.addon.texture = UA.about.addon:CreateTexture("UnderAchieverAboutAddonTexture", "ARTWORK");
UA.about.addon.texture:SetPoint("TOPLEFT", UA.about.addon, 10, -15);
UA.about.addon.texture:SetHeight(128);
UA.about.addon.texture:SetWidth(128);
UA.about.addon.texture:SetTexture("Interface\\AddOns\\UnderAchiever\\Textures\\UA");

UA.about.addon.titleLabel = UA.about.addon:CreateFontString("UnderAchieverAboutAddonTitleLabel", "ARTWORK", "GameFontNormal");
UA.about.addon.titleLabel:SetPoint("TOPLEFT", UA.about.addon.texture, "TOPRIGHT", 10, 0);
UA.about.addon.titleLabel:SetText("AddOn:");

UA.about.addon.titleText = UA.about.addon:CreateFontString("UnderAchieverAboutAddonTitleText", "ARTWORK", "GameFontHighlight");
UA.about.addon.titleText:SetPoint("TOPLEFT", UA.about.addon.titleLabel, "TOPRIGHT", 10, 0);
UA.about.addon.titleText:SetText("UnderAchiever");

UA.about.addon.descLabel = UA.about.addon:CreateFontString("UnderAchieverAboutAddonDescriptionLabel", "ARTWORK", "GameFontNormal");
UA.about.addon.descLabel:SetPoint("TOPLEFT", UA.about.addon.titleLabel, "BOTTOMLEFT", 0, -10);
UA.about.addon.descLabel:SetText("Description:");

UA.about.addon.descText = UA.about.addon:CreateFontString("UnderAchieverAboutAddonDescriptionText", "ARTWORK", "GameFontHighlight");
UA.about.addon.descText:SetPoint("TOPLEFT", UA.about.addon.descLabel, "TOPRIGHT", 10, 0);
UA.about.addon.descText:SetPoint("RIGHT", UA.about.addon, "RIGHT", -10, 0);
UA.about.addon.descText:SetPoint("BOTTOM", UA.about.addon, "BOTTOM", 10, 0);
UA.about.addon.descText:SetText("UnderAchiever is an AddOn that allows players to fake achievement links automatically. Players can also create replacement texts, which are exchanged for achievement links when typing a chat message.");
UA.about.addon.descText:SetJustifyH("LEFT");
UA.about.addon.descText:SetJustifyV("TOP");


-- Aelobin
UA.about.author = CreateFrame("Frame","UnderAchieverAboutAuthor",UA.about);
UA.about.author:SetPoint("TOPLEFT", UA.about.addon, "BOTTOMLEFT", 0, -5);
UA.about.author:SetWidth(300);
UA.about.author:SetHeight(160);
UA.about.author:SetBackdrop({ 
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, 
	insets = { left = 5, right = 5, top = 5, bottom = 5 }
});

UA.about.author.texture = UA.about.author:CreateTexture("UnderAchieverAboutAuthorTexture", "ARTWORK");
UA.about.author.texture:SetPoint("TOPLEFT", UA.about.author, 10, -15);
UA.about.author.texture:SetHeight(128);
UA.about.author.texture:SetWidth(128);
UA.about.author.texture:SetTexture("Interface\\AddOns\\UnderAchiever\\Textures\\Aelo");

UA.about.author.titleLabel = UA.about.author:CreateFontString("UnderAchieverAboutAuthorTitleLabel", "ARTWORK", "GameFontNormal");
UA.about.author.titleLabel:SetPoint("TOPLEFT", UA.about.author.texture, "TOPRIGHT", 10, 0);
UA.about.author.titleLabel:SetText("Author:");

UA.about.author.titleText = UA.about.author:CreateFontString("UnderAchieverAboutAuthorTitleText", "ARTWORK", "GameFontHighlight");
UA.about.author.titleText:SetPoint("TOPLEFT", UA.about.author.titleLabel, "TOPRIGHT", 10, 0);
UA.about.author.titleText:SetText("Aelobin");


-- Reset buttons
UA.about.reset = CreateFrame("Frame","UnderAchieverAboutReset",UA.about);
UA.about.reset:SetPoint("TOPLEFT", UA.about.author, "TOPRIGHT", 5, 0);
UA.about.reset:SetPoint("RIGHT", UA.about, -15, 0);
UA.about.reset:SetPoint("BOTTOM", UA.about.author, "BOTTOM");
UA.about.reset:SetBackdrop({ 
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, 
	insets = { left = 5, right = 5, top = 5, bottom = 5 }
});

UA.about.reset.options = CreateFrame("Button","UnderAchieverAboutResetOptions",UA.about.reset,"OptionsButtonTemplate");
UA.about.reset.options:SetPoint("TOPLEFT",UA.about.reset,"TOPLEFT",5,-10);
UA.about.reset.options:SetPoint("RIGHT",UA.about.reset,"RIGHT",-5,0);
UA.about.reset.options:SetText("Default Options");
UA.about.reset.options:SetScript("OnClick",function()
	UA_Settings.min_value = 7;
	UA_Settings.min_type = 1;
	UA_Settings.max_value = 14;
	UA_Settings.max_type = 1;
	UA_Settings.state = true;
	UA_Settings.default = 1;
	UA_Settings.saves = false;
	UA_Settings.date = true;
	UA_Settings.real = false;
	UA_Settings.disable = false;
	UA.print("Options have been reset to defaults.");
end);

UA.about.reset.saves = CreateFrame("Button","UnderAchieverAboutResetSaves",UA.about.reset,"OptionsButtonTemplate");
UA.about.reset.saves:SetPoint("TOPLEFT",UA.about.reset.options,"BOTTOMLEFT",0,0);
UA.about.reset.saves:SetPoint("RIGHT",UA.about.reset,"RIGHT",-5,0);
UA.about.reset.saves:SetText("Clear Advanced Saves");
UA.about.reset.saves:SetScript("OnClick",function()
	UA_Saves = {};
	UA.print("All advanced saves have been deleted.");
end);

UA.about.reset.replacements = CreateFrame("Button","UnderAchieverAboutResetReplacements",UA.about.reset,"OptionsButtonTemplate");
UA.about.reset.replacements:SetPoint("TOPLEFT",UA.about.reset.saves,"BOTTOMLEFT",0,0);
UA.about.reset.replacements:SetPoint("RIGHT",UA.about.reset,"RIGHT",-5,0);
UA.about.reset.replacements:SetText("Default Replacements");
UA.about.reset.replacements:SetScript("OnClick",function()
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
	UA.print("Replacements have been reset to defaults.");
end);

UA.about.reset.disabledExceptions = CreateFrame("Button","UnderAchieverAboutResetDisabledExceptions",UA.about.reset,"OptionsButtonTemplate");
UA.about.reset.disabledExceptions:SetPoint("TOPLEFT",UA.about.reset.replacements,"BOTTOMLEFT",0,0);
UA.about.reset.disabledExceptions:SetPoint("RIGHT",UA.about.reset,"RIGHT",-5,0);
UA.about.reset.disabledExceptions:SetText("Clear Disabled Exceptions");
UA.about.reset.disabledExceptions:SetScript("OnClick",function()
	UA_Exceptions_Disabled = {};
	UA.print("All disabled exceptions have been deleted.");
end);

UA.about.reset.enabledExceptions = CreateFrame("Button","UnderAchieverAboutResetEnabledExceptions",UA.about.reset,"OptionsButtonTemplate");
UA.about.reset.enabledExceptions:SetPoint("TOPLEFT",UA.about.reset.disabledExceptions,"BOTTOMLEFT",0,0);
UA.about.reset.enabledExceptions:SetPoint("RIGHT",UA.about.reset,"RIGHT",-5,0);
UA.about.reset.enabledExceptions:SetText("Clear Enabled Exceptions");
UA.about.reset.enabledExceptions:SetScript("OnClick",function()
	UA_Exceptions_Enabled = {};
	UA.print("All enabled exceptions have been deleted.");
end);

UA.about.reset.all = CreateFrame("Button","UnderAchieverAboutResetAll",UA.about.reset,"OptionsButtonTemplate");
UA.about.reset.all:SetPoint("LEFT",UA.about.reset.enabledExceptions,"LEFT");
UA.about.reset.all:SetPoint("RIGHT",UA.about.reset.enabledExceptions,"RIGHT");
UA.about.reset.all:SetPoint("BOTTOM",UA.about.reset,"BOTTOM", 0, 10);
UA.about.reset.all:SetText("Reset/Clear All");
UA.about.reset.all:SetScript("OnClick",function()
	UA_Settings.min_value = 7;
	UA_Settings.min_type = 1;
	UA_Settings.max_value = 14;
	UA_Settings.max_type = 1;
	UA_Settings.state = true;
	UA_Settings.default = 1;
	UA_Settings.saves = false;
	UA_Settings.date = true;
	UA_Settings.real = false;
	UA_Settings.disable = false;
	
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
	
	UA.print("UnderAchiever has been reset to defaults.");
end);