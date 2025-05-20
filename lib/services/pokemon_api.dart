import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon_list_response.dart';
import '../models/pokemon_detail_response.dart';
import '../utils/debounce.dart';

class PokemonApi {
  static const _baseUrl = 'https://pokeapi.co/api/v2';
  final _debounce = AppDebounce();

  Future<PokemonListApiResponse> fetchPokemonList({
    int limit = 20,
    int offset = 0,
  }) async {
    final completer = Completer<PokemonListApiResponse>();
    final url = '$_baseUrl/pokemon?limit=$limit&offset=$offset';

    _debounce.call(() async {
      try {
        final res = await http.get(Uri.parse(url));
        if (res.statusCode == 200) {
          final listResponse = PokemonListApiResponse.fromJson(
            jsonDecode(res.body),
          );
          completer.complete(listResponse);
        } else {
          completer.completeError(
            Exception(
              "Failede to fetch Pokemon list (statusCode: ${res.statusCode})",
            ),
          );
        }
      } catch (e) {
        completer.completeError(e);
      }
    });


    final res = await http.get(Uri.parse('$_baseUrl/pokemon'));
    if (res.statusCode == 200) {
      return PokemonListApiResponse.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to fetch Pokemon list');
  }

  Future<PokemonDetailApiResponse> fetchPokemonDetails(String url) {
    final completer = Completer<PokemonDetailApiResponse>();

    _debounce.call(() async {
      try {
        final res = await http.get(
          Uri.parse(url),
          headers: {
            'Accept': 'application/json',
            'User-Agent': 'PokemonMaurico/1.0',
          },
        );

        if (res.statusCode == 200) {
          final detail = PokemonDetailApiResponse.fromJson(
            jsonDecode(res.body),
          );
          completer.complete(detail);
        } else {
          completer.completeError(
            Exception(
              'Failed to fetch Pokemon details (statusCode: ${res.statusCode})',
            ),
          );
        }
      } catch (e) {
        completer.completeError(e);
      }
    });
    return completer.future;
  }
}
