local mysterious = Action()
function mysterious.onUse(cid, item, fromPosition, itemEx, toPosition)
	local p = { x = 33672, y = 31884, z = 5 } -- where to tp to 33672, 31884, 5
	doCreatureSay(cid, "This metal egg seems to be locked by a strange mechanism. The time for it to reveal its contents has not yet come.", TALKTYPE_MONSTER_SAY)
end

mysterious:id(19065, 22739)
mysterious:register()
