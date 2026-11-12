#!/usr/bin/env bash
# Pripraví stack Gitea v ~/docker/gitea. Spúšťa sa vo WSL na serveri.
#   bash setup.sh                 # meno = plné meno Windows hostiteľa (už je v AD DNS)
#   bash setup.sh gitea.firma.sk  # meno dohodnuté s IT
# Stack nespúšťa. Existujúci .env nemení a heslá nikdy nevypisuje.
set -euo pipefail

src="$(cd "$(dirname "$0")" && pwd)"
dst="$HOME/docker/gitea"
gitea_image="gitea/gitea:28.2.0"

command -v docker >/dev/null || { echo "Docker nie je nainštalovaný." >&2; exit 1; }
docker info >/dev/null 2>&1 || { echo "Docker nebeží alebo používateľ nie je v skupine docker." >&2; exit 1; }

domain="${1:-}"
if [ -z "$domain" ]; then
  domain="$(powershell.exe -NoProfile -Command '[System.Net.Dns]::GetHostEntry("").HostName' | tr -d '\r')"
fi
domain="$(printf '%s' "$domain" | tr '[:upper:]' '[:lower:]')"
case "$domain" in
  ""|*://*|*:*|*/*|*" "*) echo "Neplatné meno: '$domain'. Bez https:// a bez portu." >&2; exit 1 ;;
  *.*) ;;
  *) echo "Pozor: '$domain' nie je plné DNS meno, počítač asi nie je v doméne. Zadajte meno ako argument." >&2; exit 1 ;;
esac

mkdir -p "$dst/certs"
stamp="$(date +%Y%m%d-%H%M%S)"
for f in docker-compose.yml Caddyfile .env.example; do
  if [ -f "$dst/$f" ] && ! cmp -s "$src/$f" "$dst/$f"; then
    cp "$dst/$f" "$dst/$f.bak-$stamp"
    echo "Záloha: $dst/$f.bak-$stamp"
  fi
  cp "$src/$f" "$dst/$f"
done

rnd() { head -c 48 /dev/urandom | base64 | tr -d '/+=\n' | cut -c1-48; }

if [ -f "$dst/.env" ]; then
  echo ".env už existuje, nemením ho. Meno v ňom: $(grep '^GITEA_DOMAIN=' "$dst/.env" | cut -d= -f2)"
else
  echo "Generujem .env pre $domain ..."
  secret="$(docker run --rm "$gitea_image" gitea generate secret SECRET_KEY | tr -d '\r\n')"
  token="$(docker run --rm "$gitea_image" gitea generate secret INTERNAL_TOKEN | tr -d '\r\n')"
  [ -n "$secret" ] && [ -n "$token" ] || { echo "Generovanie tajomstiev zlyhalo." >&2; exit 1; }
  (
    umask 077
    {
      echo "GITEA_DOMAIN=$domain"
      echo "POSTGRES_PASSWORD=$(rnd)"
      echo "GITEA_SECRET_KEY=$secret"
      echo "GITEA_INTERNAL_TOKEN=$token"
      echo "REQUIRE_SIGNIN_VIEW=true"
    } > "$dst/.env"
  )
fi
chmod 600 "$dst/.env"

cd "$dst"
docker compose config -q
docker run --rm -e GITEA_DOMAIN="$(grep '^GITEA_DOMAIN=' .env | cut -d= -f2)" \
  -v "$dst/Caddyfile:/etc/caddy/Caddyfile:ro" caddy:2 \
  caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile >/dev/null 2>&1 \
  || { echo "Caddyfile je neplatný: docker run --rm caddy:2 caddy validate ..." >&2; exit 1; }

echo "OK: konfigurácia v $dst je platná. Spustenie: cd $dst && docker compose up -d"
