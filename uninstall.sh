#!/usr/bin/env bash
set -euo pipefail

TOOLS=( aimap airgeddon amass arjun armitage arpon arpspoof-smikims arptools backfuzz bbot beef berate_ap blackarch-mirrorlist burpsuite caido-desktop cariddi chiron clairvoyance cmseek cloudflared commix corsy credsniper crunch crypthook cupp dalfox ddosify dontgo403 exiflooter feroxbuster ffuf gau gloom gophish h8mail hakrawler holehe httpx hyde infoga interactsh-client katana-pd kickthemout linkfinder maigret maketh mdbtools mdk3 metasploit mitm monocle netdiscover nexfil ngrok nikto nomore403 nmap nuclei nuclei-templates omnibus phoneinfoga photon pyinstaller pyinstaller-hooks-contrib python-shodan responder roguehostapd secretfinder secure-delete seeker set sherlock shodan social-mapper socialscan sooty sparrow-wifi spiderfoot spooftooph subfinder theharvester torctl trape websploit wifijammer wifiphisher )
if [[ $EUID -ne 0 ]]; then echo 'Hata: root yetkisi gerekli. sudo ./uninstall.sh'; exit 1; fi
command -v pacman >/dev/null 2>&1 || { echo 'Hata: pacman bulunamadı.'; exit 1; }
echo '=== BlackArch Toolset Kaldırma ==='
echo 'Paketler ve BlackArch repository ayrı ayrı sorulacaktır.'
read -r -p 'Toolset paketlerinin tamamını kaldır? [e/H]: ' answer
answer="${answer:-H}"
if [[ "$answer" =~ ^[EeYy]$ ]]; then
  installed=()
  for tool in "${TOOLS[@]}"; do pacman -Qq "$tool" >/dev/null 2>&1 && installed+=("$tool"); done
  if ((${#installed[@]} == 0)); then
    echo 'Kaldırılacak kurulu toolset paketi bulunamadı.'
  else
    printf 'Kaldırılacak paket sayısı: %s\n' "${#installed[@]}"
    printf '  - %s\n' "${installed[@]}"
    echo 'UYARI: -Rns, artık gerekmeyen bağımlılıkları da kaldırabilir.'
    read -r -p 'Gerçekten kaldır? [e/H]: ' confirm
    if [[ "${confirm:-H}" =~ ^[EeYy]$ ]]; then pacman -Rns -- "${installed[@]}"; else echo 'Paket kaldırma iptal edildi.'; fi
  fi
else
  echo 'Paket kaldırma atlandı.'
fi
echo
read -r -p 'BlackArch repository yapılandırmasını kaldır? [e/H]: ' repo_answer
repo_answer="${repo_answer:-H}"
if [[ "$repo_answer" =~ ^[EeYy]$ ]]; then
  backup="/etc/pacman.conf.blackarch-toolset-backup.$(date +%Y%m%d-%H%M%S)"
  cp -a /etc/pacman.conf "$backup"
  tmp="$(mktemp)"
  awk 'BEGIN{skip=0} /^[[:space:]]*\[blackarch\][[:space:]]*$/{skip=1;next} skip && /^[[:space:]]*\[/{skip=0} skip{next} {print}' /etc/pacman.conf > "$tmp"
  if grep -Eq '^[[:space:]]*\[blackarch\][[:space:]]*$' "$tmp"; then rm -f "$tmp"; echo "Hata: repository bölümü kaldırılamadı. Yedek: $backup"; exit 1; fi
  install -m 644 "$tmp" /etc/pacman.conf
  rm -f "$tmp"
  echo 'BlackArch repository bölümü kaldırıldı.'
  echo "Pacman yedeği: $backup"
  echo 'Gerekirse: sudo pacman -Syy'
else
  echo 'BlackArch repository kaldırma atlandı.'
fi
echo 'Kaldırma işlemi tamamlandı.'