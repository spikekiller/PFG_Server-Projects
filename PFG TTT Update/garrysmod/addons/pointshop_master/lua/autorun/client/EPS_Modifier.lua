local Modifier_Colors = {}
Modifier_Colors.Boarder = Color(0,150,255,255)
Modifier_Colors.BackGround = Color(20,20,20,255)
Modifier_Colors.Modifier_MainTitle = Color(0,255,255,255)

Modifier_Colors.Modifier_Title = Color(0,150,255,255)
Modifier_Colors.Modifier_ElementsName = Color(200,200,200,255)
Modifier_Colors.Modifier_ElementsValue = Color(0,200,200,255)

Modifier_Colors.Modifier_ElementsTopBG = Color(40,40,40,255)
Modifier_Colors.Modifier_ElementsBG = Color(30,30,30,255)


function PS_OpenRXModifier(Data,Modifiers)

	if PS_ShopMenu and PS_ShopMenu:IsValid() then
		PS_ShopMenu.previewpanel:SetVisible(false)
	end

	local BG = vgui.Create("DFrame") PS_RXModiferBG = BG
	BG:ShowCloseButton(false)
	BG:SetTitle("")
	BG:SetDraggable(false)
	
	BG:SetSize(ScrW(),ScrH())
	BG.Paint = function(slf)
		surface.SetDrawColor(Color(0,0,0,230))
		surface.DrawRect(0,0,slf:GetWide(),slf:GetTall())
	end
	BG:MakePopup()
	
	local Main = vgui.Create("DPointshopModifier",BG) PS_RXModifer = Main
	Main:SetSize(ScrW()*0.8,ScrH()*0.7)
	Main:Center()
	Main:Install(Data,Modifiers)

end

function PS_CloseRXModifier()
	if PS_RXModiferBG and PS_RXModiferBG:IsValid() then
		PS_RXModiferBG:Remove()
		PS_RXModiferBG = nil
	end
	
	if PS_ShopMenu and PS_ShopMenu:IsValid() then
		PS_ShopMenu.previewpanel:SetVisible(true)
	end
end

function PS_RXModifier_Init(Modification)
	Modification.Position = Modification.Position or Vector(0,0,0)
	Modification.Angle = Modification.Angle or Angle(0,0,0)
end

function PS_RXModifier_DoModify(Modification,CModel,Pos,Ang)
	PS_RXModifier_Init(Modification)
	local MasterBoneAngle = Angle(Ang.p,Ang.y,Ang.r)
	
	Pos = Pos + MasterBoneAngle:Forward() * Modification.Position.x
	Pos = Pos + MasterBoneAngle:Right() * Modification.Position.y
	Pos = Pos + MasterBoneAngle:Up() * Modification.Position.z
	
	
	Ang:RotateAroundAxis(MasterBoneAngle:Forward(), Modification.Angle.p)
	Ang:RotateAroundAxis(MasterBoneAngle:Up(), Modification.Angle.y)
	Ang:RotateAroundAxis(MasterBoneAngle:Right(), Modification.Angle.r)
	
	return Pos,Ang
end

function PS_RXModifier_CanModify(ITEM)
		if ITEM.AllowModification_Angle or 
			ITEM.AllowModification_Position or 
			ITEM.AllowModification_Attachment or
			ITEM.AllowModification_Color then
			
			if EPS_Config:PlayerCanEnhancedModify(LocalPlayer()) then
				return true
			end
		end
	return false
end

local PANEL = {}

function PANEL:Init()
	self.Modifier = {}
end
function PANEL:Lister_Add_Title(Lister,Text)
	local Panel = vgui.Create("DPanel") Lister:AddItem(Panel)
	Panel:SetTall(24)
	Panel.Paint = function(slf)
		surface.SetDrawColor(Modifier_Colors.Modifier_ElementsTopBG)
		surface.DrawRect(0,0,slf:GetWide(),slf:GetTall())
		draw.SimpleText(Text, 'EPSF_VerdOut_S22', 10, 2, Modifier_Colors.Modifier_Title)
	end
end

function PANEL:Lister_Add_Slider(Lister,Text,Min,Max,Decimal)
	local Panel = vgui.Create("DPanel") Lister:AddItem(Panel)
	Panel:SetTall(40)
	Panel.Paint = function(slf)
		surface.SetDrawColor(Modifier_Colors.Modifier_ElementsBG)
		surface.DrawRect(0,0,slf:GetWide(),slf:GetTall())
	end
	
		local NumSlider = vgui.Create( "DNumSlider", Panel )
		NumSlider:SetWide( Lister:GetWide()-40 )
		NumSlider:SetPos(20,0)
		NumSlider:SetTall(40)
		NumSlider:SetText( Text )
		NumSlider:SetMin( Min )
		NumSlider:SetMax( Max )
		NumSlider:SetDecimals( Decimal )
		NumSlider.TextArea:SetTextColor(Modifier_Colors.Modifier_ElementsValue)
		NumSlider.TextArea:SetFont("EPSF_VerdOut_S20")
		NumSlider.TextArea:SetWide(60)
		
		NumSlider.Label:SetTextColor(Modifier_Colors.Modifier_ElementsName)
		NumSlider.Label:SetFont("EPSF_VerdOut_S20")
		NumSlider.Label:SetWide(60)
		NumSlider:SetValue(0)
		
	return NumSlider
end

function PANEL:Lister_Add_SelecterButton(Lister,Text)
	local Panel = vgui.Create("DButton") Lister:AddItem(Panel)
	Panel:SetTall(40)
	Panel:SetText("")
	Panel.Options = {}
	Panel.Paint = function(slf)
		surface.SetDrawColor(Modifier_Colors.Modifier_ElementsBG)
		surface.DrawRect(0,0,slf:GetWide(),slf:GetTall())
		draw.SimpleText(Text, 'EPSF_VerdOut_S22', 20, 10, Modifier_Colors.Modifier_ElementsName)
		draw.SimpleText(slf.Selected or "NONE", 'EPSF_VerdOut_S22', slf:GetWide()-20, 10, Modifier_Colors.Modifier_ElementsValue,TEXT_ALIGN_RIGHT)
	end
	function Panel:OnSelect(Value)
	
	end
	function Panel:SetValue(Value)
		self.Selected = Value
		self:OnSelect(Value)
	end
	
	function Panel:AddOption(Value)
		table.insert(self.Options,Value)
	end
	Panel.DoClick = function(slf)
		local Menu = DermaMenu()
		Menu:AddSpacer()
		for k,v in pairs(slf.Options) do
			Menu:AddOption(v,function(sl)
				slf.Selected = v
				slf:OnSelect(v)
			end)
		end
		Menu:AddSpacer()
		Menu:AddOption("Set to Default",function(sl)
			slf.Selected = false
			slf:OnSelect(false)
		end)
		Menu:Open()
	end
	
	return Panel
end



function PANEL:Install(Data,Modifiers)
	self.Modifier = {}
	if Modifiers then
		self.Modifier = table.Copy(Modifiers)
		self.FirstSetup = table.Copy(Modifiers)
	end
	
	PS_RXModifier_Init(self.Modifier)
	
	local TopPanel = vgui.Create("DPanel",self)
	TopPanel:SetPos(1,1)
	TopPanel:SetSize(self:GetWide()-2,38)
	TopPanel.Paint = function(slf)
		surface.SetDrawColor(Color(10,10,10,255))
		surface.DrawRect(0,0,slf:GetWide(),slf:GetTall())
		
		surface.SetDrawColor(Color(80,80,80,255))
		surface.DrawRect(0,slf:GetTall()-2,slf:GetWide(),2)
		draw.SimpleText("Advanced Modifier", 'EPSF_Verd_S30', 10, 5, Modifier_Colors.Modifier_MainTitle)
	end
	
	local Apply = vgui.Create("EPS_CategoryButtons",self)
	Apply:SetSize(150,38)
	Apply:SetPos(self:GetWide() - Apply:GetWide(),0)
	Apply:SetTexts("Apply")
	Apply.Click = function(slf)
		PS_CloseRXModifier()
		PS:SendModifications(Data.ID, self.Modifier)
	end
	
	
	
	local previewpanel = vgui.Create('DPointShopPreview', self)
	previewpanel:SetSize(299,self:GetTall()-41)
	previewpanel:SetPos(self:GetWide()-300,40)
	previewpanel.ModifyingItemData = Data
	
	local Lister = vgui.Create("DPanelList",self)
	Lister:SetPos(1,40)
	Lister:SetSize(self:GetWide()-300,self:GetTall()-41)
	Lister:SetSpacing(0);
	Lister:SetPadding(0);
	Lister:EnableVerticalScrollbar(true);
	Lister:EnableHorizontal(false);
	
	-- Title
	if Data.AllowModification_Position then
		self:Lister_Add_Title(Lister,"Position Editor")
		local Slider_PX = self:Lister_Add_Slider(Lister,"Position - X",EPS_Config.Modifier.Position_Min.x,EPS_Config.Modifier.Position_Max.x,0)
		Slider_PX.OnValueChanged = function(slf,Val)
			self.Modifier.Position = self.Modifier.Position or Vector(0,0,0)
			self.Modifier.Position.x = Val
		end
		Slider_PX:SetValue(self.Modifier.Position.x)
		
		local Slider_PY = self:Lister_Add_Slider(Lister,"Position - Y",EPS_Config.Modifier.Position_Min.y,EPS_Config.Modifier.Position_Max.y,0)
		Slider_PY.OnValueChanged = function(slf,Val)
			self.Modifier.Position = self.Modifier.Position or Vector(0,0,0)
			self.Modifier.Position.y = Val
		end
		Slider_PY:SetValue(self.Modifier.Position.y)
		
		local Slider_PZ = self:Lister_Add_Slider(Lister,"Position - Z",EPS_Config.Modifier.Position_Min.z,EPS_Config.Modifier.Position_Max.z,0)
		Slider_PZ.OnValueChanged = function(slf,Val)
			self.Modifier.Position = self.Modifier.Position or Vector(0,0,0)
			self.Modifier.Position.z = Val
		end
		Slider_PZ:SetValue(self.Modifier.Position.z)
	end
	
	-- Angle
	if Data.AllowModification_Angle then
		self:Lister_Add_Title(Lister,"Angle Editor")
		local Slider_AP = self:Lister_Add_Slider(Lister,"Angle - P",0,360,0)
		Slider_AP.OnValueChanged = function(slf,Val)
			self.Modifier.Angle = self.Modifier.Angle or Angle(0,0,0)
			self.Modifier.Angle.p = Val
		end
		Slider_AP:SetValue(self.Modifier.Angle.p)
		
		local Slider_AY = self:Lister_Add_Slider(Lister,"Angle - Y",0,360,0)
		Slider_AY.OnValueChanged = function(slf,Val)
			self.Modifier.Angle = self.Modifier.Angle or Angle(0,0,0)
			self.Modifier.Angle.y = Val
		end
		Slider_AY:SetValue(self.Modifier.Angle.y)
		
		local Slider_AR = self:Lister_Add_Slider(Lister,"Angle - R",0,360,0)
		Slider_AR.OnValueChanged = function(slf,Val)
			self.Modifier.Angle = self.Modifier.Angle or Angle(0,0,0)
			self.Modifier.Angle.r = Val
		end
		Slider_AR:SetValue(self.Modifier.Angle.r)
	end
	
	-- Attachment
	if Data.AllowModification_Attachment then
		self:Lister_Add_Title(Lister,"Attachment & Bone")
		local Menus = self:Lister_Add_SelecterButton(Lister,"Attachment Override")
		Menus.OnSelect = function(slf,Value)
			self.Modifier.AttachmentOVR = Value
		end
		Menus:SetValue(self.Modifier.AttachmentOVR)
		
		for num,db in pairs(LocalPlayer():GetAttachments()) do
			local att_id = LocalPlayer():LookupAttachment(db.name)
			if att_id then
				Menus:AddOption(db.name)
			end
		end
		
		local Menus = self:Lister_Add_SelecterButton(Lister,"Bone Override")
		Menus.OnSelect = function(slf,Value)
			self.Modifier.BoneOVR = Value
		end
		Menus:SetValue(self.Modifier.BoneOVR)
		
		for i=0, LocalPlayer():GetBoneCount() - 1 do
			local bone_id = LocalPlayer():LookupBone(LocalPlayer():GetBoneName(i))
			if bone_id then
				Menus:AddOption(LocalPlayer():GetBoneName(i))
			end
		end
	end
	
	-- Colors
	
	if Data.AllowModification_Color then
		self:Lister_Add_Title(Lister,"Color Override")
		local Panel = vgui.Create("DButton") Lister:AddItem(Panel)
		Panel:SetTall(200)
		Panel:SetText("")
		Panel.Options = {}
		Panel.Paint = function(slf)
			surface.SetDrawColor(Modifier_Colors.Modifier_ElementsBG)
			surface.DrawRect(0,0,slf:GetWide(),slf:GetTall())
		end
		local ColorP = vgui.Create("DColorMixer",Panel)
		ColorP:SetPos(5,5)
		ColorP:SetSize(300,190)
		ColorP.ValueChanged = function(slf,col)
			self.Modifier.ColorOVR = col
		end
		ColorP:SetColor(self.Modifier.ColorOVR or Color(255,255,255,255))
	end
end

function PANEL:OnChoose(color)
	-- nothing, gets over-ridden
end

function PANEL:Paint()
	surface.SetDrawColor(Modifier_Colors.Boarder)
	surface.DrawRect(0,0,self:GetWide(),self:GetTall())
	
	surface.SetDrawColor(Modifier_Colors.BackGround)
	surface.DrawRect(1,1,self:GetWide()-2,self:GetTall()-2)
end

function PANEL:SetColor(color)
	self.colorpicker:SetColor(color or Color(255, 255, 255, 255))
end

vgui.Register('DPointshopModifier', PANEL, 'DPanel')
