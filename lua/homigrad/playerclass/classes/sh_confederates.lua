local CLASS = player.RegClass("confederates")

function CLASS.Off(self)
    if CLIENT then return end
end

local models = {
    "models/humans/civilwar/male_06.mdl",
    "models/humans/civilwar/male_07.mdl",
    "models/humans/civilwar/male_08.mdl",
    "models/humans/civilwar/male_09.mdl"
}

if SERVER then
    for _, m in ipairs(models) do util.PrecacheModel(m) end
end

function CLASS.On(self, data)
    if CLIENT then return end
    ApplyAppearance(self,nil,nil,nil,true)
    local Appearance = self.CurAppearance or hg.Appearance.GetRandomAppearance()
    Appearance.AAttachments = ""
    Appearance.AClothes = ""
    self:SetNetVar("Accessories", "")
    self.CurAppearance = Appearance
    self:SetModel(models[math.random(#models)])
    self:SetMaterial("")
    self:SetColor(color_white)
    self:DrawShadow(true)
    self:SetRenderMode(RENDERMODE_NORMAL)
    self:SetSubMaterial()
    zb.GiveRole(self, "Confederate", Color(120,60,60))
    if not (data and data.bNoEquipment) then
        self:PlayerClassEvent("GiveEquipment")
    end
end

function CLASS.GiveEquipment(self)
    self:Give("weapon_hands_sh")
    local gun = self:Give("weapon_musket")
    if IsValid(gun) and gun.GetPrimaryAmmoType and gun:GetPrimaryAmmoType() then
        self:GiveAmmo(0, gun:GetPrimaryAmmoType(), true)
    end
    for i=1,20 do
        local ent = ents.Create("ent_ammo_metallicball")
        if IsValid(ent) then
            ent:SetPos(self:GetPos() + Vector(0,0,5))
            ent:Spawn()
            ent:Use(self)
        end
    end
    self:Give("weapon_bandage_sh")
    self:Give("weapon_bigbandage_sh")
    self:Give("weapon_hg_machete")
end

function CLASS.Guilt(self, Victim)
    if CLIENT then return end
    if Victim:GetPlayerClass() == self:GetPlayerClass() then
        return 1
    end
    return 1
end
