ITEM.Name = 'Dragonborn Helmet'
ITEM.Price = 1500
ITEM.Model = 'models/player/items/heavy/skyrim_helmet.mdl'
ITEM.Attachment = 'eyes'

function ITEM:OnEquip(ply, modifications)
	ply:PS_AddClientsideModel(self.ID)
end

function ITEM:OnHolster(ply)
	ply:PS_RemoveClientsideModel(self.ID)
end

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
	pos = pos + (ang:Forward() * -5) + (ang:Up() * -4)
	
	return model, pos, ang
end