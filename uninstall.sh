#!/usr/bin/env bash
set -uo pipefail

STATE_DIR="/var/lib/blackarch-toolset"
STATE_FILE="$STATE_DIR/installed-by-toolset"
TMP_FILE=""
BACKUP_FILE=""

cleanup() {
  [[ -z "$TMP_FILE" || ! -e "$TMP_FILE" ]] || rm -f -- "$TMP_FILE"
}
trap cleanup EXIT

if [[ $EUID -ne 0 ]]; then
  echo 'Hata: root yetkisi gerekli. sudo ./uninstall.sh'
  exit 1
fi
if ! command -v pacman >/dev/null 2>&1; then
  echo 'Hata: pacman bulunamadı.'
  exit 1
fi

echo '=== BlackArch Toolset Kaldırma ==='
echo 'Paketler ve BlackArch repository ayrı ayrı sorulacaktır.'
echo 'Güvenlik: yalnızca install.sh tarafından yeni kurulduğu kaydedilen paketler kaldırılabilir.'
echo

read -r -p 'Toolset tarafından yeni kurulduğu kaydedilen paketleri kaldır? [e/H]: ' answer || answer="H"
if [[ "${answer:-H}" =~ ^[EeYy]$ ]]; then
  if [[ ! -f "$STATE_FILE" ]]; then
    echo 'Paket kaldırma atlandı: kurulum durum kaydı bulunamadı.'
    echo "Bu kayıt olmadan paketleri topluca kaldırmak, önceden kurulu paketleri silebileceğinden güvenli değil."
  else
    installed=()
    while IFS= read -r tool; do
      [[ -n "$tool" ]] || continue
      # Durum dosyası bozulmuşsa keyfi paket adlarını pacman'a geçirme.
      if [[ "$tool" =~ ^[a-zA-Z0-9@._+-]+$ ]] && pacman -Qq "$tool" >/dev/null 2>&1; then
        installed+=("$tool")
      fi
    done < "$STATE_FILE"

    if (("${#installed[@]}" == 0)); then
      echo 'Kayıtlı ve halen kurulu kaldırılabilir paket bulunamadı.'
    else
      printf 'Kaldırılacak paket sayısı: %s\n' "${#installed[@]}"
      printf '  - %s\n' "${installed[@]}"
      echo 'UYARI: pacman -Rns artık gerekmeyen bağımlılıkları da kaldırabilir.'
      read -r -p 'Gerçekten kaldır? [e/H]: ' confirm || confirm="H"
      if [[ "${confirm:-H}" =~ ^[EeYy]$ ]]; then
        if pacman -Rns -- "${installed[@]}"; then
          # Kayıt yalnızca başarıyla kaldırılan paketlerden arındırılır.
          remaining=()
          while IFS= read -r tool; do
            [[ -n "$tool" ]] || continue
            pacman -Qq "$tool" >/dev/null 2>&1 && remaining+=("$tool")
          done < "$STATE_FILE"
          state_tmp="$(mktemp "$STATE_DIR/.installed-by-toolset.XXXXXX")" || {
            echo 'Uyarı: paketler kaldırıldı ancak durum kaydı güncellenemedi.'
            state_tmp=""
          }
          if [[ -n "$state_tmp" ]]; then
            if (("${#remaining[@]}" > 0)); then printf '%s\n' "${remaining[@]}" > "$state_tmp"; fi
            chmod 600 "$state_tmp"
            mv -f -- "$state_tmp" "$STATE_FILE"
          fi
          echo 'Paket kaldırma komutu başarıyla tamamlandı.'
        else
          echo 'Hata: paket kaldırma başarısız oldu. Repository kaldırma seçeneği yine de sunulacak.'
        fi
      else
        echo 'Paket kaldırma iptal edildi.'
      fi
    fi
  fi
else
  echo 'Paket kaldırma atlandı.'
fi

echo
read -r -p 'BlackArch repository yapılandırmasını /etc/pacman.conf dosyasından kaldır? [e/H]: ' repo_answer || repo_answer="H"
if [[ "${repo_answer:-H}" =~ ^[EeYy]$ ]]; then
  if [[ ! -f /etc/pacman.conf ]]; then
    echo 'Hata: /etc/pacman.conf bulunamadı; repository yapılandırması değiştirilmedi.'
    exit 1
  fi

  BACKUP_FILE="$(mktemp /etc/pacman.conf.blackarch-toolset-backup.XXXXXX)" || {
    echo 'Hata: yedek dosyası oluşturulamadı.'
    exit 1
  }
  if ! cp -a -- /etc/pacman.conf "$BACKUP_FILE"; then
    rm -f -- "$BACKUP_FILE"
    BACKUP_FILE=""
    echo 'Hata: /etc/pacman.conf yedeklenemedi; yapılandırma değiştirilmedi.'
    exit 1
  fi

  TMP_FILE="$(mktemp /etc/.pacman.conf.blackarch-toolset.XXXXXX)" || {
    echo "Hata: geçici dosya oluşturulamadı. Yedek: $BACKUP_FILE"
    exit 1
  }
  if ! awk 'BEGIN{skip=0} /^[[:space:]]*\[blackarch\][[:space:]]*$/{skip=1;next} skip && /^[[:space:]]*\[/{skip=0} skip{next} {print}' /etc/pacman.conf > "$TMP_FILE"; then
    echo "Hata: pacman.conf işlenemedi. Orijinal dosya korunmuştur. Yedek: $BACKUP_FILE"
    exit 1
  fi

  if grep -Eq '^[[:space:]]*\[blackarch\][[:space:]]*$' "$TMP_FILE"; then
    echo "Hata: BlackArch bölümü hâlâ mevcut; yapılandırma değiştirilmedi. Yedek: $BACKUP_FILE"
    exit 1
  fi

  # Orijinal sahiplik ve izinleri koru, ardından aynı dosya sisteminde atomik değiştir.
  if ! chmod --reference=/etc/pacman.conf "$TMP_FILE" ||
     ! chown --reference=/etc/pacman.conf "$TMP_FILE" ||
     ! mv -f -- "$TMP_FILE" /etc/pacman.conf; then
    echo "Hata: yeni pacman.conf yerleştirilemedi. Yedeği korundu: $BACKUP_FILE"
    exit 1
  fi
  TMP_FILE=""

  echo 'BlackArch repository bölümü kaldırıldı.'
  echo "Pacman yedeği: $BACKUP_FILE"
  echo 'Not: Bu işlem yalnızca /etc/pacman.conf içindeki [blackarch] bölümünü kaldırır; keyring paketini veya başka dosyalardaki ayarları kaldırmaz.'
  echo 'Gerekirse: sudo pacman -Syy'
else
  echo 'BlackArch repository kaldırma atlandı.'
fi

echo 'Kaldırma işlemi tamamlandı.'
