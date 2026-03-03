if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_hg_grenade_tpik"
SWEP.PrintName = "Chicken Grenade"
SWEP.Category = "Weapons - Explosive"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Wait = 2
SWEP.Primary.Next = 0
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.HoldType = "camera"
SWEP.ViewModel = ""
SWEP.WorkWithFake = true
SWEP.WorldModel = "models/props_junk/PopCan01a.mdl"
SWEP.ENT = "ent_chickennade"

function SWEP:Initialize()
	self.BaseClass.Initialize(self)
	self.count = 999999
end
