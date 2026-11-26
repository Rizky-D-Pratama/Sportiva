import 'package:flutter/foundation.dart';

enum RescheduleReason {
  dipesan,
  ditutup,
  terlaluDekat,
  tanggalTidakValid,
  lapanganNonaktif,
  unknown,
}

enum RescheduleResult {
  dijadwalUlang,
  tidakBerubah,
}

/// Data class representing an hour option from RPC `get_reschedule_options`
@immutable
class RescheduleOption {
  final int jamMulai;
  final bool tersedia;
  final RescheduleReason? alasan;
  final String? rawAlasan;

  const RescheduleOption({
    required this.jamMulai,
    required this.tersedia,
    this.alasan,
    this.rawAlasan,
  });

  factory RescheduleOption.fromJson(Map<String, dynamic> json) {
    final jamMulai = (json['jam_mulai'] as num).toInt();
    final tersedia = json['tersedia'] as bool? ?? false;
    final rawAlasan = json['alasan'] as String?;

    RescheduleReason? alasanEnum;
    if (rawAlasan != null && rawAlasan.isNotEmpty) {
      alasanEnum = switch (rawAlasan) {
        'dipesan' => RescheduleReason.dipesan,
        'ditutup' => RescheduleReason.ditutup,
        'terlalu_dekat' => RescheduleReason.terlaluDekat,
        'tanggal_tidak_valid' => RescheduleReason.tanggalTidakValid,
        'lapangan_nonaktif' => RescheduleReason.lapanganNonaktif,
        _ => RescheduleReason.unknown,
      };
    }

    return RescheduleOption(
      jamMulai: jamMulai,
      tersedia: tersedia,
      alasan: alasanEnum,
      rawAlasan: rawAlasan,
    );
  }
}
