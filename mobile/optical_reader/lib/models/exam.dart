class ExamConfig {
  final String? sinavId;
  final String sinavAdi;
  final int soruSayisi;
  final int sikSayisi;
  final List<double> puanlar;
  final int grupSayisi;
  final List<String> gruplar;

  ExamConfig({
    this.sinavId,
    required this.sinavAdi,
    required this.soruSayisi,
    required this.sikSayisi,
    required this.puanlar,
    this.grupSayisi = 1,
    List<String>? gruplar,
  }) : gruplar = gruplar ?? const ['A', 'B', 'C', 'D'].sublist(0, grupSayisi);

  Map<String, dynamic> toJson() => {
        if (sinavId != null) 'sinav_id': sinavId,
        'sinav_adi': sinavAdi,
        'soru_sayisi': soruSayisi,
        'sik_sayisi': sikSayisi,
        'puanlar': puanlar,
        'grup_sayisi': grupSayisi,
        'gruplar': gruplar,
      };

  factory ExamConfig.fromJson(Map<String, dynamic> json) => ExamConfig(
        sinavId: json['sinav_id'] as String?,
        sinavAdi: json['sinav_adi'] as String,
        soruSayisi: json['soru_sayisi'] as int,
        sikSayisi: json['sik_sayisi'] as int,
        puanlar: (json['puanlar'] as List).map((e) => (e as num).toDouble()).toList(),
        grupSayisi: json['grup_sayisi'] as int? ?? 1,
        gruplar: (json['gruplar'] as List?)?.cast<String>(),
      );

  ExamConfig copyWith({String? sinavId}) => ExamConfig(
        sinavId: sinavId ?? this.sinavId,
        sinavAdi: sinavAdi,
        soruSayisi: soruSayisi,
        sikSayisi: sikSayisi,
        puanlar: puanlar,
        grupSayisi: grupSayisi,
        gruplar: gruplar,
      );
}

class AnswerKey {
  final String sinavId;
  final String grup;
  final List<String> cevaplar;
  final List<double> puanlar;

  AnswerKey({
    required this.sinavId,
    required this.grup,
    required this.cevaplar,
    required this.puanlar,
  });

  Map<String, dynamic> toJson() => {
        'sinav_id': sinavId,
        'grup': grup,
        'cevaplar': cevaplar,
        'puanlar': puanlar,
      };

  factory AnswerKey.fromJson(Map<String, dynamic> json) => AnswerKey(
        sinavId: json['sinav_id'] as String,
        grup: json['grup'] as String,
        cevaplar: (json['cevaplar'] as List).cast<String>(),
        puanlar: (json['puanlar'] as List).map((e) => (e as num).toDouble()).toList(),
      );
}
