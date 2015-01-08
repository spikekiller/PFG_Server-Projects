---- Scoreboard player score row, based on sandbox version

include("sb_info.lua")

local GetTranslation = LANG.GetTranslation
local GetPTranslation = LANG.GetParamTranslation
local inputColor = {255, 0, 0}

local clock = os.clock
function sleep(n)  -- seconds
  local t0 = clock()
  while clock() - t0 <= n do end
end 

function randomColor(inputCol)
   speed = bfscoreboard.randomColorSpeed
   
   -- Red to Green
   if inputCol[1] == 255 and inputCol[3] == 0 and inputCol[2] != 255 then
      inputCol[2] = inputCol[2] + speed
   elseif inputCol[2] == 255 and inputCol[1] != 0 then
      inputCol[1] = inputCol[1] - speed

   -- Green to Blue
   elseif inputCol[2] == 255 and inputCol[3] != 255 then
      inputCol[3] = inputCol[3] + speed
   elseif inputCol[3] == 255 and inputCol[2] != 0 then
      inputCol[2] = inputCol[2] - speed

   -- Blue to Red
   elseif inputCol[3] == 255 and inputCol[1] != 255 then
      inputCol[1] = inputCol[1] + speed
   elseif inputCol[1] == 255 and inputCol[3] != 0 then
      inputCol[3] = inputCol[3] - speed
   end

   return Color( inputCol[1], inputCol[2], inputCol[3], 255)
end

SB_ROW_HEIGHT = tonumber(bfscoreboard.rowHeight) --16

local PANEL = {}

function PANEL:Init()
   -- cannot create info card until player state is known
   self.info = nil

   self.open = false

   self.cols = {}
   self.cols[1] = vgui.Create("DLabel", self)
   self.cols[1]:SetText(GetTranslation("sb_ping"))

   self.cols[2] = vgui.Create("DLabel", self)
   self.cols[2]:SetText(GetTranslation("sb_deaths"))

   self.cols[3] = vgui.Create("DLabel", self)
   self.cols[3]:SetText(GetTranslation("sb_score"))

   if KARMA.IsEnabled() then
      self.cols[4] = vgui.Create("DLabel", self)
      self.cols[4]:SetText(GetTranslation("sb_karma"))
   end

   self.cols[5] = vgui.Create("DLabel", self)
   self.cols[5]:SetText("Rank")

   for _, c in ipairs(self.cols) do
      c:SetMouseInputEnabled(false)
   end

   self.tag = vgui.Create("DLabel", self)
   self.tag:SetText("")
   self.tag:SetMouseInputEnabled(false)

   self.sresult = vgui.Create("DImage", self)
   self.sresult:SetSize(16,16)
   self.sresult:SetMouseInputEnabled(false)

   self.avatar = vgui.Create( "AvatarImage", self )
   self.avatar:SetSize(SB_ROW_HEIGHT, SB_ROW_HEIGHT)
   self.avatar:SetMouseInputEnabled(false)

   self.nick = vgui.Create("DLabel", self)
   self.nick:SetMouseInputEnabled(false)

   self.voice = vgui.Create("DImageButton", self)
   self.voice:SetSize(16,16)

   self:SetCursor( "hand" )
end

function PANEL:Paint()
   if not IsValid(self.Player) then return end
--   if ( self.Player:GetFriendStatus() == "friend" ) then
--      color = Color( 236, 181, 113, 255 )
--   end
   if self.open then
      borderRowHeight = SB_ROW_HEIGHT + 30
   else
      borderRowHeight = SB_ROW_HEIGHT
   end

   local ply = self.Player

   if ply:IsTraitor() then
      surface.SetDrawColor( bfscoreboard.traitorColor )
   elseif ply:IsDetective() then
      surface.SetDrawColor( bfscoreboard.detectiveColor )
   else
      if ply == LocalPlayer() then
         local alphaGeneratedColor = Color( 240, 240, 255, 20)
         if bfscoreboard.localPlayerColor == "Random" then
            alphaGeneratedColor = Color( inputColor[1], inputColor[2], inputColor[3], 10)
            surface.SetDrawColor( alphaGeneratedColor )
         else
            alphaGeneratedColor = bfscoreboard.localPlayerColor
            surface.SetDrawColor( alphaGeneratedColor )
         end
      else
         surface.SetDrawColor(0, 0, 0, 0)
      end
   end


   local gradientTexture = surface.GetTextureID("gui/gradient") -- No file types.
   surface.SetTexture(gradientTexture) -- So it draws in normal color.
   surface.DrawTexturedRectRotated(self:GetWide()/2, SB_ROW_HEIGHT/2, SB_ROW_HEIGHT-1, self:GetWide(), 90)
   return true
end

function PANEL:SetPlayer(ply)
   self.Player = ply
   self.avatar:SetPlayer(ply)

   if not self.info then
      local g = ScoreGroup(ply)
      if g == GROUP_TERROR and ply != LocalPlayer() then
         self.info = vgui.Create("TTTScorePlayerInfoTags", self)
         self.info:SetPlayer(ply)

         self:InvalidateLayout()
      elseif g == GROUP_FOUND or g == GROUP_NOTFOUND then
         self.info = vgui.Create("TTTScorePlayerInfoSearch", self)
         self.info:SetPlayer(ply)
         self:InvalidateLayout()
      end
   else
      self.info:SetPlayer(ply)

      self:InvalidateLayout()
   end

   self.voice.DoClick = function()
                           if IsValid(ply) and ply != LocalPlayer() then
                              ply:SetMuted(not ply:IsMuted())
                           end
                        end

   self:UpdatePlayerData()
end

function PANEL:GetPlayer() return self.Player end

function PANEL:UpdatePlayerData()
   if not IsValid(self.Player) then return end

   local ply = self.Player
   self.cols[1]:SetText(ply:Ping())
   self.cols[2]:SetText(ply:Deaths())
   self.cols[3]:SetText(ply:Frags())

   if self.cols[4] then
      self.cols[4]:SetText(math.Round(ply:GetBaseKarma()))
   end
   local generatedColor = Color(255, 255, 255)
   self.nick:SetText(ply:Nick())
   self.nick:SizeToContents()
   for k, v in pairs(bfscoreboard.ulxGroups) do
      if ply:IsUserGroup(v[1]) then
         if v[3] == "Random" then
            generatedColor = randomColor( inputColor )
            self.cols[5]:SetTextColor( generatedColor )
            self.nick:SetTextColor( generatedColor )
         else
            self.cols[5]:SetTextColor(v[3])
            self.nick:SetTextColor(v[3])
         end
         self.cols[5]:SetText(v[2])
      end
   end

   local ptag = ply.sb_tag
   if ScoreGroup(ply) != GROUP_TERROR then
      ptag = nil
   end

   self.tag:SetText(ptag and GetTranslation(ptag.txt) or "")
   self.tag:SetTextColor(ptag and ptag.color or COLOR_WHITE)

   self.sresult:SetVisible(ply.search_result != nil)

   -- More blue if a detective searched them
   if ply.search_result and (LocalPlayer():IsDetective() or (not ply.search_result.show)) then
      self.sresult:SetImageColor(Color(200, 200, 255))
   end

   -- Cols are likely to need re-centering
   self:LayoutColumns()

   if self.info then
      self.info:UpdatePlayerData()
   end

   if self.Player != LocalPlayer() then
      local muted = self.Player:IsMuted()
      self.voice:SetImage(muted and "icon16/sound_mute.png" or "icon16/sound.png")
   else
      self.voice:Hide()
   end
        
if ply:IsUserGroup("owner") then
  self.cols[5]:SetText("Owner")
  -- self.cols[5]:SetTextColor(Color(255,0,0))
  -- declaring random variables
  local rand01, rand02, rand03 = 0, 0, 0
  -- declaring color variables
  local cR, cG, cB = 0, 0, 0
  while true do
    --assigning random value, either 0 or 1.
    rand01, rand02, rand03 = math.random(0, 1), math.random(0, 1), math.random(0, 1)
    if rand01 == 1 then cR = 255 elseif cR = 0 end
    if rand02 == 1 then cG = 255 elseif cG = 0 end
    if rand03 == 1 then cB = 255 elseif cB = 0 end
    self.cols[5]:SetTextColor(Color(cR, cG, cB))
    sleep(0.2)
  end
end

if ply:IsUserGroup("user") then
  self.cols[5]:SetText("Guest")
  self.cols[5]:SetTextColor(Color(0,153,0))
end

if ply:IsUserGroup("Admin") then
  self.cols[5]:SetText("Admin")
  self.cols[5]:SetTextColor(Color(0,0,153))
end

if ply:IsUserGroup("modintraining") then
  self.cols[5]:SetText("M.I.T.")
  self.cols[5]:SetTextColor(Color(0,51,102))
end

if ply:IsUserGroup("moderator") then
  self.cols[5]:SetText("Moderator")
  self.cols[5]:SetTextColor(Color(0,70,0))
end

if ply:IsUserGroup("member") then
  self.cols[5]:SetText("Member")
  self.cols[5]:SetTextColor(Color(230,123,55))
end

if ply:IsUserGroup("coowner") then
  self.cols[5]:SetText("Co-Owner")
  self.cols[5]:SetTextColor(Color(255,122,122))
end

if ply:IsUserGroup("swampsgirl") then
  self.cols[5]:SetText("Swamps GF")
  self.cols[5]:SetTextColor(Color(255,122,122))
end

if ply:IsUserGroup("manager") then
  self.cols[5]:SetText("Manager")
  self.cols[5]:SetTextColor(Color(0,255,0))
end

if ply:IsUserGroup("seniormoderator") then
  self.cols[5]:SetText("S. Mod")
 self.cols[5]:SetTextColor(Color(100,150,70))
end

if ply:IsUserGroup("Member") then
  self.cols[5]:SetText("Member")
  self.cols[5]:SetTextColor(Color(230,123,55))
end

if ply:IsUserGroup("trusted") then
  self.cols[5]:SetText("Trusted")
  self.cols[5]:SetTextColor(Color(12,46,157))
end

if ply:IsUserGroup("veteran") then
  self.cols[5]:SetText("Veteran")
  self.cols[5]:SetTextColor(Color(68,84,255))
end

if ply:IsUserGroup("Veteran") then
  self.cols[5]:SetText("Veteran")
  self.cols[5]:SetTextColor(Color(68,84,255))
end

if ply:IsUserGroup("game_master") then
  self.cols[5]:SetText("Game Master")
  self.cols[5]:SetTextColor(Color(198,172,19))
end

if ply:IsUserGroup("vip") then
  self.cols[5]:SetText("VIP")
  self.cols[5]:SetTextColor(Color(176,12,200))
end

if ply:IsUserGroup("senioradmin") then
  self.cols[5]:SetText("S. Admin")
  self.cols[5]:SetTextColor(Color(99,12,46))
end


  
end

function PANEL:ApplySchemeSettings()
   for k,v in pairs(self.cols) do
      v:SetFont("BFSB22")
      v:SetTextColor(COLOR_WHITE)
   end

   self.nick:SetFont("BFSB22")

   local ptag = self.Player and self.Player.sb_tag
   self.tag:SetTextColor(ptag and ptag.color or COLOR_WHITE)
   self.tag:SetFont("BFSB20")

   self.sresult:SetImage("icon16/magnifier.png")
   self.sresult:SetImageColor(Color(170, 170, 170, 150))
end

function PANEL:LayoutColumns()
   if scrollOnFlag then
      shiftLeftAmount = -scrollOnBarSize
   else
      shiftLeftAmount = 0
   end
   for k,v in ipairs(self.cols) do
      v:SizeToContents()
      v:SetPos(self:GetWide() - (50*k) - v:GetWide()/2 + shiftLeftAmount, (SB_ROW_HEIGHT - v:GetTall()) / 2)
      if v == self.cols[5] then
         v:SetPos(self:GetWide() - (50*k) - v:GetWide()/2 - 30 + shiftLeftAmount, (SB_ROW_HEIGHT - v:GetTall()) / 2)
      end
   end

   self.tag:SizeToContents()
   self.tag:SetPos(self:GetWide() - (50 * 7.5) - self.tag:GetWide()/2 + shiftLeftAmount, (SB_ROW_HEIGHT - self.tag:GetTall()) / 2)
   self.tag:SetPos(self:GetWide() - (50 * 7.5) - self.tag:GetWide()/2 + shiftLeftAmount, (SB_ROW_HEIGHT - self.tag:GetTall()) / 2)

   self.sresult:SetPos(self:GetWide() - (50*6) - 55 + shiftLeftAmount, (SB_ROW_HEIGHT - 16) / 2)
end

function PANEL:PerformLayout()
   self.avatar:SetPos(3,3)
   if self.open and self.Player != LocalPlayer() and self.info then
      self.avatar:SetSize(24 + SB_ROW_HEIGHT, 24 + SB_ROW_HEIGHT)
   else
      self.avatar:SetSize(SB_ROW_HEIGHT-6, SB_ROW_HEIGHT-6)
   end

   if not self.open then
      self:SetSize(self:GetWide(), SB_ROW_HEIGHT)

      if self.info then self.info:SetVisible(false) end
   elseif self.info then
      self:SetSize(self:GetWide(), 100 + SB_ROW_HEIGHT)

      self.info:SetVisible(true)
      if self.info.searchBool then
         self.info:SetPos(67, SB_ROW_HEIGHT + 5)
      else
         self.info:SetPos(5, SB_ROW_HEIGHT + 5)
      end
      self.info:SetSize(self:GetWide(), 100)
      self.info:PerformLayout()

      self:SetSize(self:GetWide(), SB_ROW_HEIGHT + self.info:GetTall())
   end

   self.nick:SizeToContents()

   if self.open and self.Player != LocalPlayer() and self.info then
      self.nick:SetPos(SB_ROW_HEIGHT + 40, (SB_ROW_HEIGHT - self.nick:GetTall()) / 2)
   else
      self.nick:SetPos(SB_ROW_HEIGHT + 10, (SB_ROW_HEIGHT - self.nick:GetTall()) / 2)
   end

   self:LayoutColumns()

   self.voice:SetVisible(not (self.open and self.Player != LocalPlayer() and self.info))
   self.voice:SetSize(16, 16)
   if scrollOnFlag then
      self.voice:DockMargin(4, 4, 20, 4)
   else
      self.voice:DockMargin(4, 4, 4, 4)
   end
   self.voice:Dock(RIGHT)
end

function PANEL:DoClick(x, y)
   self:SetOpen(not self.open)
end

function PANEL:SetOpen(o)
   if self.open then
      surface.PlaySound("ui/buttonclickrelease.wav")
   else
      surface.PlaySound("ui/buttonclick.wav")
   end

   self.open = o

   self:PerformLayout()
   self:GetParent():PerformLayout()
   sboard_panel:PerformLayout()
end

function PANEL:DoRightClick()
   -- Thanks to an.droid from CoderHire for this!
   -- http://facepunch.com/showthread.php?t=1296365
   local ply = self.Player
   if bfscoreboard.adminMenuEnabled then
      if LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() then   
         surface.PlaySound("buttons/button9.wav")
         local options = DermaMenu()
         options:AddOption("Copy Name", function() SetClipboardText(ply:Nick()) surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/user_edit.png")
         options:AddOption("Copy SteamID", function() SetClipboardText(ply:SteamID()) surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/tag_blue.png")
         options:AddSpacer()
         options:AddOption("Open Profile", function() ply:ShowProfile() surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/world.png")
         options:AddSpacer()
         options.Paint = function(slf, w, h)
            surface.SetDrawColor(bfscoreboard.adminMenuBGColor)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor( bfscoreboard.adminMenuBorderColor )
            surface.DrawRect(0, 0, w, 1)
            surface.DrawRect(0, h-1, w, 1)
            surface.DrawRect(0, 0, 1, h)
            surface.DrawRect(w-1, 0, 1, h)
         end

         if IsValid(ply) then
            local adminop,subimg = options:AddSubMenu("Admin")
            subimg:SetImage("icon16/lorry.png")
            adminop:AddOption("Slay Next Round", function() RunConsoleCommand("ulx","slaynr",ply:Nick()) surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/cross.png")
            adminop:AddOption("Slay Now", function() RunConsoleCommand("ulx","slay",ply:Nick()) surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/cut_red.png")
            adminop:AddOption("Kick", function() RunConsoleCommand("ulx","kick",ply:Nick(),"You were kicked") surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/door_out.png")
            adminop:AddOption("Ban", function() RunConsoleCommand("ulx","ban",ply:Nick(),120,"You were banned") surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/delete.png")
            adminop:AddSpacer()
            adminop:AddOption("Mute", function() RunConsoleCommand("ulx","mute",ply:Nick()) surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/asterisk_yellow.png")
            adminop:AddOption("Gag", function() RunConsoleCommand("ulx","gag",ply:Nick()) surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/asterisk_orange.png")
            adminop:AddSpacer()
            adminop:AddOption("Spectate", function() RunConsoleCommand("ulx","spectate",ply:Nick()) surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/zoom.png")
            adminop:AddSpacer()
            adminop.Paint = function(slf, w, h)
               surface.SetDrawColor(bfscoreboard.adminMenuBGColor)
               surface.DrawRect(0, 0, w, h)
               surface.SetDrawColor( bfscoreboard.adminMenuBorderColor )
               surface.DrawRect(0, 0, w, 1)
               surface.DrawRect(0, h-1, w, 1)
               surface.DrawRect(0, 0, 1, h)
               surface.DrawRect(w-1, 0, 1, h)
            end
            options:Open()
         end
      end
   end
end

vgui.Register( "TTTScorePlayerRow", PANEL, "Button" )
