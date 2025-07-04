-- 🌸 Style.lua — global pastel theme + reusable cuteness

local style = {}

-- Main pastel colors
style.colors = {
    pink = 0xFFC0CB,
    blue = 0xADD8E6,
    white = 0xFFFFFF
}

style.header = style.colors.pink
style.highlight = style.colors.blue
style.text = style.colors.white

-- Safe emojis for OpenComputers
style.emojis = {
    "*.*",
    "^_^",
    ":)",
    "⭐",
    "🌙",
    "✨",
    "<3"
}

-- Reusable sparkle styles
style.sparkleStyles = {
    "✦ ✧ ✩ ✪ ✫ ✦ ✧ ✩ ✪ ✫ ✦ ✧ ✩ ✪ ✫ ✦ ✧",
    "★ ☆ ★ ☆ ★ ☆ ★ ☆ ★ ☆ ★ ☆ ★ ☆ ★ ☆",
    "* + * + * + * + * + * + * + * + * +",
    "⭒ ⭑ ⭒ ⭑ ⭒ ⭑ ⭒ ⭑ ⭒ ⭑ ⭒ ⭑ ⭒ ⭑ ⭒ ⭑",
    "~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~"
}

-- Pastel ASCII cat
style.cat = [[
 /\_/\
( o.o )
 > ^ <
]]

-- Fortune quotes
style.fortunes = {
    "You are the sparkle in the code ✨",
    "Pastel dreams build bright machines!",
    "Take a break & stretch your paws ^_^",
    "You can do hard things ⭐",
    "GTNH loves your pastel vibe 🌙",
    "Stay cozy, craft cutely!"
}

-- ✅✅✅ This must be defined *inside* the table to export!
function style.printSignature()
    local gpu = require("component").gpu
    gpu.setForeground(style.highlight)
    print(style.cat)

    gpu.setForeground(style.text)
    local fortune = style.fortunes[math.random(#style.fortunes)]
    print(fortune)
end

return style
