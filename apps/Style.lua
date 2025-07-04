-- 🌸 Style.lua — global pastel theme + cuteness

local style = {}

-- Main colors
style.colors = {
    pink = 0xFFC0CB,
    blue = 0xADD8E6,
    white = 0xFFFFFF
}

style.header = style.colors.pink
style.highlight = style.colors.blue
style.text = style.colors.white

-- Cute assets
style.emojis = {"✨", "🌸", "💖", "🌙", "⭐", "🪐", "🌷"}

style.sparkleStyles = {
    "✦ ✧ ✩ ✪ ✫ ✦ ✧ ✩ ✪ ✫ ✦ ✧ ✩ ✪ ✫ ✦ ✧",
    "★ ☆ ★ ☆ ★ ☆ ★ ☆ ★ ☆ ★ ☆ ★ ☆ ★ ☆",
    "* + * + * + * + * + * + * + * + * +",
    "⭒ ⭑ ⭒ ⭑ ⭒ ⭑ ⭒ ⭑ ⭒ ⭑ ⭒ ⭑ ⭒ ⭑ ⭒ ⭑",
    "~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~"
}

return style
