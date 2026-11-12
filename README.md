# gitea-server

Gitea pre TIA SBOM Utility vo firemnej sieti: Caddy (HTTPS 443) → Gitea → PostgreSQL, Docker Engine vo WSL na Windows serveri.

## Súbory

| Súbor | Účel |
|---|---|
| `docker-compose.yml` | Stack. Von ide iba 80 (presmerovanie) a 443 cez Caddy |
| `Caddyfile` | HTTPS pre `GITEA_DOMAIN`, zatiaľ `tls internal`, neskôr certifikát firemnej CA |
| `.env.example` | Šablóna. Skutočný `.env` vytvorí `setup.sh` |
| `setup.sh` | Skopíruje súbory do `~/docker/gitea`, vygeneruje `.env` s náhodnými heslami, overí konfiguráciu |

## Dokumentácia

| Chcem | Dokument |
|---|---|
| nasadiť server od nuly | [docs/nasadenie.md](docs/nasadenie.md) |
| spravovať, aktualizovať, zálohovať | [docs/sprava.md](docs/sprava.md) |
| poznať sieť a pravidlá pre tajomstvá | [docs/bezpecnost.md](docs/bezpecnost.md) |
| vyriešiť chybu | [docs/riesenie-problemov.md](docs/riesenie-problemov.md) |

Add-in, `config.json` na počítačoch a tokeny opisuje repozitár `tia-sbom-utility`.

## Stav

Stack bol spustený izolovane vo vývojovej WSL (2026-11-12). Overené: `healthz` cez Caddy, zamknutý sprievodca, vyžadované prihlásenie, vytvorenie administrátora cez CLI. Neoverené: sieť na serveri cez `portproxy` 443, štart po reštarte bez prihlásenia, export add-inu cez HTTPS, záloha a obnova.

Do repozitára nikdy nepatrí `.env`, certifikát, kľúč, IP adresy ani mená strojov.
