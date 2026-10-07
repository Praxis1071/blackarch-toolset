#!/usr/bin/env bash

# BlackArch Toolset Commands
# Installs only the packages listed in blackarch.txt.
# Intended for Arch Linux systems with the BlackArch repository configured.

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
  mitm
  monocle
  netdiscover
  nexfil
  ngrok
  nuclei
  nuclei-templates
  omnibus
  phoneinfoga
  photon
  pyinstaller
  pyinstaller-hooks-contrib
  python2-shodan
  responder
  roguehostapd
  secretfinder
  secure-delete
  seeker
  set
  sherlock
  social-mapper
  socialscan
  sooty
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
  echo "Hata: Bu script pacman için root yetkisi gerektirir."
  echo "Şununla çalıştır: sudo ./install.sh"
  exit 1
fi

if ! command -v pacman >/dev/null 2>&1; then
  echo "Hata: pacman bulunamadı. Bu script Arch Linux + BlackArch repository için hazırlanmıştır."
  exit 1
fi

echo "BlackArch toolset kurulumu başlıyor..."
echo "Toplam paket: ${#TOOLS[@]}"
echo

pacman -S --needed "${TOOLS[@]}"

echo
echo "Kurulum tamamlandı."
