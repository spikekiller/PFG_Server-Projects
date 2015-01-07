ITEM.Name = 'Maxs Severed Head'
ITEM.Price = 2200
ITEM.Model = 'models/player/items/demo/demo_ttg_max.mdl'
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