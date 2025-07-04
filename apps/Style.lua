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

-- Reusable cute emoji list
style.emojis = {"✨", "🌸", "💖", "🌙", "⭐", "🪐", "🌷"}

-- Reusable sparkle line styles
style.sparkleStyles = {
    "✦ ✧ ✩ ✪ ✫ ✦ ✧ ✩ ✪ ✫ ✦ ✧ ✩ ✪ ✫ ✦ ✧",
    "★ ☆ ★ ☆ ★ ☆ ★ ☆ ★ ☆ ★ ☆ ★ ☆ ★ ☆",
    "* + * + * + * + * + * + * + * + * +",
    "⭒ ⭑ ⭒ ⭑ ⭒ ⭑ ⭒ ⭑ ⭒ ⭑ ⭒ ⭑ ⭒ ⭑ ⭒ ⭑",
    "~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~"
}

-- Tiny pastel ASCII cat
style.cat = [[
 /\_/\
( o.o )
 > ^ <
]]

-- Random pastel fortune quotes
style.fortunes = {
    "You are the sparkle in the code 🌸",
    "Pastel dreams bring bright builds ✨",
    "Take a break & feed your cat 💖",
    "You can do hard things ⭐",
    "GTNH loves your pastel vibe 🌙",
    "Stay cozy, code cutely 🪐"
}

return style
