# BlackArch Toolset Commands

BlackArch ve Arch Linux için seçilmiş güvenlik araçları ve Türkçe komut referansı.

## İçerik

- `HACKKOMUT.txt` — Komutlar ve kullanım örnekleri
- `HACKTOOLS.txt` — Araç açıklamaları ve kategoriler
- `blackarch.txt` — Kurulacak paket listesi
- `install.sh` — Otomatik kurulum betiği
- `LICENSE` — MIT lisansı

## Kurulum

Arch Linux veya BlackArch üzerinde:

```bash
chmod +x install.sh
sudo ./install.sh
```

Betik BlackArch deposunu kontrol eder; gerekirse resmi BlackArch `strap.sh` betiğini doğrulayarak depoyu yapılandırır ve listedeki paketleri kurar.

## Kullanım

Önce `HACKTOOLS.txt` içinden aracı bul, ardından `HACKKOMUT.txt` içindeki örneklere bak.

Komutlar yalnızca kendi sistemlerinde veya açıkça yetkilendirildiğin test/lab ortamlarında kullanılmalıdır.

Örneklerde gerçek parola, API anahtarı, token veya başka gizli bilgiler kullanma.

## Not

BlackArch paketleri ve araçların komutları zamanla değişebilir. Gerekirse:

```bash
araç --help
```

Bu proje tam BlackArch kataloğu değildir; seçilmiş bir araç setidir.
