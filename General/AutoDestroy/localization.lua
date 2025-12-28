AUTODESTROY_VERSION = tonumber(GetAddOnMetadata("AutoDestroy", "Version"));

AUTODESTROY_LOGIN = "|c00ffff00Auto Destroy|r v|c0000ffff"..AUTODESTROY_VERSION.."|r AddOn loaded.  |c0000ff00/ad|r to use";
AUTODESTROY_REFUSING = "Refusing to delete ";
AUTODESTROY_DESTROYING = "Destroying ";
AUTODESTROY_REQUIRESLEVEL = "Requires Level";
AUTODESTROY_RECEIVELOOT = "You receive loot:";
AUTODESTROY_REFUSETOADD = "Refusing to add epic or greater quality item to destroy list";
AUTODESTROY_ADDEDTOLIST = " added to destroy list";

AUTODESTROY_WEAPONS = {
	["Axe"] = 1,
	["Mace"] = 1,
	["Sword"] = 1,
	["Dagger"] = 1,
	["Polearm"] = 1,
	["Gun"] = 1,
	["Bow"] = 1,
	["Staff"] = 1,
	["Wand"] = 1,
	["Shield"] = 1,
	["Held In Off-hand"] = 1,
};
AUTODESTROY_ARMOR = {
	["Mail"] = 1,
	["Cloth"] = 1,
	["Leather"] = 1,
	["Plate"] = 1,
	["Back"] = 1,
};

AUTODESTROY_ENABLE = "Enable";
AUTODESTROY_SETZONEBUTTON = "Set to Current";
AUTODESTROY_WEAPONTHRESHOLD = "Weapon Destruction Threshold";
AUTODESTROY_ARMORTHRESHOLD = "Armor Destruction Threshold";
AUTODESTROY_ALWAYSDESTROYLIST = "Always Destroy List";

AUTODESTROY_COLORS_TEXT = {
	[0] = "NONE",
	[1] = "gray",
	[2] = "white",
	[3] = "green",
	[4] = "blue",
	[5] = "purple",
};

AUTODESTROY_TOOLTIP1 = "Enable Auto Destroy";
AUTODESTROY_TOOLTIP2 = "The name of the zone this add on will function in.  This pain in the ass implemented as one of many safeguards to prevent unwanted destruction";
AUTODESTROY_TOOLTIP3 = "Destroy only weapons and armor below this level";
AUTODESTROY_TOOLTIP4 = "Destroy weapons of this quality and below";
AUTODESTROY_TOOLTIP5 = "Destroy armor of this quality and below";
AUTODESTROY_TOOLTIP6 = "Enter the names of the non-weapons/armor items to destroy here, one item name per line.  Or Alt + Click items in your inventory to add them to this list.  These items will *ALWAYS* be destroyed, regardless of quality or level.  Be extremely careful what you enter here.  Item names are case sensitive.  (Note this will also destroy weapons/armor)";


if ( GetLocale() == "deDE" ) then
end

if ( GetLocale() == "frFR" ) then
end
