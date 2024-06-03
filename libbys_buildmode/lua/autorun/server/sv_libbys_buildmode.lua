require("libbys")

local function check_dmg(ent)
	if not IsValid(ent) then return true end

	if ent:IsPlayer() then
		return not ent:GetInBuildMode()
	end

	if not check_dmg(ent:GetCreator()) then return false end
	if not check_dmg(ent:GetOwner()) then return false end
	if not check_dmg(ent:GetParent()) then return false end

	return true
end

libbys.hooks.make_unique("PlayerSpawn", function(ply)
	if ply:GetInBuildMode() then
		ply:GodEnable()
	end
end)

libbys.hooks.make_unique("EntityTakeDamage", function(ent, dmg)
	if ent:IsPlayer() and ent:GetInBuildMode() then
		return false
	end

	-- Don't let godded players attack pvpers
	if not check_dmg(dmg:GetAttacker()) then return false end
	if not check_dmg(dmg:GetInflictor()) then return false end
end)

libbys.hooks.make_unique("PlayerShouldTakeDamage", function(ply, attacker)
	if ply:GetInBuildMode() then
		return false
	end

	if attacker:IsPlayer() and attacker:GetInBuildMode() then
		return false
	end
end)

libbys.hooks.make_unique("GetFallDamage", function(ply)
	if ply:GetInBuildMode() then
		-- Prevent the noise
		return 0
	end
end)

libbys.hooks.make_unique("OnDamagedByExplosion", function(ply)
	if ply:GetInBuildMode() then
		-- Prevent the noise
		return true
	end
end)
