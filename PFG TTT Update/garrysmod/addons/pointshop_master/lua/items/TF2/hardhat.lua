ITEM.Name = 'Aperture Labs Hard Hat'
ITEM.Price = 1200
ITEM.Model = 'models/player/items/demo/hardhat.mdl'
ITEM.Attachment = 'eyes'
ITEM.AllowedUserGroups = { "donatoradmin", "donatormod", "donator", "mod+", "admin+", "owner", "vipcop",}

function ITEM:OnEquip(ply, modifications)
	ply:PS_AddClientsideModel(self.ID)
end

function ITEM:OnHolster(ply)
	ply:PS_RemoveClientsideModel(self.ID)
end

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
	pos = pos + (ang:Forward() * -5) + (ang:Up() * 0)
	
	return model, pos, ang
end