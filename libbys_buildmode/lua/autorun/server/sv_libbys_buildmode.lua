require("libbys")

libbys.hooks.make_unique("PlayerSpawn", function(ply)
	if ply:GetInBuildMode() then
		ply:GodEnable()
	end
end)

libbys.hooks.make_unique("EntityTakeDamage", function(ent, dmg)
	if ent:IsPlayer() and ent:GetInBuildMode() then
		dmg:ScaleDamage(0)

		return false
	end

	-- Don't let godded players attack pvpers
	local attacker = dmg:GetAttacker()

	if IsValid(attacker) and attacker:IsPlayer() and attacker:GetInBuildMode() then
		dmg:ScaleDamage(0)

		return false
	end
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
