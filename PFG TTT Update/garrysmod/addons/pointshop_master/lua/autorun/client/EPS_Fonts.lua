EPS_FontInstalled = false

if EPS_FontInstalled then return end
EPS_FontInstalled = true

-- For RocketMania's stuff
local Fonts = {}
	Fonts["EPSF_CoolV"] = "coolvetica"
	Fonts["EPSF_Treb"] = "Trebuchet MS"
	Fonts["EPSF_Cour"] = "Courier New"
	Fonts["EPSF_Verd"] = "Verdana"
	Fonts["EPSF_Ari"] = "Arial"
	Fonts["EPSF_Taho"] = "Tahoma"
	Fonts["EPSF_Luci"] = "Lucida Console"
	
	
for a,b in pairs(Fonts) do
	for k=10,70 do
		surface.CreateFont( a .. "_S"..k,{font = b,size = k,weight = 10,antialias = true})
		surface.CreateFont( a .. "Out_S"..k,{font = b,size = k,weight = 10,antialias = true,outline = true})
	end
end