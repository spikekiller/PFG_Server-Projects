ITEM.Name = 'Cone Hat'
ITEM.Price = 100
ITEM.Model = 'models/props_junk/TrafficCone001a.mdl'
ITEM.Attachment = 'eyes'

ITEM.AllowModification_Position = true
ITEM.AllowModification_Angle = true
ITEM.AllowModification_Attachment = true
ITEM.AllowModification_Color = true

function ITEM:OnEquip(ply)
	ply:PS_AddClientsideModel(self.ID)
end

function ITEM:OnHolster(ply)
	ply:PS_RemoveClientsideModel(self.ID)
end

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
	model:SetModelScale(0.8, 0)
	pos = pos + (ang:Forward() * -7) + (ang:Up() * 11)
	ang:RotateAroundAxis(ang:Right(), 20)
	
	return model, pos, ang
end
