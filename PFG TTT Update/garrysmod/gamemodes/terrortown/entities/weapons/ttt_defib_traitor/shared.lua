SWEP.Base = "weapon_tttbase"

SWEP.HoldType = "slam"

SWEP.ViewModel  = Model("models/weapons/v_c4.mdl")
SWEP.WorldModel = Model("models/weapons/w_c4.mdl")

SWEP.Kind = WEAPON_EQUIP2
SWEP.AutoSpawnable = false
SWEP.CanBuy = { ROLE_TRAITOR }
SWEP.LimitedStock = true


if CLIENT then
    SWEP.PrintName = "Defibrillator"
    SWEP.Slot      = 7 
    
    SWEP.ViewModelFOV  = 10
    --SWEP.ViewModelFlip = true
   
   SWEP.Icon = "VGUI/ttt/icon_rg_defibrillator"
   
    SWEP.EquipMenuData = {
      type  = "item_weapon",
      name  = "Defibrillator",
      desc  = "Resurrect dead mates with this one!"
    };
   
   usermessage.Hook("_resurrectbody", function(um)
      local ply = um:ReadEntity()
      ply.was_resurrected = true
      ply.was_found = um:ReadBool()
   end)

   usermessage.Hook("_resetresurrectedbody", function(um)
      for _, p in pairs(player.GetAll()) do
         p.was_resurrected = nil
         p.was_found = nil
      end
   end)
   
   function ScoreGroup(p)
      if !IsValid(p) then return -1 end --because of reasons
         if p.was_resurrected then
            if LocalPlayer():Alive() then
               if !LocalPlayer():IsActiveTraitor() then
                  return p.was_found and GROUP_FOUND or GROUP_TERROR
               else
                  return GROUP_TERROR
               end
            end
         end
         if p.was_resurrected and LocalPlayer() == p then
            return GROUP_TERROR
         end
        if DetectiveMode() then
      if p:IsSpec() and (not p:Alive()) then
        if p:GetNWBool("body_found", false) then
            return GROUP_FOUND
        else
            local client = LocalPlayer()
            -- To terrorists, missing players show as alive
            if client:IsSpec() or
              client:IsActiveTraitor() or
              ((GAMEMODE.round_state != ROUND_ACTIVE) and client:IsTerror()) then
              return GROUP_NOTFOUND
            else
              return GROUP_TERROR
            end
        end
      end
  end

  return p:IsTerror() and GROUP_TERROR or GROUP_SPEC
   end
   
  
   function SWEP:PrimaryAttack()
      local tr = util.TraceLine({start = self.Owner:EyePos(), endpos = self.Owner:EyePos() + self.Owner:EyeAngles():Forward() * 80, filter = self.Owner})
      if tr.HitNonWorld and IsValid(tr.Entity) and tr.Entity:GetClass() == "prop_ragdoll" and CORPSE.GetPlayerNick(tr.Entity) ~= "" then
         self.StartTime = CurTime()
         self.EndTime = CurTime() + 5
         self.Started = true
      end
   end
   
   function SWEP:DrawHUD()
      if self.Started then
         --print("1")
         if self.Owner:KeyDown(IN_ATTACK) then
         --print("2")
         local tr = util.TraceLine({start = self.Owner:EyePos(), endpos = self.Owner:EyePos() + self.Owner:EyeAngles():Forward() * 80, filter = self.Owner})
            if tr.HitNonWorld and IsValid(tr.Entity) and tr.Entity:GetClass() == "prop_ragdoll" and CORPSE.GetPlayerNick(tr.Entity) ~= "" then
               local mins, maxs = self.Owner:OBBMins(), self.Owner:OBBMaxs()
               local tr2 = util.TraceHull({start = tr.Entity:LocalToWorld(tr.Entity:OBBCenter()) + vector_up, endpos = tr.Entity:LocalToWorld(tr.Entity:OBBCenter()) + Vector(0, 0, 80), filter = {tr.Entity, self.Owner}, mins = Vector(mins.x * 1.6, mins.y * 1.6, 0), maxs = Vector(maxs.x * 1.6, maxs.y * 1.6, 0), mask = MASK_PLAYERSOLID})
               if tr2.Hit then
                  local w, h = surface.GetTextSize("THERE'S NO ROOM TO RESURRECT HERE")
                  surface.SetTextPos(ScrW() / 2 - (w / 2), ScrH() / 2 - h)
                  surface.SetTextColor(Color(255, 0, 0, 255))
                  surface.DrawText("THERE'S NO ROOM TO RESURRECT HERE")
                  self.StartTime = CurTime()
                  self.EndTime = CurTime() + 5
               else
                  fract = math.TimeFraction(self.StartTime, self.EndTime, CurTime())
                  surface.SetDrawColor(Color(255, 0, 0, 255))
                  surface.SetDrawColor(Color(120, 120, 120, 130))
                  surface.DrawRect(ScrW() / 2 - (160 / 2), ScrH() / 2 + 10, 160, 10)
                  surface.SetFont("TabLarge")
                  local w, h = surface.GetTextSize("RESURRECTING")
                  surface.SetTextPos(ScrW() / 2 - (w / 2), ScrH() / 2 - h)
                  surface.SetTextColor(Color(255, 0, 0, 255))
                  surface.DrawText("RESURRECTING")
                  surface.SetDrawColor(Color(255, 0, 0, 255))
                  surface.DrawRect(ScrW() / 2 - (160 / 2), ScrH() / 2 + 10, math.Clamp(160 * fract, 0, 160), 10)
               end
            else
               self.StartTime = CurTime()
               self.EndTime = CurTime() + 5
            end
         end
      end
   end
end

if SERVER then
   resource.AddFile("materials/vgui/ttt/icon_rg_defibrillator.vmt")
   AddCSLuaFile("shared.lua")
   
   function SWEP:Deploy()
      self.Started = false
   end
   
   function ResurrectHandler(rag)
      if IsValid(rag) and rag:GetClass() == "prop_ragdoll" and rag.player_ragdoll then
         local ply = player.GetByUniqueID(rag.uqid)
         local credits = CORPSE.GetCredits(rag, 0)
         ply:SpawnForRound(true)
         ply:SetCredits(credits)
         ply:SetPos(rag:LocalToWorld(rag:OBBCenter()) + vector_up / 2) --Just in case he gets stuck somewhere
         ply:SetEyeAngles(Angle(0, rag:GetAngles().y, 0))
         ply:SetCollisionGroup(COLLISION_GROUP_WEAPON)
         timer.Simple(2, function() ply:SetCollisionGroup(COLLISION_GROUP_PLAYER) end)
         umsg.Start("_resurrectbody")
            umsg.Entity(ply)
            umsg.Bool(CORPSE.GetFound(rag, false))
         umsg.End()
         rag:Remove()
      end
   end
   
   function SWEP:PrimaryAttack()
      local tr = util.TraceLine({start = self.Owner:EyePos(), endpos = self.Owner:EyePos() + self.Owner:EyeAngles():Forward() * 80, filter = self.Owner})
      if tr.HitNonWorld and IsValid(tr.Entity) and tr.Entity:GetClass() == "prop_ragdoll" and tr.Entity.player_ragdoll then
         self.StartTime = CurTime()
         self.Started = true
         
      end
   end
   
   function SWEP:Think()
      if self.Started then
      --print("1")
         if self.Owner:KeyDown(IN_ATTACK) then
            --print("2")
            local tr = util.TraceLine({start = self.Owner:EyePos(), endpos = self.Owner:EyePos() + self.Owner:EyeAngles():Forward() * 80, filter = self.Owner})
            if tr.HitNonWorld and IsValid(tr.Entity) and tr.Entity:GetClass() == "prop_ragdoll" and tr.Entity.player_ragdoll then
               --print("3")
               local mins, maxs = self.Owner:OBBMins(), self.Owner:OBBMaxs()
               local tr2 = util.TraceHull({start = tr.Entity:LocalToWorld(tr.Entity:OBBCenter()) + vector_up, endpos = tr.Entity:LocalToWorld(tr.Entity:OBBCenter()) + Vector(0, 0, 80), filter = {tr.Entity, self.Owner}, mins = Vector(mins.x * 1.6, mins.y * 1.6, 0), maxs = Vector(maxs.x * 1.6, maxs.y * 1.6, 0), mask = MASK_PLAYERSOLID})
               if !tr2.Hit then
                  --print(CurTime() - self.StartTime)
                  if CurTime() - self.StartTime >= 5 then
                     ResurrectHandler(tr.Entity)
                     self:Remove()
                  end
               else
                  self.StartTime = CurTime()
               end
            else
               self.StartTime = CurTime()
            end
         else
            self.StartTime = CurTime()
            self.Started = false
         end
      end
   end
   
   hook.Add("TTTEndRound", "_resetresurrectedbody", function()
      umsg.Start("_resetresurrectedbody")
      umsg.End()
   end)
end