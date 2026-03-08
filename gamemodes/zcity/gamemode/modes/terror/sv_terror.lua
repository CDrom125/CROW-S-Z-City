local MODE = MODE

MODE.name = "terror"
MODE.PrintName = "Terrorist Threat"
MODE.LootSpawn = false
MODE.ForBigMaps = false
MODE.Chance = 0.03
MODE.OverideSpawnPos = true

util.AddNetworkString("terror_start")
util.AddNetworkString("terror_roundend")
util.AddNetworkString("terror_swat_arrival")

function MODE.GuiltCheck(Attacker, Victim, add, harm, amt)
    if Attacker:Team() == 1 then return 0, false end -- Terrorists kill freely
    if Attacker:Team() == 2 and Victim:Team() == 1 then return 0, false end -- Police kill Terrorists freely
    if Attacker:Team() == 2 and Victim:Team() == 3 then return 1, true end -- Police kill Innocents -> Karma loss
    if Attacker:Team() == 2 and Victim:Team() == 2 then return 1, true end -- Police kill Police -> Karma loss
    if Attacker:Team() == 3 and Victim:Team() == 1 then return 0, false end -- Innocents kill Terrorists freely
    if Attacker:Team() == 3 and (Victim:Team() == 3 or Victim:Team() == 2) then return 1, true end -- Innocents kill Innocents/Police -> Karma loss
    return 1, true
end

function MODE:Intermission()
    game.CleanUpMap()
    for i, ply in player.Iterator() do
        if ply:Team() == TEAM_SPECTATOR then continue end
        ply:SetupTeam(ply:Team())
    end
    net.Start("terror_start")
    net.Broadcast()
end

function MODE:CheckAlivePlayers()
    local terrorists = {}
    local police = {}
    local innocents = {}

    for _, ply in ipairs(team.GetPlayers(1)) do
        if ply:Alive() and not ply:GetNetVar("handcuffed", false) then
            table.insert(terrorists, ply)
        end
    end
    for _, ply in ipairs(team.GetPlayers(2)) do
        if ply:Alive() and not ply:GetNetVar("handcuffed", false) then
            table.insert(police, ply)
        end
    end
    for _, ply in ipairs(team.GetPlayers(3)) do
        if ply:Alive() and not ply:GetNetVar("handcuffed", false) then
            table.insert(innocents, ply)
        end
    end

    return {terrorists, police, innocents}
end

function MODE:EndRound()
    local result = self:CheckAlivePlayers()
    local terrorists = result[1]
    local police = result[2]
    local innocents = result[3]
    
    local winner = 0 -- 0: Draw/None, 1: Terrorists, 2: Police/Innocents
    
    if #terrorists == 0 and (#police > 0 or #innocents > 0) then
        winner = 2
    elseif #police == 0 and #innocents == 0 and #terrorists > 0 then
        winner = 1
    end

    timer.Simple(2, function()
        net.Start("terror_roundend")
        net.WriteInt(winner, 4)
        net.Broadcast()
    end)
end

function MODE:ShouldRoundEnd()
    local result = self:CheckAlivePlayers()
    local terrorists = result[1]
    local police = result[2]
    local innocents = result[3]

    if #terrorists == 0 then return true end
    if #police == 0 and #innocents == 0 then return true end
    
    return false
end

function MODE:RoundStart()
    self.SWATArrived = false
    self.SWATTime = CurTime() + math.random(120, 180)
end

function MODE:AssignTeams()
    local players = player.GetAll()
    local numPlayers = #players
    table.Shuffle(players)

    local numTerrorists = math.Clamp(math.ceil(numPlayers / 6), 1, 4)
    local numPolice = math.Clamp(math.ceil(numPlayers / 6), 1, 4)
    
    local terrorIdx = 0
    local policeIdx = 0
    
    for i, ply in ipairs(players) do
        if ply:Team() == TEAM_SPECTATOR then continue end
        
        if terrorIdx < numTerrorists then
            ply:SetTeam(1) -- Terrorist
            ply:SetPlayerClass("terrorist")
            zb.GiveRole(ply, "Terrorist", Color(200, 0, 0))
            terrorIdx = terrorIdx + 1
        elseif policeIdx < numPolice then
            ply:SetTeam(2) -- Police
            ply:SetPlayerClass("police")
            zb.GiveRole(ply, "Police", Color(0, 0, 200))
            policeIdx = policeIdx + 1
        else
            ply:SetTeam(3) -- Innocent
            ply:SetPlayerClass("default") -- Or citizen
            zb.GiveRole(ply, "Innocent", Color(0, 200, 0))
        end
    end
end

function MODE:GiveEquipment()
    self:AssignTeams()

    local terrorists = team.GetPlayers(1)
    local police = team.GetPlayers(2)
    local innocents = team.GetPlayers(3)
    
    -- Spawn Points
    local tSpawns, ctSpawns = self:GetTeamSpawn()
    local tSpawn = (tSpawns and #tSpawns > 0) and tSpawns[math.random(#tSpawns)] or zb:GetRandomSpawn()
    local ctSpawn = (ctSpawns and #ctSpawns > 0) and ctSpawns[math.random(#ctSpawns)] or zb:GetRandomSpawn()

    -- Terrorist Loadout & Spawn
    local rgdGiven = false
    local iedGiven = false
    
    for i, ply in ipairs(terrorists) do
        -- Set Position (Grouped)
        if tSpawn then
            ply:SetPos(hg.tpPlayer(tSpawn, ply, i, 0))
        end

        ply:Give("weapon_hands_sh")
        local ak = ply:Give("weapon_ak74")
        if IsValid(ak) then ply:GiveAmmo(60, ak:GetPrimaryAmmoType(), true) end
        
        local mak = ply:Give("weapon_makarov")
        if IsValid(mak) then ply:GiveAmmo(16, mak:GetPrimaryAmmoType(), true) end
        
        ply:Give("weapon_ducttape")
        hg.AddArmor(ply, "ent_armor_helmet7")
        hg.AddArmor(ply, "ent_armor_vest4")
        
        if not rgdGiven then
            ply:Give("weapon_hg_rgd_tpik")
            rgdGiven = true
        elseif not iedGiven then
            ply:Give("weapon_traitor_ied")
            iedGiven = true
        end
    end
    
    -- Police Loadout & Spawn
    for i, ply in ipairs(police) do
        -- Set Position (Grouped)
        if ctSpawn then
            ply:SetPos(hg.tpPlayer(ctSpawn, ply, i, 0))
        end

        ply:Give("weapon_hands_sh")
        hg.AddArmor(ply, "ent_armor_vest2")
        hg.AddArmor(ply, "ent_armor_helmet3")
        
        local glock = ply:Give("weapon_glock17")
        if IsValid(glock) then ply:GiveAmmo(34, glock:GetPrimaryAmmoType(), true) end
        
        local taser = ply:Give("weapon_taser")
        if IsValid(taser) then ply:GiveAmmo(2, taser:GetPrimaryAmmoType(), true) end
        
        ply:Give("weapon_handcuffs")
        ply:Give("weapon_handcuffs_key")
        ply:Give("weapon_hg_tonfa")
    end
    
    -- Innocent Loadout & Spawn (Random)
    for _, ply in ipairs(innocents) do
        -- Set Position (Random)
        local randSpawn = zb:GetRandomSpawn(ply)
        if randSpawn then ply:SetPos(randSpawn) end

        ply:Give("weapon_hands_sh")
    end
end

function MODE:RoundThink()
    if not self.SWATArrived and CurTime() > self.SWATTime then
        self.SWATArrived = true
        
        net.Start("terror_swat_arrival")
        net.Broadcast()
        
        local deadPlayers = {}
        for _, ply in player.Iterator() do
            if not ply:Alive() and ply:Team() ~= TEAM_SPECTATOR then
                table.insert(deadPlayers, ply)
            end
        end
        
        local spawns = self:GetTeamSpawn() -- Returns T, CT spawns
        local ctSpawns = spawns[2] -- Use CT spawns for SWAT
        
        local ramGiven = false
        local revolverGiven = false
        local benelliGiven = false
        
        for i, ply in ipairs(deadPlayers) do
            ply:Spawn()
            ply:SetTeam(2) -- Join Police team
            ply:SetPlayerClass("swat")
            zb.GiveRole(ply, "SWAT", Color(0, 0, 200))
            
            -- TP to CT spawn
            if ctSpawns and #ctSpawns > 0 then
                ply:SetPos(ctSpawns[math.random(#ctSpawns)])
            end
            
            -- Loadout
            ply:StripWeapons()
            ply:Give("weapon_hands_sh")
            hg.AddArmor(ply, "ent_armor_helmet6")
            hg.AddArmor(ply, "ent_armor_vest8")
            ply:Give("weapon_sogknife")
            ply:Give("weapon_hg_flashbang_tpik")
            ply:Give("weapon_breachcharge")
            ply:Give("weapon_medkit_sh")
            
            if not ramGiven then
                ply:Give("weapon_ram")
                ramGiven = true
            end
            
            -- Primary
            if not benelliGiven then
                ply:Give("weapon_benelli")
                ply:GiveAmmo(12, "Buckshot", true)
                benelliGiven = true
            else
                local m4 = ply:Give("weapon_m4a1")
                if IsValid(m4) then
                    hg.AddAttachmentForce(ply, m4, "ent_att_laser1")
                    hg.AddAttachmentForce(ply, m4, "ent_att_holo14")
                    hg.AddAttachmentForce(ply, m4, "ent_att_grip3")
                    ply:GiveAmmo(60, m4:GetPrimaryAmmoType(), true)
                end
            end
            
            -- Secondary
            if not revolverGiven then
                local rev = ply:Give("weapon_revolversh12")
                if IsValid(rev) then ply:GiveAmmo(10, rev:GetPrimaryAmmoType(), true) end
                revolverGiven = true
            else
                local fn57 = ply:Give("weapon_fn57")
                if IsValid(fn57) then ply:GiveAmmo(20, fn57:GetPrimaryAmmoType(), true) end
            end
        end
    end
end

function MODE:GetTeamSpawn()
    local function pts(name)
        return zb.TranslatePointsToVectors(zb.GetMapPoints(name))
    end
    -- Use Civil War / Homicide TDM points
    local tSpawn = pts("HMCD_TDM_T")
    local ctSpawn = pts("HMCD_TDM_CT")
    
    if (not tSpawn or #tSpawn == 0) then tSpawn = pts("HMCD_CRI_T") end
    if (not ctSpawn or #ctSpawn == 0) then ctSpawn = pts("HMCD_CRI_CT") end
    
    -- Fallback to random
    if not tSpawn or #tSpawn == 0 then tSpawn = {zb:GetRandomSpawn()} end
    if not ctSpawn or #ctSpawn == 0 then ctSpawn = {zb:GetRandomSpawn()} end
    
    return tSpawn, ctSpawn
end

function MODE:CanLaunch()
    local activePlayers = 0
    for _, ply in player.Iterator() do
        if ply:Team() ~= TEAM_SPECTATOR then
            activePlayers = activePlayers + 1
        end
    end
    if activePlayers < 4 then return false end
    return true
end

return MODE
