ITEM.Name = 'Wiki Cap'
ITEM.Price = 900
ITEM.Model = 'models/player/items/all_class/wikicap_medic.mdl'
ITEM.Attachment = 'eyes'

function ITEM:OnEquip(ply, modifications)
	ply:PS_AddClientsideModel(self.ID)
end

function ITEM:OnHolster(ply)
	ply:PS_RemoveClientsideModel(self.ID)
end

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
	pos = pos + (ang:Forward() * -5) + (ang:Up() * -2)
	
	return model, pos, ang
end