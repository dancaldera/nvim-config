local M = {}

local api_key_cache = nil

local shell_configs = { "~/.zshrc", "~/.bashrc", "~/.zprofile" }

local function parse_api_key_from_shell_config(path)
	if vim.fn.filereadable(path) ~= 1 then
		return nil
	end

	for _, line in ipairs(vim.fn.readfile(path)) do
		local value = line:match("^%s*export%s+OPENAI_API_KEY%s*=%s*(.+)%s*$")
			or line:match("^%s*OPENAI_API_KEY%s*=%s*(.+)%s*$")
		if value then
			value = value:gsub("%s+#.*$", "")
			value = value:gsub('^"(.*)"$', "%1")
			value = value:gsub("^'(.*)'$", "%1")
			if value ~= "" then
				return value
			end
		end
	end

	return nil
end

local function post_json(url, api_key, body)
	if not vim.system then
		return nil, "vim.system is unavailable"
	end

	local result = vim.system({
		"curl",
		"-sS",
		url,
		"-K",
		"-",
	}, {
		text = true,
		stdin = table.concat({
			string.format('header = "Authorization: Bearer %s"', api_key),
			'header = "Content-Type: application/json"',
			string.format("data = %s", vim.fn.json_encode(body)),
		}, "\n"),
	}):wait()

	if result.code ~= 0 then
		return nil, result.stderr ~= "" and result.stderr or "curl request failed"
	end

	return result.stdout, nil
end

M.get_api_key = function()
	if api_key_cache then
		return api_key_cache
	end

	local key = vim.fn.getenv("OPENAI_API_KEY")
	if key and key ~= vim.NIL and key ~= "" then
		api_key_cache = key
		return key
	end

	for _, config in ipairs(shell_configs) do
		local expanded = vim.fn.expand(config)
		key = parse_api_key_from_shell_config(expanded)
		if key then
			api_key_cache = key
			return key
		end
	end

	return nil
end

M.generate_commit_message = function(diff, fallback_message)
	local api_key = M.get_api_key()

	if not api_key then
		vim.notify("OPENAI_API_KEY not found. Using fallback message.", vim.log.levels.WARN)
		return fallback_message
	end

	local prompt = string.format(
		"Generate a conventional commit message for these git changes. Use format: type: description. Maximum 10 words total. Do not use scope.\n\nChanges:\n%s",
		diff
	)

	local output, err = post_json("https://api.openai.com/v1/chat/completions", api_key, {
		model = "gpt-4o",
		messages = {
			{ role = "user", content = prompt },
		},
		max_tokens = 150,
		temperature = 0.7,
	})
	if not output then
		vim.notify("OpenAI API request failed: " .. err .. ". Using fallback message.", vim.log.levels.WARN)
		return fallback_message
	end

	local success, data = pcall(vim.fn.json_decode, output)
	if not success then
		vim.notify("OpenAI API request failed (JSON decode error). Using fallback message.", vim.log.levels.WARN)
		vim.notify("Output: " .. output:sub(1, 200), vim.log.levels.DEBUG)
		return fallback_message
	end

	if not data.choices or #data.choices == 0 then
		if data.error then
			vim.notify("OpenAI API error: " .. (data.error.message or "Unknown error"), vim.log.levels.WARN)
		else
			vim.notify("OpenAI API request failed. Using fallback message.", vim.log.levels.WARN)
		end
		return fallback_message
	end

	local message = data.choices[1].message.content:gsub("[\r\n]+", ""):gsub("^%s*(.-)%s*$", "%1")
	return message ~= "" and message or fallback_message
end

M.test_api_key = function()
	local api_key = M.get_api_key()
	if not api_key then
		vim.notify("OPENAI_API_KEY not found", vim.log.levels.ERROR)
		return
	end

	vim.notify("OPENAI_API_KEY found (length: " .. #api_key .. ")", vim.log.levels.INFO)
	vim.notify("Testing API connection...", vim.log.levels.INFO)

	local output, err = post_json("https://api.openai.com/v1/chat/completions", api_key, {
		model = "gpt-4o",
		messages = {
			{ role = "user", content = "test" },
		},
		max_tokens = 10,
	})
	if not output then
		vim.notify("API test failed: " .. err, vim.log.levels.ERROR)
		return
	end

	local success, data = pcall(vim.fn.json_decode, output)
	if not success then
		vim.notify("API test failed: " .. output, vim.log.levels.ERROR)
	elseif data.error then
		vim.notify("API error: " .. (data.error.message or "Unknown error"), vim.log.levels.ERROR)
	else
		vim.notify("API test successful!", vim.log.levels.INFO)
	end
end

return M
