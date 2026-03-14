local M = {}

local api_key_cache = {
	openai = nil,
	openrouter = nil,
}

local shell_configs = { "~/.zshrc", "~/.bashrc", "~/.zprofile", "~/.env" }

local function parse_api_key_from_shell_config(path, env_name)
	if vim.fn.filereadable(path) ~= 1 then
		return nil
	end

	for _, line in ipairs(vim.fn.readfile(path)) do
		local value = line:match("^%s*export%s+" .. env_name .. "%s*=%s*(.+)%s*$")
			or line:match("^%s*" .. env_name .. "%s*=%s*(.+)%s*$")
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

local function get_env_key(cache_name, env_name)
	if api_key_cache[cache_name] then
		return api_key_cache[cache_name]
	end

	local key = vim.fn.getenv(env_name)
	if key and key ~= vim.NIL and key ~= "" then
		api_key_cache[cache_name] = key
		return key
	end

	for _, config in ipairs(shell_configs) do
		local expanded = vim.fn.expand(config)
		key = parse_api_key_from_shell_config(expanded, env_name)
		if key then
			api_key_cache[cache_name] = key
			return key
		end
	end

	return nil
end

local function post_json(url, api_key, body)
	if not vim.system then
		return nil, "vim.system is unavailable"
	end

	local encoded_body = vim.fn.json_encode(body)
	local result = vim.system({
		"curl",
		"-sS",
		"-X",
		"POST",
		url,
		"-H",
		"Content-Type: application/json",
		"-H",
		"Authorization: Bearer " .. api_key,
		"--data-binary",
		"@-",
	}, {
		text = true,
		stdin = encoded_body,
	}):wait()

	if result.code ~= 0 then
		return nil, result.stderr ~= "" and result.stderr or "curl request failed"
	end

	return result.stdout, nil
end

local function decode_json(output)
	local success, data = pcall(vim.fn.json_decode, output)
	if not success then
		return nil, "JSON decode error", nil
	end

	if not data.choices or #data.choices == 0 then
		local api_error = data.error and (data.error.message or "Unknown error") or "Missing choices in response"
		return nil, api_error, data
	end

	local content = data.choices[1].message and data.choices[1].message.content or nil
	if not content or content == "" then
		return nil, "Empty response content", data
	end

	return content, nil, data
end

M.get_api_key = function()
	return get_env_key("openai", "OPENAI_API_KEY")
end

M.get_openrouter_api_key = function()
	return get_env_key("openrouter", "OPENROUTER_API_KEY")
end

M.generate_commit_message = function(diff, fallback_message)
	local prompt = string.format(
		"Generate a conventional commit message for these git changes. Use format: type: description. Maximum 10 words total. Do not use scope.\n\nChanges:\n%s",
		diff
	)

	local api_key = M.get_api_key()
	local output, err, message
	if api_key then
		output, err = post_json("https://api.openai.com/v1/chat/completions", api_key, {
			model = "gpt-4o",
			messages = {
				{ role = "user", content = prompt },
			},
			max_tokens = 150,
			temperature = 0.7,
		})
		if output then
			message, err = decode_json(output)
		end

		if not message then
			vim.notify("OpenAI API request failed: " .. err .. ". Trying OpenRouter.", vim.log.levels.WARN)
		end
	end

	if not message then
		local openrouter_api_key = M.get_openrouter_api_key()
		if openrouter_api_key then
			output, err = post_json("https://openrouter.ai/api/v1/chat/completions", openrouter_api_key, {
				model = "openrouter/free",
				messages = {
					{ role = "user", content = prompt },
				},
				reasoning = {
					enabled = true,
				},
			})
			if output then
				message, err = decode_json(output)
			end

			if not message then
				vim.notify("OpenRouter API request failed: " .. err .. ". Using fallback message.", vim.log.levels.WARN)
				return fallback_message
			end
		else
			vim.notify("No OPENAI_API_KEY or OPENROUTER_API_KEY found. Using fallback message.", vim.log.levels.WARN)
			return fallback_message
		end
	end

	message = message:gsub("[\r\n]+", ""):gsub("^%s*(.-)%s*$", "%1")
	return message ~= "" and message or fallback_message
end

M.test_api_key = function()
	local api_key = M.get_api_key()
	local provider = "OpenAI"

	if not api_key then
		api_key = M.get_openrouter_api_key()
		provider = "OpenRouter"
	end

	if not api_key then
		vim.notify("OPENAI_API_KEY and OPENROUTER_API_KEY not found", vim.log.levels.ERROR)
		return
	end

	vim.notify(provider .. " API key found (length: " .. #api_key .. ")", vim.log.levels.INFO)
	vim.notify("Testing API connection...", vim.log.levels.INFO)

	local output, err
	if provider == "OpenAI" then
		output, err = post_json("https://api.openai.com/v1/chat/completions", api_key, {
			model = "gpt-4o",
			messages = {
				{ role = "user", content = "test" },
			},
			max_tokens = 10,
		})
	else
		output, err = post_json("https://openrouter.ai/api/v1/chat/completions", api_key, {
			model = "openrouter/free",
			messages = {
				{ role = "user", content = "test" },
			},
			reasoning = {
				enabled = true,
			},
		})
	end

	if not output then
		vim.notify(provider .. " API test failed: " .. err, vim.log.levels.ERROR)
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
