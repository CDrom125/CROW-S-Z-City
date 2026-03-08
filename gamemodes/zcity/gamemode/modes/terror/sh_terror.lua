local MODE = MODE

MODE.name = "terror"
MODE.PrintName = "Terrorist Threat"
MODE.LootSpawn = false
MODE.ForBigMaps = false
MODE.Chance = 0.03
MODE.OverideSpawnPos = true

function MODE.GuiltCheck(Attacker, Victim, add, harm, amt)
	local attTeam = Attacker:Team()
	local vicTeam = Victim:Team()

	-- Terrorists (Team 1) kill anyone without karma loss
	if attTeam == 1 then
		return 0, false
	end

	-- Police (Team 2) kill Terrorists (Team 1) without karma loss
	if attTeam == 2 and vicTeam == 1 then
		return 0, false
	end

	-- Police (Team 2) kill Innocents (Team 3) with karma loss
	if attTeam == 2 and vicTeam == 3 then
		return 1, true
	end

	-- Police (Team 2) kill Police (Team 2) with karma loss (Friendly Fire)
	if attTeam == 2 and vicTeam == 2 then
		return 1, true
	end

	-- Innocents (Team 3) kill Terrorists (Team 1) without karma loss
	if attTeam == 3 and vicTeam == 1 then
		return 0, false
	end

	-- Innocents (Team 3) kill Innocents (Team 3) or Police (Team 2) with karma loss
	if attTeam == 3 and (vicTeam == 3 or vicTeam == 2) then
		return 1, true
	end

	-- SWAT (Team 4, handled as Police logic usually, or separate Team 4 if implemented)
	-- Assuming SWAT joins Police team (Team 2) or uses separate Team 4
	-- If separate Team 4:
	if attTeam == 4 and vicTeam == 1 then return 0, false end
	if attTeam == 4 and (vicTeam == 3 or vicTeam == 2 or vicTeam == 4) then return 1, true end

	return 1, true
end

if SERVER then
	util.AddNetworkString("terror_start")
	util.AddNetworkString("terror_roundend")
	util.AddNetworkString("terror_swat_arrival")
end
