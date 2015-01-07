local PANEL = {}

function PANEL:Init()
	if PS_GiveMenuPanel and PS_GiveMenuPanel:IsValid() then
		PS_GiveMenuPanel:Remove()
		PS_GiveMenuPanel = nil
	end
	
	self:SetTitle("PointShop Give "..PS.Config.PointsName)
	self:SetSize(300, 144)
	
	self:SetDeleteOnClose(true)
	self:SetBackgroundBlur(true)
	self:SetDrawOnTop(true)
	
			local TopBar = vgui.Create("DPanel",self)
			TopBar:SetSize(self:GetWide()-2,25)
			TopBar:SetPos(1,1)
			TopBar.Paint = function(slf)
				surface.SetDrawColor( EPS_Config.Color.PG.BackGround )
				surface.DrawRect(0, 0, slf:GetWide(), slf:GetTall())
				surface.SetDrawColor( EPS_Config.Color.PG.OutLine )
				surface.DrawRect(0, slf:GetTall()-1, slf:GetWide(), 1)
				draw.SimpleText("Give Points", 'EPSF_Treb_S22', 10, 2, EPS_Config.Color.PG.TitleText)
			end

	local l1 = vgui.Create("DLabel", self)
	l1:SetText("Player:")
	l1:Dock(TOP)
	l1:DockMargin(4, 0, 4, 4)
	l1:SizeToContents()

	local pselect = vgui.Create("DComboBox", self)
	pselect:SetValue("Select A Player")
	pselect:SetTall(24)
	pselect:Dock(TOP)
	self.playerselect = pselect

	self:FillPlayers()

	local l2 = vgui.Create("DLabel", self)
	l2:SetText(PS.Config.PointsName..":")
	l2:Dock(TOP)
	l2:DockMargin(4, 2, 4, 4)
	l2:SizeToContents()

	local pointsselector = vgui.Create("DNumberWang", self)
	pointsselector:SetTextColor( Color(0, 0, 0, 255) )
	pointsselector:SetTall(24)
	pointsselector:Dock(TOP)
	self.pselector = pointsselector
	
	local btnlist = vgui.Create("DPanel", self)
	btnlist:SetDrawBackground(false)
	btnlist:DockMargin(0, 5, 0, 0)
	btnlist:Dock(BOTTOM)

	local cancel = vgui.Create('DButton', btnlist)
	cancel:SetText('Cancel')
	cancel:DockMargin(4, 0, 0, 0)
	cancel:Dock(RIGHT)
	self.cancel = cancel

	local done = vgui.Create('DButton', btnlist)
	done:SetText('Send')
	done:SetDisabled(true)
	done:DockMargin(0, 0, 4, 0)
	done:Dock(RIGHT)
	self.submit = done
	
	self.selected_uid = nil
	pselect.OnSelect = function( s, idx, val, data )
		if data then self.selected_uid = data end

		self:Update()
	end

	pointsselector.OnValueChanged = function()
		self:Update()
	end

	done.DoClick = function()
		self:Submit()
		self:Close()
	end

	cancel.DoClick = function()
		self:Close()
	end

	self:Center()
	self:MakePopup()
	
	PS_GiveMenuPanel = self
end

function PANEL:Paint()
		surface.SetDrawColor(EPS_Config.Color.PG.BackGround)
		surface.DrawRect(0, 0, self:GetWide(),self:GetTall())
		
		surface.SetDrawColor(EPS_Config.Color.PG.OutLine)
		surface.DrawRect( 0, 0, self:GetWide(), 1 )
		surface.DrawRect( 0, self:GetTall()-1, self:GetWide(), 1 )
		surface.DrawRect( 0, 0, 1, self:GetTall() )
		surface.DrawRect( self:GetWide()-1, 0, 1, self:GetTall() )
		
end

function PANEL:FillPlayers()
	for _, ply in pairs(player.GetAll()) do
		if ply == LocalPlayer() then continue end
		
		self.playerselect:AddChoice(ply:Nick(), ply:UniqueID())
	end
end

function PANEL:Submit()
	local other = false
	
	for _, ply in pairs(player.GetAll()) do
		if tonumber(ply:UniqueID()) == tonumber(self.selected_uid) then
			other = ply
		end
	end
	
	if not other then return end -- player could have left

	net.Start('PS_SendPoints')
		net.WriteEntity(other)
		net.WriteInt(tonumber(self.pselector:GetValue()), 32)
	net.SendToServer()
end

function PANEL:Update()
	local disabled = false

	if not self.selected_uid then disabled = true end
	
	if (self.pselector:GetValue() < 1) or (self.pselector:GetValue() > LocalPlayer():PS_GetPoints()) then
		disabled = true
		self.pselector:SetTextColor(Color(180, 0, 0, 255))
	else
		self.pselector:SetTextColor(Color(0, 0, 0, 255))
	end

	self.submit:SetDisabled(disabled)
end

vgui.Register('DPointShopGivePoints', PANEL, 'DFrame')