require("relative-motions"):setup({ show_numbers = "relative", show_motion = true })
require("gvfs"):setup({
	save_path = os.getenv("HOME") .. "/.config/yazi/gvfs.private",
	password_vault = "keyring",
})

-- Owner, group, readable size and newest of mtime/btime; shared by the linemode and the status bar.
local function file_info(file)
	local cha = file.cha
	local user = ya.user_name(cha.uid) or tostring(cha.uid or "")
	local group = ya.group_name(cha.gid) or tostring(cha.gid or "")
	local size = file:size()
	local size_s = size and ya.readable_size(size) or "-"
	local time = math.max(math.floor(cha.mtime or 0), math.floor(cha.btime or 0))
	return user, group, size_s, time
end

function Linemode:perms_owner_time()
	local user, group, size, time = file_info(self._file)
	local perm = self._file.cha:perm() or ""

	local date = ""
	if time > 0 then
		local same_year = os.date("%Y", time) == os.date("%Y")
		date = os.date(same_year and "%b %d %H:%M" or "%b %d  %Y", time)
	end

	return string.format("%s  %s  %s:%s  %s", size, perm, user, group, date)
end

Status:children_add(function()
	local h = cx.active.current.hovered
	if not h or ya.target_family() ~= "unix" then
		return ""
	end

	local user, group, size, time = file_info(h)
	local date = time > 0 and os.date("%b %d %H:%M", time) or ""

	return ui.Line {
		ui.Span(size .. "  "):fg("cyan"),
		ui.Span(user .. ":" .. group .. "  "):fg("magenta"),
		ui.Span(date .. "  "):fg("blue"),
	}
end, 500, Status.RIGHT)

Status:children_add(function()
	local files = cx.active.current.files
	local count, total = 0, 0
	for i = 1, #files do
		local f = files[i]
		if f:is_selected() then
			count = count + 1
			total = total + (f:size() or 0)
		end
	end
	if count == 0 then
		return ""
	end
	return ui.Line {
		ui.Span(string.format(" %d sel %s ", count, ya.readable_size(total))):fg("yellow"),
	}
end, 600, Status.RIGHT)
