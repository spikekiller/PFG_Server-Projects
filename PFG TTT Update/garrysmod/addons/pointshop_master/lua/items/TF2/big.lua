ITEM.Name = 'Big Chief'
ITEM.Price = 800
ITEM.Model = 'models/player/items/heavy/heavy_big_chief.mdl'
ITEM.Attachment = 'eyes'

function ITEM:OnEquip(ply, modifications)
	ply:PS_AddClientsideModel(self.ID)
end

function ITEM:OnHolster(ply)
	ply:PS_RemoveClientsideModel(self.ID)
end

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
	pos = pos + (ang:Forward() * -6) + (ang:Up() * -3)
	
	return model, pos, ang
end