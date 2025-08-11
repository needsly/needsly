List<String> reorderList(List<String> elements, int oldIdx, int newIdx) {
  if (elements.isEmpty) return List.empty();
  if (oldIdx == newIdx) return elements;
  if (oldIdx < 0 || oldIdx >= elements.length || newIdx < 0 || newIdx >= elements.length) {
    throw RangeError('Index out of range');
  }

final elementToMove = elements[oldIdx];
  if (newIdx > oldIdx) {
    final elementsBefore = oldIdx > 0 ? elements.sublist(0, oldIdx) : [];
    // old element is shifted to the left
    final elementsInBetween = elements.sublist(oldIdx + 1, newIdx + 1);
    final elementsAfter = oldIdx < elements.length ? elements.sublist(newIdx + 1) : [];
    return [...elementsBefore, ...elementsInBetween, elementToMove, ...elementsAfter,];
  } else {
    final elementsBefore = newIdx > 0 ? elements.sublist(0, newIdx) : [];
    // old element is shifted to the right
    final elementsInBetween = elements.sublist(newIdx, oldIdx);
    final elementsAfter = oldIdx < elements.length ? elements.sublist(oldIdx + 1) : [];
    return [...elementsBefore, elementToMove, ...elementsInBetween, ...elementsAfter];
  }
}
