-- Modifyed HUD by Hillzy37

local table = table
local surface = surface
local draw = draw
local math = math
local string = string

local GetTranslation = LANG.GetTranslation
local GetPTranslation = LANG.GetParamTranslation
local GetLang = LANG.GetUnsafeLanguageTable
local interp = string.Interp

local TopBarText1 = Color(250,230,55) //Color of the wave/stage text
local TopBarText2 = Color(180,55,55) //Color of the Next Boxx text

local Healthbar = Color(255,100,0) //Color of the Health
local Armorbar = Color(0,100,255) //Color of the Armor

local ActivePanel = Color(255,100,0) //Color of the Active panel text

local LeftTop = Color(0,0,0) //Color of the text at the top of the screen

local ammoposx = ScrW() - 430 --The X position of the ammo group of HUD (ammo clip, etc)
local ammoposy = ScrH() - 29 --The Y position of the ammo group of HUD (ammo clip, etc)

local ammocolor = Color(0,100,255,255)


local ammocolor2 = Color(0,100,255,255)--Extra ammo text color


--[[---------------------------------------------------------
Making the Polys ready for use
-------------------------------------------------------------]]
															               --[
 x1 = 8 //Position of Leftbase								      --[
 y1 = ScrH() - 28											            --[
 leftbase = {{ },{ },{ },{ }} 								      --[
															               --[
 --First Vertex											          	--[
leftbase[1]["x"] = x1									         	--[
leftbase[1]["y"] = y1									         	--[
leftbase[1]["u"] = 0 //Top Left							       	--[
leftbase[1]["v"] = 0									             	--[
														                	--[
 --Second Vertex									              		--[
leftbase[2]["x"] = x1 + 285									      --[	        LEFT BASE
leftbase[2]["y"] = y1										         --[
leftbase[2]["u"] = 1 //Top Right							         --[
leftbase[2]["v"] = 0										            --[
															               --[
 --Third Vertex												         --[
leftbase[3]["x"] = x1 + 306									      --[
leftbase[3]["y"] = y1 + 20									         --[
leftbase[3]["u"] = 0 //Bottom right							      --[
leftbase[3]["v"] = 1										            --[
  --Fourth Vertex											            --[
leftbase[4]["x"] = x1 										         --[
leftbase[4]["y"] = y1  + 20									      --[
leftbase[4]["u"] = 1 //Bottom left							      --[
leftbase[4]["v"] = 0										            --[
--------------------------------------------------------------[
 x2 = 6 //Position of Leftbase								      --[
 y2 = ScrH() - 30											            --[
leftborder = {{ },{ },{ },{ }} 								      --[
															               --[
 --First Vertex												         --[
leftborder[1]["x"] = x2										         --[
leftborder[1]["y"] = y2										         --[
leftborder[1]["u"] = 0 //Top Left							      --[
leftborder[1]["v"] = 0										         --[
															--[
 --Second Vertex											--[
leftborder[2]["x"] = x2 + 288								--[			LEFT BASE BORDER
leftborder[2]["y"] = y2 									--[
leftborder[2]["u"] = 1 //Top Right							--[
leftborder[2]["v"] = 0										--[
															--[
 --Third Vertex												--[
leftborder[3]["x"] = x2 + 313								--[
leftborder[3]["y"] = y2 + 24								--[
leftborder[3]["u"] = 0 //Bottom right						--[	
leftborder[3]["v"] = 1										--[
  --Fourth Vertex											--[
leftborder[4]["x"] = x2 									--[
leftborder[4]["y"] = y2  + 24								--[
leftborder[4]["u"] = 1 //Bottom left						--[
leftborder[4]["v"] = 0										--[										
--------------------------------------------------------------
															--[
 x3 = ScrW() - 323 //Position of rightbase					--[
 y3 = ScrH() - 28											--[
 rightbase = {{ },{ },{ },{ }} 								--[
															--[
 --First Vertex												--[
rightbase[1]["x"] = x3 + 20									--[
rightbase[1]["y"] = y3										--[
rightbase[1]["u"] = 0 //Top Left							--[
rightbase[1]["v"] = 0										--[
															--[
 --Second Vertex											--[
rightbase[2]["x"] = x3 + 310								--[			RIGHT BASE
rightbase[2]["y"] = y3										--[
rightbase[2]["u"] = 1 //Top Right							--[
rightbase[2]["v"] = 0										--[
															--[
 --Third Vertex												--[
rightbase[3]["x"] = x3 + 310								--[
rightbase[3]["y"] = y3 + 20									--[
rightbase[3]["u"] = 0 //Bottom right						--[
rightbase[3]["v"] = 1										--[
  --Fourth Vertex											--[
rightbase[4]["x"] = x3 	- 0									--[
rightbase[4]["y"] = y3  + 20								--[
rightbase[4]["u"] = 1 //Bottom left							--[
rightbase[4]["v"] = 0										--[
--------------------------------------------------------------[
 x4 = ScrW() - 361 //Position of rightbase					--[
 y4 = ScrH() - 30											--[
rightborder = {{ },{ },{ },{ }} 							--[
															--[
 --First Vertex												--[
rightborder[1]["x"] = x4 + 56								--[
rightborder[1]["y"] = y4									--[
rightborder[1]["u"] = 0 //Top left							--[
rightborder[1]["v"] = 0										--[
															--[
 --Second Vertex											--[
rightborder[2]["x"] = x4 + 350								--[			RIGHT BASE BORDER
rightborder[2]["y"] = y4 									--[
rightborder[2]["u"] = 1 //Top Right							--[
rightborder[2]["v"] = 0										--[
															--[
 --Third Vertex												--[
rightborder[3]["x"] = x4 + 350								--[
rightborder[3]["y"] = y4 + 24.5								--[
rightborder[3]["u"] = 0 //Bottom right						--[	
rightborder[3]["v"] = 1										--[
  --Fourth Vertex											--[
rightborder[4]["x"] = x4  + 31								--[
rightborder[4]["y"] = y4  + 24.5							--[
rightborder[4]["u"] = 1 //Bottom right						--[
rightborder[4]["v"] = 0										--[										
--------------------------------------------------------------[
--------------------------------------------------------------
															--[
 x5 = ScrW()/2 - 200 //Position of TOP base					--[
 y5 = 4.1														--[
 topbase = {{ },{ },{ },{ }} 								--[
															--[
 --First Vertex												--[
topbase[1]["x"] = x5 + 100									--[
topbase[1]["y"] = y5										--[
topbase[1]["u"] = 0 //Top Left								--[
topbase[1]["v"] = 0											--[
															--[
 --Second Vertex											--[
topbase[2]["x"] = x5 + 310									--[			TOP BASE
topbase[2]["y"] = y5										--[
topbase[2]["u"] = 1 //Top Right								--[
topbase[2]["v"] = 0											--[
															--[
 --Third Vertex												--[
topbase[3]["x"] = x5 + 290									--[
topbase[3]["y"] = y5 + 30									--[
topbase[3]["u"] = 0 //Bottom right							--[
topbase[3]["v"] = 1											--[
  --Fourth Vertex											--[
topbase[4]["x"] = x5  + 120									--[
topbase[4]["y"] = y5  + 30									--[
topbase[4]["u"] = 1 //Bottom left							--[
topbase[4]["v"] = 0											--[
--------------------------------------------------------------[
 x6 = ScrW()/2 - 202 //Position of topbase					--[
 y6 = 1.59													--[
topborder = {{ },{ },{ },{ }} 								--[
															--[
 --First Vertex												--[
topborder[1]["x"] = x6 + 98									--[
topborder[1]["y"] = y6										--[
topborder[1]["u"] = 0 //Top left							--[
topborder[1]["v"] = 0										--[
															--[
 --Second Vertex											--[
topborder[2]["x"] = x6 + 316								--[			TOP BASE BORDER
topborder[2]["y"] = y6 										--[
topborder[2]["u"] = 0 //Top Right							--[
topborder[2]["v"] = 0										--[
															--[
 --Third Vertex												--[
topborder[3]["x"] = x6 + 293								--[
topborder[3]["y"] = y6 + 35									--[
topborder[3]["u"] = 0 //Bottom right						--[	
topborder[3]["v"] = 0										--[
  --Fourth Vertex											--[
topborder[4]["x"] = x6  + 121								--[
topborder[4]["y"] = y6  + 35								--[
topborder[4]["u"] = 0 //Bottom right						--[
topborder[4]["v"] = 0										--[										
--------------------------------------------------------------[
															--[
 x5 = ScrW()/2 - 200 //Position of bot base					--[
 y5 = ScrH() - 34													--[
 botbase = {{ },{ },{ },{ }} 								--[
															--[
 --First Vertex												--[
botbase[1]["x"] = x5 + 120									--[
botbase[1]["y"] = y5										--[
botbase[1]["u"] = 0 //bot Left								--[
botbase[1]["v"] = 0											--[
															--[
 --Second Vertex											--[
botbase[2]["x"] = x5 + 290									--[			bot BASE
botbase[2]["y"] = y5										--[
botbase[2]["u"] = 1 //bot Right								--[
botbase[2]["v"] = 0											--[
															--[
 --Third Vertex												--[
botbase[3]["x"] = x5 + 310									--[
botbase[3]["y"] = y5 + 30									--[
botbase[3]["u"] = 0 //Bottom right							--[
botbase[3]["v"] = 1											--[
  --Fourth Vertex											--[
botbase[4]["x"] = x5  + 100									--[
botbase[4]["y"] = y5  + 30									--[
botbase[4]["u"] = 1 //Bottom left							--[
botbase[4]["v"] = 0											--[
--------------------------------------------------------------[
 x6 = ScrW()/2 - 202 //Position of botbase					--[
 y6 = ScrH() - 32													--[
botborder = {{ },{ },{ },{ }} 								--[
								--[
															--[
 --First Vertex												--[
botborder[1]["x"] = x6 + 120									--[
botborder[1]["y"] = y6	 - 5									--[
botborder[1]["u"] = 0 //top Left								--[
botborder[1]["v"] = 0											--[
															--[
 --Second Vertex											--[
botborder[2]["x"] = x6 + 294									--[			bot border
botborder[2]["y"] = y6 - 5									--[
botborder[2]["u"] = 1 //top Right								--[
botborder[2]["v"] = 0											--[
															--[
 --Third Vertex												--[
botborder[3]["x"] = x6 + 317									--[
botborder[3]["y"] = y6 + 30									--[
botborder[3]["u"] = 0 //Bottom right							--[
botborder[3]["v"] = 1											--[
  --Fourth Vertex											--[
botborder[4]["x"] = x6  + 97									--[
botborder[4]["y"] = y6  + 30									--[
botborder[4]["u"] = 1 //Bottom left							--[
botborder[4]["v"] = 0										--[										
--------------------------------------------------------------[


-- Fonts
surface.CreateFont("TraitorState", {font = "Trebuchet24",
                                    size = 28,
                                    weight = 1000})
surface.CreateFont("TimeLeft",     {font = "Trebuchet24",
                                    size = 24,
                                    weight = 800})
surface.CreateFont("HealthAmmo",   {font = "Trebuchet24",
                                    size = 24,
                                    weight = 750})
-- Color presets
local bg_colors = {
   background_main = Color(0, 0, 10, 255),

   noround = Color(100,100,100,255),
   traitor = Color(200, 25, 25, 255),
   innocent = Color(25, 200, 25, 255),
   detective = Color(25, 25, 200, 255)
};

local health_colors = {
   border = COLOR_WHITE,
   background = Color(100, 25, 25, 222),
   fill = Color(200, 50, 50, 250)
};

local ammo_colors = {
   border = COLOR_WHITE,
   background = Color(20, 20, 5, 222),
   fill = Color(205, 155, 0, 255)
};

--[[---------------------------------------------------------
Creating the fonts
-----------------------------------------------------------]]

surface.CreateFont("smallest",
	{
		font = "Trebuchet MS",
		size = 18,
		weight = 200
	}
)

surface.CreateFont("medium",
	{
		font = "Trebuchet MS",
		size = 22,
		weight = 1000
	}
)
surface.CreateFont("medium2",
	{
		font = "Trebuchet MS",
		size = 19,
		weight = 1000
	}
)

surface.CreateFont("large",
	{
		font = "Trebuchet MS",
		size = 26,
		weight = 600
	}
)

-- Modified RoundedBox
local Tex_Corner8 = surface.GetTextureID( "gui/corner8" )
local function RoundedMeter( bs, x, y, w, h, color)
   surface.SetDrawColor(clr(color))

   surface.DrawRect( x+bs, y, w-bs*2, h )
   surface.DrawRect( x, y+bs, bs, h-bs*2 )

   surface.SetTexture( Tex_Corner8 )
   surface.DrawTexturedRectRotated( x + bs/2 , y + bs/2, bs, bs, 0 )
   surface.DrawTexturedRectRotated( x + bs/2 , y + h -bs/2, bs, bs, 90 )

   if w > 14 then
      surface.DrawRect( x+w-bs, y+bs, bs, h-bs*2 )
      surface.DrawTexturedRectRotated( x + w - bs/2 , y + bs/2, bs, bs, 270 )
      surface.DrawTexturedRectRotated( x + w - bs/2 , y + h - bs/2, bs, bs, 180 )
   else
      surface.DrawRect( x + math.max(w-bs, bs), y, bs/2, h )
   end

end

---- The bar painting is loosely based on:
---- http://wiki.garrysmod.com/?title=Creating_a_HUD

-- Paints a graphical meter bar
local function PaintBar(x, y, w, h, colors, value)
   -- Background
   -- slightly enlarged to make a subtle border
   draw.RoundedBox(8, x-1, y-1, w+2, h+2, colors.background)

   -- Fill
   local width = w * math.Clamp(value, 0, 1)

   if width > 0 then
      RoundedMeter(8, x, y, width, h, colors.fill)
   end
end

local roundstate_string = {
   [ROUND_WAIT]   = "round_wait",
   [ROUND_PREP]   = "round_prep",
   [ROUND_ACTIVE] = "round_active",
   [ROUND_POST]   = "round_post"
};

-- Returns player's ammo information
local function GetAmmo(ply)
   local weap = ply:GetActiveWeapon()
   if not weap or not ply:Alive() then return -1 end

   local ammo_inv = weap:Ammo1() or 0
   local ammo_clip = weap:Clip1() or 0
   local ammo_max = weap.Primary.ClipSize or 0

   return ammo_clip, ammo_max, ammo_inv
end

local function DrawBg(x, y, width, height, client)
   -- Traitor area sizes
   local th = 30
   local tw = 170

   -- Adjust for these
   y = y - th
   height = height + th

   -- main bg area, invariant
   -- encompasses entire area
   -- main border, traitor based

  
end

local sf = surface
local dr = draw

local function ShadowedText(text, font, x, y, color, xalign, yalign)

   dr.SimpleText(text, font, x+2, y+2, COLOR_BLACK, xalign, yalign)// HEALTH TEXT

   dr.SimpleText(text, font, x, y, color, xalign, yalign)// HEALTH TEXT
end

local margin = 10

-- Paint punch-o-meter
local function PunchPaint(client)
   local L = GetLang()
   local punch = client:GetNWFloat("specpunches", 0)

   local width, height = 200, 25
   local x = ScrW() / 2 - width/2
   local y = margin/2 + height

   PaintBar(x, y, width, height, ammo_colors, punch)

   local color = bg_colors.background_main

   dr.SimpleText(L.punch_title, "HealthAmmo", ScrW() / 2, y, color, TEXT_ALIGN_CENTER)

   dr.SimpleText(L.punch_help, "TabLarge", ScrW() / 2, margin, COLOR_WHITE, TEXT_ALIGN_CENTER)

   local bonus = client:GetNWInt("bonuspunches", 0)
   if bonus != 0 then
      local text
      if bonus < 0 then
         text = interp(L.punch_bonus, {num = bonus})
      else
         text = interp(L.punch_malus, {num = bonus})
      end

      dr.SimpleText(text, "TabLarge", ScrW() / 2, y * 2, COLOR_WHITE, TEXT_ALIGN_CENTER)
   end
end

local key_params = { usekey = Key("+use", "USE") }

local function SpecHUDPaint(client)
   local L = GetLang() -- for fast direct table lookups

   -- Draw round state
   local x       = margin
   local height  = 32
   local width   = 250
   local round_y = ScrH() - height - margin

   -- move up a little on low resolutions to allow space for spectator hints
   if ScrW() < 1000 then round_y = round_y - 15 end

   local time_x = x + 170
   local time_y = round_y + 4

   draw.RoundedBox(8, x, round_y, width, height, bg_colors.background_main)
   draw.RoundedBox(8, x, round_y, time_x - x, height, bg_colors.noround)

   local text = L[ roundstate_string[GAMEMODE.round_state] ]
   ShadowedText(text, "TraitorState", x + margin, round_y, COLOR_WHITE)

   -- Draw round/prep/post time remaining
   local text = util.SimpleTime(math.max(0, GetGlobalFloat("ttt_round_end", 0) - CurTime()), "%02i:%02i")
   ShadowedText(text, "TimeLeft", time_x + margin, time_y, COLOR_WHITE)

   local tgt = client:GetObserverTarget()
   if IsValid(tgt) and tgt:IsPlayer() then
      ShadowedText(tgt:Nick(), "TimeLeft", ScrW() / 2, margin, COLOR_WHITE, TEXT_ALIGN_CENTER)

   elseif IsValid(tgt) and tgt:GetNWEntity("spec_owner", nil) == client then
      PunchPaint(client)
   else
      ShadowedText(interp(L.spec_help, key_params), "TabLarge", ScrW() / 2, margin, COLOR_WHITE, TEXT_ALIGN_CENTER)
   end
end

local ttt_health_label = CreateClientConVar("ttt_health_label", "0", true)

local function InfoPaint(client)
   local L = GetLang()

   local width = 250
   local height = 90

   local x = margin
   local y = ScrH() - margin - height

   DrawBg(x, y, width, height, client)

   local bar_height = 25
   local bar_width = width - (margin*2)

   -- Draw health
   local health = math.max(0, client:Health())
   local health_y = y + margin





   if ttt_health_label:GetBool() then
      local health_status = util.HealthToString(health)
      draw.SimpleText(L[health_status], "TabLarge", x + margin*2, 2, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
   end

  

   -- Draw traitor state
   local round_state = GAMEMODE.round_state

   local traitor_y = ScrH() - 65
   local text = nil
   if round_state == ROUND_ACTIVE then
      text = L[ client:GetRoleStringRaw() ]
   else
      text = L[ roundstate_string[round_state] ]
   end

   ShadowedText(text, "TraitorState", ScrW()/2 + 2, ScrH() - 34, COLOR_WHITE, TEXT_ALIGN_CENTER)

   -- Draw round time
   local is_haste = HasteMode() and round_state == ROUND_ACTIVE
   local is_traitor = client:IsActiveTraitor()

   local endtime = GetGlobalFloat("ttt_round_end", 0) - CurTime()

   local text
   local font = "TimeLeft"
   local color = COLOR_WHITE
   local rx = ScrW()/2 - 25
   local ry = ScrH() - 65

   -- Time displays differently depending on whether haste mode is on,
   -- whether the player is traitor or not, and whether it is overtime.
   if is_haste then
      local hastetime = GetGlobalFloat("ttt_haste_end", 0) - CurTime()
      if hastetime < 0 then
         if (not is_traitor) or (math.ceil(CurTime()) % 7 <= 2) then
            -- innocent or blinking "overtime"
            text = L.overtime
            font = "Trebuchet18"

            -- need to hack the position a little because of the font switch
            ry = ry + 7
            rx = rx - 3
         else
            -- traitor and not blinking "overtime" right now, so standard endtime display
            text  = util.SimpleTime(math.max(0, endtime), "%02i:%02i")
            color = COLOR_RED
         end
      else
         -- still in starting period
         local t = hastetime
         if is_traitor and math.ceil(CurTime()) % 6 < 2 then
            t = endtime
            color = COLOR_RED
         end
         text = util.SimpleTime(math.max(0, t), "%02i:%02i")
      end
   else
      -- bog standard time when haste mode is off (or round not active)
      text = util.SimpleTime(math.max(0, endtime), "%02i:%02i")
   end

  

   if is_haste then
     ShadowedText(L.hastemode, "medium", ScrW()/2 - 80, ScrH() - 62, color )
	  ShadowedText(text, "large", ScrW()/2 + 23, ScrH() - 65, color)
   else
    ShadowedText(text, font, ScrW()/2 - 25, ScrH() - 65, color)
	end

end

-- Paints player status HUD element in the bottom left
function GM:HUDPaint()
   local client = LocalPlayer()

   GAMEMODE:HUDDrawTargetID()

   MSTACK:Draw(client)

   if (not client:Alive()) or client:Team() == TEAM_SPEC then
      SpecHUDPaint(client)

      return
   end
	

	--[[Drawing the bases]]--
	local blank = surface.GetTextureID( "vgui/white" )
	function draw.NoTexture()
		surface.SetTexture( blank )
	end
	surface.SetDrawColor(0,0,0,255)
	surface.DrawRect(5, ScrH() - 30,ScrW() - 17,24)
	
	surface.SetDrawColor(50,50,50,200)
	surface.DrawRect(5, ScrH() - 28,ScrW() - 200,20)
	
	surface.SetTexture( blank )	
	surface.SetDrawColor( 0, 0, 0, 255 ) 
   surface.DrawPoly( botborder )
   surface.DrawPoly( botbase )

	
	surface.SetDrawColor( 0, 0, 0, 240 ) 
   surface.DrawPoly( rightborder )
	
   surface.SetDrawColor( 50,50,50,200 ) 
   surface.DrawPoly( rightbase ) 
	
	surface.SetDrawColor( 0, 0, 0, 240 ) 
   surface.DrawPoly( leftborder )
	
   surface.SetDrawColor( 50,50,50,200 ) 
   surface.DrawPoly( leftbase ) 
	
   local col = bg_colors.innocent
   if GAMEMODE.round_state != ROUND_ACTIVE then
      col = bg_colors.noround
   elseif client:GetTraitor() then
      col = bg_colors.traitor
   elseif client:GetDetective() then
      col = bg_colors.detective
   end
   surface.SetDrawColor( col ) 
   surface.DrawPoly( botbase ) 
	
		--[HEALTH]--
	local MaxSquares = 350/21
	local client = LocalPlayer();
	local hp = client:Health();
	local hpr = math.Round(hp/6.3);
	local howManyLoops = hpr
		 for i=1, math.Clamp(howManyLoops, 0, MaxSquares) do
            surface.SetDrawColor(Healthbar);    
            surface.DrawTexturedRectRotated(1  + (i*18), ScrH() - 18, 7, 18,45);    
		end   
	draw.SimpleText(hp.."%","medium",318, ScrH()-29, Color(0,0,0))
	draw.SimpleText(hp.."%","medium",318, ScrH()-30, Color(255,100,0))
	if hp <= 35 then
		draw.SimpleText("LOW HEALTH WARNING!","smallest",131, ScrH()-25, Color(0,0,0))
		draw.SimpleText("LOW HEALTH WARNING!","smallest",130, ScrH()-26, Color(255,100,0))
		
	end
	
 
    
   local Maxammo = 350/20
      if LocalPlayer():Alive() then    
      local client = LocalPlayer();    
      if client:GetActiveWeapon():IsValid() then -- Here :D  
      local mag_left = client:GetActiveWeapon():Clip1()    
      if mag_left == 0 then  
      draw.SimpleText("NO AMMUNITION LEFT","smallest",ScrW() - 301, ScrH()-26, Color(0,100,255))
      draw.SimpleText("NO AMMUNITION LEFT","smallest",ScrW()- 300, ScrH()-25, Color(0,0,0))
      end
      if mag_left >= 1 then

      else


      end
      howManyLoops2 = mag_left;    
         for i=1, math.Clamp(howManyLoops2, 0, MaxSquares) do           
            surface.SetTexture( blank );    
            surface.SetDrawColor(0,100,255);    
            surface.DrawTexturedRectRotated(ScrW() - 6 + (i*-18), ScrH() - 18, 7, 18,-45);    
         end  
      end
   end    
   
   if LocalPlayer():GetActiveWeapon().Primary != nil then
    if (LocalPlayer():GetActiveWeapon():Clip1()*100)/LocalPlayer():GetActiveWeapon().Primary.ClipSize > 15 then
        ammocolor = Color(0,100,255,255)--Ammo clip text color
    else
        ammocolor = Color(255,0,0,255)--Ammo clip text color when is less that 25% of clip capacity
    end
	end
	
	//Ammo
	    --Weapons and stuff
    if client:GetActiveWeapon() != NULL then
        if client:GetActiveWeapon():Clip1() != -1 then
            if client:GetActiveWeapon():GetPrintName() != "#HL2_GravityGun" then
              --Clip
			  draw.SimpleText(client:GetActiveWeapon():Clip1().." / ","medium",ammoposx + 81, ammoposy + 2, Color(0,0,0),2,0)
              draw.SimpleText(client:GetActiveWeapon():Clip1().." / ","medium",ammoposx + 80, ammoposy, ammocolor,2,0)
        
                --Extra
                draw.SimpleText(client:GetAmmoCount(client:GetActiveWeapon():GetPrimaryAmmoType()),"medium",ammoposx + 81, ammoposy + 2, Color(0,0,0),0,0)
				draw.SimpleText(client:GetAmmoCount(client:GetActiveWeapon():GetPrimaryAmmoType()),"medium",ammoposx + 80, ammoposy, ammocolor,0,0)
            end
        else
            if client:GetAmmoCount(client:GetActiveWeapon():GetPrimaryAmmoType()) != 0 then
                draw.SimpleText(client:GetAmmoCount(client:GetActiveWeapon():GetPrimaryAmmoType()),"medium",ammoposx + 1, ammoposy + 2, Color(0,0,0),2,0)
				draw.SimpleText(client:GetAmmoCount(client:GetActiveWeapon():GetPrimaryAmmoType()),"medium",ammoposx, ammoposy, ammocolor,2,0)
            end
		end
	end

	
   RADAR:Draw(client)
   TBHUD:Draw(client)
   WSWITCH:Draw(client)

   VOICE.Draw(client)
   DISGUISE.Draw(client)

   GAMEMODE:HUDDrawPickupHistory()

   -- Draw bottom left info panel
   InfoPaint(client)
end

-- Hide the standard HUD stuff
local hud = {"CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo"}
function GM:HUDShouldDraw(name)
   for k, v in pairs(hud) do
      if name == v then return false end
   end

   return true
end


