// Firstly, thank you for purchasing TTT BF4 Scoreboard!
// This scoreboard is purely inspired by Battlefield 4 and doesn't intend to be a complete copy,
// This config file contains a wide selection of settings that will help you to customize your hud
// But beware, some of these may cause 'bugs' if they're change to unacceptable values; I suggest you just play with them
// If you require this to be compatable with any addons you have installed, feel free to contact me on Steam - http://steamcommunity.com/id/Braden96
// Remember, if you liked the script; give it a lovely review!
// Extra information is at the end of the script!

bfscoreboard = {} // Do not edit this!

-- Scoreboard Main Settings
    -- Scoreboard Main
		bfscoreboard.scoreboardBGColor = Color(0, 0, 0, 220)
		bfscoreboard.scoreboardBGBlur = true
		bfscoreboard.scoreboardBGBlurStrength = 55
		bfscoreboard.titleAuto = false -- Uses your servers hostname, if set to true
		bfscoreboard.titleName = "Perilous Strike Gaming"
		bfscoreboard.titleColor = Color(255, 255, 255, 255)
		bfscoreboard.titleBGColor = Color(0, 0, 0, 120)
		bfscoreboard.columnDarkenColor = Color(180, 180, 180, 1)
		bfscoreboard.serverImageEnabled = true
		bfscoreboard.donateURL = "http://perilousstrikegaming.enjin.com/donate"
		bfscoreboard.websiteURL = "http://firehawkgaming.enjin.com/"

	-- Scoreboard Row
		bfscoreboard.rowHeight = 30
		bfscoreboard.rowBGColor = Color(27, 28, 33, 255)
		bfscoreboard.rowBGColorFade = Color(28, 29, 34, 255)
		bfscoreboard.rowBorderColor = Color(43, 44, 48, 255)
		bfscoreboard.rowBorderColorDark = Color(23, 24, 28, 255)

		bfscoreboard.terroristsBGColor = Color(116, 183, 62, 120)
		bfscoreboard.spectatorsBGColor = Color(125, 185, 231, 120)
		bfscoreboard.missingBGColor = Color(255, 153, 0, 120)
		bfscoreboard.confirmedBGColor =  Color(186, 50, 51, 120)

		bfscoreboard.localPlayerColor = "Random"
		bfscoreboard.detectiveColor = Color(30, 110, 255, 10)
		bfscoreboard.traitorColor = Color(205, 0, 0, 10)
		bfscoreboard.randomColorSpeed = 15 -- Make this 1, 3, 5, 15, 17, 51, or 85!

		bfscoreboard.adminMenuEnabled = true
		bfscoreboard.adminMenuBGColor = Color(94, 94, 100, 255)
		bfscoreboard.adminMenuBorderColor = Color(188, 188, 195, 255)

	-- Scoreboard Groups
		-- { ULXGROUPNAME, DISPLAYNAME, COLOR, ShowOnStaffMenu }
		bfscoreboard.ulxGroups = {
		{"superadmin", "Super-Admin", Color(50, 235, 50, 255), true},
		{"admin", "Admin", Color(30,144,255,255), true},
		{"operator", "Operator", Color(100, 255, 50)},
		{"user", "Guest", Color(255, 255, 255)}
		};



// Thank you so incredibly much for buying my script, please remember to leave a positive review; else contact me on Steam!
// Also, be sure to check out my other scripts!

-- Do not edit below this line!		
resource.AddFile( "resource/fonts/bfhud.ttf" )