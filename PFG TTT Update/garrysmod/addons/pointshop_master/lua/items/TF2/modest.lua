ITEM.Name = 'Modest Pile Of Hat'
ITEM.Price = 700
ITEM.Model = 'models/player/items/demo/hat_third_nr.mdl'
ITEM.Attachment = 'eyes'

function ITEM:OnEquip(ply, modifications)
	ply:PS_AddClientsideModel(self.ID)
end

function ITEM:OnHolster(ply)
	ply:PS_RemoveClientsideModel(self.ID)
end

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
	pos = pos + (ang:Forward() * -5) + (ang:Up() * -1)
	
	return model, pos, ang
end