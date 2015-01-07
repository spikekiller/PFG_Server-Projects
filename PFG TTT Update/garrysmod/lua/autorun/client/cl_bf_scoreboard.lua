totalTimeTTT = 0
local startTimeCount = true

hook.Add("TTTEndRound", "TotalTimeTTTEnd", function() startTimeCount = false end)
hook.Add("TTTPrepareRound", "TotalTimeTTTPrep", function() 
	startTimeCount = true
	totalTimeTTT = 0 
end)

timer.Create( "TTTCountTimer", 1, 0, function() 
	if startTimeCount then
		totalTimeTTT = totalTimeTTT + 1
	end 
end)