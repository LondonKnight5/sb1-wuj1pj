PS.Items = {
    ["vip_1month"] = {
        name = "VIP 1 Month",
        description = "Get VIP status for 1 month",
        category = "VIP",
        prices = {
            Points = 5000,
            DarkRP = 500000,
            Custom = 50000
        },
        icon = "icon16/star.png",
        command = function(ply)
            local steamid64 = ply:SteamID64()
            game.ConsoleCommand("ulx adduser " .. steamid64 .. " vip\n")
        end
    },
    ["health_boost"] = {
        name = "Health Boost",
        description = "Boost your health to 150",
        category = "Commands",
        prices = {
            Points = 1000,
            DarkRP = 100000,
            Custom = 10000
        },
        icon = "icon16/heart.png",
        command = function(ply)
            ply:SetHealth(150)
        end
    }
}