import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openplants/pages/model_info/model_info_datasource.dart';

void main() {
  test('short input shape metadata returns unknown size', () async {
    final datasource = ModelInfoDatasource(
      bundle: _MetadataBundle('{"input_shape":[1,3,224]}'),
    );

    final metadata = await datasource.loadModelMeta();

    expect(metadata['inputSize'], 'unknown');
  });

  test('rank-four input shape metadata returns image dimensions', () async {
    final datasource = ModelInfoDatasource(
      bundle: _MetadataBundle('{"input_shape":[1,3,224,224]}'),
    );

    final metadata = await datasource.loadModelMeta();

    expect(metadata['inputSize'], '224x224');
  });
}

class _MetadataBundle extends AssetBundle {
  final String _json;

  _MetadataBundle(this._json);

  @override
  Future<String> loadString(String key, {bool cache = true}) async => _json;

  @override
  Future<ByteData> load(String key) async => throw UnimplementedError();
}
