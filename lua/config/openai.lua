local M = {}

local api_key_cache = nil

local shell_configs = { "~/.zshrc", "~/.bashrc", "~/.zprofile" }

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
		if vim.fn.filereadable(expanded) == 1 then
			vim.fn.system(string.format("source %s 2>/dev/null || true", expanded))
			key = vim.fn.getenv("OPENAI_API_KEY")
			if key and key ~= vim.NIL and key ~= "" then
				api_key_cache = key
				return key
			end
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

	local json_body = string.format(
		'{"model": "gpt-4o", "messages": [{"role": "user", "content": %s}], "max_tokens": 150, "temperature": 0.7}',
		vim.fn.json_encode(prompt)
	)

	local curl_cmd = string.format(
		'curl -s https://api.openai.com/v1/chat/completions -H "Authorization: Bearer %s" -H "Content-Type: application/json" -d \'%s\'',
		api_key,
		json_body
	)

	local output = vim.fn.system(curl_cmd)

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

	local test_json = '{"model": "gpt-4o", "messages": [{"role": "user", "content": "test"}], "max_tokens": 10}'
	local curl_cmd = string.format(
		'curl -s https://api.openai.com/v1/chat/completions -H "Authorization: Bearer %s" -H "Content-Type: application/json" -d \'%s\'',
		api_key,
		test_json
	)

	local output = vim.fn.system(curl_cmd)

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
