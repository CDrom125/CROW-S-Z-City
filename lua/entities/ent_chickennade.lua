AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"

function ENT:Initialize()
	if SERVER then
		self:SetModel("models/props_junk/garbage_metalcan002a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
		end
	end
end

function ENT:PhysicsCollide(data, phys)
	if SERVER then
		local pos = data.HitPos or self:GetPos()
		local ang = Angle(0, 0, 0)
		local chick = ents.Create("sent_chicken")
		if IsValid(chick) then
			chick:SetPos(pos)
			chick:SetAngles(ang)
			chick:Spawn()
		end
		SafeRemoveEntity(self)
	end
end

function ENT:OnTakeDamage()
	if SERVER then
		local chick = ents.Create("sent_chicken")
		if IsValid(chick) then
			chick:SetPos(self:GetPos())
			chick:SetAngles(Angle(0,0,0))
			chick:Spawn()
		end
		SafeRemoveEntity(self)
	end
end
