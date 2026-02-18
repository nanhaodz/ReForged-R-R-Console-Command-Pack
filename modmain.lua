local _G = GLOBAL
local TheNet = _G.TheNet
local TheWorld = _G.TheWorld


-- Act as tostring() but keeps integer form for integers or fixes 2 decimal places for floats
local function display(number)
    if number % 1 == 0 then
        return tostring(number)
    end
    return tostring(math.floor(number * 100) / 100)
end


-- Spawn a ping banner at target object
_G.c_rr_ping = function(inst)
    if not inst then return end
    local x = inst:GetPosition().x
    local z = inst:GetPosition().z
    _G.SpawnPrefab("rf_ping_banner").Transform:SetPosition(x, 0, z)
end


-- Announce health info of a nearby prefab
_G.c_rr_gethealth = function(prefab)
    local inst = _G.c_find(prefab)
    if not inst then return end
    local health = inst.components.health
    TheNet:Announce(string.format("Prefab: %s\nHealth :heart:: [ %s / %d ] (-%s)", prefab, display(health.currenthealth), health.maxhealth, display(health.maxhealth - health.currenthealth)))
    _G.c_rr_ping(inst)
end


-- Restore the health of a prefab to full
_G.c_rr_restore = function(prefab)
    local inst = _G.c_find(prefab)
    if not inst then return end
    local health = inst.components.health
    health:SetPercent(1)
    TheNet:Announce(string.format("Prefab: %s\nRestored health to full (%d)", prefab, health.maxhealth))
    _G.c_rr_ping(inst)
end


-- Spawn a dummy and track its health loss
_G.c_rr_dummy = function(prefab, do_announce, maxhealth)
	local inst = _G.SpawnPrefab(prefab)
    if not inst then return end
    inst.Transform:SetPosition(_G.ConsoleWorldPosition():Get())
    inst.components.locomotor:SetExternalSpeedMultiplier(inst, "rr_speedmult", 0) 
    TheNet:Announce(string.format("Tracking health loss on prefab '%s'", prefab))

    local health = inst.components.health
    local currenthealth = health.currenthealth
    if maxhealth and maxhealth > 0 then health:SetMaxHealth(maxhealth) end

    local label = inst.entity:AddLabel()
    label:SetFontSize(22)
    label:SetFont(_G.BODYTEXTFONT)
    label:SetWorldOffset(0, -1, 0)
    label:SetColour(255/255, 255/255, 255/255)

    local health_info = ""
    local function update_health_info()
        if health.currenthealth <= 0 then
            label:Enable(false)
            return
        end
        health_info = string.format("'%s'\n%s/%s", prefab, display(health.currenthealth), display(health.maxhealth))
        label:SetText(health_info)
    end

    update_health_info()
    label:Enable(true)

    local function OnAttacked()
        if do_announce then
            TheNet:Announce(string.format("%s: Lost %s hp", inst.name, display(currenthealth - health.currenthealth)))
        end
        update_health_info()

        currenthealth = health.currenthealth
        if currenthealth <= 0 then
            inst:RemoveEventCallback("attacked", OnAttacked)
        end
    end

    inst:ListenForEvent("attacked", OnAttacked)
end


-- Stop an object's brain
-- It may work again under certain circumstances
_G.c_rr_stopbrain = function(inst)
    if inst and inst.brain then
        inst.brain:Stop()
    end
end


-- Spawn a dummy and track DPS done on it
_G.c_rr_dpsdummy = function(prefab, dur, maxhealth)
	local inst = _G.SpawnPrefab(prefab)
    if not inst then return end
    inst.Transform:SetPosition(_G.ConsoleWorldPosition():Get())
    inst.components.locomotor:SetExternalSpeedMultiplier(inst, "rr_speedmult", 0)
    TheNet:Announce(string.format("Tracking DPS on prefab '%s'", prefab))

    local health = inst.components.health
    if maxhealth and maxhealth > 0 then health:SetMaxHealth(maxhealth) end

    local label = inst.entity:AddLabel()
    label:SetFontSize(22)
    label:SetFont(_G.BODYTEXTFONT)
    label:SetWorldOffset(0, -1, 0)
    label:SetColour(255/255, 255/255, 255/255)

    local health_info = ""
    local function update_health_info()
        if health.currenthealth <= 0 then
            label:Enable(false)
            return
        end
        health_info = string.format("'%s'\nTotal damage: %s", prefab, display(health.maxhealth - health.currenthealth))
        label:SetText(health_info)
    end

    update_health_info()
    label:Enable(true)

    local duration = dur or 30
    if duration <= 0 then return end
    local hits_taken = 0

    local function OnAttacked()
        hits_taken = hits_taken + 1
        update_health_info()

        if hits_taken > 1 then return end

        TheNet:Announce(string.format("Timer started for %s seconds", display(duration)))
        if duration >= 5 then
            inst:DoTaskInTime(duration - 3, function()
                TheNet:Announce("3...")
            end)
            inst:DoTaskInTime(duration - 2, function()
                TheNet:Announce("2...")
            end)
            inst:DoTaskInTime(duration - 1, function()
                TheNet:Announce("1...")
            end)
        end
        inst:DoTaskInTime(duration, function()
            TheNet:Announce(string.format(
                "Summary:\nDuration: %s seconds\nTotal damage: %s (%s dmg/s)\nTotal hits: %s (%s hits/s)",
                duration,
                display(health.maxhealth - health.currenthealth), display((health.maxhealth - health.currenthealth)/duration),
                hits_taken, display(hits_taken/duration)
            ))
            _G.c_rr_damagehit(inst, 0, health.currenthealth)
            inst:RemoveEventCallback("attacked", OnAttacked)
        end)
    end

    inst:ListenForEvent("attacked", OnAttacked)
end


_G.c_rr_damagehit = function(inst, percent, flat)
    if not inst then return end
    if not percent or percent < 0 or percent > 1 then return end

    local health = inst.components.health
    local damage = health.maxhealth * percent + (flat or 0)
    health:DoDelta(-1 * damage)
    inst:PushEvent("attacked", { attacker = TheWorld, damage = damage } )
end


_G.c_rr_scantable = function(table)
    if not table then return end
    TheNet:Announce("-----")
    for k, v in pairs(table) do
        TheNet:Announce(k .. ": " .. tostring(v))
    end
end