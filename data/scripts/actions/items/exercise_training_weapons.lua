local exhaustionTime = 10

local function isDummy(id)
	local dummies = Game.getDummies()
	return dummies[id] and dummies[id] > 0
end

local exerciseTraining = Action()

function exerciseTraining.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if not target or not target:getId() then
		return true
	end

	local playerId = player:getId()
	local targetId = target:getId()

	if target:isItem() and isDummy(targetId) then
		if _G.OnExerciseTraining[playerId] then
			player:sendTextMessage(MESSAGE_FAILURE, "You are already training!")
			return true
		end

		local playerPos = player:getPosition()
		if not ExerciseWeaponsTable[item.itemid].allowFarUse and (playerPos:getDistance(target:getPosition()) > 1) then
			player:sendTextMessage(MESSAGE_FAILURE, "Get closer to the dummy.")
			return true
		end

		if not playerPos:isProtectionZoneTile() then
			player:sendTextMessage(MESSAGE_FAILURE, "You need to be in a protection zone.")
			return true
		end

		local playerHouse = player:getTile():getHouse()
		local targetPos = target:getPosition()
		local targetHouse = Tile(targetPos):getHouse()

		if targetHouse and isDummy(targetId) then
			if playerHouse ~= targetHouse then
				player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You must be inside the house to use this dummy.")
				return true
			end

			local playersOnDummy = 0
			for _, playerTraining in pairs(_G.OnExerciseTraining) do
				if playerTraining.dummyPos == targetPos then
					playersOnDummy = playersOnDummy + 1
				end

				if playersOnDummy >= configManager.getNumber(configKeys.MAX_ALLOWED_ON_A_DUMMY) then
					player:sendTextMessage(MESSAGE_FAILURE, "That exercise dummy is busy.")
					return true
				end
			end
		end

		if player:hasExhaustion("training-exhaustion") then
			player:sendTextMessage(MESSAGE_FAILURE, "This exercise dummy can only be used after a " .. exhaustionTime .. " seconds cooldown.")
			return true
		end

		_G.OnExerciseTraining[playerId] = {}
		if not _G.OnExerciseTraining[playerId].event then
			_G.OnExerciseTraining[playerId].event = addEvent(ExerciseEvent, 0, playerId, targetPos, item.itemid, targetId)
			_G.OnExerciseTraining[playerId].dummyPos = targetPos
			player:setTraining(true)
			player:setExhaustion("training-exhaustion", exhaustionTime)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have started training on an exercise dummy.")
		end
		return true
	end
	return false
end

for weaponId, weapon in pairs(ExerciseWeaponsTable) do
	exerciseTraining:id(weaponId)
	if weapon.allowFarUse then
		exerciseTraining:allowFarUse(true)
	end
end

exerciseTraining:register()
