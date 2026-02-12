// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_preference.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ThemePreferenceAdapter extends TypeAdapter<ThemePreference> {
  @override
  final int typeId = 5;

  @override
  ThemePreference read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ThemePreference(
      themePreset: fields[0] as ThemePreset,
      useGlassEffect: fields[1] as bool,
      isDarkMode: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ThemePreference obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.themePreset)
      ..writeByte(1)
      ..write(obj.useGlassEffect)
      ..writeByte(2)
      ..write(obj.isDarkMode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemePreferenceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ThemePresetAdapter extends TypeAdapter<ThemePreset> {
  @override
  final int typeId = 4;

  @override
  ThemePreset read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ThemePreset.material;
      case 1:
        return ThemePreset.tacticalDark;
      default:
        return ThemePreset.material;
    }
  }

  @override
  void write(BinaryWriter writer, ThemePreset obj) {
    switch (obj) {
      case ThemePreset.material:
        writer.writeByte(0);
        break;
      case ThemePreset.tacticalDark:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemePresetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
