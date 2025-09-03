List<String> reorderList(List<String> elements, int oldIdx, int newIdx) {
  if (elements.isEmpty) return List.empty();
  if (oldIdx == newIdx) return elements;
  if (oldIdx < 0 ||
      oldIdx >= elements.length ||
      newIdx < 0 ||
      newIdx >= elements.length) {
    throw RangeError('Index out of range');
  }

  final elementToMove = elements[oldIdx];
  if (newIdx > oldIdx) {
    final elementsBefore = oldIdx > 0 ? elements.sublist(0, oldIdx) : [];
    // old element is shifted to the left
    final elementsInBetween = elements.sublist(oldIdx + 1, newIdx + 1);
    final elementsAfter = oldIdx < elements.length
        ? elements.sublist(newIdx + 1)
        : [];
    return [
      ...elementsBefore,
      ...elementsInBetween,
      elementToMove,
      ...elementsAfter,
    ];
  } else {
    final elementsBefore = newIdx > 0 ? elements.sublist(0, newIdx) : [];
    // old element is shifted to the right
    final elementsInBetween = elements.sublist(newIdx, oldIdx);
    final elementsAfter = oldIdx < elements.length
        ? elements.sublist(oldIdx + 1)
        : [];
    return [
      ...elementsBefore,
      elementToMove,
      ...elementsInBetween,
      ...elementsAfter,
    ];
  }
}

List<String> toStringList(dynamic value) {
  if (value == null) return [];
  if (value is List<String>) return value;
  if (value is List) return value.map((e) => e.toString()).toList();
  throw ArgumentError("Expected a List, got $value");
}

Map<String, List<String>> mergeMaps(
  Map<String, List<String>> a,
  Map<String, List<String>> b,
) {
  final result = <String, List<String>>{};

  // Start with a copy of map a
  a.forEach((key, value) {
    result[key] = List<String>.from(value);
  });

  // Merge entries from b
  b.forEach((key, value) {
    result.putIfAbsent(key, () => []);
    result[key]!.addAll(value);
  });

  return result;
}
