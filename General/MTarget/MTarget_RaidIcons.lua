--[[
  MTarget - Raid Icons Functions ($Id$)
  Written by gameldar
  http://www.wowace.com/projects/mtarget

  Thanks to:
    Ace3: Great lib framework
  ]]--

function MTarget:RaidIcons_OnInitialize()
  MTarget.raidtargets = {
    "star",
    "circle",
    "diamond",
    "triangle",
    "moon",
    "square",
    "cross",
    "skull",
  };
  MTarget:SecureHook("SetRaidTarget");
end

function MTarget:SetRaidTarget(unit, index)
  if (MTarget.db.profile.raidtargets and MTarget.raidtargets[index]) then
    MTarget:SetVariable(MTarget.raidtargets[index], UnitName(unit));
  end
end