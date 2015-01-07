local PANEL = {}

function PANEL:Init()
	if PS_ColorPanel and PS_ColorPanel:IsValid() then
		PS_ColorPanel:Remove()
	end
	self:SetSize(300, 300)
	
	self.colorpicker = vgui.Create('DColorMixer', self)
	self.colorpicker:Dock(FILL)
	
	local done = vgui.Create('EPS_CategoryButtons', self)
	done:DockMargin(0, 5, 0, 0)
	done:Dock(BOTTOM)
	
	done:SetTexts('Done')
	
	done.DoClick = function()
		self.OnChoose(self.colorpicker:GetColor())
		self:Remove()
	end
	
	self:Center()
	self:Show()
	
	PS_ColorPanel = self
end

function PANEL:OnChoose(color)
	-- nothing, gets over-ridden
end

function PANEL:Paint()
end

function PANEL:SetColor(color)
	self.colorpicker:SetColor(color or Color(255, 255, 255, 255))
end

vgui.Register('DPointShopColorChooser', PANEL, 'DPanel')
