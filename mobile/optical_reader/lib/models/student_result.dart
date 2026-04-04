class QuestionDetail {
  final int soruNo;
  final String? verilenCevap;
  final String dogruCevap;
  final double puan;
  final double alinanPuan;
  final String durum; // "dogru" | "yanlis" | "bos" | "gecersiz"

  QuestionDetail({
    required this.soruNo,
    this.verilenCevap,
    required this.dogruCevap,
    required this.puan,
    required this.alinanPuan,
    required this.durum,
  });

  Map<String, dynamic> toJson() => {
        'soru_no': soruNo,
        'verilen_cevap': verilenCevap,
        'dogru_cevap': dogruCevap,
        'puan': puan,
        'alinan_puan': alinanPuan,
        'durum': durum,
      };

  factory QuestionDetail.fromJson(Map<String, dynamic> json) => QuestionDetail(
        soruNo: json['soru_no'] as int,
        verilenCevap: json['verilen_cevap'] as String?,
        dogruCevap: json['dogru_cevap'] as String,
        puan: (json['puan'] as num).toDouble(),
        alinanPuan: (json['alinan_puan'] as num).toDouble(),
        durum: json['durum'] as String,
      );
}

class GradeResult {
  final String? ogrenciAd;
  final String? ogrenciNo;
  final String sinavId;
  final String grup;
  final List<QuestionDetail> soruDetay;
  final double toplamPuan;
  final double maksPuan;
  final int dogruSayisi;
  final int yanlisSayisi;
  final int bosSayisi;
  final int gecersizSayisi;

  GradeResult({
    this.ogrenciAd,
    this.ogrenciNo,
    required this.sinavId,
    required this.grup,
    required this.soruDetay,
    required this.toplamPuan,
    required this.maksPuan,
    required this.dogruSayisi,
    required this.yanlisSayisi,
    required this.bosSayisi,
    required this.gecersizSayisi,
  });

  Map<String, dynamic> toJson() => {
        'ogrenci_ad': ogrenciAd,
        'ogrenci_no': ogrenciNo,
        'sinav_id': sinavId,
        'grup': grup,
        'soru_detay': soruDetay.map((d) => d.toJson()).toList(),
        'toplam_puan': toplamPuan,
        'maks_puan': maksPuan,
        'dogru_sayisi': dogruSayisi,
        'yanlis_sayisi': yanlisSayisi,
        'bos_sayisi': bosSayisi,
        'gecersiz_sayisi': gecersizSayisi,
      };

  factory GradeResult.fromJson(Map<String, dynamic> json) => GradeResult(
        ogrenciAd: json['ogrenci_ad'] as String?,
        ogrenciNo: json['ogrenci_no'] as String?,
        sinavId: json['sinav_id'] as String,
        grup: json['grup'] as String,
        soruDetay: (json['soru_detay'] as List)
            .map((e) => QuestionDetail.fromJson(e as Map<String, dynamic>))
            .toList(),
        toplamPuan: (json['toplam_puan'] as num).toDouble(),
        maksPuan: (json['maks_puan'] as num).toDouble(),
        dogruSayisi: json['dogru_sayisi'] as int,
        yanlisSayisi: json['yanlis_sayisi'] as int,
        bosSayisi: json['bos_sayisi'] as int,
        gecersizSayisi: json['gecersiz_sayisi'] as int,
      );
}
