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
PSLottery = {}
PSLottery.TimeLeft = 0

surface.CreateFont("MenuLarge", {
	font = "Verdana",
	size = 15,
	weight = 600,
	antialias = true,
})

surface.CreateFont( "WinLarge", {
	font = "Trebuchet MS",
	size = 32,
	weight = 900,
	blursize 	= 0,
	scanlines 	= 0,
	antialias 	= true
} )

surface.CreateFont( "WinSmall", {
	font = "Trebuchet MS",
	size = 20,
	weight = 900,
	blursize 	= 0,
	scanlines 	= 0,
	antialias 	= true
} )

function PSLottery:LMenu(Jackpot)
	local LPanel = vgui.Create( "DFrame" ) -- Creates the frame itself
	LPanel:SetSize( 300, 220 ) -- Size of the frame
	LPanel:SetTitle( "PS Lottery" ) -- Title of the frame
	LPanel:SetVisible( true )
	LPanel:SetDraggable( true ) -- Draggable by mouse?
	LPanel:ShowCloseButton( true ) -- Show the close button?
	LPanel:MakePopup() -- Show the frame
	LPanel:Center()
	LPanel:MakePopup()
	
	local ThreeLabel = vgui.Create( "DLabel", LPanel )
	ThreeLabel:SetPos( 4, 24 )
	ThreeLabel:SetFont("WinSmall")
	ThreeLabel:SetText( "Number of Tickets you can buy: "..(PSLottery.MaxTickets - LocalPlayer():GetNWInt("TicketsBought")))
	ThreeLabel:SizeToContents()
	
	local ThreeLabel1 = vgui.Create( "DLabel", LPanel )
	ThreeLabel1:SetPos( 4, 38 )
	ThreeLabel1:SetFont("WinSmall")
	ThreeLabel1:SetText( "Enter A Ticket Number")
	ThreeLabel1:SizeToContents()
	
	local ThreeLabel2 = vgui.Create( "DLabel", LPanel )
	ThreeLabel2:SetPos( 4, 120 )
	ThreeLabel2:SetFont("WinSmall")
	ThreeLabel2:SetText( "The next drawing is in "..string.ToMinutesSeconds(PSLottery.TimeLeft -10))
	ThreeLabel2:SizeToContents()
	
	local ThreeLabel3 = vgui.Create( "DLabel", LPanel )
	ThreeLabel3:SetPos( 4, 140 )
	ThreeLabel3:SetFont("WinSmall")
	ThreeLabel3:SetText( "The current jackpot is "..Jackpot)
	ThreeLabel3:SizeToContents()
	
	local StreamEntry = vgui.Create( "DTextEntry", LPanel )
	StreamEntry:SetPos( 4, 60 )
	StreamEntry:SetTall( 20 )
	StreamEntry:SetWide( 292 )
	StreamEntry:SetEnterAllowed( false )
	
	local SubmitButton = vgui.Create( "DButton", LPanel )
	SubmitButton:SetText( "Buy Ticket" )
	SubmitButton:SetPos( 4, 80 )
	SubmitButton:SetSize( 75, 30 )
	SubmitButton.DoClick = function ()
		local number = tonumber(StreamEntry:GetValue())
		if (!number) then number = -1 end
		net.Start( "LotteryMenu" )
			net.WriteEntity(LocalPlayer())
			net.WriteInt(number, 16)
		net.SendToServer( )
		LPanel:Close()
	end
	
	local ThreeLabel5 = vgui.Create( "DLabel", LPanel )
	ThreeLabel5:SetPos( 4, 160 )
	ThreeLabel5:SetText( "'!psl' to pull up this menu\n '!psl' help for help\n '!psl buy 'ticket number'' to buy a ticket\n '!psl time' to see how much time is left")
	ThreeLabel5:SizeToContents()
	
end

net.Receive( "LotteryMenu", function( len )
	PSLottery.MaxTickets = net.ReadInt(16)
	PSLottery.TimeLeft = net.ReadInt(16)
	local Jackpot = net.ReadInt(32)
	PSLottery:LMenu(Jackpot)
end )