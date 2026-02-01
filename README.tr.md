# <img src="assets/images/app_logo.png" alt="Ehliyet Rehberim" width="48" height="48" /> Ehliyet Rehberim

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat-square&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=flat-square&logo=firebase&logoColor=black)
![License](https://img.shields.io/badge/License-MIT-green.svg?style=flat-square)

[🇺🇸 Read in English](README.md)

Ehliyet Rehberim, Türkiye Ehliyet Sınavı hazırlık sürecini kolaylaştırmak için tasarlanmış kapsamlı bir mobil uygulamadır. Optimize edilmiş bir öğrenme deneyimi sunmak için gelişmiş performans analizleri, görsel hafıza teknikleri ve gerçek zamanlı durum yönetimi (state management) entegrasyonuna sahiptir.

## Genel Bakış

Uygulama, 20'den fazla sınav simülasyonu, detaylı konu anlatımları ve etkileşimli testler sunan güçlü bir eğitim platformudur. Ölçeklenebilirlik ve sürdürülebilirlik sağlamak için özellik odaklı (feature-first) bir mimari kullanır; durum yönetimi için Riverpod ve kimlik doğrulama ile veri kalıcılığı gibi backend servisleri için Firebase'den yararlanır.

## Mimari & Tasarım

Bu proje, ilgilerin ayrrımı (separation of concerns) ve modülerliği teşvik eden **Feature-First Architecture** (Özellik Odaklı Mimari) yapısına sadık kalır. Her özellik; Domain, Data ve Presentation katmanlarına sahip bağımsız bir modül olarak tasarlanmıştır, bu da iş mantığının UI bileşenlerinden ayrıştırılmasını sağlar.

### Temel Prensipler
*   **Katmanlı Mimari**: Data, Domain ve Presentation katmanları arasında katı bir ayrım.
*   **Reaktif State Management**: Bağımlılık enjeksiyonu ve durum yönetimi için `flutter_riverpod` kullanımı.
*   **Repository Pattern**: Veri kaynaklarını soyutlayarak domain katmanı için temiz bir API sağlar.
*   **Clean Code**: Okunabilirlik, test edilebilirlik ve SOLID prensiplerine vurgu.

## Özellikler & Kullanım Senaryoları

*   **Sınav Simülasyonu**: Gerçek sınav koşullarını birebir yansıtan 20+ tam kapsamlı deneme sınavı.
*   **Performans Analitiği**: Kullanıcı gelişimini görselleştirmek ve eksik alanları belirlemek için `fl_chart` implementasyonu.
*   **Görsel Öğrenme Modülleri**: Trafik işaretleri ve araç teknik bilgileri için özelleştirilmiş etkileşimli bileşenler.
*   **Durum Kalıcılığı (Persistence)**: Çevrimdışı kullanım yeteneği için `shared_preferences` ve yerel önbellekleme stratejileri.
*   **Güvenli Kimlik Doğrulama**: Email, Google ve Apple Sign-In sağlayıcılarını destekleyen entegre Firebase Auth yapısı.

## Teknoloji Yığını (Tech Stack)

| Bileşen | Teknoloji | Açıklama |
| :--- | :--- | :--- |
| **Framework** | Flutter 3.8.1+ | Native derlenmiş uygulamalar geliştirmek için UI araç seti. |
| **Dil** | Dart | UI mantığı ve asenkron programlama için optimize edilmiş dil. |
| **State Management** | Riverpod | Derleme güvenli (compile-safe) durum yönetimi ve bağımlılık enjeksiyonu. |
| **Backend** | Firebase | Auth, Firestore ve Analytics için sunucusuz (serverless) backend. |
| **Yerel Depolama** | SharedPreferences | Kullanıcı ayarları ve hafif veriler için anahtar-değer deposu. |
| **Görselleştirme** | FL Chart | Karmaşık ve etkileşimli grafiklerin çizimi için kütüphane. |
| **Tipografi** | Google Fonts | Tutarlı tipografi için `Inter` yazı tipi ailesi. |

## Proje Yapısı

Dizin yapısı, feature-first yaklaşımını yansıtır:

```
lib/
├── src/
│   ├── features/               # Özellik tabanlı modüller
│   │   ├── auth/               # Kimlik Doğrulama (Giriş, Kayıt, AuthGate)
│   │   ├── home/               # Dashboard ve temel navigasyon mantığı
│   │   ├── quiz/               # Sınav motoru, durum yönetimi ve UI
│   │   ├── stats/              # Veri görselleştirme ve ilerleme takibi
│   │   ├── profile/            # Kullanıcı ayarları ve profil yönetimi
│   │   └── favorites/          # Sorular için favorilere ekleme sistemi
│   ├── common_widgets/         # Paylaşılan UI bileşenleri (Butonlar, Kartlar vb.)
│   ├── constants/              # Uygulama genelindeki sabitler (Renkler, Stringler)
│   ├── utils/                  # Yardımcı sınıflar, formatlayıcılar ve eklentiler
│   ├── routing/                # Router yapılandırması ve yollar
│   └── localization/           # Uluslararasılaştırma kaynakları
└── main.dart                   # Uygulama giriş noktası ve başlatma işlemleri
```

## Kurulum

### Ön Gereksinimler
*   Flutter SDK: `>=3.8.1`
*   Dart SDK: Flutter sürümüyle uyumlu
*   CocoaPods (iOS derlemesi için)

### Adım Adım Kurulum

1.  **Repoyu Klonlayın**
    ```bash
    git clone https://github.com/Start-Up-Academy-Mobile-App/ehliyet-rehberim.git
    cd ehliyet-rehberim
    ```

2.  **Bağımlılıkları Yükleyin**
    ```bash
    flutter pub get
    ```

3.  **Firebase Yapılandırması**
    *   `google-services.json` dosyasını `android/app/` dizinine yerleştirin.
    *   `GoogleService-Info.plist` dosyasını `ios/Runner/` dizinine yerleştirin.

4.  **Uygulamayı Başlatın**
    ```bash
    flutter run
    ```

## Ekran Görüntüleri

| Ana Sayfa | Quiz Arayüzü | Analizler | Profil |
|:---:|:---:|:---:|:---:|
| <img src="assets/images/screenshots/home.png" width="220" alt="Home" /> | <img src="assets/images/screenshots/quiz.png" width="220" alt="Quiz" /> | <img src="assets/images/screenshots/stats.png" width="220" alt="Stats" /> | <img src="assets/images/screenshots/profile.png" width="220" alt="Profile" /> |

## Lisans

Bu proje MIT Lisansı ile lisanslanmıştır - detaylar için [LICENSE](LICENSE) dosyasına bakınız.
