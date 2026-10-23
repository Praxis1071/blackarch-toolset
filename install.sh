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

for komut in curl sha1sum awk grep; do
  if ! command -v "$komut" >/dev/null 2>&1; then
    echo "Hata: Gerekli komut bulunamadı: $komut"
    echo "Eksik bağımlılığı kurduktan sonra scripti tekrar çalıştır."
    exit 1
  fi
done

blackarch_repo_var_mi() {
  if command -v pacman-conf >/dev/null 2>&1; then
    pacman-conf --repo-list 2>/dev/null | grep -Fx "blackarch" >/dev/null
    return
  fi

  grep -Eq '^[[:space:]]*\[blackarch\][[:space:]]*$' /etc/pacman.conf
}

TEMP_DIR=""
trap 'if [[ -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" ]]; then rm -rf -- "$TEMP_DIR"; fi' EXIT

blackarch_repo_ekle() {
  local strap_file expected_sha1 actual_sha1 strap_status

  TEMP_DIR="$(mktemp -d)"
  strap_file="$TEMP_DIR/strap.sh"

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
  echo "Bu aşamada resmi betik anahtarları ve depo ayarlarını hazırlar."
  if "$strap_file"; then
    strap_status=0
  else
    strap_status=$?
    echo "Uyarı: strap.sh çıkış kodu $strap_status ile sonlandı."
  fi

  echo
  echo "BlackArch depo yapılandırması doğrulanıyor..."
  if ! blackarch_repo_var_mi; then
    echo "Hata: strap.sh sonrasında BlackArch deposu etkin görünmüyor."
    echo "Kurulum güvenlik nedeniyle durduruldu; yukarıdaki strap.sh hata mesajlarını kontrol et."
    exit 1
  fi

  if (( strap_status != 0 )); then
    if ! pacman -Q blackarch-keyring >/dev/null 2>&1; then
      echo "Hata: strap.sh başarısız oldu ve blackarch-keyring kurulu görünmüyor."
      echo "Paket kurulumuna geçilmeyecek. Yukarıdaki hata mesajlarını düzeltip tekrar dene."
      exit 1
    fi
    echo "Uyarı: strap.sh sıfırdan farklı kod döndürdü ancak depo ve blackarch-keyring mevcut."
    echo "İşleme devam ediliyor; pacman sonraki adımlarda eksik veya bozuk paket durumunu gösterebilir."
  fi

  echo "BlackArch deposu yapılandırıldı."
  return 0
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
echo "Paket veritabanları senkronize ediliyor ve sistem güncelleniyor..."
if ! pacman -Syyu; then
  echo "Hata: pacman -Syyu başarısız oldu veya iptal edildi."
  echo "Araçlar kurulmadı. Ağ, anahtar/imza ve paket çakışması mesajlarını kontrol et; ardından scripti tekrar çalıştır."
  exit 1
fi

echo
echo "Araçlar kuruluyor..."
if ! pacman -S --needed "${TOOLS[@]}"; then
  echo "Hata: Araç paketlerinin kurulumu tamamlanamadı."
  echo "Pacman çıktısında bulunamayan paketleri, imza hatalarını veya çakışmaları kontrol et."
  exit 1
fi

echo
echo "Kurulum tamamlandı."
