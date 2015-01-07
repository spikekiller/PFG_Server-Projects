PS.ShopMenu = nil
PS.ClientsideModels = {}

PS.HoverModel = nil
PS.HoverModelClientsideModel = nil

local invalidplayeritems = {}

-- menu stuff

function PS:ToggleMenu()
	if PS_GiveMenuPanel and PS_GiveMenuPanel:IsValid() then
		PS_GiveMenuPanel:Remove()
	end
	if PS_ColorPanel and PS_ColorPanel:IsValid() then
		PS_ColorPanel:Remove()
	end
	
	
	if !PS.ShopMenu then
		PS.ShopMenu = vgui.Create('DPointShopMenu')
		PS.ShopMenu:Install()
		PS.ShopMenu:MakePopup()
	else
		PS.ShopMenu:Remove()
		PS.ShopMenu = nil
	end
	
end

function PS:SetHoverItem(item_id)
	local ITEM = PS.Items[item_id]
	
	if ITEM.Model then
		self.HoverModel = item_id
	
		self.HoverModelClientsideModel = ClientsideModel(ITEM.Model, RENDERGROUP_OPAQUE)
		self.HoverModelClientsideModel:SetNoDraw(true)
	end
end

function PS:RemoveHoverItem()
	self.HoverModel = nil
	self.HoverModelClientsideModel = nil
end

-- modification stuff

function PS:ShowGivePointMenu()
	-- TODO: Do this
	
	local BG = vgui.Create("DFrame")
	BG:SetSize(ScrW(),ScrH())
	BG:SetTitle("")
	BG:ShowCloseButton(false)
	BG:SetDraggable(false)
	BG.Paint = function(slf)
		surface.SetDrawColor(Color(0,0,0,230))
		surface.DrawRect(0,0,slf:GetWide(),slf:GetTall())
	end
	BG:MakePopup()
	
	local chooser = vgui.Create('DPointShopGivePoints',BG)
	chooser:Center()
	chooser.OnRemove = function()
		BG:Remove()
	end
end


function PS:ShowColorChooser(item, modifications)
	-- TODO: Do this
	
	local BG = vgui.Create("DPanel")
	BG:SetSize(ScrW(),ScrH())
	BG.Paint = function(slf)
		surface.SetDrawColor(Color(0,0,0,230))
		surface.DrawRect(0,0,slf:GetWide(),slf:GetTall())
	end
	BG:MakePopup()
	
	local chooser = vgui.Create('DPointShopColorChooser',BG)
	chooser:SetColor(modifications.color)
	chooser:Center()
	chooser.OnChoose = function(color)
		modifications.color = color
		self:SendModifications(item.ID, modifications)
	end
	chooser.OnRemove = function()
		BG:Remove()
	end
end

function PS:SendModifications(item_id, modifications)
	net.Start('PS_ModifyItem')
		net.WriteString(item_id)
		net.WriteTable(modifications)
	net.SendToServer()
end

-- net hooks

net.Receive('PS_ToggleMenu', function(length)
	PS:ToggleMenu()
end)

net.Receive('PS_Items', function(length)
	local ply = net.ReadEntity()
	local items = net.ReadTable()
	ply.PS_Items = PS:ValidateItems(items)
	hook.Call("PS_ItemAdjusted")
end)

net.Receive('PS_Points', function(length)
	local ply = net.ReadEntity()
	local points = net.ReadInt(32)
	ply.PS_Points = PS:ValidatePoints(points)
end)

net.Receive('PS_AddClientsideModel', function(length)
	local ply = net.ReadEntity()
	local item_id = net.ReadString()
	
	if not IsValid(ply) then
		if not invalidplayeritems[ply] then
			invalidplayeritems[ply] = {}
		end
		
		table.insert(invalidplayeritems[ply], item_id)
		return
	end
	
	ply:PS_AddClientsideModel(item_id)
end)

net.Receive('PS_RemoveClientsideModel', function(length)
	local ply = net.ReadEntity()
	local item_id = net.ReadString()
	
	if not ply or not IsValid(ply) or not ply:IsPlayer() then return end
	
	ply:PS_RemoveClientsideModel(item_id)
end)

net.Receive('PS_SendClientsideModels', function(length)
	local itms = net.ReadTable()
	
	for ply, items in pairs(itms) do
		if not IsValid(ply) then -- skip if the player isn't valid yet and add them to the table to sort out later
			invalidplayeritems[ply] = items
			continue
		end
			
		for _, item_id in pairs(items) do
			if PS.Items[item_id] then
				ply:PS_AddClientsideModel(item_id)
			end
		end
	end
end)

net.Receive('PS_SendNotification', function(length)
	local str = net.ReadString()
	notification.AddLegacy(str, NOTIFY_GENERIC, 5)
end)

-- hooks

hook.Add('Think', 'PS_Think', function()
	for ply, items in pairs(invalidplayeritems) do
		if IsValid(ply) then
			for _, item_id in pairs(items) do
				if PS.Items[item_id] then
					ply:PS_AddClientsideModel(item_id)
				end
			end
			
			invalidplayeritems[ply] = nil
		end
	end
end)

hook.Add('PostPlayerDraw', 'PS_PostPlayerDraw', function(ply)
	if not ply:Alive() then return end
	if ply == LocalPlayer() and GetViewEntity():GetClass() == 'player' and (GetConVar('thirdperson') and GetConVar('thirdperson'):GetInt() == 0) then return end
	if not PS.ClientsideModels[ply] then return end
	
	for item_id, model in pairs(PS.ClientsideModels[ply]) do
		if not PS.Items[item_id] then PS.ClientsideModel[ply][item_id] = nil continue end
		
		local ITEM = PS.Items[item_id]
		
		if not ITEM.Attachment and not ITEM.Bone then PS.ClientsideModel[ply][item_id] = nil continue end
		
		local RenderColor = Color(255,255,255,255)
		
		--
		local Modifier = nil
		if ply.PS_Items and ply.PS_Items[item_id] then
			Modifier = ply.PS_Items[item_id].Modifiers
		end
		
		local pos = Vector()
		local ang = Angle()
		
		local Attachment = ITEM.Attachment
		local Bone = ITEM.Bone
		
		if Modifier then
			Attachment = Modifier.AttachmentOVR or Attachment
			Bone = Modifier.BoneOVR or Bone
			
			RenderColor = Modifier.ColorOVR or RenderColor
		end
			
		if Attachment then
			local attach_id = ply:LookupAttachment(Attachment)
			if not attach_id then return end
			
			local attach = ply:GetAttachment(attach_id)
			
			if not attach then return end
			
			pos = attach.Pos
			ang = attach.Ang
		end
		
		if Bone then
			local bone_id = ply:LookupBone(Bone)
			if not bone_id then return end
			
			pos, ang = ply:GetBonePosition(bone_id)
		end
		
		model, pos, ang = ITEM:ModifyClientsideModel(ply, model, pos, ang)
		
		if Modifier then
			pos,ang = PS_RXModifier_DoModify(Modifier,model,pos,ang)
		end
		

		render.SetColorModulation( RenderColor.r/255,RenderColor.g/255,RenderColor.b/255 )
		render.SetBlend(RenderColor.a/255)
		
		model:SetPos(pos)
		model:SetAngles(ang)

		model:SetRenderOrigin(pos)
		model:SetRenderAngles(ang)
		model:SetupBones()
		model:DrawModel()
		model:SetRenderOrigin()
		model:SetRenderAngles()
		
		render.SetColorModulation( 1,1,1 )
		render.SetBlend(1)
	end
end)
