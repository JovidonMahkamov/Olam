import 'package:olam/core/networks/api_urls.dart';
import 'package:olam/core/networks/dio_client.dart';
import 'package:olam/core/utils/logger.dart';
import 'package:olam/features/home/data/datasource/home_data_source.dart';
import 'package:olam/features/home/data/model/mahsulot_model.dart';
import 'package:olam/features/home/data/model/mijoz_model.dart';
import 'package:olam/features/home/data/model/sotuv_model.dart';

class HomeDataSourceImpl implements HomeDataSource {
  final DioClient dioClient;

  HomeDataSourceImpl({required this.dioClient});

  @override
  Future<MahsulotlarResponseModel> getMahsulotlar({String? q, int sahifa = 1}) async {
    try {
      final response = await dioClient.get(
        ApiUrls.getMahsulotlar,
        queryParams: {
          if (q != null && q.isNotEmpty) 'q': q,
          'sahifa': sahifa,
          'har_sahifa': 100,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return MahsulotlarResponseModel.fromJson(response.data);
      }
      throw Exception('getMahsulotlar failed: ${response.statusCode}');
    } catch (e) {
      LoggerService.error('getMahsulotlar error: $e');
      rethrow;
    }
  }

  @override
  Future<MijozlarResponseModel> getMijozlar({String? q}) async {
    try {
      final response = await dioClient.get(
        ApiUrls.getMijozlar,
        queryParams: {
          if (q != null && q.isNotEmpty) 'q': q,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return MijozlarResponseModel.fromJson(response.data);
      }
      throw Exception('getMijozlar failed: ${response.statusCode}');
    } catch (e) {
      LoggerService.error('getMijozlar error: $e');
      rethrow;
    }
  }

  @override
  Future<MijozModel> postMijoz({
    required String fish,
    String? telefon,
    String? manzil,
  }) async {
    try {
      final response = await dioClient.post(
        ApiUrls.postMijoz,
        data: {
          'fish': fish,
          if (telefon != null) 'telefon': telefon,
          if (manzil != null) 'manzil': manzil,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return MijozModel.fromJson(response.data['data']);
      }
      throw Exception('postMijoz failed: ${response.statusCode}');
    } catch (e) {
      LoggerService.error('postMijoz error: $e');
      rethrow;
    }
  }

  @override
  Future<List<SotuvModel>> getSotuvlar() async {
    try {
      final response = await dioClient.get(ApiUrls.getSotuvlar,queryParams: {});
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] as Map<String, dynamic>;
        final list = data['sotuvlar'] as List<dynamic>? ?? [];
        return list.map((e) => SotuvModel.fromJson(e)).toList();
      }
      throw Exception('getSotuvlar failed: ${response.statusCode}');
    } catch (e) {
      LoggerService.error('getSotuvlar error: $e');
      rethrow;
    }
  }

  @override
  Future<SotuvModel> postSotuv({
    required String nomi,
    required int mijozId,
  }) async {
    try {
      final response = await dioClient.post(
        ApiUrls.postSotuv,
        data: {'nomi': nomi, 'mijoz_id': mijozId},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return SotuvModel.fromJson(response.data['data']);
      }
      throw Exception('postSotuv failed: ${response.statusCode}');
    } catch (e) {
      LoggerService.error('postSotuv error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteSotuv({required int id}) async {
    try {
      final response = await dioClient.delete('${ApiUrls.deleteSotuv}$id');
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('deleteSotuv failed: ${response.statusCode}');
      }
    } catch (e) {
      LoggerService.error('deleteSotuv error: $e');
      rethrow;
    }
  }

  @override
  Future<SotuvElementModel> postSotuvElement({
    required int sotuvId,
    required int mahsulotId,
    double dona = 0,
    double pachtka = 0,
    double metr = 0,
    required double narxUsd,
  }) async {
    try {
      final response = await dioClient.post(
        '${ApiUrls.sotuvElementlar}$sotuvId/elementlar',
        data: {
          'mahsulot_id': mahsulotId,
          'dona':        dona,
          'pachtka':     pachtka,
          'metr':        metr,
          'narx_usd':    narxUsd,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return SotuvElementModel.fromJson(response.data['data']);
      }
      throw Exception('postSotuvElement failed: ${response.statusCode}');
    } catch (e) {
      LoggerService.error('postSotuvElement error: $e');
      rethrow;
    }
  }

  @override
  Future<SotuvModel> yakunlashSotuv({
    required int sotuvId,
    required String tolovTuri,
    required double tolovQilinganUsd,
    bool chegirma = false,
    bool sms = false,
    String? izoh,
  }) async {
    try {
      final response = await dioClient.post(
        '${ApiUrls.sotuvYakunlash}$sotuvId/yakunlash',
        data: {
          'tolov_turi':          tolovTuri,
          'tolov_qilingan_usd':  tolovQilinganUsd,
          'chegirma':            chegirma,
          'sms':                 sms,
          if (izoh != null) 'izoh': izoh,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return SotuvModel.fromJson(response.data['data']);
      }
      throw Exception('yakunlashSotuv failed: ${response.statusCode}');
    } catch (e) {
      LoggerService.error('yakunlashSotuv error: $e');
      rethrow;
    }
  }
}