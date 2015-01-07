local PANEL = {}
function PANEL:Init()
	self:SetText(" ")
	self.Status = "idle"
	self.Text = " "
	self.TextCol = EPS_Config.Color.MS.LC.CategoryName
	self.DescCol = EPS_Config.Color.MS.LC.CategoryDesc
	self.FXCol = Color(255,255,255,255)
	self.BGCol = Color(0,0,0,0)
	self.MoveRight = 0
	self.HoverPer = 0
	
	self.MainFont = "EPSF_CourOut_S33"
	self.DescFont = "EPSF_CourOut_S20"
end

function PANEL:DoClick()
	surface.PlaySound("ui/buttonclick.wav")
	self.HoverPer = 1
	self:Click()
	return
end
function PANEL:SetTexts(name,shortdesc)
	self.Text = name
	self.ShortDesc = shortdesc
end

function PANEL:PaintBackGround()
	-- override
end
function PANEL:PaintOverlay()
	-- override
end
function PANEL:SetIcon(mat)
	if mat then
		mat = "icon16/" .. mat .. ".png"
		self.IconCache = Material(mat)
	end
end

function PANEL:Paint()
	self:PaintBackGround()
	surface.SetDrawColor( self.BGCol )
	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	
	if self:IsHovered() then
		self.HoverPer = Lerp(FrameTime()*10,self.HoverPer,1)
	else
		self.HoverPer = Lerp(FrameTime()*10,self.HoverPer,0)
	end
	
	
		local COL = self.FXCol
		
		surface.SetDrawColor( Color(COL.r,COL.g,COL.b,self.HoverPer*30) )
		surface.DrawRect( 1, 1, (self:GetWide()-2), self:GetTall()-2 )
		
		if !self.ShortDesc then
			draw.SimpleText(self.Text, self.MainFont, 30+self.MoveRight,self:GetTall()/2, self.TextCol,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
		else
			draw.SimpleText(self.Text, self.MainFont, 30+self.MoveRight,self:GetTall()/3, self.TextCol,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
			draw.SimpleText(self.ShortDesc, self.DescFont, 30+self.MoveRight,self:GetTall()/3*2, self.DescCol,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
		end
		
		if self.IconCache then
			surface.SetDrawColor(255,255,255,255)
			surface.SetMaterial(self.IconCache)
			surface.DrawTexturedRect(8+self.MoveRight,self:GetTall()/2-8,16,16)
		end
		
		self:PaintOverlay()
end
function PANEL:Click()
	-- Override
end

vgui.Register("EPS_CategoryButtons",PANEL,"DButton")