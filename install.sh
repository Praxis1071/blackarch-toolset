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

for komut in curl sha1sum awk grep sort wc; do
  if ! command -v "$komut" >/dev/null 2>&1; then
    echo "Hata: Gerekli komut bulunamadı: $komut"
    echo "Eksik bağımlılığı kurduktan sonra scripti tekrar çalıştır."
    exit 1
  fi
done

# Dönüş kodları: 0 = depo var, 1 = depo yok, 2 = yapılandırma okunamadı.
blackarch_repo_var_mi() {
  local repo_list status

  if command -v pacman-conf >/dev/null 2>&1; then
    if ! repo_list="$(pacman-conf --repo-list 2>/dev/null)"; then
      echo "Hata: pacman-conf depo yapılandırmasını okuyamadı; güvenli biçimde duruluyor." >&2
      return 2
    fi

    if printf '%s\n' "$repo_list" | grep -Fxq "blackarch"; then
      return 0
    fi
    return 1
  fi

  if [[ ! -r /etc/pacman.conf ]]; then
    echo "Hata: pacman-conf yok ve /etc/pacman.conf okunamıyor." >&2
    return 2
  fi

  if grep -Eq '^[[:space:]]*\[blackarch\][[:space:]]*$' /etc/pacman.conf; then
    return 0
  else
    status=$?
    if (( status == 1 )); then
      return 1
    fi
    echo "Hata: /etc/pacman.conf kontrol edilemedi." >&2
    return 2
  fi
}

TEMP_DIR=""
trap 'if [[ -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" ]]; then rm -rf -- "$TEMP_DIR"; fi' EXIT

blackarch_repo_ekle() {
  local strap_file expected_sha1 actual_sha1 strap_status repo_check_status

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

  if (( strap_status != 0 )); then
    echo "Hata: strap.sh sıfırdan farklı kodla sonlandı; araç paketlerinin kurulumu durduruluyor."
    echo "Resmî strap.sh paket veritabanını pacman -Syy ile yenilemiş olabilir."
    echo "Daha önce verdiğin tam sistem güncellemesi onayı kapsamında,"
    echo "kısmi yükseltme durumunu bırakmamak için pacman -Syu deneniyor..."
    if ! pacman -Syu; then
      echo "KRİTİK UYARI: pacman -Syu tamamlanamadı."
      echo "Başka paket işlemi yapmadan önce hatayı çöz ve pacman -Syu komutunu başarıyla tamamla."
    fi
    echo "strap.sh başarısız olduğu için toolset paketleri kurulmayacak."
    echo "Yukarıdaki hata mesajlarını düzelt; depo/keyring durumunu kontrol etmeden tekrar deneme."
    exit 1
  fi

  echo
  echo "BlackArch depo yapılandırması doğrulanıyor..."
  if blackarch_repo_var_mi; then
    :
  else
    repo_check_status=$?
    if (( repo_check_status == 2 )); then
      echo "Hata: depo yapılandırmasının durumu doğrulanamadı; kurulum durduruldu."
    else
      echo "Hata: strap.sh sonrasında BlackArch deposu etkin görünmüyor."
    fi
    echo "Kurulum güvenlik nedeniyle durduruldu; yukarıdaki strap.sh hata mesajlarını kontrol et."
    exit 1
  fi

  echo "BlackArch deposu yapılandırıldı."
  return 0
}

STATE_DIR="/var/lib/blackarch-toolset"
STATE_FILE="$STATE_DIR/installed-by-toolset"
BASELINE_FILE=""
STATE_TMP=""
cleanup() {
  [[ -z "${TEMP_DIR:-}" || ! -d "$TEMP_DIR" ]] || rm -rf -- "$TEMP_DIR"
  [[ -z "${BASELINE_FILE:-}" || ! -f "$BASELINE_FILE" ]] || rm -f -- "$BASELINE_FILE"
  [[ -z "${STATE_TMP:-}" || ! -f "$STATE_TMP" ]] || rm -f -- "$STATE_TMP"
}
trap cleanup EXIT

is_tool_package() {
  local candidate
  for candidate in "${TOOLS[@]}"; do
    [[ "$candidate" == "$1" ]] && return 0
  done
  return 1
}

record_new_packages() {
  local tool
  local -a newly_installed=()
  local -a previous_state=()
  for tool in "${TOOLS[@]}"; do
    if ! grep -Fxq -- "$tool" "$BASELINE_FILE" && pacman -Qq "$tool" >/dev/null 2>&1; then
      newly_installed+=("$tool")
    fi
  done
  if [[ -L "$STATE_FILE" || ( -e "$STATE_FILE" && ! -f "$STATE_FILE" ) ]]; then
    echo "Hata: durum kayıt dosyası normal bir dosya değil." >&2
    return 1
  fi
  if [[ -f "$STATE_FILE" ]]; then
    while IFS= read -r tool; do
      [[ -n "$tool" ]] || continue
      if ! is_tool_package "$tool"; then
        echo "Uyarı: durum kaydında toolset dışı/geçersiz paket adı atlandı: $tool" >&2
        continue
      fi
      pacman -Qq "$tool" >/dev/null 2>&1 && previous_state+=("$tool")
    done < "$STATE_FILE"
  fi
  if [[ -L "$STATE_DIR" ]] || ! mkdir -p -- "$STATE_DIR" ||
     [[ ! -d "$STATE_DIR" ]] || ! chown root:root "$STATE_DIR" || ! chmod 700 "$STATE_DIR"; then
    echo "Hata: durum kayıt dizini güvenli biçimde hazırlanamadı." >&2
    return 1
  fi
  STATE_TMP="$(mktemp "$STATE_DIR/.installed-by-toolset.XXXXXX")" || {
    echo "Hata: geçici durum kaydı oluşturulamadı." >&2
    return 1
  }
  if (("${#previous_state[@]}" > 0 || "${#newly_installed[@]}" > 0)); then
    if ! printf '%s\n' "${previous_state[@]}" "${newly_installed[@]}" | sort -u > "$STATE_TMP"; then
      echo "Hata: durum kaydı yazılamadı." >&2
      return 1
    fi
  fi
  if ! chmod 600 "$STATE_TMP" || ! mv -f -- "$STATE_TMP" "$STATE_FILE"; then
    echo "Hata: durum kaydı güvenli biçimde kaydedilemedi." >&2
    return 1
  fi
  STATE_TMP=""
  echo "Toolset tarafından yeni kurulduğu kaydedilen paket sayısı: $(wc -l < "$STATE_FILE")"
}

echo "BlackArch toolset kurulumu başlıyor..."
echo "Toplam paket: ${#TOOLS[@]}"
echo
# Paketleri kurmadan önce durum kaydı için alanın yazılabilir olduğunu doğrula.
# Sembolik bağlantı üzerinden başka bir konuma yazılmasını önle.
if [[ -L "$STATE_DIR" ]]; then
  echo "Hata: durum kayıt dizini sembolik bağlantı; paket işlemleri başlatılmadı." >&2
  exit 1
fi
if ! mkdir -p -- "$STATE_DIR" || [[ ! -d "$STATE_DIR" ]] ||
   ! chown root:root "$STATE_DIR" || ! chmod 700 "$STATE_DIR"; then
  echo "Hata: durum kayıt dizini güvenli biçimde hazırlanamadı; paket güncellemesi başlatılmadı." >&2
  exit 1
fi
if [[ -L "$STATE_FILE" || ( -e "$STATE_FILE" && ! -f "$STATE_FILE" ) ]]; then
  echo "Hata: durum kayıt dosyası normal bir dosya değil; paket işlemleri başlatılmadı." >&2
  exit 1
fi
if [[ -f "$STATE_FILE" ]] &&
   { ! chown root:root "$STATE_FILE" || ! chmod 600 "$STATE_FILE"; }; then
  echo "Hata: durum kayıt dosyası güvenli izinlerle hazırlanamadı; paket işlemleri başlatılmadı." >&2
  exit 1
fi
preflight_tmp="$(mktemp "$STATE_DIR/.preflight.XXXXXX")" || {
  echo "Hata: durum kayıt dizinine yazılamıyor; paket kurulumu başlatılmadı." >&2
  exit 1
}
STATE_TMP="$preflight_tmp"
if ! rm -f -- "$preflight_tmp"; then
  echo "Hata: durum kayıt alanı kontrolü sonrası geçici dosya temizlenemedi." >&2
  exit 1
fi
STATE_TMP=""


# Önce tüm sistem güncellemesi için onay al. Resmî strap.sh, bu onaydan
# sonra keyring/depo işlemleri yapar ve kendi içinde ayrıca pacman -Su sorabilir.
# Kullanıcı bu betikte bir kez onay verdiyse strap.sh bu soruyu reddetse bile
# aşağıdaki pacman -Syu çalışır; böylece kurulum yarıda "onay verilmedi" diye
# bırakılıp güncel olmayan depo veritabanıyla devam edilmez.
echo
echo "ÖNEMLİ: Arch Linux'ta kısmi yükseltme desteklenmez."
echo "pacman -Syu, toolset dışındaki sistem paketlerini de güncelleyebilir."
echo "BlackArch deposu eksikse, resmî strap.sh bu onaydan sonra çalıştırılacaktır."
read -r -p "Depo kurulumu gerekiyorsa bunu ve ardından tüm sistemin güncellenmesini onaylıyor musunuz? [e/H]: " update_answer
if [[ ! "${update_answer:-H}" =~ ^[EeYy]$ ]]; then
  echo "Onay verilmedi; depo kurulumu ve paket işlemleri başlatılmadı."
  exit 1
fi

if blackarch_repo_var_mi; then
  echo "BlackArch deposu zaten yapılandırılmış. Depo kurulumu atlanıyor."
else
  repo_check_status=$?
  if (( repo_check_status == 2 )); then
    echo "Hata: BlackArch deposunun durumu güvenilir biçimde belirlenemedi; strap.sh çalıştırılmayacak."
    exit 1
  fi
  blackarch_repo_ekle
fi

echo "Paket veritabanları senkronize ediliyor ve sistem güncelleniyor..."
if ! pacman -Syu; then
  echo "Hata: pacman -Syu başarısız oldu veya iptal edildi."
  echo "Araçlar kurulmadı. Ağ, anahtar/imza ve paket çakışması mesajlarını kontrol et; ardından scripti tekrar çalıştır."
  exit 1
fi

# Paket kurulumundan hemen önceki envanter, yalnızca bu toolset işleminin eklediklerini belirlemek için kullanılır.
BASELINE_FILE="$(mktemp)"
for tool in "${TOOLS[@]}"; do
  if pacman -Qq "$tool" >/dev/null 2>&1; then
    printf '%s\n' "$tool" >> "$BASELINE_FILE"
  fi
done

echo "Araçlar kuruluyor..."
if pacman -S --needed "${TOOLS[@]}"; then
  install_status=0
else
  install_status=$?
  echo "Uyarı: paket kurulumu başarısız oldu; kısmen kurulmuş yeni paketler kaydedilecek."
fi

if ! record_new_packages; then
  echo "Hata: kurulum durumu kaydedilemedi. Paketleri otomatik kaldırmadan önce pacman -Q ile kontrol et."
  exit 1
fi
if (( install_status != 0 )); then
  echo "Hata: Araç paketlerinin kurulumu tamamlanamadı."
  echo "Pacman çıktısında bulunamayan paketleri, imza hatalarını veya çakışmaları kontrol et."
  exit "$install_status"
fi

echo "Kurulum tamamlandı."
echo "Uninstall scripti yalnızca bu kayıt dosyasındaki paketleri kaldırmayı önerecek."
