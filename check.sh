#!/usr/bin/env bash
set -u
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"
failed=0
ok(){ printf '[✓] %s\n' "$1"; }
fail(){ printf '[✗] %s\n' "$1"; failed=1; }
for file in README.md LICENSE HACKTOOLS.txt HACKKOMUT.txt blackarch.txt install.sh uninstall.sh; do [[ -s "$file" ]] && ok "$file mevcut" || fail "$file eksik veya boş"; done
count="$(grep -Ec '^\[[0-9]{2}\] ' blackarch.txt 2>/dev/null || true)"; [[ "$count" == 87 ]] && ok 'blackarch.txt: 87 paket' || fail "blackarch.txt: beklenen 87, bulunan $count"
bash -n install.sh && ok 'install.sh syntax OK' || fail 'install.sh syntax hatası'
bash -n uninstall.sh && ok 'uninstall.sh syntax OK' || fail 'uninstall.sh syntax hatası'
sections="$(grep -Ec '^[0-9]{2}\. ' HACKKOMUT.txt 2>/dev/null || true)"; [[ "$sections" == 84 ]] && ok 'HACKKOMUT.txt: 84 bölüm' || fail "HACKKOMUT.txt: beklenen 84, bulunan $sections"
fences="$(grep -c '^```' HACKKOMUT.txt 2>/dev/null || true)"; (( fences % 2 == 0 )) && ok 'HACKKOMUT.txt: code fence dengesi OK' || fail 'HACKKOMUT.txt: code fence dengesi bozuk'
tools="$(grep -Ec '^\* [[:alnum:]][^ ]*' HACKTOOLS.txt 2>/dev/null || true)"; [[ "$tools" == 87 ]] && ok 'HACKTOOLS.txt: 87 araç' || fail "HACKTOOLS.txt: beklenen 87, bulunan $tools"
for ref in HACKKOMUT.txt HACKTOOLS.txt blackarch.txt install.sh uninstall.sh LICENSE; do grep -Fq "$ref" README.md && ok "README: $ref" || fail "README: $ref eksik"; done
echo
if (( failed == 0 )); then echo 'Repository check: PASSED'; exit 0; else echo 'Repository check: FAILED'; exit 1; fi