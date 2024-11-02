-- Point Shop Configuration
PS = PS or {}
PS.Config = {
    -- Currency Settings
    Currencies = {
        Points = {
            Name = "Points",
            Symbol = "📍",
            Enabled = true
        },
        DarkRP = {
            Name = "DarkRP Money",
            Symbol = "$",
            Enabled = true,
            ExchangeRate = 100 -- 100 DarkRP Money = 1 Point
        },
        Custom = {
            Name = "Gems",
            Symbol = "💎",
            Enabled = true,
            ExchangeRate = 10 -- 10 Gems = 1 Point
        }
    },
    
    -- Categories
    Categories = {
        ["VIP"] = {
            icon = "icon16/star.png",
            order = 1
        },
        ["Commands"] = {
            icon = "icon16/application_xp_terminal.png",
            order = 2
        },
        ["Special"] = {
            icon = "icon16/wand.png",
            order = 3
        }
    }
}