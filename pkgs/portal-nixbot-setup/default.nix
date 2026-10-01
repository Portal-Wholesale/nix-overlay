{
  lib,
  writeShellApplication,
  coreutils,
  flock,
  python3,
}:

# Idempotently registers the Portal Nixbot server in ~/.config/nixbot/hosts.toml
# so `nbo` authenticates through the Tailscale proxy without a token. Existing
# entries and invalid config are never overwritten.
writeShellApplication {
  name = "portal-nixbot-setup";

  runtimeInputs = [
    coreutils
    flock
    python3
  ];

  text = ''
    url="''${NIXBOT_URL:-https://nixbot.tailb22a98.ts.net}"
    config_dir="''${XDG_CONFIG_HOME:-$HOME/.config}/nixbot"
    hosts_file="$config_dir/hosts.toml"

    mkdir -p "$config_dir"
    chmod 700 "$config_dir"
    (
      umask 077
      flock -x 9
      python3 - "$hosts_file" "$url" <<'PY'
    import json
    import os
    import sys
    import tomllib
    from pathlib import Path

    path = Path(sys.argv[1])
    url = sys.argv[2]
    text = path.read_text() if path.exists() else ""
    try:
        hosts = tomllib.loads(text) if text else {}
    except tomllib.TOMLDecodeError as error:
        print(f"warning: not updating invalid nixbot config {path}: {error}", file=sys.stderr)
        raise SystemExit(0)
    if url in hosts:
        entry = hosts[url]
        if isinstance(entry, dict) and ({"token", "token_command"} & entry.keys()):
            print(f"warning: bearer auth in {path} overrides Tailscale proxy auth for {url}", file=sys.stderr)
        raise SystemExit(0)
    with path.open("a") as config:
        if text and not text.endswith("\n"):
            config.write("\n")
        if text:
            config.write("\n")
        config.write(f"[{json.dumps(url)}]\n")
    os.chmod(path, 0o600)
    PY
    ) 9>"$hosts_file.lock"
    chmod 600 "$hosts_file.lock"
  '';

  meta = {
    description = "Register the Portal Nixbot server in the local nbo config";
    mainProgram = "portal-nixbot-setup";
    platforms = lib.platforms.unix;
  };
}
