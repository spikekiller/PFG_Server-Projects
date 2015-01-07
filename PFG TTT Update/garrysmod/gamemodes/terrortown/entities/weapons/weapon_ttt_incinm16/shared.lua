

if SERVER then

   AddCSLuaFile( "shared.lua" )
end

SWEP.HoldType			= "ar2"


if CLIENT then

   SWEP.PrintName			= "Incendary M16"
   SWEP.Slot				= 6

      SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "A slightly weaker M16 that ignites people!"
   };


   SWEP.Icon = "VGUI/ttt/icon_m16"
end


SWEP.Base				= "weapon_tttbase"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.Kind = WEAPON_EQUIP
SWEP.WeaponID = AMMO_M16

SWEP.Primary.Delay			= 0.19
SWEP.Primary.Recoil			= 1.6
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "Pistol"
SWEP.Primary.Damage = 15
SWEP.Primary.Cone = 0.018
SWEP.Primary.ClipSize = 20
SWEP.Primary.ClipMax = 20
SWEP.Primary.DefaultClip = 20
SWEP.AutoSpawnable      = true
SWEP.AmmoEnt = "item_ammo_pistol_ttt"
SWEP.HeadshotMultiplier = 2.2
SWEP.CanBuy = {ROLE_TRAITOR} -- only traitors can buy
SWEP.LimitedStock = true -- only buyable once


SWEP.UseHands			= true
SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 64
SWEP.ViewModel			= "models/weapons/cstrike/c_rif_m4a1.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_m4a1.mdl"

SWEP.Primary.Sound = Sound( "Weapon_M4A1.Silenced" )

SWEP.IronSightsPos = Vector(-7.58, -9.2, 0.55)
SWEP.IronSightsAng = Vector(2.599, -1.3, -3.6)


function SWEP:SetZoom(state)
   if CLIENT then return end
   if not (IsValid(self.Owner) and self.Owner:IsPlayer()) then return end
   if state then
      self.Owner:SetFOV(35, 0.5)
   else
      self.Owner:SetFOV(0, 0.2)
   end
end

-- Add some zoom to ironsights for this gun
function SWEP:SecondaryAttack()
   if not self.IronSightsPos then return end
   if self.Weapon:GetNextSecondaryFire() > CurTime() then return end

   bIronsights = not self:GetIronsights()

   self:SetIronsights( bIronsights )

   if SERVER then
      self:SetZoom(bIronsights)
   end

   self.Weapon:SetNextSecondaryFire(CurTime() + 0.3)
end

function SWEP:PreDrop()
   self:SetZoom(false)
   self:SetIronsights(false)
   return self.BaseClass.PreDrop(self)
end

function SWEP:Reload()
   self.Weapon:DefaultReload( ACT_VM_RELOAD );
   self:SetIronsights( false )
   self:SetZoom(false)
end


function SWEP:Holster()
   self:SetIronsights(false)
   self:SetZoom(false)
   return true
end

local function RunIgniteTimer(ent, timer_name)
   if IsValid(ent) and ent:IsOnFire() then
      if ent:WaterLevel() > 0 then
         ent:Extinguish()
      elseif CurTime() > ent.burn_destroy then
         ent:SetNotSolid(true)
         ent:Remove()
      else
         -- keep on burning
         return
      end
   end

   timer.Destroy(timer_name) -- stop running timer
end

local SendScorches

if CLIENT then
   local function ReceiveScorches(um)
      local ent = um:ReadEntity()
      local num = um:ReadChar()
      for i=1, num do
         util.PaintDown(um:ReadVector(), "FadingScorch", ent)
      end

      if IsValid(ent) then
         util.PaintDown(ent:LocalToWorld(ent:OBBCenter()), "Scorch", ent)
      end
   end
   usermessage.Hook("flare_scorch", ReceiveScorches)
else
   -- it's sad that decals are so unreliable when drawn serverside, failing to
   -- draw more often than they work, that I have to do this
   SendScorches = function(ent, tbl)
      umsg.Start("flare_scorch")
      umsg.Entity(ent)
      umsg.Char(#tbl)
      for _, p in pairs(tbl) do
         umsg.Vector(p)
      end
      umsg.End()
   end
   usermessage.Hook("flare_scorch") -- pools it
end


local function ScorchUnderRagdoll(ent)
   if SERVER then
      local postbl = {}
      -- small scorches under limbs
      for i=0, ent:GetPhysicsObjectCount()-1 do
         local subphys = ent:GetPhysicsObjectNum(i)
         if IsValid(subphys) then
            local pos = subphys:GetPos()
            util.PaintDown(pos, "FadingScorch", ent)

            table.insert(postbl, pos)
         end
      end

      SendScorches(ent, postbl)
   end

   -- big scorch at center
   local mid = ent:LocalToWorld(ent:OBBCenter())
   mid.z = mid.z + 25
   util.PaintDown(mid, "Scorch", ent)
end


function IgniteTarget(att, path, dmginfo)
   local ent = path.Entity
   if not IsValid(ent) then return end

   if CLIENT and IsFirstTimePredicted() then
      if ent:GetClass() == "prop_ragdoll" then
         ScorchUnderRagdoll(ent)
      end
      return
   end

   if SERVER then

      local dur = ent:IsPlayer() and 5 or 10

      -- disallow if prep or post round
      if ent:IsPlayer() and (not GAMEMODE:AllowPVP()) then return end

      ent:Ignite(dur, 100)

      ent.ignite_info = {att=dmginfo:GetAttacker(), infl=dmginfo:GetInflictor()}

      if ent:IsPlayer() then
         timer.Simple(dur + 0.1, function()
                                    if IsValid(ent) then
                                       ent.ignite_info = nil
                                    end
                                 end)

      elseif ent:GetClass() == "prop_ragdoll" then
         ScorchUnderRagdoll(ent)

         local burn_time = 10
         local tname = Format("ragburn_%d_%d", ent:EntIndex(), math.ceil(CurTime()))

         ent.burn_destroy = false

         timer.Create(tname,
                      0.1,
                      math.ceil(1 + burn_time / 0.1), -- upper limit, failsafe
                      function()
                         RunIgniteTimer(ent, tname)
                      end)
      end
   end
end

function SWEP:ShootFlare()
   local cone = self.Primary.Cone
   local bullet = {}
   bullet.Num       = 1
   bullet.Src       = self.Owner:GetShootPos()
   bullet.Dir       = self.Owner:GetAimVector()
   bullet.Spread    = Vector( cone, cone, 0 )
   bullet.Tracer    = 1
   bullet.Force     = 2
   bullet.Damage    = self.Primary.Damage
   bullet.TracerName = self.Tracer
   bullet.Callback = IgniteTarget

   self.Owner:FireBullets( bullet )
end

function SWEP:PrimaryAttack()
   self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

   if not self:CanPrimaryAttack() then return end

   self.Weapon:EmitSound( self.Primary.Sound )

   self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

   self:ShootFlare()

   self:TakePrimaryAmmo( 1 )

   if IsValid(self.Owner) then
      self.Owner:SetAnimation( PLAYER_ATTACK1 )

      self.Owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0 ) )
   end

   if ( (game.SinglePlayer() && SERVER) || CLIENT ) then
      self.Weapon:SetNetworkedFloat( "LastShootTime", CurTime() )
   end
end
