---- Unlike sandbox, we have teams to deal with, so here's an extra panel in the
---- hierarchy that handles a set of player rows belonging to its team.

include("sb_row.lua")

function RoundedBoxOutline( borderSize, x, y, w, h, color )
        x = math.Round( x )
        y = y
        w = math.Round( w )
        h = math.Round( h )
        borderSize = math.Round( borderSize )
        surface.SetDrawColor( color.r, color.g, color.b, color.a )
        surface.DrawRect( x, y, borderSize, h )
        surface.DrawRect( x + w, y, borderSize, h+borderSize )
        surface.DrawRect( x, y, w, borderSize )
        surface.DrawRect( x, y + h, w, borderSize )
end

local function CompareScore(pa, pb)
   if not ValidPanel(pa) then return false end
   if not ValidPanel(pb) then return true end
   local a = pa:GetPlayer()
   local b = pb:GetPlayer()
   if not IsValid(a) then return false end
   if not IsValid(b) then return true end
   if a:Frags() == b:Frags() then return a:Deaths() < b:Deaths() end
   return a:Frags() > b:Frags()
end

local PANEL = {}

function PANEL:Init()
   self.name = "Unnamed"
   self.color = COLOR_WHITE
   self.rows = {}
   self.rowcount = 0
   self.rows_sorted = {}
   self.group = "spec"
end

function PANEL:SetGroupInfo(name, color, group)
   self.name = name
   self.color = color
   self.group = group
end

local bgcolor = bfscoreboard.rowBGColor
function PANEL:Paint()
   -- Darkened background
   draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), bgcolor)

   surface.SetFont("BFSB24")

   -- Header bg
   local txt = self.name .. " (" .. self.rowcount .. ")"
   local w, h = surface.GetTextSize(txt)
   draw.RoundedBox(0, 0, 0, self:GetWide(), 24, self.color)
   if self.color == bfscoreboard.terroristsBGColor then
      surface.SetDrawColor( 116, 183, 62, 255)
   elseif self.color == bfscoreboard.spectatorsBGColor then
      surface.SetDrawColor( 77, 116, 149, 100)
   elseif self.color == bfscoreboard.missingBGColor then
      surface.SetDrawColor( 255, 177, 61, 100)
   elseif self.color == bfscoreboard.confirmedBGColor then
      surface.SetDrawColor( 132, 45, 51, 120)
   end
   local gradientTexture = surface.GetTextureID("gui/gradient"); -- No file types.
   surface.SetTexture(gradientTexture) -- So it draws in normal color.
   surface.DrawTexturedRectRotated(0, 12,  24,  self:GetWide()*2, 90)

   -- Text
   surface.SetTextPos(10, 11 - h/2)
   surface.SetTextColor(255,255,255,255)
   surface.DrawText(string.upper(txt))

   surface.SetFont("BFSB16")
   -- Column Header Text
   local shiftLeftAmount = 0
   if scrollOnFlag then
      shiftLeftAmount = -scrollOnBarSize
   else
      shiftLeftAmount = 0
   end
   surface.SetTextPos(self:GetWide()-65 + shiftLeftAmount, 15 - h/2)
   surface.SetTextColor(255, 255, 255, 255)
   surface.DrawText("PING")

   surface.SetTextPos(self:GetWide()-122 + shiftLeftAmount, 15 - h/2)
   surface.SetTextColor(255, 255, 255, 255)
   surface.DrawText("DEATHS")

   surface.SetTextPos(self:GetWide()-170 + shiftLeftAmount, 15 - h/2)
   surface.SetTextColor(255, 255, 255, 255)
   surface.DrawText("SCORE")

   if KARMA.IsEnabled() then
      surface.SetTextPos(self:GetWide()-220 + shiftLeftAmount, 15 - h/2)
      surface.SetTextColor(255, 255, 255, 255)
      surface.DrawText("KARMA")
   end

   surface.SetTextPos(self:GetWide()-295 + shiftLeftAmount, 15 - h/2)
   surface.SetTextColor(255, 255, 255, 255)
   surface.DrawText("RANK")

   -- Row background
   local y = 24
   for i, row in ipairs(self.rows_sorted) do
      surface.SetDrawColor( bfscoreboard.rowBGColor )
      surface.DrawRect(0, y, self:GetWide()-1, row:GetTall()-1)
      RoundedBoxOutline(1, 0, y, self:GetWide()-1, row:GetTall()-1, bfscoreboard.rowBorderColor)
      RoundedBoxOutline(1, 2, y+2, self:GetWide()-4, row:GetTall()-4, bfscoreboard.rowBorderColorDark)
      surface.SetDrawColor( bfscoreboard.rowBGColorFade )
      local gradientTexture = surface.GetTextureID("gui/gradient"); -- No file types.
      surface.SetTexture(gradientTexture) -- So it draws in normal color.
      surface.DrawTexturedRectRotated(0 + (self:GetWide()-1)/2, y + (row:GetTall()-1)/2 , row:GetTall()-1, self:GetWide()-1, 90)
      y = y + row:GetTall() --+ 1
   end

   --Column Darkening
   surface.SetDrawColor( bfscoreboard.columnDarkenColor )
   surface.DrawRect(self:GetWide()-75, 25, 50, self:GetTall())
   surface.DrawRect(self:GetWide()-175, 25, 50, self:GetTall())
   surface.DrawRect(self:GetWide()-335, 25, 110, self:GetTall())

   RoundedBoxOutline(1, self:GetWide() - 335 + shiftLeftAmount, 24, 110, self:GetTall(), bfscoreboard.rowBorderColor)
   RoundedBoxOutline(1, self:GetWide() - 175 + shiftLeftAmount, 24, 50, self:GetTall(), bfscoreboard.rowBorderColor)
   RoundedBoxOutline(1, self:GetWide() - 75 + shiftLeftAmount, 24, 50, self:GetTall(), bfscoreboard.rowBorderColor)
end

function PANEL:AddPlayerRow(ply)
   if ScoreGroup(ply) == self.group and not self.rows[ply] then
      local row = vgui.Create("TTTScorePlayerRow", self)
      row:SetPlayer(ply)
      self.rows[ply] = row
      self.rowcount = table.Count(self.rows)

--      row:InvalidateLayout()

      -- must force layout immediately or it takes its sweet time to do so
      self:PerformLayout()
      --self:InvalidateLayout()
   end
end

function PANEL:HasPlayerRow(ply)
   return self.rows[ply] != nil
end

function PANEL:HasRows()
   return self.rowcount > 0
end

function PANEL:UpdateSortCache()
   self.rows_sorted = {}
   for k,v in pairs(self.rows) do
      table.insert(self.rows_sorted, v)
   end

   table.sort(self.rows_sorted, CompareScore)
end

function PANEL:UpdatePlayerData()
   local to_remove = {}
   for k,v in pairs(self.rows) do
      -- Player still belongs in this group?
      if ValidPanel(v) and IsValid(v:GetPlayer()) and ScoreGroup(v:GetPlayer()) == self.group then
         v:UpdatePlayerData()
      else
         -- can't remove now, will break pairs
         table.insert(to_remove, k)
      end
   end

   if #to_remove == 0 then return end

   for k,ply in pairs(to_remove) do
      local pnl = self.rows[ply]
      if ValidPanel(pnl) then
         pnl:Remove()
      end

--      print(CurTime(), "Removed player", ply)

      self.rows[ply] = nil
   end
   self.rowcount = table.Count(self.rows)

   self:UpdateSortCache()

   self:InvalidateLayout()
end


function PANEL:PerformLayout()
   if self.rowcount < 1 then
      self:SetVisible(false)
      return
   end

   self:SetSize(self:GetWide(), 30 + self.rowcount + self.rowcount * SB_ROW_HEIGHT)

   -- Sort and layout player rows
   self:UpdateSortCache()

   local y = 24
   for k, v in ipairs(self.rows_sorted) do
      v:SetPos(0, y)
      v:SetSize(self:GetWide(), v:GetTall())

      y = y + v:GetTall()-- + 1
   end

   self:SetSize(self:GetWide(), 24 + (y - 24))
end

vgui.Register("TTTScoreGroup", PANEL, "Panel")
