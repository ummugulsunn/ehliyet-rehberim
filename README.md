# 🚗 Ehliyet Rehberim

Türkiye'de ehliyet sınavına hazırlananlar için geliştirilmiş modern ve kullanıcı dostu bir Flutter uygulaması.

## ✨ Özellikler

### 📚 Kapsamlı Soru Bankası
- **100 soru** ile tam kapsamlı hazırlık
- **5 kategori** ile organize edilmiş içerik:
  - 🚑 İlk Yardım
  - 🔧 Motor ve Araç Tekniği
  - 🤝 Trafik Adabı
  - 🛑 Trafik İşaretleri
  - 🌍 Trafik ve Çevre Bilgisi

### 🎯 Akıllı Öğrenme Sistemi
- **Konu bazlı çalışma** - İstediğin konuyu seç ve çalış
- **Sınav modu** - Gerçek sınav deneyimi
- **Detaylı açıklamalar** - Her soru için kapsamlı açıklama
- **Skor takibi** - İlerlemeni takip et

### 💎 Premium Özellikler
- **Pro abonelik** - Tüm özelliklere sınırsız erişim
- **Konu seçimi** - PRO kullanıcılar için
- **Tam soru bankası** - 100 soruya erişim
- **Reklamsız deneyim** - Kesintisiz çalışma

## 🚀 Kurulum

### Gereksinimler
- Flutter 3.29.3 veya üzeri
- Dart 3.7.0 veya üzeri
- Android Studio / VS Code
- Android SDK (API 21+)

### Adımlar

1. **Projeyi klonlayın**
```bash
git clone https://github.com/yourusername/ehliyet-rehberim.git
cd ehliyet-rehberim
```

2. **Bağımlılıkları yükleyin**
```bash
flutter pub get
```

3. **Uygulamayı çalıştırın**
```bash
flutter run
```

## 📱 Ekran Görüntüleri

### Ana Sayfa
- Modern Material Design 3 arayüzü
- Kolay navigasyon
- Pro özellikler için özel butonlar

### Konu Seçimi
- Kategorilere göre organize edilmiş sorular
- Her kategori için soru sayısı gösterimi
- Görsel ikonlar ile kolay tanımlama

### Sınav Ekranı
- Temiz ve okunabilir arayüz
- İlerleme göstergesi
- Anında geri bildirim

## 🏗️ Proje Yapısı

```
lib/
├── src/
│   ├── core/
│   │   ├── models/
│   │   │   └── question_model.dart
│   │   └── services/
│   │       ├── quiz_service.dart
│   │       └── purchase_service.dart
│   ├── features/
│   │   ├── home/
│   │   │   └── presentation/
│   │   │       └── home_screen.dart
│   │   ├── quiz/
│   │   │   ├── application/
│   │   │   │   ├── quiz_providers.dart
│   │   │   │   └── quiz_state.dart
│   │   │   └── presentation/
│   │   │       └── quiz_screen.dart
│   │   └── topics/
│   │       └── presentation/
│   │           └── topic_selection_screen.dart
│   └── main.dart
├── assets/
│   └── data/
│       └── questions.json
└── test/
    └── features/
        └── quiz/
            └── application/
                └── quiz_providers_test.dart
```

## 🧪 Test

```bash
# Tüm testleri çalıştır
flutter test

# Belirli bir test dosyasını çalıştır
flutter test test/features/quiz/application/quiz_providers_test.dart
```

## 📦 Build

### Android APK
```bash
# Release build
flutter build apk

# Split APK (farklı CPU mimarileri için)
flutter build apk --release --split-per-abi
```

### iOS
```bash
# iOS build
flutter build ios
```

## 🔧 Konfigürasyon

### RevenueCat Entegrasyonu
Pro özellikler için RevenueCat API key'lerini ekleyin:

1. `lib/src/core/services/purchase_service.dart` dosyasını açın
2. API key'leri güncelleyin:
```dart
static const String _appleApiKey = 'your_apple_api_key';
static const String _googleApiKey = 'your_google_api_key';
```

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için `LICENSE` dosyasına bakın.

## 📞 İletişim

- **Geliştirici**: [Your Name]
- **Email**: [your.email@example.com]
- **GitHub**: [@yourusername]

## 🙏 Teşekkürler

- Flutter ekibine harika framework için
- Material Design ekibine güzel tasarım sistemi için
- Tüm katkıda bulunanlara

---

⭐ Bu projeyi beğendiyseniz yıldız vermeyi unutmayın!
