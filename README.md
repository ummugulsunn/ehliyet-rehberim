<div align="center">
  <img src="assets/images/app_logo.png" alt="Ehliyet Rehberim Logo" width="120" height="auto" />
  <h1>Ehliyet Rehberim</h1>
  
  <p>
    <strong>Türkiye'nin En Kapsamlı Ehliyet Sınavı Hazırlık Uygulaması</strong>
  </p>

  <p>
    <a href="https://flutter.dev">
      <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" alt="Flutter">
    </a>
    <a href="https://dart.dev">
      <img src="https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
    </a>
    <a href="https://firebase.google.com">
      <img src="https://img.shields.io/badge/Firebase-%23FFCA28.svg?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase">
    </a>
    <a href="LICENSE">
      <img src="https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge" alt="License">
    </a>
  </p>
</div>

---

## � Proje Hakkında

**Ehliyet Rehberim**, ehliyet sınavına hazırlanan adaylar için özel olarak tasarlanmış modern bir mobil uygulamadır. 20'den fazla deneme sınavı, konu anlatımları ve görsel hafıza teknikleri ile sınav stresini azaltmayı ve başarıyı artırmayı hedefler. Kullanıcı dostu arayüzü ve performans takibi özellikleri ile öğrenme sürecini kişiselleştirir.

---

## ✨ Özellikler

| Özellik | Açıklama |
| :--- | :--- |
| 🎯 **Geniş Soru Havuzu** | Gerçek sınav formatında 20+ deneme sınavı ve yüzlerce soru. |
| 📊 **Detaylı Analizler** | Gelişmiş grafiklerle performans takibi ve eksik konu belirleme. |
| 🧠 **Görsel Öğrenme** | Trafik işaretleri ve araç bilgisi için özel görsel modüller. |
| ⚡ **Dinamik Quiz** | Konfetili kutlamalar ve anlık geri bildirimlerle eğlenceli test deneyimi. |
| 💾 **Çevrimdışı Mod** | İnternet olmadan da çalışabilen, verilerinizi yerel olarak saklayan yapı. |
| � **Güvenli Giriş** | Firebase altyapısı ile Email, Google ve Apple ile güvenli oturum açma. |

---

## 📸 Ekran Görüntüleri

| **Ana Sayfa** | **Quiz Ekranı** | **İstatistikler** | **Profil** |
|:---:|:---:|:---:|:---:|
| <img src="assets/images/screenshots/home.png" width="200" alt="Home Screen" /> | <img src="assets/images/screenshots/quiz.png" width="200" alt="Quiz Screen" /> | <img src="assets/images/screenshots/stats.png" width="200" alt="Stats Screen" /> | <img src="assets/images/screenshots/profile.png" width="200" alt="Profile Screen" /> |
> *Not: Ekran görüntüleri geliştirme aşamasındadır.*

---

## 🛠️ Teknolojiler

Bu proje, modern ve ölçeklenebilir teknolojiler kullanılarak geliştirilmiştir:

| Alan | Teknoloji | Kullanım Amacı |
| :--- | :--- | :--- |
| **Framework** | Flutter (3.8.1+) | Cross-platform mobil uygulama geliştirme. |
| **Dil** | Dart | Tip güvenli ve performanslı programlama dili. |
| **State Management** | Riverpod | Test edilebilir ve reaktif durum yönetimi. |
| **Backend** | Firebase | Auth, Firestore ve Core servisleri. |
| **Veri Görselleştirme** | FL Chart | İstatistiksel verilerin grafiksel gösterimi. |
| **Yerel Depolama** | SharedPreferences | Kullanıcı tercihlerinin cihazda saklanması. |

---

## 🚀 Kurulum

Projeyi yerel ortamınızda çalıştırmak için aşağıdaki adımları izleyin:

### Gereksinimler
*   Flutter SDK (3.8.1 veya üzeri)
*   Dart SDK
*   VS Code veya Android Studio

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
    *   `google-services.json` dosyasını `android/app/` dizinine ekleyin.
    *   `GoogleService-Info.plist` dosyasını `ios/Runner/` dizinine ekleyin.

4.  **Uygulamayı Başlatın**
    ```bash
    flutter run
    ```

---

## 📂 Proje Yapısı

Proje, **Feature-First** (Özellik Odaklı) mimari prensiplerine göre yapılandırılmıştır:

```text
lib/
├── src/
│   ├── features/           # Özellik bazlı modüller
│   │   ├── auth/           # Kimlik doğrulama
│   │   ├── home/           # Ana sayfa
│   │   ├── quiz/           # Sınav motoru
│   │   ├── stats/          # İstatistikler
│   │   └── ...
│   ├── common_widgets/     # Paylaşılan UI bileşenleri
│   ├── constants/          # Sabitler ve tema ayarları
│   ├── utils/              # Yardımcı fonksiyonlar
│   └── routing/            # Navigasyon yapılandırması
└── main.dart               # Başlangıç noktası
```

---

## � Katkıda Bulunma

Katkılarınızı bekliyoruz! Lütfen aşağıdaki adımları takip edin:

1.  Bu repoyu Fork'layın.
2.  Yeni bir feature branch oluşturun (`git checkout -b feature/HarikaOzellik`).
3.  Değişikliklerinizi commit'leyin (`git commit -m 'HarikaOzellik eklendi'`).
4.  Branch'inizi Push'layın (`git push origin feature/HarikaOzellik`).
5.  Bir Pull Request oluşturun.

---

## 📄 Lisans

Bu proje **MIT Lisansı** ile lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakabilirsiniz.
