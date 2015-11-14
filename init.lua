-- i18n = internationalization
-- l10n = localization

if rawget(_G, "i18n") then return end

i18n = {}
i18n.locale = minetest.setting_get("language")
i18n.l10n = {}

function i18n.has_locale()
	return i18n.locale and i18n.locale ~= ""
end

function i18n.format(default, key, ...)
	local formatted
	if i18n.has_locale() then formatted = i18n.l10n[key] end
	formatted = formatted or default
	if ... then formatted = string.format(formatted, ...) end
	return formatted
end

function i18n.localize_mod(modname)
	if i18n.has_locale() then
		modname = modname or minetest.get_current_modname()
		for name, def in pairs(minetest.registered_items) do
			if def.description and def.description ~= "" then
				if name:match("^"..modname..":") then
					minetest.override_item(name, {
						description = i18n.format(def.description, name)
					})
				end
			end
		end
	end
end

function i18n.localize_mods(modnames)
	if i18n.has_locale() then
		for name, def in pairs(minetest.registered_items) do
			if def.description and def.description ~= "" then
				for i, modname in ipairs(modnames) do
					if name:match("^"..modname..":") then
						minetest.override_item(name, {
							description = i18n.format(name, def.description)
						})
						break
					end
				end
			end
		end
	end
end

if i18n.has_locale() then
	for i, modname in ipairs(minetest.get_modnames()) do
		local dir = minetest.get_modpath(modname)..DIR_DELIM.."locale"
		local file = dir..DIR_DELIM..i18n.locale..".lua"
		
		if file_exists(file) then
			local l10n = dofile(file)
			
			if l10n then
				for name, description in pairs(l10n) do
					i18n.l10n[name] = description
					
					-- Localize item if mod already active
					local def = minetest.registered_items[name]
					if def and def.description and def.description ~= "" then
						minetest.override_item(name, {
							description = description or def.description
						})
					end
				end
				
				minetest.log("verbose", "Added localization from "..file)
			end
		end
	end
end
