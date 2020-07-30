-- Author: ILIKEPIEFOO2
-- Heavily based upon: https://github.com/wiremod/wire/blob/master/lua/entities/gmod_wire_expression2/core/chat.lua

local IsValid = IsValid

local MoneyList = {
    last = { nil, 0, 0 }
}

local MoneyAlert = {}

--[[************************************************************************]]--

registerCallback("destruct",function(self)
    MoneyAlert[self.entity] = nil
end

hook.Add("PlayerAddMoney","Exp2MoneyChanged",function(ply,amount)
    local entry = { ply, amount, CurTime() }
    MoneyList[ply:EntIndex()] = entry
    MoneyList.last = entry
    for e in pairs(MoneyAlert) do
        if IsValid(e) then
            e.context.data.runByMoneyChange = entry
            e:Execute()
            e.context.data.runByMoneyChange = nil
        else
            MoneyAlert[e] = nil
         end
    end
end
         



hook.Add("EntityRemoved","Exp2MoneyPlayerDisconnect", function(ply)
    MoneyList[ply:EntIndex()] = nil
end

--[[************************************************************************]]--

__e2setcost(1)

--- If <activate> == 0, the chip will no longer run on money events, otherwise it makes this chip execute when someone’s balance changes. Only needs to be called once, not in every execution.
e2function void runOnMoneyChange(activate)
    if activate ~= 0 then
        MoneyAlert[self.entity] = true
    else
        MoneyAlert[self.entity] = nil
     end
end

--- Returns 1 if the chip is being executed because of a money chance event. Return 0 otherwise.
e2function number moneyChangeClk()
    return self.data.runByMoneyChange and 1 or 0
end

--- Returns 1 if the chip is being executed because of a money change event by player <ply>. Returns 0 otherwise.
e2function number moneyChangeClk(ply)
    if not IsValid(ply) then return 0 end
    local cause = self.data.runByMoneyChange
    return cause and cause[1] == ply and 1 or 0
end

--[[************************************************************************]]--

__e2setcost(3)

--- Returns the last player to have money changed.
e2function entity lastMoneyChange()
    local entry = MoneyList.last
    if not entry then return nil end
    
    local ply = entry[1]
    if not IsValid(ply) then return nil end
    if not ply:IsPlayer() then return nil end
    
    return ply
end

--- Returns the amount of money changed last.
e2function number lastMoneyChangeAmount()
    local entry = MoneyList.last
    if not entry then return 0 end

    return entry[2]
end

--- Returns the time the last money change occurred.
e2function number lastMoneyChangeWhen()
    local entry = MoneyList.last
    if not entry then return 0 end

    return entry[3]
end


--- Returns how much the player’s money last changed.
e2function number entity:lastMoneyChangeAmount()
    if not IsValid(this) then return 0 end
    if not this:IsPlayer() then return 0 end
    
    local entry = MoneyList[this:EntIndex()]
    if not entry then return 0 end

    return entry[2]
end

--- Returns when the player’s money last changed.
e2function number entity:lastMoneyChangeWhen()
    if not IsValid(this) then return 0 end
    if not this:IsPlayer() then return 0 end
    
    local entry = MoneyList[this:EntIndex()]
    if not entry then return 0 end

    return entry[3]
end
