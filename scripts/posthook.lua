local function env(k)
  return os.getenv(k) or "unknown"
end

local status = tonumber(env("GHCTL_STATUS")) or 1
local log = io.open(os.getenv("HOME") .. "/.local/state/ghctl.log", "a")

log:write(string.format(
  "[POST] status=%d\n",
  status
))

if status ~= 0 then
  log:write("[ERROR] command failed\n")
end

log:close()

if status ~= 0 then
  os.exit(1)
end

