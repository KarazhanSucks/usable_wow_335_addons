local GUI = LibStub("AceGUI-3.0");

local frame = GUI:Create("Frame", "Reagent Restocker");
frame:SetTitle("Reagent Restocker");
frame:SetLayout("Flow");
frame.name="Reagent Restocker";

InterfaceOptions_AddCategory(frame);
