ITEM.Name = 'Ghostly Gibus'
ITEM.Price = 700
ITEM.Model = 'models/player/items/all_class/ghostly_gibus_medic.mdl'
ITEM.Attachment = 'eyes'

function ITEM:OnEquip(ply, modifications)
	ply:PS_AddClientsideModel(self.ID)
end

function ITEM:OnHolster(ply)
	ply:PS_RemoveClientsideModel(self.ID)
end

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
	pos = pos + (ang:Forward() * -5) + (ang:Up() * 1)
	
	return model, pos, ang
end