local CLASS = player.RegClass("stamina")

function CLASS.Off(self)
    if CLIENT then return end
    self.StaminaExhaustMul = nil
end

function CLASS.On(self)
    if CLIENT then return end
    ApplyAppearance(self)
    
    self.StaminaExhaustMul = 0
    
    if self.organism and self.organism.stamina then
        self.organism.stamina.max = 9999 -- Visual feedback and buffer
        self.organism.stamina[1] = 9999
    end
end

function CLASS.Guilt(self, Victim)
    if CLIENT then return end
    return 1
end
