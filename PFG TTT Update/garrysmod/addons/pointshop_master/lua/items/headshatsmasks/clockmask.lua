ITEM.Name = 'Clock Mask'
ITEM.Price = 50
ITEM.Model = 'models/props_c17/clock01.mdl'
ITEM.Attachment = 'eyes'

ITEM.AllowModification_Position = true
ITEM.AllowModification_Angle = true
ITEM.AllowModification_Attachment = true
ITEM.AllowModification_Color = true

ITEM.SubCategoryName = "Masks"
function ITEM:OnEquip(ply, modifications)
	ply:PS_AddClientsideModel(self.ID)
end

function ITEM:OnHolster(ply)
	ply:PS_RemoveClientsideModel(self.ID)
end

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
	ang:RotateAroundAxis(ang:Right(), -90)
	
	return model, pos, ang
end