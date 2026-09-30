import 'package:flutter_test/flutter_test.dart';
import 'package:petpaws/utils/pet_ranking.dart';
import 'package:petpaws/utils/pet_tags.dart';

Map<String, dynamic> pet(String id, List<String> tags, {String province = ''}) =>
    {'id': id, 'tags': tags, 'province': province};

List<String> ids(List<Map<String, dynamic>> pets) =>
    pets.map((p) => p['id'].toString()).toList();

void main() {
  group('tag helpers', () {
    test('tagMatchCount counts shared tags', () {
      expect(tagMatchCount(['a', 'b', 'c'], ['b', 'c', 'd']), 2);
      expect(tagMatchCount(['a'], []), 0);
    });

    test('petTagIds tolerates a missing tags field', () {
      expect(petTagIds({'id': '1'}), isEmpty);
    });
  });

  group('sortPetsForUser', () {
    test('puts the pet with the most matching tags first', () {
      final sorted = sortPetsForUser(
        [pet('100', ['x']), pet('200', ['a', 'b']), pet('300', ['a'])],
        userTagIds: ['a', 'b'],
      );
      expect(ids(sorted), ['200', '300', '100']);
    });

    test('breaks ties by same province, then by newest post', () {
      final sorted = sortPetsForUser(
        [
          pet('100', ['a'], province: 'Chiang Mai'),
          pet('300', ['a']),
          pet('200', ['a'], province: 'Bangkok'),
        ],
        userTagIds: ['a'],
        userProvince: 'Bangkok',
      );
      expect(ids(sorted), ['200', '300', '100']);
    });

    test('keeps pets with no matching tags in the feed', () {
      final sorted = sortPetsForUser([pet('1', ['z'])], userTagIds: ['a']);
      expect(sorted, hasLength(1));
    });

    test('does not modify the input list', () {
      final input = [pet('1', []), pet('2', ['a'])];
      sortPetsForUser(input, userTagIds: ['a']);
      expect(ids(input), ['1', '2']);
    });
  });
}
