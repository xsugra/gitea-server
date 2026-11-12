# gitea-server

Gitea pre TIA SBOM Utility vo firemnej sieti: Caddy (HTTPS 443) → Gitea → PostgreSQL, Docker Engine vo WSL na Windows serveri.

| Súbor | Účel |
|---|---|
| `docker-compose.yml` | Stack. Von ide iba 80 (presmerovanie) a 443 cez Caddy |
| `Caddyfile` | HTTPS pre `GITEA_DOMAIN`, zatiaľ `tls internal`, neskôr certifikát firemnej CA |
| `.env.example` | Šablóna. Skutočný `.env` vytvorí `setup.sh` |
| `setup.sh` | Skopíruje súbory do `~/docker/gitea`, vygeneruje `.env` s náhodnými heslami, overí konfiguráciu |

Použitie vo WSL na serveri:

```bash
bash setup.sh gitea.firma.internal
cd ~/docker/gitea && docker compose up -d
```

Celý postup vrátane siete na Windows, certifikátu a štartu so systémom je v repozitári `tia-sbom-utility`, `docs/04-produkcia.md`.

Do repozitára nikdy nepatrí `.env`, certifikát, kľúč, IP adresy ani mená strojov.
