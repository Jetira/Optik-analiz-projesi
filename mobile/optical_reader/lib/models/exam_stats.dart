class ExamStats {
  final String sinavId;
  final int toplamOgrenci;
  final double sinifOrtalamasi;
  final double medyan;
  final double enYuksek;
  final double enDusuk;
  final double standartSapma;
  final Map<String, double> grupOrtalamalari;
  final List<double> soruDogruOranlari;
  final List<Map<String, double>> soruSikDagilimi;
  final List<int> enZorSorular;

  ExamStats({
    required this.sinavId,
    required this.toplamOgrenci,
    required this.sinifOrtalamasi,
    required this.medyan,
    required this.enYuksek,
    required this.enDusuk,
    required this.standartSapma,
    required this.grupOrtalamalari,
    required this.soruDogruOranlari,
    required this.soruSikDagilimi,
    required this.enZorSorular,
  });

  factory ExamStats.fromJson(Map<String, dynamic> json) => ExamStats(
        sinavId: json['sinav_id'] as String,
        toplamOgrenci: json['toplam_ogrenci'] as int,
        sinifOrtalamasi: (json['sinif_ortalamasi'] as num).toDouble(),
        medyan: (json['medyan'] as num).toDouble(),
        enYuksek: (json['en_yuksek'] as num).toDouble(),
        enDusuk: (json['en_dusuk'] as num).toDouble(),
        standartSapma: (json['standart_sapma'] as num).toDouble(),
        grupOrtalamalari: (json['grup_ortalamalari'] as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, (v as num).toDouble())),
        soruDogruOranlari: (json['soru_dogru_oranlari'] as List)
            .map((e) => (e as num).toDouble())
            .toList(),
        soruSikDagilimi: (json['soru_sik_dagilimi'] as List)
            .map((e) => (e as Map<String, dynamic>)
                .map((k, v) => MapEntry(k, (v as num).toDouble())))
            .toList(),
        enZorSorular: (json['en_zor_sorular'] as List).cast<int>(),
      );
}
