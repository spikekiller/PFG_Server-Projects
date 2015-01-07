--[[
  _____      _       _    _____ _                   _           _   _                  
 |  __ \    (_)     | |  / ____| |                 | |         | | | |                 
 | |__) |__  _ _ __ | |_| (___ | |__   ___  _ __   | |     ___ | |_| |_ ___ _ __ _   _ 
 |  ___/ _ \| | '_ \| __|\___ \| '_ \ / _ \| '_ \  | |    / _ \| __| __/ _ \ '__| | | |
 | |  | (_) | | | | | |_ ____) | | | | (_) | |_) | | |___| (_) | |_| ||  __/ |  | |_| |
 |_|   \___/|_|_| |_|\__|_____/|_| |_|\___/| .__/  |______\___/ \__|\__\___|_|   \__, |
                                           | |                                    __/ |
                                           |_|                                   |___/  --By Max
]]

//set-up meta table
PSLottery = {}


--------------------------------------------------------------------------------------------------------------------------------------------------
--EDIT VALUES BELOW THIS LINE ONLY!---------------------------------------------------------------------------------------------------------------

//PSLottery.DefaultTime sets the amount of time between drawing in seconds. 
//Default 1800 (30 minutes)
PSLottery.DefaultTime = 1800

//PSLottery.MaxValue Sets the range of possible numbers, this sets the "difficulty" in guessing the right number
//Default 500, meaning 1 in 500 chance of guessing the current lotto number
PSLottery.MaxValue = 500

//PSLottery.TicketPrice sets the price of the tickets and how much the jackpot goes up with each ticket sale.
//Default 5
PSLottery.TicketPrice = 5

//PSLottery.StartingJackpot sets the default jackpot when the server first starts, and when someone wins
//Default 100
PSLottery.StartingJackpot = 100

//PSLottery.MessageDelay Sets the delay in, seconds, that the server advertises the current time left before the drawing and the current jackpot
//Default 180 (3 minutes) (Must be below PSLottery.DefaultTime)
PSLottery.MessageDelay = 180

//PSLottery.Persistent Makes it so that the Jackpot is saved between server shutdowns / map changes.
//Default true
PSLottery.Persistent = true

//PSLottery.MaxTickets sets how many tickets each player can buy per drawing.
//Default 3
PSLottery.MaxTickets = 3

//PSLottery.PointsName sets What the points are called.
//Default "Points"
PSLottery.PointsName = "Points"

--EDIT VALUES ABOVE THIS LINE ONLY!-------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------

util.AddNetworkString("LotteryMenu")
util.AddNetworkString("TicketBuy")

print("PointShop Lottery Initialized")

if !file.Exists( "pslottery.txt", "DATA" ) then
	file.Write( "pslottery.txt", PSLottery.StartingJackpot )
end
local PersistentJackpot = tonumber(file.Read("pslottery.txt", "DATA"))

//Set up variables
PSLottery.TimeLeft = PSLottery.DefaultTime
PSLottery.Number = 0
PSLottery.Tickets = {}
PSLottery.TicketNumber = 0
PSLottery.CanBuy = false
PSLottery.Winrars = {}
PSLottery.WinrarsNumber = 0

if (PSLottery.Persistent) then
	PSLottery.Jackpot = PersistentJackpot
else
	PSLottery.Jackpot = PSLottery.StartingJackpot
end

//create default timer
timer.Create( "LotteryTick", 1, 0, function() PSLottery:LotteryTick() end )

timer.Create("LotterySave", 60, 0, function() file.Write( "pslottery.txt", PSLottery.Jackpot ) end )

//main function that sets up everything
function PSLottery:StartUp()
	self.Tickets = {}
	self.TicketNumber = 0
	self.Winrars = {}
	self.WinrarsNumber = 0
	
	self:GenerateNumeber()
	
	self.TimeLeft = PSLottery.DefaultTime
	
	for k,v in pairs(player.GetAll()) do
		v:SetNWInt("TicketsBought",0)
	end
	
	self.CanBuy = true
	timer.Create( "LotteryMessage", self.MessageDelay, 0, function() PSLottery:Message() end )
end

//Run each Second
function PSLottery:LotteryTick()
	self.TimeLeft = self.TimeLeft - 1
	
	//Don't Let it hit 0
	if (self.TimeLeft == 0) then
		self.TimeLeft = PSLottery.DefaultTime
	
	//Do elseif and print shit here!!!!!!
	
	//announce winrar
	elseif (self.TimeLeft == 10) then
		self.CanBuy = false
		self:Drawing()
		
	//reset everything for next lotto
	elseif (self.TimeLeft == 5) then
		self:StartUp()
	end
	
end

//Generate the winning number
function PSLottery:GenerateNumeber()
	self.Number = math.random(0, self.MaxValue)
end

//handle the winning system
function PSLottery:Drawing()
	timer.Destroy( "LotteryMessage")
	for k,v in pairs(self.Tickets) do
		if (v.NumberChosen == self.Number) then
			self.WinrarsNumber = self.WinrarsNumber + 1
			self.Winrars[self.WinrarsNumber] = v.PlayerEnt
		end
	end
	if (self.WinrarsNumber > 0) then
		self:Winrar()
	else
		for k,v in pairs(player.GetAll()) do
			v:PrintMessage( HUD_PRINTTALK , "PointShop Lottery: The winning number is "..self.Number)
			v:PrintMessage( HUD_PRINTTALK , "PointShop Lottery: Nobody won! The Jackpot stays at "..self.Jackpot.." "..self.PointsName.."!")
			v:PrintMessage( HUD_PRINTTALK , "PointShop Lottery: Next Drawing in "..string.ToMinutesSeconds(self.DefaultTime))
		end
	end
	file.Write( "pslottery.txt", self.Jackpot )
end

//Handles the winnings
function PSLottery:Winrar()
	local PlayerPayout = self.Jackpot / self.WinrarsNumber
	
	//reset the jackpot
	self.Jackpot = self.StartingJackpot
	file.Write( "pslottery.txt", self.Jackpot )
	for k,v in pairs(self.Winrars) do
		v:PS_GivePoints(PlayerPayout)
		for i,p in pairs(player.GetAll()) do
			p:PrintMessage( HUD_PRINTTALK , "PointShop Lottery: The winning number is "..self.Number)
			p:PrintMessage( HUD_PRINTTALK , "PointShop Lottery: Player '"..v:Name().."' Won the Lottery, and got "..PlayerPayout.." "..self.PointsName.."!")
		end
	end
end

//deals with tickets
function PSLottery:AddTicket(ply, number)
	self.TicketNumber = self.TicketNumber + 1
	
	self.Tickets[self.TicketNumber] = {}
	self.Tickets[self.TicketNumber].PlayerEnt = ply
	self.Tickets[self.TicketNumber].NumberChosen = number
	
	self.Jackpot = self.Jackpot + self.TicketPrice
	ply:PrintMessage( HUD_PRINTTALK , "PointShop Lottery: You Bought a ticket with the number "..number)
	ply:PrintMessage( HUD_PRINTTALK , "PointShop Lottery: The Jackpot is currently "..self.Jackpot.." "..self.PointsName.."!")
end

//How users will buy tickets
function CCommand( ply, text, public )
    if (string.lower(string.sub(text, 1, 4))== "!psl") then
        if (string.lower(string.sub(text, 6, 8))== "buy") then
			local number = tonumber(string.sub(text, 10))
			PSLottery:CheckNumber(ply, number)
		elseif (string.lower(string.sub(text, 6, 9))== "time") then
			ply:PrintMessage( HUD_PRINTTALK , "PointShop Lottery: The next drawing is in "..string.ToMinutesSeconds((PSLottery.TimeLeft - 10)))
			ply:PrintMessage( HUD_PRINTTALK , "The Jackpot is currently at "..PSLottery.Jackpot.." "..PSLottery.PointsName)
		elseif (string.lower(string.sub(text, 6, 9))== "help") then
			ply:PrintMessage( HUD_PRINTTALK , "PointShop Lottery Usage: !psl buy 'ticket number 0-"..PSLottery.MaxValue.."'")
			ply:PrintMessage( HUD_PRINTTALK , "PointShop Lottery Usage: '!psl time' to see how much time is left, and the current Jackpot.")
		else
			net.Start( "LotteryMenu" )
				net.WriteInt(PSLottery.MaxTickets, 16)
				net.WriteInt(PSLottery.TimeLeft, 16)
				net.WriteInt(PSLottery.Jackpot, 32)
			net.Send( ply )
		end
		
        return(false)
    end
end
hook.Add( "PlayerSay", "PSLotteryChatCommand", CCommand)

function PSLottery:CheckNumber(ply, number)
	if (number != nil && (number >= 0 && number <= PSLottery.MaxValue)) then
		if (ply:PS_HasPoints(PSLottery.TicketPrice)) then
			local IsGood = true
			for k,v in pairs(PSLottery.Tickets) do
				if (v.PlayerEnt == ply && v.NumberChosen == number) then
					IsGood = false
					break;
				end
			end
			if (IsGood) then
				if (PSLottery.CanBuy) then
					if (ply:GetNWInt("TicketsBought") < PSLottery.MaxTickets) then
						ply:PS_TakePoints(PSLottery.TicketPrice)
						PSLottery:AddTicket(ply, number)
						ply:SetNWInt("TicketsBought", (ply:GetNWInt("TicketsBought") +1))
					else
						ply:PrintMessage( HUD_PRINTTALK , "PointShop Lottery: You bought the maximum amount of tickets, please wait for next drawing.")
					end
				else
					ply:PrintMessage( HUD_PRINTTALK , "PointShop Lottery: You can not buy tickets right now, please wait "..PSLottery.TimeLeft.." seconds")
				end
			else
				ply:PrintMessage( HUD_PRINTTALK , "PointShop Lottery: You can't buy two tickets with the same number!")
			end
		else
			ply:PrintMessage( HUD_PRINTTALK , "PointShop Lottery: You don't have enough "..PSLottery.PointsName.." to buy a ticket!")
		end
	else
		ply:PrintMessage( HUD_PRINTTALK , "PointShop Lottery: enter a ticket number between 0-"..PSLottery.MaxValue)
	end
end

function PSLottery:Message()
	for k,v in pairs(player.GetAll()) do
		v:PrintMessage( HUD_PRINTTALK , "PointShop Lottery: The next drawing is in "..string.ToMinutesSeconds((PSLottery.TimeLeft - 10)))
		v:PrintMessage( HUD_PRINTTALK , "The Jackpot is currently at "..PSLottery.Jackpot.." "..PSLottery.PointsName.."")
	end
end

//if a player leaves the server their tickets get "removed" by making out of the lotto's scope of numbers
function PlayerLeavesServer( ply )
	for k,v in pairs(PSLottery.Tickets) do
		if (v.PlayerEnt == ply) then
			v.NumberChosen = -1
		end
	end
end
hook.Add( "PlayerDisconnected", "PSLplayerleavesserver", PlayerLeavesServer )

net.Receive( "LotteryMenu", function( len )
	local ply = net.ReadEntity()
	local number = net.ReadInt(16)
	PSLottery:CheckNumber(ply, number)
end )