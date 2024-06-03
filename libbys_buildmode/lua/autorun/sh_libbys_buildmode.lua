AddCSLuaFile()

AccessorFunc(FindMetaTable("Entity"), "m_bBuildGhosted", "IsBuildGhosted", FORCE_BOOL)

AccessorFunc(FindMetaTable("Player"), "m_bBuildMode", "InBuildMode", FORCE_BOOL)
AccessorFunc(FindMetaTable("Player"), "m_flBuildSwitchTime", "BuildSwitchTime", FORCE_NUMBER)

require("libbys")

local TIME_SWITCH_DIFFERENCE = 5 -- In seconds

local function get_state_name(state)
	return state and "build" or "pvp"
end

local function set_build_mode(ply, new_state)
	if ply:IsBot() then return end
	if CLIENT and ply ~= LocalPlayer() then return end -- Not necessary, but buildmode status is not networked

	if new_state == ply:GetInBuildMode() then
		if CLIENT then
			notification.AddLegacy(("You are already in %s mode"):format(get_state_name(current_state)), NOTIFY_ERROR, 3)
		end

		return
	end

	local current_time = CurTime()
	local last_switch_time = ply:GetBuildSwitchTime() or 0

	if current_time - last_switch_time < TIME_SWITCH_DIFFERENCE then
		if CLIENT then
			local time_difference = TIME_SWITCH_DIFFERENCE - (current_time - last_switch_time)

			notification.AddLegacy(("You can't switch for another %s"):format(string.NiceTime(time_difference)), NOTIFY_ERROR, 3)
		end

		return
	end

	ply:SetInBuildMode(new_state)
	ply:SetBuildSwitchTime(current_time)

	if CLIENT then
		notification.AddLegacy(("You are now in %s mode!"):format(get_state_name(new_state)), NOTIFY_GENERIC, 3)
	end

	ply:Spawn()
end

libbys.hooks.add_chat_command("build", function(ply)
	set_build_mode(ply, true)

	ply:SetCustomCollisionCheck(true)
end)

libbys.hooks.add_chat_command("pvp", function(ply)
	set_build_mode(ply, false)
end)

-- Needs to be shared for prediction
libbys.hooks.make_unique("PhysgunPickup", function(ply, ent)
	if not ply:GetInBuildMode() then return end

	ent:SetIsBuildGhosted(true)
	ent:SetCustomCollisionCheck(true)
end)

libbys.hooks.make_unique("PhysgunDrop", function(_, ent)
	timer.Simple(1, function()
		if not IsValid(ent) then return end

		ent:SetIsBuildGhosted(false)
	end)
end)

libbys.hooks.make_unique("PlayerNoClip", function(ply, desired_state)
	if desired_state and not ply:GetInBuildMode() then
		return false
	end
end)

libbys.hooks.make_unique("ScalePlayerDamage", function(ply, _, dmg)
	if ply:GetInBuildMode() then
		return true
	end
end)

libbys.hooks.make_unique("ShouldCollide", function(ent_a, ent_b)
	if ent_a:IsPlayer() and ent_b:GetIsBuildGhosted() then return false end
	if ent_b:IsPlayer() and ent_a:GetIsBuildGhosted() then return false end

	if (ent_a:IsPlayer() and ent_b:IsPlayer()) and (ent_a:GetInBuildMode() or ent_b:GetInBuildMode()) then
		return false
	end
end)
