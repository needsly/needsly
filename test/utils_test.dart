import 'package:flutter_test/flutter_test.dart';
import 'package:needsly/utils/utils.dart';

void main() {
  test("Reordering elements, empty list", () {
    List<String> elements = List.empty();
    final resultList = shiftList(elements, 0, 1);
    expect(resultList, List.empty());
  });

  test("Reordering elements, newIdx == oldIdx", () {
    List<String> elements1 = ["a", "b", "c", "d", "e"];
    expect(shiftList(elements1, 1, 1), elements1);
    expect(shiftList(elements1, 0, 0), elements1);
    expect(shiftList(elements1, 2, 2), elements1);
    expect(shiftList(elements1, 4, 4), elements1);
    expect(shiftList(elements1, 3, 3), elements1);
  });

  test("Throw index out of range", () {
    List<String> elements1 = ["a", "b", "c", "d", "e"];
    expect(() => shiftList(elements1, -1, 0), throwsRangeError);
    expect(() => shiftList(elements1, 5, 0), throwsRangeError);
    expect(() => shiftList(elements1, 0, -1), throwsRangeError);
    expect(() => shiftList(elements1, 0, 5), throwsRangeError);

    List<String> elements2 = ["a"];
    expect(shiftList(elements2, 0, 0), ["a"]);
    expect(() => shiftList(elements2, 0, 1), throwsRangeError);
    expect(() => shiftList(elements2, 1, 0), throwsRangeError);
  });

  test("Reordering elements, single element", () {
    List<String> elements = ["a"];
    expect(shiftList(elements, 0, 0), ["a"]);
    expect(() => shiftList(elements, 0, 1), throwsRangeError);
    expect(() => shiftList(elements, 1, 0), throwsRangeError);
  });

  test("Reordering elements, two elements", () {
    List<String> elements = ["a", "b"];
    expect(shiftList(elements, 0, 1), ["b", "a"]);
    expect(shiftList(elements, 1, 0), ["b", "a"]);
    expect(() => shiftList(elements, -1, 0), throwsRangeError);
    expect(() => shiftList(elements, 2, 0), throwsRangeError);
  });

  test("Reordering elements, three elements", () {
    List<String> elements = ["a", "b", "c"];
    expect(shiftList(elements, 0, 1), ["b", "a", "c"]);
    expect(shiftList(elements, 1, 0), ["b", "a", "c"]);
    expect(shiftList(elements, 1, 2), ["a", "c", "b"]);
    expect(shiftList(elements, 2, 1), ["a", "c", "b"]);
    expect(() => shiftList(elements, -1, 0), throwsRangeError);
    expect(() => shiftList(elements, 3, 0), throwsRangeError);
  });

  test("Reordering elements, four elements", () {
    List<String> elements = ["a", "b", "c", "d"];
    expect(shiftList(elements, 0, 1), ["b", "a", "c", "d"]);
    expect(shiftList(elements, 1, 0), ["b", "a", "c", "d"]);
    expect(shiftList(elements, 1, 2), ["a", "c", "b", "d"]);
    expect(shiftList(elements, 2, 1), ["a", "c", "b", "d"]);
    expect(shiftList(elements, 2, 3), ["a", "b", "d", "c"]);
    expect(shiftList(elements, 3, 2), ["a", "b", "d", "c"]);
    expect(() => shiftList(elements, -1, 0), throwsRangeError);
    expect(() => shiftList(elements, 4, 0), throwsRangeError);
  });

  test("Reordering elements, five elements", () {
    List<String> elements = ["a", "b", "c", "d", "e"];
    expect(shiftList(elements, 0, 1), ["b", "a", "c", "d", "e"]);
    expect(shiftList(elements, 1, 0), ["b", "a", "c", "d", "e"]);
    expect(shiftList(elements, 1, 2), ["a", "c", "b", "d", "e"]);
    expect(shiftList(elements, 2, 1), ["a", "c", "b", "d", "e"]);
    expect(shiftList(elements, 2, 3), ["a", "b", "d", "c", "e"]);
    expect(shiftList(elements, 3, 2), ["a", "b", "d", "c", "e"]);
    expect(shiftList(elements, 3, 4), ["a", "b", "c", "e", "d"]);
    expect(shiftList(elements, 4, 3), ["a", "b", "c", "e", "d"]);
    expect(() => shiftList(elements, -1, 0), throwsRangeError);
    expect(() => shiftList(elements, 5, 0), throwsRangeError);
  });
}
