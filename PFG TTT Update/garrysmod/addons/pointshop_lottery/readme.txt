PointShop Lottery by: Max

To install, extract pointshop_lottery.zip to "garrysmod\garrysmod\addons\", then just start up your server!

You must have _Undefined's pointshop already installed.

To configure the addon open up lottery_init.lua in "addons\pointshop_lottery\lua\ps_lottery\lottery_init.lua"

These are the settings that can be changed in lottery_init.lua, they are at the top of the file.

PSLottery.DefaultTime sets the amount of time between drawing in seconds. 
Default 1800 (30 minutes)

PSLottery.MaxValue Sets the range of possible numbers, this sets the "difficulty" in guessing the right number
Default 500, meaning 1 in 500 chance of guessing the current lotto number

PSLottery.TicketPrice sets the price of the tickets and how much the jackpot goes up with each ticket sale.
Default 5

PSLottery.StartingJackpot sets the default jackpot when the server first starts, and when someone wins
Default 100

PSLottery.MessageDelay Sets the delay in, seconds, that the server advertises the current time left before the drawing and the current jackpot
Default 180 (3 minutes) (Must be below PSLottery.DefaultTime)

PSLottery.Persistent Makes it so that the Jackpot is saved between server shutdowns / map changes.
Default true

PSLottery.MaxTickets sets how many tickets each player can buy per drawing.
Default 3