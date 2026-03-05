SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Useless gun"
SWEP.Author = "ZCity"
SWEP.Instructions = "Absolutely useless, what's the point of shooting anyone with this?"
SWEP.Category = "Weapons - Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/salat_port/slugcat_figure.mdl"
SWEP.WorldModelFake = "models/salat_port/slugcat_figure.mdl"

SWEP.FakePos = Vector(1, 1.005, -1.21)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.AttachmentPos = Vector(-1.6,-0.1,0)
SWEP.AttachmentAng = Angle(0,0,0)

SWEP.DOZVUK = true

SWEP.ScrappersSlot = "Secondary"
SWEP.weight = 1
SWEP.punchmul = 0
SWEP.punchspeed = 1
SWEP.CustomShell = "9x19"
SWEP.norecoil = true
SWEP.NoWINCHESTERFIRE = true

SWEP.LocalMuzzlePos = Vector(5.767,0.001,2.28)
SWEP.LocalMuzzleAng = Angle(0.7,-0.1,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.weaponInvCategory = 2
SWEP.ShellEject = "EjectBrass_9mm"
SWEP.Primary.ClipSize = 5
SWEP.Primary.DefaultClip = 5
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "9x19 mm Parabellum"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 1
SWEP.Primary.Force = 5
SWEP.Primary.Wait = 1
SWEP.ReloadTime = 2.2
SWEP.ReloadSoundes = {
	"none",
	"none",
	"none",
	"none",
	"none",
	"none",
	"none",
	"none",
	"none"
}

SWEP.PPSMuzzleEffect = "pcf_jack_mf_tpistol"
SWEP.DeploySnd = {"homigrad/weapons/draw_pistol.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/holster_pistol.mp3", 55, 100, 110}
SWEP.HoldType = "revolver"
SWEP.ZoomPos = Vector(-3, -0.0136, 2.9594)
SWEP.RHandPos = Vector(-2, 0, 0)
SWEP.LHandPos = false
SWEP.SprayRand = {Angle(0, 0, 0), Angle(0, 0, 0)}
SWEP.Ergonomics = 1
SWEP.AnimShootMul = 1
SWEP.AnimShootHandMul = 0.1
SWEP.addSprayMul = 0
SWEP.Penetration = 0
SWEP.WorldPos = Vector(4,-1.5,-2)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(0, 0, 0)
SWEP.attAng = Angle(-0.1,-0.9,0)
SWEP.lengthSub = 5
SWEP.DistSound = ""

SWEP.holsteredBone = "ValveBiped.Bip01_R_Thigh"
SWEP.holsteredPos = Vector(0, -2, 1)
SWEP.holsteredAng = Angle(0, 20, 30)
SWEP.shouldntDrawHolstered = true

SWEP.ShockMultiplier = 0.5
SWEP.HurtMultiplier = 0.1
SWEP.PainMultiplier = 0.5

SWEP.DamageMultiplier = 0.02

function SWEP:InitializePost()
	self.Primary.Wait = 1
	self.Primary.Automatic = false
end

