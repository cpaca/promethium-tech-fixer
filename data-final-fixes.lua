local util = require("util")

local research_prod_ingredients = data.raw["technology"]["research-productivity"]["unit"]["ingredients"]
-- rpi_dict, short for research_prod_ingredients_dict
local rpi_dict = {}
for ingredient_idx, ingredient in pairs(research_prod_ingredients) do
    rpi_dict[ingredient[1]] = ingredient
end
-- Hmm. What if research_productivity tech uses 10 promethium science packs...?

data.raw["technology"]["research-productivity"]["prom-tech-fixer-ignore"] = true

log("Promethium tech fixer activating...")
for tech_name, tech in pairs(data.raw["technology"]) do
    -- For each tech:
    -- Determine if it uses a promethium science pack, and if it does, update it.
    if tech["prom-tech-fixer-ignore"] then
        -- Other mods can use this to get ignored by this mod
        -- but also this mod uses it so it doesn't update research prod
        goto continue
    end

    local tech_unit = tech["unit"]
    if not tech_unit then
        -- idk how this would be possible, but it IS marked as "Optional"
        goto continue
    end

    local tech_ingredients = tech_unit["ingredients"]
    if not tech_ingredients then
        -- this really shouldn't be possible (not marked as "optional") but i'll have the failsafe anyway
        goto continue
    end

    -- I did some thought, and this seems like the easiest way to set new ingredients.
    -- If I want to account for "tech that uses 2 promethium and 1000 red per craft", anyway.
    local ingredients_dict = {}

    for ingredient_idx, ingredient in pairs(tech_ingredients) do
        ingredients_dict[ingredient[1]] = ingredient
    end

    if not ingredients_dict["promethium-science-pack"] then
        -- No promethium science packs, do not update this one.
        goto continue
    end
    promethium_multiplier = ingredients_dict["promethium-science-pack"][2]
    log("Using a promethium multiplier of " .. promethium_multiplier)

    -- Fix the tech cost, add the new ingredients:
    local ingredient_added = false
    for ingredient_name, ingredient in pairs(rpi_dict) do
        log("rpi_dict ingredient looping " .. ingredient_name)
        if not ingredients_dict[ingredient_name] then
            log("Adding ingredient from rpi_dict: " .. ingredient_name)
            -- ingredient is not included: add it to the ingredients_dict
            ingredients_dict[ingredient_name] = util.table.deepcopy(ingredient)
            ingredients_dict[ingredient_name][2] = ingredients_dict[ingredient_name][2] * promethium_multiplier
            -- an ingredient was added to the ingredients_dict!
            ingredient_added = true
        end
    end
    if not ingredient_added then
        log("Warning: Nothing was actually added to the ingredients dict.")
    end
    log("Old ingredients dict: " .. serpent.block(tech_ingredients))
    -- log("Ingredients dict: " .. serpent.block(ingredients_dict))

    -- Now revert it back to an array[ResearchIngredient]
    local new_ingredients = {}
    for ingredient, research_ingredient in pairs(ingredients_dict) do
        table.insert(new_ingredients, research_ingredient)
    end
    log("New ingredients array: " .. serpent.block(new_ingredients))

    -- Put this array into the tech_ingredients and I think we're done.
    -- tech_unit["ingredients"] = new_ingredients
    data.raw["technology"][tech_name]["unit"]["ingredients"] = new_ingredients
    log("Updated ingredients for tech " .. tech_name)

    ::continue::
end