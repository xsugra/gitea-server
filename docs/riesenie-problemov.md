# Riešenie problémov

| Príznak | Príčina | Riešenie |
|---|---|---|
| `setup.sh`: `$'\r': command not found` | Súbory majú CRLF z Windows | `find ~/tiasbom-server -type f -exec sed -i 's/\r$//' {} +` |
| `setup.sh`: `nie je plné DNS meno` | Stroj nie je v doméne, chýba DNS prípona | Zadať meno ako argument |
| `setup.sh`: `používateľ nie je v skupine docker` | Skupina ešte neplatí | Na Windows `wsl --terminate Ubuntu-26.04`, znovu otvoriť WSL |
| Iný počítač nevidí 443 | `portproxy` na starej IP, `iphlpsvc` nebeží, sieť nie je v profile Domain, WSL nebeží | [nasadenie.md, krok 5](nasadenie.md#5-sieť-na-windows) |
| Nič nebeží po reštarte servera | Úloha `Gitea WSL` nezbehla | Plánovač úloh, história úlohy, [krok 7](nasadenie.md#7-štart-so-systémom) |
| Add-in alebo prehliadač hlási chybu certifikátu | Počítač nedôveruje `tls internal`, alebo certifikát nie je pre presné meno | [nasadenie.md, krok 6](nasadenie.md#6-certifikát-počas-pilotu) |
| Prihlásenie na web nič neurobí | Adresa sa líši od `GITEA_DOMAIN`, cookie je Secure | Otvárať presne `https://<GITEA_DOMAIN>` |
| `Only signed in user is allowed to call APIs` | `REQUIRE_SIGNIN_VIEW=true`, volanie bez tokenu | Na test použiť `/api/healthz` |
| Kontajner nebeží | Chyba v `.env` alebo certifikáte | `docker compose ps`, `docker compose logs caddy gitea` |
