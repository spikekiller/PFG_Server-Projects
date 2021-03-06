ITEM.Name = 'Berliners Bucket Helm'
ITEM.Price = 900
ITEM.Model = 'models/player/items/medic/berliners_bucket_helm.mdl'
ITEM.Attachment = 'eyes'

function ITEM:OnEquip(ply, modifications)
	ply:PS_AddClientsideModel(self.ID)
end

function ITEM:OnHolster(ply)
	ply:PS_RemoveClientsideModel(self.ID)
end

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
	pos = pos + (ang:Forward() * -4) + (ang:Up() * -2)
	
	return model, pos, ang
end