MODE.name = "civilwar"
MODE.PrintName = "The Civil War!"

MODE.OverideSpawnPos = true
MODE.LootSpawn = false
MODE.ForBigMaps = false
MODE.Chance = 0.03

util.AddNetworkString("civilwar_start")
util.AddNetworkString("civilwar_roundend")

function MODE.GuiltCheck(Attacker, Victim, add, harm, amt)
    return 1, true
end

function MODE:Intermission()
    game.CleanUpMap()

	for i, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end
		ply:SetupTeam(ply:Team())
	end

    net.Start("civilwar_start")
    net.Broadcast()
end

function MODE:CheckAlivePlayers()
    local confederates = {}
    local union = {}

    for _, ply in ipairs(team.GetPlayers(0)) do
        if ply:Alive() and not ply:GetNetVar("handcuffed", false) then
            table.insert(confederates, ply)
        end
    end

    for _, ply in ipairs(team.GetPlayers(1)) do
        if ply:Alive() and not ply:GetNetVar("handcuffed", false) then
            table.insert(union, ply)
        end
    end

    return {confederates, union}
end

function MODE:EndRound()
    timer.Simple(2,function()
        net.Start("civilwar_roundend")
        net.Broadcast()
    end)
end

function MODE:ShouldRoundEnd()
    local endround = zb:CheckWinner(self:CheckAlivePlayers())
    return endround
end

function MODE:RoundStart()
end

local function GiveRiflemanLoadout(ply)
    ply:Give("weapon_hands_sh")
    local gun = ply:Give("weapon_musket")
    if IsValid(gun) and gun.GetPrimaryAmmoType and gun:GetPrimaryAmmoType() then
        ply:GiveAmmo(0, gun:GetPrimaryAmmoType(), true)
    end

    for i=1,20 do
        local ent = ents.Create("ent_ammo_metallicball")
        if IsValid(ent) then
            ent:SetPos(ply:GetPos() + Vector(0,0,5))
            ent:Spawn()
            ent:Use(ply)
        end
    end

    ply:Give("weapon_bandage_sh")
    ply:Give("weapon_bigbandage_sh")
    ply:Give("weapon_hg_machete")
end

function MODE:GiveEquipment()
    local players = player.GetAll()
    table.Shuffle(players)

    local numPlayers = #players
    local half = math.max(math.floor(numPlayers / 2), 1)

    for i, ply in ipairs(players) do
        if ply:Team() == TEAM_SPECTATOR then continue end

        if i <= half then
            ply:SetupTeam(0)
            ply:SetPlayerClass("Rebel", {bNoEquipment = true})
            zb.GiveRole(ply, "Confederate", Color(120, 60, 60))
        else
            ply:SetupTeam(1)
            ply:SetPlayerClass("commanderforces", {bNoEquipment = true})
            zb.GiveRole(ply, "Union", Color(60, 90, 150))
        end

        local inv = ply:GetNetVar("Inventory") or {}
        inv["Weapons"] = inv["Weapons"] or {}
        inv["Weapons"]["hg_sling"] = true
        ply:SetNetVar("Inventory", inv)

        GiveRiflemanLoadout(ply)

        local hands = ply:Give("weapon_hands_sh")
        ply:SelectWeapon("weapon_hands_sh")

        timer.Simple(0.1, function()
            if IsValid(ply) then
                ply.noSound = false
                ply:SetSuppressPickupNotices(false)
            end
        end)
    end
end

function MODE:GetTeamSpawn()
    local t0 = zb.TranslatePointsToVectors(zb.GetMapPoints("CIVIL_TDM_CONFED"))
    local t1 = zb.TranslatePointsToVectors(zb.GetMapPoints("CIVIL_TDM_UNION"))

    if (not t0 or #t0 == 0) and (not t1 or #t1 == 0) then
        return zb.TranslatePointsToVectors(zb.GetMapPoints("HMCD_TDM_T")), zb.TranslatePointsToVectors(zb.GetMapPoints("HMCD_TDM_CT"))
    end

    return t0, t1
end

function MODE:RoundThink()
end

function MODE:CanLaunch()
    local activePlayers = 0
    for _, ply in player.Iterator() do
        if ply:Team() ~= TEAM_SPECTATOR then
            activePlayers = activePlayers + 1
        end
    end
    if activePlayers < 4 then
        return false
    end
    return true
end

return MODE
