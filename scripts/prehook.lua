

local function env(k)
  return os.getenv(k) or "unknown"
end

local log = io.open(os.getenv("HOME") .. "/.local/state/ghctl.log", "a")

log:write(string.format(
  "[PRE] mode=%s cmd=%s path=%s\n",
  env("GHCTL_MODE"),
  env("GHCTL_CMD"),
  env("GHCTL_PATH")
))

if env("GHCTL_CMD") == "push" then
  os.execute("git diff --quiet || echo '[WARN] uncommitted changes'")
end

log:close()
