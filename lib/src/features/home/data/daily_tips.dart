
/// A collection of daily tips and facts for driver candidates
class DailyTips {
  static const List<String> tips = [
    "Şehir içi hız sınırı, aksi belirtilmedikçe 50 km/s'dir.",
    "Takip mesafesi, hızınızın yarısı kadar metredir. (Örn: 90 km/s -> 45m)",
    "Yağışlı havalarda takip mesafesini iki katına çıkarın.",
    "Kırmızı ışıkta geçmenin cezası sadece para değil, aynı zamanda 20 ceza puanıdır.",
    "Emniyet kemeri takmak, kaza anında ölüm riskini %45 azaltır.",
    "Sollama yaparken önce aynaları kontrol et, sonra sinyal ver.",
    "Yaya geçitlerinde öncelik her zaman yayalarındır.",
    "Tali yoldan ana yola çıkan araçlar, ana yoldaki araçlara yol vermelidir.",
    "Lastik basınçlarını ayda en az bir kez kontrol edin.",
    "Motor yağı seviyesini düz bir zeminde ve motor soğukken kontrol edin.",
    "Uzun farlar 100 metreyi, kısa farlar 25 metreyi aydınlatmalıdır.",
    "3 şeritli yollarda ağır vasıtalar en sağ şeridi kullanmalıdır.",
    "Dönel kavşaklarda, kavşak içindeki araca yol verilmelidir.",
    "Alkollü araç kullanmak trafikten men sebebidir.",
    "Yangın söndürme cihazı, sürücünün en kolay ulaşabileceği yerde olmalıdır."
  ];

  /// Returns a tip based on the day of the year to ensure it changes daily but stays same during the day
  static String getTodayTip() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return tips[dayOfYear % tips.length];
  }
}
