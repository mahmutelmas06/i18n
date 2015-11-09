-- i18n = internationalization
-- l10n = localization

i18n = {}
i18n.locale = minetest.setting_get("locale") or "en_US"
i18n.l10n = {}

minetest.log("info", "Locale: "..i18n.locale)

function i18n.format(s, args)
	return i18n.l10n[i18n.locale][s] or i18n.l10n["en_US"][s] or s
end

local supportedmods = {"beds", "boats", "bones", "bucket", "creative", "default", "doors", "dye", "farming", "fire", "flowers", "give_initial_stuff", "screwdriver", "sethome", "stairs", "tnt", "vessels", "wool", "xpanes"}

local function get_path(...)
    local separator = package.config:sub(1,1);
    local elements = {...}
    return table.concat(elements, separator)
end

local function file_exists(name)
	return os.rename(name, name) ~= nil
end

local function list_files(dir)
	-- Unix: ls -a dir
	return io.popen('dir "'..dir..'" /b'):lines()
end

for i, modname in ipairs(minetest.get_modnames()) do
	local langdir = get_path(minetest.get_modpath(modname), "lang")
	if file_exists(langdir) then
		for filename in list_files(langdir) do
			local lang, extension = filename:match("([^\\/]-)(%.?[^%.\\/]*)$")
			if extension == ".lua" then
				if i18n.l10n[lang] == nil then
					i18n.l10n[lang] = {}
				end
				
				local localization = dofile(get_path(langdir, filename))
				for k, v in pairs(localization) do
					i18n.l10n[lang][k] = v
				end
				
				minetest.log("action", "Added localization from "..langdir)
			end
		end
	end
end

for name, def in pairs(minetest.registered_items) do
	if def.description ~= nil and def.description ~= "" then
		for i, modname in ipairs(supportedmods) do
			if name:match("^"..modname..":") then
				minetest.override_item(name, {description = i18n.format(name)})
				break
			end
		end
	end
end
