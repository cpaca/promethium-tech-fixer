local field_name = "planetslib_ensure_all_packs_from_vanilla_lab"

for tech_name, tech in pairs(data.raw["technology"]) do
    if tech[field_name] == false then
        log("field_name is false; will not be force-setting it to true for tech " .. tech_name)
        goto continue
    end

    tech_unit = tech["unit"]
    if not tech_unit then
        log("Could not find unit for tech " .. tech_name)
        goto continue
    end

    tech_ingredients = tech_unit["ingredients"]
    if not tech_ingredients then
        log("Found unit, couldn't find ingredients for tech " .. tech_name)
        goto continue
    end

    for _, ingredient in pairs(tech_ingredients) do
        if ingredient[1] == "promethium-science-pack" then
            log("force-setting field_name to true for tech " .. tech_name)
            data.raw["technology"][tech_name][field_name] = true
            break
        end
    end

    ::continue::
end