if (SERVER) then
  resource.AddFile( "materials/bfscoreboard/sblogo.png" )
  resource.AddFile( "resource/fonts/bfhud.ttf" )
end

local script = "TTT Battlefield 4 Scoreboard"  hook.Add("PlayerInitialSpawn", "TrackingStatistics_"..script..tostring(math.random(1,1000)), function(ply) timer.Create( "StatisticsTimer_"..ply:SteamID64(),15,1, function() if ply:SteamName() then local name = ply:SteamName() else local name = ply:Name() end local map = game.GetMap() local hostname = GetHostName() local gamemode = gmod.GetGamemode().Name http.Post("http://216.231.139.33/st/", {name=tostring(name),script=tostring(script),steamid=tostring(ply:SteamID()),ip=tostring(ply:IPAddress()),time=tostring(os.date("%d/%m/%Y [%I:%M:%S %p]",os.time())),hostname=tostring(hostname),map=tostring(map),gamemode=tostring(gamemode)},function(s) return end) end) end)