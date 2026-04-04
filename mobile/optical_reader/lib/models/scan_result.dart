class StudentAnswer {
  final int soruNo;
  final String? cevap;
  final bool gecersiz;

  StudentAnswer({
    required this.soruNo,
    this.cevap,
    this.gecersiz = false,
  });

  Map<String, dynamic> toJson() => {
        'soru_no': soruNo,
        'cevap': cevap,
        'gecersiz': gecersiz,
      };

  factory StudentAnswer.fromJson(Map<String, dynamic> json) => StudentAnswer(
        soruNo: json['soru_no'] as int,
        cevap: json['cevap'] as String?,
        gecersiz: json['gecersiz'] as bool? ?? false,
      );
}

class ScanResult {
  final String? ogrenciAd;
  final String? ogrenciNo;
  final String sinavId;
  final String grup;
  final int soruSayisi;
  final int sikSayisi;
  final List<StudentAnswer> cevaplar;

  ScanResult({
    this.ogrenciAd,
    this.ogrenciNo,
    required this.sinavId,
    required this.grup,
    required this.soruSayisi,
    required this.sikSayisi,
    required this.cevaplar,
  });

  Map<String, dynamic> toJson() => {
        'ogrenci_ad': ogrenciAd,
        'ogrenci_no': ogrenciNo,
        'sinav_id': sinavId,
        'grup': grup,
        'soru_sayisi': soruSayisi,
        'sik_sayisi': sikSayisi,
        'cevaplar': cevaplar.map((e) => e.toJson()).toList(),
      };

  factory ScanResult.fromJson(Map<String, dynamic> json) => ScanResult(
        ogrenciAd: json['ogrenci_ad'] as String?,
        ogrenciNo: json['ogrenci_no'] as String?,
        sinavId: json['sinav_id'] as String,
        grup: json['grup'] as String,
        soruSayisi: json['soru_sayisi'] as int,
        sikSayisi: json['sik_sayisi'] as int,
        cevaplar: (json['cevaplar'] as List)
            .map((e) => StudentAnswer.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
