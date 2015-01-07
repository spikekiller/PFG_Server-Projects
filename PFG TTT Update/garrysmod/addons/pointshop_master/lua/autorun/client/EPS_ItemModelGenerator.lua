if !PS_CMODEL_MASTER then
	PS_CMODEL_MASTER = ClientsideModel("models/props_junk/PopCan01a.mdl",RENDER_GROUP_VIEW_MODEL_OPAQUE)	
	PS_CMODEL_MASTER:SetNoDraw(true)
end
if !PS_CMODEL_TEMP_MASTER then
	PS_CMODEL_TEMP_MASTER = ClientsideModel("models/props_junk/PopCan01a.mdl",RENDER_GROUP_VIEW_MODEL_OPAQUE)	
	PS_CMODEL_TEMP_MASTER:SetNoDraw(true)
end



local PANEL = {}

function PANEL:Init()
	self.Zoom = 30
	
	self.ViewPos = Vector(0,0,0)
	self.CamAngle = Angle(0,90,0)
end

function PANEL:OnCursorEntered()
	self.Hovering = true
	PS:SetHoverItem(self.Data.ID)
end

function PANEL:OnCursorExited()
	self.Hovering = false
	PS:RemoveHoverItem()
end

function PANEL:OnMouseWheeled(mc)
end

function PANEL:Think()
end

function PANEL:SetData(Data)
	self.Data = Data
	
	if Data.Model then
		PS_CMODEL_MASTER:SetModel(Data.Model)
		local PrevMins, PrevMaxs = PS_CMODEL_MASTER:GetRenderBounds()
		self.ViewPos = (PrevMaxs + PrevMins) / 2
		
		self.Zoom = PrevMins:Distance(PrevMaxs)*0.8
		
		self.ModelEntity = ClientsideModel(Data.Model,RENDER_GROUP_VIEW_MODEL_OPAQUE)	
	end

end

function PANEL:OnRemove()
	if self.ModelEntity and self.ModelEntity:IsValid() then
		self.ModelEntity:Remove()
	end
end

function PANEL:Paint()

	if self.Hovering then
		self.CamAngle.y = self.CamAngle.y + FrameTime()*100
	end
	
	local x, y = self:LocalToScreen( 0, 0 )
	local w, h = self:GetSize()
	
	cam.Start3D( self.ViewPos - self.CamAngle:Forward()*self.Zoom,self.CamAngle, 100, x, y, w, h, 3, 4096 )
		self:DrawMain()
	cam.End3D()
	
	self.LastPaint = RealTime()
end


function PANEL:DoClick()
	local points = PS.Config.CalculateBuyPrice(LocalPlayer(), self.Data)
	
	if not LocalPlayer():PS_HasItem(self.Data.ID) and not LocalPlayer():PS_HasPoints(points) then
		notification.AddLegacy("You don't have enough "..PS.Config.PointsName.." for this!", NOTIFY_GENERIC, 5)
	end

	local menu = DermaMenu(self)
	
	if LocalPlayer():PS_HasItem(self.Data.ID) then
		menu:AddOption('Sell', function()
			Derma_Query('Are you sure you want to sell ' .. self.Data.Name .. '?', 'Sell Item',
				'Yes', function() LocalPlayer():PS_SellItem(self.Data.ID) end,
				'No', function() end
			)
		end)
	elseif LocalPlayer():PS_HasPoints(points) then
		menu:AddOption('Buy', function()
			Derma_Query('Are you sure you want to buy ' .. self.Data.Name .. '?', 'Buy Item',
				'Yes', function() LocalPlayer():PS_BuyItem(self.Data.ID) end,
				'No', function() end
			)
		end)
	end
	
	if LocalPlayer():PS_HasItem(self.Data.ID) then
		menu:AddSpacer()
		
		if LocalPlayer():PS_HasItemEquipped(self.Data.ID) then
			menu:AddOption('Holster', function()
				LocalPlayer():PS_HolsterItem(self.Data.ID)
			end)
		else
			menu:AddOption('Equip', function()
				LocalPlayer():PS_EquipItem(self.Data.ID)
			end)
		end
		
		if LocalPlayer():PS_HasItemEquipped(self.Data.ID) and self.Data.Modify then
			menu:AddSpacer()
			
			menu:AddOption('Modify...', function()
				PS.Items[self.Data.ID]:Modify(LocalPlayer().PS_Items[self.Data.ID].Modifiers)
			end)
		end
		
		if self.Data.AllowModification_Angle or self.Data.AllowModification_Position or self.Data.AllowModification_Attachment then
			if EPS_Config:PlayerCanEnhancedModify(LocalPlayer()) then
				menu:AddSpacer()
				
				if self.Data.AllowModification_Angle then
					menu:AddOption('Modify Angle&Position', function()
						PS_OpenRXModifier(self.Data,LocalPlayer().PS_Items[self.Data.ID].Modifiers)
					end)
				end
			end
		end
	end
	
	menu:Open()
end

function PANEL:DrawMain()
	local ply = LocalPlayer()
	local ItemData = self.Data
	
	if self.Data.Model then
		PS_CMODEL_MASTER:SetModel(LocalPlayer():GetModel())
		PS_CMODEL_MASTER:SetRenderOrigin(Vector(0,0,0))
		PS_CMODEL_MASTER:DrawModel()
		
		local a = nil
		local pos = Vector()
		local ang = Angle()
		
		local Attachment = self.Data.Attachment
		local Bone = self.Data.Bone
		
			if Attachment then
				local attach_id = PS_CMODEL_MASTER:LookupAttachment(Attachment)
				if not attach_id then return end
				
				local attach = PS_CMODEL_MASTER:GetAttachment(attach_id)
				
				if not attach then return end
				
				pos = attach.Pos
				ang = attach.Ang
			end
			
			if Bone then
				local bone_id = PS_CMODEL_MASTER:LookupBone(Bone)
				if not bone_id then return end
				
				pos, ang = PS_CMODEL_MASTER:GetBonePosition(bone_id)
			end
			
		self.ModelEntity, pos, ang = self.Data:ModifyClientsideModel(LocalPlayer(), self.ModelEntity, pos, ang)
			
		self.ViewPos = pos
			
		self.ModelEntity:SetRenderOrigin(pos)
		self.ModelEntity:SetRenderAngles(ang)
		self.ModelEntity:DrawModel()
	end
	
end

vgui.Register('DPointShopItemModelGenerator', PANEL, 'DPanel')
