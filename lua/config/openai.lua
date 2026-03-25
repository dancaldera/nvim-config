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

	local env_key = vim.fn.getenv(env_name)
	if env_key and env_key ~= vim.NIL and env_key ~= "" then
		api_key_cache[cache_name] = env_key
		return env_key
	end

	for _, config in ipairs(shell_configs) do
		local expanded = vim.fn.expand(config)
		local file_key = parse_api_key_from_shell_config(expanded, env_name)
		if file_key then
			api_key_cache[cache_name] = file_key
			return file_key
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

local function post_json_async(url, api_key, body, callback)
	if not vim.system then
		callback(nil, "vim.system is unavailable")
		return nil
	end

	local encoded_body = vim.fn.json_encode(body)
	local handle = vim.system(
		{
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
		},
		{
			text = true,
			stdin = encoded_body,
		},
		vim.schedule_wrap(function(result)
			if result.code ~= 0 then
				callback(nil, result.stderr ~= "" and result.stderr or "curl request failed")
				return
			end

			callback(result.stdout, nil)
		end)
	)
	return handle
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

local function get_commit_prompt(diff)
	return string.format(
		"Write a concise git commit message for these changes. Start with lowercase prefix (feat:, fix:, chore:, refactor:, docs:, test:, build:, ci:, perf:). Use imperative mood. Subject only unless body adds real value. Output plain text only, no markdown formatting.\n\nChanges:\n%s",
		diff
	)
end

M.generate_commit_message_async = function(diff, fallback_message, callback, handle_cb)
	local prompt = get_commit_prompt(diff)

	local function use_openrouter()
		local openrouter_api_key = M.get_openrouter_api_key()
		if not openrouter_api_key then
			vim.notify("No OPENAI_API_KEY or OPENROUTER_API_KEY found. Using fallback message.", vim.log.levels.WARN)
			callback(fallback_message)
			return
		end

		local h = post_json_async("https://openrouter.ai/api/v1/chat/completions", openrouter_api_key, {
			model = "openrouter/free",
			messages = {
				{ role = "user", content = prompt },
			},
			reasoning = {
				enabled = true,
			},
		}, function(output, err)
			if not output then
				vim.notify("OpenRouter API request failed: " .. err .. ". Using fallback message.", vim.log.levels.WARN)
				callback(fallback_message)
				return
			end

			local message, decode_err = decode_json(output)
			if not message then
				vim.notify(
					"OpenRouter API request failed: " .. decode_err .. ". Using fallback message.",
					vim.log.levels.WARN
				)
				callback(fallback_message)
				return
			end

			message = message:gsub("[\r\n]+", ""):gsub("^%s*(.-)%s*$", "%1")
			callback(message ~= "" and message or fallback_message)
		end)
		if handle_cb and h then
			handle_cb(h)
		end
	end

	local api_key = M.get_api_key()
	if not api_key then
		use_openrouter()
		return
	end

	local h = post_json_async("https://api.openai.com/v1/chat/completions", api_key, {
		model = "gpt-4o",
		messages = {
			{ role = "user", content = prompt },
		},
		max_tokens = 150,
		temperature = 0.7,
	}, function(output, err)
		if not output then
			vim.notify("OpenAI API request failed: " .. err .. ". Trying OpenRouter.", vim.log.levels.WARN)
			use_openrouter()
			return
		end

		local message, decode_err = decode_json(output)
		if not message then
			vim.notify("OpenAI API request failed: " .. decode_err .. ". Trying OpenRouter.", vim.log.levels.WARN)
			use_openrouter()
			return
		end

		message = message:gsub("[\r\n]+", ""):gsub("^%s*(.-)%s*$", "%1")
		callback(message ~= "" and message or fallback_message)
	end)
	if handle_cb and h then
		handle_cb(h)
	end
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

M.test_commit_message = function()
	local test_diff =
		"diff --git a/test.lua b/test.lua\nindex 123..456 789\n--- a/test.lua\n+++ b/test.lua\n@@ -1,3 +1,4 @@\n function test()\n+  print('hello')\n   return true\n end"
	local fallback = "[test] Auto-commit"

	vim.notify("Testing OpenAI commit message generation...", vim.log.levels.INFO)

	local openai_key = M.get_api_key()
	local openrouter_key = M.get_openrouter_api_key()

	if not openai_key and not openrouter_key then
		vim.notify("No API keys found. Set OPENAI_API_KEY or OPENROUTER_API_KEY.", vim.log.levels.ERROR)
		return
	end

	local completed = 0
	local total = (openai_key and 1 or 0) + (openrouter_key and 1 or 0)

	local function on_complete(provider, message)
		completed = completed + 1
		if message then
			vim.notify(string.format("%s result: %s", provider, message), vim.log.levels.INFO)
		end
		if completed == total then
			vim.notify("Test complete!", vim.log.levels.INFO)
		end
	end

	if openai_key then
		local prompt = get_commit_prompt(test_diff)
		vim.notify("Sending request to OpenAI (gpt-4o)...", vim.log.levels.INFO)
		post_json_async(
			"https://api.openai.com/v1/chat/completions",
			openai_key,
			{
				model = "gpt-4o",
				messages = { { role = "user", content = prompt } },
				max_tokens = 150,
				temperature = 0.7,
			},
			vim.schedule_wrap(function(output, err)
				if not output then
					vim.notify("OpenAI failed: " .. err, vim.log.levels.ERROR)
					on_complete("OpenAI", nil)
					return
				end
				local message, decode_err = decode_json(output)
				if not message then
					vim.notify("OpenAI decode failed: " .. decode_err, vim.log.levels.ERROR)
					on_complete("OpenAI", nil)
					return
				end
				message = message:gsub("[\r\n]+", ""):gsub("^%s*(.-)%s*$", "%1")
				on_complete("OpenAI", message ~= "" and message or fallback)
			end)
		)
	end

	if openrouter_key then
		local prompt = get_commit_prompt(test_diff)
		vim.notify("Sending request to OpenRouter (openrouter/free)...", vim.log.levels.INFO)
		post_json_async(
			"https://openrouter.ai/api/v1/chat/completions",
			openrouter_key,
			{
				model = "openrouter/free",
				messages = { { role = "user", content = prompt } },
				reasoning = { enabled = true },
			},
			vim.schedule_wrap(function(output, err)
				if not output then
					vim.notify("OpenRouter failed: " .. err, vim.log.levels.ERROR)
					on_complete("OpenRouter", nil)
					return
				end
				local message, decode_err = decode_json(output)
				if not message then
					vim.notify("OpenRouter decode failed: " .. decode_err, vim.log.levels.ERROR)
					on_complete("OpenRouter", nil)
					return
				end
				message = message:gsub("[\r\n]+", ""):gsub("^%s*(.-)%s*$", "%1")
				on_complete("OpenRouter", message ~= "" and message or fallback)
			end)
		)
	end
end

return M
