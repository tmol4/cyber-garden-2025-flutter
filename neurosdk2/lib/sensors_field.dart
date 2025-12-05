import 'package:neurosdk2/cmn_types.dart';
import 'package:neurosdk2/pigeon_messages.g.dart';

class _SensorProperty<T> {
  final String _guid;

  _SensorProperty(this._guid);
}

class SensorGetProperty<T> extends _SensorProperty<T> {
  final Future<T> Function(String) _getter;
  final SensorPropertyConverter? _converter;

  SensorGetProperty(super.guid, this._getter, [this._converter]);

  Future<T> get value async {
    return _converter == null ? _getter(_guid) : _converter.fromNative(await _getter(_guid));
  }
}

class SensorGetConvertedProperty<N, F> extends _SensorProperty<N> {
  final Future<N> Function(String) _getter;
  final SensorPropertyConverter<N, F> _converter;

  SensorGetConvertedProperty(super.guid, this._getter, this._converter);

  Future<F> get value async {
    return _converter.fromNative(await _getter(_guid));
  }
}

class SensorGetSetProperty<T> extends SensorGetProperty<T> {
  final Future<void> Function(String, T) _setter;

  SensorGetSetProperty(super.guid, super._getter, this._setter);

  Future<void> set(T newValue) {
    return _setter(_guid, newValue);
  }
}

class SensorGetSetConvertedProperty<N, F> extends SensorGetConvertedProperty<N, F> {
  final Future<void> Function(String, N) setter;

  SensorGetSetConvertedProperty(super.guid, super.getter, this.setter, super.converter);

  Future<void> set(F newValue) {
    return setter(_guid, _converter.toNative(newValue));
  }
}

abstract class SensorPropertyConverter<N, F> {
  N toNative(F val);
  F fromNative(N val);

  SensorPropertyConverter();
}

class SensorFeaturesSetConverter extends SensorPropertyConverter<List<int?>, Set<FSensorFeature>> {
  SensorFeaturesSetConverter();

  @override
  Set<FSensorFeature> fromNative(List<int?> val) {
    return Set.unmodifiable(val.map<FSensorFeature>((element) => FSensorFeature.values[element ?? 0]));
  }

  @override
  List<int> toNative(Set<FSensorFeature> val) {
    return List<int>.generate(val.length, (index) => val.elementAt(index).index);
  }
}

class SensorCommandsSetConverter extends SensorPropertyConverter<List<int?>, Set<FSensorCommand>> {
  SensorCommandsSetConverter();

  @override
  Set<FSensorCommand> fromNative(List<int?> val) {
    return Set.unmodifiable(val.map<FSensorCommand>((element) => FSensorCommand.values[element ?? 0]));
  }

  @override
  List<int> toNative(Set<FSensorCommand> val) {
    return List<int>.generate(val.length, (index) => val.elementAt(index).index);
  }
}

class SensorFiltersSetConverter extends SensorPropertyConverter<List<int>, Set<FSensorFilter>> {
  SensorFiltersSetConverter();

  @override
  Set<FSensorFilter> fromNative(List<int?> val) {
    return Set.unmodifiable(val.map<FSensorFilter>((element) => FSensorFilter.values[element ?? 0]));
  }

  @override
  List<int> toNative(Set<FSensorFilter> val) {
    return List<int>.generate(val.length, (index) => val.elementAt(index).index);
  }
}

class BrainBit2AmplifierParamConverter extends SensorPropertyConverter<BrainBit2AmplifierParamNative, BrainBit2AmplifierParam> {
  BrainBit2AmplifierParamConverter();

  @override
  BrainBit2AmplifierParam fromNative(BrainBit2AmplifierParamNative val) {
    return BrainBit2AmplifierParam(
        current: val.current,
        chGain: List.generate(val.chGain.length, (index) => FSensorGain.values[val.chGain[index] ?? 0]),
        chResistUse: List.generate(val.chResistUse.length, (index) => val.chResistUse[index] ?? false),
        chSignalMode: List.generate(val.chSignalMode.length, (index) => FBrainBit2ChannelMode.values[val.chSignalMode[index] ?? 0]));
  }

  @override
  BrainBit2AmplifierParamNative toNative(BrainBit2AmplifierParam val) {
    return BrainBit2AmplifierParamNative(
        chSignalMode: List.generate(val.chSignalMode.length, (index) => val.chSignalMode[index].index),
        chResistUse: val.chResistUse,
        chGain: List.generate(val.chGain.length, (index) => val.chGain[index].index),
        current: val.current);
  }
}
