MODE.name = "civilwar"

local MODE = MODE

net.Receive("civilwar_start", function()
    if CivilWarSound then
        CivilWarSound:Stop()
        CivilWarSound = nil
    end

    local candidates = {
        "sound/zbattle/civilwar.wav",
        "sound/zbattle/civilwar.mp4",
        "sound/civilwar.wav",
        "sound/civilwar.mp4",
    }

    local function tryPlay(i)
        if i > #candidates then return end
        local path = candidates[i]
        sound.PlayFile(path, "noplay", function(station)
            if IsValid(station) then
                station:SetVolume(6)
                station:Play()
                CivilWarSound = station
            else
                tryPlay(i + 1)
            end
        end)
    end

    tryPlay(1)

    zb.RemoveFade()
end)

local teams = {
	[0] = {
		objective = "Fight the scum that want to take our freedom!",
		name = "Confederate",
		color1 = Color(150,60,60),
		color2 = Color(150,60,60)
	},
	[1] = {
		objective = "Fight off the slave-keeping rebels!",
		name = "Union",
		color1 = Color(60,90,150),
		color2 = Color(60,90,150)
	},
}

function MODE:RenderScreenspaceEffects()
    if zb.ROUND_START + 7.5 < CurTime() then return end
    local fade = math.Clamp(zb.ROUND_START + 7.5 - CurTime(),0,1)

    surface.SetDrawColor(0,0,0,255 * fade)
    surface.DrawRect(-1,-1,ScrW() + 1,ScrH() + 1)
end

function MODE:HUDPaint()
    if zb.ROUND_START + 8.5 < CurTime() then return end
	if not lply:Alive() then return end
	zb.RemoveFade()
    local fade = math.Clamp(zb.ROUND_START + 8 - CurTime(),0,1)
	local team_ = lply:Team()
    draw.SimpleText("The Civil War!", "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.1, Color(200,200,255, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    local RoleColor = teams[team_] and teams[team_].color1 or color_white
    RoleColor.a = 255 * fade
    local desc = teams[team_] and teams[team_].objective or ""
    draw.SimpleText(desc, "ZB_HomicideMedium", sw * 0.5, sh * 0.15, RoleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end
