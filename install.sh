#!/usr/bin/env bash

# BlackArch Toolset Commands
# Mevcut blackarch.txt listesindeki paketleri kurar.
# BlackArch deposu yoksa kullanıcı onayıyla resmi strap.sh betiği üzerinden ekler.

set -euo pipefail

TOOLS=(
  aimap
  airgeddon
  amass
  arjun
  armitage
  arpon
  arpspoof-smikims
  arptools
  backfuzz
  bbot
  beef
  berate_ap
  blackarch-mirrorlist
  burpsuite
  caido-desktop
  cariddi
  chiron
  clairvoyance
  cmseek
  cloudflared
  commix
  corsy
  credsniper
  crunch
  crypthook
  cupp
  dalfox
  ddosify
  dontgo403
  exiflooter
  feroxbuster
  ffuf
  gau
  gloom
  gophish
  h8mail
  hakrawler
  holehe
  httpx
  hyde
  infoga
  interactsh-client
  katana-pd
  kickthemout
  linkfinder
  maigret
  maketh
  mdbtools
  mdk3
  metasploit
  mitm
  monocle
  netdiscover
  nexfil
  ngrok
  nikto
  nomore403
  nmap
  nuclei
  nuclei-templates
  omnibus
  phoneinfoga
  photon
  pyinstaller
  pyinstaller-hooks-contrib
  python-shodan
  responder
  roguehostapd
  secretfinder
  secure-delete
  seeker
  set
  sherlock
  shodan
  social-mapper
  socialscan
  sooty
  sparrow-wifi
  spiderfoot
  spooftooph
  subfinder
  theharvester
  torctl
  trape
  websploit
  wifijammer
  wifiphisher
)
if [[ $EUID -ne 0 ]]; then
  echo "Hata: Bu script pacman ve depo yapılandırması için root yetkisi gerektirir."
  echo "Şununla çalıştır: sudo ./install.sh"
  exit 1
fi

if ! command -v pacman >/dev/null 2>&1; then
  echo "Hata: pacman bulunamadı. Bu script Arch Linux + BlackArch repository için hazırlanmıştır."
  exit 1
fi

for komut in curl sha1sum awk; do
  if ! command -v "$komut" >/dev/null 2>&1; then
    echo "Hata: Gerekli komut bulunamadı: $komut"
    echo "Eksik bağımlılığı kurduktan sonra scripti tekrar çalıştır."
    exit 1
  fi
done

blackarch_repo_var_mi() {
  if command -v pacman-conf >/dev/null 2>&1; then
    pacman-conf --repo-list 2>/dev/null | grep -Fxq "blackarch"
    return
  fi

  grep -Eq '^[[:space:]]*\[blackarch\][[:space:]]*$' /etc/pacman.conf
}

blackarch_repo_ekle() {
  local temp_dir strap_file expected_sha1 actual_sha1

  temp_dir="$(mktemp -d)"
  trap 'rm -rf "$temp_dir"' RETURN

  strap_file="$temp_dir/strap.sh"

  echo "BlackArch deposu bulunamadı."
  echo "Resmi BlackArch strap.sh betiği indirilecek ve depo yapılandırılacaktır."
  echo
  read -r -p "BlackArch deposunu eklemek istiyor musunuz? [E/h]: " cevap

  case "$cevap" in
    ""|E|e|Y|y)
      ;;
    *)
      echo "İşlem kullanıcı tarafından iptal edildi."
      exit 0
      ;;
  esac

  echo
  echo "Resmi BlackArch strap.sh indiriliyor..."
  curl -fsSL "https://blackarch.org/strap.sh" -o "$strap_file"

  expected_sha1="d338a4bb95d9e09f97508da68ac9e17d963b85f"
  actual_sha1="$(sha1sum "$strap_file" | awk '{print $1}')"

  if [[ "$actual_sha1" != "$expected_sha1" ]]; then
    echo "Hata: İndirilen strap.sh doğrulaması başarısız."
    echo "Beklenen SHA1: $expected_sha1"
    echo "Bulunan SHA1:  $actual_sha1"
    exit 1
  fi

  chmod +x "$strap_file"

  echo "strap.sh doğrulandı. BlackArch deposu yapılandırılıyor..."
  "$strap_file"

  echo
  echo "BlackArch deposu yapılandırması doğrulanıyor..."
  if ! blackarch_repo_var_mi; then
    echo "Hata: BlackArch deposu yapılandırılamadı."
    exit 1
  fi

  echo "BlackArch deposu başarıyla eklendi."
  echo "Paket veritabanları senkronize ediliyor..."
  pacman -Syyu
}

echo "BlackArch toolset kurulumu başlıyor..."
echo "Toplam paket: ${#TOOLS[@]}"
echo

if blackarch_repo_var_mi; then
  echo "BlackArch deposu zaten yapılandırılmış. Depo kurulumu atlanıyor."
else
  blackarch_repo_ekle
fi

echo
echo "Araçlar kuruluyor..."
pacman -S --needed "${TOOLS[@]}"

echo
echo "Kurulum tamamlandı."
