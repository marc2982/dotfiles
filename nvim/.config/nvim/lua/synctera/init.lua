-- [nfnl] fnl/synctera.fnl
local M = {}
local registry_cache = nil
local jwt_cache = {}
local jwt_refresh_margin = 60
local synctera_host_pattern = "[%w-]+%.syncteraops%.com$"
local function current_env()
  return (vim.g.synctera_env or "dev")
end
local function shell(cmd)
  local out = vim.fn.system(cmd)
  if vim.v.shell_error == 0 then
    return vim.trim(out)
  else
    vim.notify(("synctera: `" .. cmd .. "` failed:\n" .. out), vim.log.levels.ERROR)
    return nil
  end
end
local function b64url_decode(s)
  local s0 = s:gsub("-", "+"):gsub("_", "/")
  local pad = (#s0 % 4)
  local s1
  if pad > 0 then
    s1 = (s0 .. string.rep("=", (4 - pad)))
  else
    s1 = s0
  end
  local ok, decoded = pcall(vim.base64.decode, s1)
  return (ok and decoded)
end
local function jwt_exp(token)
  if not token or (token == "") then
    return 0
  else
    local payload = token:match("^[^.]+%.([^.]+)%.")
    local decoded = (payload and b64url_decode(payload))
    local exp = (decoded and decoded:match('"exp"%s*:%s*(%d+)'))
    return (tonumber(exp) or 0)
  end
end
local function refresh_jwt(key, cmd)
  local entry = jwt_cache[key]
  local now = os.time()
  if entry and ((entry.exp - jwt_refresh_margin) > now) then
    return entry.token
  else
    local token = shell(cmd)
    if token then
      jwt_cache[key] = { token = token, exp = jwt_exp(token) }
    else
    end
    return token
  end
end
local function load_registry()
  local raw = shell("sc registry --format=json --with-synctera")
  if not raw then
    return {}
  else
    local ok, parsed = pcall(vim.json.decode, raw)
    if not ok then
      vim.notify("synctera: failed to parse `sc registry` JSON output", vim.log.levels.ERROR)
      return {}
    else
      local out = {}
      for svc, spec in pairs(parsed) do
        if (type(spec) == "table") and spec.envs then
          for env, env_spec in pairs(spec.envs) do
            if (type(env_spec) == "table") and env_spec.base_url then
              if nil == out[env] then
                out[env] = {}
              else
              end
              out[env][svc] = env_spec.base_url
            else
            end
          end
        else
        end
      end
      return out
    end
  end
end
local function registry()
  if nil == registry_cache then
    registry_cache = load_registry()
  else
  end
  return registry_cache
end
local function synctera_host_3f(url)
  local host = url:match("^https?://([^/]+)")
  return (host and host:match(synctera_host_pattern) and true)
end
local function header_set_3f(headers, name)
  local target = name:lower()
  local found = false
  for k, _ in pairs((headers or {})) do
    if found then
      break
    end
    found = (k:lower() == target)
  end
  return found
end
local function inject_auth_headers_21(request, env)
  if not header_set_3f(request.headers, "Authorization") then
    local token = refresh_jwt("iap", "sc jwt print-iap-token")
    if token then
      request.headers["Authorization"] = ("Bearer " .. token)
    else
    end
  else
  end
  -- Operations env is IAP-fronted only; no Synctera-Identity required.
  if env == "operations" then
    return nil
  end
  if not header_set_3f(request.headers, "Synctera-Identity") then
    local token = refresh_jwt(("synctera:" .. env), ("sc jwt --env " .. env))
    if token then
      request.headers["Synctera-Identity"] = token
      return nil
    else
      return nil
    end
  else
    return nil
  end
end
M["before-request"] = function(request)
  local env = current_env()
  local url = (request.url or "")
  if nil == request.headers then
    request["headers"] = {}
  else
  end
  if url:match("^https?://") then
    if synctera_host_3f(url) then
      inject_auth_headers_21(request, env)
    else
    end
  else
    local svc, rest = url:match("^([%w-]+)(.*)$")
    local base_url
    local and_18_ = svc
    if and_18_ then
      local t_19_ = registry()
      if nil ~= t_19_ then
        t_19_ = t_19_[env]
      else
      end
      if nil ~= t_19_ then
        t_19_ = t_19_[svc]
      else
      end
      and_18_ = t_19_
    end
    base_url = and_18_
    if base_url then
      request.url = (base_url .. (rest or ""))
      inject_auth_headers_21(request, env)
    else
      vim.notify(("synctera: unknown service `" .. (svc or url) .. "` in env `" .. env .. "`"), vim.log.levels.WARN)
    end
  end
  if vim.g.synctera_debug then
    local headers = request.headers or {}
    local line = string.format("[%s] env=%s url=%s auth=%s identity=%s\n",
      os.date("%H:%M:%S"), env, request.url,
      tostring(headers["Authorization"] ~= nil),
      tostring(headers["Synctera-Identity"] ~= nil))
    local f = io.open(vim.fn.stdpath("cache") .. "/synctera.log", "a")
    if f then
      f:write(line)
      f:close()
    end
  end
  return true
end
M["set-env"] = function(env)
  vim.g.synctera_env = env
  for k, _ in pairs(jwt_cache) do
    if k:match("^synctera:") then
      jwt_cache[k] = nil
    else
    end
  end
  return vim.notify(("synctera: env set to " .. env))
end
M.clear = function()
  registry_cache = nil
  for k, _ in pairs(jwt_cache) do
    jwt_cache[k] = nil
  end
  return vim.notify("synctera: caches cleared")
end
M.status = function()
  local env = current_env()
  local now = os.time()
  local svcs
  do
    local t_25_ = (registry_cache or {})
    if nil ~= t_25_ then
      t_25_ = t_25_[env]
    else
    end
    svcs = t_25_
  end
  local svc_count
  do
    local n = 0
    for _, _0 in pairs((svcs or {})) do
      n = (n + 1)
    end
    svc_count = n
  end
  local lines
  local _27_
  if nil == registry_cache then
    _27_ = "(not loaded)"
  else
    _27_ = tostring(svc_count)
  end
  lines = { ("synctera env: " .. env), ("  services in cache: " .. _27_) }
  for k, v in pairs(jwt_cache) do
    table.insert(lines, string.format("  jwt %s: %ds remaining", k, (v.exp - now)))
  end
  return vim.notify(table.concat(lines, "\n"))
end
return M
