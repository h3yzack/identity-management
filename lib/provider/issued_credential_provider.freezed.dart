// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'issued_credential_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$IssuedCredentialState {
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isSaving => throw _privateConstructorUsedError;
  int get recordAdded => throw _privateConstructorUsedError;
  List<IssuedCredential>? get credentials => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $IssuedCredentialStateCopyWith<IssuedCredentialState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IssuedCredentialStateCopyWith<$Res> {
  factory $IssuedCredentialStateCopyWith(IssuedCredentialState value,
          $Res Function(IssuedCredentialState) then) =
      _$IssuedCredentialStateCopyWithImpl<$Res, IssuedCredentialState>;
  @useResult
  $Res call(
      {bool isLoading,
      bool isSaving,
      int recordAdded,
      List<IssuedCredential>? credentials});
}

/// @nodoc
class _$IssuedCredentialStateCopyWithImpl<$Res,
        $Val extends IssuedCredentialState>
    implements $IssuedCredentialStateCopyWith<$Res> {
  _$IssuedCredentialStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isSaving = null,
    Object? recordAdded = null,
    Object? credentials = freezed,
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
      recordAdded: null == recordAdded
          ? _value.recordAdded
          : recordAdded // ignore: cast_nullable_to_non_nullable
              as int,
      credentials: freezed == credentials
          ? _value.credentials
          : credentials // ignore: cast_nullable_to_non_nullable
              as List<IssuedCredential>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_IssuedCredentialStateCopyWith<$Res>
    implements $IssuedCredentialStateCopyWith<$Res> {
  factory _$$_IssuedCredentialStateCopyWith(_$_IssuedCredentialState value,
          $Res Function(_$_IssuedCredentialState) then) =
      __$$_IssuedCredentialStateCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      bool isSaving,
      int recordAdded,
      List<IssuedCredential>? credentials});
}

/// @nodoc
class __$$_IssuedCredentialStateCopyWithImpl<$Res>
    extends _$IssuedCredentialStateCopyWithImpl<$Res, _$_IssuedCredentialState>
    implements _$$_IssuedCredentialStateCopyWith<$Res> {
  __$$_IssuedCredentialStateCopyWithImpl(_$_IssuedCredentialState _value,
      $Res Function(_$_IssuedCredentialState) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isSaving = null,
    Object? recordAdded = null,
    Object? credentials = freezed,
  }) {
    return _then(_$_IssuedCredentialState(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isSaving: null == isSaving
          ? _value.isSaving
          : isSaving // ignore: cast_nullable_to_non_nullable
              as bool,
      recordAdded: null == recordAdded
          ? _value.recordAdded
          : recordAdded // ignore: cast_nullable_to_non_nullable
              as int,
      credentials: freezed == credentials
          ? _value._credentials
          : credentials // ignore: cast_nullable_to_non_nullable
              as List<IssuedCredential>?,
    ));
  }
}

/// @nodoc

class _$_IssuedCredentialState extends _IssuedCredentialState {
  const _$_IssuedCredentialState(
      {this.isLoading = true,
      this.isSaving = false,
      this.recordAdded = 0,
      final List<IssuedCredential>? credentials})
      : _credentials = credentials,
        super._();

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isSaving;
  @override
  @JsonKey()
  final int recordAdded;
  final List<IssuedCredential>? _credentials;
  @override
  List<IssuedCredential>? get credentials {
    final value = _credentials;
    if (value == null) return null;
    if (_credentials is EqualUnmodifiableListView) return _credentials;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'IssuedCredentialState(isLoading: $isLoading, isSaving: $isSaving, recordAdded: $recordAdded, credentials: $credentials)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_IssuedCredentialState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isSaving, isSaving) ||
                other.isSaving == isSaving) &&
            (identical(other.recordAdded, recordAdded) ||
                other.recordAdded == recordAdded) &&
            const DeepCollectionEquality()
                .equals(other._credentials, _credentials));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, isSaving, recordAdded,
      const DeepCollectionEquality().hash(_credentials));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_IssuedCredentialStateCopyWith<_$_IssuedCredentialState> get copyWith =>
      __$$_IssuedCredentialStateCopyWithImpl<_$_IssuedCredentialState>(
          this, _$identity);
}

abstract class _IssuedCredentialState extends IssuedCredentialState {
  const factory _IssuedCredentialState(
      {final bool isLoading,
      final bool isSaving,
      final int recordAdded,
      final List<IssuedCredential>? credentials}) = _$_IssuedCredentialState;
  const _IssuedCredentialState._() : super._();

  @override
  bool get isLoading;
  @override
  bool get isSaving;
  @override
  int get recordAdded;
  @override
  List<IssuedCredential>? get credentials;
  @override
  @JsonKey(ignore: true)
  _$$_IssuedCredentialStateCopyWith<_$_IssuedCredentialState> get copyWith =>
      throw _privateConstructorUsedError;
}
