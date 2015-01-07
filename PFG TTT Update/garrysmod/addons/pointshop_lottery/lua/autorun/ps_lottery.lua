AddCSLuaFile()
if SERVER then
	include("ps_lottery/lottery_init.lua")
	AddCSLuaFile("ps_lottery/lottery_cl.lua")
	PSLottery:StartUp()
else
	include("ps_lottery/lottery_cl.lua")
end