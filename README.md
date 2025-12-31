# minik-rentacar – QBCore Araç Kiralama Sistemi

Bu resource, QBCore tabanlı sunucular için **araç kiralama sistemi** ekler.

## Özellikler

- ✅ 3 eski araç (Sentinel, Futo, Blista)
- ✅ Her oyuncu 30 dakika gerçek saat ile bekleme süresi
- ✅ Kiralama kontratı item'ı verilir
- ✅ **Araç anahtarı otomatik verilir** (qb-vehiclekeys, cd_garage, qb-vehicleshop desteği)
- ✅ QBCore ve yeni QB desteği
- ✅ qb-target entegrasyonu
- ✅ qb-menu veya qb-input desteği

## Gerekli Scriptler

- **Zorunlu**
  - `qb-core`
  - `qb-target`
- **Opsiyonel**
  - `qb-menu` (menü için, yoksa target'tan direkt seçim yapılır)
  - `qb-vehiclekeys` veya `cd_garage` veya `qb-vehicleshop` (araç anahtarı sistemi - otomatik algılanır)

## Kurulum

1. Resource klasörünü `minik-rentacar` olarak kaydedin
2. `server.cfg` veya `resources.cfg` dosyasına ekleyin:
   ```cfg
   ensure qb-core
   ensure qb-target
   ensure minik-rentacar
   ```

3. **Kiralama kontratı item'ını ekleyin:**
   
   `qb-core/shared/items.lua` dosyasına ekleyin:
   ```lua
   ['kiralama_kontrati'] = {
       ['name'] = 'kiralama_kontrati',
       ['label'] = 'Kiralama Kontratı',
       ['weight'] = 100,
       ['type'] = 'item',
       ['image'] = 'kiralama_kontrati.png',
       ['unique'] = false,
       ['useable'] = true,
       ['shouldClose'] = true,
       ['combinable'] = nil,
       ['description'] = 'Araç kiralama kontratı'
   },
   ```

4. Item görseli için `jpr-inventory/html/images/` klasörüne `kiralama_kontrati.png` ekleyin (opsiyonel)

## Konfigürasyon

`shared/config.lua` dosyasından ayarlayabilirsiniz:

- **Kiralama lokasyonu**: `Config.RentalLocation` (NPC ve spawn konumu)
- **Spawn koordinatı**: `Config.RentalLocation.SpawnCoords` (tüm araçlar aynı yere spawn olur)
- **Araçlar**: `Config.RentalVehicles` (model, fiyat)
- **Bekleme süresi**: `Config.CooldownTime` (dakika cinsinden)
- **Para türü**: `Config.MoneyType` ('cash', 'bank', 'crypto')

## Kullanım

1. Los Santos Airport civarındaki kiralama noktasına gidin
2. NPC ile etkileşime geçin (qb-target)
3. "Araç Kirala" seçeneğini seçin
4. İstediğiniz aracı seçin
5. Ödeme yapın ve araç spawn olur
6. Kiralama kontratı envanterinize eklenir
7. **Araç anahtarı otomatik olarak verilir** (araç sisteminize göre)

## Admin Komutları

- `/resetrental [id]` - Oyuncunun kiralama cooldown'unu sıfırla (admin yetkisi gerekir)

## Notlar

- Her oyuncu 30 dakika gerçek saat ile bekleme süresine tabidir
- **Tüm araçlar aynı konuma spawn olur** - Eğer spawn konumunda zaten bir araç varsa, yeni araç spawn olmaz ve "Spawn konumunda zaten bir araç var!" mesajı gösterilir
- Araçlar kiralık olarak spawn olur ve plakaları "RENTAL" ile başlar
- Kiralama kontratı item'ı envanterde saklanır ve kullanılabilir
- **Araç anahtarı otomatik verilir**: Sistem otomatik olarak `qb-vehiclekeys`, `cd_garage` veya `qb-vehicleshop` sistemlerini algılar ve uygun şekilde anahtar verir

