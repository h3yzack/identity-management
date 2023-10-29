// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'did_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$DidState {
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isSaving => throw _privateConstructorUsedError;
  bool get isBack => throw _privateConstructorUsedError;
  int get recordAdded => throw _privateConstructorUsedError;
  List<DidDocument>? get didDocuments => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DidStateCopyWith<DidState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DidStateCopyWith<$Res> {
  factory $DidStateCopyWith(DidState value, $Res Function(DidState) then) =
      _$DidStateCopyWithImpl<$Res, DidState>;
  @useResult
  $Res call(
      {bool isLoading,
      bool isSaving,
      bool isBack,
      int recordAdded,
      List<DidDocument>? didDocuments});
}

/// @nodoc
class _$DidStateCopyWithImpl<$Res, $Val extends DidState>
    implements $DidStateCopyWith<$Res> {
  _$DidStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isSaving = null,
    Object? isBack = null,
    Object? recordAdded = null,
    Object? didDocuments = freezed,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isSaving: null == isSaving
          ? _value.isSaving
          : isSaving // ignore: cast_nullable_to_non_nullable
              as bool,
      isBack: null == isBack
          ? _value.isBack
          : isBack // ignore: cast_nullable_to_non_nullable
              as bool,
      recordAdded: null == recordAdded
          ? _value.recordAdded
          : recordAdded // ignore: cast_nullable_to_non_nullable
              as int,
      didDocuments: freezed == didDocuments
          ? _value.didDocuments
          : didDocuments // ignore: cast_nullable_to_non_nullable
              as List<DidDocument>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_DidStateCopyWith<$Res> implements $DidStateCopyWith<$Res> {
  factory _$$_DidStateCopyWith(
          _$_DidState value, $Res Function(_$_DidState) then) =
      __$$_DidStateCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      bool isSaving,
      bool isBack,
      int recordAdded,
      List<DidDocument>? didDocuments});
}

/// @nodoc
class __$$_DidStateCopyWithImpl<$Res>
    extends _$DidStateCopyWithImpl<$Res, _$_DidState>
    implements _$$_DidStateCopyWith<$Res> {
  __$$_DidStateCopyWithImpl(
      _$_DidState _value, $Res Function(_$_DidState) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isSaving = null,
    Object? isBack = null,
    Object? recordAdded = null,
    Object? didDocuments = freezed,
  }) {
    return _then(_$_DidState(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isSaving: null == isSaving
          ? _value.isSaving
          : isSaving // ignore: cast_nullable_to_non_nullable
              as bool,
      isBack: null == isBack
          ? _value.isBack
          : isBack // ignore: cast_nullable_to_non_nullable
              as bool,
      recordAdded: null == recordAdded
          ? _value.recordAdded
          : recordAdded // ignore: cast_nullable_to_non_nullable
              as int,
      didDocuments: freezed == didDocuments
          ? _value._didDocuments
          : didDocuments // ignore: cast_nullable_to_non_nullable
              as List<DidDocument>?,
    ));
  }
}

/// @nodoc

class _$_DidState extends _DidState {
  const _$_DidState(
      {this.isLoading = true,
      this.isSaving = false,
      this.isBack = false,
      this.recordAdded = 0,
      final List<DidDocument>? didDocuments})
      : _didDocuments = didDocuments,
        super._();

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isSaving;
  @override
  @JsonKey()
  final bool isBack;
  @override
  @JsonKey()
  final int recordAdded;
  final List<DidDocument>? _didDocuments;
  @override
  List<DidDocument>? get didDocuments {
    final value = _didDocuments;
    if (value == null) return null;
    if (_didDocuments is EqualUnmodifiableListView) return _didDocuments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'DidState(isLoading: $isLoading, isSaving: $isSaving, isBack: $isBack, recordAdded: $recordAdded, didDocuments: $didDocuments)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_DidState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isSaving, isSaving) ||
                other.isSaving == isSaving) &&
            (identical(other.isBack, isBack) || other.isBack == isBack) &&
            (identical(other.recordAdded, recordAdded) ||
                other.recordAdded == recordAdded) &&
            const DeepCollectionEquality()
                .equals(other._didDocuments, _didDocuments));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, isSaving, isBack,
      recordAdded, const DeepCollectionEquality().hash(_didDocuments));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_DidStateCopyWith<_$_DidState> get copyWith =>
      __$$_DidStateCopyWithImpl<_$_DidState>(this, _$identity);
}

abstract class _DidState extends DidState {
  const factory _DidState(
      {final bool isLoading,
      final bool isSaving,
      final bool isBack,
      final int recordAdded,
      final List<DidDocument>? didDocuments}) = _$_DidState;
  const _DidState._() : super._();

  @override
  bool get isLoading;
  @override
  bool get isSaving;
  @override
  bool get isBack;
  @override
  int get recordAdded;
  @override
  List<DidDocument>? get didDocuments;
  @override
  @JsonKey(ignore: true)
  _$$_DidStateCopyWith<_$_DidState> get copyWith =>
      throw _privateConstructorUsedError;
}
