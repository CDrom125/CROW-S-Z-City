local MODE = MODE

MODE.name = "terror"

local teams = {
    [1] = {
        name = "Terrorists",
        color = Color(200, 0, 0),
        objective = "Eliminate all non-believers!"
    },
    [2] = {
        name = "Police",
        color = Color(0, 0, 200),
        objective = "Protect the innocents and neutralize the threat!"
    },
    [3] = {
        name = "Innocent",
        color = Color(0, 200, 0),
        objective = "Survive the attack!"
    }
}

net.Receive("terror_start", function()
    -- Stop previous music if playing
    if IsValid(MODE.StartMusic) then MODE.StartMusic:Stop() end
    if IsValid(MODE.SwatMusic) then MODE.SwatMusic:Stop() end

    -- Play start music
    sound.PlayFile("sound/start.wav", "noplay", function(station, errID, errName)
        if IsValid(station) then
            MODE.StartMusic = station
            local vol = GetConVar("snd_musicvolume"):GetFloat() or 1
            station:SetVolume(0.5 * vol)
            station:Play()
        else
            print("[Terrorist Threat] Failed to play start music: sound/start.wav", errID, errName)
        end
    end)
    
    zb.RemoveFade()
end)

net.Receive("terror_swat_arrival", function()
    -- Stop start music if it's still playing
    if IsValid(MODE.StartMusic) then MODE.StartMusic:Stop() end

    -- Play SWAT music
    sound.PlayFile("sound/swatmusic.wav", "noplay", function(station, errID, errName)
        if IsValid(station) then
            MODE.SwatMusic = station
            local vol = GetConVar("snd_musicvolume"):GetFloat() or 1
            station:SetVolume(1.0 * vol)
            station:Play()
        else
            print("[Terrorist Threat] Failed to play SWAT music: sound/swatmusic.wav", errID, errName)
        end
    end)
    
    -- Show "SWAT Arrived!" text
    hook.Add("HUDPaint", "TerrorSWATText", function()
        draw.SimpleText("SWAT Arrived!", "ZB_HomicideLarge", ScrW() * 0.5, ScrH() * 0.2, Color(0, 0, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end)
    
    timer.Simple(5, function()
        hook.Remove("HUDPaint", "TerrorSWATText")
    end)
end)

net.Receive("terror_roundend", function()
    local winner = net.ReadInt(4)
    
    local text = "Round Draw"
    local col = Color(255, 255, 255)
    
    if winner == 1 then
        text = "Terrorists Win!"
        col = Color(200, 0, 0)
    elseif winner == 2 then
        text = "Police & Innocents Win!"
        col = Color(0, 0, 200)
    end
    
    hook.Add("HUDPaint", "TerrorEndScreen", function()
        draw.SimpleText(text, "ZB_HomicideLarge", ScrW() * 0.5, ScrH() * 0.4, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end)
    
    timer.Simple(10, function()
        hook.Remove("HUDPaint", "TerrorEndScreen")
    end)
end)

function MODE:HUDPaint()
    if zb.ROUND_START + 8.5 < CurTime() then return end
    if not LocalPlayer():Alive() then return end
    
    zb.RemoveFade()
    local fade = math.Clamp(zb.ROUND_START + 8 - CurTime(), 0, 1)
    local team_ = LocalPlayer():Team()
    
    draw.SimpleText("Terrorist Threat", "ZB_HomicideMediumLarge", ScrW() * 0.5, ScrH() * 0.1, Color(200, 200, 255, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    local tInfo = teams[team_]
    if tInfo then
        local RoleColor = table.Copy(tInfo.color)
        RoleColor.a = 255 * fade
        draw.SimpleText(tInfo.objective, "ZB_HomicideMedium", ScrW() * 0.5, ScrH() * 0.15, RoleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end
