import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/visitor.dart';

class Collector extends RecursiveElementVisitor<void> {
  final List<ClassElement> _classElements = [];

  Iterable<ClassElement> get classElements => _classElements;

  Collector();

  @override
  void visitClassElement(ClassElement element) {
    if (_classElements.where((e) => e.name == element.name).isEmpty) {
      _classElements.add(element);
    }
  }

  @override
  void visitLibraryExportElement(LibraryExportElement element) {
    final shownNames = <String>{};

    for (final combinator in element.combinators) {
      if (combinator is ShowElementCombinator) {
        shownNames.addAll(combinator.shownNames);
      }
    }

    final collector = Collector();
    element.exportedLibrary?.accept(collector);

    bool shouldInclude(ClassElement element) => element.isPublic && !shownNames.contains(element.name);

    collector.classElements.where(shouldInclude).forEach(visitClassElement);
  }
}
