import '../../../core/identity/permanent_id.dart';
import '../../../core/storage/managed_relative_path.dart';
import '../../icons/domain/icon_selection.dart';
import '../../icons/domain/icon_definition.dart';

final class LabelValidationException implements Exception {
  const LabelValidationException(this.message);
  final String message;
}

enum LabelKind {
  battery('battery', 'battery', IconScope.battery),
  set('set', 'battery_set', IconScope.batterySet),
  device('device', 'device', IconScope.device);

  const LabelKind(this.host, this.storage, this.scope);
  final String host, storage;
  final IconScope scope;
}

final class LabelRef {
  const LabelRef(this.kind, this.id);
  final LabelKind kind;
  final PermanentId id;
  Uri get uri =>
      Uri(scheme: 'batterytracker', host: kind.host, path: '/' + id.value);
  factory LabelRef.parse(String input) {
    try {
      final u = Uri.parse(input.trim());
      if (u.scheme != 'batterytracker' ||
          u.userInfo.isNotEmpty ||
          u.hasPort ||
          u.hasQuery ||
          u.hasFragment ||
          u.pathSegments.length != 1) throw const FormatException();
      final kind = LabelKind.values.firstWhere((k) => k.host == u.host);
      return LabelRef(kind, PermanentId.parse(u.pathSegments.single));
    } on Object {
      throw const LabelValidationException(
          'Enter a Battery Tracker QR value with a valid permanent UUID.');
    }
  }
  @override
  bool operator ==(Object other) =>
      other is LabelRef && other.kind == kind && other.id == id;
  @override
  int get hashCode => Object.hash(kind, id);
}

final class LabelTarget {
  LabelTarget(
      {required this.ref,
      required Map<String, String> fields,
      required this.icon,
      this.photo})
      : fields = Map.unmodifiable(fields);
  final LabelRef ref;
  final Map<String, String> fields;
  final IconSelection icon;
  final ManagedRelativePath? photo;
  String get title => fields['id']?.isNotEmpty == true
      ? fields['id']!
      : fields['name'] ?? ref.id.value;
}

const labelFields = {
  'id': 'Battery / Set ID',
  'name': 'Name',
  'type': 'Battery Type',
  'manufacturer': 'Manufacturer',
  'model': 'Model',
  'capacity': 'Capacity',
  'members': 'Set member count',
  'category': 'Device category'
};

final class LabelLayout {
  LabelLayout(
      {this.width = 144,
      this.height = 72,
      this.qrSize = 43.2,
      this.fontSize = 8,
      this.margin = 4,
      this.align = 'left',
      this.orientation = 'landscape',
      this.showIcon = true,
      this.usePhoto = false,
      List<String> fields = const ['id', 'name'],
      this.customText = ''})
      : fields = List.unmodifiable(fields);
  final double width, height, qrSize, fontSize, margin;
  final String align, orientation, customText;
  final bool showIcon, usePhoto;
  final List<String> fields;
  double get pageWidth => orientation == 'portrait' ? height : width;
  double get pageHeight => orientation == 'portrait' ? width : height;
  void validate() {
    if ([width, height, qrSize, fontSize, margin].any((v) => !v.isFinite) ||
        width < 36 ||
        height < 36 ||
        width > 864 ||
        height > 864 ||
        margin < 0 ||
        fontSize < 4 ||
        fontSize > 72 ||
        qrSize < 36 ||
        (orientation == 'portrait'
            ? (qrSize > pageWidth - 2 * margin ||
                pageHeight - 2 * margin - qrSize - 4 < 18)
            : (qrSize > pageHeight - 2 * margin ||
                pageWidth - 2 * margin - qrSize - 4 < 18)) ||
        !['left', 'center', 'right'].contains(align) ||
        !['landscape', 'portrait'].contains(orientation) ||
        fields.any((f) => !labelFields.containsKey(f)) ||
        fields.toSet().length != fields.length)
      throw const LabelValidationException(
          'Layout does not fit. Use a QR of at least 0.5 inches, leave space for text, and check dimensions, margins, and font size.');
  }

  Map<String, Object?> toJson() => {
        'width': width,
        'height': height,
        'qrSize': qrSize,
        'fontSize': fontSize,
        'margin': margin,
        'align': align,
        'orientation': orientation,
        'showIcon': showIcon,
        'usePhoto': usePhoto,
        'fields': fields,
        'customText': customText
      };
  factory LabelLayout.fromJson(Map<String, dynamic> j) {
    try {
      final l = LabelLayout(
          width: (j['width'] as num).toDouble(),
          height: (j['height'] as num).toDouble(),
          qrSize: (j['qrSize'] as num).toDouble(),
          fontSize: (j['fontSize'] as num).toDouble(),
          margin: (j['margin'] as num).toDouble(),
          align: j['align'] as String,
          orientation: j['orientation'] as String,
          showIcon: j['showIcon'] as bool,
          usePhoto: j['usePhoto'] as bool,
          fields: (j['fields'] as List).cast<String>(),
          customText: j['customText'] as String);
      l.validate();
      return l;
    } on Object {
      throw const LabelValidationException(
          'This saved label layout is invalid.');
    }
  }
  static Map<String, LabelLayout> get presets => {
        'Small Battery Label': LabelLayout(
            width: 108, height: 54, qrSize: 36, fontSize: 7, margin: 3),
        'Medium Battery Label': LabelLayout(),
        'Device Label': LabelLayout(
            width: 216,
            height: 144,
            qrSize: 72,
            fontSize: 12,
            fields: ['name', 'manufacturer', 'model']),
        'Address Label Sheet': LabelLayout(width: 189, height: 72),
        'Custom Size': LabelLayout()
      };
}

final class LabelSheet {
  const LabelSheet(
      {this.enabled = false,
      this.paperWidth = 612,
      this.paperHeight = 792,
      this.rows = 10,
      this.columns = 3,
      this.marginX = 13.5,
      this.marginY = 36,
      this.gapX = 9,
      this.gapY = 0,
      this.start = 1});
  final bool enabled;
  final double paperWidth, paperHeight, marginX, marginY, gapX, gapY;
  final int rows, columns, start;
  void validate(LabelLayout l) {
    l.validate();
    if (!enabled) return;
    if ([paperWidth, paperHeight, marginX, marginY, gapX, gapY]
            .any((v) => !v.isFinite) ||
        paperWidth < 72 ||
        paperHeight < 72 ||
        paperWidth > 1728 ||
        paperHeight > 1728 ||
        rows < 1 ||
        columns < 1 ||
        rows * columns > 200 ||
        start < 1 ||
        start > rows * columns ||
        [marginX, marginY, gapX, gapY].any((v) => v < 0) ||
        2 * marginX + columns * l.pageWidth + (columns - 1) * gapX >
            paperWidth + .001 ||
        2 * marginY + rows * l.pageHeight + (rows - 1) * gapY >
            paperHeight + .001)
      throw const LabelValidationException(
          'Labels do not fit this sheet. Check paper size, rows, columns, gaps, margins, and starting position.');
  }

  Map<String, Object?> toJson() => {
        'enabled': enabled,
        'paperWidth': paperWidth,
        'paperHeight': paperHeight,
        'rows': rows,
        'columns': columns,
        'marginX': marginX,
        'marginY': marginY,
        'gapX': gapX,
        'gapY': gapY,
        'start': start
      };
  factory LabelSheet.fromJson(Map<String, dynamic> j) => LabelSheet(
      enabled: j['enabled'] as bool,
      paperWidth: (j['paperWidth'] as num).toDouble(),
      paperHeight: (j['paperHeight'] as num).toDouble(),
      rows: j['rows'] as int,
      columns: j['columns'] as int,
      marginX: (j['marginX'] as num).toDouble(),
      marginY: (j['marginY'] as num).toDouble(),
      gapX: (j['gapX'] as num).toDouble(),
      gapY: (j['gapY'] as num).toDouble(),
      start: j['start'] as int);
  List<LabelPlacement> positions(int count, LabelLayout l) {
    validate(l);
    if (count < 1 || count > 1000)
      throw const LabelValidationException('Select 1–1000 labels.');
    return List.generate(count, (i) {
      final slot = i + (enabled ? start - 1 : 0),
          capacity = enabled ? rows * columns : 1;
      return LabelPlacement(
          i,
          slot ~/ capacity,
          enabled
              ? marginX + (slot % capacity % columns) * (l.pageWidth + gapX)
              : 0,
          enabled
              ? marginY + (slot % capacity ~/ columns) * (l.pageHeight + gapY)
              : 0);
    });
  }
}

final class LabelPlacement {
  const LabelPlacement(this.index, this.page, this.x, this.y);
  final int index, page;
  final double x, y;
}

final class LabelTemplate {
  const LabelTemplate(this.id, this.name, this.kind, this.layout, this.sheet);
  final PermanentId id;
  final String name;
  final LabelKind kind;
  final LabelLayout layout;
  final LabelSheet sheet;
}

final class LabelJob {
  LabelJob(this.id, this.name, List<LabelRef> refs, this.layout, this.sheet)
      : refs = List.unmodifiable(refs);
  final String id, name;
  final List<LabelRef> refs;
  final LabelLayout layout;
  final LabelSheet sheet;
}

abstract interface class LabelRepository {
  Future<List<LabelTarget>> inventory();
  Future<LabelTarget> resolve(LabelRef ref);
  Future<List<LabelRef>> setMembers(PermanentId setId);
  Future<List<LabelTemplate>> templates();
  Future<void> saveTemplate(
      String name, LabelKind kind, LabelLayout layout, LabelSheet sheet,
      {PermanentId? id});
  Future<void> deactivateTemplate(PermanentId id);
  Future<List<LabelJob>> jobs();
  Future<void> saveJob(
      String name, List<LabelRef> refs, LabelLayout layout, LabelSheet sheet);
  Future<void> recordOutput(String event, List<LabelRef> refs);
}
