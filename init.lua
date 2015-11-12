-- i18n = internationalization
-- l10n = localization

if rawget(_G, "i18n") then return end

i18n = {}
i18n.locale = minetest.setting_get("language")
i18n.l10n = {}

function i18n.format(s, default, ...)
	local formatted = default or s
	if i18n.locale then formatted = i18n.l10n[s] or formatted end
	if ... then formatted = string.format(formatted, ...) end
	return formatted
end

function i18n.localize_mod(modname)
	if i18n.locale then
		modname = modname or minetest.get_current_modname()
		for name, def in pairs(minetest.registered_items) do
			if def.description and def.description ~= "" then
				if name:match("^"..modname..":") then
					minetest.override_item(name, {
						description = i18n.format(name, def.description)
					})
				end
			end
		end
	end
end

function i18n.localize_mods(modnames)
	if i18n.locale then
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

if i18n.locale then
	for i, modname in ipairs(minetest.get_modnames()) do
		local separator = package.config:sub(1, 1)
		local dir = minetest.get_modpath(modname)..separator.."locale"
		local exists = os.rename(dir, dir)
		
		if exists then
			local files
			
			if separator == "\\" or separator == "\\\\" then
				-- Windows
				files = io.popen('dir "'..dir..'" /b'):lines()
			else
				-- Unix?
				files = io.popen('ls -a "'..dir..'"'):lines()
			end
			
			for file in files do
				local locale, filetype = file:match("([^\\/]-)(%.?[^%.\\/]*)$")
				
				if locale == i18n.locale and filetype == ".lua" then
					local l10n = dofile(dir..separator..file)
					
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
					
					minetest.log("action", "Added localization from "..dir)
				end
			end
		end
	end
end
