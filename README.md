# BlackArch Toolset

BlackArch ve Arch Linux için seçilmiş güvenlik araçlarını öğrenmek, kurmak ve kullanmak amacıyla hazırlanmış Türkçe bir komut referansıdır.

## 📦 İçerik

| Dosya | Açıklama |
|---|---|
| `HACKKOMUT.txt` | Araçların kullanım komutları, örnekleri ve önemli notları |
| `HACKTOOLS.txt` | Araçların kısa açıklamaları ve kategorileri |
| `blackarch.txt` | Kurulumda kullanılacak paket listesi |
| `install.sh` | Araç setini otomatik olarak kuran kurulum betiği |
| `uninstall.sh` | Paketleri ve BlackArch repository yapılandırmasını ayrı ayrı kaldıran betik |
| `check.sh` | Repository dosyalarını ve temel tutarlılığı kontrol eden kalite betiği |
| `LICENSE` | MIT lisansı |

## 🚀 Kurulum

Proje Arch Linux / BlackArch tabanlı sistemler için hazırlanmıştır.

### 1. Repoyu klonla

```bash
git clone https://github.com/Praxis1071/blackarch-toolset.git
cd blackarch-toolset
```

### 2. Araçları kur

```bash
chmod +x install.sh uninstall.sh check.sh
sudo ./install.sh
```

`install.sh` şunları yapar:

- `pacman` ve gerekli yardımcı komutları kontrol eder.
- BlackArch deposunun sistemde bulunup bulunmadığını kontrol eder.
- BlackArch deposu yoksa resmi `strap.sh` betiğini doğrulayarak kurulumu başlatır ve senden onay ister.
- Paket listesindeki araçları `pacman` ile kurar.
- Zaten kurulu paketleri gereksiz yere yeniden kurmaz.

> **Not:** BlackArch deposu eklenmeden önce sistemdeki mevcut paket ve depo yapılandırmalarını kontrol et.

## 🧹 Kaldırma

Kurulan toolset'i geri kaldırmak için:

```bash
chmod +x uninstall.sh
sudo ./uninstall.sh
```

Script iki işlemi **ayrı ayrı sorar**:

1. Toolset paketlerinin tamamını kaldırmak.
2. BlackArch repository yapılandırmasını kaldırmak.

Her iki sorunun varsayılan cevabı **Hayır**'dır. Repository kaldırılmadan önce `/etc/pacman.conf` için zaman damgalı bir yedek oluşturulur.

> **Uyarı:** Paket kaldırma seçeneği `pacman -Rns` kullanır; artık gerekmeyen bağımlılıkları da kaldırabilir. İşlemden önce gösterilen paket listesini kontrol et.

## 🔎 Kalite kontrolü

Repository'nin temel bütünlüğünü kontrol etmek için:

```bash
chmod +x check.sh
./check.sh
```

Kontrol; dosyaların varlığını, paket sayısını, script syntax'ını, HACKKOMUT bölüm sayısını ve README referanslarını doğrular.
## 🛠️ Nasıl kullanılır?

Bir aracı öğrenmek için önerilen sıra:

1. **`HACKTOOLS.txt`** dosyasından aracın ne işe yaradığını öğren.
2. **`HACKKOMUT.txt`** dosyasında aracın kullanım örneklerine bak.
3. Aracın kendi yardım ekranını kontrol et:
   ```bash
   arac --help
   ```
4. Önce kendi sisteminde veya izole bir laboratuvarda güvenli bir test yap.

Örneğin Nmap için:

```bash
nmap --help
```

Komut seçenekleri araç sürümüne göre değişebileceği için, kurulu sürümün yardım çıktısı her zaman önceliklidir.

## 🔎 Araç kapsamı

Toolset; aşağıdaki alanlardan seçilmiş araçları içerir:

- 🌐 Ağ keşfi ve güvenliği
- 🕸️ Web uygulama güvenliği
- 🔍 OSINT ve reconnaissance
- 📡 Kablosuz ağ güvenliği
- 🧪 Fuzzing ve güvenlik testleri
- 🗂️ Metadata ve bilgi toplama
- 🔐 Kimlik doğrulama ve güvenlik denetimleri
- 🛠️ Yardımcı ve analiz araçları

Bu proje **tam BlackArch araç kataloğu değildir**. Amaç, seçilmiş araçları anlaşılır komut örnekleriyle tek bir yerde toplamaktır.

## 📚 Dosyaları nasıl kullanmalısın?

**Yeni başlıyorsan:**

`HACKTOOLS.txt` → aracın ne olduğunu öğren  
↓  
`HACKKOMUT.txt` → temel komutları incele  
↓  
`arac --help` → seçenekleri öğren  
↓  
Kendi laboratuvarında güvenli şekilde çalış

**Kurulum yapmak istiyorsan:**

`blackarch.txt` → kurulacak paketleri gör  
↓  
`install.sh` → otomatik kurulumu çalıştır

## 🔐 Yetkili kullanım

Bu projedeki bazı araçlar aktif tarama, trafik manipülasyonu, yük/stres testi, kablosuz saldırı simülasyonu veya kimlik doğrulama testleri yapabilir.

Araçları yalnızca:

- kendi sistemlerinde,
- kendi laboratuvarlarında,
- CTF ve eğitim ortamlarında,
- veya açıkça izin verilmiş sistemlerde

kullan.

Yetkisiz sistemleri veya ağları tarama, test etme ya da trafiğini değiştirme.

Örneklerde gerçek parola, API anahtarı, token, cookie veya başka gizli bilgiler kullanma.

## ⚠️ Güncellik

BlackArch paketleri ve upstream projeler zaman içinde değişebilir. Bu nedenle bir komut beklediğin gibi çalışmazsa önce:

```bash
arac --help
```

çıktısını kontrol et.

Ayrıca aracın güncel upstream belgelerine bakmak, sürüme bağlı CLI değişikliklerini tespit etmenin en güvenilir yoludur.

## 📄 Lisans

Bu proje MIT License ile lisanslanmıştır. Ayrıntılar için `LICENSE` dosyasına bak.
