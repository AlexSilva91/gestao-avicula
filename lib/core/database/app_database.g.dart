// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _passwordHashMeta = const VerificationMeta(
    'passwordHash',
  );
  @override
  late final GeneratedColumn<String> passwordHash = GeneratedColumn<String>(
    'password_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSuperuserMeta = const VerificationMeta(
    'isSuperuser',
  );
  @override
  late final GeneratedColumn<bool> isSuperuser = GeneratedColumn<bool>(
    'is_superuser',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_superuser" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastLoginAtMeta = const VerificationMeta(
    'lastLoginAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastLoginAt = GeneratedColumn<DateTime>(
    'last_login_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    username,
    displayName,
    passwordHash,
    isSuperuser,
    isActive,
    createdAt,
    updatedAt,
    lastLoginAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('password_hash')) {
      context.handle(
        _passwordHashMeta,
        passwordHash.isAcceptableOrUnknown(
          data['password_hash']!,
          _passwordHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_passwordHashMeta);
    }
    if (data.containsKey('is_superuser')) {
      context.handle(
        _isSuperuserMeta,
        isSuperuser.isAcceptableOrUnknown(
          data['is_superuser']!,
          _isSuperuserMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('last_login_at')) {
      context.handle(
        _lastLoginAtMeta,
        lastLoginAt.isAcceptableOrUnknown(
          data['last_login_at']!,
          _lastLoginAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      passwordHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password_hash'],
      )!,
      isSuperuser: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_superuser'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      lastLoginAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_login_at'],
      ),
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final String id;
  final String username;
  final String displayName;
  final String passwordHash;
  final bool isSuperuser;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;
  const User({
    required this.id,
    required this.username,
    required this.displayName,
    required this.passwordHash,
    required this.isSuperuser,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['username'] = Variable<String>(username);
    map['display_name'] = Variable<String>(displayName);
    map['password_hash'] = Variable<String>(passwordHash);
    map['is_superuser'] = Variable<bool>(isSuperuser);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastLoginAt != null) {
      map['last_login_at'] = Variable<DateTime>(lastLoginAt);
    }
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      username: Value(username),
      displayName: Value(displayName),
      passwordHash: Value(passwordHash),
      isSuperuser: Value(isSuperuser),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastLoginAt: lastLoginAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastLoginAt),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      username: serializer.fromJson<String>(json['username']),
      displayName: serializer.fromJson<String>(json['displayName']),
      passwordHash: serializer.fromJson<String>(json['passwordHash']),
      isSuperuser: serializer.fromJson<bool>(json['isSuperuser']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastLoginAt: serializer.fromJson<DateTime?>(json['lastLoginAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'username': serializer.toJson<String>(username),
      'displayName': serializer.toJson<String>(displayName),
      'passwordHash': serializer.toJson<String>(passwordHash),
      'isSuperuser': serializer.toJson<bool>(isSuperuser),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastLoginAt': serializer.toJson<DateTime?>(lastLoginAt),
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? displayName,
    String? passwordHash,
    bool? isSuperuser,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> lastLoginAt = const Value.absent(),
  }) => User(
    id: id ?? this.id,
    username: username ?? this.username,
    displayName: displayName ?? this.displayName,
    passwordHash: passwordHash ?? this.passwordHash,
    isSuperuser: isSuperuser ?? this.isSuperuser,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastLoginAt: lastLoginAt.present ? lastLoginAt.value : this.lastLoginAt,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      username: data.username.present ? data.username.value : this.username,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
      isSuperuser: data.isSuperuser.present
          ? data.isSuperuser.value
          : this.isSuperuser,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastLoginAt: data.lastLoginAt.present
          ? data.lastLoginAt.value
          : this.lastLoginAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('displayName: $displayName, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('isSuperuser: $isSuperuser, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastLoginAt: $lastLoginAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    username,
    displayName,
    passwordHash,
    isSuperuser,
    isActive,
    createdAt,
    updatedAt,
    lastLoginAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.username == this.username &&
          other.displayName == this.displayName &&
          other.passwordHash == this.passwordHash &&
          other.isSuperuser == this.isSuperuser &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastLoginAt == this.lastLoginAt);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String> username;
  final Value<String> displayName;
  final Value<String> passwordHash;
  final Value<bool> isSuperuser;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastLoginAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.displayName = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.isSuperuser = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastLoginAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String username,
    required String displayName,
    required String passwordHash,
    this.isSuperuser = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.lastLoginAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       username = Value(username),
       displayName = Value(displayName),
       passwordHash = Value(passwordHash),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? username,
    Expression<String>? displayName,
    Expression<String>? passwordHash,
    Expression<bool>? isSuperuser,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastLoginAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (displayName != null) 'display_name': displayName,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (isSuperuser != null) 'is_superuser': isSuperuser,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastLoginAt != null) 'last_login_at': lastLoginAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<String>? username,
    Value<String>? displayName,
    Value<String>? passwordHash,
    Value<bool>? isSuperuser,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? lastLoginAt,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      passwordHash: passwordHash ?? this.passwordHash,
      isSuperuser: isSuperuser ?? this.isSuperuser,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<String>(passwordHash.value);
    }
    if (isSuperuser.present) {
      map['is_superuser'] = Variable<bool>(isSuperuser.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastLoginAt.present) {
      map['last_login_at'] = Variable<DateTime>(lastLoginAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('displayName: $displayName, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('isSuperuser: $isSuperuser, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastLoginAt: $lastLoginAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserPermissionsTable extends UserPermissions
    with TableInfo<$UserPermissionsTable, UserPermission> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserPermissionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _permissionMeta = const VerificationMeta(
    'permission',
  );
  @override
  late final GeneratedColumn<String> permission = GeneratedColumn<String>(
    'permission',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, userId, permission, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_permissions';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserPermission> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('permission')) {
      context.handle(
        _permissionMeta,
        permission.isAcceptableOrUnknown(data['permission']!, _permissionMeta),
      );
    } else if (isInserting) {
      context.missing(_permissionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {userId, permission},
  ];
  @override
  UserPermission map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserPermission(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      permission: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}permission'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UserPermissionsTable createAlias(String alias) {
    return $UserPermissionsTable(attachedDatabase, alias);
  }
}

class UserPermission extends DataClass implements Insertable<UserPermission> {
  final String id;
  final String userId;
  final String permission;
  final DateTime createdAt;
  const UserPermission({
    required this.id,
    required this.userId,
    required this.permission,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['permission'] = Variable<String>(permission);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UserPermissionsCompanion toCompanion(bool nullToAbsent) {
    return UserPermissionsCompanion(
      id: Value(id),
      userId: Value(userId),
      permission: Value(permission),
      createdAt: Value(createdAt),
    );
  }

  factory UserPermission.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserPermission(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      permission: serializer.fromJson<String>(json['permission']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'permission': serializer.toJson<String>(permission),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UserPermission copyWith({
    String? id,
    String? userId,
    String? permission,
    DateTime? createdAt,
  }) => UserPermission(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    permission: permission ?? this.permission,
    createdAt: createdAt ?? this.createdAt,
  );
  UserPermission copyWithCompanion(UserPermissionsCompanion data) {
    return UserPermission(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      permission: data.permission.present
          ? data.permission.value
          : this.permission,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserPermission(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('permission: $permission, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, permission, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPermission &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.permission == this.permission &&
          other.createdAt == this.createdAt);
}

class UserPermissionsCompanion extends UpdateCompanion<UserPermission> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> permission;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const UserPermissionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.permission = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserPermissionsCompanion.insert({
    required String id,
    required String userId,
    required String permission,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       permission = Value(permission),
       createdAt = Value(createdAt);
  static Insertable<UserPermission> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? permission,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (permission != null) 'permission': permission,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserPermissionsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? permission,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return UserPermissionsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      permission: permission ?? this.permission,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (permission.present) {
      map['permission'] = Variable<String>(permission.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserPermissionsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('permission: $permission, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditLogsTable extends AuditLogs
    with TableInfo<$AuditLogsTable, AuditLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metadataMeta = const VerificationMeta(
    'metadata',
  );
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
    'metadata',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    action,
    entityType,
    entityId,
    timestamp,
    description,
    metadata,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('metadata')) {
      context.handle(
        _metadataMeta,
        metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      ),
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      metadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata'],
      ),
    );
  }

  @override
  $AuditLogsTable createAlias(String alias) {
    return $AuditLogsTable(attachedDatabase, alias);
  }
}

class AuditLog extends DataClass implements Insertable<AuditLog> {
  final String id;
  final String? userId;
  final String action;
  final String entityType;
  final String? entityId;
  final DateTime timestamp;
  final String description;
  final String? metadata;
  const AuditLog({
    required this.id,
    this.userId,
    required this.action,
    required this.entityType,
    this.entityId,
    required this.timestamp,
    required this.description,
    this.metadata,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['action'] = Variable<String>(action);
    map['entity_type'] = Variable<String>(entityType);
    if (!nullToAbsent || entityId != null) {
      map['entity_id'] = Variable<String>(entityId);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<String>(metadata);
    }
    return map;
  }

  AuditLogsCompanion toCompanion(bool nullToAbsent) {
    return AuditLogsCompanion(
      id: Value(id),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      action: Value(action),
      entityType: Value(entityType),
      entityId: entityId == null && nullToAbsent
          ? const Value.absent()
          : Value(entityId),
      timestamp: Value(timestamp),
      description: Value(description),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
    );
  }

  factory AuditLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditLog(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String?>(json['userId']),
      action: serializer.fromJson<String>(json['action']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String?>(json['entityId']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      description: serializer.fromJson<String>(json['description']),
      metadata: serializer.fromJson<String?>(json['metadata']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String?>(userId),
      'action': serializer.toJson<String>(action),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String?>(entityId),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'description': serializer.toJson<String>(description),
      'metadata': serializer.toJson<String?>(metadata),
    };
  }

  AuditLog copyWith({
    String? id,
    Value<String?> userId = const Value.absent(),
    String? action,
    String? entityType,
    Value<String?> entityId = const Value.absent(),
    DateTime? timestamp,
    String? description,
    Value<String?> metadata = const Value.absent(),
  }) => AuditLog(
    id: id ?? this.id,
    userId: userId.present ? userId.value : this.userId,
    action: action ?? this.action,
    entityType: entityType ?? this.entityType,
    entityId: entityId.present ? entityId.value : this.entityId,
    timestamp: timestamp ?? this.timestamp,
    description: description ?? this.description,
    metadata: metadata.present ? metadata.value : this.metadata,
  );
  AuditLog copyWithCompanion(AuditLogsCompanion data) {
    return AuditLog(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      action: data.action.present ? data.action.value : this.action,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      description: data.description.present
          ? data.description.value
          : this.description,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditLog(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('action: $action, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('timestamp: $timestamp, ')
          ..write('description: $description, ')
          ..write('metadata: $metadata')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    action,
    entityType,
    entityId,
    timestamp,
    description,
    metadata,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditLog &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.action == this.action &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.timestamp == this.timestamp &&
          other.description == this.description &&
          other.metadata == this.metadata);
}

class AuditLogsCompanion extends UpdateCompanion<AuditLog> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<String> action;
  final Value<String> entityType;
  final Value<String?> entityId;
  final Value<DateTime> timestamp;
  final Value<String> description;
  final Value<String?> metadata;
  final Value<int> rowid;
  const AuditLogsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.action = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.description = const Value.absent(),
    this.metadata = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditLogsCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required String action,
    required String entityType,
    this.entityId = const Value.absent(),
    required DateTime timestamp,
    required String description,
    this.metadata = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       action = Value(action),
       entityType = Value(entityType),
       timestamp = Value(timestamp),
       description = Value(description);
  static Insertable<AuditLog> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? action,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<DateTime>? timestamp,
    Expression<String>? description,
    Expression<String>? metadata,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (action != null) 'action': action,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (timestamp != null) 'timestamp': timestamp,
      if (description != null) 'description': description,
      if (metadata != null) 'metadata': metadata,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditLogsCompanion copyWith({
    Value<String>? id,
    Value<String?>? userId,
    Value<String>? action,
    Value<String>? entityType,
    Value<String?>? entityId,
    Value<DateTime>? timestamp,
    Value<String>? description,
    Value<String?>? metadata,
    Value<int>? rowid,
  }) {
    return AuditLogsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      action: action ?? this.action,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      timestamp: timestamp ?? this.timestamp,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('action: $action, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('timestamp: $timestamp, ')
          ..write('description: $description, ')
          ..write('metadata: $metadata, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LotsTable extends Lots with TableInfo<$LotsTable, Lot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _strainMeta = const VerificationMeta('strain');
  @override
  late final GeneratedColumn<String> strain = GeneratedColumn<String>(
    'strain',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _initialQuantityMeta = const VerificationMeta(
    'initialQuantity',
  );
  @override
  late final GeneratedColumn<int> initialQuantity = GeneratedColumn<int>(
    'initial_quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
    'received_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _arrivalAgeDaysMeta = const VerificationMeta(
    'arrivalAgeDays',
  );
  @override
  late final GeneratedColumn<int> arrivalAgeDays = GeneratedColumn<int>(
    'arrival_age_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitValueCentsMeta = const VerificationMeta(
    'unitValueCents',
  );
  @override
  late final GeneratedColumn<int> unitValueCents = GeneratedColumn<int>(
    'unit_value_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _supplierMeta = const VerificationMeta(
    'supplier',
  );
  @override
  late final GeneratedColumn<String> supplier = GeneratedColumn<String>(
    'supplier',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ACTIVE'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    strain,
    initialQuantity,
    receivedAt,
    arrivalAgeDays,
    unitValueCents,
    supplier,
    notes,
    status,
    createdAt,
    createdBy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lots';
  @override
  VerificationContext validateIntegrity(
    Insertable<Lot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('strain')) {
      context.handle(
        _strainMeta,
        strain.isAcceptableOrUnknown(data['strain']!, _strainMeta),
      );
    }
    if (data.containsKey('initial_quantity')) {
      context.handle(
        _initialQuantityMeta,
        initialQuantity.isAcceptableOrUnknown(
          data['initial_quantity']!,
          _initialQuantityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_initialQuantityMeta);
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_receivedAtMeta);
    }
    if (data.containsKey('arrival_age_days')) {
      context.handle(
        _arrivalAgeDaysMeta,
        arrivalAgeDays.isAcceptableOrUnknown(
          data['arrival_age_days']!,
          _arrivalAgeDaysMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_arrivalAgeDaysMeta);
    }
    if (data.containsKey('unit_value_cents')) {
      context.handle(
        _unitValueCentsMeta,
        unitValueCents.isAcceptableOrUnknown(
          data['unit_value_cents']!,
          _unitValueCentsMeta,
        ),
      );
    }
    if (data.containsKey('supplier')) {
      context.handle(
        _supplierMeta,
        supplier.isAcceptableOrUnknown(data['supplier']!, _supplierMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Lot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Lot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      strain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}strain'],
      ),
      initialQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}initial_quantity'],
      )!,
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at'],
      )!,
      arrivalAgeDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}arrival_age_days'],
      )!,
      unitValueCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_value_cents'],
      ),
      supplier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
    );
  }

  @override
  $LotsTable createAlias(String alias) {
    return $LotsTable(attachedDatabase, alias);
  }
}

class Lot extends DataClass implements Insertable<Lot> {
  final String id;
  final String name;
  final String? strain;
  final int initialQuantity;
  final DateTime receivedAt;
  final int arrivalAgeDays;
  final int? unitValueCents;
  final String? supplier;
  final String? notes;
  final String status;
  final DateTime createdAt;
  final String createdBy;
  const Lot({
    required this.id,
    required this.name,
    this.strain,
    required this.initialQuantity,
    required this.receivedAt,
    required this.arrivalAgeDays,
    this.unitValueCents,
    this.supplier,
    this.notes,
    required this.status,
    required this.createdAt,
    required this.createdBy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || strain != null) {
      map['strain'] = Variable<String>(strain);
    }
    map['initial_quantity'] = Variable<int>(initialQuantity);
    map['received_at'] = Variable<DateTime>(receivedAt);
    map['arrival_age_days'] = Variable<int>(arrivalAgeDays);
    if (!nullToAbsent || unitValueCents != null) {
      map['unit_value_cents'] = Variable<int>(unitValueCents);
    }
    if (!nullToAbsent || supplier != null) {
      map['supplier'] = Variable<String>(supplier);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['created_by'] = Variable<String>(createdBy);
    return map;
  }

  LotsCompanion toCompanion(bool nullToAbsent) {
    return LotsCompanion(
      id: Value(id),
      name: Value(name),
      strain: strain == null && nullToAbsent
          ? const Value.absent()
          : Value(strain),
      initialQuantity: Value(initialQuantity),
      receivedAt: Value(receivedAt),
      arrivalAgeDays: Value(arrivalAgeDays),
      unitValueCents: unitValueCents == null && nullToAbsent
          ? const Value.absent()
          : Value(unitValueCents),
      supplier: supplier == null && nullToAbsent
          ? const Value.absent()
          : Value(supplier),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      status: Value(status),
      createdAt: Value(createdAt),
      createdBy: Value(createdBy),
    );
  }

  factory Lot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Lot(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      strain: serializer.fromJson<String?>(json['strain']),
      initialQuantity: serializer.fromJson<int>(json['initialQuantity']),
      receivedAt: serializer.fromJson<DateTime>(json['receivedAt']),
      arrivalAgeDays: serializer.fromJson<int>(json['arrivalAgeDays']),
      unitValueCents: serializer.fromJson<int?>(json['unitValueCents']),
      supplier: serializer.fromJson<String?>(json['supplier']),
      notes: serializer.fromJson<String?>(json['notes']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'strain': serializer.toJson<String?>(strain),
      'initialQuantity': serializer.toJson<int>(initialQuantity),
      'receivedAt': serializer.toJson<DateTime>(receivedAt),
      'arrivalAgeDays': serializer.toJson<int>(arrivalAgeDays),
      'unitValueCents': serializer.toJson<int?>(unitValueCents),
      'supplier': serializer.toJson<String?>(supplier),
      'notes': serializer.toJson<String?>(notes),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'createdBy': serializer.toJson<String>(createdBy),
    };
  }

  Lot copyWith({
    String? id,
    String? name,
    Value<String?> strain = const Value.absent(),
    int? initialQuantity,
    DateTime? receivedAt,
    int? arrivalAgeDays,
    Value<int?> unitValueCents = const Value.absent(),
    Value<String?> supplier = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    String? status,
    DateTime? createdAt,
    String? createdBy,
  }) => Lot(
    id: id ?? this.id,
    name: name ?? this.name,
    strain: strain.present ? strain.value : this.strain,
    initialQuantity: initialQuantity ?? this.initialQuantity,
    receivedAt: receivedAt ?? this.receivedAt,
    arrivalAgeDays: arrivalAgeDays ?? this.arrivalAgeDays,
    unitValueCents: unitValueCents.present
        ? unitValueCents.value
        : this.unitValueCents,
    supplier: supplier.present ? supplier.value : this.supplier,
    notes: notes.present ? notes.value : this.notes,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    createdBy: createdBy ?? this.createdBy,
  );
  Lot copyWithCompanion(LotsCompanion data) {
    return Lot(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      strain: data.strain.present ? data.strain.value : this.strain,
      initialQuantity: data.initialQuantity.present
          ? data.initialQuantity.value
          : this.initialQuantity,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
      arrivalAgeDays: data.arrivalAgeDays.present
          ? data.arrivalAgeDays.value
          : this.arrivalAgeDays,
      unitValueCents: data.unitValueCents.present
          ? data.unitValueCents.value
          : this.unitValueCents,
      supplier: data.supplier.present ? data.supplier.value : this.supplier,
      notes: data.notes.present ? data.notes.value : this.notes,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Lot(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('strain: $strain, ')
          ..write('initialQuantity: $initialQuantity, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('arrivalAgeDays: $arrivalAgeDays, ')
          ..write('unitValueCents: $unitValueCents, ')
          ..write('supplier: $supplier, ')
          ..write('notes: $notes, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    strain,
    initialQuantity,
    receivedAt,
    arrivalAgeDays,
    unitValueCents,
    supplier,
    notes,
    status,
    createdAt,
    createdBy,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Lot &&
          other.id == this.id &&
          other.name == this.name &&
          other.strain == this.strain &&
          other.initialQuantity == this.initialQuantity &&
          other.receivedAt == this.receivedAt &&
          other.arrivalAgeDays == this.arrivalAgeDays &&
          other.unitValueCents == this.unitValueCents &&
          other.supplier == this.supplier &&
          other.notes == this.notes &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy);
}

class LotsCompanion extends UpdateCompanion<Lot> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> strain;
  final Value<int> initialQuantity;
  final Value<DateTime> receivedAt;
  final Value<int> arrivalAgeDays;
  final Value<int?> unitValueCents;
  final Value<String?> supplier;
  final Value<String?> notes;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<String> createdBy;
  final Value<int> rowid;
  const LotsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.strain = const Value.absent(),
    this.initialQuantity = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.arrivalAgeDays = const Value.absent(),
    this.unitValueCents = const Value.absent(),
    this.supplier = const Value.absent(),
    this.notes = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LotsCompanion.insert({
    required String id,
    required String name,
    this.strain = const Value.absent(),
    required int initialQuantity,
    required DateTime receivedAt,
    required int arrivalAgeDays,
    this.unitValueCents = const Value.absent(),
    this.supplier = const Value.absent(),
    this.notes = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime createdAt,
    required String createdBy,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       initialQuantity = Value(initialQuantity),
       receivedAt = Value(receivedAt),
       arrivalAgeDays = Value(arrivalAgeDays),
       createdAt = Value(createdAt),
       createdBy = Value(createdBy);
  static Insertable<Lot> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? strain,
    Expression<int>? initialQuantity,
    Expression<DateTime>? receivedAt,
    Expression<int>? arrivalAgeDays,
    Expression<int>? unitValueCents,
    Expression<String>? supplier,
    Expression<String>? notes,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<String>? createdBy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (strain != null) 'strain': strain,
      if (initialQuantity != null) 'initial_quantity': initialQuantity,
      if (receivedAt != null) 'received_at': receivedAt,
      if (arrivalAgeDays != null) 'arrival_age_days': arrivalAgeDays,
      if (unitValueCents != null) 'unit_value_cents': unitValueCents,
      if (supplier != null) 'supplier': supplier,
      if (notes != null) 'notes': notes,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (createdBy != null) 'created_by': createdBy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LotsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? strain,
    Value<int>? initialQuantity,
    Value<DateTime>? receivedAt,
    Value<int>? arrivalAgeDays,
    Value<int?>? unitValueCents,
    Value<String?>? supplier,
    Value<String?>? notes,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<String>? createdBy,
    Value<int>? rowid,
  }) {
    return LotsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      strain: strain ?? this.strain,
      initialQuantity: initialQuantity ?? this.initialQuantity,
      receivedAt: receivedAt ?? this.receivedAt,
      arrivalAgeDays: arrivalAgeDays ?? this.arrivalAgeDays,
      unitValueCents: unitValueCents ?? this.unitValueCents,
      supplier: supplier ?? this.supplier,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (strain.present) {
      map['strain'] = Variable<String>(strain.value);
    }
    if (initialQuantity.present) {
      map['initial_quantity'] = Variable<int>(initialQuantity.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (arrivalAgeDays.present) {
      map['arrival_age_days'] = Variable<int>(arrivalAgeDays.value);
    }
    if (unitValueCents.present) {
      map['unit_value_cents'] = Variable<int>(unitValueCents.value);
    }
    if (supplier.present) {
      map['supplier'] = Variable<String>(supplier.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LotsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('strain: $strain, ')
          ..write('initialQuantity: $initialQuantity, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('arrivalAgeDays: $arrivalAgeDays, ')
          ..write('unitValueCents: $unitValueCents, ')
          ..write('supplier: $supplier, ')
          ..write('notes: $notes, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BirdMovementsTable extends BirdMovements
    with TableInfo<$BirdMovementsTable, BirdMovement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BirdMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lotIdMeta = const VerificationMeta('lotId');
  @override
  late final GeneratedColumn<String> lotId = GeneratedColumn<String>(
    'lot_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relatedLotIdMeta = const VerificationMeta(
    'relatedLotId',
  );
  @override
  late final GeneratedColumn<String> relatedLotId = GeneratedColumn<String>(
    'related_lot_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitValueCentsMeta = const VerificationMeta(
    'unitValueCents',
  );
  @override
  late final GeneratedColumn<int> unitValueCents = GeneratedColumn<int>(
    'unit_value_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalValueCentsMeta = const VerificationMeta(
    'totalValueCents',
  );
  @override
  late final GeneratedColumn<int> totalValueCents = GeneratedColumn<int>(
    'total_value_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    occurredAt,
    lotId,
    relatedLotId,
    quantity,
    unitValueCents,
    totalValueCents,
    reference,
    notes,
    createdBy,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bird_movements';
  @override
  VerificationContext validateIntegrity(
    Insertable<BirdMovement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('lot_id')) {
      context.handle(
        _lotIdMeta,
        lotId.isAcceptableOrUnknown(data['lot_id']!, _lotIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lotIdMeta);
    }
    if (data.containsKey('related_lot_id')) {
      context.handle(
        _relatedLotIdMeta,
        relatedLotId.isAcceptableOrUnknown(
          data['related_lot_id']!,
          _relatedLotIdMeta,
        ),
      );
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_value_cents')) {
      context.handle(
        _unitValueCentsMeta,
        unitValueCents.isAcceptableOrUnknown(
          data['unit_value_cents']!,
          _unitValueCentsMeta,
        ),
      );
    }
    if (data.containsKey('total_value_cents')) {
      context.handle(
        _totalValueCentsMeta,
        totalValueCents.isAcceptableOrUnknown(
          data['total_value_cents']!,
          _totalValueCentsMeta,
        ),
      );
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BirdMovement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BirdMovement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      lotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lot_id'],
      )!,
      relatedLotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}related_lot_id'],
      ),
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      unitValueCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_value_cents'],
      ),
      totalValueCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_value_cents'],
      ),
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BirdMovementsTable createAlias(String alias) {
    return $BirdMovementsTable(attachedDatabase, alias);
  }
}

class BirdMovement extends DataClass implements Insertable<BirdMovement> {
  final String id;
  final String type;
  final DateTime occurredAt;
  final String lotId;
  final String? relatedLotId;
  final int quantity;
  final int? unitValueCents;
  final int? totalValueCents;
  final String? reference;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  const BirdMovement({
    required this.id,
    required this.type,
    required this.occurredAt,
    required this.lotId,
    this.relatedLotId,
    required this.quantity,
    this.unitValueCents,
    this.totalValueCents,
    this.reference,
    this.notes,
    required this.createdBy,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['lot_id'] = Variable<String>(lotId);
    if (!nullToAbsent || relatedLotId != null) {
      map['related_lot_id'] = Variable<String>(relatedLotId);
    }
    map['quantity'] = Variable<int>(quantity);
    if (!nullToAbsent || unitValueCents != null) {
      map['unit_value_cents'] = Variable<int>(unitValueCents);
    }
    if (!nullToAbsent || totalValueCents != null) {
      map['total_value_cents'] = Variable<int>(totalValueCents);
    }
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(reference);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_by'] = Variable<String>(createdBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BirdMovementsCompanion toCompanion(bool nullToAbsent) {
    return BirdMovementsCompanion(
      id: Value(id),
      type: Value(type),
      occurredAt: Value(occurredAt),
      lotId: Value(lotId),
      relatedLotId: relatedLotId == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedLotId),
      quantity: Value(quantity),
      unitValueCents: unitValueCents == null && nullToAbsent
          ? const Value.absent()
          : Value(unitValueCents),
      totalValueCents: totalValueCents == null && nullToAbsent
          ? const Value.absent()
          : Value(totalValueCents),
      reference: reference == null && nullToAbsent
          ? const Value.absent()
          : Value(reference),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
    );
  }

  factory BirdMovement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BirdMovement(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      lotId: serializer.fromJson<String>(json['lotId']),
      relatedLotId: serializer.fromJson<String?>(json['relatedLotId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitValueCents: serializer.fromJson<int?>(json['unitValueCents']),
      totalValueCents: serializer.fromJson<int?>(json['totalValueCents']),
      reference: serializer.fromJson<String?>(json['reference']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'lotId': serializer.toJson<String>(lotId),
      'relatedLotId': serializer.toJson<String?>(relatedLotId),
      'quantity': serializer.toJson<int>(quantity),
      'unitValueCents': serializer.toJson<int?>(unitValueCents),
      'totalValueCents': serializer.toJson<int?>(totalValueCents),
      'reference': serializer.toJson<String?>(reference),
      'notes': serializer.toJson<String?>(notes),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BirdMovement copyWith({
    String? id,
    String? type,
    DateTime? occurredAt,
    String? lotId,
    Value<String?> relatedLotId = const Value.absent(),
    int? quantity,
    Value<int?> unitValueCents = const Value.absent(),
    Value<int?> totalValueCents = const Value.absent(),
    Value<String?> reference = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    String? createdBy,
    DateTime? createdAt,
  }) => BirdMovement(
    id: id ?? this.id,
    type: type ?? this.type,
    occurredAt: occurredAt ?? this.occurredAt,
    lotId: lotId ?? this.lotId,
    relatedLotId: relatedLotId.present ? relatedLotId.value : this.relatedLotId,
    quantity: quantity ?? this.quantity,
    unitValueCents: unitValueCents.present
        ? unitValueCents.value
        : this.unitValueCents,
    totalValueCents: totalValueCents.present
        ? totalValueCents.value
        : this.totalValueCents,
    reference: reference.present ? reference.value : this.reference,
    notes: notes.present ? notes.value : this.notes,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
  );
  BirdMovement copyWithCompanion(BirdMovementsCompanion data) {
    return BirdMovement(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      lotId: data.lotId.present ? data.lotId.value : this.lotId,
      relatedLotId: data.relatedLotId.present
          ? data.relatedLotId.value
          : this.relatedLotId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitValueCents: data.unitValueCents.present
          ? data.unitValueCents.value
          : this.unitValueCents,
      totalValueCents: data.totalValueCents.present
          ? data.totalValueCents.value
          : this.totalValueCents,
      reference: data.reference.present ? data.reference.value : this.reference,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BirdMovement(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('lotId: $lotId, ')
          ..write('relatedLotId: $relatedLotId, ')
          ..write('quantity: $quantity, ')
          ..write('unitValueCents: $unitValueCents, ')
          ..write('totalValueCents: $totalValueCents, ')
          ..write('reference: $reference, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    occurredAt,
    lotId,
    relatedLotId,
    quantity,
    unitValueCents,
    totalValueCents,
    reference,
    notes,
    createdBy,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BirdMovement &&
          other.id == this.id &&
          other.type == this.type &&
          other.occurredAt == this.occurredAt &&
          other.lotId == this.lotId &&
          other.relatedLotId == this.relatedLotId &&
          other.quantity == this.quantity &&
          other.unitValueCents == this.unitValueCents &&
          other.totalValueCents == this.totalValueCents &&
          other.reference == this.reference &&
          other.notes == this.notes &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt);
}

class BirdMovementsCompanion extends UpdateCompanion<BirdMovement> {
  final Value<String> id;
  final Value<String> type;
  final Value<DateTime> occurredAt;
  final Value<String> lotId;
  final Value<String?> relatedLotId;
  final Value<int> quantity;
  final Value<int?> unitValueCents;
  final Value<int?> totalValueCents;
  final Value<String?> reference;
  final Value<String?> notes;
  final Value<String> createdBy;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BirdMovementsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.lotId = const Value.absent(),
    this.relatedLotId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitValueCents = const Value.absent(),
    this.totalValueCents = const Value.absent(),
    this.reference = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BirdMovementsCompanion.insert({
    required String id,
    required String type,
    required DateTime occurredAt,
    required String lotId,
    this.relatedLotId = const Value.absent(),
    required int quantity,
    this.unitValueCents = const Value.absent(),
    this.totalValueCents = const Value.absent(),
    this.reference = const Value.absent(),
    this.notes = const Value.absent(),
    required String createdBy,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       occurredAt = Value(occurredAt),
       lotId = Value(lotId),
       quantity = Value(quantity),
       createdBy = Value(createdBy),
       createdAt = Value(createdAt);
  static Insertable<BirdMovement> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<DateTime>? occurredAt,
    Expression<String>? lotId,
    Expression<String>? relatedLotId,
    Expression<int>? quantity,
    Expression<int>? unitValueCents,
    Expression<int>? totalValueCents,
    Expression<String>? reference,
    Expression<String>? notes,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (lotId != null) 'lot_id': lotId,
      if (relatedLotId != null) 'related_lot_id': relatedLotId,
      if (quantity != null) 'quantity': quantity,
      if (unitValueCents != null) 'unit_value_cents': unitValueCents,
      if (totalValueCents != null) 'total_value_cents': totalValueCents,
      if (reference != null) 'reference': reference,
      if (notes != null) 'notes': notes,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BirdMovementsCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<DateTime>? occurredAt,
    Value<String>? lotId,
    Value<String?>? relatedLotId,
    Value<int>? quantity,
    Value<int?>? unitValueCents,
    Value<int?>? totalValueCents,
    Value<String?>? reference,
    Value<String?>? notes,
    Value<String>? createdBy,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return BirdMovementsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      occurredAt: occurredAt ?? this.occurredAt,
      lotId: lotId ?? this.lotId,
      relatedLotId: relatedLotId ?? this.relatedLotId,
      quantity: quantity ?? this.quantity,
      unitValueCents: unitValueCents ?? this.unitValueCents,
      totalValueCents: totalValueCents ?? this.totalValueCents,
      reference: reference ?? this.reference,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (lotId.present) {
      map['lot_id'] = Variable<String>(lotId.value);
    }
    if (relatedLotId.present) {
      map['related_lot_id'] = Variable<String>(relatedLotId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitValueCents.present) {
      map['unit_value_cents'] = Variable<int>(unitValueCents.value);
    }
    if (totalValueCents.present) {
      map['total_value_cents'] = Variable<int>(totalValueCents.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BirdMovementsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('lotId: $lotId, ')
          ..write('relatedLotId: $relatedLotId, ')
          ..write('quantity: $quantity, ')
          ..write('unitValueCents: $unitValueCents, ')
          ..write('totalValueCents: $totalValueCents, ')
          ..write('reference: $reference, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EggCollectionsTable extends EggCollections
    with TableInfo<$EggCollectionsTable, EggCollection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EggCollectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _collectedOnMeta = const VerificationMeta(
    'collectedOn',
  );
  @override
  late final GeneratedColumn<DateTime> collectedOn = GeneratedColumn<DateTime>(
    'collected_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lotIdMeta = const VerificationMeta('lotId');
  @override
  late final GeneratedColumn<String> lotId = GeneratedColumn<String>(
    'lot_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brokenEggsMeta = const VerificationMeta(
    'brokenEggs',
  );
  @override
  late final GeneratedColumn<int> brokenEggs = GeneratedColumn<int>(
    'broken_eggs',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _discardedEggsMeta = const VerificationMeta(
    'discardedEggs',
  );
  @override
  late final GeneratedColumn<int> discardedEggs = GeneratedColumn<int>(
    'discarded_eggs',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    collectedOn,
    lotId,
    quantity,
    brokenEggs,
    discardedEggs,
    notes,
    createdBy,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'egg_collections';
  @override
  VerificationContext validateIntegrity(
    Insertable<EggCollection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('collected_on')) {
      context.handle(
        _collectedOnMeta,
        collectedOn.isAcceptableOrUnknown(
          data['collected_on']!,
          _collectedOnMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectedOnMeta);
    }
    if (data.containsKey('lot_id')) {
      context.handle(
        _lotIdMeta,
        lotId.isAcceptableOrUnknown(data['lot_id']!, _lotIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lotIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('broken_eggs')) {
      context.handle(
        _brokenEggsMeta,
        brokenEggs.isAcceptableOrUnknown(data['broken_eggs']!, _brokenEggsMeta),
      );
    }
    if (data.containsKey('discarded_eggs')) {
      context.handle(
        _discardedEggsMeta,
        discardedEggs.isAcceptableOrUnknown(
          data['discarded_eggs']!,
          _discardedEggsMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EggCollection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EggCollection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      collectedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}collected_on'],
      )!,
      lotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lot_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      brokenEggs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}broken_eggs'],
      )!,
      discardedEggs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discarded_eggs'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $EggCollectionsTable createAlias(String alias) {
    return $EggCollectionsTable(attachedDatabase, alias);
  }
}

class EggCollection extends DataClass implements Insertable<EggCollection> {
  final String id;
  final DateTime collectedOn;
  final String lotId;
  final int quantity;
  final int brokenEggs;
  final int discardedEggs;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  const EggCollection({
    required this.id,
    required this.collectedOn,
    required this.lotId,
    required this.quantity,
    required this.brokenEggs,
    required this.discardedEggs,
    this.notes,
    required this.createdBy,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['collected_on'] = Variable<DateTime>(collectedOn);
    map['lot_id'] = Variable<String>(lotId);
    map['quantity'] = Variable<int>(quantity);
    map['broken_eggs'] = Variable<int>(brokenEggs);
    map['discarded_eggs'] = Variable<int>(discardedEggs);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_by'] = Variable<String>(createdBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  EggCollectionsCompanion toCompanion(bool nullToAbsent) {
    return EggCollectionsCompanion(
      id: Value(id),
      collectedOn: Value(collectedOn),
      lotId: Value(lotId),
      quantity: Value(quantity),
      brokenEggs: Value(brokenEggs),
      discardedEggs: Value(discardedEggs),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
    );
  }

  factory EggCollection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EggCollection(
      id: serializer.fromJson<String>(json['id']),
      collectedOn: serializer.fromJson<DateTime>(json['collectedOn']),
      lotId: serializer.fromJson<String>(json['lotId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      brokenEggs: serializer.fromJson<int>(json['brokenEggs']),
      discardedEggs: serializer.fromJson<int>(json['discardedEggs']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'collectedOn': serializer.toJson<DateTime>(collectedOn),
      'lotId': serializer.toJson<String>(lotId),
      'quantity': serializer.toJson<int>(quantity),
      'brokenEggs': serializer.toJson<int>(brokenEggs),
      'discardedEggs': serializer.toJson<int>(discardedEggs),
      'notes': serializer.toJson<String?>(notes),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  EggCollection copyWith({
    String? id,
    DateTime? collectedOn,
    String? lotId,
    int? quantity,
    int? brokenEggs,
    int? discardedEggs,
    Value<String?> notes = const Value.absent(),
    String? createdBy,
    DateTime? createdAt,
  }) => EggCollection(
    id: id ?? this.id,
    collectedOn: collectedOn ?? this.collectedOn,
    lotId: lotId ?? this.lotId,
    quantity: quantity ?? this.quantity,
    brokenEggs: brokenEggs ?? this.brokenEggs,
    discardedEggs: discardedEggs ?? this.discardedEggs,
    notes: notes.present ? notes.value : this.notes,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
  );
  EggCollection copyWithCompanion(EggCollectionsCompanion data) {
    return EggCollection(
      id: data.id.present ? data.id.value : this.id,
      collectedOn: data.collectedOn.present
          ? data.collectedOn.value
          : this.collectedOn,
      lotId: data.lotId.present ? data.lotId.value : this.lotId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      brokenEggs: data.brokenEggs.present
          ? data.brokenEggs.value
          : this.brokenEggs,
      discardedEggs: data.discardedEggs.present
          ? data.discardedEggs.value
          : this.discardedEggs,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EggCollection(')
          ..write('id: $id, ')
          ..write('collectedOn: $collectedOn, ')
          ..write('lotId: $lotId, ')
          ..write('quantity: $quantity, ')
          ..write('brokenEggs: $brokenEggs, ')
          ..write('discardedEggs: $discardedEggs, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    collectedOn,
    lotId,
    quantity,
    brokenEggs,
    discardedEggs,
    notes,
    createdBy,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EggCollection &&
          other.id == this.id &&
          other.collectedOn == this.collectedOn &&
          other.lotId == this.lotId &&
          other.quantity == this.quantity &&
          other.brokenEggs == this.brokenEggs &&
          other.discardedEggs == this.discardedEggs &&
          other.notes == this.notes &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt);
}

class EggCollectionsCompanion extends UpdateCompanion<EggCollection> {
  final Value<String> id;
  final Value<DateTime> collectedOn;
  final Value<String> lotId;
  final Value<int> quantity;
  final Value<int> brokenEggs;
  final Value<int> discardedEggs;
  final Value<String?> notes;
  final Value<String> createdBy;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const EggCollectionsCompanion({
    this.id = const Value.absent(),
    this.collectedOn = const Value.absent(),
    this.lotId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.brokenEggs = const Value.absent(),
    this.discardedEggs = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EggCollectionsCompanion.insert({
    required String id,
    required DateTime collectedOn,
    required String lotId,
    required int quantity,
    this.brokenEggs = const Value.absent(),
    this.discardedEggs = const Value.absent(),
    this.notes = const Value.absent(),
    required String createdBy,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       collectedOn = Value(collectedOn),
       lotId = Value(lotId),
       quantity = Value(quantity),
       createdBy = Value(createdBy),
       createdAt = Value(createdAt);
  static Insertable<EggCollection> custom({
    Expression<String>? id,
    Expression<DateTime>? collectedOn,
    Expression<String>? lotId,
    Expression<int>? quantity,
    Expression<int>? brokenEggs,
    Expression<int>? discardedEggs,
    Expression<String>? notes,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (collectedOn != null) 'collected_on': collectedOn,
      if (lotId != null) 'lot_id': lotId,
      if (quantity != null) 'quantity': quantity,
      if (brokenEggs != null) 'broken_eggs': brokenEggs,
      if (discardedEggs != null) 'discarded_eggs': discardedEggs,
      if (notes != null) 'notes': notes,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EggCollectionsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? collectedOn,
    Value<String>? lotId,
    Value<int>? quantity,
    Value<int>? brokenEggs,
    Value<int>? discardedEggs,
    Value<String?>? notes,
    Value<String>? createdBy,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return EggCollectionsCompanion(
      id: id ?? this.id,
      collectedOn: collectedOn ?? this.collectedOn,
      lotId: lotId ?? this.lotId,
      quantity: quantity ?? this.quantity,
      brokenEggs: brokenEggs ?? this.brokenEggs,
      discardedEggs: discardedEggs ?? this.discardedEggs,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (collectedOn.present) {
      map['collected_on'] = Variable<DateTime>(collectedOn.value);
    }
    if (lotId.present) {
      map['lot_id'] = Variable<String>(lotId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (brokenEggs.present) {
      map['broken_eggs'] = Variable<int>(brokenEggs.value);
    }
    if (discardedEggs.present) {
      map['discarded_eggs'] = Variable<int>(discardedEggs.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EggCollectionsCompanion(')
          ..write('id: $id, ')
          ..write('collectedOn: $collectedOn, ')
          ..write('lotId: $lotId, ')
          ..write('quantity: $quantity, ')
          ..write('brokenEggs: $brokenEggs, ')
          ..write('discardedEggs: $discardedEggs, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EggStockMovementsTable extends EggStockMovements
    with TableInfo<$EggStockMovementsTable, EggStockMovement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EggStockMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  @override
  late final GeneratedColumn<String> collectionId = GeneratedColumn<String>(
    'collection_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    occurredAt,
    quantity,
    collectionId,
    reference,
    notes,
    createdBy,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'egg_stock_movements';
  @override
  VerificationContext validateIntegrity(
    Insertable<EggStockMovement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EggStockMovement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EggStockMovement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_id'],
      ),
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $EggStockMovementsTable createAlias(String alias) {
    return $EggStockMovementsTable(attachedDatabase, alias);
  }
}

class EggStockMovement extends DataClass
    implements Insertable<EggStockMovement> {
  final String id;
  final String type;
  final DateTime occurredAt;
  final int quantity;
  final String? collectionId;
  final String? reference;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  const EggStockMovement({
    required this.id,
    required this.type,
    required this.occurredAt,
    required this.quantity,
    this.collectionId,
    this.reference,
    this.notes,
    required this.createdBy,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['quantity'] = Variable<int>(quantity);
    if (!nullToAbsent || collectionId != null) {
      map['collection_id'] = Variable<String>(collectionId);
    }
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(reference);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_by'] = Variable<String>(createdBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  EggStockMovementsCompanion toCompanion(bool nullToAbsent) {
    return EggStockMovementsCompanion(
      id: Value(id),
      type: Value(type),
      occurredAt: Value(occurredAt),
      quantity: Value(quantity),
      collectionId: collectionId == null && nullToAbsent
          ? const Value.absent()
          : Value(collectionId),
      reference: reference == null && nullToAbsent
          ? const Value.absent()
          : Value(reference),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
    );
  }

  factory EggStockMovement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EggStockMovement(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      quantity: serializer.fromJson<int>(json['quantity']),
      collectionId: serializer.fromJson<String?>(json['collectionId']),
      reference: serializer.fromJson<String?>(json['reference']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'quantity': serializer.toJson<int>(quantity),
      'collectionId': serializer.toJson<String?>(collectionId),
      'reference': serializer.toJson<String?>(reference),
      'notes': serializer.toJson<String?>(notes),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  EggStockMovement copyWith({
    String? id,
    String? type,
    DateTime? occurredAt,
    int? quantity,
    Value<String?> collectionId = const Value.absent(),
    Value<String?> reference = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    String? createdBy,
    DateTime? createdAt,
  }) => EggStockMovement(
    id: id ?? this.id,
    type: type ?? this.type,
    occurredAt: occurredAt ?? this.occurredAt,
    quantity: quantity ?? this.quantity,
    collectionId: collectionId.present ? collectionId.value : this.collectionId,
    reference: reference.present ? reference.value : this.reference,
    notes: notes.present ? notes.value : this.notes,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
  );
  EggStockMovement copyWithCompanion(EggStockMovementsCompanion data) {
    return EggStockMovement(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      reference: data.reference.present ? data.reference.value : this.reference,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EggStockMovement(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('quantity: $quantity, ')
          ..write('collectionId: $collectionId, ')
          ..write('reference: $reference, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    occurredAt,
    quantity,
    collectionId,
    reference,
    notes,
    createdBy,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EggStockMovement &&
          other.id == this.id &&
          other.type == this.type &&
          other.occurredAt == this.occurredAt &&
          other.quantity == this.quantity &&
          other.collectionId == this.collectionId &&
          other.reference == this.reference &&
          other.notes == this.notes &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt);
}

class EggStockMovementsCompanion extends UpdateCompanion<EggStockMovement> {
  final Value<String> id;
  final Value<String> type;
  final Value<DateTime> occurredAt;
  final Value<int> quantity;
  final Value<String?> collectionId;
  final Value<String?> reference;
  final Value<String?> notes;
  final Value<String> createdBy;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const EggStockMovementsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.quantity = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.reference = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EggStockMovementsCompanion.insert({
    required String id,
    required String type,
    required DateTime occurredAt,
    required int quantity,
    this.collectionId = const Value.absent(),
    this.reference = const Value.absent(),
    this.notes = const Value.absent(),
    required String createdBy,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       occurredAt = Value(occurredAt),
       quantity = Value(quantity),
       createdBy = Value(createdBy),
       createdAt = Value(createdAt);
  static Insertable<EggStockMovement> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<DateTime>? occurredAt,
    Expression<int>? quantity,
    Expression<String>? collectionId,
    Expression<String>? reference,
    Expression<String>? notes,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (quantity != null) 'quantity': quantity,
      if (collectionId != null) 'collection_id': collectionId,
      if (reference != null) 'reference': reference,
      if (notes != null) 'notes': notes,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EggStockMovementsCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<DateTime>? occurredAt,
    Value<int>? quantity,
    Value<String?>? collectionId,
    Value<String?>? reference,
    Value<String?>? notes,
    Value<String>? createdBy,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return EggStockMovementsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      occurredAt: occurredAt ?? this.occurredAt,
      quantity: quantity ?? this.quantity,
      collectionId: collectionId ?? this.collectionId,
      reference: reference ?? this.reference,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<String>(collectionId.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EggStockMovementsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('quantity: $quantity, ')
          ..write('collectionId: $collectionId, ')
          ..write('reference: $reference, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IngredientsTable extends Ingredients
    with TableInfo<$IngredientsTable, Ingredient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('kg'),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    unit,
    isActive,
    notes,
    createdAt,
    createdBy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ingredients';
  @override
  VerificationContext validateIntegrity(
    Insertable<Ingredient> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Ingredient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Ingredient(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
    );
  }

  @override
  $IngredientsTable createAlias(String alias) {
    return $IngredientsTable(attachedDatabase, alias);
  }
}

class Ingredient extends DataClass implements Insertable<Ingredient> {
  final String id;
  final String name;
  final String unit;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;
  final String createdBy;
  const Ingredient({
    required this.id,
    required this.name,
    required this.unit,
    required this.isActive,
    this.notes,
    required this.createdAt,
    required this.createdBy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['unit'] = Variable<String>(unit);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['created_by'] = Variable<String>(createdBy);
    return map;
  }

  IngredientsCompanion toCompanion(bool nullToAbsent) {
    return IngredientsCompanion(
      id: Value(id),
      name: Value(name),
      unit: Value(unit),
      isActive: Value(isActive),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      createdBy: Value(createdBy),
    );
  }

  factory Ingredient.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Ingredient(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      unit: serializer.fromJson<String>(json['unit']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'unit': serializer.toJson<String>(unit),
      'isActive': serializer.toJson<bool>(isActive),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'createdBy': serializer.toJson<String>(createdBy),
    };
  }

  Ingredient copyWith({
    String? id,
    String? name,
    String? unit,
    bool? isActive,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    String? createdBy,
  }) => Ingredient(
    id: id ?? this.id,
    name: name ?? this.name,
    unit: unit ?? this.unit,
    isActive: isActive ?? this.isActive,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    createdBy: createdBy ?? this.createdBy,
  );
  Ingredient copyWithCompanion(IngredientsCompanion data) {
    return Ingredient(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      unit: data.unit.present ? data.unit.value : this.unit,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Ingredient(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('isActive: $isActive, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, unit, isActive, notes, createdAt, createdBy);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ingredient &&
          other.id == this.id &&
          other.name == this.name &&
          other.unit == this.unit &&
          other.isActive == this.isActive &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy);
}

class IngredientsCompanion extends UpdateCompanion<Ingredient> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> unit;
  final Value<bool> isActive;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<String> createdBy;
  final Value<int> rowid;
  const IngredientsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.unit = const Value.absent(),
    this.isActive = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IngredientsCompanion.insert({
    required String id,
    required String name,
    this.unit = const Value.absent(),
    this.isActive = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required String createdBy,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       createdBy = Value(createdBy);
  static Insertable<Ingredient> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? unit,
    Expression<bool>? isActive,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<String>? createdBy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (unit != null) 'unit': unit,
      if (isActive != null) 'is_active': isActive,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (createdBy != null) 'created_by': createdBy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IngredientsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? unit,
    Value<bool>? isActive,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<String>? createdBy,
    Value<int>? rowid,
  }) {
    return IngredientsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IngredientsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('isActive: $isActive, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IngredientPriceHistoryTable extends IngredientPriceHistory
    with TableInfo<$IngredientPriceHistoryTable, IngredientPriceHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IngredientPriceHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ingredientIdMeta = const VerificationMeta(
    'ingredientId',
  );
  @override
  late final GeneratedColumn<String> ingredientId = GeneratedColumn<String>(
    'ingredient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pricePerKgCentsMeta = const VerificationMeta(
    'pricePerKgCents',
  );
  @override
  late final GeneratedColumn<int> pricePerKgCents = GeneratedColumn<int>(
    'price_per_kg_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _effectiveDateMeta = const VerificationMeta(
    'effectiveDate',
  );
  @override
  late final GeneratedColumn<DateTime> effectiveDate =
      GeneratedColumn<DateTime>(
        'effective_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _supplierMeta = const VerificationMeta(
    'supplier',
  );
  @override
  late final GeneratedColumn<String> supplier = GeneratedColumn<String>(
    'supplier',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ingredientId,
    pricePerKgCents,
    effectiveDate,
    supplier,
    notes,
    createdBy,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ingredient_price_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<IngredientPriceHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('ingredient_id')) {
      context.handle(
        _ingredientIdMeta,
        ingredientId.isAcceptableOrUnknown(
          data['ingredient_id']!,
          _ingredientIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ingredientIdMeta);
    }
    if (data.containsKey('price_per_kg_cents')) {
      context.handle(
        _pricePerKgCentsMeta,
        pricePerKgCents.isAcceptableOrUnknown(
          data['price_per_kg_cents']!,
          _pricePerKgCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pricePerKgCentsMeta);
    }
    if (data.containsKey('effective_date')) {
      context.handle(
        _effectiveDateMeta,
        effectiveDate.isAcceptableOrUnknown(
          data['effective_date']!,
          _effectiveDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_effectiveDateMeta);
    }
    if (data.containsKey('supplier')) {
      context.handle(
        _supplierMeta,
        supplier.isAcceptableOrUnknown(data['supplier']!, _supplierMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IngredientPriceHistoryData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IngredientPriceHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ingredientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingredient_id'],
      )!,
      pricePerKgCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_per_kg_cents'],
      )!,
      effectiveDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}effective_date'],
      )!,
      supplier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $IngredientPriceHistoryTable createAlias(String alias) {
    return $IngredientPriceHistoryTable(attachedDatabase, alias);
  }
}

class IngredientPriceHistoryData extends DataClass
    implements Insertable<IngredientPriceHistoryData> {
  final String id;
  final String ingredientId;
  final int pricePerKgCents;
  final DateTime effectiveDate;
  final String? supplier;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  const IngredientPriceHistoryData({
    required this.id,
    required this.ingredientId,
    required this.pricePerKgCents,
    required this.effectiveDate,
    this.supplier,
    this.notes,
    required this.createdBy,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['ingredient_id'] = Variable<String>(ingredientId);
    map['price_per_kg_cents'] = Variable<int>(pricePerKgCents);
    map['effective_date'] = Variable<DateTime>(effectiveDate);
    if (!nullToAbsent || supplier != null) {
      map['supplier'] = Variable<String>(supplier);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_by'] = Variable<String>(createdBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  IngredientPriceHistoryCompanion toCompanion(bool nullToAbsent) {
    return IngredientPriceHistoryCompanion(
      id: Value(id),
      ingredientId: Value(ingredientId),
      pricePerKgCents: Value(pricePerKgCents),
      effectiveDate: Value(effectiveDate),
      supplier: supplier == null && nullToAbsent
          ? const Value.absent()
          : Value(supplier),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
    );
  }

  factory IngredientPriceHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IngredientPriceHistoryData(
      id: serializer.fromJson<String>(json['id']),
      ingredientId: serializer.fromJson<String>(json['ingredientId']),
      pricePerKgCents: serializer.fromJson<int>(json['pricePerKgCents']),
      effectiveDate: serializer.fromJson<DateTime>(json['effectiveDate']),
      supplier: serializer.fromJson<String?>(json['supplier']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ingredientId': serializer.toJson<String>(ingredientId),
      'pricePerKgCents': serializer.toJson<int>(pricePerKgCents),
      'effectiveDate': serializer.toJson<DateTime>(effectiveDate),
      'supplier': serializer.toJson<String?>(supplier),
      'notes': serializer.toJson<String?>(notes),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  IngredientPriceHistoryData copyWith({
    String? id,
    String? ingredientId,
    int? pricePerKgCents,
    DateTime? effectiveDate,
    Value<String?> supplier = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    String? createdBy,
    DateTime? createdAt,
  }) => IngredientPriceHistoryData(
    id: id ?? this.id,
    ingredientId: ingredientId ?? this.ingredientId,
    pricePerKgCents: pricePerKgCents ?? this.pricePerKgCents,
    effectiveDate: effectiveDate ?? this.effectiveDate,
    supplier: supplier.present ? supplier.value : this.supplier,
    notes: notes.present ? notes.value : this.notes,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
  );
  IngredientPriceHistoryData copyWithCompanion(
    IngredientPriceHistoryCompanion data,
  ) {
    return IngredientPriceHistoryData(
      id: data.id.present ? data.id.value : this.id,
      ingredientId: data.ingredientId.present
          ? data.ingredientId.value
          : this.ingredientId,
      pricePerKgCents: data.pricePerKgCents.present
          ? data.pricePerKgCents.value
          : this.pricePerKgCents,
      effectiveDate: data.effectiveDate.present
          ? data.effectiveDate.value
          : this.effectiveDate,
      supplier: data.supplier.present ? data.supplier.value : this.supplier,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IngredientPriceHistoryData(')
          ..write('id: $id, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('pricePerKgCents: $pricePerKgCents, ')
          ..write('effectiveDate: $effectiveDate, ')
          ..write('supplier: $supplier, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ingredientId,
    pricePerKgCents,
    effectiveDate,
    supplier,
    notes,
    createdBy,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IngredientPriceHistoryData &&
          other.id == this.id &&
          other.ingredientId == this.ingredientId &&
          other.pricePerKgCents == this.pricePerKgCents &&
          other.effectiveDate == this.effectiveDate &&
          other.supplier == this.supplier &&
          other.notes == this.notes &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt);
}

class IngredientPriceHistoryCompanion
    extends UpdateCompanion<IngredientPriceHistoryData> {
  final Value<String> id;
  final Value<String> ingredientId;
  final Value<int> pricePerKgCents;
  final Value<DateTime> effectiveDate;
  final Value<String?> supplier;
  final Value<String?> notes;
  final Value<String> createdBy;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const IngredientPriceHistoryCompanion({
    this.id = const Value.absent(),
    this.ingredientId = const Value.absent(),
    this.pricePerKgCents = const Value.absent(),
    this.effectiveDate = const Value.absent(),
    this.supplier = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IngredientPriceHistoryCompanion.insert({
    required String id,
    required String ingredientId,
    required int pricePerKgCents,
    required DateTime effectiveDate,
    this.supplier = const Value.absent(),
    this.notes = const Value.absent(),
    required String createdBy,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ingredientId = Value(ingredientId),
       pricePerKgCents = Value(pricePerKgCents),
       effectiveDate = Value(effectiveDate),
       createdBy = Value(createdBy),
       createdAt = Value(createdAt);
  static Insertable<IngredientPriceHistoryData> custom({
    Expression<String>? id,
    Expression<String>? ingredientId,
    Expression<int>? pricePerKgCents,
    Expression<DateTime>? effectiveDate,
    Expression<String>? supplier,
    Expression<String>? notes,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ingredientId != null) 'ingredient_id': ingredientId,
      if (pricePerKgCents != null) 'price_per_kg_cents': pricePerKgCents,
      if (effectiveDate != null) 'effective_date': effectiveDate,
      if (supplier != null) 'supplier': supplier,
      if (notes != null) 'notes': notes,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IngredientPriceHistoryCompanion copyWith({
    Value<String>? id,
    Value<String>? ingredientId,
    Value<int>? pricePerKgCents,
    Value<DateTime>? effectiveDate,
    Value<String?>? supplier,
    Value<String?>? notes,
    Value<String>? createdBy,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return IngredientPriceHistoryCompanion(
      id: id ?? this.id,
      ingredientId: ingredientId ?? this.ingredientId,
      pricePerKgCents: pricePerKgCents ?? this.pricePerKgCents,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      supplier: supplier ?? this.supplier,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ingredientId.present) {
      map['ingredient_id'] = Variable<String>(ingredientId.value);
    }
    if (pricePerKgCents.present) {
      map['price_per_kg_cents'] = Variable<int>(pricePerKgCents.value);
    }
    if (effectiveDate.present) {
      map['effective_date'] = Variable<DateTime>(effectiveDate.value);
    }
    if (supplier.present) {
      map['supplier'] = Variable<String>(supplier.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IngredientPriceHistoryCompanion(')
          ..write('id: $id, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('pricePerKgCents: $pricePerKgCents, ')
          ..write('effectiveDate: $effectiveDate, ')
          ..write('supplier: $supplier, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IngredientLotsTable extends IngredientLots
    with TableInfo<$IngredientLotsTable, IngredientLot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IngredientLotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ingredientIdMeta = const VerificationMeta(
    'ingredientId',
  );
  @override
  late final GeneratedColumn<String> ingredientId = GeneratedColumn<String>(
    'ingredient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _entryDateMeta = const VerificationMeta(
    'entryDate',
  );
  @override
  late final GeneratedColumn<DateTime> entryDate = GeneratedColumn<DateTime>(
    'entry_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _initialQuantityKgMeta = const VerificationMeta(
    'initialQuantityKg',
  );
  @override
  late final GeneratedColumn<double> initialQuantityKg =
      GeneratedColumn<double>(
        'initial_quantity_kg',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _packageUnitMeta = const VerificationMeta(
    'packageUnit',
  );
  @override
  late final GeneratedColumn<String> packageUnit = GeneratedColumn<String>(
    'package_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('KG'),
  );
  static const VerificationMeta _packageQuantityMeta = const VerificationMeta(
    'packageQuantity',
  );
  @override
  late final GeneratedColumn<double> packageQuantity = GeneratedColumn<double>(
    'package_quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _packageWeightKgMeta = const VerificationMeta(
    'packageWeightKg',
  );
  @override
  late final GeneratedColumn<double> packageWeightKg = GeneratedColumn<double>(
    'package_weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _totalCostCentsMeta = const VerificationMeta(
    'totalCostCents',
  );
  @override
  late final GeneratedColumn<int> totalCostCents = GeneratedColumn<int>(
    'total_cost_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pricePerKgCentsMeta = const VerificationMeta(
    'pricePerKgCents',
  );
  @override
  late final GeneratedColumn<int> pricePerKgCents = GeneratedColumn<int>(
    'price_per_kg_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supplierMeta = const VerificationMeta(
    'supplier',
  );
  @override
  late final GeneratedColumn<String> supplier = GeneratedColumn<String>(
    'supplier',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ingredientId,
    code,
    entryDate,
    initialQuantityKg,
    packageUnit,
    packageQuantity,
    packageWeightKg,
    totalCostCents,
    pricePerKgCents,
    supplier,
    notes,
    createdBy,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ingredient_lots';
  @override
  VerificationContext validateIntegrity(
    Insertable<IngredientLot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('ingredient_id')) {
      context.handle(
        _ingredientIdMeta,
        ingredientId.isAcceptableOrUnknown(
          data['ingredient_id']!,
          _ingredientIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ingredientIdMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('entry_date')) {
      context.handle(
        _entryDateMeta,
        entryDate.isAcceptableOrUnknown(data['entry_date']!, _entryDateMeta),
      );
    } else if (isInserting) {
      context.missing(_entryDateMeta);
    }
    if (data.containsKey('initial_quantity_kg')) {
      context.handle(
        _initialQuantityKgMeta,
        initialQuantityKg.isAcceptableOrUnknown(
          data['initial_quantity_kg']!,
          _initialQuantityKgMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_initialQuantityKgMeta);
    }
    if (data.containsKey('package_unit')) {
      context.handle(
        _packageUnitMeta,
        packageUnit.isAcceptableOrUnknown(
          data['package_unit']!,
          _packageUnitMeta,
        ),
      );
    }
    if (data.containsKey('package_quantity')) {
      context.handle(
        _packageQuantityMeta,
        packageQuantity.isAcceptableOrUnknown(
          data['package_quantity']!,
          _packageQuantityMeta,
        ),
      );
    }
    if (data.containsKey('package_weight_kg')) {
      context.handle(
        _packageWeightKgMeta,
        packageWeightKg.isAcceptableOrUnknown(
          data['package_weight_kg']!,
          _packageWeightKgMeta,
        ),
      );
    }
    if (data.containsKey('total_cost_cents')) {
      context.handle(
        _totalCostCentsMeta,
        totalCostCents.isAcceptableOrUnknown(
          data['total_cost_cents']!,
          _totalCostCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalCostCentsMeta);
    }
    if (data.containsKey('price_per_kg_cents')) {
      context.handle(
        _pricePerKgCentsMeta,
        pricePerKgCents.isAcceptableOrUnknown(
          data['price_per_kg_cents']!,
          _pricePerKgCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pricePerKgCentsMeta);
    }
    if (data.containsKey('supplier')) {
      context.handle(
        _supplierMeta,
        supplier.isAcceptableOrUnknown(data['supplier']!, _supplierMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IngredientLot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IngredientLot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ingredientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingredient_id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      entryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}entry_date'],
      )!,
      initialQuantityKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}initial_quantity_kg'],
      )!,
      packageUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_unit'],
      )!,
      packageQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}package_quantity'],
      )!,
      packageWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}package_weight_kg'],
      )!,
      totalCostCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_cost_cents'],
      )!,
      pricePerKgCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_per_kg_cents'],
      )!,
      supplier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $IngredientLotsTable createAlias(String alias) {
    return $IngredientLotsTable(attachedDatabase, alias);
  }
}

class IngredientLot extends DataClass implements Insertable<IngredientLot> {
  final String id;
  final String ingredientId;
  final String code;
  final DateTime entryDate;
  final double initialQuantityKg;
  final String packageUnit;
  final double packageQuantity;
  final double packageWeightKg;
  final int totalCostCents;
  final int pricePerKgCents;
  final String? supplier;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  const IngredientLot({
    required this.id,
    required this.ingredientId,
    required this.code,
    required this.entryDate,
    required this.initialQuantityKg,
    required this.packageUnit,
    required this.packageQuantity,
    required this.packageWeightKg,
    required this.totalCostCents,
    required this.pricePerKgCents,
    this.supplier,
    this.notes,
    required this.createdBy,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['ingredient_id'] = Variable<String>(ingredientId);
    map['code'] = Variable<String>(code);
    map['entry_date'] = Variable<DateTime>(entryDate);
    map['initial_quantity_kg'] = Variable<double>(initialQuantityKg);
    map['package_unit'] = Variable<String>(packageUnit);
    map['package_quantity'] = Variable<double>(packageQuantity);
    map['package_weight_kg'] = Variable<double>(packageWeightKg);
    map['total_cost_cents'] = Variable<int>(totalCostCents);
    map['price_per_kg_cents'] = Variable<int>(pricePerKgCents);
    if (!nullToAbsent || supplier != null) {
      map['supplier'] = Variable<String>(supplier);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_by'] = Variable<String>(createdBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  IngredientLotsCompanion toCompanion(bool nullToAbsent) {
    return IngredientLotsCompanion(
      id: Value(id),
      ingredientId: Value(ingredientId),
      code: Value(code),
      entryDate: Value(entryDate),
      initialQuantityKg: Value(initialQuantityKg),
      packageUnit: Value(packageUnit),
      packageQuantity: Value(packageQuantity),
      packageWeightKg: Value(packageWeightKg),
      totalCostCents: Value(totalCostCents),
      pricePerKgCents: Value(pricePerKgCents),
      supplier: supplier == null && nullToAbsent
          ? const Value.absent()
          : Value(supplier),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
    );
  }

  factory IngredientLot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IngredientLot(
      id: serializer.fromJson<String>(json['id']),
      ingredientId: serializer.fromJson<String>(json['ingredientId']),
      code: serializer.fromJson<String>(json['code']),
      entryDate: serializer.fromJson<DateTime>(json['entryDate']),
      initialQuantityKg: serializer.fromJson<double>(json['initialQuantityKg']),
      packageUnit: serializer.fromJson<String>(json['packageUnit']),
      packageQuantity: serializer.fromJson<double>(json['packageQuantity']),
      packageWeightKg: serializer.fromJson<double>(json['packageWeightKg']),
      totalCostCents: serializer.fromJson<int>(json['totalCostCents']),
      pricePerKgCents: serializer.fromJson<int>(json['pricePerKgCents']),
      supplier: serializer.fromJson<String?>(json['supplier']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ingredientId': serializer.toJson<String>(ingredientId),
      'code': serializer.toJson<String>(code),
      'entryDate': serializer.toJson<DateTime>(entryDate),
      'initialQuantityKg': serializer.toJson<double>(initialQuantityKg),
      'packageUnit': serializer.toJson<String>(packageUnit),
      'packageQuantity': serializer.toJson<double>(packageQuantity),
      'packageWeightKg': serializer.toJson<double>(packageWeightKg),
      'totalCostCents': serializer.toJson<int>(totalCostCents),
      'pricePerKgCents': serializer.toJson<int>(pricePerKgCents),
      'supplier': serializer.toJson<String?>(supplier),
      'notes': serializer.toJson<String?>(notes),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  IngredientLot copyWith({
    String? id,
    String? ingredientId,
    String? code,
    DateTime? entryDate,
    double? initialQuantityKg,
    String? packageUnit,
    double? packageQuantity,
    double? packageWeightKg,
    int? totalCostCents,
    int? pricePerKgCents,
    Value<String?> supplier = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    String? createdBy,
    DateTime? createdAt,
  }) => IngredientLot(
    id: id ?? this.id,
    ingredientId: ingredientId ?? this.ingredientId,
    code: code ?? this.code,
    entryDate: entryDate ?? this.entryDate,
    initialQuantityKg: initialQuantityKg ?? this.initialQuantityKg,
    packageUnit: packageUnit ?? this.packageUnit,
    packageQuantity: packageQuantity ?? this.packageQuantity,
    packageWeightKg: packageWeightKg ?? this.packageWeightKg,
    totalCostCents: totalCostCents ?? this.totalCostCents,
    pricePerKgCents: pricePerKgCents ?? this.pricePerKgCents,
    supplier: supplier.present ? supplier.value : this.supplier,
    notes: notes.present ? notes.value : this.notes,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
  );
  IngredientLot copyWithCompanion(IngredientLotsCompanion data) {
    return IngredientLot(
      id: data.id.present ? data.id.value : this.id,
      ingredientId: data.ingredientId.present
          ? data.ingredientId.value
          : this.ingredientId,
      code: data.code.present ? data.code.value : this.code,
      entryDate: data.entryDate.present ? data.entryDate.value : this.entryDate,
      initialQuantityKg: data.initialQuantityKg.present
          ? data.initialQuantityKg.value
          : this.initialQuantityKg,
      packageUnit: data.packageUnit.present
          ? data.packageUnit.value
          : this.packageUnit,
      packageQuantity: data.packageQuantity.present
          ? data.packageQuantity.value
          : this.packageQuantity,
      packageWeightKg: data.packageWeightKg.present
          ? data.packageWeightKg.value
          : this.packageWeightKg,
      totalCostCents: data.totalCostCents.present
          ? data.totalCostCents.value
          : this.totalCostCents,
      pricePerKgCents: data.pricePerKgCents.present
          ? data.pricePerKgCents.value
          : this.pricePerKgCents,
      supplier: data.supplier.present ? data.supplier.value : this.supplier,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IngredientLot(')
          ..write('id: $id, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('code: $code, ')
          ..write('entryDate: $entryDate, ')
          ..write('initialQuantityKg: $initialQuantityKg, ')
          ..write('packageUnit: $packageUnit, ')
          ..write('packageQuantity: $packageQuantity, ')
          ..write('packageWeightKg: $packageWeightKg, ')
          ..write('totalCostCents: $totalCostCents, ')
          ..write('pricePerKgCents: $pricePerKgCents, ')
          ..write('supplier: $supplier, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ingredientId,
    code,
    entryDate,
    initialQuantityKg,
    packageUnit,
    packageQuantity,
    packageWeightKg,
    totalCostCents,
    pricePerKgCents,
    supplier,
    notes,
    createdBy,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IngredientLot &&
          other.id == this.id &&
          other.ingredientId == this.ingredientId &&
          other.code == this.code &&
          other.entryDate == this.entryDate &&
          other.initialQuantityKg == this.initialQuantityKg &&
          other.packageUnit == this.packageUnit &&
          other.packageQuantity == this.packageQuantity &&
          other.packageWeightKg == this.packageWeightKg &&
          other.totalCostCents == this.totalCostCents &&
          other.pricePerKgCents == this.pricePerKgCents &&
          other.supplier == this.supplier &&
          other.notes == this.notes &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt);
}

class IngredientLotsCompanion extends UpdateCompanion<IngredientLot> {
  final Value<String> id;
  final Value<String> ingredientId;
  final Value<String> code;
  final Value<DateTime> entryDate;
  final Value<double> initialQuantityKg;
  final Value<String> packageUnit;
  final Value<double> packageQuantity;
  final Value<double> packageWeightKg;
  final Value<int> totalCostCents;
  final Value<int> pricePerKgCents;
  final Value<String?> supplier;
  final Value<String?> notes;
  final Value<String> createdBy;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const IngredientLotsCompanion({
    this.id = const Value.absent(),
    this.ingredientId = const Value.absent(),
    this.code = const Value.absent(),
    this.entryDate = const Value.absent(),
    this.initialQuantityKg = const Value.absent(),
    this.packageUnit = const Value.absent(),
    this.packageQuantity = const Value.absent(),
    this.packageWeightKg = const Value.absent(),
    this.totalCostCents = const Value.absent(),
    this.pricePerKgCents = const Value.absent(),
    this.supplier = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IngredientLotsCompanion.insert({
    required String id,
    required String ingredientId,
    required String code,
    required DateTime entryDate,
    required double initialQuantityKg,
    this.packageUnit = const Value.absent(),
    this.packageQuantity = const Value.absent(),
    this.packageWeightKg = const Value.absent(),
    required int totalCostCents,
    required int pricePerKgCents,
    this.supplier = const Value.absent(),
    this.notes = const Value.absent(),
    required String createdBy,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ingredientId = Value(ingredientId),
       code = Value(code),
       entryDate = Value(entryDate),
       initialQuantityKg = Value(initialQuantityKg),
       totalCostCents = Value(totalCostCents),
       pricePerKgCents = Value(pricePerKgCents),
       createdBy = Value(createdBy),
       createdAt = Value(createdAt);
  static Insertable<IngredientLot> custom({
    Expression<String>? id,
    Expression<String>? ingredientId,
    Expression<String>? code,
    Expression<DateTime>? entryDate,
    Expression<double>? initialQuantityKg,
    Expression<String>? packageUnit,
    Expression<double>? packageQuantity,
    Expression<double>? packageWeightKg,
    Expression<int>? totalCostCents,
    Expression<int>? pricePerKgCents,
    Expression<String>? supplier,
    Expression<String>? notes,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ingredientId != null) 'ingredient_id': ingredientId,
      if (code != null) 'code': code,
      if (entryDate != null) 'entry_date': entryDate,
      if (initialQuantityKg != null) 'initial_quantity_kg': initialQuantityKg,
      if (packageUnit != null) 'package_unit': packageUnit,
      if (packageQuantity != null) 'package_quantity': packageQuantity,
      if (packageWeightKg != null) 'package_weight_kg': packageWeightKg,
      if (totalCostCents != null) 'total_cost_cents': totalCostCents,
      if (pricePerKgCents != null) 'price_per_kg_cents': pricePerKgCents,
      if (supplier != null) 'supplier': supplier,
      if (notes != null) 'notes': notes,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IngredientLotsCompanion copyWith({
    Value<String>? id,
    Value<String>? ingredientId,
    Value<String>? code,
    Value<DateTime>? entryDate,
    Value<double>? initialQuantityKg,
    Value<String>? packageUnit,
    Value<double>? packageQuantity,
    Value<double>? packageWeightKg,
    Value<int>? totalCostCents,
    Value<int>? pricePerKgCents,
    Value<String?>? supplier,
    Value<String?>? notes,
    Value<String>? createdBy,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return IngredientLotsCompanion(
      id: id ?? this.id,
      ingredientId: ingredientId ?? this.ingredientId,
      code: code ?? this.code,
      entryDate: entryDate ?? this.entryDate,
      initialQuantityKg: initialQuantityKg ?? this.initialQuantityKg,
      packageUnit: packageUnit ?? this.packageUnit,
      packageQuantity: packageQuantity ?? this.packageQuantity,
      packageWeightKg: packageWeightKg ?? this.packageWeightKg,
      totalCostCents: totalCostCents ?? this.totalCostCents,
      pricePerKgCents: pricePerKgCents ?? this.pricePerKgCents,
      supplier: supplier ?? this.supplier,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ingredientId.present) {
      map['ingredient_id'] = Variable<String>(ingredientId.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (entryDate.present) {
      map['entry_date'] = Variable<DateTime>(entryDate.value);
    }
    if (initialQuantityKg.present) {
      map['initial_quantity_kg'] = Variable<double>(initialQuantityKg.value);
    }
    if (packageUnit.present) {
      map['package_unit'] = Variable<String>(packageUnit.value);
    }
    if (packageQuantity.present) {
      map['package_quantity'] = Variable<double>(packageQuantity.value);
    }
    if (packageWeightKg.present) {
      map['package_weight_kg'] = Variable<double>(packageWeightKg.value);
    }
    if (totalCostCents.present) {
      map['total_cost_cents'] = Variable<int>(totalCostCents.value);
    }
    if (pricePerKgCents.present) {
      map['price_per_kg_cents'] = Variable<int>(pricePerKgCents.value);
    }
    if (supplier.present) {
      map['supplier'] = Variable<String>(supplier.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IngredientLotsCompanion(')
          ..write('id: $id, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('code: $code, ')
          ..write('entryDate: $entryDate, ')
          ..write('initialQuantityKg: $initialQuantityKg, ')
          ..write('packageUnit: $packageUnit, ')
          ..write('packageQuantity: $packageQuantity, ')
          ..write('packageWeightKg: $packageWeightKg, ')
          ..write('totalCostCents: $totalCostCents, ')
          ..write('pricePerKgCents: $pricePerKgCents, ')
          ..write('supplier: $supplier, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IngredientStockMovementsTable extends IngredientStockMovements
    with TableInfo<$IngredientStockMovementsTable, IngredientStockMovement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IngredientStockMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ingredientIdMeta = const VerificationMeta(
    'ingredientId',
  );
  @override
  late final GeneratedColumn<String> ingredientId = GeneratedColumn<String>(
    'ingredient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ingredientLotIdMeta = const VerificationMeta(
    'ingredientLotId',
  );
  @override
  late final GeneratedColumn<String> ingredientLotId = GeneratedColumn<String>(
    'ingredient_lot_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityKgMeta = const VerificationMeta(
    'quantityKg',
  );
  @override
  late final GeneratedColumn<double> quantityKg = GeneratedColumn<double>(
    'quantity_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pricePerKgCentsSnapshotMeta =
      const VerificationMeta('pricePerKgCentsSnapshot');
  @override
  late final GeneratedColumn<int> pricePerKgCentsSnapshot =
      GeneratedColumn<int>(
        'price_per_kg_cents_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _totalCostCentsMeta = const VerificationMeta(
    'totalCostCents',
  );
  @override
  late final GeneratedColumn<int> totalCostCents = GeneratedColumn<int>(
    'total_cost_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceTypeMeta = const VerificationMeta(
    'referenceType',
  );
  @override
  late final GeneratedColumn<String> referenceType = GeneratedColumn<String>(
    'reference_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceIdMeta = const VerificationMeta(
    'referenceId',
  );
  @override
  late final GeneratedColumn<String> referenceId = GeneratedColumn<String>(
    'reference_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    occurredAt,
    ingredientId,
    ingredientLotId,
    quantityKg,
    pricePerKgCentsSnapshot,
    totalCostCents,
    referenceType,
    referenceId,
    notes,
    createdBy,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ingredient_stock_movements';
  @override
  VerificationContext validateIntegrity(
    Insertable<IngredientStockMovement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('ingredient_id')) {
      context.handle(
        _ingredientIdMeta,
        ingredientId.isAcceptableOrUnknown(
          data['ingredient_id']!,
          _ingredientIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ingredientIdMeta);
    }
    if (data.containsKey('ingredient_lot_id')) {
      context.handle(
        _ingredientLotIdMeta,
        ingredientLotId.isAcceptableOrUnknown(
          data['ingredient_lot_id']!,
          _ingredientLotIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ingredientLotIdMeta);
    }
    if (data.containsKey('quantity_kg')) {
      context.handle(
        _quantityKgMeta,
        quantityKg.isAcceptableOrUnknown(data['quantity_kg']!, _quantityKgMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityKgMeta);
    }
    if (data.containsKey('price_per_kg_cents_snapshot')) {
      context.handle(
        _pricePerKgCentsSnapshotMeta,
        pricePerKgCentsSnapshot.isAcceptableOrUnknown(
          data['price_per_kg_cents_snapshot']!,
          _pricePerKgCentsSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pricePerKgCentsSnapshotMeta);
    }
    if (data.containsKey('total_cost_cents')) {
      context.handle(
        _totalCostCentsMeta,
        totalCostCents.isAcceptableOrUnknown(
          data['total_cost_cents']!,
          _totalCostCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalCostCentsMeta);
    }
    if (data.containsKey('reference_type')) {
      context.handle(
        _referenceTypeMeta,
        referenceType.isAcceptableOrUnknown(
          data['reference_type']!,
          _referenceTypeMeta,
        ),
      );
    }
    if (data.containsKey('reference_id')) {
      context.handle(
        _referenceIdMeta,
        referenceId.isAcceptableOrUnknown(
          data['reference_id']!,
          _referenceIdMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IngredientStockMovement map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IngredientStockMovement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      ingredientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingredient_id'],
      )!,
      ingredientLotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingredient_lot_id'],
      )!,
      quantityKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity_kg'],
      )!,
      pricePerKgCentsSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_per_kg_cents_snapshot'],
      )!,
      totalCostCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_cost_cents'],
      )!,
      referenceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_type'],
      ),
      referenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_id'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $IngredientStockMovementsTable createAlias(String alias) {
    return $IngredientStockMovementsTable(attachedDatabase, alias);
  }
}

class IngredientStockMovement extends DataClass
    implements Insertable<IngredientStockMovement> {
  final String id;
  final String type;
  final DateTime occurredAt;
  final String ingredientId;
  final String ingredientLotId;
  final double quantityKg;
  final int pricePerKgCentsSnapshot;
  final int totalCostCents;
  final String? referenceType;
  final String? referenceId;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  const IngredientStockMovement({
    required this.id,
    required this.type,
    required this.occurredAt,
    required this.ingredientId,
    required this.ingredientLotId,
    required this.quantityKg,
    required this.pricePerKgCentsSnapshot,
    required this.totalCostCents,
    this.referenceType,
    this.referenceId,
    this.notes,
    required this.createdBy,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['ingredient_id'] = Variable<String>(ingredientId);
    map['ingredient_lot_id'] = Variable<String>(ingredientLotId);
    map['quantity_kg'] = Variable<double>(quantityKg);
    map['price_per_kg_cents_snapshot'] = Variable<int>(pricePerKgCentsSnapshot);
    map['total_cost_cents'] = Variable<int>(totalCostCents);
    if (!nullToAbsent || referenceType != null) {
      map['reference_type'] = Variable<String>(referenceType);
    }
    if (!nullToAbsent || referenceId != null) {
      map['reference_id'] = Variable<String>(referenceId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_by'] = Variable<String>(createdBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  IngredientStockMovementsCompanion toCompanion(bool nullToAbsent) {
    return IngredientStockMovementsCompanion(
      id: Value(id),
      type: Value(type),
      occurredAt: Value(occurredAt),
      ingredientId: Value(ingredientId),
      ingredientLotId: Value(ingredientLotId),
      quantityKg: Value(quantityKg),
      pricePerKgCentsSnapshot: Value(pricePerKgCentsSnapshot),
      totalCostCents: Value(totalCostCents),
      referenceType: referenceType == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceType),
      referenceId: referenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceId),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
    );
  }

  factory IngredientStockMovement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IngredientStockMovement(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      ingredientId: serializer.fromJson<String>(json['ingredientId']),
      ingredientLotId: serializer.fromJson<String>(json['ingredientLotId']),
      quantityKg: serializer.fromJson<double>(json['quantityKg']),
      pricePerKgCentsSnapshot: serializer.fromJson<int>(
        json['pricePerKgCentsSnapshot'],
      ),
      totalCostCents: serializer.fromJson<int>(json['totalCostCents']),
      referenceType: serializer.fromJson<String?>(json['referenceType']),
      referenceId: serializer.fromJson<String?>(json['referenceId']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'ingredientId': serializer.toJson<String>(ingredientId),
      'ingredientLotId': serializer.toJson<String>(ingredientLotId),
      'quantityKg': serializer.toJson<double>(quantityKg),
      'pricePerKgCentsSnapshot': serializer.toJson<int>(
        pricePerKgCentsSnapshot,
      ),
      'totalCostCents': serializer.toJson<int>(totalCostCents),
      'referenceType': serializer.toJson<String?>(referenceType),
      'referenceId': serializer.toJson<String?>(referenceId),
      'notes': serializer.toJson<String?>(notes),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  IngredientStockMovement copyWith({
    String? id,
    String? type,
    DateTime? occurredAt,
    String? ingredientId,
    String? ingredientLotId,
    double? quantityKg,
    int? pricePerKgCentsSnapshot,
    int? totalCostCents,
    Value<String?> referenceType = const Value.absent(),
    Value<String?> referenceId = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    String? createdBy,
    DateTime? createdAt,
  }) => IngredientStockMovement(
    id: id ?? this.id,
    type: type ?? this.type,
    occurredAt: occurredAt ?? this.occurredAt,
    ingredientId: ingredientId ?? this.ingredientId,
    ingredientLotId: ingredientLotId ?? this.ingredientLotId,
    quantityKg: quantityKg ?? this.quantityKg,
    pricePerKgCentsSnapshot:
        pricePerKgCentsSnapshot ?? this.pricePerKgCentsSnapshot,
    totalCostCents: totalCostCents ?? this.totalCostCents,
    referenceType: referenceType.present
        ? referenceType.value
        : this.referenceType,
    referenceId: referenceId.present ? referenceId.value : this.referenceId,
    notes: notes.present ? notes.value : this.notes,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
  );
  IngredientStockMovement copyWithCompanion(
    IngredientStockMovementsCompanion data,
  ) {
    return IngredientStockMovement(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      ingredientId: data.ingredientId.present
          ? data.ingredientId.value
          : this.ingredientId,
      ingredientLotId: data.ingredientLotId.present
          ? data.ingredientLotId.value
          : this.ingredientLotId,
      quantityKg: data.quantityKg.present
          ? data.quantityKg.value
          : this.quantityKg,
      pricePerKgCentsSnapshot: data.pricePerKgCentsSnapshot.present
          ? data.pricePerKgCentsSnapshot.value
          : this.pricePerKgCentsSnapshot,
      totalCostCents: data.totalCostCents.present
          ? data.totalCostCents.value
          : this.totalCostCents,
      referenceType: data.referenceType.present
          ? data.referenceType.value
          : this.referenceType,
      referenceId: data.referenceId.present
          ? data.referenceId.value
          : this.referenceId,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IngredientStockMovement(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('ingredientLotId: $ingredientLotId, ')
          ..write('quantityKg: $quantityKg, ')
          ..write('pricePerKgCentsSnapshot: $pricePerKgCentsSnapshot, ')
          ..write('totalCostCents: $totalCostCents, ')
          ..write('referenceType: $referenceType, ')
          ..write('referenceId: $referenceId, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    occurredAt,
    ingredientId,
    ingredientLotId,
    quantityKg,
    pricePerKgCentsSnapshot,
    totalCostCents,
    referenceType,
    referenceId,
    notes,
    createdBy,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IngredientStockMovement &&
          other.id == this.id &&
          other.type == this.type &&
          other.occurredAt == this.occurredAt &&
          other.ingredientId == this.ingredientId &&
          other.ingredientLotId == this.ingredientLotId &&
          other.quantityKg == this.quantityKg &&
          other.pricePerKgCentsSnapshot == this.pricePerKgCentsSnapshot &&
          other.totalCostCents == this.totalCostCents &&
          other.referenceType == this.referenceType &&
          other.referenceId == this.referenceId &&
          other.notes == this.notes &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt);
}

class IngredientStockMovementsCompanion
    extends UpdateCompanion<IngredientStockMovement> {
  final Value<String> id;
  final Value<String> type;
  final Value<DateTime> occurredAt;
  final Value<String> ingredientId;
  final Value<String> ingredientLotId;
  final Value<double> quantityKg;
  final Value<int> pricePerKgCentsSnapshot;
  final Value<int> totalCostCents;
  final Value<String?> referenceType;
  final Value<String?> referenceId;
  final Value<String?> notes;
  final Value<String> createdBy;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const IngredientStockMovementsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.ingredientId = const Value.absent(),
    this.ingredientLotId = const Value.absent(),
    this.quantityKg = const Value.absent(),
    this.pricePerKgCentsSnapshot = const Value.absent(),
    this.totalCostCents = const Value.absent(),
    this.referenceType = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IngredientStockMovementsCompanion.insert({
    required String id,
    required String type,
    required DateTime occurredAt,
    required String ingredientId,
    required String ingredientLotId,
    required double quantityKg,
    required int pricePerKgCentsSnapshot,
    required int totalCostCents,
    this.referenceType = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.notes = const Value.absent(),
    required String createdBy,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       occurredAt = Value(occurredAt),
       ingredientId = Value(ingredientId),
       ingredientLotId = Value(ingredientLotId),
       quantityKg = Value(quantityKg),
       pricePerKgCentsSnapshot = Value(pricePerKgCentsSnapshot),
       totalCostCents = Value(totalCostCents),
       createdBy = Value(createdBy),
       createdAt = Value(createdAt);
  static Insertable<IngredientStockMovement> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<DateTime>? occurredAt,
    Expression<String>? ingredientId,
    Expression<String>? ingredientLotId,
    Expression<double>? quantityKg,
    Expression<int>? pricePerKgCentsSnapshot,
    Expression<int>? totalCostCents,
    Expression<String>? referenceType,
    Expression<String>? referenceId,
    Expression<String>? notes,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (ingredientId != null) 'ingredient_id': ingredientId,
      if (ingredientLotId != null) 'ingredient_lot_id': ingredientLotId,
      if (quantityKg != null) 'quantity_kg': quantityKg,
      if (pricePerKgCentsSnapshot != null)
        'price_per_kg_cents_snapshot': pricePerKgCentsSnapshot,
      if (totalCostCents != null) 'total_cost_cents': totalCostCents,
      if (referenceType != null) 'reference_type': referenceType,
      if (referenceId != null) 'reference_id': referenceId,
      if (notes != null) 'notes': notes,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IngredientStockMovementsCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<DateTime>? occurredAt,
    Value<String>? ingredientId,
    Value<String>? ingredientLotId,
    Value<double>? quantityKg,
    Value<int>? pricePerKgCentsSnapshot,
    Value<int>? totalCostCents,
    Value<String?>? referenceType,
    Value<String?>? referenceId,
    Value<String?>? notes,
    Value<String>? createdBy,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return IngredientStockMovementsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      occurredAt: occurredAt ?? this.occurredAt,
      ingredientId: ingredientId ?? this.ingredientId,
      ingredientLotId: ingredientLotId ?? this.ingredientLotId,
      quantityKg: quantityKg ?? this.quantityKg,
      pricePerKgCentsSnapshot:
          pricePerKgCentsSnapshot ?? this.pricePerKgCentsSnapshot,
      totalCostCents: totalCostCents ?? this.totalCostCents,
      referenceType: referenceType ?? this.referenceType,
      referenceId: referenceId ?? this.referenceId,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (ingredientId.present) {
      map['ingredient_id'] = Variable<String>(ingredientId.value);
    }
    if (ingredientLotId.present) {
      map['ingredient_lot_id'] = Variable<String>(ingredientLotId.value);
    }
    if (quantityKg.present) {
      map['quantity_kg'] = Variable<double>(quantityKg.value);
    }
    if (pricePerKgCentsSnapshot.present) {
      map['price_per_kg_cents_snapshot'] = Variable<int>(
        pricePerKgCentsSnapshot.value,
      );
    }
    if (totalCostCents.present) {
      map['total_cost_cents'] = Variable<int>(totalCostCents.value);
    }
    if (referenceType.present) {
      map['reference_type'] = Variable<String>(referenceType.value);
    }
    if (referenceId.present) {
      map['reference_id'] = Variable<String>(referenceId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IngredientStockMovementsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('ingredientLotId: $ingredientLotId, ')
          ..write('quantityKg: $quantityKg, ')
          ..write('pricePerKgCentsSnapshot: $pricePerKgCentsSnapshot, ')
          ..write('totalCostCents: $totalCostCents, ')
          ..write('referenceType: $referenceType, ')
          ..write('referenceId: $referenceId, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FeedFormulasTable extends FeedFormulas
    with TableInfo<$FeedFormulasTable, FeedFormula> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeedFormulasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phaseMeta = const VerificationMeta('phase');
  @override
  late final GeneratedColumn<String> phase = GeneratedColumn<String>(
    'phase',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _validFromMeta = const VerificationMeta(
    'validFrom',
  );
  @override
  late final GeneratedColumn<DateTime> validFrom = GeneratedColumn<DateTime>(
    'valid_from',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    phase,
    version,
    isActive,
    validFrom,
    notes,
    createdBy,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feed_formulas';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeedFormula> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phase')) {
      context.handle(
        _phaseMeta,
        phase.isAcceptableOrUnknown(data['phase']!, _phaseMeta),
      );
    } else if (isInserting) {
      context.missing(_phaseMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('valid_from')) {
      context.handle(
        _validFromMeta,
        validFrom.isAcceptableOrUnknown(data['valid_from']!, _validFromMeta),
      );
    } else if (isInserting) {
      context.missing(_validFromMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FeedFormula map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeedFormula(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phase'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      validFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}valid_from'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FeedFormulasTable createAlias(String alias) {
    return $FeedFormulasTable(attachedDatabase, alias);
  }
}

class FeedFormula extends DataClass implements Insertable<FeedFormula> {
  final String id;
  final String name;
  final String phase;
  final int version;
  final bool isActive;
  final DateTime validFrom;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  const FeedFormula({
    required this.id,
    required this.name,
    required this.phase,
    required this.version,
    required this.isActive,
    required this.validFrom,
    this.notes,
    required this.createdBy,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['phase'] = Variable<String>(phase);
    map['version'] = Variable<int>(version);
    map['is_active'] = Variable<bool>(isActive);
    map['valid_from'] = Variable<DateTime>(validFrom);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_by'] = Variable<String>(createdBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FeedFormulasCompanion toCompanion(bool nullToAbsent) {
    return FeedFormulasCompanion(
      id: Value(id),
      name: Value(name),
      phase: Value(phase),
      version: Value(version),
      isActive: Value(isActive),
      validFrom: Value(validFrom),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
    );
  }

  factory FeedFormula.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeedFormula(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phase: serializer.fromJson<String>(json['phase']),
      version: serializer.fromJson<int>(json['version']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      validFrom: serializer.fromJson<DateTime>(json['validFrom']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'phase': serializer.toJson<String>(phase),
      'version': serializer.toJson<int>(version),
      'isActive': serializer.toJson<bool>(isActive),
      'validFrom': serializer.toJson<DateTime>(validFrom),
      'notes': serializer.toJson<String?>(notes),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FeedFormula copyWith({
    String? id,
    String? name,
    String? phase,
    int? version,
    bool? isActive,
    DateTime? validFrom,
    Value<String?> notes = const Value.absent(),
    String? createdBy,
    DateTime? createdAt,
  }) => FeedFormula(
    id: id ?? this.id,
    name: name ?? this.name,
    phase: phase ?? this.phase,
    version: version ?? this.version,
    isActive: isActive ?? this.isActive,
    validFrom: validFrom ?? this.validFrom,
    notes: notes.present ? notes.value : this.notes,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
  );
  FeedFormula copyWithCompanion(FeedFormulasCompanion data) {
    return FeedFormula(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phase: data.phase.present ? data.phase.value : this.phase,
      version: data.version.present ? data.version.value : this.version,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      validFrom: data.validFrom.present ? data.validFrom.value : this.validFrom,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeedFormula(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phase: $phase, ')
          ..write('version: $version, ')
          ..write('isActive: $isActive, ')
          ..write('validFrom: $validFrom, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    phase,
    version,
    isActive,
    validFrom,
    notes,
    createdBy,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedFormula &&
          other.id == this.id &&
          other.name == this.name &&
          other.phase == this.phase &&
          other.version == this.version &&
          other.isActive == this.isActive &&
          other.validFrom == this.validFrom &&
          other.notes == this.notes &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt);
}

class FeedFormulasCompanion extends UpdateCompanion<FeedFormula> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> phase;
  final Value<int> version;
  final Value<bool> isActive;
  final Value<DateTime> validFrom;
  final Value<String?> notes;
  final Value<String> createdBy;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const FeedFormulasCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phase = const Value.absent(),
    this.version = const Value.absent(),
    this.isActive = const Value.absent(),
    this.validFrom = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeedFormulasCompanion.insert({
    required String id,
    required String name,
    required String phase,
    this.version = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime validFrom,
    this.notes = const Value.absent(),
    required String createdBy,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       phase = Value(phase),
       validFrom = Value(validFrom),
       createdBy = Value(createdBy),
       createdAt = Value(createdAt);
  static Insertable<FeedFormula> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? phase,
    Expression<int>? version,
    Expression<bool>? isActive,
    Expression<DateTime>? validFrom,
    Expression<String>? notes,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phase != null) 'phase': phase,
      if (version != null) 'version': version,
      if (isActive != null) 'is_active': isActive,
      if (validFrom != null) 'valid_from': validFrom,
      if (notes != null) 'notes': notes,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FeedFormulasCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? phase,
    Value<int>? version,
    Value<bool>? isActive,
    Value<DateTime>? validFrom,
    Value<String?>? notes,
    Value<String>? createdBy,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return FeedFormulasCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phase: phase ?? this.phase,
      version: version ?? this.version,
      isActive: isActive ?? this.isActive,
      validFrom: validFrom ?? this.validFrom,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phase.present) {
      map['phase'] = Variable<String>(phase.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (validFrom.present) {
      map['valid_from'] = Variable<DateTime>(validFrom.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeedFormulasCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phase: $phase, ')
          ..write('version: $version, ')
          ..write('isActive: $isActive, ')
          ..write('validFrom: $validFrom, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FeedFormulaItemsTable extends FeedFormulaItems
    with TableInfo<$FeedFormulaItemsTable, FeedFormulaItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeedFormulaItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _formulaIdMeta = const VerificationMeta(
    'formulaId',
  );
  @override
  late final GeneratedColumn<String> formulaId = GeneratedColumn<String>(
    'formula_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ingredientIdMeta = const VerificationMeta(
    'ingredientId',
  );
  @override
  late final GeneratedColumn<String> ingredientId = GeneratedColumn<String>(
    'ingredient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseQuantityKgMeta = const VerificationMeta(
    'baseQuantityKg',
  );
  @override
  late final GeneratedColumn<double> baseQuantityKg = GeneratedColumn<double>(
    'base_quantity_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    formulaId,
    ingredientId,
    baseQuantityKg,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feed_formula_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeedFormulaItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('formula_id')) {
      context.handle(
        _formulaIdMeta,
        formulaId.isAcceptableOrUnknown(data['formula_id']!, _formulaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_formulaIdMeta);
    }
    if (data.containsKey('ingredient_id')) {
      context.handle(
        _ingredientIdMeta,
        ingredientId.isAcceptableOrUnknown(
          data['ingredient_id']!,
          _ingredientIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ingredientIdMeta);
    }
    if (data.containsKey('base_quantity_kg')) {
      context.handle(
        _baseQuantityKgMeta,
        baseQuantityKg.isAcceptableOrUnknown(
          data['base_quantity_kg']!,
          _baseQuantityKgMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baseQuantityKgMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FeedFormulaItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeedFormulaItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      formulaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}formula_id'],
      )!,
      ingredientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingredient_id'],
      )!,
      baseQuantityKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}base_quantity_kg'],
      )!,
    );
  }

  @override
  $FeedFormulaItemsTable createAlias(String alias) {
    return $FeedFormulaItemsTable(attachedDatabase, alias);
  }
}

class FeedFormulaItem extends DataClass implements Insertable<FeedFormulaItem> {
  final String id;
  final String formulaId;
  final String ingredientId;
  final double baseQuantityKg;
  const FeedFormulaItem({
    required this.id,
    required this.formulaId,
    required this.ingredientId,
    required this.baseQuantityKg,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['formula_id'] = Variable<String>(formulaId);
    map['ingredient_id'] = Variable<String>(ingredientId);
    map['base_quantity_kg'] = Variable<double>(baseQuantityKg);
    return map;
  }

  FeedFormulaItemsCompanion toCompanion(bool nullToAbsent) {
    return FeedFormulaItemsCompanion(
      id: Value(id),
      formulaId: Value(formulaId),
      ingredientId: Value(ingredientId),
      baseQuantityKg: Value(baseQuantityKg),
    );
  }

  factory FeedFormulaItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeedFormulaItem(
      id: serializer.fromJson<String>(json['id']),
      formulaId: serializer.fromJson<String>(json['formulaId']),
      ingredientId: serializer.fromJson<String>(json['ingredientId']),
      baseQuantityKg: serializer.fromJson<double>(json['baseQuantityKg']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'formulaId': serializer.toJson<String>(formulaId),
      'ingredientId': serializer.toJson<String>(ingredientId),
      'baseQuantityKg': serializer.toJson<double>(baseQuantityKg),
    };
  }

  FeedFormulaItem copyWith({
    String? id,
    String? formulaId,
    String? ingredientId,
    double? baseQuantityKg,
  }) => FeedFormulaItem(
    id: id ?? this.id,
    formulaId: formulaId ?? this.formulaId,
    ingredientId: ingredientId ?? this.ingredientId,
    baseQuantityKg: baseQuantityKg ?? this.baseQuantityKg,
  );
  FeedFormulaItem copyWithCompanion(FeedFormulaItemsCompanion data) {
    return FeedFormulaItem(
      id: data.id.present ? data.id.value : this.id,
      formulaId: data.formulaId.present ? data.formulaId.value : this.formulaId,
      ingredientId: data.ingredientId.present
          ? data.ingredientId.value
          : this.ingredientId,
      baseQuantityKg: data.baseQuantityKg.present
          ? data.baseQuantityKg.value
          : this.baseQuantityKg,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeedFormulaItem(')
          ..write('id: $id, ')
          ..write('formulaId: $formulaId, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('baseQuantityKg: $baseQuantityKg')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, formulaId, ingredientId, baseQuantityKg);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedFormulaItem &&
          other.id == this.id &&
          other.formulaId == this.formulaId &&
          other.ingredientId == this.ingredientId &&
          other.baseQuantityKg == this.baseQuantityKg);
}

class FeedFormulaItemsCompanion extends UpdateCompanion<FeedFormulaItem> {
  final Value<String> id;
  final Value<String> formulaId;
  final Value<String> ingredientId;
  final Value<double> baseQuantityKg;
  final Value<int> rowid;
  const FeedFormulaItemsCompanion({
    this.id = const Value.absent(),
    this.formulaId = const Value.absent(),
    this.ingredientId = const Value.absent(),
    this.baseQuantityKg = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeedFormulaItemsCompanion.insert({
    required String id,
    required String formulaId,
    required String ingredientId,
    required double baseQuantityKg,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       formulaId = Value(formulaId),
       ingredientId = Value(ingredientId),
       baseQuantityKg = Value(baseQuantityKg);
  static Insertable<FeedFormulaItem> custom({
    Expression<String>? id,
    Expression<String>? formulaId,
    Expression<String>? ingredientId,
    Expression<double>? baseQuantityKg,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (formulaId != null) 'formula_id': formulaId,
      if (ingredientId != null) 'ingredient_id': ingredientId,
      if (baseQuantityKg != null) 'base_quantity_kg': baseQuantityKg,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FeedFormulaItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? formulaId,
    Value<String>? ingredientId,
    Value<double>? baseQuantityKg,
    Value<int>? rowid,
  }) {
    return FeedFormulaItemsCompanion(
      id: id ?? this.id,
      formulaId: formulaId ?? this.formulaId,
      ingredientId: ingredientId ?? this.ingredientId,
      baseQuantityKg: baseQuantityKg ?? this.baseQuantityKg,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (formulaId.present) {
      map['formula_id'] = Variable<String>(formulaId.value);
    }
    if (ingredientId.present) {
      map['ingredient_id'] = Variable<String>(ingredientId.value);
    }
    if (baseQuantityKg.present) {
      map['base_quantity_kg'] = Variable<double>(baseQuantityKg.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeedFormulaItemsCompanion(')
          ..write('id: $id, ')
          ..write('formulaId: $formulaId, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('baseQuantityKg: $baseQuantityKg, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FeedBatchesTable extends FeedBatches
    with TableInfo<$FeedBatchesTable, FeedBatche> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeedBatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _phaseMeta = const VerificationMeta('phase');
  @override
  late final GeneratedColumn<String> phase = GeneratedColumn<String>(
    'phase',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _formulaIdMeta = const VerificationMeta(
    'formulaId',
  );
  @override
  late final GeneratedColumn<String> formulaId = GeneratedColumn<String>(
    'formula_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _producedAtMeta = const VerificationMeta(
    'producedAt',
  );
  @override
  late final GeneratedColumn<DateTime> producedAt = GeneratedColumn<DateTime>(
    'produced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _producedQuantityKgMeta =
      const VerificationMeta('producedQuantityKg');
  @override
  late final GeneratedColumn<double> producedQuantityKg =
      GeneratedColumn<double>(
        'produced_quantity_kg',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _totalCostCentsMeta = const VerificationMeta(
    'totalCostCents',
  );
  @override
  late final GeneratedColumn<int> totalCostCents = GeneratedColumn<int>(
    'total_cost_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costPerKgCentsMeta = const VerificationMeta(
    'costPerKgCents',
  );
  @override
  late final GeneratedColumn<double> costPerKgCents = GeneratedColumn<double>(
    'cost_per_kg_cents',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    phase,
    formulaId,
    producedAt,
    producedQuantityKg,
    totalCostCents,
    costPerKgCents,
    notes,
    createdBy,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feed_batches';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeedBatche> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('phase')) {
      context.handle(
        _phaseMeta,
        phase.isAcceptableOrUnknown(data['phase']!, _phaseMeta),
      );
    } else if (isInserting) {
      context.missing(_phaseMeta);
    }
    if (data.containsKey('formula_id')) {
      context.handle(
        _formulaIdMeta,
        formulaId.isAcceptableOrUnknown(data['formula_id']!, _formulaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_formulaIdMeta);
    }
    if (data.containsKey('produced_at')) {
      context.handle(
        _producedAtMeta,
        producedAt.isAcceptableOrUnknown(data['produced_at']!, _producedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_producedAtMeta);
    }
    if (data.containsKey('produced_quantity_kg')) {
      context.handle(
        _producedQuantityKgMeta,
        producedQuantityKg.isAcceptableOrUnknown(
          data['produced_quantity_kg']!,
          _producedQuantityKgMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_producedQuantityKgMeta);
    }
    if (data.containsKey('total_cost_cents')) {
      context.handle(
        _totalCostCentsMeta,
        totalCostCents.isAcceptableOrUnknown(
          data['total_cost_cents']!,
          _totalCostCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalCostCentsMeta);
    }
    if (data.containsKey('cost_per_kg_cents')) {
      context.handle(
        _costPerKgCentsMeta,
        costPerKgCents.isAcceptableOrUnknown(
          data['cost_per_kg_cents']!,
          _costPerKgCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_costPerKgCentsMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FeedBatche map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeedBatche(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      phase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phase'],
      )!,
      formulaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}formula_id'],
      )!,
      producedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}produced_at'],
      )!,
      producedQuantityKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}produced_quantity_kg'],
      )!,
      totalCostCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_cost_cents'],
      )!,
      costPerKgCents: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost_per_kg_cents'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FeedBatchesTable createAlias(String alias) {
    return $FeedBatchesTable(attachedDatabase, alias);
  }
}

class FeedBatche extends DataClass implements Insertable<FeedBatche> {
  final String id;
  final String code;
  final String phase;
  final String formulaId;
  final DateTime producedAt;
  final double producedQuantityKg;
  final int totalCostCents;
  final double costPerKgCents;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  const FeedBatche({
    required this.id,
    required this.code,
    required this.phase,
    required this.formulaId,
    required this.producedAt,
    required this.producedQuantityKg,
    required this.totalCostCents,
    required this.costPerKgCents,
    this.notes,
    required this.createdBy,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['code'] = Variable<String>(code);
    map['phase'] = Variable<String>(phase);
    map['formula_id'] = Variable<String>(formulaId);
    map['produced_at'] = Variable<DateTime>(producedAt);
    map['produced_quantity_kg'] = Variable<double>(producedQuantityKg);
    map['total_cost_cents'] = Variable<int>(totalCostCents);
    map['cost_per_kg_cents'] = Variable<double>(costPerKgCents);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_by'] = Variable<String>(createdBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FeedBatchesCompanion toCompanion(bool nullToAbsent) {
    return FeedBatchesCompanion(
      id: Value(id),
      code: Value(code),
      phase: Value(phase),
      formulaId: Value(formulaId),
      producedAt: Value(producedAt),
      producedQuantityKg: Value(producedQuantityKg),
      totalCostCents: Value(totalCostCents),
      costPerKgCents: Value(costPerKgCents),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
    );
  }

  factory FeedBatche.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeedBatche(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      phase: serializer.fromJson<String>(json['phase']),
      formulaId: serializer.fromJson<String>(json['formulaId']),
      producedAt: serializer.fromJson<DateTime>(json['producedAt']),
      producedQuantityKg: serializer.fromJson<double>(
        json['producedQuantityKg'],
      ),
      totalCostCents: serializer.fromJson<int>(json['totalCostCents']),
      costPerKgCents: serializer.fromJson<double>(json['costPerKgCents']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String>(code),
      'phase': serializer.toJson<String>(phase),
      'formulaId': serializer.toJson<String>(formulaId),
      'producedAt': serializer.toJson<DateTime>(producedAt),
      'producedQuantityKg': serializer.toJson<double>(producedQuantityKg),
      'totalCostCents': serializer.toJson<int>(totalCostCents),
      'costPerKgCents': serializer.toJson<double>(costPerKgCents),
      'notes': serializer.toJson<String?>(notes),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FeedBatche copyWith({
    String? id,
    String? code,
    String? phase,
    String? formulaId,
    DateTime? producedAt,
    double? producedQuantityKg,
    int? totalCostCents,
    double? costPerKgCents,
    Value<String?> notes = const Value.absent(),
    String? createdBy,
    DateTime? createdAt,
  }) => FeedBatche(
    id: id ?? this.id,
    code: code ?? this.code,
    phase: phase ?? this.phase,
    formulaId: formulaId ?? this.formulaId,
    producedAt: producedAt ?? this.producedAt,
    producedQuantityKg: producedQuantityKg ?? this.producedQuantityKg,
    totalCostCents: totalCostCents ?? this.totalCostCents,
    costPerKgCents: costPerKgCents ?? this.costPerKgCents,
    notes: notes.present ? notes.value : this.notes,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
  );
  FeedBatche copyWithCompanion(FeedBatchesCompanion data) {
    return FeedBatche(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      phase: data.phase.present ? data.phase.value : this.phase,
      formulaId: data.formulaId.present ? data.formulaId.value : this.formulaId,
      producedAt: data.producedAt.present
          ? data.producedAt.value
          : this.producedAt,
      producedQuantityKg: data.producedQuantityKg.present
          ? data.producedQuantityKg.value
          : this.producedQuantityKg,
      totalCostCents: data.totalCostCents.present
          ? data.totalCostCents.value
          : this.totalCostCents,
      costPerKgCents: data.costPerKgCents.present
          ? data.costPerKgCents.value
          : this.costPerKgCents,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeedBatche(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('phase: $phase, ')
          ..write('formulaId: $formulaId, ')
          ..write('producedAt: $producedAt, ')
          ..write('producedQuantityKg: $producedQuantityKg, ')
          ..write('totalCostCents: $totalCostCents, ')
          ..write('costPerKgCents: $costPerKgCents, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    code,
    phase,
    formulaId,
    producedAt,
    producedQuantityKg,
    totalCostCents,
    costPerKgCents,
    notes,
    createdBy,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedBatche &&
          other.id == this.id &&
          other.code == this.code &&
          other.phase == this.phase &&
          other.formulaId == this.formulaId &&
          other.producedAt == this.producedAt &&
          other.producedQuantityKg == this.producedQuantityKg &&
          other.totalCostCents == this.totalCostCents &&
          other.costPerKgCents == this.costPerKgCents &&
          other.notes == this.notes &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt);
}

class FeedBatchesCompanion extends UpdateCompanion<FeedBatche> {
  final Value<String> id;
  final Value<String> code;
  final Value<String> phase;
  final Value<String> formulaId;
  final Value<DateTime> producedAt;
  final Value<double> producedQuantityKg;
  final Value<int> totalCostCents;
  final Value<double> costPerKgCents;
  final Value<String?> notes;
  final Value<String> createdBy;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const FeedBatchesCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.phase = const Value.absent(),
    this.formulaId = const Value.absent(),
    this.producedAt = const Value.absent(),
    this.producedQuantityKg = const Value.absent(),
    this.totalCostCents = const Value.absent(),
    this.costPerKgCents = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeedBatchesCompanion.insert({
    required String id,
    required String code,
    required String phase,
    required String formulaId,
    required DateTime producedAt,
    required double producedQuantityKg,
    required int totalCostCents,
    required double costPerKgCents,
    this.notes = const Value.absent(),
    required String createdBy,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       code = Value(code),
       phase = Value(phase),
       formulaId = Value(formulaId),
       producedAt = Value(producedAt),
       producedQuantityKg = Value(producedQuantityKg),
       totalCostCents = Value(totalCostCents),
       costPerKgCents = Value(costPerKgCents),
       createdBy = Value(createdBy),
       createdAt = Value(createdAt);
  static Insertable<FeedBatche> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<String>? phase,
    Expression<String>? formulaId,
    Expression<DateTime>? producedAt,
    Expression<double>? producedQuantityKg,
    Expression<int>? totalCostCents,
    Expression<double>? costPerKgCents,
    Expression<String>? notes,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (phase != null) 'phase': phase,
      if (formulaId != null) 'formula_id': formulaId,
      if (producedAt != null) 'produced_at': producedAt,
      if (producedQuantityKg != null)
        'produced_quantity_kg': producedQuantityKg,
      if (totalCostCents != null) 'total_cost_cents': totalCostCents,
      if (costPerKgCents != null) 'cost_per_kg_cents': costPerKgCents,
      if (notes != null) 'notes': notes,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FeedBatchesCompanion copyWith({
    Value<String>? id,
    Value<String>? code,
    Value<String>? phase,
    Value<String>? formulaId,
    Value<DateTime>? producedAt,
    Value<double>? producedQuantityKg,
    Value<int>? totalCostCents,
    Value<double>? costPerKgCents,
    Value<String?>? notes,
    Value<String>? createdBy,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return FeedBatchesCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      phase: phase ?? this.phase,
      formulaId: formulaId ?? this.formulaId,
      producedAt: producedAt ?? this.producedAt,
      producedQuantityKg: producedQuantityKg ?? this.producedQuantityKg,
      totalCostCents: totalCostCents ?? this.totalCostCents,
      costPerKgCents: costPerKgCents ?? this.costPerKgCents,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (phase.present) {
      map['phase'] = Variable<String>(phase.value);
    }
    if (formulaId.present) {
      map['formula_id'] = Variable<String>(formulaId.value);
    }
    if (producedAt.present) {
      map['produced_at'] = Variable<DateTime>(producedAt.value);
    }
    if (producedQuantityKg.present) {
      map['produced_quantity_kg'] = Variable<double>(producedQuantityKg.value);
    }
    if (totalCostCents.present) {
      map['total_cost_cents'] = Variable<int>(totalCostCents.value);
    }
    if (costPerKgCents.present) {
      map['cost_per_kg_cents'] = Variable<double>(costPerKgCents.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeedBatchesCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('phase: $phase, ')
          ..write('formulaId: $formulaId, ')
          ..write('producedAt: $producedAt, ')
          ..write('producedQuantityKg: $producedQuantityKg, ')
          ..write('totalCostCents: $totalCostCents, ')
          ..write('costPerKgCents: $costPerKgCents, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FeedBatchItemsTable extends FeedBatchItems
    with TableInfo<$FeedBatchItemsTable, FeedBatchItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeedBatchItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ingredientIdMeta = const VerificationMeta(
    'ingredientId',
  );
  @override
  late final GeneratedColumn<String> ingredientId = GeneratedColumn<String>(
    'ingredient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityKgMeta = const VerificationMeta(
    'quantityKg',
  );
  @override
  late final GeneratedColumn<double> quantityKg = GeneratedColumn<double>(
    'quantity_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pricePerKgCentsSnapshotMeta =
      const VerificationMeta('pricePerKgCentsSnapshot');
  @override
  late final GeneratedColumn<int> pricePerKgCentsSnapshot =
      GeneratedColumn<int>(
        'price_per_kg_cents_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _itemCostCentsMeta = const VerificationMeta(
    'itemCostCents',
  );
  @override
  late final GeneratedColumn<int> itemCostCents = GeneratedColumn<int>(
    'item_cost_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    batchId,
    ingredientId,
    quantityKg,
    pricePerKgCentsSnapshot,
    itemCostCents,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feed_batch_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeedBatchItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('ingredient_id')) {
      context.handle(
        _ingredientIdMeta,
        ingredientId.isAcceptableOrUnknown(
          data['ingredient_id']!,
          _ingredientIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ingredientIdMeta);
    }
    if (data.containsKey('quantity_kg')) {
      context.handle(
        _quantityKgMeta,
        quantityKg.isAcceptableOrUnknown(data['quantity_kg']!, _quantityKgMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityKgMeta);
    }
    if (data.containsKey('price_per_kg_cents_snapshot')) {
      context.handle(
        _pricePerKgCentsSnapshotMeta,
        pricePerKgCentsSnapshot.isAcceptableOrUnknown(
          data['price_per_kg_cents_snapshot']!,
          _pricePerKgCentsSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pricePerKgCentsSnapshotMeta);
    }
    if (data.containsKey('item_cost_cents')) {
      context.handle(
        _itemCostCentsMeta,
        itemCostCents.isAcceptableOrUnknown(
          data['item_cost_cents']!,
          _itemCostCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_itemCostCentsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FeedBatchItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeedBatchItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      )!,
      ingredientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingredient_id'],
      )!,
      quantityKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity_kg'],
      )!,
      pricePerKgCentsSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_per_kg_cents_snapshot'],
      )!,
      itemCostCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_cost_cents'],
      )!,
    );
  }

  @override
  $FeedBatchItemsTable createAlias(String alias) {
    return $FeedBatchItemsTable(attachedDatabase, alias);
  }
}

class FeedBatchItem extends DataClass implements Insertable<FeedBatchItem> {
  final String id;
  final String batchId;
  final String ingredientId;
  final double quantityKg;
  final int pricePerKgCentsSnapshot;
  final int itemCostCents;
  const FeedBatchItem({
    required this.id,
    required this.batchId,
    required this.ingredientId,
    required this.quantityKg,
    required this.pricePerKgCentsSnapshot,
    required this.itemCostCents,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['batch_id'] = Variable<String>(batchId);
    map['ingredient_id'] = Variable<String>(ingredientId);
    map['quantity_kg'] = Variable<double>(quantityKg);
    map['price_per_kg_cents_snapshot'] = Variable<int>(pricePerKgCentsSnapshot);
    map['item_cost_cents'] = Variable<int>(itemCostCents);
    return map;
  }

  FeedBatchItemsCompanion toCompanion(bool nullToAbsent) {
    return FeedBatchItemsCompanion(
      id: Value(id),
      batchId: Value(batchId),
      ingredientId: Value(ingredientId),
      quantityKg: Value(quantityKg),
      pricePerKgCentsSnapshot: Value(pricePerKgCentsSnapshot),
      itemCostCents: Value(itemCostCents),
    );
  }

  factory FeedBatchItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeedBatchItem(
      id: serializer.fromJson<String>(json['id']),
      batchId: serializer.fromJson<String>(json['batchId']),
      ingredientId: serializer.fromJson<String>(json['ingredientId']),
      quantityKg: serializer.fromJson<double>(json['quantityKg']),
      pricePerKgCentsSnapshot: serializer.fromJson<int>(
        json['pricePerKgCentsSnapshot'],
      ),
      itemCostCents: serializer.fromJson<int>(json['itemCostCents']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'batchId': serializer.toJson<String>(batchId),
      'ingredientId': serializer.toJson<String>(ingredientId),
      'quantityKg': serializer.toJson<double>(quantityKg),
      'pricePerKgCentsSnapshot': serializer.toJson<int>(
        pricePerKgCentsSnapshot,
      ),
      'itemCostCents': serializer.toJson<int>(itemCostCents),
    };
  }

  FeedBatchItem copyWith({
    String? id,
    String? batchId,
    String? ingredientId,
    double? quantityKg,
    int? pricePerKgCentsSnapshot,
    int? itemCostCents,
  }) => FeedBatchItem(
    id: id ?? this.id,
    batchId: batchId ?? this.batchId,
    ingredientId: ingredientId ?? this.ingredientId,
    quantityKg: quantityKg ?? this.quantityKg,
    pricePerKgCentsSnapshot:
        pricePerKgCentsSnapshot ?? this.pricePerKgCentsSnapshot,
    itemCostCents: itemCostCents ?? this.itemCostCents,
  );
  FeedBatchItem copyWithCompanion(FeedBatchItemsCompanion data) {
    return FeedBatchItem(
      id: data.id.present ? data.id.value : this.id,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      ingredientId: data.ingredientId.present
          ? data.ingredientId.value
          : this.ingredientId,
      quantityKg: data.quantityKg.present
          ? data.quantityKg.value
          : this.quantityKg,
      pricePerKgCentsSnapshot: data.pricePerKgCentsSnapshot.present
          ? data.pricePerKgCentsSnapshot.value
          : this.pricePerKgCentsSnapshot,
      itemCostCents: data.itemCostCents.present
          ? data.itemCostCents.value
          : this.itemCostCents,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeedBatchItem(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('quantityKg: $quantityKg, ')
          ..write('pricePerKgCentsSnapshot: $pricePerKgCentsSnapshot, ')
          ..write('itemCostCents: $itemCostCents')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    batchId,
    ingredientId,
    quantityKg,
    pricePerKgCentsSnapshot,
    itemCostCents,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedBatchItem &&
          other.id == this.id &&
          other.batchId == this.batchId &&
          other.ingredientId == this.ingredientId &&
          other.quantityKg == this.quantityKg &&
          other.pricePerKgCentsSnapshot == this.pricePerKgCentsSnapshot &&
          other.itemCostCents == this.itemCostCents);
}

class FeedBatchItemsCompanion extends UpdateCompanion<FeedBatchItem> {
  final Value<String> id;
  final Value<String> batchId;
  final Value<String> ingredientId;
  final Value<double> quantityKg;
  final Value<int> pricePerKgCentsSnapshot;
  final Value<int> itemCostCents;
  final Value<int> rowid;
  const FeedBatchItemsCompanion({
    this.id = const Value.absent(),
    this.batchId = const Value.absent(),
    this.ingredientId = const Value.absent(),
    this.quantityKg = const Value.absent(),
    this.pricePerKgCentsSnapshot = const Value.absent(),
    this.itemCostCents = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeedBatchItemsCompanion.insert({
    required String id,
    required String batchId,
    required String ingredientId,
    required double quantityKg,
    required int pricePerKgCentsSnapshot,
    required int itemCostCents,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       batchId = Value(batchId),
       ingredientId = Value(ingredientId),
       quantityKg = Value(quantityKg),
       pricePerKgCentsSnapshot = Value(pricePerKgCentsSnapshot),
       itemCostCents = Value(itemCostCents);
  static Insertable<FeedBatchItem> custom({
    Expression<String>? id,
    Expression<String>? batchId,
    Expression<String>? ingredientId,
    Expression<double>? quantityKg,
    Expression<int>? pricePerKgCentsSnapshot,
    Expression<int>? itemCostCents,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (batchId != null) 'batch_id': batchId,
      if (ingredientId != null) 'ingredient_id': ingredientId,
      if (quantityKg != null) 'quantity_kg': quantityKg,
      if (pricePerKgCentsSnapshot != null)
        'price_per_kg_cents_snapshot': pricePerKgCentsSnapshot,
      if (itemCostCents != null) 'item_cost_cents': itemCostCents,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FeedBatchItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? batchId,
    Value<String>? ingredientId,
    Value<double>? quantityKg,
    Value<int>? pricePerKgCentsSnapshot,
    Value<int>? itemCostCents,
    Value<int>? rowid,
  }) {
    return FeedBatchItemsCompanion(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      ingredientId: ingredientId ?? this.ingredientId,
      quantityKg: quantityKg ?? this.quantityKg,
      pricePerKgCentsSnapshot:
          pricePerKgCentsSnapshot ?? this.pricePerKgCentsSnapshot,
      itemCostCents: itemCostCents ?? this.itemCostCents,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (ingredientId.present) {
      map['ingredient_id'] = Variable<String>(ingredientId.value);
    }
    if (quantityKg.present) {
      map['quantity_kg'] = Variable<double>(quantityKg.value);
    }
    if (pricePerKgCentsSnapshot.present) {
      map['price_per_kg_cents_snapshot'] = Variable<int>(
        pricePerKgCentsSnapshot.value,
      );
    }
    if (itemCostCents.present) {
      map['item_cost_cents'] = Variable<int>(itemCostCents.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeedBatchItemsCompanion(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('quantityKg: $quantityKg, ')
          ..write('pricePerKgCentsSnapshot: $pricePerKgCentsSnapshot, ')
          ..write('itemCostCents: $itemCostCents, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FeedStockMovementsTable extends FeedStockMovements
    with TableInfo<$FeedStockMovementsTable, FeedStockMovement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeedStockMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityKgMeta = const VerificationMeta(
    'quantityKg',
  );
  @override
  late final GeneratedColumn<double> quantityKg = GeneratedColumn<double>(
    'quantity_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feedingIdMeta = const VerificationMeta(
    'feedingId',
  );
  @override
  late final GeneratedColumn<String> feedingId = GeneratedColumn<String>(
    'feeding_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    occurredAt,
    batchId,
    quantityKg,
    feedingId,
    notes,
    createdBy,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feed_stock_movements';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeedStockMovement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('quantity_kg')) {
      context.handle(
        _quantityKgMeta,
        quantityKg.isAcceptableOrUnknown(data['quantity_kg']!, _quantityKgMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityKgMeta);
    }
    if (data.containsKey('feeding_id')) {
      context.handle(
        _feedingIdMeta,
        feedingId.isAcceptableOrUnknown(data['feeding_id']!, _feedingIdMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FeedStockMovement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeedStockMovement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      )!,
      quantityKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity_kg'],
      )!,
      feedingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feeding_id'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FeedStockMovementsTable createAlias(String alias) {
    return $FeedStockMovementsTable(attachedDatabase, alias);
  }
}

class FeedStockMovement extends DataClass
    implements Insertable<FeedStockMovement> {
  final String id;
  final String type;
  final DateTime occurredAt;
  final String batchId;
  final double quantityKg;
  final String? feedingId;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  const FeedStockMovement({
    required this.id,
    required this.type,
    required this.occurredAt,
    required this.batchId,
    required this.quantityKg,
    this.feedingId,
    this.notes,
    required this.createdBy,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['batch_id'] = Variable<String>(batchId);
    map['quantity_kg'] = Variable<double>(quantityKg);
    if (!nullToAbsent || feedingId != null) {
      map['feeding_id'] = Variable<String>(feedingId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_by'] = Variable<String>(createdBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FeedStockMovementsCompanion toCompanion(bool nullToAbsent) {
    return FeedStockMovementsCompanion(
      id: Value(id),
      type: Value(type),
      occurredAt: Value(occurredAt),
      batchId: Value(batchId),
      quantityKg: Value(quantityKg),
      feedingId: feedingId == null && nullToAbsent
          ? const Value.absent()
          : Value(feedingId),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
    );
  }

  factory FeedStockMovement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeedStockMovement(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      batchId: serializer.fromJson<String>(json['batchId']),
      quantityKg: serializer.fromJson<double>(json['quantityKg']),
      feedingId: serializer.fromJson<String?>(json['feedingId']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'batchId': serializer.toJson<String>(batchId),
      'quantityKg': serializer.toJson<double>(quantityKg),
      'feedingId': serializer.toJson<String?>(feedingId),
      'notes': serializer.toJson<String?>(notes),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FeedStockMovement copyWith({
    String? id,
    String? type,
    DateTime? occurredAt,
    String? batchId,
    double? quantityKg,
    Value<String?> feedingId = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    String? createdBy,
    DateTime? createdAt,
  }) => FeedStockMovement(
    id: id ?? this.id,
    type: type ?? this.type,
    occurredAt: occurredAt ?? this.occurredAt,
    batchId: batchId ?? this.batchId,
    quantityKg: quantityKg ?? this.quantityKg,
    feedingId: feedingId.present ? feedingId.value : this.feedingId,
    notes: notes.present ? notes.value : this.notes,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
  );
  FeedStockMovement copyWithCompanion(FeedStockMovementsCompanion data) {
    return FeedStockMovement(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      quantityKg: data.quantityKg.present
          ? data.quantityKg.value
          : this.quantityKg,
      feedingId: data.feedingId.present ? data.feedingId.value : this.feedingId,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeedStockMovement(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('batchId: $batchId, ')
          ..write('quantityKg: $quantityKg, ')
          ..write('feedingId: $feedingId, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    occurredAt,
    batchId,
    quantityKg,
    feedingId,
    notes,
    createdBy,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedStockMovement &&
          other.id == this.id &&
          other.type == this.type &&
          other.occurredAt == this.occurredAt &&
          other.batchId == this.batchId &&
          other.quantityKg == this.quantityKg &&
          other.feedingId == this.feedingId &&
          other.notes == this.notes &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt);
}

class FeedStockMovementsCompanion extends UpdateCompanion<FeedStockMovement> {
  final Value<String> id;
  final Value<String> type;
  final Value<DateTime> occurredAt;
  final Value<String> batchId;
  final Value<double> quantityKg;
  final Value<String?> feedingId;
  final Value<String?> notes;
  final Value<String> createdBy;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const FeedStockMovementsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.batchId = const Value.absent(),
    this.quantityKg = const Value.absent(),
    this.feedingId = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeedStockMovementsCompanion.insert({
    required String id,
    required String type,
    required DateTime occurredAt,
    required String batchId,
    required double quantityKg,
    this.feedingId = const Value.absent(),
    this.notes = const Value.absent(),
    required String createdBy,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       occurredAt = Value(occurredAt),
       batchId = Value(batchId),
       quantityKg = Value(quantityKg),
       createdBy = Value(createdBy),
       createdAt = Value(createdAt);
  static Insertable<FeedStockMovement> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<DateTime>? occurredAt,
    Expression<String>? batchId,
    Expression<double>? quantityKg,
    Expression<String>? feedingId,
    Expression<String>? notes,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (batchId != null) 'batch_id': batchId,
      if (quantityKg != null) 'quantity_kg': quantityKg,
      if (feedingId != null) 'feeding_id': feedingId,
      if (notes != null) 'notes': notes,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FeedStockMovementsCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<DateTime>? occurredAt,
    Value<String>? batchId,
    Value<double>? quantityKg,
    Value<String?>? feedingId,
    Value<String?>? notes,
    Value<String>? createdBy,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return FeedStockMovementsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      occurredAt: occurredAt ?? this.occurredAt,
      batchId: batchId ?? this.batchId,
      quantityKg: quantityKg ?? this.quantityKg,
      feedingId: feedingId ?? this.feedingId,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (quantityKg.present) {
      map['quantity_kg'] = Variable<double>(quantityKg.value);
    }
    if (feedingId.present) {
      map['feeding_id'] = Variable<String>(feedingId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeedStockMovementsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('batchId: $batchId, ')
          ..write('quantityKg: $quantityKg, ')
          ..write('feedingId: $feedingId, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyFeedingsTable extends DailyFeedings
    with TableInfo<$DailyFeedingsTable, DailyFeeding> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyFeedingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feedingDateMeta = const VerificationMeta(
    'feedingDate',
  );
  @override
  late final GeneratedColumn<DateTime> feedingDate = GeneratedColumn<DateTime>(
    'feeding_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lotIdMeta = const VerificationMeta('lotId');
  @override
  late final GeneratedColumn<String> lotId = GeneratedColumn<String>(
    'lot_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityKgMeta = const VerificationMeta(
    'quantityKg',
  );
  @override
  late final GeneratedColumn<double> quantityKg = GeneratedColumn<double>(
    'quantity_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    feedingDate,
    lotId,
    batchId,
    quantityKg,
    notes,
    createdBy,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_feedings';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyFeeding> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('feeding_date')) {
      context.handle(
        _feedingDateMeta,
        feedingDate.isAcceptableOrUnknown(
          data['feeding_date']!,
          _feedingDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_feedingDateMeta);
    }
    if (data.containsKey('lot_id')) {
      context.handle(
        _lotIdMeta,
        lotId.isAcceptableOrUnknown(data['lot_id']!, _lotIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lotIdMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('quantity_kg')) {
      context.handle(
        _quantityKgMeta,
        quantityKg.isAcceptableOrUnknown(data['quantity_kg']!, _quantityKgMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityKgMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailyFeeding map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyFeeding(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      feedingDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}feeding_date'],
      )!,
      lotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lot_id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      )!,
      quantityKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity_kg'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DailyFeedingsTable createAlias(String alias) {
    return $DailyFeedingsTable(attachedDatabase, alias);
  }
}

class DailyFeeding extends DataClass implements Insertable<DailyFeeding> {
  final String id;
  final DateTime feedingDate;
  final String lotId;
  final String batchId;
  final double quantityKg;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  const DailyFeeding({
    required this.id,
    required this.feedingDate,
    required this.lotId,
    required this.batchId,
    required this.quantityKg,
    this.notes,
    required this.createdBy,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['feeding_date'] = Variable<DateTime>(feedingDate);
    map['lot_id'] = Variable<String>(lotId);
    map['batch_id'] = Variable<String>(batchId);
    map['quantity_kg'] = Variable<double>(quantityKg);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_by'] = Variable<String>(createdBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DailyFeedingsCompanion toCompanion(bool nullToAbsent) {
    return DailyFeedingsCompanion(
      id: Value(id),
      feedingDate: Value(feedingDate),
      lotId: Value(lotId),
      batchId: Value(batchId),
      quantityKg: Value(quantityKg),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
    );
  }

  factory DailyFeeding.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyFeeding(
      id: serializer.fromJson<String>(json['id']),
      feedingDate: serializer.fromJson<DateTime>(json['feedingDate']),
      lotId: serializer.fromJson<String>(json['lotId']),
      batchId: serializer.fromJson<String>(json['batchId']),
      quantityKg: serializer.fromJson<double>(json['quantityKg']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'feedingDate': serializer.toJson<DateTime>(feedingDate),
      'lotId': serializer.toJson<String>(lotId),
      'batchId': serializer.toJson<String>(batchId),
      'quantityKg': serializer.toJson<double>(quantityKg),
      'notes': serializer.toJson<String?>(notes),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DailyFeeding copyWith({
    String? id,
    DateTime? feedingDate,
    String? lotId,
    String? batchId,
    double? quantityKg,
    Value<String?> notes = const Value.absent(),
    String? createdBy,
    DateTime? createdAt,
  }) => DailyFeeding(
    id: id ?? this.id,
    feedingDate: feedingDate ?? this.feedingDate,
    lotId: lotId ?? this.lotId,
    batchId: batchId ?? this.batchId,
    quantityKg: quantityKg ?? this.quantityKg,
    notes: notes.present ? notes.value : this.notes,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
  );
  DailyFeeding copyWithCompanion(DailyFeedingsCompanion data) {
    return DailyFeeding(
      id: data.id.present ? data.id.value : this.id,
      feedingDate: data.feedingDate.present
          ? data.feedingDate.value
          : this.feedingDate,
      lotId: data.lotId.present ? data.lotId.value : this.lotId,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      quantityKg: data.quantityKg.present
          ? data.quantityKg.value
          : this.quantityKg,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyFeeding(')
          ..write('id: $id, ')
          ..write('feedingDate: $feedingDate, ')
          ..write('lotId: $lotId, ')
          ..write('batchId: $batchId, ')
          ..write('quantityKg: $quantityKg, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    feedingDate,
    lotId,
    batchId,
    quantityKg,
    notes,
    createdBy,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyFeeding &&
          other.id == this.id &&
          other.feedingDate == this.feedingDate &&
          other.lotId == this.lotId &&
          other.batchId == this.batchId &&
          other.quantityKg == this.quantityKg &&
          other.notes == this.notes &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt);
}

class DailyFeedingsCompanion extends UpdateCompanion<DailyFeeding> {
  final Value<String> id;
  final Value<DateTime> feedingDate;
  final Value<String> lotId;
  final Value<String> batchId;
  final Value<double> quantityKg;
  final Value<String?> notes;
  final Value<String> createdBy;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DailyFeedingsCompanion({
    this.id = const Value.absent(),
    this.feedingDate = const Value.absent(),
    this.lotId = const Value.absent(),
    this.batchId = const Value.absent(),
    this.quantityKg = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyFeedingsCompanion.insert({
    required String id,
    required DateTime feedingDate,
    required String lotId,
    required String batchId,
    required double quantityKg,
    this.notes = const Value.absent(),
    required String createdBy,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       feedingDate = Value(feedingDate),
       lotId = Value(lotId),
       batchId = Value(batchId),
       quantityKg = Value(quantityKg),
       createdBy = Value(createdBy),
       createdAt = Value(createdAt);
  static Insertable<DailyFeeding> custom({
    Expression<String>? id,
    Expression<DateTime>? feedingDate,
    Expression<String>? lotId,
    Expression<String>? batchId,
    Expression<double>? quantityKg,
    Expression<String>? notes,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (feedingDate != null) 'feeding_date': feedingDate,
      if (lotId != null) 'lot_id': lotId,
      if (batchId != null) 'batch_id': batchId,
      if (quantityKg != null) 'quantity_kg': quantityKg,
      if (notes != null) 'notes': notes,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyFeedingsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? feedingDate,
    Value<String>? lotId,
    Value<String>? batchId,
    Value<double>? quantityKg,
    Value<String?>? notes,
    Value<String>? createdBy,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return DailyFeedingsCompanion(
      id: id ?? this.id,
      feedingDate: feedingDate ?? this.feedingDate,
      lotId: lotId ?? this.lotId,
      batchId: batchId ?? this.batchId,
      quantityKg: quantityKg ?? this.quantityKg,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (feedingDate.present) {
      map['feeding_date'] = Variable<DateTime>(feedingDate.value);
    }
    if (lotId.present) {
      map['lot_id'] = Variable<String>(lotId.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (quantityKg.present) {
      map['quantity_kg'] = Variable<double>(quantityKg.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyFeedingsCompanion(')
          ..write('id: $id, ')
          ..write('feedingDate: $feedingDate, ')
          ..write('lotId: $lotId, ')
          ..write('batchId: $batchId, ')
          ..write('quantityKg: $quantityKg, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, Customer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    phone,
    address,
    notes,
    isActive,
    createdAt,
    createdBy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Customer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Customer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Customer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class Customer extends DataClass implements Insertable<Customer> {
  final String id;
  final String name;
  final String? phone;
  final String? address;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final String createdBy;
  const Customer({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    this.notes,
    required this.isActive,
    required this.createdAt,
    required this.createdBy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['created_by'] = Variable<String>(createdBy);
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      name: Value(name),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      createdBy: Value(createdBy),
    );
  }

  factory Customer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Customer(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      address: serializer.fromJson<String?>(json['address']),
      notes: serializer.fromJson<String?>(json['notes']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'address': serializer.toJson<String?>(address),
      'notes': serializer.toJson<String?>(notes),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'createdBy': serializer.toJson<String>(createdBy),
    };
  }

  Customer copyWith({
    String? id,
    String? name,
    Value<String?> phone = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
    String? createdBy,
  }) => Customer(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone.present ? phone.value : this.phone,
    address: address.present ? address.value : this.address,
    notes: notes.present ? notes.value : this.notes,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    createdBy: createdBy ?? this.createdBy,
  );
  Customer copyWithCompanion(CustomersCompanion data) {
    return Customer(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      address: data.address.present ? data.address.value : this.address,
      notes: data.notes.present ? data.notes.value : this.notes,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Customer(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    phone,
    address,
    notes,
    isActive,
    createdAt,
    createdBy,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Customer &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.address == this.address &&
          other.notes == this.notes &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy);
}

class CustomersCompanion extends UpdateCompanion<Customer> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> address;
  final Value<String?> notes;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<String> createdBy;
  final Value<int> rowid;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomersCompanion.insert({
    required String id,
    required String name,
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    required String createdBy,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       createdBy = Value(createdBy);
  static Insertable<Customer> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? address,
    Expression<String>? notes,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<String>? createdBy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (notes != null) 'notes': notes,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (createdBy != null) 'created_by': createdBy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? phone,
    Value<String?>? address,
    Value<String?>? notes,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<String>? createdBy,
    Value<int>? rowid,
  }) {
    return CustomersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OrdersTable extends Orders with TableInfo<$OrdersTable, Order> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderNumberMeta = const VerificationMeta(
    'orderNumber',
  );
  @override
  late final GeneratedColumn<int> orderNumber = GeneratedColumn<int>(
    'order_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _requestedDateMeta = const VerificationMeta(
    'requestedDate',
  );
  @override
  late final GeneratedColumn<DateTime> requestedDate =
      GeneratedColumn<DateTime>(
        'requested_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _expectedDeliveryDateMeta =
      const VerificationMeta('expectedDeliveryDate');
  @override
  late final GeneratedColumn<DateTime> expectedDeliveryDate =
      GeneratedColumn<DateTime>(
        'expected_delivery_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('DRAFT'),
  );
  static const VerificationMeta _subtotalCentsMeta = const VerificationMeta(
    'subtotalCents',
  );
  @override
  late final GeneratedColumn<int> subtotalCents = GeneratedColumn<int>(
    'subtotal_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountCentsMeta = const VerificationMeta(
    'discountCents',
  );
  @override
  late final GeneratedColumn<int> discountCents = GeneratedColumn<int>(
    'discount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalCentsMeta = const VerificationMeta(
    'totalCents',
  );
  @override
  late final GeneratedColumn<int> totalCents = GeneratedColumn<int>(
    'total_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    orderNumber,
    customerId,
    requestedDate,
    expectedDeliveryDate,
    status,
    subtotalCents,
    discountCents,
    totalCents,
    notes,
    createdBy,
    updatedBy,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'orders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Order> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('order_number')) {
      context.handle(
        _orderNumberMeta,
        orderNumber.isAcceptableOrUnknown(
          data['order_number']!,
          _orderNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_orderNumberMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    }
    if (data.containsKey('requested_date')) {
      context.handle(
        _requestedDateMeta,
        requestedDate.isAcceptableOrUnknown(
          data['requested_date']!,
          _requestedDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestedDateMeta);
    }
    if (data.containsKey('expected_delivery_date')) {
      context.handle(
        _expectedDeliveryDateMeta,
        expectedDeliveryDate.isAcceptableOrUnknown(
          data['expected_delivery_date']!,
          _expectedDeliveryDateMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('subtotal_cents')) {
      context.handle(
        _subtotalCentsMeta,
        subtotalCents.isAcceptableOrUnknown(
          data['subtotal_cents']!,
          _subtotalCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subtotalCentsMeta);
    }
    if (data.containsKey('discount_cents')) {
      context.handle(
        _discountCentsMeta,
        discountCents.isAcceptableOrUnknown(
          data['discount_cents']!,
          _discountCentsMeta,
        ),
      );
    }
    if (data.containsKey('total_cents')) {
      context.handle(
        _totalCentsMeta,
        totalCents.isAcceptableOrUnknown(data['total_cents']!, _totalCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_totalCentsMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Order map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Order(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      orderNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_number'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      ),
      requestedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}requested_date'],
      )!,
      expectedDeliveryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expected_delivery_date'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      subtotalCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subtotal_cents'],
      )!,
      discountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discount_cents'],
      )!,
      totalCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_cents'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $OrdersTable createAlias(String alias) {
    return $OrdersTable(attachedDatabase, alias);
  }
}

class Order extends DataClass implements Insertable<Order> {
  final String id;
  final int orderNumber;
  final String? customerId;
  final DateTime requestedDate;
  final DateTime? expectedDeliveryDate;
  final String status;
  final int subtotalCents;
  final int discountCents;
  final int totalCents;
  final String? notes;
  final String createdBy;
  final String updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Order({
    required this.id,
    required this.orderNumber,
    this.customerId,
    required this.requestedDate,
    this.expectedDeliveryDate,
    required this.status,
    required this.subtotalCents,
    required this.discountCents,
    required this.totalCents,
    this.notes,
    required this.createdBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['order_number'] = Variable<int>(orderNumber);
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    map['requested_date'] = Variable<DateTime>(requestedDate);
    if (!nullToAbsent || expectedDeliveryDate != null) {
      map['expected_delivery_date'] = Variable<DateTime>(expectedDeliveryDate);
    }
    map['status'] = Variable<String>(status);
    map['subtotal_cents'] = Variable<int>(subtotalCents);
    map['discount_cents'] = Variable<int>(discountCents);
    map['total_cents'] = Variable<int>(totalCents);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_by'] = Variable<String>(createdBy);
    map['updated_by'] = Variable<String>(updatedBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  OrdersCompanion toCompanion(bool nullToAbsent) {
    return OrdersCompanion(
      id: Value(id),
      orderNumber: Value(orderNumber),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      requestedDate: Value(requestedDate),
      expectedDeliveryDate: expectedDeliveryDate == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedDeliveryDate),
      status: Value(status),
      subtotalCents: Value(subtotalCents),
      discountCents: Value(discountCents),
      totalCents: Value(totalCents),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdBy: Value(createdBy),
      updatedBy: Value(updatedBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Order.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Order(
      id: serializer.fromJson<String>(json['id']),
      orderNumber: serializer.fromJson<int>(json['orderNumber']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      requestedDate: serializer.fromJson<DateTime>(json['requestedDate']),
      expectedDeliveryDate: serializer.fromJson<DateTime?>(
        json['expectedDeliveryDate'],
      ),
      status: serializer.fromJson<String>(json['status']),
      subtotalCents: serializer.fromJson<int>(json['subtotalCents']),
      discountCents: serializer.fromJson<int>(json['discountCents']),
      totalCents: serializer.fromJson<int>(json['totalCents']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'orderNumber': serializer.toJson<int>(orderNumber),
      'customerId': serializer.toJson<String?>(customerId),
      'requestedDate': serializer.toJson<DateTime>(requestedDate),
      'expectedDeliveryDate': serializer.toJson<DateTime?>(
        expectedDeliveryDate,
      ),
      'status': serializer.toJson<String>(status),
      'subtotalCents': serializer.toJson<int>(subtotalCents),
      'discountCents': serializer.toJson<int>(discountCents),
      'totalCents': serializer.toJson<int>(totalCents),
      'notes': serializer.toJson<String?>(notes),
      'createdBy': serializer.toJson<String>(createdBy),
      'updatedBy': serializer.toJson<String>(updatedBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Order copyWith({
    String? id,
    int? orderNumber,
    Value<String?> customerId = const Value.absent(),
    DateTime? requestedDate,
    Value<DateTime?> expectedDeliveryDate = const Value.absent(),
    String? status,
    int? subtotalCents,
    int? discountCents,
    int? totalCents,
    Value<String?> notes = const Value.absent(),
    String? createdBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Order(
    id: id ?? this.id,
    orderNumber: orderNumber ?? this.orderNumber,
    customerId: customerId.present ? customerId.value : this.customerId,
    requestedDate: requestedDate ?? this.requestedDate,
    expectedDeliveryDate: expectedDeliveryDate.present
        ? expectedDeliveryDate.value
        : this.expectedDeliveryDate,
    status: status ?? this.status,
    subtotalCents: subtotalCents ?? this.subtotalCents,
    discountCents: discountCents ?? this.discountCents,
    totalCents: totalCents ?? this.totalCents,
    notes: notes.present ? notes.value : this.notes,
    createdBy: createdBy ?? this.createdBy,
    updatedBy: updatedBy ?? this.updatedBy,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Order copyWithCompanion(OrdersCompanion data) {
    return Order(
      id: data.id.present ? data.id.value : this.id,
      orderNumber: data.orderNumber.present
          ? data.orderNumber.value
          : this.orderNumber,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      requestedDate: data.requestedDate.present
          ? data.requestedDate.value
          : this.requestedDate,
      expectedDeliveryDate: data.expectedDeliveryDate.present
          ? data.expectedDeliveryDate.value
          : this.expectedDeliveryDate,
      status: data.status.present ? data.status.value : this.status,
      subtotalCents: data.subtotalCents.present
          ? data.subtotalCents.value
          : this.subtotalCents,
      discountCents: data.discountCents.present
          ? data.discountCents.value
          : this.discountCents,
      totalCents: data.totalCents.present
          ? data.totalCents.value
          : this.totalCents,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Order(')
          ..write('id: $id, ')
          ..write('orderNumber: $orderNumber, ')
          ..write('customerId: $customerId, ')
          ..write('requestedDate: $requestedDate, ')
          ..write('expectedDeliveryDate: $expectedDeliveryDate, ')
          ..write('status: $status, ')
          ..write('subtotalCents: $subtotalCents, ')
          ..write('discountCents: $discountCents, ')
          ..write('totalCents: $totalCents, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    orderNumber,
    customerId,
    requestedDate,
    expectedDeliveryDate,
    status,
    subtotalCents,
    discountCents,
    totalCents,
    notes,
    createdBy,
    updatedBy,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Order &&
          other.id == this.id &&
          other.orderNumber == this.orderNumber &&
          other.customerId == this.customerId &&
          other.requestedDate == this.requestedDate &&
          other.expectedDeliveryDate == this.expectedDeliveryDate &&
          other.status == this.status &&
          other.subtotalCents == this.subtotalCents &&
          other.discountCents == this.discountCents &&
          other.totalCents == this.totalCents &&
          other.notes == this.notes &&
          other.createdBy == this.createdBy &&
          other.updatedBy == this.updatedBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class OrdersCompanion extends UpdateCompanion<Order> {
  final Value<String> id;
  final Value<int> orderNumber;
  final Value<String?> customerId;
  final Value<DateTime> requestedDate;
  final Value<DateTime?> expectedDeliveryDate;
  final Value<String> status;
  final Value<int> subtotalCents;
  final Value<int> discountCents;
  final Value<int> totalCents;
  final Value<String?> notes;
  final Value<String> createdBy;
  final Value<String> updatedBy;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const OrdersCompanion({
    this.id = const Value.absent(),
    this.orderNumber = const Value.absent(),
    this.customerId = const Value.absent(),
    this.requestedDate = const Value.absent(),
    this.expectedDeliveryDate = const Value.absent(),
    this.status = const Value.absent(),
    this.subtotalCents = const Value.absent(),
    this.discountCents = const Value.absent(),
    this.totalCents = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrdersCompanion.insert({
    required String id,
    required int orderNumber,
    this.customerId = const Value.absent(),
    required DateTime requestedDate,
    this.expectedDeliveryDate = const Value.absent(),
    this.status = const Value.absent(),
    required int subtotalCents,
    this.discountCents = const Value.absent(),
    required int totalCents,
    this.notes = const Value.absent(),
    required String createdBy,
    required String updatedBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       orderNumber = Value(orderNumber),
       requestedDate = Value(requestedDate),
       subtotalCents = Value(subtotalCents),
       totalCents = Value(totalCents),
       createdBy = Value(createdBy),
       updatedBy = Value(updatedBy),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Order> custom({
    Expression<String>? id,
    Expression<int>? orderNumber,
    Expression<String>? customerId,
    Expression<DateTime>? requestedDate,
    Expression<DateTime>? expectedDeliveryDate,
    Expression<String>? status,
    Expression<int>? subtotalCents,
    Expression<int>? discountCents,
    Expression<int>? totalCents,
    Expression<String>? notes,
    Expression<String>? createdBy,
    Expression<String>? updatedBy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orderNumber != null) 'order_number': orderNumber,
      if (customerId != null) 'customer_id': customerId,
      if (requestedDate != null) 'requested_date': requestedDate,
      if (expectedDeliveryDate != null)
        'expected_delivery_date': expectedDeliveryDate,
      if (status != null) 'status': status,
      if (subtotalCents != null) 'subtotal_cents': subtotalCents,
      if (discountCents != null) 'discount_cents': discountCents,
      if (totalCents != null) 'total_cents': totalCents,
      if (notes != null) 'notes': notes,
      if (createdBy != null) 'created_by': createdBy,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrdersCompanion copyWith({
    Value<String>? id,
    Value<int>? orderNumber,
    Value<String?>? customerId,
    Value<DateTime>? requestedDate,
    Value<DateTime?>? expectedDeliveryDate,
    Value<String>? status,
    Value<int>? subtotalCents,
    Value<int>? discountCents,
    Value<int>? totalCents,
    Value<String?>? notes,
    Value<String>? createdBy,
    Value<String>? updatedBy,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return OrdersCompanion(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      requestedDate: requestedDate ?? this.requestedDate,
      expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
      status: status ?? this.status,
      subtotalCents: subtotalCents ?? this.subtotalCents,
      discountCents: discountCents ?? this.discountCents,
      totalCents: totalCents ?? this.totalCents,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (orderNumber.present) {
      map['order_number'] = Variable<int>(orderNumber.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (requestedDate.present) {
      map['requested_date'] = Variable<DateTime>(requestedDate.value);
    }
    if (expectedDeliveryDate.present) {
      map['expected_delivery_date'] = Variable<DateTime>(
        expectedDeliveryDate.value,
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (subtotalCents.present) {
      map['subtotal_cents'] = Variable<int>(subtotalCents.value);
    }
    if (discountCents.present) {
      map['discount_cents'] = Variable<int>(discountCents.value);
    }
    if (totalCents.present) {
      map['total_cents'] = Variable<int>(totalCents.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrdersCompanion(')
          ..write('id: $id, ')
          ..write('orderNumber: $orderNumber, ')
          ..write('customerId: $customerId, ')
          ..write('requestedDate: $requestedDate, ')
          ..write('expectedDeliveryDate: $expectedDeliveryDate, ')
          ..write('status: $status, ')
          ..write('subtotalCents: $subtotalCents, ')
          ..write('discountCents: $discountCents, ')
          ..write('totalCents: $totalCents, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OrderItemsTable extends OrderItems
    with TableInfo<$OrderItemsTable, OrderItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrderItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIdMeta = const VerificationMeta(
    'orderId',
  );
  @override
  late final GeneratedColumn<String> orderId = GeneratedColumn<String>(
    'order_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productTypeMeta = const VerificationMeta(
    'productType',
  );
  @override
  late final GeneratedColumn<String> productType = GeneratedColumn<String>(
    'product_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPriceCentsMeta = const VerificationMeta(
    'unitPriceCents',
  );
  @override
  late final GeneratedColumn<int> unitPriceCents = GeneratedColumn<int>(
    'unit_price_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalCentsMeta = const VerificationMeta(
    'totalCents',
  );
  @override
  late final GeneratedColumn<int> totalCents = GeneratedColumn<int>(
    'total_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    orderId,
    productType,
    quantity,
    unitPriceCents,
    totalCents,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'order_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<OrderItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('order_id')) {
      context.handle(
        _orderIdMeta,
        orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('product_type')) {
      context.handle(
        _productTypeMeta,
        productType.isAcceptableOrUnknown(
          data['product_type']!,
          _productTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productTypeMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_price_cents')) {
      context.handle(
        _unitPriceCentsMeta,
        unitPriceCents.isAcceptableOrUnknown(
          data['unit_price_cents']!,
          _unitPriceCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitPriceCentsMeta);
    }
    if (data.containsKey('total_cents')) {
      context.handle(
        _totalCentsMeta,
        totalCents.isAcceptableOrUnknown(data['total_cents']!, _totalCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_totalCentsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrderItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      orderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_id'],
      )!,
      productType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_type'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      unitPriceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_price_cents'],
      )!,
      totalCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_cents'],
      )!,
    );
  }

  @override
  $OrderItemsTable createAlias(String alias) {
    return $OrderItemsTable(attachedDatabase, alias);
  }
}

class OrderItem extends DataClass implements Insertable<OrderItem> {
  final String id;
  final String orderId;
  final String productType;
  final double quantity;
  final int unitPriceCents;
  final int totalCents;
  const OrderItem({
    required this.id,
    required this.orderId,
    required this.productType,
    required this.quantity,
    required this.unitPriceCents,
    required this.totalCents,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['order_id'] = Variable<String>(orderId);
    map['product_type'] = Variable<String>(productType);
    map['quantity'] = Variable<double>(quantity);
    map['unit_price_cents'] = Variable<int>(unitPriceCents);
    map['total_cents'] = Variable<int>(totalCents);
    return map;
  }

  OrderItemsCompanion toCompanion(bool nullToAbsent) {
    return OrderItemsCompanion(
      id: Value(id),
      orderId: Value(orderId),
      productType: Value(productType),
      quantity: Value(quantity),
      unitPriceCents: Value(unitPriceCents),
      totalCents: Value(totalCents),
    );
  }

  factory OrderItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderItem(
      id: serializer.fromJson<String>(json['id']),
      orderId: serializer.fromJson<String>(json['orderId']),
      productType: serializer.fromJson<String>(json['productType']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unitPriceCents: serializer.fromJson<int>(json['unitPriceCents']),
      totalCents: serializer.fromJson<int>(json['totalCents']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'orderId': serializer.toJson<String>(orderId),
      'productType': serializer.toJson<String>(productType),
      'quantity': serializer.toJson<double>(quantity),
      'unitPriceCents': serializer.toJson<int>(unitPriceCents),
      'totalCents': serializer.toJson<int>(totalCents),
    };
  }

  OrderItem copyWith({
    String? id,
    String? orderId,
    String? productType,
    double? quantity,
    int? unitPriceCents,
    int? totalCents,
  }) => OrderItem(
    id: id ?? this.id,
    orderId: orderId ?? this.orderId,
    productType: productType ?? this.productType,
    quantity: quantity ?? this.quantity,
    unitPriceCents: unitPriceCents ?? this.unitPriceCents,
    totalCents: totalCents ?? this.totalCents,
  );
  OrderItem copyWithCompanion(OrderItemsCompanion data) {
    return OrderItem(
      id: data.id.present ? data.id.value : this.id,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      productType: data.productType.present
          ? data.productType.value
          : this.productType,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPriceCents: data.unitPriceCents.present
          ? data.unitPriceCents.value
          : this.unitPriceCents,
      totalCents: data.totalCents.present
          ? data.totalCents.value
          : this.totalCents,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderItem(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('productType: $productType, ')
          ..write('quantity: $quantity, ')
          ..write('unitPriceCents: $unitPriceCents, ')
          ..write('totalCents: $totalCents')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    orderId,
    productType,
    quantity,
    unitPriceCents,
    totalCents,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderItem &&
          other.id == this.id &&
          other.orderId == this.orderId &&
          other.productType == this.productType &&
          other.quantity == this.quantity &&
          other.unitPriceCents == this.unitPriceCents &&
          other.totalCents == this.totalCents);
}

class OrderItemsCompanion extends UpdateCompanion<OrderItem> {
  final Value<String> id;
  final Value<String> orderId;
  final Value<String> productType;
  final Value<double> quantity;
  final Value<int> unitPriceCents;
  final Value<int> totalCents;
  final Value<int> rowid;
  const OrderItemsCompanion({
    this.id = const Value.absent(),
    this.orderId = const Value.absent(),
    this.productType = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPriceCents = const Value.absent(),
    this.totalCents = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrderItemsCompanion.insert({
    required String id,
    required String orderId,
    required String productType,
    required double quantity,
    required int unitPriceCents,
    required int totalCents,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       orderId = Value(orderId),
       productType = Value(productType),
       quantity = Value(quantity),
       unitPriceCents = Value(unitPriceCents),
       totalCents = Value(totalCents);
  static Insertable<OrderItem> custom({
    Expression<String>? id,
    Expression<String>? orderId,
    Expression<String>? productType,
    Expression<double>? quantity,
    Expression<int>? unitPriceCents,
    Expression<int>? totalCents,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orderId != null) 'order_id': orderId,
      if (productType != null) 'product_type': productType,
      if (quantity != null) 'quantity': quantity,
      if (unitPriceCents != null) 'unit_price_cents': unitPriceCents,
      if (totalCents != null) 'total_cents': totalCents,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrderItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? orderId,
    Value<String>? productType,
    Value<double>? quantity,
    Value<int>? unitPriceCents,
    Value<int>? totalCents,
    Value<int>? rowid,
  }) {
    return OrderItemsCompanion(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productType: productType ?? this.productType,
      quantity: quantity ?? this.quantity,
      unitPriceCents: unitPriceCents ?? this.unitPriceCents,
      totalCents: totalCents ?? this.totalCents,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<String>(orderId.value);
    }
    if (productType.present) {
      map['product_type'] = Variable<String>(productType.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unitPriceCents.present) {
      map['unit_price_cents'] = Variable<int>(unitPriceCents.value);
    }
    if (totalCents.present) {
      map['total_cents'] = Variable<int>(totalCents.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrderItemsCompanion(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('productType: $productType, ')
          ..write('quantity: $quantity, ')
          ..write('unitPriceCents: $unitPriceCents, ')
          ..write('totalCents: $totalCents, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OrderStatusHistoryTable extends OrderStatusHistory
    with TableInfo<$OrderStatusHistoryTable, OrderStatusHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrderStatusHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIdMeta = const VerificationMeta(
    'orderId',
  );
  @override
  late final GeneratedColumn<String> orderId = GeneratedColumn<String>(
    'order_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _oldStatusMeta = const VerificationMeta(
    'oldStatus',
  );
  @override
  late final GeneratedColumn<String> oldStatus = GeneratedColumn<String>(
    'old_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _newStatusMeta = const VerificationMeta(
    'newStatus',
  );
  @override
  late final GeneratedColumn<String> newStatus = GeneratedColumn<String>(
    'new_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _changedAtMeta = const VerificationMeta(
    'changedAt',
  );
  @override
  late final GeneratedColumn<DateTime> changedAt = GeneratedColumn<DateTime>(
    'changed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _changedByMeta = const VerificationMeta(
    'changedBy',
  );
  @override
  late final GeneratedColumn<String> changedBy = GeneratedColumn<String>(
    'changed_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    orderId,
    oldStatus,
    newStatus,
    changedAt,
    changedBy,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'order_status_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<OrderStatusHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('order_id')) {
      context.handle(
        _orderIdMeta,
        orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('old_status')) {
      context.handle(
        _oldStatusMeta,
        oldStatus.isAcceptableOrUnknown(data['old_status']!, _oldStatusMeta),
      );
    }
    if (data.containsKey('new_status')) {
      context.handle(
        _newStatusMeta,
        newStatus.isAcceptableOrUnknown(data['new_status']!, _newStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_newStatusMeta);
    }
    if (data.containsKey('changed_at')) {
      context.handle(
        _changedAtMeta,
        changedAt.isAcceptableOrUnknown(data['changed_at']!, _changedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_changedAtMeta);
    }
    if (data.containsKey('changed_by')) {
      context.handle(
        _changedByMeta,
        changedBy.isAcceptableOrUnknown(data['changed_by']!, _changedByMeta),
      );
    } else if (isInserting) {
      context.missing(_changedByMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrderStatusHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderStatusHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      orderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_id'],
      )!,
      oldStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}old_status'],
      ),
      newStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}new_status'],
      )!,
      changedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}changed_at'],
      )!,
      changedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}changed_by'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $OrderStatusHistoryTable createAlias(String alias) {
    return $OrderStatusHistoryTable(attachedDatabase, alias);
  }
}

class OrderStatusHistoryData extends DataClass
    implements Insertable<OrderStatusHistoryData> {
  final String id;
  final String orderId;
  final String? oldStatus;
  final String newStatus;
  final DateTime changedAt;
  final String changedBy;
  final String? notes;
  const OrderStatusHistoryData({
    required this.id,
    required this.orderId,
    this.oldStatus,
    required this.newStatus,
    required this.changedAt,
    required this.changedBy,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['order_id'] = Variable<String>(orderId);
    if (!nullToAbsent || oldStatus != null) {
      map['old_status'] = Variable<String>(oldStatus);
    }
    map['new_status'] = Variable<String>(newStatus);
    map['changed_at'] = Variable<DateTime>(changedAt);
    map['changed_by'] = Variable<String>(changedBy);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  OrderStatusHistoryCompanion toCompanion(bool nullToAbsent) {
    return OrderStatusHistoryCompanion(
      id: Value(id),
      orderId: Value(orderId),
      oldStatus: oldStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(oldStatus),
      newStatus: Value(newStatus),
      changedAt: Value(changedAt),
      changedBy: Value(changedBy),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory OrderStatusHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderStatusHistoryData(
      id: serializer.fromJson<String>(json['id']),
      orderId: serializer.fromJson<String>(json['orderId']),
      oldStatus: serializer.fromJson<String?>(json['oldStatus']),
      newStatus: serializer.fromJson<String>(json['newStatus']),
      changedAt: serializer.fromJson<DateTime>(json['changedAt']),
      changedBy: serializer.fromJson<String>(json['changedBy']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'orderId': serializer.toJson<String>(orderId),
      'oldStatus': serializer.toJson<String?>(oldStatus),
      'newStatus': serializer.toJson<String>(newStatus),
      'changedAt': serializer.toJson<DateTime>(changedAt),
      'changedBy': serializer.toJson<String>(changedBy),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  OrderStatusHistoryData copyWith({
    String? id,
    String? orderId,
    Value<String?> oldStatus = const Value.absent(),
    String? newStatus,
    DateTime? changedAt,
    String? changedBy,
    Value<String?> notes = const Value.absent(),
  }) => OrderStatusHistoryData(
    id: id ?? this.id,
    orderId: orderId ?? this.orderId,
    oldStatus: oldStatus.present ? oldStatus.value : this.oldStatus,
    newStatus: newStatus ?? this.newStatus,
    changedAt: changedAt ?? this.changedAt,
    changedBy: changedBy ?? this.changedBy,
    notes: notes.present ? notes.value : this.notes,
  );
  OrderStatusHistoryData copyWithCompanion(OrderStatusHistoryCompanion data) {
    return OrderStatusHistoryData(
      id: data.id.present ? data.id.value : this.id,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      oldStatus: data.oldStatus.present ? data.oldStatus.value : this.oldStatus,
      newStatus: data.newStatus.present ? data.newStatus.value : this.newStatus,
      changedAt: data.changedAt.present ? data.changedAt.value : this.changedAt,
      changedBy: data.changedBy.present ? data.changedBy.value : this.changedBy,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderStatusHistoryData(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('oldStatus: $oldStatus, ')
          ..write('newStatus: $newStatus, ')
          ..write('changedAt: $changedAt, ')
          ..write('changedBy: $changedBy, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    orderId,
    oldStatus,
    newStatus,
    changedAt,
    changedBy,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderStatusHistoryData &&
          other.id == this.id &&
          other.orderId == this.orderId &&
          other.oldStatus == this.oldStatus &&
          other.newStatus == this.newStatus &&
          other.changedAt == this.changedAt &&
          other.changedBy == this.changedBy &&
          other.notes == this.notes);
}

class OrderStatusHistoryCompanion
    extends UpdateCompanion<OrderStatusHistoryData> {
  final Value<String> id;
  final Value<String> orderId;
  final Value<String?> oldStatus;
  final Value<String> newStatus;
  final Value<DateTime> changedAt;
  final Value<String> changedBy;
  final Value<String?> notes;
  final Value<int> rowid;
  const OrderStatusHistoryCompanion({
    this.id = const Value.absent(),
    this.orderId = const Value.absent(),
    this.oldStatus = const Value.absent(),
    this.newStatus = const Value.absent(),
    this.changedAt = const Value.absent(),
    this.changedBy = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrderStatusHistoryCompanion.insert({
    required String id,
    required String orderId,
    this.oldStatus = const Value.absent(),
    required String newStatus,
    required DateTime changedAt,
    required String changedBy,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       orderId = Value(orderId),
       newStatus = Value(newStatus),
       changedAt = Value(changedAt),
       changedBy = Value(changedBy);
  static Insertable<OrderStatusHistoryData> custom({
    Expression<String>? id,
    Expression<String>? orderId,
    Expression<String>? oldStatus,
    Expression<String>? newStatus,
    Expression<DateTime>? changedAt,
    Expression<String>? changedBy,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orderId != null) 'order_id': orderId,
      if (oldStatus != null) 'old_status': oldStatus,
      if (newStatus != null) 'new_status': newStatus,
      if (changedAt != null) 'changed_at': changedAt,
      if (changedBy != null) 'changed_by': changedBy,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrderStatusHistoryCompanion copyWith({
    Value<String>? id,
    Value<String>? orderId,
    Value<String?>? oldStatus,
    Value<String>? newStatus,
    Value<DateTime>? changedAt,
    Value<String>? changedBy,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return OrderStatusHistoryCompanion(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      oldStatus: oldStatus ?? this.oldStatus,
      newStatus: newStatus ?? this.newStatus,
      changedAt: changedAt ?? this.changedAt,
      changedBy: changedBy ?? this.changedBy,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<String>(orderId.value);
    }
    if (oldStatus.present) {
      map['old_status'] = Variable<String>(oldStatus.value);
    }
    if (newStatus.present) {
      map['new_status'] = Variable<String>(newStatus.value);
    }
    if (changedAt.present) {
      map['changed_at'] = Variable<DateTime>(changedAt.value);
    }
    if (changedBy.present) {
      map['changed_by'] = Variable<String>(changedBy.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrderStatusHistoryCompanion(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('oldStatus: $oldStatus, ')
          ..write('newStatus: $newStatus, ')
          ..write('changedAt: $changedAt, ')
          ..write('changedBy: $changedBy, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SalesTable extends Sales with TableInfo<$SalesTable, Sale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _soldAtMeta = const VerificationMeta('soldAt');
  @override
  late final GeneratedColumn<DateTime> soldAt = GeneratedColumn<DateTime>(
    'sold_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderIdMeta = const VerificationMeta(
    'orderId',
  );
  @override
  late final GeneratedColumn<String> orderId = GeneratedColumn<String>(
    'order_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _dozensMeta = const VerificationMeta('dozens');
  @override
  late final GeneratedColumn<int> dozens = GeneratedColumn<int>(
    'dozens',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _looseEggsMeta = const VerificationMeta(
    'looseEggs',
  );
  @override
  late final GeneratedColumn<int> looseEggs = GeneratedColumn<int>(
    'loose_eggs',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dozenPriceCentsMeta = const VerificationMeta(
    'dozenPriceCents',
  );
  @override
  late final GeneratedColumn<int> dozenPriceCents = GeneratedColumn<int>(
    'dozen_price_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalCentsMeta = const VerificationMeta(
    'totalCents',
  );
  @override
  late final GeneratedColumn<int> totalCents = GeneratedColumn<int>(
    'total_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('CONFIRMED'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    soldAt,
    customerId,
    orderId,
    dozens,
    looseEggs,
    dozenPriceCents,
    totalCents,
    paymentMethod,
    status,
    notes,
    createdBy,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sales';
  @override
  VerificationContext validateIntegrity(
    Insertable<Sale> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sold_at')) {
      context.handle(
        _soldAtMeta,
        soldAt.isAcceptableOrUnknown(data['sold_at']!, _soldAtMeta),
      );
    } else if (isInserting) {
      context.missing(_soldAtMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    }
    if (data.containsKey('order_id')) {
      context.handle(
        _orderIdMeta,
        orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta),
      );
    }
    if (data.containsKey('dozens')) {
      context.handle(
        _dozensMeta,
        dozens.isAcceptableOrUnknown(data['dozens']!, _dozensMeta),
      );
    }
    if (data.containsKey('loose_eggs')) {
      context.handle(
        _looseEggsMeta,
        looseEggs.isAcceptableOrUnknown(data['loose_eggs']!, _looseEggsMeta),
      );
    }
    if (data.containsKey('dozen_price_cents')) {
      context.handle(
        _dozenPriceCentsMeta,
        dozenPriceCents.isAcceptableOrUnknown(
          data['dozen_price_cents']!,
          _dozenPriceCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dozenPriceCentsMeta);
    }
    if (data.containsKey('total_cents')) {
      context.handle(
        _totalCentsMeta,
        totalCents.isAcceptableOrUnknown(data['total_cents']!, _totalCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_totalCentsMeta);
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentMethodMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Sale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sale(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      soldAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}sold_at'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      ),
      orderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_id'],
      ),
      dozens: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dozens'],
      )!,
      looseEggs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}loose_eggs'],
      )!,
      dozenPriceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dozen_price_cents'],
      )!,
      totalCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_cents'],
      )!,
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SalesTable createAlias(String alias) {
    return $SalesTable(attachedDatabase, alias);
  }
}

class Sale extends DataClass implements Insertable<Sale> {
  final String id;
  final DateTime soldAt;
  final String? customerId;
  final String? orderId;
  final int dozens;
  final int looseEggs;
  final int dozenPriceCents;
  final int totalCents;
  final String paymentMethod;
  final String status;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  const Sale({
    required this.id,
    required this.soldAt,
    this.customerId,
    this.orderId,
    required this.dozens,
    required this.looseEggs,
    required this.dozenPriceCents,
    required this.totalCents,
    required this.paymentMethod,
    required this.status,
    this.notes,
    required this.createdBy,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sold_at'] = Variable<DateTime>(soldAt);
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    if (!nullToAbsent || orderId != null) {
      map['order_id'] = Variable<String>(orderId);
    }
    map['dozens'] = Variable<int>(dozens);
    map['loose_eggs'] = Variable<int>(looseEggs);
    map['dozen_price_cents'] = Variable<int>(dozenPriceCents);
    map['total_cents'] = Variable<int>(totalCents);
    map['payment_method'] = Variable<String>(paymentMethod);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_by'] = Variable<String>(createdBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SalesCompanion toCompanion(bool nullToAbsent) {
    return SalesCompanion(
      id: Value(id),
      soldAt: Value(soldAt),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      orderId: orderId == null && nullToAbsent
          ? const Value.absent()
          : Value(orderId),
      dozens: Value(dozens),
      looseEggs: Value(looseEggs),
      dozenPriceCents: Value(dozenPriceCents),
      totalCents: Value(totalCents),
      paymentMethod: Value(paymentMethod),
      status: Value(status),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
    );
  }

  factory Sale.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sale(
      id: serializer.fromJson<String>(json['id']),
      soldAt: serializer.fromJson<DateTime>(json['soldAt']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      orderId: serializer.fromJson<String?>(json['orderId']),
      dozens: serializer.fromJson<int>(json['dozens']),
      looseEggs: serializer.fromJson<int>(json['looseEggs']),
      dozenPriceCents: serializer.fromJson<int>(json['dozenPriceCents']),
      totalCents: serializer.fromJson<int>(json['totalCents']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'soldAt': serializer.toJson<DateTime>(soldAt),
      'customerId': serializer.toJson<String?>(customerId),
      'orderId': serializer.toJson<String?>(orderId),
      'dozens': serializer.toJson<int>(dozens),
      'looseEggs': serializer.toJson<int>(looseEggs),
      'dozenPriceCents': serializer.toJson<int>(dozenPriceCents),
      'totalCents': serializer.toJson<int>(totalCents),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Sale copyWith({
    String? id,
    DateTime? soldAt,
    Value<String?> customerId = const Value.absent(),
    Value<String?> orderId = const Value.absent(),
    int? dozens,
    int? looseEggs,
    int? dozenPriceCents,
    int? totalCents,
    String? paymentMethod,
    String? status,
    Value<String?> notes = const Value.absent(),
    String? createdBy,
    DateTime? createdAt,
  }) => Sale(
    id: id ?? this.id,
    soldAt: soldAt ?? this.soldAt,
    customerId: customerId.present ? customerId.value : this.customerId,
    orderId: orderId.present ? orderId.value : this.orderId,
    dozens: dozens ?? this.dozens,
    looseEggs: looseEggs ?? this.looseEggs,
    dozenPriceCents: dozenPriceCents ?? this.dozenPriceCents,
    totalCents: totalCents ?? this.totalCents,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
  );
  Sale copyWithCompanion(SalesCompanion data) {
    return Sale(
      id: data.id.present ? data.id.value : this.id,
      soldAt: data.soldAt.present ? data.soldAt.value : this.soldAt,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      dozens: data.dozens.present ? data.dozens.value : this.dozens,
      looseEggs: data.looseEggs.present ? data.looseEggs.value : this.looseEggs,
      dozenPriceCents: data.dozenPriceCents.present
          ? data.dozenPriceCents.value
          : this.dozenPriceCents,
      totalCents: data.totalCents.present
          ? data.totalCents.value
          : this.totalCents,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sale(')
          ..write('id: $id, ')
          ..write('soldAt: $soldAt, ')
          ..write('customerId: $customerId, ')
          ..write('orderId: $orderId, ')
          ..write('dozens: $dozens, ')
          ..write('looseEggs: $looseEggs, ')
          ..write('dozenPriceCents: $dozenPriceCents, ')
          ..write('totalCents: $totalCents, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    soldAt,
    customerId,
    orderId,
    dozens,
    looseEggs,
    dozenPriceCents,
    totalCents,
    paymentMethod,
    status,
    notes,
    createdBy,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sale &&
          other.id == this.id &&
          other.soldAt == this.soldAt &&
          other.customerId == this.customerId &&
          other.orderId == this.orderId &&
          other.dozens == this.dozens &&
          other.looseEggs == this.looseEggs &&
          other.dozenPriceCents == this.dozenPriceCents &&
          other.totalCents == this.totalCents &&
          other.paymentMethod == this.paymentMethod &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt);
}

class SalesCompanion extends UpdateCompanion<Sale> {
  final Value<String> id;
  final Value<DateTime> soldAt;
  final Value<String?> customerId;
  final Value<String?> orderId;
  final Value<int> dozens;
  final Value<int> looseEggs;
  final Value<int> dozenPriceCents;
  final Value<int> totalCents;
  final Value<String> paymentMethod;
  final Value<String> status;
  final Value<String?> notes;
  final Value<String> createdBy;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SalesCompanion({
    this.id = const Value.absent(),
    this.soldAt = const Value.absent(),
    this.customerId = const Value.absent(),
    this.orderId = const Value.absent(),
    this.dozens = const Value.absent(),
    this.looseEggs = const Value.absent(),
    this.dozenPriceCents = const Value.absent(),
    this.totalCents = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SalesCompanion.insert({
    required String id,
    required DateTime soldAt,
    this.customerId = const Value.absent(),
    this.orderId = const Value.absent(),
    this.dozens = const Value.absent(),
    this.looseEggs = const Value.absent(),
    required int dozenPriceCents,
    required int totalCents,
    required String paymentMethod,
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    required String createdBy,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       soldAt = Value(soldAt),
       dozenPriceCents = Value(dozenPriceCents),
       totalCents = Value(totalCents),
       paymentMethod = Value(paymentMethod),
       createdBy = Value(createdBy),
       createdAt = Value(createdAt);
  static Insertable<Sale> custom({
    Expression<String>? id,
    Expression<DateTime>? soldAt,
    Expression<String>? customerId,
    Expression<String>? orderId,
    Expression<int>? dozens,
    Expression<int>? looseEggs,
    Expression<int>? dozenPriceCents,
    Expression<int>? totalCents,
    Expression<String>? paymentMethod,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (soldAt != null) 'sold_at': soldAt,
      if (customerId != null) 'customer_id': customerId,
      if (orderId != null) 'order_id': orderId,
      if (dozens != null) 'dozens': dozens,
      if (looseEggs != null) 'loose_eggs': looseEggs,
      if (dozenPriceCents != null) 'dozen_price_cents': dozenPriceCents,
      if (totalCents != null) 'total_cents': totalCents,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SalesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? soldAt,
    Value<String?>? customerId,
    Value<String?>? orderId,
    Value<int>? dozens,
    Value<int>? looseEggs,
    Value<int>? dozenPriceCents,
    Value<int>? totalCents,
    Value<String>? paymentMethod,
    Value<String>? status,
    Value<String?>? notes,
    Value<String>? createdBy,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SalesCompanion(
      id: id ?? this.id,
      soldAt: soldAt ?? this.soldAt,
      customerId: customerId ?? this.customerId,
      orderId: orderId ?? this.orderId,
      dozens: dozens ?? this.dozens,
      looseEggs: looseEggs ?? this.looseEggs,
      dozenPriceCents: dozenPriceCents ?? this.dozenPriceCents,
      totalCents: totalCents ?? this.totalCents,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (soldAt.present) {
      map['sold_at'] = Variable<DateTime>(soldAt.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<String>(orderId.value);
    }
    if (dozens.present) {
      map['dozens'] = Variable<int>(dozens.value);
    }
    if (looseEggs.present) {
      map['loose_eggs'] = Variable<int>(looseEggs.value);
    }
    if (dozenPriceCents.present) {
      map['dozen_price_cents'] = Variable<int>(dozenPriceCents.value);
    }
    if (totalCents.present) {
      map['total_cents'] = Variable<int>(totalCents.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalesCompanion(')
          ..write('id: $id, ')
          ..write('soldAt: $soldAt, ')
          ..write('customerId: $customerId, ')
          ..write('orderId: $orderId, ')
          ..write('dozens: $dozens, ')
          ..write('looseEggs: $looseEggs, ')
          ..write('dozenPriceCents: $dozenPriceCents, ')
          ..write('totalCents: $totalCents, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FinanceTransactionsTable extends FinanceTransactions
    with TableInfo<$FinanceTransactionsTable, FinanceTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FinanceTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceTypeMeta = const VerificationMeta(
    'referenceType',
  );
  @override
  late final GeneratedColumn<String> referenceType = GeneratedColumn<String>(
    'reference_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceIdMeta = const VerificationMeta(
    'referenceId',
  );
  @override
  late final GeneratedColumn<String> referenceId = GeneratedColumn<String>(
    'reference_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('CONFIRMED'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    occurredAt,
    type,
    category,
    description,
    amountCents,
    referenceType,
    referenceId,
    paymentMethod,
    status,
    notes,
    createdBy,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'finance_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<FinanceTransaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('reference_type')) {
      context.handle(
        _referenceTypeMeta,
        referenceType.isAcceptableOrUnknown(
          data['reference_type']!,
          _referenceTypeMeta,
        ),
      );
    }
    if (data.containsKey('reference_id')) {
      context.handle(
        _referenceIdMeta,
        referenceId.isAcceptableOrUnknown(
          data['reference_id']!,
          _referenceIdMeta,
        ),
      );
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FinanceTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FinanceTransaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      referenceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_type'],
      ),
      referenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_id'],
      ),
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FinanceTransactionsTable createAlias(String alias) {
    return $FinanceTransactionsTable(attachedDatabase, alias);
  }
}

class FinanceTransaction extends DataClass
    implements Insertable<FinanceTransaction> {
  final String id;
  final DateTime occurredAt;
  final String type;
  final String category;
  final String description;
  final int amountCents;
  final String? referenceType;
  final String? referenceId;
  final String? paymentMethod;
  final String status;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  const FinanceTransaction({
    required this.id,
    required this.occurredAt,
    required this.type,
    required this.category,
    required this.description,
    required this.amountCents,
    this.referenceType,
    this.referenceId,
    this.paymentMethod,
    required this.status,
    this.notes,
    required this.createdBy,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['type'] = Variable<String>(type);
    map['category'] = Variable<String>(category);
    map['description'] = Variable<String>(description);
    map['amount_cents'] = Variable<int>(amountCents);
    if (!nullToAbsent || referenceType != null) {
      map['reference_type'] = Variable<String>(referenceType);
    }
    if (!nullToAbsent || referenceId != null) {
      map['reference_id'] = Variable<String>(referenceId);
    }
    if (!nullToAbsent || paymentMethod != null) {
      map['payment_method'] = Variable<String>(paymentMethod);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_by'] = Variable<String>(createdBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FinanceTransactionsCompanion toCompanion(bool nullToAbsent) {
    return FinanceTransactionsCompanion(
      id: Value(id),
      occurredAt: Value(occurredAt),
      type: Value(type),
      category: Value(category),
      description: Value(description),
      amountCents: Value(amountCents),
      referenceType: referenceType == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceType),
      referenceId: referenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceId),
      paymentMethod: paymentMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentMethod),
      status: Value(status),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
    );
  }

  factory FinanceTransaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FinanceTransaction(
      id: serializer.fromJson<String>(json['id']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      type: serializer.fromJson<String>(json['type']),
      category: serializer.fromJson<String>(json['category']),
      description: serializer.fromJson<String>(json['description']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      referenceType: serializer.fromJson<String?>(json['referenceType']),
      referenceId: serializer.fromJson<String?>(json['referenceId']),
      paymentMethod: serializer.fromJson<String?>(json['paymentMethod']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'type': serializer.toJson<String>(type),
      'category': serializer.toJson<String>(category),
      'description': serializer.toJson<String>(description),
      'amountCents': serializer.toJson<int>(amountCents),
      'referenceType': serializer.toJson<String?>(referenceType),
      'referenceId': serializer.toJson<String?>(referenceId),
      'paymentMethod': serializer.toJson<String?>(paymentMethod),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FinanceTransaction copyWith({
    String? id,
    DateTime? occurredAt,
    String? type,
    String? category,
    String? description,
    int? amountCents,
    Value<String?> referenceType = const Value.absent(),
    Value<String?> referenceId = const Value.absent(),
    Value<String?> paymentMethod = const Value.absent(),
    String? status,
    Value<String?> notes = const Value.absent(),
    String? createdBy,
    DateTime? createdAt,
  }) => FinanceTransaction(
    id: id ?? this.id,
    occurredAt: occurredAt ?? this.occurredAt,
    type: type ?? this.type,
    category: category ?? this.category,
    description: description ?? this.description,
    amountCents: amountCents ?? this.amountCents,
    referenceType: referenceType.present
        ? referenceType.value
        : this.referenceType,
    referenceId: referenceId.present ? referenceId.value : this.referenceId,
    paymentMethod: paymentMethod.present
        ? paymentMethod.value
        : this.paymentMethod,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
  );
  FinanceTransaction copyWithCompanion(FinanceTransactionsCompanion data) {
    return FinanceTransaction(
      id: data.id.present ? data.id.value : this.id,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      type: data.type.present ? data.type.value : this.type,
      category: data.category.present ? data.category.value : this.category,
      description: data.description.present
          ? data.description.value
          : this.description,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      referenceType: data.referenceType.present
          ? data.referenceType.value
          : this.referenceType,
      referenceId: data.referenceId.present
          ? data.referenceId.value
          : this.referenceId,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FinanceTransaction(')
          ..write('id: $id, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('amountCents: $amountCents, ')
          ..write('referenceType: $referenceType, ')
          ..write('referenceId: $referenceId, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    occurredAt,
    type,
    category,
    description,
    amountCents,
    referenceType,
    referenceId,
    paymentMethod,
    status,
    notes,
    createdBy,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FinanceTransaction &&
          other.id == this.id &&
          other.occurredAt == this.occurredAt &&
          other.type == this.type &&
          other.category == this.category &&
          other.description == this.description &&
          other.amountCents == this.amountCents &&
          other.referenceType == this.referenceType &&
          other.referenceId == this.referenceId &&
          other.paymentMethod == this.paymentMethod &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt);
}

class FinanceTransactionsCompanion extends UpdateCompanion<FinanceTransaction> {
  final Value<String> id;
  final Value<DateTime> occurredAt;
  final Value<String> type;
  final Value<String> category;
  final Value<String> description;
  final Value<int> amountCents;
  final Value<String?> referenceType;
  final Value<String?> referenceId;
  final Value<String?> paymentMethod;
  final Value<String> status;
  final Value<String?> notes;
  final Value<String> createdBy;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const FinanceTransactionsCompanion({
    this.id = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.type = const Value.absent(),
    this.category = const Value.absent(),
    this.description = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.referenceType = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FinanceTransactionsCompanion.insert({
    required String id,
    required DateTime occurredAt,
    required String type,
    required String category,
    required String description,
    required int amountCents,
    this.referenceType = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    required String createdBy,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       occurredAt = Value(occurredAt),
       type = Value(type),
       category = Value(category),
       description = Value(description),
       amountCents = Value(amountCents),
       createdBy = Value(createdBy),
       createdAt = Value(createdAt);
  static Insertable<FinanceTransaction> custom({
    Expression<String>? id,
    Expression<DateTime>? occurredAt,
    Expression<String>? type,
    Expression<String>? category,
    Expression<String>? description,
    Expression<int>? amountCents,
    Expression<String>? referenceType,
    Expression<String>? referenceId,
    Expression<String>? paymentMethod,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (type != null) 'type': type,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
      if (amountCents != null) 'amount_cents': amountCents,
      if (referenceType != null) 'reference_type': referenceType,
      if (referenceId != null) 'reference_id': referenceId,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FinanceTransactionsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? occurredAt,
    Value<String>? type,
    Value<String>? category,
    Value<String>? description,
    Value<int>? amountCents,
    Value<String?>? referenceType,
    Value<String?>? referenceId,
    Value<String?>? paymentMethod,
    Value<String>? status,
    Value<String?>? notes,
    Value<String>? createdBy,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return FinanceTransactionsCompanion(
      id: id ?? this.id,
      occurredAt: occurredAt ?? this.occurredAt,
      type: type ?? this.type,
      category: category ?? this.category,
      description: description ?? this.description,
      amountCents: amountCents ?? this.amountCents,
      referenceType: referenceType ?? this.referenceType,
      referenceId: referenceId ?? this.referenceId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (referenceType.present) {
      map['reference_type'] = Variable<String>(referenceType.value);
    }
    if (referenceId.present) {
      map['reference_id'] = Variable<String>(referenceId.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FinanceTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('amountCents: $amountCents, ')
          ..write('referenceType: $referenceType, ')
          ..write('referenceId: $referenceId, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvestmentsTable extends Investments
    with TableInfo<$InvestmentsTable, Investment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvestmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _investmentDateMeta = const VerificationMeta(
    'investmentDate',
  );
  @override
  late final GeneratedColumn<DateTime> investmentDate =
      GeneratedColumn<DateTime>(
        'investment_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lotIdMeta = const VerificationMeta('lotId');
  @override
  late final GeneratedColumn<String> lotId = GeneratedColumn<String>(
    'lot_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    description,
    category,
    investmentDate,
    amountCents,
    lotId,
    createdBy,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'investments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Investment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('investment_date')) {
      context.handle(
        _investmentDateMeta,
        investmentDate.isAcceptableOrUnknown(
          data['investment_date']!,
          _investmentDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_investmentDateMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('lot_id')) {
      context.handle(
        _lotIdMeta,
        lotId.isAcceptableOrUnknown(data['lot_id']!, _lotIdMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Investment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Investment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      investmentDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}investment_date'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      lotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lot_id'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $InvestmentsTable createAlias(String alias) {
    return $InvestmentsTable(attachedDatabase, alias);
  }
}

class Investment extends DataClass implements Insertable<Investment> {
  final String id;
  final String description;
  final String category;
  final DateTime investmentDate;
  final int amountCents;
  final String? lotId;
  final String createdBy;
  final DateTime createdAt;
  const Investment({
    required this.id,
    required this.description,
    required this.category,
    required this.investmentDate,
    required this.amountCents,
    this.lotId,
    required this.createdBy,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['description'] = Variable<String>(description);
    map['category'] = Variable<String>(category);
    map['investment_date'] = Variable<DateTime>(investmentDate);
    map['amount_cents'] = Variable<int>(amountCents);
    if (!nullToAbsent || lotId != null) {
      map['lot_id'] = Variable<String>(lotId);
    }
    map['created_by'] = Variable<String>(createdBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  InvestmentsCompanion toCompanion(bool nullToAbsent) {
    return InvestmentsCompanion(
      id: Value(id),
      description: Value(description),
      category: Value(category),
      investmentDate: Value(investmentDate),
      amountCents: Value(amountCents),
      lotId: lotId == null && nullToAbsent
          ? const Value.absent()
          : Value(lotId),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
    );
  }

  factory Investment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Investment(
      id: serializer.fromJson<String>(json['id']),
      description: serializer.fromJson<String>(json['description']),
      category: serializer.fromJson<String>(json['category']),
      investmentDate: serializer.fromJson<DateTime>(json['investmentDate']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      lotId: serializer.fromJson<String?>(json['lotId']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'description': serializer.toJson<String>(description),
      'category': serializer.toJson<String>(category),
      'investmentDate': serializer.toJson<DateTime>(investmentDate),
      'amountCents': serializer.toJson<int>(amountCents),
      'lotId': serializer.toJson<String?>(lotId),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Investment copyWith({
    String? id,
    String? description,
    String? category,
    DateTime? investmentDate,
    int? amountCents,
    Value<String?> lotId = const Value.absent(),
    String? createdBy,
    DateTime? createdAt,
  }) => Investment(
    id: id ?? this.id,
    description: description ?? this.description,
    category: category ?? this.category,
    investmentDate: investmentDate ?? this.investmentDate,
    amountCents: amountCents ?? this.amountCents,
    lotId: lotId.present ? lotId.value : this.lotId,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
  );
  Investment copyWithCompanion(InvestmentsCompanion data) {
    return Investment(
      id: data.id.present ? data.id.value : this.id,
      description: data.description.present
          ? data.description.value
          : this.description,
      category: data.category.present ? data.category.value : this.category,
      investmentDate: data.investmentDate.present
          ? data.investmentDate.value
          : this.investmentDate,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      lotId: data.lotId.present ? data.lotId.value : this.lotId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Investment(')
          ..write('id: $id, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('investmentDate: $investmentDate, ')
          ..write('amountCents: $amountCents, ')
          ..write('lotId: $lotId, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    description,
    category,
    investmentDate,
    amountCents,
    lotId,
    createdBy,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Investment &&
          other.id == this.id &&
          other.description == this.description &&
          other.category == this.category &&
          other.investmentDate == this.investmentDate &&
          other.amountCents == this.amountCents &&
          other.lotId == this.lotId &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt);
}

class InvestmentsCompanion extends UpdateCompanion<Investment> {
  final Value<String> id;
  final Value<String> description;
  final Value<String> category;
  final Value<DateTime> investmentDate;
  final Value<int> amountCents;
  final Value<String?> lotId;
  final Value<String> createdBy;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const InvestmentsCompanion({
    this.id = const Value.absent(),
    this.description = const Value.absent(),
    this.category = const Value.absent(),
    this.investmentDate = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.lotId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvestmentsCompanion.insert({
    required String id,
    required String description,
    required String category,
    required DateTime investmentDate,
    required int amountCents,
    this.lotId = const Value.absent(),
    required String createdBy,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       description = Value(description),
       category = Value(category),
       investmentDate = Value(investmentDate),
       amountCents = Value(amountCents),
       createdBy = Value(createdBy),
       createdAt = Value(createdAt);
  static Insertable<Investment> custom({
    Expression<String>? id,
    Expression<String>? description,
    Expression<String>? category,
    Expression<DateTime>? investmentDate,
    Expression<int>? amountCents,
    Expression<String>? lotId,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      if (investmentDate != null) 'investment_date': investmentDate,
      if (amountCents != null) 'amount_cents': amountCents,
      if (lotId != null) 'lot_id': lotId,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvestmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? description,
    Value<String>? category,
    Value<DateTime>? investmentDate,
    Value<int>? amountCents,
    Value<String?>? lotId,
    Value<String>? createdBy,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return InvestmentsCompanion(
      id: id ?? this.id,
      description: description ?? this.description,
      category: category ?? this.category,
      investmentDate: investmentDate ?? this.investmentDate,
      amountCents: amountCents ?? this.amountCents,
      lotId: lotId ?? this.lotId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (investmentDate.present) {
      map['investment_date'] = Variable<DateTime>(investmentDate.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (lotId.present) {
      map['lot_id'] = Variable<String>(lotId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvestmentsCompanion(')
          ..write('id: $id, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('investmentDate: $investmentDate, ')
          ..write('amountCents: $amountCents, ')
          ..write('lotId: $lotId, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LightingProgramsTable extends LightingPrograms
    with TableInfo<$LightingProgramsTable, LightingProgram> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LightingProgramsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    isDefault,
    isActive,
    createdBy,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lighting_programs';
  @override
  VerificationContext validateIntegrity(
    Insertable<LightingProgram> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LightingProgram map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LightingProgram(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LightingProgramsTable createAlias(String alias) {
    return $LightingProgramsTable(attachedDatabase, alias);
  }
}

class LightingProgram extends DataClass implements Insertable<LightingProgram> {
  final String id;
  final String name;
  final String? description;
  final bool isDefault;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;
  const LightingProgram({
    required this.id,
    required this.name,
    this.description,
    required this.isDefault,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['is_default'] = Variable<bool>(isDefault);
    map['is_active'] = Variable<bool>(isActive);
    map['created_by'] = Variable<String>(createdBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LightingProgramsCompanion toCompanion(bool nullToAbsent) {
    return LightingProgramsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      isDefault: Value(isDefault),
      isActive: Value(isActive),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
    );
  }

  factory LightingProgram.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LightingProgram(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'isDefault': serializer.toJson<bool>(isDefault),
      'isActive': serializer.toJson<bool>(isActive),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LightingProgram copyWith({
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    bool? isDefault,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
  }) => LightingProgram(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    isDefault: isDefault ?? this.isDefault,
    isActive: isActive ?? this.isActive,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
  );
  LightingProgram copyWithCompanion(LightingProgramsCompanion data) {
    return LightingProgram(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LightingProgram(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('isDefault: $isDefault, ')
          ..write('isActive: $isActive, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    isDefault,
    isActive,
    createdBy,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LightingProgram &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.isDefault == this.isDefault &&
          other.isActive == this.isActive &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt);
}

class LightingProgramsCompanion extends UpdateCompanion<LightingProgram> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<bool> isDefault;
  final Value<bool> isActive;
  final Value<String> createdBy;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LightingProgramsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LightingProgramsCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isActive = const Value.absent(),
    required String createdBy,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdBy = Value(createdBy),
       createdAt = Value(createdAt);
  static Insertable<LightingProgram> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<bool>? isDefault,
    Expression<bool>? isActive,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (isDefault != null) 'is_default': isDefault,
      if (isActive != null) 'is_active': isActive,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LightingProgramsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<bool>? isDefault,
    Value<bool>? isActive,
    Value<String>? createdBy,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return LightingProgramsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LightingProgramsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('isDefault: $isDefault, ')
          ..write('isActive: $isActive, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LightingProgramStepsTable extends LightingProgramSteps
    with TableInfo<$LightingProgramStepsTable, LightingProgramStep> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LightingProgramStepsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _programIdMeta = const VerificationMeta(
    'programId',
  );
  @override
  late final GeneratedColumn<String> programId = GeneratedColumn<String>(
    'program_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startAgeDaysMeta = const VerificationMeta(
    'startAgeDays',
  );
  @override
  late final GeneratedColumn<int> startAgeDays = GeneratedColumn<int>(
    'start_age_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endAgeDaysMeta = const VerificationMeta(
    'endAgeDays',
  );
  @override
  late final GeneratedColumn<int> endAgeDays = GeneratedColumn<int>(
    'end_age_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalLightMinutesMeta = const VerificationMeta(
    'totalLightMinutes',
  );
  @override
  late final GeneratedColumn<int> totalLightMinutes = GeneratedColumn<int>(
    'total_light_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<String> startTime = GeneratedColumn<String>(
    'start_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<String> endTime = GeneratedColumn<String>(
    'end_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weeklyIncrementMinutesMeta =
      const VerificationMeta('weeklyIncrementMinutes');
  @override
  late final GeneratedColumn<int> weeklyIncrementMinutes = GeneratedColumn<int>(
    'weekly_increment_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _relatedPhaseMeta = const VerificationMeta(
    'relatedPhase',
  );
  @override
  late final GeneratedColumn<String> relatedPhase = GeneratedColumn<String>(
    'related_phase',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    programId,
    startAgeDays,
    endAgeDays,
    totalLightMinutes,
    startTime,
    endTime,
    weeklyIncrementMinutes,
    relatedPhase,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lighting_program_steps';
  @override
  VerificationContext validateIntegrity(
    Insertable<LightingProgramStep> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('program_id')) {
      context.handle(
        _programIdMeta,
        programId.isAcceptableOrUnknown(data['program_id']!, _programIdMeta),
      );
    } else if (isInserting) {
      context.missing(_programIdMeta);
    }
    if (data.containsKey('start_age_days')) {
      context.handle(
        _startAgeDaysMeta,
        startAgeDays.isAcceptableOrUnknown(
          data['start_age_days']!,
          _startAgeDaysMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startAgeDaysMeta);
    }
    if (data.containsKey('end_age_days')) {
      context.handle(
        _endAgeDaysMeta,
        endAgeDays.isAcceptableOrUnknown(
          data['end_age_days']!,
          _endAgeDaysMeta,
        ),
      );
    }
    if (data.containsKey('total_light_minutes')) {
      context.handle(
        _totalLightMinutesMeta,
        totalLightMinutes.isAcceptableOrUnknown(
          data['total_light_minutes']!,
          _totalLightMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalLightMinutesMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    }
    if (data.containsKey('weekly_increment_minutes')) {
      context.handle(
        _weeklyIncrementMinutesMeta,
        weeklyIncrementMinutes.isAcceptableOrUnknown(
          data['weekly_increment_minutes']!,
          _weeklyIncrementMinutesMeta,
        ),
      );
    }
    if (data.containsKey('related_phase')) {
      context.handle(
        _relatedPhaseMeta,
        relatedPhase.isAcceptableOrUnknown(
          data['related_phase']!,
          _relatedPhaseMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LightingProgramStep map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LightingProgramStep(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      programId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}program_id'],
      )!,
      startAgeDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_age_days'],
      )!,
      endAgeDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_age_days'],
      ),
      totalLightMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_light_minutes'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_time'],
      ),
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_time'],
      ),
      weeklyIncrementMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekly_increment_minutes'],
      )!,
      relatedPhase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}related_phase'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $LightingProgramStepsTable createAlias(String alias) {
    return $LightingProgramStepsTable(attachedDatabase, alias);
  }
}

class LightingProgramStep extends DataClass
    implements Insertable<LightingProgramStep> {
  final String id;
  final String programId;
  final int startAgeDays;
  final int? endAgeDays;
  final int totalLightMinutes;
  final String? startTime;
  final String? endTime;
  final int weeklyIncrementMinutes;
  final String? relatedPhase;
  final String? notes;
  const LightingProgramStep({
    required this.id,
    required this.programId,
    required this.startAgeDays,
    this.endAgeDays,
    required this.totalLightMinutes,
    this.startTime,
    this.endTime,
    required this.weeklyIncrementMinutes,
    this.relatedPhase,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['program_id'] = Variable<String>(programId);
    map['start_age_days'] = Variable<int>(startAgeDays);
    if (!nullToAbsent || endAgeDays != null) {
      map['end_age_days'] = Variable<int>(endAgeDays);
    }
    map['total_light_minutes'] = Variable<int>(totalLightMinutes);
    if (!nullToAbsent || startTime != null) {
      map['start_time'] = Variable<String>(startTime);
    }
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<String>(endTime);
    }
    map['weekly_increment_minutes'] = Variable<int>(weeklyIncrementMinutes);
    if (!nullToAbsent || relatedPhase != null) {
      map['related_phase'] = Variable<String>(relatedPhase);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  LightingProgramStepsCompanion toCompanion(bool nullToAbsent) {
    return LightingProgramStepsCompanion(
      id: Value(id),
      programId: Value(programId),
      startAgeDays: Value(startAgeDays),
      endAgeDays: endAgeDays == null && nullToAbsent
          ? const Value.absent()
          : Value(endAgeDays),
      totalLightMinutes: Value(totalLightMinutes),
      startTime: startTime == null && nullToAbsent
          ? const Value.absent()
          : Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      weeklyIncrementMinutes: Value(weeklyIncrementMinutes),
      relatedPhase: relatedPhase == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedPhase),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory LightingProgramStep.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LightingProgramStep(
      id: serializer.fromJson<String>(json['id']),
      programId: serializer.fromJson<String>(json['programId']),
      startAgeDays: serializer.fromJson<int>(json['startAgeDays']),
      endAgeDays: serializer.fromJson<int?>(json['endAgeDays']),
      totalLightMinutes: serializer.fromJson<int>(json['totalLightMinutes']),
      startTime: serializer.fromJson<String?>(json['startTime']),
      endTime: serializer.fromJson<String?>(json['endTime']),
      weeklyIncrementMinutes: serializer.fromJson<int>(
        json['weeklyIncrementMinutes'],
      ),
      relatedPhase: serializer.fromJson<String?>(json['relatedPhase']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'programId': serializer.toJson<String>(programId),
      'startAgeDays': serializer.toJson<int>(startAgeDays),
      'endAgeDays': serializer.toJson<int?>(endAgeDays),
      'totalLightMinutes': serializer.toJson<int>(totalLightMinutes),
      'startTime': serializer.toJson<String?>(startTime),
      'endTime': serializer.toJson<String?>(endTime),
      'weeklyIncrementMinutes': serializer.toJson<int>(weeklyIncrementMinutes),
      'relatedPhase': serializer.toJson<String?>(relatedPhase),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  LightingProgramStep copyWith({
    String? id,
    String? programId,
    int? startAgeDays,
    Value<int?> endAgeDays = const Value.absent(),
    int? totalLightMinutes,
    Value<String?> startTime = const Value.absent(),
    Value<String?> endTime = const Value.absent(),
    int? weeklyIncrementMinutes,
    Value<String?> relatedPhase = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => LightingProgramStep(
    id: id ?? this.id,
    programId: programId ?? this.programId,
    startAgeDays: startAgeDays ?? this.startAgeDays,
    endAgeDays: endAgeDays.present ? endAgeDays.value : this.endAgeDays,
    totalLightMinutes: totalLightMinutes ?? this.totalLightMinutes,
    startTime: startTime.present ? startTime.value : this.startTime,
    endTime: endTime.present ? endTime.value : this.endTime,
    weeklyIncrementMinutes:
        weeklyIncrementMinutes ?? this.weeklyIncrementMinutes,
    relatedPhase: relatedPhase.present ? relatedPhase.value : this.relatedPhase,
    notes: notes.present ? notes.value : this.notes,
  );
  LightingProgramStep copyWithCompanion(LightingProgramStepsCompanion data) {
    return LightingProgramStep(
      id: data.id.present ? data.id.value : this.id,
      programId: data.programId.present ? data.programId.value : this.programId,
      startAgeDays: data.startAgeDays.present
          ? data.startAgeDays.value
          : this.startAgeDays,
      endAgeDays: data.endAgeDays.present
          ? data.endAgeDays.value
          : this.endAgeDays,
      totalLightMinutes: data.totalLightMinutes.present
          ? data.totalLightMinutes.value
          : this.totalLightMinutes,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      weeklyIncrementMinutes: data.weeklyIncrementMinutes.present
          ? data.weeklyIncrementMinutes.value
          : this.weeklyIncrementMinutes,
      relatedPhase: data.relatedPhase.present
          ? data.relatedPhase.value
          : this.relatedPhase,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LightingProgramStep(')
          ..write('id: $id, ')
          ..write('programId: $programId, ')
          ..write('startAgeDays: $startAgeDays, ')
          ..write('endAgeDays: $endAgeDays, ')
          ..write('totalLightMinutes: $totalLightMinutes, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('weeklyIncrementMinutes: $weeklyIncrementMinutes, ')
          ..write('relatedPhase: $relatedPhase, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    programId,
    startAgeDays,
    endAgeDays,
    totalLightMinutes,
    startTime,
    endTime,
    weeklyIncrementMinutes,
    relatedPhase,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LightingProgramStep &&
          other.id == this.id &&
          other.programId == this.programId &&
          other.startAgeDays == this.startAgeDays &&
          other.endAgeDays == this.endAgeDays &&
          other.totalLightMinutes == this.totalLightMinutes &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.weeklyIncrementMinutes == this.weeklyIncrementMinutes &&
          other.relatedPhase == this.relatedPhase &&
          other.notes == this.notes);
}

class LightingProgramStepsCompanion
    extends UpdateCompanion<LightingProgramStep> {
  final Value<String> id;
  final Value<String> programId;
  final Value<int> startAgeDays;
  final Value<int?> endAgeDays;
  final Value<int> totalLightMinutes;
  final Value<String?> startTime;
  final Value<String?> endTime;
  final Value<int> weeklyIncrementMinutes;
  final Value<String?> relatedPhase;
  final Value<String?> notes;
  final Value<int> rowid;
  const LightingProgramStepsCompanion({
    this.id = const Value.absent(),
    this.programId = const Value.absent(),
    this.startAgeDays = const Value.absent(),
    this.endAgeDays = const Value.absent(),
    this.totalLightMinutes = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.weeklyIncrementMinutes = const Value.absent(),
    this.relatedPhase = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LightingProgramStepsCompanion.insert({
    required String id,
    required String programId,
    required int startAgeDays,
    this.endAgeDays = const Value.absent(),
    required int totalLightMinutes,
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.weeklyIncrementMinutes = const Value.absent(),
    this.relatedPhase = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       programId = Value(programId),
       startAgeDays = Value(startAgeDays),
       totalLightMinutes = Value(totalLightMinutes);
  static Insertable<LightingProgramStep> custom({
    Expression<String>? id,
    Expression<String>? programId,
    Expression<int>? startAgeDays,
    Expression<int>? endAgeDays,
    Expression<int>? totalLightMinutes,
    Expression<String>? startTime,
    Expression<String>? endTime,
    Expression<int>? weeklyIncrementMinutes,
    Expression<String>? relatedPhase,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (programId != null) 'program_id': programId,
      if (startAgeDays != null) 'start_age_days': startAgeDays,
      if (endAgeDays != null) 'end_age_days': endAgeDays,
      if (totalLightMinutes != null) 'total_light_minutes': totalLightMinutes,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (weeklyIncrementMinutes != null)
        'weekly_increment_minutes': weeklyIncrementMinutes,
      if (relatedPhase != null) 'related_phase': relatedPhase,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LightingProgramStepsCompanion copyWith({
    Value<String>? id,
    Value<String>? programId,
    Value<int>? startAgeDays,
    Value<int?>? endAgeDays,
    Value<int>? totalLightMinutes,
    Value<String?>? startTime,
    Value<String?>? endTime,
    Value<int>? weeklyIncrementMinutes,
    Value<String?>? relatedPhase,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return LightingProgramStepsCompanion(
      id: id ?? this.id,
      programId: programId ?? this.programId,
      startAgeDays: startAgeDays ?? this.startAgeDays,
      endAgeDays: endAgeDays ?? this.endAgeDays,
      totalLightMinutes: totalLightMinutes ?? this.totalLightMinutes,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      weeklyIncrementMinutes:
          weeklyIncrementMinutes ?? this.weeklyIncrementMinutes,
      relatedPhase: relatedPhase ?? this.relatedPhase,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (programId.present) {
      map['program_id'] = Variable<String>(programId.value);
    }
    if (startAgeDays.present) {
      map['start_age_days'] = Variable<int>(startAgeDays.value);
    }
    if (endAgeDays.present) {
      map['end_age_days'] = Variable<int>(endAgeDays.value);
    }
    if (totalLightMinutes.present) {
      map['total_light_minutes'] = Variable<int>(totalLightMinutes.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<String>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<String>(endTime.value);
    }
    if (weeklyIncrementMinutes.present) {
      map['weekly_increment_minutes'] = Variable<int>(
        weeklyIncrementMinutes.value,
      );
    }
    if (relatedPhase.present) {
      map['related_phase'] = Variable<String>(relatedPhase.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LightingProgramStepsCompanion(')
          ..write('id: $id, ')
          ..write('programId: $programId, ')
          ..write('startAgeDays: $startAgeDays, ')
          ..write('endAgeDays: $endAgeDays, ')
          ..write('totalLightMinutes: $totalLightMinutes, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('weeklyIncrementMinutes: $weeklyIncrementMinutes, ')
          ..write('relatedPhase: $relatedPhase, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LotLightingProgramsTable extends LotLightingPrograms
    with TableInfo<$LotLightingProgramsTable, LotLightingProgram> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LotLightingProgramsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lotIdMeta = const VerificationMeta('lotId');
  @override
  late final GeneratedColumn<String> lotId = GeneratedColumn<String>(
    'lot_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _programIdMeta = const VerificationMeta(
    'programId',
  );
  @override
  late final GeneratedColumn<String> programId = GeneratedColumn<String>(
    'program_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assignedAtMeta = const VerificationMeta(
    'assignedAt',
  );
  @override
  late final GeneratedColumn<DateTime> assignedAt = GeneratedColumn<DateTime>(
    'assigned_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lotId,
    programId,
    assignedAt,
    createdBy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lot_lighting_programs';
  @override
  VerificationContext validateIntegrity(
    Insertable<LotLightingProgram> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('lot_id')) {
      context.handle(
        _lotIdMeta,
        lotId.isAcceptableOrUnknown(data['lot_id']!, _lotIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lotIdMeta);
    }
    if (data.containsKey('program_id')) {
      context.handle(
        _programIdMeta,
        programId.isAcceptableOrUnknown(data['program_id']!, _programIdMeta),
      );
    } else if (isInserting) {
      context.missing(_programIdMeta);
    }
    if (data.containsKey('assigned_at')) {
      context.handle(
        _assignedAtMeta,
        assignedAt.isAcceptableOrUnknown(data['assigned_at']!, _assignedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_assignedAtMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LotLightingProgram map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LotLightingProgram(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      lotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lot_id'],
      )!,
      programId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}program_id'],
      )!,
      assignedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}assigned_at'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
    );
  }

  @override
  $LotLightingProgramsTable createAlias(String alias) {
    return $LotLightingProgramsTable(attachedDatabase, alias);
  }
}

class LotLightingProgram extends DataClass
    implements Insertable<LotLightingProgram> {
  final String id;
  final String lotId;
  final String programId;
  final DateTime assignedAt;
  final String createdBy;
  const LotLightingProgram({
    required this.id,
    required this.lotId,
    required this.programId,
    required this.assignedAt,
    required this.createdBy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['lot_id'] = Variable<String>(lotId);
    map['program_id'] = Variable<String>(programId);
    map['assigned_at'] = Variable<DateTime>(assignedAt);
    map['created_by'] = Variable<String>(createdBy);
    return map;
  }

  LotLightingProgramsCompanion toCompanion(bool nullToAbsent) {
    return LotLightingProgramsCompanion(
      id: Value(id),
      lotId: Value(lotId),
      programId: Value(programId),
      assignedAt: Value(assignedAt),
      createdBy: Value(createdBy),
    );
  }

  factory LotLightingProgram.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LotLightingProgram(
      id: serializer.fromJson<String>(json['id']),
      lotId: serializer.fromJson<String>(json['lotId']),
      programId: serializer.fromJson<String>(json['programId']),
      assignedAt: serializer.fromJson<DateTime>(json['assignedAt']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'lotId': serializer.toJson<String>(lotId),
      'programId': serializer.toJson<String>(programId),
      'assignedAt': serializer.toJson<DateTime>(assignedAt),
      'createdBy': serializer.toJson<String>(createdBy),
    };
  }

  LotLightingProgram copyWith({
    String? id,
    String? lotId,
    String? programId,
    DateTime? assignedAt,
    String? createdBy,
  }) => LotLightingProgram(
    id: id ?? this.id,
    lotId: lotId ?? this.lotId,
    programId: programId ?? this.programId,
    assignedAt: assignedAt ?? this.assignedAt,
    createdBy: createdBy ?? this.createdBy,
  );
  LotLightingProgram copyWithCompanion(LotLightingProgramsCompanion data) {
    return LotLightingProgram(
      id: data.id.present ? data.id.value : this.id,
      lotId: data.lotId.present ? data.lotId.value : this.lotId,
      programId: data.programId.present ? data.programId.value : this.programId,
      assignedAt: data.assignedAt.present
          ? data.assignedAt.value
          : this.assignedAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LotLightingProgram(')
          ..write('id: $id, ')
          ..write('lotId: $lotId, ')
          ..write('programId: $programId, ')
          ..write('assignedAt: $assignedAt, ')
          ..write('createdBy: $createdBy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, lotId, programId, assignedAt, createdBy);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LotLightingProgram &&
          other.id == this.id &&
          other.lotId == this.lotId &&
          other.programId == this.programId &&
          other.assignedAt == this.assignedAt &&
          other.createdBy == this.createdBy);
}

class LotLightingProgramsCompanion extends UpdateCompanion<LotLightingProgram> {
  final Value<String> id;
  final Value<String> lotId;
  final Value<String> programId;
  final Value<DateTime> assignedAt;
  final Value<String> createdBy;
  final Value<int> rowid;
  const LotLightingProgramsCompanion({
    this.id = const Value.absent(),
    this.lotId = const Value.absent(),
    this.programId = const Value.absent(),
    this.assignedAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LotLightingProgramsCompanion.insert({
    required String id,
    required String lotId,
    required String programId,
    required DateTime assignedAt,
    required String createdBy,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       lotId = Value(lotId),
       programId = Value(programId),
       assignedAt = Value(assignedAt),
       createdBy = Value(createdBy);
  static Insertable<LotLightingProgram> custom({
    Expression<String>? id,
    Expression<String>? lotId,
    Expression<String>? programId,
    Expression<DateTime>? assignedAt,
    Expression<String>? createdBy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lotId != null) 'lot_id': lotId,
      if (programId != null) 'program_id': programId,
      if (assignedAt != null) 'assigned_at': assignedAt,
      if (createdBy != null) 'created_by': createdBy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LotLightingProgramsCompanion copyWith({
    Value<String>? id,
    Value<String>? lotId,
    Value<String>? programId,
    Value<DateTime>? assignedAt,
    Value<String>? createdBy,
    Value<int>? rowid,
  }) {
    return LotLightingProgramsCompanion(
      id: id ?? this.id,
      lotId: lotId ?? this.lotId,
      programId: programId ?? this.programId,
      assignedAt: assignedAt ?? this.assignedAt,
      createdBy: createdBy ?? this.createdBy,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (lotId.present) {
      map['lot_id'] = Variable<String>(lotId.value);
    }
    if (programId.present) {
      map['program_id'] = Variable<String>(programId.value);
    }
    if (assignedAt.present) {
      map['assigned_at'] = Variable<DateTime>(assignedAt.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LotLightingProgramsCompanion(')
          ..write('id: $id, ')
          ..write('lotId: $lotId, ')
          ..write('programId: $programId, ')
          ..write('assignedAt: $assignedAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CalendarEventsTable extends CalendarEvents
    with TableInfo<$CalendarEventsTable, CalendarEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CalendarEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startsAtMeta = const VerificationMeta(
    'startsAt',
  );
  @override
  late final GeneratedColumn<DateTime> startsAt = GeneratedColumn<DateTime>(
    'starts_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endsAtMeta = const VerificationMeta('endsAt');
  @override
  late final GeneratedColumn<DateTime> endsAt = GeneratedColumn<DateTime>(
    'ends_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lotIdMeta = const VerificationMeta('lotId');
  @override
  late final GeneratedColumn<String> lotId = GeneratedColumn<String>(
    'lot_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceTypeMeta = const VerificationMeta(
    'referenceType',
  );
  @override
  late final GeneratedColumn<String> referenceType = GeneratedColumn<String>(
    'reference_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceIdMeta = const VerificationMeta(
    'referenceId',
  );
  @override
  late final GeneratedColumn<String> referenceId = GeneratedColumn<String>(
    'reference_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _alertEnabledMeta = const VerificationMeta(
    'alertEnabled',
  );
  @override
  late final GeneratedColumn<bool> alertEnabled = GeneratedColumn<bool>(
    'alert_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("alert_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _alertMessageMeta = const VerificationMeta(
    'alertMessage',
  );
  @override
  late final GeneratedColumn<String> alertMessage = GeneratedColumn<String>(
    'alert_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _alertTimeMeta = const VerificationMeta(
    'alertTime',
  );
  @override
  late final GeneratedColumn<String> alertTime = GeneratedColumn<String>(
    'alert_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('08:00'),
  );
  static const VerificationMeta _recurrenceMeta = const VerificationMeta(
    'recurrence',
  );
  @override
  late final GeneratedColumn<String> recurrence = GeneratedColumn<String>(
    'recurrence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ONCE'),
  );
  static const VerificationMeta _repeatUntilMeta = const VerificationMeta(
    'repeatUntil',
  );
  @override
  late final GeneratedColumn<DateTime> repeatUntil = GeneratedColumn<DateTime>(
    'repeat_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weekdaysMeta = const VerificationMeta(
    'weekdays',
  );
  @override
  late final GeneratedColumn<String> weekdays = GeneratedColumn<String>(
    'weekdays',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    type,
    startsAt,
    endsAt,
    lotId,
    referenceType,
    referenceId,
    notes,
    alertEnabled,
    alertMessage,
    alertTime,
    recurrence,
    repeatUntil,
    weekdays,
    createdBy,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'calendar_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<CalendarEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('starts_at')) {
      context.handle(
        _startsAtMeta,
        startsAt.isAcceptableOrUnknown(data['starts_at']!, _startsAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startsAtMeta);
    }
    if (data.containsKey('ends_at')) {
      context.handle(
        _endsAtMeta,
        endsAt.isAcceptableOrUnknown(data['ends_at']!, _endsAtMeta),
      );
    }
    if (data.containsKey('lot_id')) {
      context.handle(
        _lotIdMeta,
        lotId.isAcceptableOrUnknown(data['lot_id']!, _lotIdMeta),
      );
    }
    if (data.containsKey('reference_type')) {
      context.handle(
        _referenceTypeMeta,
        referenceType.isAcceptableOrUnknown(
          data['reference_type']!,
          _referenceTypeMeta,
        ),
      );
    }
    if (data.containsKey('reference_id')) {
      context.handle(
        _referenceIdMeta,
        referenceId.isAcceptableOrUnknown(
          data['reference_id']!,
          _referenceIdMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('alert_enabled')) {
      context.handle(
        _alertEnabledMeta,
        alertEnabled.isAcceptableOrUnknown(
          data['alert_enabled']!,
          _alertEnabledMeta,
        ),
      );
    }
    if (data.containsKey('alert_message')) {
      context.handle(
        _alertMessageMeta,
        alertMessage.isAcceptableOrUnknown(
          data['alert_message']!,
          _alertMessageMeta,
        ),
      );
    }
    if (data.containsKey('alert_time')) {
      context.handle(
        _alertTimeMeta,
        alertTime.isAcceptableOrUnknown(data['alert_time']!, _alertTimeMeta),
      );
    }
    if (data.containsKey('recurrence')) {
      context.handle(
        _recurrenceMeta,
        recurrence.isAcceptableOrUnknown(data['recurrence']!, _recurrenceMeta),
      );
    }
    if (data.containsKey('repeat_until')) {
      context.handle(
        _repeatUntilMeta,
        repeatUntil.isAcceptableOrUnknown(
          data['repeat_until']!,
          _repeatUntilMeta,
        ),
      );
    }
    if (data.containsKey('weekdays')) {
      context.handle(
        _weekdaysMeta,
        weekdays.isAcceptableOrUnknown(data['weekdays']!, _weekdaysMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CalendarEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CalendarEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      startsAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}starts_at'],
      )!,
      endsAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ends_at'],
      ),
      lotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lot_id'],
      ),
      referenceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_type'],
      ),
      referenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_id'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      alertEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}alert_enabled'],
      )!,
      alertMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alert_message'],
      ),
      alertTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alert_time'],
      )!,
      recurrence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence'],
      )!,
      repeatUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}repeat_until'],
      ),
      weekdays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weekdays'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CalendarEventsTable createAlias(String alias) {
    return $CalendarEventsTable(attachedDatabase, alias);
  }
}

class CalendarEvent extends DataClass implements Insertable<CalendarEvent> {
  final String id;
  final String title;
  final String type;
  final DateTime startsAt;
  final DateTime? endsAt;
  final String? lotId;
  final String? referenceType;
  final String? referenceId;
  final String? notes;
  final bool alertEnabled;
  final String? alertMessage;
  final String alertTime;
  final String recurrence;
  final DateTime? repeatUntil;
  final String? weekdays;
  final String createdBy;
  final DateTime createdAt;
  const CalendarEvent({
    required this.id,
    required this.title,
    required this.type,
    required this.startsAt,
    this.endsAt,
    this.lotId,
    this.referenceType,
    this.referenceId,
    this.notes,
    required this.alertEnabled,
    this.alertMessage,
    required this.alertTime,
    required this.recurrence,
    this.repeatUntil,
    this.weekdays,
    required this.createdBy,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['type'] = Variable<String>(type);
    map['starts_at'] = Variable<DateTime>(startsAt);
    if (!nullToAbsent || endsAt != null) {
      map['ends_at'] = Variable<DateTime>(endsAt);
    }
    if (!nullToAbsent || lotId != null) {
      map['lot_id'] = Variable<String>(lotId);
    }
    if (!nullToAbsent || referenceType != null) {
      map['reference_type'] = Variable<String>(referenceType);
    }
    if (!nullToAbsent || referenceId != null) {
      map['reference_id'] = Variable<String>(referenceId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['alert_enabled'] = Variable<bool>(alertEnabled);
    if (!nullToAbsent || alertMessage != null) {
      map['alert_message'] = Variable<String>(alertMessage);
    }
    map['alert_time'] = Variable<String>(alertTime);
    map['recurrence'] = Variable<String>(recurrence);
    if (!nullToAbsent || repeatUntil != null) {
      map['repeat_until'] = Variable<DateTime>(repeatUntil);
    }
    if (!nullToAbsent || weekdays != null) {
      map['weekdays'] = Variable<String>(weekdays);
    }
    map['created_by'] = Variable<String>(createdBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CalendarEventsCompanion toCompanion(bool nullToAbsent) {
    return CalendarEventsCompanion(
      id: Value(id),
      title: Value(title),
      type: Value(type),
      startsAt: Value(startsAt),
      endsAt: endsAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endsAt),
      lotId: lotId == null && nullToAbsent
          ? const Value.absent()
          : Value(lotId),
      referenceType: referenceType == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceType),
      referenceId: referenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceId),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      alertEnabled: Value(alertEnabled),
      alertMessage: alertMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(alertMessage),
      alertTime: Value(alertTime),
      recurrence: Value(recurrence),
      repeatUntil: repeatUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(repeatUntil),
      weekdays: weekdays == null && nullToAbsent
          ? const Value.absent()
          : Value(weekdays),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
    );
  }

  factory CalendarEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CalendarEvent(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      type: serializer.fromJson<String>(json['type']),
      startsAt: serializer.fromJson<DateTime>(json['startsAt']),
      endsAt: serializer.fromJson<DateTime?>(json['endsAt']),
      lotId: serializer.fromJson<String?>(json['lotId']),
      referenceType: serializer.fromJson<String?>(json['referenceType']),
      referenceId: serializer.fromJson<String?>(json['referenceId']),
      notes: serializer.fromJson<String?>(json['notes']),
      alertEnabled: serializer.fromJson<bool>(json['alertEnabled']),
      alertMessage: serializer.fromJson<String?>(json['alertMessage']),
      alertTime: serializer.fromJson<String>(json['alertTime']),
      recurrence: serializer.fromJson<String>(json['recurrence']),
      repeatUntil: serializer.fromJson<DateTime?>(json['repeatUntil']),
      weekdays: serializer.fromJson<String?>(json['weekdays']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'type': serializer.toJson<String>(type),
      'startsAt': serializer.toJson<DateTime>(startsAt),
      'endsAt': serializer.toJson<DateTime?>(endsAt),
      'lotId': serializer.toJson<String?>(lotId),
      'referenceType': serializer.toJson<String?>(referenceType),
      'referenceId': serializer.toJson<String?>(referenceId),
      'notes': serializer.toJson<String?>(notes),
      'alertEnabled': serializer.toJson<bool>(alertEnabled),
      'alertMessage': serializer.toJson<String?>(alertMessage),
      'alertTime': serializer.toJson<String>(alertTime),
      'recurrence': serializer.toJson<String>(recurrence),
      'repeatUntil': serializer.toJson<DateTime?>(repeatUntil),
      'weekdays': serializer.toJson<String?>(weekdays),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CalendarEvent copyWith({
    String? id,
    String? title,
    String? type,
    DateTime? startsAt,
    Value<DateTime?> endsAt = const Value.absent(),
    Value<String?> lotId = const Value.absent(),
    Value<String?> referenceType = const Value.absent(),
    Value<String?> referenceId = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? alertEnabled,
    Value<String?> alertMessage = const Value.absent(),
    String? alertTime,
    String? recurrence,
    Value<DateTime?> repeatUntil = const Value.absent(),
    Value<String?> weekdays = const Value.absent(),
    String? createdBy,
    DateTime? createdAt,
  }) => CalendarEvent(
    id: id ?? this.id,
    title: title ?? this.title,
    type: type ?? this.type,
    startsAt: startsAt ?? this.startsAt,
    endsAt: endsAt.present ? endsAt.value : this.endsAt,
    lotId: lotId.present ? lotId.value : this.lotId,
    referenceType: referenceType.present
        ? referenceType.value
        : this.referenceType,
    referenceId: referenceId.present ? referenceId.value : this.referenceId,
    notes: notes.present ? notes.value : this.notes,
    alertEnabled: alertEnabled ?? this.alertEnabled,
    alertMessage: alertMessage.present ? alertMessage.value : this.alertMessage,
    alertTime: alertTime ?? this.alertTime,
    recurrence: recurrence ?? this.recurrence,
    repeatUntil: repeatUntil.present ? repeatUntil.value : this.repeatUntil,
    weekdays: weekdays.present ? weekdays.value : this.weekdays,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
  );
  CalendarEvent copyWithCompanion(CalendarEventsCompanion data) {
    return CalendarEvent(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      type: data.type.present ? data.type.value : this.type,
      startsAt: data.startsAt.present ? data.startsAt.value : this.startsAt,
      endsAt: data.endsAt.present ? data.endsAt.value : this.endsAt,
      lotId: data.lotId.present ? data.lotId.value : this.lotId,
      referenceType: data.referenceType.present
          ? data.referenceType.value
          : this.referenceType,
      referenceId: data.referenceId.present
          ? data.referenceId.value
          : this.referenceId,
      notes: data.notes.present ? data.notes.value : this.notes,
      alertEnabled: data.alertEnabled.present
          ? data.alertEnabled.value
          : this.alertEnabled,
      alertMessage: data.alertMessage.present
          ? data.alertMessage.value
          : this.alertMessage,
      alertTime: data.alertTime.present ? data.alertTime.value : this.alertTime,
      recurrence: data.recurrence.present
          ? data.recurrence.value
          : this.recurrence,
      repeatUntil: data.repeatUntil.present
          ? data.repeatUntil.value
          : this.repeatUntil,
      weekdays: data.weekdays.present ? data.weekdays.value : this.weekdays,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CalendarEvent(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('startsAt: $startsAt, ')
          ..write('endsAt: $endsAt, ')
          ..write('lotId: $lotId, ')
          ..write('referenceType: $referenceType, ')
          ..write('referenceId: $referenceId, ')
          ..write('notes: $notes, ')
          ..write('alertEnabled: $alertEnabled, ')
          ..write('alertMessage: $alertMessage, ')
          ..write('alertTime: $alertTime, ')
          ..write('recurrence: $recurrence, ')
          ..write('repeatUntil: $repeatUntil, ')
          ..write('weekdays: $weekdays, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    type,
    startsAt,
    endsAt,
    lotId,
    referenceType,
    referenceId,
    notes,
    alertEnabled,
    alertMessage,
    alertTime,
    recurrence,
    repeatUntil,
    weekdays,
    createdBy,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalendarEvent &&
          other.id == this.id &&
          other.title == this.title &&
          other.type == this.type &&
          other.startsAt == this.startsAt &&
          other.endsAt == this.endsAt &&
          other.lotId == this.lotId &&
          other.referenceType == this.referenceType &&
          other.referenceId == this.referenceId &&
          other.notes == this.notes &&
          other.alertEnabled == this.alertEnabled &&
          other.alertMessage == this.alertMessage &&
          other.alertTime == this.alertTime &&
          other.recurrence == this.recurrence &&
          other.repeatUntil == this.repeatUntil &&
          other.weekdays == this.weekdays &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt);
}

class CalendarEventsCompanion extends UpdateCompanion<CalendarEvent> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> type;
  final Value<DateTime> startsAt;
  final Value<DateTime?> endsAt;
  final Value<String?> lotId;
  final Value<String?> referenceType;
  final Value<String?> referenceId;
  final Value<String?> notes;
  final Value<bool> alertEnabled;
  final Value<String?> alertMessage;
  final Value<String> alertTime;
  final Value<String> recurrence;
  final Value<DateTime?> repeatUntil;
  final Value<String?> weekdays;
  final Value<String> createdBy;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CalendarEventsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.type = const Value.absent(),
    this.startsAt = const Value.absent(),
    this.endsAt = const Value.absent(),
    this.lotId = const Value.absent(),
    this.referenceType = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.notes = const Value.absent(),
    this.alertEnabled = const Value.absent(),
    this.alertMessage = const Value.absent(),
    this.alertTime = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.repeatUntil = const Value.absent(),
    this.weekdays = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CalendarEventsCompanion.insert({
    required String id,
    required String title,
    required String type,
    required DateTime startsAt,
    this.endsAt = const Value.absent(),
    this.lotId = const Value.absent(),
    this.referenceType = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.notes = const Value.absent(),
    this.alertEnabled = const Value.absent(),
    this.alertMessage = const Value.absent(),
    this.alertTime = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.repeatUntil = const Value.absent(),
    this.weekdays = const Value.absent(),
    required String createdBy,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       type = Value(type),
       startsAt = Value(startsAt),
       createdBy = Value(createdBy),
       createdAt = Value(createdAt);
  static Insertable<CalendarEvent> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? type,
    Expression<DateTime>? startsAt,
    Expression<DateTime>? endsAt,
    Expression<String>? lotId,
    Expression<String>? referenceType,
    Expression<String>? referenceId,
    Expression<String>? notes,
    Expression<bool>? alertEnabled,
    Expression<String>? alertMessage,
    Expression<String>? alertTime,
    Expression<String>? recurrence,
    Expression<DateTime>? repeatUntil,
    Expression<String>? weekdays,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (type != null) 'type': type,
      if (startsAt != null) 'starts_at': startsAt,
      if (endsAt != null) 'ends_at': endsAt,
      if (lotId != null) 'lot_id': lotId,
      if (referenceType != null) 'reference_type': referenceType,
      if (referenceId != null) 'reference_id': referenceId,
      if (notes != null) 'notes': notes,
      if (alertEnabled != null) 'alert_enabled': alertEnabled,
      if (alertMessage != null) 'alert_message': alertMessage,
      if (alertTime != null) 'alert_time': alertTime,
      if (recurrence != null) 'recurrence': recurrence,
      if (repeatUntil != null) 'repeat_until': repeatUntil,
      if (weekdays != null) 'weekdays': weekdays,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CalendarEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? type,
    Value<DateTime>? startsAt,
    Value<DateTime?>? endsAt,
    Value<String?>? lotId,
    Value<String?>? referenceType,
    Value<String?>? referenceId,
    Value<String?>? notes,
    Value<bool>? alertEnabled,
    Value<String?>? alertMessage,
    Value<String>? alertTime,
    Value<String>? recurrence,
    Value<DateTime?>? repeatUntil,
    Value<String?>? weekdays,
    Value<String>? createdBy,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CalendarEventsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      lotId: lotId ?? this.lotId,
      referenceType: referenceType ?? this.referenceType,
      referenceId: referenceId ?? this.referenceId,
      notes: notes ?? this.notes,
      alertEnabled: alertEnabled ?? this.alertEnabled,
      alertMessage: alertMessage ?? this.alertMessage,
      alertTime: alertTime ?? this.alertTime,
      recurrence: recurrence ?? this.recurrence,
      repeatUntil: repeatUntil ?? this.repeatUntil,
      weekdays: weekdays ?? this.weekdays,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (startsAt.present) {
      map['starts_at'] = Variable<DateTime>(startsAt.value);
    }
    if (endsAt.present) {
      map['ends_at'] = Variable<DateTime>(endsAt.value);
    }
    if (lotId.present) {
      map['lot_id'] = Variable<String>(lotId.value);
    }
    if (referenceType.present) {
      map['reference_type'] = Variable<String>(referenceType.value);
    }
    if (referenceId.present) {
      map['reference_id'] = Variable<String>(referenceId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (alertEnabled.present) {
      map['alert_enabled'] = Variable<bool>(alertEnabled.value);
    }
    if (alertMessage.present) {
      map['alert_message'] = Variable<String>(alertMessage.value);
    }
    if (alertTime.present) {
      map['alert_time'] = Variable<String>(alertTime.value);
    }
    if (recurrence.present) {
      map['recurrence'] = Variable<String>(recurrence.value);
    }
    if (repeatUntil.present) {
      map['repeat_until'] = Variable<DateTime>(repeatUntil.value);
    }
    if (weekdays.present) {
      map['weekdays'] = Variable<String>(weekdays.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CalendarEventsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('startsAt: $startsAt, ')
          ..write('endsAt: $endsAt, ')
          ..write('lotId: $lotId, ')
          ..write('referenceType: $referenceType, ')
          ..write('referenceId: $referenceId, ')
          ..write('notes: $notes, ')
          ..write('alertEnabled: $alertEnabled, ')
          ..write('alertMessage: $alertMessage, ')
          ..write('alertTime: $alertTime, ')
          ..write('recurrence: $recurrence, ')
          ..write('repeatUntil: $repeatUntil, ')
          ..write('weekdays: $weekdays, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotificationSettingsTable extends NotificationSettings
    with TableInfo<$NotificationSettingsTable, NotificationSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _daysBeforeMeta = const VerificationMeta(
    'daysBefore',
  );
  @override
  late final GeneratedColumn<int> daysBefore = GeneratedColumn<int>(
    'days_before',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _notificationTimeMeta = const VerificationMeta(
    'notificationTime',
  );
  @override
  late final GeneratedColumn<String> notificationTime = GeneratedColumn<String>(
    'notification_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('08:00'),
  );
  static const VerificationMeta _defaultMessageMeta = const VerificationMeta(
    'defaultMessage',
  );
  @override
  late final GeneratedColumn<String> defaultMessage = GeneratedColumn<String>(
    'default_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultRecurrenceMeta = const VerificationMeta(
    'defaultRecurrence',
  );
  @override
  late final GeneratedColumn<String> defaultRecurrence =
      GeneratedColumn<String>(
        'default_recurrence',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('ONCE'),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    isEnabled,
    daysBefore,
    notificationTime,
    defaultMessage,
    defaultRecurrence,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notification_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotificationSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    }
    if (data.containsKey('days_before')) {
      context.handle(
        _daysBeforeMeta,
        daysBefore.isAcceptableOrUnknown(data['days_before']!, _daysBeforeMeta),
      );
    }
    if (data.containsKey('notification_time')) {
      context.handle(
        _notificationTimeMeta,
        notificationTime.isAcceptableOrUnknown(
          data['notification_time']!,
          _notificationTimeMeta,
        ),
      );
    }
    if (data.containsKey('default_message')) {
      context.handle(
        _defaultMessageMeta,
        defaultMessage.isAcceptableOrUnknown(
          data['default_message']!,
          _defaultMessageMeta,
        ),
      );
    }
    if (data.containsKey('default_recurrence')) {
      context.handle(
        _defaultRecurrenceMeta,
        defaultRecurrence.isAcceptableOrUnknown(
          data['default_recurrence']!,
          _defaultRecurrenceMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotificationSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
      daysBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}days_before'],
      )!,
      notificationTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notification_time'],
      )!,
      defaultMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_message'],
      ),
      defaultRecurrence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_recurrence'],
      )!,
    );
  }

  @override
  $NotificationSettingsTable createAlias(String alias) {
    return $NotificationSettingsTable(attachedDatabase, alias);
  }
}

class NotificationSetting extends DataClass
    implements Insertable<NotificationSetting> {
  final String id;
  final String type;
  final bool isEnabled;
  final int daysBefore;
  final String notificationTime;
  final String? defaultMessage;
  final String defaultRecurrence;
  const NotificationSetting({
    required this.id,
    required this.type,
    required this.isEnabled,
    required this.daysBefore,
    required this.notificationTime,
    this.defaultMessage,
    required this.defaultRecurrence,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['days_before'] = Variable<int>(daysBefore);
    map['notification_time'] = Variable<String>(notificationTime);
    if (!nullToAbsent || defaultMessage != null) {
      map['default_message'] = Variable<String>(defaultMessage);
    }
    map['default_recurrence'] = Variable<String>(defaultRecurrence);
    return map;
  }

  NotificationSettingsCompanion toCompanion(bool nullToAbsent) {
    return NotificationSettingsCompanion(
      id: Value(id),
      type: Value(type),
      isEnabled: Value(isEnabled),
      daysBefore: Value(daysBefore),
      notificationTime: Value(notificationTime),
      defaultMessage: defaultMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultMessage),
      defaultRecurrence: Value(defaultRecurrence),
    );
  }

  factory NotificationSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationSetting(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      daysBefore: serializer.fromJson<int>(json['daysBefore']),
      notificationTime: serializer.fromJson<String>(json['notificationTime']),
      defaultMessage: serializer.fromJson<String?>(json['defaultMessage']),
      defaultRecurrence: serializer.fromJson<String>(json['defaultRecurrence']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'daysBefore': serializer.toJson<int>(daysBefore),
      'notificationTime': serializer.toJson<String>(notificationTime),
      'defaultMessage': serializer.toJson<String?>(defaultMessage),
      'defaultRecurrence': serializer.toJson<String>(defaultRecurrence),
    };
  }

  NotificationSetting copyWith({
    String? id,
    String? type,
    bool? isEnabled,
    int? daysBefore,
    String? notificationTime,
    Value<String?> defaultMessage = const Value.absent(),
    String? defaultRecurrence,
  }) => NotificationSetting(
    id: id ?? this.id,
    type: type ?? this.type,
    isEnabled: isEnabled ?? this.isEnabled,
    daysBefore: daysBefore ?? this.daysBefore,
    notificationTime: notificationTime ?? this.notificationTime,
    defaultMessage: defaultMessage.present
        ? defaultMessage.value
        : this.defaultMessage,
    defaultRecurrence: defaultRecurrence ?? this.defaultRecurrence,
  );
  NotificationSetting copyWithCompanion(NotificationSettingsCompanion data) {
    return NotificationSetting(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      daysBefore: data.daysBefore.present
          ? data.daysBefore.value
          : this.daysBefore,
      notificationTime: data.notificationTime.present
          ? data.notificationTime.value
          : this.notificationTime,
      defaultMessage: data.defaultMessage.present
          ? data.defaultMessage.value
          : this.defaultMessage,
      defaultRecurrence: data.defaultRecurrence.present
          ? data.defaultRecurrence.value
          : this.defaultRecurrence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationSetting(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('daysBefore: $daysBefore, ')
          ..write('notificationTime: $notificationTime, ')
          ..write('defaultMessage: $defaultMessage, ')
          ..write('defaultRecurrence: $defaultRecurrence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    isEnabled,
    daysBefore,
    notificationTime,
    defaultMessage,
    defaultRecurrence,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationSetting &&
          other.id == this.id &&
          other.type == this.type &&
          other.isEnabled == this.isEnabled &&
          other.daysBefore == this.daysBefore &&
          other.notificationTime == this.notificationTime &&
          other.defaultMessage == this.defaultMessage &&
          other.defaultRecurrence == this.defaultRecurrence);
}

class NotificationSettingsCompanion
    extends UpdateCompanion<NotificationSetting> {
  final Value<String> id;
  final Value<String> type;
  final Value<bool> isEnabled;
  final Value<int> daysBefore;
  final Value<String> notificationTime;
  final Value<String?> defaultMessage;
  final Value<String> defaultRecurrence;
  final Value<int> rowid;
  const NotificationSettingsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.daysBefore = const Value.absent(),
    this.notificationTime = const Value.absent(),
    this.defaultMessage = const Value.absent(),
    this.defaultRecurrence = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotificationSettingsCompanion.insert({
    required String id,
    required String type,
    this.isEnabled = const Value.absent(),
    this.daysBefore = const Value.absent(),
    this.notificationTime = const Value.absent(),
    this.defaultMessage = const Value.absent(),
    this.defaultRecurrence = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type);
  static Insertable<NotificationSetting> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<bool>? isEnabled,
    Expression<int>? daysBefore,
    Expression<String>? notificationTime,
    Expression<String>? defaultMessage,
    Expression<String>? defaultRecurrence,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (daysBefore != null) 'days_before': daysBefore,
      if (notificationTime != null) 'notification_time': notificationTime,
      if (defaultMessage != null) 'default_message': defaultMessage,
      if (defaultRecurrence != null) 'default_recurrence': defaultRecurrence,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotificationSettingsCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<bool>? isEnabled,
    Value<int>? daysBefore,
    Value<String>? notificationTime,
    Value<String?>? defaultMessage,
    Value<String>? defaultRecurrence,
    Value<int>? rowid,
  }) {
    return NotificationSettingsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      isEnabled: isEnabled ?? this.isEnabled,
      daysBefore: daysBefore ?? this.daysBefore,
      notificationTime: notificationTime ?? this.notificationTime,
      defaultMessage: defaultMessage ?? this.defaultMessage,
      defaultRecurrence: defaultRecurrence ?? this.defaultRecurrence,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (daysBefore.present) {
      map['days_before'] = Variable<int>(daysBefore.value);
    }
    if (notificationTime.present) {
      map['notification_time'] = Variable<String>(notificationTime.value);
    }
    if (defaultMessage.present) {
      map['default_message'] = Variable<String>(defaultMessage.value);
    }
    if (defaultRecurrence.present) {
      map['default_recurrence'] = Variable<String>(defaultRecurrence.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationSettingsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('daysBefore: $daysBefore, ')
          ..write('notificationTime: $notificationTime, ')
          ..write('defaultMessage: $defaultMessage, ')
          ..write('defaultRecurrence: $defaultRecurrence, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt, updatedBy];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      ),
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  final DateTime updatedAt;
  final String? updatedBy;
  const AppSetting({
    required this.key,
    required this.value,
    required this.updatedAt,
    this.updatedBy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'updatedBy': serializer.toJson<String?>(updatedBy),
    };
  }

  AppSetting copyWith({
    String? key,
    String? value,
    DateTime? updatedAt,
    Value<String?> updatedBy = const Value.absent(),
  }) => AppSetting(
    key: key ?? this.key,
    value: value ?? this.value,
    updatedAt: updatedAt ?? this.updatedAt,
    updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt, updatedBy);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<String?> updatedBy;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.updatedBy = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<String>? updatedBy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<String?>? updatedBy,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $UserPermissionsTable userPermissions = $UserPermissionsTable(
    this,
  );
  late final $AuditLogsTable auditLogs = $AuditLogsTable(this);
  late final $LotsTable lots = $LotsTable(this);
  late final $BirdMovementsTable birdMovements = $BirdMovementsTable(this);
  late final $EggCollectionsTable eggCollections = $EggCollectionsTable(this);
  late final $EggStockMovementsTable eggStockMovements =
      $EggStockMovementsTable(this);
  late final $IngredientsTable ingredients = $IngredientsTable(this);
  late final $IngredientPriceHistoryTable ingredientPriceHistory =
      $IngredientPriceHistoryTable(this);
  late final $IngredientLotsTable ingredientLots = $IngredientLotsTable(this);
  late final $IngredientStockMovementsTable ingredientStockMovements =
      $IngredientStockMovementsTable(this);
  late final $FeedFormulasTable feedFormulas = $FeedFormulasTable(this);
  late final $FeedFormulaItemsTable feedFormulaItems = $FeedFormulaItemsTable(
    this,
  );
  late final $FeedBatchesTable feedBatches = $FeedBatchesTable(this);
  late final $FeedBatchItemsTable feedBatchItems = $FeedBatchItemsTable(this);
  late final $FeedStockMovementsTable feedStockMovements =
      $FeedStockMovementsTable(this);
  late final $DailyFeedingsTable dailyFeedings = $DailyFeedingsTable(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $OrdersTable orders = $OrdersTable(this);
  late final $OrderItemsTable orderItems = $OrderItemsTable(this);
  late final $OrderStatusHistoryTable orderStatusHistory =
      $OrderStatusHistoryTable(this);
  late final $SalesTable sales = $SalesTable(this);
  late final $FinanceTransactionsTable financeTransactions =
      $FinanceTransactionsTable(this);
  late final $InvestmentsTable investments = $InvestmentsTable(this);
  late final $LightingProgramsTable lightingPrograms = $LightingProgramsTable(
    this,
  );
  late final $LightingProgramStepsTable lightingProgramSteps =
      $LightingProgramStepsTable(this);
  late final $LotLightingProgramsTable lotLightingPrograms =
      $LotLightingProgramsTable(this);
  late final $CalendarEventsTable calendarEvents = $CalendarEventsTable(this);
  late final $NotificationSettingsTable notificationSettings =
      $NotificationSettingsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    userPermissions,
    auditLogs,
    lots,
    birdMovements,
    eggCollections,
    eggStockMovements,
    ingredients,
    ingredientPriceHistory,
    ingredientLots,
    ingredientStockMovements,
    feedFormulas,
    feedFormulaItems,
    feedBatches,
    feedBatchItems,
    feedStockMovements,
    dailyFeedings,
    customers,
    orders,
    orderItems,
    orderStatusHistory,
    sales,
    financeTransactions,
    investments,
    lightingPrograms,
    lightingProgramSteps,
    lotLightingPrograms,
    calendarEvents,
    notificationSettings,
    appSettings,
  ];
}

typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      required String id,
      required String username,
      required String displayName,
      required String passwordHash,
      Value<bool> isSuperuser,
      Value<bool> isActive,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> lastLoginAt,
      Value<int> rowid,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<String> id,
      Value<String> username,
      Value<String> displayName,
      Value<String> passwordHash,
      Value<bool> isSuperuser,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastLoginAt,
      Value<int> rowid,
    });

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSuperuser => $composableBuilder(
    column: $table.isSuperuser,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSuperuser => $composableBuilder(
    column: $table.isSuperuser,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSuperuser => $composableBuilder(
    column: $table.isSuperuser,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => column,
  );
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
          User,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> passwordHash = const Value.absent(),
                Value<bool> isSuperuser = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastLoginAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                username: username,
                displayName: displayName,
                passwordHash: passwordHash,
                isSuperuser: isSuperuser,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastLoginAt: lastLoginAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String username,
                required String displayName,
                required String passwordHash,
                Value<bool> isSuperuser = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> lastLoginAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                username: username,
                displayName: displayName,
                passwordHash: passwordHash,
                isSuperuser: isSuperuser,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastLoginAt: lastLoginAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
      User,
      PrefetchHooks Function()
    >;
typedef $$UserPermissionsTableCreateCompanionBuilder =
    UserPermissionsCompanion Function({
      required String id,
      required String userId,
      required String permission,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$UserPermissionsTableUpdateCompanionBuilder =
    UserPermissionsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> permission,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$UserPermissionsTableFilterComposer
    extends Composer<_$AppDatabase, $UserPermissionsTable> {
  $$UserPermissionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get permission => $composableBuilder(
    column: $table.permission,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserPermissionsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserPermissionsTable> {
  $$UserPermissionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get permission => $composableBuilder(
    column: $table.permission,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserPermissionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserPermissionsTable> {
  $$UserPermissionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get permission => $composableBuilder(
    column: $table.permission,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UserPermissionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserPermissionsTable,
          UserPermission,
          $$UserPermissionsTableFilterComposer,
          $$UserPermissionsTableOrderingComposer,
          $$UserPermissionsTableAnnotationComposer,
          $$UserPermissionsTableCreateCompanionBuilder,
          $$UserPermissionsTableUpdateCompanionBuilder,
          (
            UserPermission,
            BaseReferences<
              _$AppDatabase,
              $UserPermissionsTable,
              UserPermission
            >,
          ),
          UserPermission,
          PrefetchHooks Function()
        > {
  $$UserPermissionsTableTableManager(
    _$AppDatabase db,
    $UserPermissionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserPermissionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserPermissionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserPermissionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> permission = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserPermissionsCompanion(
                id: id,
                userId: userId,
                permission: permission,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String permission,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => UserPermissionsCompanion.insert(
                id: id,
                userId: userId,
                permission: permission,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserPermissionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserPermissionsTable,
      UserPermission,
      $$UserPermissionsTableFilterComposer,
      $$UserPermissionsTableOrderingComposer,
      $$UserPermissionsTableAnnotationComposer,
      $$UserPermissionsTableCreateCompanionBuilder,
      $$UserPermissionsTableUpdateCompanionBuilder,
      (
        UserPermission,
        BaseReferences<_$AppDatabase, $UserPermissionsTable, UserPermission>,
      ),
      UserPermission,
      PrefetchHooks Function()
    >;
typedef $$AuditLogsTableCreateCompanionBuilder =
    AuditLogsCompanion Function({
      required String id,
      Value<String?> userId,
      required String action,
      required String entityType,
      Value<String?> entityId,
      required DateTime timestamp,
      required String description,
      Value<String?> metadata,
      Value<int> rowid,
    });
typedef $$AuditLogsTableUpdateCompanionBuilder =
    AuditLogsCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<String> action,
      Value<String> entityType,
      Value<String?> entityId,
      Value<DateTime> timestamp,
      Value<String> description,
      Value<String?> metadata,
      Value<int> rowid,
    });

class $$AuditLogsTableFilterComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AuditLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AuditLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);
}

class $$AuditLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuditLogsTable,
          AuditLog,
          $$AuditLogsTableFilterComposer,
          $$AuditLogsTableOrderingComposer,
          $$AuditLogsTableAnnotationComposer,
          $$AuditLogsTableCreateCompanionBuilder,
          $$AuditLogsTableUpdateCompanionBuilder,
          (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>),
          AuditLog,
          PrefetchHooks Function()
        > {
  $$AuditLogsTableTableManager(_$AppDatabase db, $AuditLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String?> entityId = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditLogsCompanion(
                id: id,
                userId: userId,
                action: action,
                entityType: entityType,
                entityId: entityId,
                timestamp: timestamp,
                description: description,
                metadata: metadata,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> userId = const Value.absent(),
                required String action,
                required String entityType,
                Value<String?> entityId = const Value.absent(),
                required DateTime timestamp,
                required String description,
                Value<String?> metadata = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditLogsCompanion.insert(
                id: id,
                userId: userId,
                action: action,
                entityType: entityType,
                entityId: entityId,
                timestamp: timestamp,
                description: description,
                metadata: metadata,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AuditLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuditLogsTable,
      AuditLog,
      $$AuditLogsTableFilterComposer,
      $$AuditLogsTableOrderingComposer,
      $$AuditLogsTableAnnotationComposer,
      $$AuditLogsTableCreateCompanionBuilder,
      $$AuditLogsTableUpdateCompanionBuilder,
      (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>),
      AuditLog,
      PrefetchHooks Function()
    >;
typedef $$LotsTableCreateCompanionBuilder =
    LotsCompanion Function({
      required String id,
      required String name,
      Value<String?> strain,
      required int initialQuantity,
      required DateTime receivedAt,
      required int arrivalAgeDays,
      Value<int?> unitValueCents,
      Value<String?> supplier,
      Value<String?> notes,
      Value<String> status,
      required DateTime createdAt,
      required String createdBy,
      Value<int> rowid,
    });
typedef $$LotsTableUpdateCompanionBuilder =
    LotsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> strain,
      Value<int> initialQuantity,
      Value<DateTime> receivedAt,
      Value<int> arrivalAgeDays,
      Value<int?> unitValueCents,
      Value<String?> supplier,
      Value<String?> notes,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<String> createdBy,
      Value<int> rowid,
    });

class $$LotsTableFilterComposer extends Composer<_$AppDatabase, $LotsTable> {
  $$LotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get strain => $composableBuilder(
    column: $table.strain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get initialQuantity => $composableBuilder(
    column: $table.initialQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get arrivalAgeDays => $composableBuilder(
    column: $table.arrivalAgeDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitValueCents => $composableBuilder(
    column: $table.unitValueCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supplier => $composableBuilder(
    column: $table.supplier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LotsTableOrderingComposer extends Composer<_$AppDatabase, $LotsTable> {
  $$LotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get strain => $composableBuilder(
    column: $table.strain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get initialQuantity => $composableBuilder(
    column: $table.initialQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get arrivalAgeDays => $composableBuilder(
    column: $table.arrivalAgeDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitValueCents => $composableBuilder(
    column: $table.unitValueCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supplier => $composableBuilder(
    column: $table.supplier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LotsTable> {
  $$LotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get strain =>
      $composableBuilder(column: $table.strain, builder: (column) => column);

  GeneratedColumn<int> get initialQuantity => $composableBuilder(
    column: $table.initialQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get arrivalAgeDays => $composableBuilder(
    column: $table.arrivalAgeDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unitValueCents => $composableBuilder(
    column: $table.unitValueCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get supplier =>
      $composableBuilder(column: $table.supplier, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);
}

class $$LotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LotsTable,
          Lot,
          $$LotsTableFilterComposer,
          $$LotsTableOrderingComposer,
          $$LotsTableAnnotationComposer,
          $$LotsTableCreateCompanionBuilder,
          $$LotsTableUpdateCompanionBuilder,
          (Lot, BaseReferences<_$AppDatabase, $LotsTable, Lot>),
          Lot,
          PrefetchHooks Function()
        > {
  $$LotsTableTableManager(_$AppDatabase db, $LotsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> strain = const Value.absent(),
                Value<int> initialQuantity = const Value.absent(),
                Value<DateTime> receivedAt = const Value.absent(),
                Value<int> arrivalAgeDays = const Value.absent(),
                Value<int?> unitValueCents = const Value.absent(),
                Value<String?> supplier = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LotsCompanion(
                id: id,
                name: name,
                strain: strain,
                initialQuantity: initialQuantity,
                receivedAt: receivedAt,
                arrivalAgeDays: arrivalAgeDays,
                unitValueCents: unitValueCents,
                supplier: supplier,
                notes: notes,
                status: status,
                createdAt: createdAt,
                createdBy: createdBy,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> strain = const Value.absent(),
                required int initialQuantity,
                required DateTime receivedAt,
                required int arrivalAgeDays,
                Value<int?> unitValueCents = const Value.absent(),
                Value<String?> supplier = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> status = const Value.absent(),
                required DateTime createdAt,
                required String createdBy,
                Value<int> rowid = const Value.absent(),
              }) => LotsCompanion.insert(
                id: id,
                name: name,
                strain: strain,
                initialQuantity: initialQuantity,
                receivedAt: receivedAt,
                arrivalAgeDays: arrivalAgeDays,
                unitValueCents: unitValueCents,
                supplier: supplier,
                notes: notes,
                status: status,
                createdAt: createdAt,
                createdBy: createdBy,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LotsTable,
      Lot,
      $$LotsTableFilterComposer,
      $$LotsTableOrderingComposer,
      $$LotsTableAnnotationComposer,
      $$LotsTableCreateCompanionBuilder,
      $$LotsTableUpdateCompanionBuilder,
      (Lot, BaseReferences<_$AppDatabase, $LotsTable, Lot>),
      Lot,
      PrefetchHooks Function()
    >;
typedef $$BirdMovementsTableCreateCompanionBuilder =
    BirdMovementsCompanion Function({
      required String id,
      required String type,
      required DateTime occurredAt,
      required String lotId,
      Value<String?> relatedLotId,
      required int quantity,
      Value<int?> unitValueCents,
      Value<int?> totalValueCents,
      Value<String?> reference,
      Value<String?> notes,
      required String createdBy,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$BirdMovementsTableUpdateCompanionBuilder =
    BirdMovementsCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<DateTime> occurredAt,
      Value<String> lotId,
      Value<String?> relatedLotId,
      Value<int> quantity,
      Value<int?> unitValueCents,
      Value<int?> totalValueCents,
      Value<String?> reference,
      Value<String?> notes,
      Value<String> createdBy,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$BirdMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $BirdMovementsTable> {
  $$BirdMovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lotId => $composableBuilder(
    column: $table.lotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relatedLotId => $composableBuilder(
    column: $table.relatedLotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitValueCents => $composableBuilder(
    column: $table.unitValueCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalValueCents => $composableBuilder(
    column: $table.totalValueCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BirdMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $BirdMovementsTable> {
  $$BirdMovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lotId => $composableBuilder(
    column: $table.lotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relatedLotId => $composableBuilder(
    column: $table.relatedLotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitValueCents => $composableBuilder(
    column: $table.unitValueCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalValueCents => $composableBuilder(
    column: $table.totalValueCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BirdMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BirdMovementsTable> {
  $$BirdMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lotId =>
      $composableBuilder(column: $table.lotId, builder: (column) => column);

  GeneratedColumn<String> get relatedLotId => $composableBuilder(
    column: $table.relatedLotId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get unitValueCents => $composableBuilder(
    column: $table.unitValueCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalValueCents => $composableBuilder(
    column: $table.totalValueCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BirdMovementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BirdMovementsTable,
          BirdMovement,
          $$BirdMovementsTableFilterComposer,
          $$BirdMovementsTableOrderingComposer,
          $$BirdMovementsTableAnnotationComposer,
          $$BirdMovementsTableCreateCompanionBuilder,
          $$BirdMovementsTableUpdateCompanionBuilder,
          (
            BirdMovement,
            BaseReferences<_$AppDatabase, $BirdMovementsTable, BirdMovement>,
          ),
          BirdMovement,
          PrefetchHooks Function()
        > {
  $$BirdMovementsTableTableManager(_$AppDatabase db, $BirdMovementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BirdMovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BirdMovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BirdMovementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String> lotId = const Value.absent(),
                Value<String?> relatedLotId = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<int?> unitValueCents = const Value.absent(),
                Value<int?> totalValueCents = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BirdMovementsCompanion(
                id: id,
                type: type,
                occurredAt: occurredAt,
                lotId: lotId,
                relatedLotId: relatedLotId,
                quantity: quantity,
                unitValueCents: unitValueCents,
                totalValueCents: totalValueCents,
                reference: reference,
                notes: notes,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                required DateTime occurredAt,
                required String lotId,
                Value<String?> relatedLotId = const Value.absent(),
                required int quantity,
                Value<int?> unitValueCents = const Value.absent(),
                Value<int?> totalValueCents = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required String createdBy,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => BirdMovementsCompanion.insert(
                id: id,
                type: type,
                occurredAt: occurredAt,
                lotId: lotId,
                relatedLotId: relatedLotId,
                quantity: quantity,
                unitValueCents: unitValueCents,
                totalValueCents: totalValueCents,
                reference: reference,
                notes: notes,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BirdMovementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BirdMovementsTable,
      BirdMovement,
      $$BirdMovementsTableFilterComposer,
      $$BirdMovementsTableOrderingComposer,
      $$BirdMovementsTableAnnotationComposer,
      $$BirdMovementsTableCreateCompanionBuilder,
      $$BirdMovementsTableUpdateCompanionBuilder,
      (
        BirdMovement,
        BaseReferences<_$AppDatabase, $BirdMovementsTable, BirdMovement>,
      ),
      BirdMovement,
      PrefetchHooks Function()
    >;
typedef $$EggCollectionsTableCreateCompanionBuilder =
    EggCollectionsCompanion Function({
      required String id,
      required DateTime collectedOn,
      required String lotId,
      required int quantity,
      Value<int> brokenEggs,
      Value<int> discardedEggs,
      Value<String?> notes,
      required String createdBy,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$EggCollectionsTableUpdateCompanionBuilder =
    EggCollectionsCompanion Function({
      Value<String> id,
      Value<DateTime> collectedOn,
      Value<String> lotId,
      Value<int> quantity,
      Value<int> brokenEggs,
      Value<int> discardedEggs,
      Value<String?> notes,
      Value<String> createdBy,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$EggCollectionsTableFilterComposer
    extends Composer<_$AppDatabase, $EggCollectionsTable> {
  $$EggCollectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get collectedOn => $composableBuilder(
    column: $table.collectedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lotId => $composableBuilder(
    column: $table.lotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get brokenEggs => $composableBuilder(
    column: $table.brokenEggs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discardedEggs => $composableBuilder(
    column: $table.discardedEggs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EggCollectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $EggCollectionsTable> {
  $$EggCollectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get collectedOn => $composableBuilder(
    column: $table.collectedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lotId => $composableBuilder(
    column: $table.lotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get brokenEggs => $composableBuilder(
    column: $table.brokenEggs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discardedEggs => $composableBuilder(
    column: $table.discardedEggs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EggCollectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EggCollectionsTable> {
  $$EggCollectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get collectedOn => $composableBuilder(
    column: $table.collectedOn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lotId =>
      $composableBuilder(column: $table.lotId, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get brokenEggs => $composableBuilder(
    column: $table.brokenEggs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get discardedEggs => $composableBuilder(
    column: $table.discardedEggs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$EggCollectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EggCollectionsTable,
          EggCollection,
          $$EggCollectionsTableFilterComposer,
          $$EggCollectionsTableOrderingComposer,
          $$EggCollectionsTableAnnotationComposer,
          $$EggCollectionsTableCreateCompanionBuilder,
          $$EggCollectionsTableUpdateCompanionBuilder,
          (
            EggCollection,
            BaseReferences<_$AppDatabase, $EggCollectionsTable, EggCollection>,
          ),
          EggCollection,
          PrefetchHooks Function()
        > {
  $$EggCollectionsTableTableManager(
    _$AppDatabase db,
    $EggCollectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EggCollectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EggCollectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EggCollectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> collectedOn = const Value.absent(),
                Value<String> lotId = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<int> brokenEggs = const Value.absent(),
                Value<int> discardedEggs = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EggCollectionsCompanion(
                id: id,
                collectedOn: collectedOn,
                lotId: lotId,
                quantity: quantity,
                brokenEggs: brokenEggs,
                discardedEggs: discardedEggs,
                notes: notes,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime collectedOn,
                required String lotId,
                required int quantity,
                Value<int> brokenEggs = const Value.absent(),
                Value<int> discardedEggs = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required String createdBy,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => EggCollectionsCompanion.insert(
                id: id,
                collectedOn: collectedOn,
                lotId: lotId,
                quantity: quantity,
                brokenEggs: brokenEggs,
                discardedEggs: discardedEggs,
                notes: notes,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EggCollectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EggCollectionsTable,
      EggCollection,
      $$EggCollectionsTableFilterComposer,
      $$EggCollectionsTableOrderingComposer,
      $$EggCollectionsTableAnnotationComposer,
      $$EggCollectionsTableCreateCompanionBuilder,
      $$EggCollectionsTableUpdateCompanionBuilder,
      (
        EggCollection,
        BaseReferences<_$AppDatabase, $EggCollectionsTable, EggCollection>,
      ),
      EggCollection,
      PrefetchHooks Function()
    >;
typedef $$EggStockMovementsTableCreateCompanionBuilder =
    EggStockMovementsCompanion Function({
      required String id,
      required String type,
      required DateTime occurredAt,
      required int quantity,
      Value<String?> collectionId,
      Value<String?> reference,
      Value<String?> notes,
      required String createdBy,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$EggStockMovementsTableUpdateCompanionBuilder =
    EggStockMovementsCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<DateTime> occurredAt,
      Value<int> quantity,
      Value<String?> collectionId,
      Value<String?> reference,
      Value<String?> notes,
      Value<String> createdBy,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$EggStockMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $EggStockMovementsTable> {
  $$EggStockMovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EggStockMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $EggStockMovementsTable> {
  $$EggStockMovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EggStockMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EggStockMovementsTable> {
  $$EggStockMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$EggStockMovementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EggStockMovementsTable,
          EggStockMovement,
          $$EggStockMovementsTableFilterComposer,
          $$EggStockMovementsTableOrderingComposer,
          $$EggStockMovementsTableAnnotationComposer,
          $$EggStockMovementsTableCreateCompanionBuilder,
          $$EggStockMovementsTableUpdateCompanionBuilder,
          (
            EggStockMovement,
            BaseReferences<
              _$AppDatabase,
              $EggStockMovementsTable,
              EggStockMovement
            >,
          ),
          EggStockMovement,
          PrefetchHooks Function()
        > {
  $$EggStockMovementsTableTableManager(
    _$AppDatabase db,
    $EggStockMovementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EggStockMovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EggStockMovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EggStockMovementsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<String?> collectionId = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EggStockMovementsCompanion(
                id: id,
                type: type,
                occurredAt: occurredAt,
                quantity: quantity,
                collectionId: collectionId,
                reference: reference,
                notes: notes,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                required DateTime occurredAt,
                required int quantity,
                Value<String?> collectionId = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required String createdBy,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => EggStockMovementsCompanion.insert(
                id: id,
                type: type,
                occurredAt: occurredAt,
                quantity: quantity,
                collectionId: collectionId,
                reference: reference,
                notes: notes,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EggStockMovementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EggStockMovementsTable,
      EggStockMovement,
      $$EggStockMovementsTableFilterComposer,
      $$EggStockMovementsTableOrderingComposer,
      $$EggStockMovementsTableAnnotationComposer,
      $$EggStockMovementsTableCreateCompanionBuilder,
      $$EggStockMovementsTableUpdateCompanionBuilder,
      (
        EggStockMovement,
        BaseReferences<
          _$AppDatabase,
          $EggStockMovementsTable,
          EggStockMovement
        >,
      ),
      EggStockMovement,
      PrefetchHooks Function()
    >;
typedef $$IngredientsTableCreateCompanionBuilder =
    IngredientsCompanion Function({
      required String id,
      required String name,
      Value<String> unit,
      Value<bool> isActive,
      Value<String?> notes,
      required DateTime createdAt,
      required String createdBy,
      Value<int> rowid,
    });
typedef $$IngredientsTableUpdateCompanionBuilder =
    IngredientsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> unit,
      Value<bool> isActive,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<String> createdBy,
      Value<int> rowid,
    });

class $$IngredientsTableFilterComposer
    extends Composer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IngredientsTableOrderingComposer
    extends Composer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IngredientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);
}

class $$IngredientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IngredientsTable,
          Ingredient,
          $$IngredientsTableFilterComposer,
          $$IngredientsTableOrderingComposer,
          $$IngredientsTableAnnotationComposer,
          $$IngredientsTableCreateCompanionBuilder,
          $$IngredientsTableUpdateCompanionBuilder,
          (
            Ingredient,
            BaseReferences<_$AppDatabase, $IngredientsTable, Ingredient>,
          ),
          Ingredient,
          PrefetchHooks Function()
        > {
  $$IngredientsTableTableManager(_$AppDatabase db, $IngredientsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IngredientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IngredientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IngredientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IngredientsCompanion(
                id: id,
                name: name,
                unit: unit,
                isActive: isActive,
                notes: notes,
                createdAt: createdAt,
                createdBy: createdBy,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> unit = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                required String createdBy,
                Value<int> rowid = const Value.absent(),
              }) => IngredientsCompanion.insert(
                id: id,
                name: name,
                unit: unit,
                isActive: isActive,
                notes: notes,
                createdAt: createdAt,
                createdBy: createdBy,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IngredientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IngredientsTable,
      Ingredient,
      $$IngredientsTableFilterComposer,
      $$IngredientsTableOrderingComposer,
      $$IngredientsTableAnnotationComposer,
      $$IngredientsTableCreateCompanionBuilder,
      $$IngredientsTableUpdateCompanionBuilder,
      (
        Ingredient,
        BaseReferences<_$AppDatabase, $IngredientsTable, Ingredient>,
      ),
      Ingredient,
      PrefetchHooks Function()
    >;
typedef $$IngredientPriceHistoryTableCreateCompanionBuilder =
    IngredientPriceHistoryCompanion Function({
      required String id,
      required String ingredientId,
      required int pricePerKgCents,
      required DateTime effectiveDate,
      Value<String?> supplier,
      Value<String?> notes,
      required String createdBy,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$IngredientPriceHistoryTableUpdateCompanionBuilder =
    IngredientPriceHistoryCompanion Function({
      Value<String> id,
      Value<String> ingredientId,
      Value<int> pricePerKgCents,
      Value<DateTime> effectiveDate,
      Value<String?> supplier,
      Value<String?> notes,
      Value<String> createdBy,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$IngredientPriceHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $IngredientPriceHistoryTable> {
  $$IngredientPriceHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ingredientId => $composableBuilder(
    column: $table.ingredientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pricePerKgCents => $composableBuilder(
    column: $table.pricePerKgCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get effectiveDate => $composableBuilder(
    column: $table.effectiveDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supplier => $composableBuilder(
    column: $table.supplier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IngredientPriceHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $IngredientPriceHistoryTable> {
  $$IngredientPriceHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ingredientId => $composableBuilder(
    column: $table.ingredientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pricePerKgCents => $composableBuilder(
    column: $table.pricePerKgCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get effectiveDate => $composableBuilder(
    column: $table.effectiveDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supplier => $composableBuilder(
    column: $table.supplier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IngredientPriceHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $IngredientPriceHistoryTable> {
  $$IngredientPriceHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ingredientId => $composableBuilder(
    column: $table.ingredientId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pricePerKgCents => $composableBuilder(
    column: $table.pricePerKgCents,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get effectiveDate => $composableBuilder(
    column: $table.effectiveDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get supplier =>
      $composableBuilder(column: $table.supplier, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$IngredientPriceHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IngredientPriceHistoryTable,
          IngredientPriceHistoryData,
          $$IngredientPriceHistoryTableFilterComposer,
          $$IngredientPriceHistoryTableOrderingComposer,
          $$IngredientPriceHistoryTableAnnotationComposer,
          $$IngredientPriceHistoryTableCreateCompanionBuilder,
          $$IngredientPriceHistoryTableUpdateCompanionBuilder,
          (
            IngredientPriceHistoryData,
            BaseReferences<
              _$AppDatabase,
              $IngredientPriceHistoryTable,
              IngredientPriceHistoryData
            >,
          ),
          IngredientPriceHistoryData,
          PrefetchHooks Function()
        > {
  $$IngredientPriceHistoryTableTableManager(
    _$AppDatabase db,
    $IngredientPriceHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IngredientPriceHistoryTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$IngredientPriceHistoryTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$IngredientPriceHistoryTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ingredientId = const Value.absent(),
                Value<int> pricePerKgCents = const Value.absent(),
                Value<DateTime> effectiveDate = const Value.absent(),
                Value<String?> supplier = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IngredientPriceHistoryCompanion(
                id: id,
                ingredientId: ingredientId,
                pricePerKgCents: pricePerKgCents,
                effectiveDate: effectiveDate,
                supplier: supplier,
                notes: notes,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ingredientId,
                required int pricePerKgCents,
                required DateTime effectiveDate,
                Value<String?> supplier = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required String createdBy,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => IngredientPriceHistoryCompanion.insert(
                id: id,
                ingredientId: ingredientId,
                pricePerKgCents: pricePerKgCents,
                effectiveDate: effectiveDate,
                supplier: supplier,
                notes: notes,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IngredientPriceHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IngredientPriceHistoryTable,
      IngredientPriceHistoryData,
      $$IngredientPriceHistoryTableFilterComposer,
      $$IngredientPriceHistoryTableOrderingComposer,
      $$IngredientPriceHistoryTableAnnotationComposer,
      $$IngredientPriceHistoryTableCreateCompanionBuilder,
      $$IngredientPriceHistoryTableUpdateCompanionBuilder,
      (
        IngredientPriceHistoryData,
        BaseReferences<
          _$AppDatabase,
          $IngredientPriceHistoryTable,
          IngredientPriceHistoryData
        >,
      ),
      IngredientPriceHistoryData,
      PrefetchHooks Function()
    >;
typedef $$IngredientLotsTableCreateCompanionBuilder =
    IngredientLotsCompanion Function({
      required String id,
      required String ingredientId,
      required String code,
      required DateTime entryDate,
      required double initialQuantityKg,
      Value<String> packageUnit,
      Value<double> packageQuantity,
      Value<double> packageWeightKg,
      required int totalCostCents,
      required int pricePerKgCents,
      Value<String?> supplier,
      Value<String?> notes,
      required String createdBy,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$IngredientLotsTableUpdateCompanionBuilder =
    IngredientLotsCompanion Function({
      Value<String> id,
      Value<String> ingredientId,
      Value<String> code,
      Value<DateTime> entryDate,
      Value<double> initialQuantityKg,
      Value<String> packageUnit,
      Value<double> packageQuantity,
      Value<double> packageWeightKg,
      Value<int> totalCostCents,
      Value<int> pricePerKgCents,
      Value<String?> supplier,
      Value<String?> notes,
      Value<String> createdBy,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$IngredientLotsTableFilterComposer
    extends Composer<_$AppDatabase, $IngredientLotsTable> {
  $$IngredientLotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ingredientId => $composableBuilder(
    column: $table.ingredientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get initialQuantityKg => $composableBuilder(
    column: $table.initialQuantityKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packageUnit => $composableBuilder(
    column: $table.packageUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get packageQuantity => $composableBuilder(
    column: $table.packageQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get packageWeightKg => $composableBuilder(
    column: $table.packageWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCostCents => $composableBuilder(
    column: $table.totalCostCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pricePerKgCents => $composableBuilder(
    column: $table.pricePerKgCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supplier => $composableBuilder(
    column: $table.supplier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IngredientLotsTableOrderingComposer
    extends Composer<_$AppDatabase, $IngredientLotsTable> {
  $$IngredientLotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ingredientId => $composableBuilder(
    column: $table.ingredientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get initialQuantityKg => $composableBuilder(
    column: $table.initialQuantityKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packageUnit => $composableBuilder(
    column: $table.packageUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get packageQuantity => $composableBuilder(
    column: $table.packageQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get packageWeightKg => $composableBuilder(
    column: $table.packageWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCostCents => $composableBuilder(
    column: $table.totalCostCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pricePerKgCents => $composableBuilder(
    column: $table.pricePerKgCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supplier => $composableBuilder(
    column: $table.supplier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IngredientLotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IngredientLotsTable> {
  $$IngredientLotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ingredientId => $composableBuilder(
    column: $table.ingredientId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<DateTime> get entryDate =>
      $composableBuilder(column: $table.entryDate, builder: (column) => column);

  GeneratedColumn<double> get initialQuantityKg => $composableBuilder(
    column: $table.initialQuantityKg,
    builder: (column) => column,
  );

  GeneratedColumn<String> get packageUnit => $composableBuilder(
    column: $table.packageUnit,
    builder: (column) => column,
  );

  GeneratedColumn<double> get packageQuantity => $composableBuilder(
    column: $table.packageQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<double> get packageWeightKg => $composableBuilder(
    column: $table.packageWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalCostCents => $composableBuilder(
    column: $table.totalCostCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pricePerKgCents => $composableBuilder(
    column: $table.pricePerKgCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get supplier =>
      $composableBuilder(column: $table.supplier, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$IngredientLotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IngredientLotsTable,
          IngredientLot,
          $$IngredientLotsTableFilterComposer,
          $$IngredientLotsTableOrderingComposer,
          $$IngredientLotsTableAnnotationComposer,
          $$IngredientLotsTableCreateCompanionBuilder,
          $$IngredientLotsTableUpdateCompanionBuilder,
          (
            IngredientLot,
            BaseReferences<_$AppDatabase, $IngredientLotsTable, IngredientLot>,
          ),
          IngredientLot,
          PrefetchHooks Function()
        > {
  $$IngredientLotsTableTableManager(
    _$AppDatabase db,
    $IngredientLotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IngredientLotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IngredientLotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IngredientLotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ingredientId = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<DateTime> entryDate = const Value.absent(),
                Value<double> initialQuantityKg = const Value.absent(),
                Value<String> packageUnit = const Value.absent(),
                Value<double> packageQuantity = const Value.absent(),
                Value<double> packageWeightKg = const Value.absent(),
                Value<int> totalCostCents = const Value.absent(),
                Value<int> pricePerKgCents = const Value.absent(),
                Value<String?> supplier = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IngredientLotsCompanion(
                id: id,
                ingredientId: ingredientId,
                code: code,
                entryDate: entryDate,
                initialQuantityKg: initialQuantityKg,
                packageUnit: packageUnit,
                packageQuantity: packageQuantity,
                packageWeightKg: packageWeightKg,
                totalCostCents: totalCostCents,
                pricePerKgCents: pricePerKgCents,
                supplier: supplier,
                notes: notes,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ingredientId,
                required String code,
                required DateTime entryDate,
                required double initialQuantityKg,
                Value<String> packageUnit = const Value.absent(),
                Value<double> packageQuantity = const Value.absent(),
                Value<double> packageWeightKg = const Value.absent(),
                required int totalCostCents,
                required int pricePerKgCents,
                Value<String?> supplier = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required String createdBy,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => IngredientLotsCompanion.insert(
                id: id,
                ingredientId: ingredientId,
                code: code,
                entryDate: entryDate,
                initialQuantityKg: initialQuantityKg,
                packageUnit: packageUnit,
                packageQuantity: packageQuantity,
                packageWeightKg: packageWeightKg,
                totalCostCents: totalCostCents,
                pricePerKgCents: pricePerKgCents,
                supplier: supplier,
                notes: notes,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IngredientLotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IngredientLotsTable,
      IngredientLot,
      $$IngredientLotsTableFilterComposer,
      $$IngredientLotsTableOrderingComposer,
      $$IngredientLotsTableAnnotationComposer,
      $$IngredientLotsTableCreateCompanionBuilder,
      $$IngredientLotsTableUpdateCompanionBuilder,
      (
        IngredientLot,
        BaseReferences<_$AppDatabase, $IngredientLotsTable, IngredientLot>,
      ),
      IngredientLot,
      PrefetchHooks Function()
    >;
typedef $$IngredientStockMovementsTableCreateCompanionBuilder =
    IngredientStockMovementsCompanion Function({
      required String id,
      required String type,
      required DateTime occurredAt,
      required String ingredientId,
      required String ingredientLotId,
      required double quantityKg,
      required int pricePerKgCentsSnapshot,
      required int totalCostCents,
      Value<String?> referenceType,
      Value<String?> referenceId,
      Value<String?> notes,
      required String createdBy,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$IngredientStockMovementsTableUpdateCompanionBuilder =
    IngredientStockMovementsCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<DateTime> occurredAt,
      Value<String> ingredientId,
      Value<String> ingredientLotId,
      Value<double> quantityKg,
      Value<int> pricePerKgCentsSnapshot,
      Value<int> totalCostCents,
      Value<String?> referenceType,
      Value<String?> referenceId,
      Value<String?> notes,
      Value<String> createdBy,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$IngredientStockMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $IngredientStockMovementsTable> {
  $$IngredientStockMovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ingredientId => $composableBuilder(
    column: $table.ingredientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ingredientLotId => $composableBuilder(
    column: $table.ingredientLotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantityKg => $composableBuilder(
    column: $table.quantityKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pricePerKgCentsSnapshot => $composableBuilder(
    column: $table.pricePerKgCentsSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCostCents => $composableBuilder(
    column: $table.totalCostCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceType => $composableBuilder(
    column: $table.referenceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IngredientStockMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $IngredientStockMovementsTable> {
  $$IngredientStockMovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ingredientId => $composableBuilder(
    column: $table.ingredientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ingredientLotId => $composableBuilder(
    column: $table.ingredientLotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantityKg => $composableBuilder(
    column: $table.quantityKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pricePerKgCentsSnapshot => $composableBuilder(
    column: $table.pricePerKgCentsSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCostCents => $composableBuilder(
    column: $table.totalCostCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceType => $composableBuilder(
    column: $table.referenceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IngredientStockMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IngredientStockMovementsTable> {
  $$IngredientStockMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ingredientId => $composableBuilder(
    column: $table.ingredientId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ingredientLotId => $composableBuilder(
    column: $table.ingredientLotId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantityKg => $composableBuilder(
    column: $table.quantityKg,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pricePerKgCentsSnapshot => $composableBuilder(
    column: $table.pricePerKgCentsSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalCostCents => $composableBuilder(
    column: $table.totalCostCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get referenceType => $composableBuilder(
    column: $table.referenceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$IngredientStockMovementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IngredientStockMovementsTable,
          IngredientStockMovement,
          $$IngredientStockMovementsTableFilterComposer,
          $$IngredientStockMovementsTableOrderingComposer,
          $$IngredientStockMovementsTableAnnotationComposer,
          $$IngredientStockMovementsTableCreateCompanionBuilder,
          $$IngredientStockMovementsTableUpdateCompanionBuilder,
          (
            IngredientStockMovement,
            BaseReferences<
              _$AppDatabase,
              $IngredientStockMovementsTable,
              IngredientStockMovement
            >,
          ),
          IngredientStockMovement,
          PrefetchHooks Function()
        > {
  $$IngredientStockMovementsTableTableManager(
    _$AppDatabase db,
    $IngredientStockMovementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IngredientStockMovementsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$IngredientStockMovementsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$IngredientStockMovementsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String> ingredientId = const Value.absent(),
                Value<String> ingredientLotId = const Value.absent(),
                Value<double> quantityKg = const Value.absent(),
                Value<int> pricePerKgCentsSnapshot = const Value.absent(),
                Value<int> totalCostCents = const Value.absent(),
                Value<String?> referenceType = const Value.absent(),
                Value<String?> referenceId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IngredientStockMovementsCompanion(
                id: id,
                type: type,
                occurredAt: occurredAt,
                ingredientId: ingredientId,
                ingredientLotId: ingredientLotId,
                quantityKg: quantityKg,
                pricePerKgCentsSnapshot: pricePerKgCentsSnapshot,
                totalCostCents: totalCostCents,
                referenceType: referenceType,
                referenceId: referenceId,
                notes: notes,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                required DateTime occurredAt,
                required String ingredientId,
                required String ingredientLotId,
                required double quantityKg,
                required int pricePerKgCentsSnapshot,
                required int totalCostCents,
                Value<String?> referenceType = const Value.absent(),
                Value<String?> referenceId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required String createdBy,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => IngredientStockMovementsCompanion.insert(
                id: id,
                type: type,
                occurredAt: occurredAt,
                ingredientId: ingredientId,
                ingredientLotId: ingredientLotId,
                quantityKg: quantityKg,
                pricePerKgCentsSnapshot: pricePerKgCentsSnapshot,
                totalCostCents: totalCostCents,
                referenceType: referenceType,
                referenceId: referenceId,
                notes: notes,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IngredientStockMovementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IngredientStockMovementsTable,
      IngredientStockMovement,
      $$IngredientStockMovementsTableFilterComposer,
      $$IngredientStockMovementsTableOrderingComposer,
      $$IngredientStockMovementsTableAnnotationComposer,
      $$IngredientStockMovementsTableCreateCompanionBuilder,
      $$IngredientStockMovementsTableUpdateCompanionBuilder,
      (
        IngredientStockMovement,
        BaseReferences<
          _$AppDatabase,
          $IngredientStockMovementsTable,
          IngredientStockMovement
        >,
      ),
      IngredientStockMovement,
      PrefetchHooks Function()
    >;
typedef $$FeedFormulasTableCreateCompanionBuilder =
    FeedFormulasCompanion Function({
      required String id,
      required String name,
      required String phase,
      Value<int> version,
      Value<bool> isActive,
      required DateTime validFrom,
      Value<String?> notes,
      required String createdBy,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$FeedFormulasTableUpdateCompanionBuilder =
    FeedFormulasCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> phase,
      Value<int> version,
      Value<bool> isActive,
      Value<DateTime> validFrom,
      Value<String?> notes,
      Value<String> createdBy,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$FeedFormulasTableFilterComposer
    extends Composer<_$AppDatabase, $FeedFormulasTable> {
  $$FeedFormulasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get validFrom => $composableBuilder(
    column: $table.validFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FeedFormulasTableOrderingComposer
    extends Composer<_$AppDatabase, $FeedFormulasTable> {
  $$FeedFormulasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get validFrom => $composableBuilder(
    column: $table.validFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FeedFormulasTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeedFormulasTable> {
  $$FeedFormulasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phase =>
      $composableBuilder(column: $table.phase, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get validFrom =>
      $composableBuilder(column: $table.validFrom, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FeedFormulasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FeedFormulasTable,
          FeedFormula,
          $$FeedFormulasTableFilterComposer,
          $$FeedFormulasTableOrderingComposer,
          $$FeedFormulasTableAnnotationComposer,
          $$FeedFormulasTableCreateCompanionBuilder,
          $$FeedFormulasTableUpdateCompanionBuilder,
          (
            FeedFormula,
            BaseReferences<_$AppDatabase, $FeedFormulasTable, FeedFormula>,
          ),
          FeedFormula,
          PrefetchHooks Function()
        > {
  $$FeedFormulasTableTableManager(_$AppDatabase db, $FeedFormulasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeedFormulasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeedFormulasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeedFormulasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> phase = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> validFrom = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeedFormulasCompanion(
                id: id,
                name: name,
                phase: phase,
                version: version,
                isActive: isActive,
                validFrom: validFrom,
                notes: notes,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String phase,
                Value<int> version = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime validFrom,
                Value<String?> notes = const Value.absent(),
                required String createdBy,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => FeedFormulasCompanion.insert(
                id: id,
                name: name,
                phase: phase,
                version: version,
                isActive: isActive,
                validFrom: validFrom,
                notes: notes,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FeedFormulasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FeedFormulasTable,
      FeedFormula,
      $$FeedFormulasTableFilterComposer,
      $$FeedFormulasTableOrderingComposer,
      $$FeedFormulasTableAnnotationComposer,
      $$FeedFormulasTableCreateCompanionBuilder,
      $$FeedFormulasTableUpdateCompanionBuilder,
      (
        FeedFormula,
        BaseReferences<_$AppDatabase, $FeedFormulasTable, FeedFormula>,
      ),
      FeedFormula,
      PrefetchHooks Function()
    >;
typedef $$FeedFormulaItemsTableCreateCompanionBuilder =
    FeedFormulaItemsCompanion Function({
      required String id,
      required String formulaId,
      required String ingredientId,
      required double baseQuantityKg,
      Value<int> rowid,
    });
typedef $$FeedFormulaItemsTableUpdateCompanionBuilder =
    FeedFormulaItemsCompanion Function({
      Value<String> id,
      Value<String> formulaId,
      Value<String> ingredientId,
      Value<double> baseQuantityKg,
      Value<int> rowid,
    });

class $$FeedFormulaItemsTableFilterComposer
    extends Composer<_$AppDatabase, $FeedFormulaItemsTable> {
  $$FeedFormulaItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get formulaId => $composableBuilder(
    column: $table.formulaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ingredientId => $composableBuilder(
    column: $table.ingredientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get baseQuantityKg => $composableBuilder(
    column: $table.baseQuantityKg,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FeedFormulaItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $FeedFormulaItemsTable> {
  $$FeedFormulaItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get formulaId => $composableBuilder(
    column: $table.formulaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ingredientId => $composableBuilder(
    column: $table.ingredientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get baseQuantityKg => $composableBuilder(
    column: $table.baseQuantityKg,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FeedFormulaItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeedFormulaItemsTable> {
  $$FeedFormulaItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get formulaId =>
      $composableBuilder(column: $table.formulaId, builder: (column) => column);

  GeneratedColumn<String> get ingredientId => $composableBuilder(
    column: $table.ingredientId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get baseQuantityKg => $composableBuilder(
    column: $table.baseQuantityKg,
    builder: (column) => column,
  );
}

class $$FeedFormulaItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FeedFormulaItemsTable,
          FeedFormulaItem,
          $$FeedFormulaItemsTableFilterComposer,
          $$FeedFormulaItemsTableOrderingComposer,
          $$FeedFormulaItemsTableAnnotationComposer,
          $$FeedFormulaItemsTableCreateCompanionBuilder,
          $$FeedFormulaItemsTableUpdateCompanionBuilder,
          (
            FeedFormulaItem,
            BaseReferences<
              _$AppDatabase,
              $FeedFormulaItemsTable,
              FeedFormulaItem
            >,
          ),
          FeedFormulaItem,
          PrefetchHooks Function()
        > {
  $$FeedFormulaItemsTableTableManager(
    _$AppDatabase db,
    $FeedFormulaItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeedFormulaItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeedFormulaItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeedFormulaItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> formulaId = const Value.absent(),
                Value<String> ingredientId = const Value.absent(),
                Value<double> baseQuantityKg = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeedFormulaItemsCompanion(
                id: id,
                formulaId: formulaId,
                ingredientId: ingredientId,
                baseQuantityKg: baseQuantityKg,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String formulaId,
                required String ingredientId,
                required double baseQuantityKg,
                Value<int> rowid = const Value.absent(),
              }) => FeedFormulaItemsCompanion.insert(
                id: id,
                formulaId: formulaId,
                ingredientId: ingredientId,
                baseQuantityKg: baseQuantityKg,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FeedFormulaItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FeedFormulaItemsTable,
      FeedFormulaItem,
      $$FeedFormulaItemsTableFilterComposer,
      $$FeedFormulaItemsTableOrderingComposer,
      $$FeedFormulaItemsTableAnnotationComposer,
      $$FeedFormulaItemsTableCreateCompanionBuilder,
      $$FeedFormulaItemsTableUpdateCompanionBuilder,
      (
        FeedFormulaItem,
        BaseReferences<_$AppDatabase, $FeedFormulaItemsTable, FeedFormulaItem>,
      ),
      FeedFormulaItem,
      PrefetchHooks Function()
    >;
typedef $$FeedBatchesTableCreateCompanionBuilder =
    FeedBatchesCompanion Function({
      required String id,
      required String code,
      required String phase,
      required String formulaId,
      required DateTime producedAt,
      required double producedQuantityKg,
      required int totalCostCents,
      required double costPerKgCents,
      Value<String?> notes,
      required String createdBy,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$FeedBatchesTableUpdateCompanionBuilder =
    FeedBatchesCompanion Function({
      Value<String> id,
      Value<String> code,
      Value<String> phase,
      Value<String> formulaId,
      Value<DateTime> producedAt,
      Value<double> producedQuantityKg,
      Value<int> totalCostCents,
      Value<double> costPerKgCents,
      Value<String?> notes,
      Value<String> createdBy,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$FeedBatchesTableFilterComposer
    extends Composer<_$AppDatabase, $FeedBatchesTable> {
  $$FeedBatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get formulaId => $composableBuilder(
    column: $table.formulaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get producedAt => $composableBuilder(
    column: $table.producedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get producedQuantityKg => $composableBuilder(
    column: $table.producedQuantityKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCostCents => $composableBuilder(
    column: $table.totalCostCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costPerKgCents => $composableBuilder(
    column: $table.costPerKgCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FeedBatchesTableOrderingComposer
    extends Composer<_$AppDatabase, $FeedBatchesTable> {
  $$FeedBatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get formulaId => $composableBuilder(
    column: $table.formulaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get producedAt => $composableBuilder(
    column: $table.producedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get producedQuantityKg => $composableBuilder(
    column: $table.producedQuantityKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCostCents => $composableBuilder(
    column: $table.totalCostCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costPerKgCents => $composableBuilder(
    column: $table.costPerKgCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FeedBatchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeedBatchesTable> {
  $$FeedBatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get phase =>
      $composableBuilder(column: $table.phase, builder: (column) => column);

  GeneratedColumn<String> get formulaId =>
      $composableBuilder(column: $table.formulaId, builder: (column) => column);

  GeneratedColumn<DateTime> get producedAt => $composableBuilder(
    column: $table.producedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get producedQuantityKg => $composableBuilder(
    column: $table.producedQuantityKg,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalCostCents => $composableBuilder(
    column: $table.totalCostCents,
    builder: (column) => column,
  );

  GeneratedColumn<double> get costPerKgCents => $composableBuilder(
    column: $table.costPerKgCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FeedBatchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FeedBatchesTable,
          FeedBatche,
          $$FeedBatchesTableFilterComposer,
          $$FeedBatchesTableOrderingComposer,
          $$FeedBatchesTableAnnotationComposer,
          $$FeedBatchesTableCreateCompanionBuilder,
          $$FeedBatchesTableUpdateCompanionBuilder,
          (
            FeedBatche,
            BaseReferences<_$AppDatabase, $FeedBatchesTable, FeedBatche>,
          ),
          FeedBatche,
          PrefetchHooks Function()
        > {
  $$FeedBatchesTableTableManager(_$AppDatabase db, $FeedBatchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeedBatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeedBatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeedBatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> phase = const Value.absent(),
                Value<String> formulaId = const Value.absent(),
                Value<DateTime> producedAt = const Value.absent(),
                Value<double> producedQuantityKg = const Value.absent(),
                Value<int> totalCostCents = const Value.absent(),
                Value<double> costPerKgCents = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeedBatchesCompanion(
                id: id,
                code: code,
                phase: phase,
                formulaId: formulaId,
                producedAt: producedAt,
                producedQuantityKg: producedQuantityKg,
                totalCostCents: totalCostCents,
                costPerKgCents: costPerKgCents,
                notes: notes,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String code,
                required String phase,
                required String formulaId,
                required DateTime producedAt,
                required double producedQuantityKg,
                required int totalCostCents,
                required double costPerKgCents,
                Value<String?> notes = const Value.absent(),
                required String createdBy,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => FeedBatchesCompanion.insert(
                id: id,
                code: code,
                phase: phase,
                formulaId: formulaId,
                producedAt: producedAt,
                producedQuantityKg: producedQuantityKg,
                totalCostCents: totalCostCents,
                costPerKgCents: costPerKgCents,
                notes: notes,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FeedBatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FeedBatchesTable,
      FeedBatche,
      $$FeedBatchesTableFilterComposer,
      $$FeedBatchesTableOrderingComposer,
      $$FeedBatchesTableAnnotationComposer,
      $$FeedBatchesTableCreateCompanionBuilder,
      $$FeedBatchesTableUpdateCompanionBuilder,
      (
        FeedBatche,
        BaseReferences<_$AppDatabase, $FeedBatchesTable, FeedBatche>,
      ),
      FeedBatche,
      PrefetchHooks Function()
    >;
typedef $$FeedBatchItemsTableCreateCompanionBuilder =
    FeedBatchItemsCompanion Function({
      required String id,
      required String batchId,
      required String ingredientId,
      required double quantityKg,
      required int pricePerKgCentsSnapshot,
      required int itemCostCents,
      Value<int> rowid,
    });
typedef $$FeedBatchItemsTableUpdateCompanionBuilder =
    FeedBatchItemsCompanion Function({
      Value<String> id,
      Value<String> batchId,
      Value<String> ingredientId,
      Value<double> quantityKg,
      Value<int> pricePerKgCentsSnapshot,
      Value<int> itemCostCents,
      Value<int> rowid,
    });

class $$FeedBatchItemsTableFilterComposer
    extends Composer<_$AppDatabase, $FeedBatchItemsTable> {
  $$FeedBatchItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ingredientId => $composableBuilder(
    column: $table.ingredientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantityKg => $composableBuilder(
    column: $table.quantityKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pricePerKgCentsSnapshot => $composableBuilder(
    column: $table.pricePerKgCentsSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemCostCents => $composableBuilder(
    column: $table.itemCostCents,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FeedBatchItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $FeedBatchItemsTable> {
  $$FeedBatchItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ingredientId => $composableBuilder(
    column: $table.ingredientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantityKg => $composableBuilder(
    column: $table.quantityKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pricePerKgCentsSnapshot => $composableBuilder(
    column: $table.pricePerKgCentsSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemCostCents => $composableBuilder(
    column: $table.itemCostCents,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FeedBatchItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeedBatchItemsTable> {
  $$FeedBatchItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<String> get ingredientId => $composableBuilder(
    column: $table.ingredientId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantityKg => $composableBuilder(
    column: $table.quantityKg,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pricePerKgCentsSnapshot => $composableBuilder(
    column: $table.pricePerKgCentsSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get itemCostCents => $composableBuilder(
    column: $table.itemCostCents,
    builder: (column) => column,
  );
}

class $$FeedBatchItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FeedBatchItemsTable,
          FeedBatchItem,
          $$FeedBatchItemsTableFilterComposer,
          $$FeedBatchItemsTableOrderingComposer,
          $$FeedBatchItemsTableAnnotationComposer,
          $$FeedBatchItemsTableCreateCompanionBuilder,
          $$FeedBatchItemsTableUpdateCompanionBuilder,
          (
            FeedBatchItem,
            BaseReferences<_$AppDatabase, $FeedBatchItemsTable, FeedBatchItem>,
          ),
          FeedBatchItem,
          PrefetchHooks Function()
        > {
  $$FeedBatchItemsTableTableManager(
    _$AppDatabase db,
    $FeedBatchItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeedBatchItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeedBatchItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeedBatchItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> batchId = const Value.absent(),
                Value<String> ingredientId = const Value.absent(),
                Value<double> quantityKg = const Value.absent(),
                Value<int> pricePerKgCentsSnapshot = const Value.absent(),
                Value<int> itemCostCents = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeedBatchItemsCompanion(
                id: id,
                batchId: batchId,
                ingredientId: ingredientId,
                quantityKg: quantityKg,
                pricePerKgCentsSnapshot: pricePerKgCentsSnapshot,
                itemCostCents: itemCostCents,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String batchId,
                required String ingredientId,
                required double quantityKg,
                required int pricePerKgCentsSnapshot,
                required int itemCostCents,
                Value<int> rowid = const Value.absent(),
              }) => FeedBatchItemsCompanion.insert(
                id: id,
                batchId: batchId,
                ingredientId: ingredientId,
                quantityKg: quantityKg,
                pricePerKgCentsSnapshot: pricePerKgCentsSnapshot,
                itemCostCents: itemCostCents,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FeedBatchItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FeedBatchItemsTable,
      FeedBatchItem,
      $$FeedBatchItemsTableFilterComposer,
      $$FeedBatchItemsTableOrderingComposer,
      $$FeedBatchItemsTableAnnotationComposer,
      $$FeedBatchItemsTableCreateCompanionBuilder,
      $$FeedBatchItemsTableUpdateCompanionBuilder,
      (
        FeedBatchItem,
        BaseReferences<_$AppDatabase, $FeedBatchItemsTable, FeedBatchItem>,
      ),
      FeedBatchItem,
      PrefetchHooks Function()
    >;
typedef $$FeedStockMovementsTableCreateCompanionBuilder =
    FeedStockMovementsCompanion Function({
      required String id,
      required String type,
      required DateTime occurredAt,
      required String batchId,
      required double quantityKg,
      Value<String?> feedingId,
      Value<String?> notes,
      required String createdBy,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$FeedStockMovementsTableUpdateCompanionBuilder =
    FeedStockMovementsCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<DateTime> occurredAt,
      Value<String> batchId,
      Value<double> quantityKg,
      Value<String?> feedingId,
      Value<String?> notes,
      Value<String> createdBy,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$FeedStockMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $FeedStockMovementsTable> {
  $$FeedStockMovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantityKg => $composableBuilder(
    column: $table.quantityKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feedingId => $composableBuilder(
    column: $table.feedingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FeedStockMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $FeedStockMovementsTable> {
  $$FeedStockMovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantityKg => $composableBuilder(
    column: $table.quantityKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedingId => $composableBuilder(
    column: $table.feedingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FeedStockMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeedStockMovementsTable> {
  $$FeedStockMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<double> get quantityKg => $composableBuilder(
    column: $table.quantityKg,
    builder: (column) => column,
  );

  GeneratedColumn<String> get feedingId =>
      $composableBuilder(column: $table.feedingId, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FeedStockMovementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FeedStockMovementsTable,
          FeedStockMovement,
          $$FeedStockMovementsTableFilterComposer,
          $$FeedStockMovementsTableOrderingComposer,
          $$FeedStockMovementsTableAnnotationComposer,
          $$FeedStockMovementsTableCreateCompanionBuilder,
          $$FeedStockMovementsTableUpdateCompanionBuilder,
          (
            FeedStockMovement,
            BaseReferences<
              _$AppDatabase,
              $FeedStockMovementsTable,
              FeedStockMovement
            >,
          ),
          FeedStockMovement,
          PrefetchHooks Function()
        > {
  $$FeedStockMovementsTableTableManager(
    _$AppDatabase db,
    $FeedStockMovementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeedStockMovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeedStockMovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeedStockMovementsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String> batchId = const Value.absent(),
                Value<double> quantityKg = const Value.absent(),
                Value<String?> feedingId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeedStockMovementsCompanion(
                id: id,
                type: type,
                occurredAt: occurredAt,
                batchId: batchId,
                quantityKg: quantityKg,
                feedingId: feedingId,
                notes: notes,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                required DateTime occurredAt,
                required String batchId,
                required double quantityKg,
                Value<String?> feedingId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required String createdBy,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => FeedStockMovementsCompanion.insert(
                id: id,
                type: type,
                occurredAt: occurredAt,
                batchId: batchId,
                quantityKg: quantityKg,
                feedingId: feedingId,
                notes: notes,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FeedStockMovementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FeedStockMovementsTable,
      FeedStockMovement,
      $$FeedStockMovementsTableFilterComposer,
      $$FeedStockMovementsTableOrderingComposer,
      $$FeedStockMovementsTableAnnotationComposer,
      $$FeedStockMovementsTableCreateCompanionBuilder,
      $$FeedStockMovementsTableUpdateCompanionBuilder,
      (
        FeedStockMovement,
        BaseReferences<
          _$AppDatabase,
          $FeedStockMovementsTable,
          FeedStockMovement
        >,
      ),
      FeedStockMovement,
      PrefetchHooks Function()
    >;
typedef $$DailyFeedingsTableCreateCompanionBuilder =
    DailyFeedingsCompanion Function({
      required String id,
      required DateTime feedingDate,
      required String lotId,
      required String batchId,
      required double quantityKg,
      Value<String?> notes,
      required String createdBy,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$DailyFeedingsTableUpdateCompanionBuilder =
    DailyFeedingsCompanion Function({
      Value<String> id,
      Value<DateTime> feedingDate,
      Value<String> lotId,
      Value<String> batchId,
      Value<double> quantityKg,
      Value<String?> notes,
      Value<String> createdBy,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$DailyFeedingsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyFeedingsTable> {
  $$DailyFeedingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get feedingDate => $composableBuilder(
    column: $table.feedingDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lotId => $composableBuilder(
    column: $table.lotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantityKg => $composableBuilder(
    column: $table.quantityKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyFeedingsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyFeedingsTable> {
  $$DailyFeedingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get feedingDate => $composableBuilder(
    column: $table.feedingDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lotId => $composableBuilder(
    column: $table.lotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantityKg => $composableBuilder(
    column: $table.quantityKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyFeedingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyFeedingsTable> {
  $$DailyFeedingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get feedingDate => $composableBuilder(
    column: $table.feedingDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lotId =>
      $composableBuilder(column: $table.lotId, builder: (column) => column);

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<double> get quantityKg => $composableBuilder(
    column: $table.quantityKg,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DailyFeedingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyFeedingsTable,
          DailyFeeding,
          $$DailyFeedingsTableFilterComposer,
          $$DailyFeedingsTableOrderingComposer,
          $$DailyFeedingsTableAnnotationComposer,
          $$DailyFeedingsTableCreateCompanionBuilder,
          $$DailyFeedingsTableUpdateCompanionBuilder,
          (
            DailyFeeding,
            BaseReferences<_$AppDatabase, $DailyFeedingsTable, DailyFeeding>,
          ),
          DailyFeeding,
          PrefetchHooks Function()
        > {
  $$DailyFeedingsTableTableManager(_$AppDatabase db, $DailyFeedingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyFeedingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyFeedingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyFeedingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> feedingDate = const Value.absent(),
                Value<String> lotId = const Value.absent(),
                Value<String> batchId = const Value.absent(),
                Value<double> quantityKg = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyFeedingsCompanion(
                id: id,
                feedingDate: feedingDate,
                lotId: lotId,
                batchId: batchId,
                quantityKg: quantityKg,
                notes: notes,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime feedingDate,
                required String lotId,
                required String batchId,
                required double quantityKg,
                Value<String?> notes = const Value.absent(),
                required String createdBy,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => DailyFeedingsCompanion.insert(
                id: id,
                feedingDate: feedingDate,
                lotId: lotId,
                batchId: batchId,
                quantityKg: quantityKg,
                notes: notes,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyFeedingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyFeedingsTable,
      DailyFeeding,
      $$DailyFeedingsTableFilterComposer,
      $$DailyFeedingsTableOrderingComposer,
      $$DailyFeedingsTableAnnotationComposer,
      $$DailyFeedingsTableCreateCompanionBuilder,
      $$DailyFeedingsTableUpdateCompanionBuilder,
      (
        DailyFeeding,
        BaseReferences<_$AppDatabase, $DailyFeedingsTable, DailyFeeding>,
      ),
      DailyFeeding,
      PrefetchHooks Function()
    >;
typedef $$CustomersTableCreateCompanionBuilder =
    CustomersCompanion Function({
      required String id,
      required String name,
      Value<String?> phone,
      Value<String?> address,
      Value<String?> notes,
      Value<bool> isActive,
      required DateTime createdAt,
      required String createdBy,
      Value<int> rowid,
    });
typedef $$CustomersTableUpdateCompanionBuilder =
    CustomersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> phone,
      Value<String?> address,
      Value<String?> notes,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<String> createdBy,
      Value<int> rowid,
    });

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);
}

class $$CustomersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomersTable,
          Customer,
          $$CustomersTableFilterComposer,
          $$CustomersTableOrderingComposer,
          $$CustomersTableAnnotationComposer,
          $$CustomersTableCreateCompanionBuilder,
          $$CustomersTableUpdateCompanionBuilder,
          (Customer, BaseReferences<_$AppDatabase, $CustomersTable, Customer>),
          Customer,
          PrefetchHooks Function()
        > {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion(
                id: id,
                name: name,
                phone: phone,
                address: address,
                notes: notes,
                isActive: isActive,
                createdAt: createdAt,
                createdBy: createdBy,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> phone = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
                required String createdBy,
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion.insert(
                id: id,
                name: name,
                phone: phone,
                address: address,
                notes: notes,
                isActive: isActive,
                createdAt: createdAt,
                createdBy: createdBy,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomersTable,
      Customer,
      $$CustomersTableFilterComposer,
      $$CustomersTableOrderingComposer,
      $$CustomersTableAnnotationComposer,
      $$CustomersTableCreateCompanionBuilder,
      $$CustomersTableUpdateCompanionBuilder,
      (Customer, BaseReferences<_$AppDatabase, $CustomersTable, Customer>),
      Customer,
      PrefetchHooks Function()
    >;
typedef $$OrdersTableCreateCompanionBuilder =
    OrdersCompanion Function({
      required String id,
      required int orderNumber,
      Value<String?> customerId,
      required DateTime requestedDate,
      Value<DateTime?> expectedDeliveryDate,
      Value<String> status,
      required int subtotalCents,
      Value<int> discountCents,
      required int totalCents,
      Value<String?> notes,
      required String createdBy,
      required String updatedBy,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$OrdersTableUpdateCompanionBuilder =
    OrdersCompanion Function({
      Value<String> id,
      Value<int> orderNumber,
      Value<String?> customerId,
      Value<DateTime> requestedDate,
      Value<DateTime?> expectedDeliveryDate,
      Value<String> status,
      Value<int> subtotalCents,
      Value<int> discountCents,
      Value<int> totalCents,
      Value<String?> notes,
      Value<String> createdBy,
      Value<String> updatedBy,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$OrdersTableFilterComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderNumber => $composableBuilder(
    column: $table.orderNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get requestedDate => $composableBuilder(
    column: $table.requestedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expectedDeliveryDate => $composableBuilder(
    column: $table.expectedDeliveryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get subtotalCents => $composableBuilder(
    column: $table.subtotalCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discountCents => $composableBuilder(
    column: $table.discountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderNumber => $composableBuilder(
    column: $table.orderNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get requestedDate => $composableBuilder(
    column: $table.requestedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expectedDeliveryDate => $composableBuilder(
    column: $table.expectedDeliveryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get subtotalCents => $composableBuilder(
    column: $table.subtotalCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discountCents => $composableBuilder(
    column: $table.discountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get orderNumber => $composableBuilder(
    column: $table.orderNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get requestedDate => $composableBuilder(
    column: $table.requestedDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expectedDeliveryDate => $composableBuilder(
    column: $table.expectedDeliveryDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get subtotalCents => $composableBuilder(
    column: $table.subtotalCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get discountCents => $composableBuilder(
    column: $table.discountCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$OrdersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OrdersTable,
          Order,
          $$OrdersTableFilterComposer,
          $$OrdersTableOrderingComposer,
          $$OrdersTableAnnotationComposer,
          $$OrdersTableCreateCompanionBuilder,
          $$OrdersTableUpdateCompanionBuilder,
          (Order, BaseReferences<_$AppDatabase, $OrdersTable, Order>),
          Order,
          PrefetchHooks Function()
        > {
  $$OrdersTableTableManager(_$AppDatabase db, $OrdersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> orderNumber = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<DateTime> requestedDate = const Value.absent(),
                Value<DateTime?> expectedDeliveryDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> subtotalCents = const Value.absent(),
                Value<int> discountCents = const Value.absent(),
                Value<int> totalCents = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<String> updatedBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrdersCompanion(
                id: id,
                orderNumber: orderNumber,
                customerId: customerId,
                requestedDate: requestedDate,
                expectedDeliveryDate: expectedDeliveryDate,
                status: status,
                subtotalCents: subtotalCents,
                discountCents: discountCents,
                totalCents: totalCents,
                notes: notes,
                createdBy: createdBy,
                updatedBy: updatedBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int orderNumber,
                Value<String?> customerId = const Value.absent(),
                required DateTime requestedDate,
                Value<DateTime?> expectedDeliveryDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                required int subtotalCents,
                Value<int> discountCents = const Value.absent(),
                required int totalCents,
                Value<String?> notes = const Value.absent(),
                required String createdBy,
                required String updatedBy,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => OrdersCompanion.insert(
                id: id,
                orderNumber: orderNumber,
                customerId: customerId,
                requestedDate: requestedDate,
                expectedDeliveryDate: expectedDeliveryDate,
                status: status,
                subtotalCents: subtotalCents,
                discountCents: discountCents,
                totalCents: totalCents,
                notes: notes,
                createdBy: createdBy,
                updatedBy: updatedBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OrdersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OrdersTable,
      Order,
      $$OrdersTableFilterComposer,
      $$OrdersTableOrderingComposer,
      $$OrdersTableAnnotationComposer,
      $$OrdersTableCreateCompanionBuilder,
      $$OrdersTableUpdateCompanionBuilder,
      (Order, BaseReferences<_$AppDatabase, $OrdersTable, Order>),
      Order,
      PrefetchHooks Function()
    >;
typedef $$OrderItemsTableCreateCompanionBuilder =
    OrderItemsCompanion Function({
      required String id,
      required String orderId,
      required String productType,
      required double quantity,
      required int unitPriceCents,
      required int totalCents,
      Value<int> rowid,
    });
typedef $$OrderItemsTableUpdateCompanionBuilder =
    OrderItemsCompanion Function({
      Value<String> id,
      Value<String> orderId,
      Value<String> productType,
      Value<double> quantity,
      Value<int> unitPriceCents,
      Value<int> totalCents,
      Value<int> rowid,
    });

class $$OrderItemsTableFilterComposer
    extends Composer<_$AppDatabase, $OrderItemsTable> {
  $$OrderItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderId => $composableBuilder(
    column: $table.orderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productType => $composableBuilder(
    column: $table.productType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitPriceCents => $composableBuilder(
    column: $table.unitPriceCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OrderItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $OrderItemsTable> {
  $$OrderItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderId => $composableBuilder(
    column: $table.orderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productType => $composableBuilder(
    column: $table.productType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitPriceCents => $composableBuilder(
    column: $table.unitPriceCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OrderItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrderItemsTable> {
  $$OrderItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get orderId =>
      $composableBuilder(column: $table.orderId, builder: (column) => column);

  GeneratedColumn<String> get productType => $composableBuilder(
    column: $table.productType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get unitPriceCents => $composableBuilder(
    column: $table.unitPriceCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => column,
  );
}

class $$OrderItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OrderItemsTable,
          OrderItem,
          $$OrderItemsTableFilterComposer,
          $$OrderItemsTableOrderingComposer,
          $$OrderItemsTableAnnotationComposer,
          $$OrderItemsTableCreateCompanionBuilder,
          $$OrderItemsTableUpdateCompanionBuilder,
          (
            OrderItem,
            BaseReferences<_$AppDatabase, $OrderItemsTable, OrderItem>,
          ),
          OrderItem,
          PrefetchHooks Function()
        > {
  $$OrderItemsTableTableManager(_$AppDatabase db, $OrderItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrderItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrderItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrderItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> orderId = const Value.absent(),
                Value<String> productType = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<int> unitPriceCents = const Value.absent(),
                Value<int> totalCents = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrderItemsCompanion(
                id: id,
                orderId: orderId,
                productType: productType,
                quantity: quantity,
                unitPriceCents: unitPriceCents,
                totalCents: totalCents,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String orderId,
                required String productType,
                required double quantity,
                required int unitPriceCents,
                required int totalCents,
                Value<int> rowid = const Value.absent(),
              }) => OrderItemsCompanion.insert(
                id: id,
                orderId: orderId,
                productType: productType,
                quantity: quantity,
                unitPriceCents: unitPriceCents,
                totalCents: totalCents,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OrderItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OrderItemsTable,
      OrderItem,
      $$OrderItemsTableFilterComposer,
      $$OrderItemsTableOrderingComposer,
      $$OrderItemsTableAnnotationComposer,
      $$OrderItemsTableCreateCompanionBuilder,
      $$OrderItemsTableUpdateCompanionBuilder,
      (OrderItem, BaseReferences<_$AppDatabase, $OrderItemsTable, OrderItem>),
      OrderItem,
      PrefetchHooks Function()
    >;
typedef $$OrderStatusHistoryTableCreateCompanionBuilder =
    OrderStatusHistoryCompanion Function({
      required String id,
      required String orderId,
      Value<String?> oldStatus,
      required String newStatus,
      required DateTime changedAt,
      required String changedBy,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$OrderStatusHistoryTableUpdateCompanionBuilder =
    OrderStatusHistoryCompanion Function({
      Value<String> id,
      Value<String> orderId,
      Value<String?> oldStatus,
      Value<String> newStatus,
      Value<DateTime> changedAt,
      Value<String> changedBy,
      Value<String?> notes,
      Value<int> rowid,
    });

class $$OrderStatusHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $OrderStatusHistoryTable> {
  $$OrderStatusHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderId => $composableBuilder(
    column: $table.orderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oldStatus => $composableBuilder(
    column: $table.oldStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get newStatus => $composableBuilder(
    column: $table.newStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get changedAt => $composableBuilder(
    column: $table.changedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get changedBy => $composableBuilder(
    column: $table.changedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OrderStatusHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $OrderStatusHistoryTable> {
  $$OrderStatusHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderId => $composableBuilder(
    column: $table.orderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oldStatus => $composableBuilder(
    column: $table.oldStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get newStatus => $composableBuilder(
    column: $table.newStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get changedAt => $composableBuilder(
    column: $table.changedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get changedBy => $composableBuilder(
    column: $table.changedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OrderStatusHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrderStatusHistoryTable> {
  $$OrderStatusHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get orderId =>
      $composableBuilder(column: $table.orderId, builder: (column) => column);

  GeneratedColumn<String> get oldStatus =>
      $composableBuilder(column: $table.oldStatus, builder: (column) => column);

  GeneratedColumn<String> get newStatus =>
      $composableBuilder(column: $table.newStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get changedAt =>
      $composableBuilder(column: $table.changedAt, builder: (column) => column);

  GeneratedColumn<String> get changedBy =>
      $composableBuilder(column: $table.changedBy, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$OrderStatusHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OrderStatusHistoryTable,
          OrderStatusHistoryData,
          $$OrderStatusHistoryTableFilterComposer,
          $$OrderStatusHistoryTableOrderingComposer,
          $$OrderStatusHistoryTableAnnotationComposer,
          $$OrderStatusHistoryTableCreateCompanionBuilder,
          $$OrderStatusHistoryTableUpdateCompanionBuilder,
          (
            OrderStatusHistoryData,
            BaseReferences<
              _$AppDatabase,
              $OrderStatusHistoryTable,
              OrderStatusHistoryData
            >,
          ),
          OrderStatusHistoryData,
          PrefetchHooks Function()
        > {
  $$OrderStatusHistoryTableTableManager(
    _$AppDatabase db,
    $OrderStatusHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrderStatusHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrderStatusHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrderStatusHistoryTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> orderId = const Value.absent(),
                Value<String?> oldStatus = const Value.absent(),
                Value<String> newStatus = const Value.absent(),
                Value<DateTime> changedAt = const Value.absent(),
                Value<String> changedBy = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrderStatusHistoryCompanion(
                id: id,
                orderId: orderId,
                oldStatus: oldStatus,
                newStatus: newStatus,
                changedAt: changedAt,
                changedBy: changedBy,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String orderId,
                Value<String?> oldStatus = const Value.absent(),
                required String newStatus,
                required DateTime changedAt,
                required String changedBy,
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrderStatusHistoryCompanion.insert(
                id: id,
                orderId: orderId,
                oldStatus: oldStatus,
                newStatus: newStatus,
                changedAt: changedAt,
                changedBy: changedBy,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OrderStatusHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OrderStatusHistoryTable,
      OrderStatusHistoryData,
      $$OrderStatusHistoryTableFilterComposer,
      $$OrderStatusHistoryTableOrderingComposer,
      $$OrderStatusHistoryTableAnnotationComposer,
      $$OrderStatusHistoryTableCreateCompanionBuilder,
      $$OrderStatusHistoryTableUpdateCompanionBuilder,
      (
        OrderStatusHistoryData,
        BaseReferences<
          _$AppDatabase,
          $OrderStatusHistoryTable,
          OrderStatusHistoryData
        >,
      ),
      OrderStatusHistoryData,
      PrefetchHooks Function()
    >;
typedef $$SalesTableCreateCompanionBuilder =
    SalesCompanion Function({
      required String id,
      required DateTime soldAt,
      Value<String?> customerId,
      Value<String?> orderId,
      Value<int> dozens,
      Value<int> looseEggs,
      required int dozenPriceCents,
      required int totalCents,
      required String paymentMethod,
      Value<String> status,
      Value<String?> notes,
      required String createdBy,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$SalesTableUpdateCompanionBuilder =
    SalesCompanion Function({
      Value<String> id,
      Value<DateTime> soldAt,
      Value<String?> customerId,
      Value<String?> orderId,
      Value<int> dozens,
      Value<int> looseEggs,
      Value<int> dozenPriceCents,
      Value<int> totalCents,
      Value<String> paymentMethod,
      Value<String> status,
      Value<String?> notes,
      Value<String> createdBy,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$SalesTableFilterComposer extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get soldAt => $composableBuilder(
    column: $table.soldAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderId => $composableBuilder(
    column: $table.orderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dozens => $composableBuilder(
    column: $table.dozens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get looseEggs => $composableBuilder(
    column: $table.looseEggs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dozenPriceCents => $composableBuilder(
    column: $table.dozenPriceCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SalesTableOrderingComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get soldAt => $composableBuilder(
    column: $table.soldAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderId => $composableBuilder(
    column: $table.orderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dozens => $composableBuilder(
    column: $table.dozens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get looseEggs => $composableBuilder(
    column: $table.looseEggs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dozenPriceCents => $composableBuilder(
    column: $table.dozenPriceCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get soldAt =>
      $composableBuilder(column: $table.soldAt, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get orderId =>
      $composableBuilder(column: $table.orderId, builder: (column) => column);

  GeneratedColumn<int> get dozens =>
      $composableBuilder(column: $table.dozens, builder: (column) => column);

  GeneratedColumn<int> get looseEggs =>
      $composableBuilder(column: $table.looseEggs, builder: (column) => column);

  GeneratedColumn<int> get dozenPriceCents => $composableBuilder(
    column: $table.dozenPriceCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SalesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SalesTable,
          Sale,
          $$SalesTableFilterComposer,
          $$SalesTableOrderingComposer,
          $$SalesTableAnnotationComposer,
          $$SalesTableCreateCompanionBuilder,
          $$SalesTableUpdateCompanionBuilder,
          (Sale, BaseReferences<_$AppDatabase, $SalesTable, Sale>),
          Sale,
          PrefetchHooks Function()
        > {
  $$SalesTableTableManager(_$AppDatabase db, $SalesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> soldAt = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<String?> orderId = const Value.absent(),
                Value<int> dozens = const Value.absent(),
                Value<int> looseEggs = const Value.absent(),
                Value<int> dozenPriceCents = const Value.absent(),
                Value<int> totalCents = const Value.absent(),
                Value<String> paymentMethod = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalesCompanion(
                id: id,
                soldAt: soldAt,
                customerId: customerId,
                orderId: orderId,
                dozens: dozens,
                looseEggs: looseEggs,
                dozenPriceCents: dozenPriceCents,
                totalCents: totalCents,
                paymentMethod: paymentMethod,
                status: status,
                notes: notes,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime soldAt,
                Value<String?> customerId = const Value.absent(),
                Value<String?> orderId = const Value.absent(),
                Value<int> dozens = const Value.absent(),
                Value<int> looseEggs = const Value.absent(),
                required int dozenPriceCents,
                required int totalCents,
                required String paymentMethod,
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required String createdBy,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SalesCompanion.insert(
                id: id,
                soldAt: soldAt,
                customerId: customerId,
                orderId: orderId,
                dozens: dozens,
                looseEggs: looseEggs,
                dozenPriceCents: dozenPriceCents,
                totalCents: totalCents,
                paymentMethod: paymentMethod,
                status: status,
                notes: notes,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SalesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SalesTable,
      Sale,
      $$SalesTableFilterComposer,
      $$SalesTableOrderingComposer,
      $$SalesTableAnnotationComposer,
      $$SalesTableCreateCompanionBuilder,
      $$SalesTableUpdateCompanionBuilder,
      (Sale, BaseReferences<_$AppDatabase, $SalesTable, Sale>),
      Sale,
      PrefetchHooks Function()
    >;
typedef $$FinanceTransactionsTableCreateCompanionBuilder =
    FinanceTransactionsCompanion Function({
      required String id,
      required DateTime occurredAt,
      required String type,
      required String category,
      required String description,
      required int amountCents,
      Value<String?> referenceType,
      Value<String?> referenceId,
      Value<String?> paymentMethod,
      Value<String> status,
      Value<String?> notes,
      required String createdBy,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$FinanceTransactionsTableUpdateCompanionBuilder =
    FinanceTransactionsCompanion Function({
      Value<String> id,
      Value<DateTime> occurredAt,
      Value<String> type,
      Value<String> category,
      Value<String> description,
      Value<int> amountCents,
      Value<String?> referenceType,
      Value<String?> referenceId,
      Value<String?> paymentMethod,
      Value<String> status,
      Value<String?> notes,
      Value<String> createdBy,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$FinanceTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $FinanceTransactionsTable> {
  $$FinanceTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceType => $composableBuilder(
    column: $table.referenceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FinanceTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $FinanceTransactionsTable> {
  $$FinanceTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceType => $composableBuilder(
    column: $table.referenceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FinanceTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FinanceTransactionsTable> {
  $$FinanceTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get referenceType => $composableBuilder(
    column: $table.referenceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FinanceTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FinanceTransactionsTable,
          FinanceTransaction,
          $$FinanceTransactionsTableFilterComposer,
          $$FinanceTransactionsTableOrderingComposer,
          $$FinanceTransactionsTableAnnotationComposer,
          $$FinanceTransactionsTableCreateCompanionBuilder,
          $$FinanceTransactionsTableUpdateCompanionBuilder,
          (
            FinanceTransaction,
            BaseReferences<
              _$AppDatabase,
              $FinanceTransactionsTable,
              FinanceTransaction
            >,
          ),
          FinanceTransaction,
          PrefetchHooks Function()
        > {
  $$FinanceTransactionsTableTableManager(
    _$AppDatabase db,
    $FinanceTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FinanceTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FinanceTransactionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$FinanceTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<String?> referenceType = const Value.absent(),
                Value<String?> referenceId = const Value.absent(),
                Value<String?> paymentMethod = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FinanceTransactionsCompanion(
                id: id,
                occurredAt: occurredAt,
                type: type,
                category: category,
                description: description,
                amountCents: amountCents,
                referenceType: referenceType,
                referenceId: referenceId,
                paymentMethod: paymentMethod,
                status: status,
                notes: notes,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime occurredAt,
                required String type,
                required String category,
                required String description,
                required int amountCents,
                Value<String?> referenceType = const Value.absent(),
                Value<String?> referenceId = const Value.absent(),
                Value<String?> paymentMethod = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required String createdBy,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => FinanceTransactionsCompanion.insert(
                id: id,
                occurredAt: occurredAt,
                type: type,
                category: category,
                description: description,
                amountCents: amountCents,
                referenceType: referenceType,
                referenceId: referenceId,
                paymentMethod: paymentMethod,
                status: status,
                notes: notes,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FinanceTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FinanceTransactionsTable,
      FinanceTransaction,
      $$FinanceTransactionsTableFilterComposer,
      $$FinanceTransactionsTableOrderingComposer,
      $$FinanceTransactionsTableAnnotationComposer,
      $$FinanceTransactionsTableCreateCompanionBuilder,
      $$FinanceTransactionsTableUpdateCompanionBuilder,
      (
        FinanceTransaction,
        BaseReferences<
          _$AppDatabase,
          $FinanceTransactionsTable,
          FinanceTransaction
        >,
      ),
      FinanceTransaction,
      PrefetchHooks Function()
    >;
typedef $$InvestmentsTableCreateCompanionBuilder =
    InvestmentsCompanion Function({
      required String id,
      required String description,
      required String category,
      required DateTime investmentDate,
      required int amountCents,
      Value<String?> lotId,
      required String createdBy,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$InvestmentsTableUpdateCompanionBuilder =
    InvestmentsCompanion Function({
      Value<String> id,
      Value<String> description,
      Value<String> category,
      Value<DateTime> investmentDate,
      Value<int> amountCents,
      Value<String?> lotId,
      Value<String> createdBy,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$InvestmentsTableFilterComposer
    extends Composer<_$AppDatabase, $InvestmentsTable> {
  $$InvestmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get investmentDate => $composableBuilder(
    column: $table.investmentDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lotId => $composableBuilder(
    column: $table.lotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InvestmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $InvestmentsTable> {
  $$InvestmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get investmentDate => $composableBuilder(
    column: $table.investmentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lotId => $composableBuilder(
    column: $table.lotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InvestmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvestmentsTable> {
  $$InvestmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<DateTime> get investmentDate => $composableBuilder(
    column: $table.investmentDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lotId =>
      $composableBuilder(column: $table.lotId, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$InvestmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvestmentsTable,
          Investment,
          $$InvestmentsTableFilterComposer,
          $$InvestmentsTableOrderingComposer,
          $$InvestmentsTableAnnotationComposer,
          $$InvestmentsTableCreateCompanionBuilder,
          $$InvestmentsTableUpdateCompanionBuilder,
          (
            Investment,
            BaseReferences<_$AppDatabase, $InvestmentsTable, Investment>,
          ),
          Investment,
          PrefetchHooks Function()
        > {
  $$InvestmentsTableTableManager(_$AppDatabase db, $InvestmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvestmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvestmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvestmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<DateTime> investmentDate = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<String?> lotId = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvestmentsCompanion(
                id: id,
                description: description,
                category: category,
                investmentDate: investmentDate,
                amountCents: amountCents,
                lotId: lotId,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String description,
                required String category,
                required DateTime investmentDate,
                required int amountCents,
                Value<String?> lotId = const Value.absent(),
                required String createdBy,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => InvestmentsCompanion.insert(
                id: id,
                description: description,
                category: category,
                investmentDate: investmentDate,
                amountCents: amountCents,
                lotId: lotId,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InvestmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvestmentsTable,
      Investment,
      $$InvestmentsTableFilterComposer,
      $$InvestmentsTableOrderingComposer,
      $$InvestmentsTableAnnotationComposer,
      $$InvestmentsTableCreateCompanionBuilder,
      $$InvestmentsTableUpdateCompanionBuilder,
      (
        Investment,
        BaseReferences<_$AppDatabase, $InvestmentsTable, Investment>,
      ),
      Investment,
      PrefetchHooks Function()
    >;
typedef $$LightingProgramsTableCreateCompanionBuilder =
    LightingProgramsCompanion Function({
      required String id,
      required String name,
      Value<String?> description,
      Value<bool> isDefault,
      Value<bool> isActive,
      required String createdBy,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$LightingProgramsTableUpdateCompanionBuilder =
    LightingProgramsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> description,
      Value<bool> isDefault,
      Value<bool> isActive,
      Value<String> createdBy,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$LightingProgramsTableFilterComposer
    extends Composer<_$AppDatabase, $LightingProgramsTable> {
  $$LightingProgramsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LightingProgramsTableOrderingComposer
    extends Composer<_$AppDatabase, $LightingProgramsTable> {
  $$LightingProgramsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LightingProgramsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LightingProgramsTable> {
  $$LightingProgramsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LightingProgramsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LightingProgramsTable,
          LightingProgram,
          $$LightingProgramsTableFilterComposer,
          $$LightingProgramsTableOrderingComposer,
          $$LightingProgramsTableAnnotationComposer,
          $$LightingProgramsTableCreateCompanionBuilder,
          $$LightingProgramsTableUpdateCompanionBuilder,
          (
            LightingProgram,
            BaseReferences<
              _$AppDatabase,
              $LightingProgramsTable,
              LightingProgram
            >,
          ),
          LightingProgram,
          PrefetchHooks Function()
        > {
  $$LightingProgramsTableTableManager(
    _$AppDatabase db,
    $LightingProgramsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LightingProgramsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LightingProgramsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LightingProgramsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LightingProgramsCompanion(
                id: id,
                name: name,
                description: description,
                isDefault: isDefault,
                isActive: isActive,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required String createdBy,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => LightingProgramsCompanion.insert(
                id: id,
                name: name,
                description: description,
                isDefault: isDefault,
                isActive: isActive,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LightingProgramsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LightingProgramsTable,
      LightingProgram,
      $$LightingProgramsTableFilterComposer,
      $$LightingProgramsTableOrderingComposer,
      $$LightingProgramsTableAnnotationComposer,
      $$LightingProgramsTableCreateCompanionBuilder,
      $$LightingProgramsTableUpdateCompanionBuilder,
      (
        LightingProgram,
        BaseReferences<_$AppDatabase, $LightingProgramsTable, LightingProgram>,
      ),
      LightingProgram,
      PrefetchHooks Function()
    >;
typedef $$LightingProgramStepsTableCreateCompanionBuilder =
    LightingProgramStepsCompanion Function({
      required String id,
      required String programId,
      required int startAgeDays,
      Value<int?> endAgeDays,
      required int totalLightMinutes,
      Value<String?> startTime,
      Value<String?> endTime,
      Value<int> weeklyIncrementMinutes,
      Value<String?> relatedPhase,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$LightingProgramStepsTableUpdateCompanionBuilder =
    LightingProgramStepsCompanion Function({
      Value<String> id,
      Value<String> programId,
      Value<int> startAgeDays,
      Value<int?> endAgeDays,
      Value<int> totalLightMinutes,
      Value<String?> startTime,
      Value<String?> endTime,
      Value<int> weeklyIncrementMinutes,
      Value<String?> relatedPhase,
      Value<String?> notes,
      Value<int> rowid,
    });

class $$LightingProgramStepsTableFilterComposer
    extends Composer<_$AppDatabase, $LightingProgramStepsTable> {
  $$LightingProgramStepsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get programId => $composableBuilder(
    column: $table.programId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startAgeDays => $composableBuilder(
    column: $table.startAgeDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endAgeDays => $composableBuilder(
    column: $table.endAgeDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalLightMinutes => $composableBuilder(
    column: $table.totalLightMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weeklyIncrementMinutes => $composableBuilder(
    column: $table.weeklyIncrementMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relatedPhase => $composableBuilder(
    column: $table.relatedPhase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LightingProgramStepsTableOrderingComposer
    extends Composer<_$AppDatabase, $LightingProgramStepsTable> {
  $$LightingProgramStepsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get programId => $composableBuilder(
    column: $table.programId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startAgeDays => $composableBuilder(
    column: $table.startAgeDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endAgeDays => $composableBuilder(
    column: $table.endAgeDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalLightMinutes => $composableBuilder(
    column: $table.totalLightMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weeklyIncrementMinutes => $composableBuilder(
    column: $table.weeklyIncrementMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relatedPhase => $composableBuilder(
    column: $table.relatedPhase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LightingProgramStepsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LightingProgramStepsTable> {
  $$LightingProgramStepsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get programId =>
      $composableBuilder(column: $table.programId, builder: (column) => column);

  GeneratedColumn<int> get startAgeDays => $composableBuilder(
    column: $table.startAgeDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endAgeDays => $composableBuilder(
    column: $table.endAgeDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalLightMinutes => $composableBuilder(
    column: $table.totalLightMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<int> get weeklyIncrementMinutes => $composableBuilder(
    column: $table.weeklyIncrementMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get relatedPhase => $composableBuilder(
    column: $table.relatedPhase,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$LightingProgramStepsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LightingProgramStepsTable,
          LightingProgramStep,
          $$LightingProgramStepsTableFilterComposer,
          $$LightingProgramStepsTableOrderingComposer,
          $$LightingProgramStepsTableAnnotationComposer,
          $$LightingProgramStepsTableCreateCompanionBuilder,
          $$LightingProgramStepsTableUpdateCompanionBuilder,
          (
            LightingProgramStep,
            BaseReferences<
              _$AppDatabase,
              $LightingProgramStepsTable,
              LightingProgramStep
            >,
          ),
          LightingProgramStep,
          PrefetchHooks Function()
        > {
  $$LightingProgramStepsTableTableManager(
    _$AppDatabase db,
    $LightingProgramStepsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LightingProgramStepsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LightingProgramStepsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LightingProgramStepsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> programId = const Value.absent(),
                Value<int> startAgeDays = const Value.absent(),
                Value<int?> endAgeDays = const Value.absent(),
                Value<int> totalLightMinutes = const Value.absent(),
                Value<String?> startTime = const Value.absent(),
                Value<String?> endTime = const Value.absent(),
                Value<int> weeklyIncrementMinutes = const Value.absent(),
                Value<String?> relatedPhase = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LightingProgramStepsCompanion(
                id: id,
                programId: programId,
                startAgeDays: startAgeDays,
                endAgeDays: endAgeDays,
                totalLightMinutes: totalLightMinutes,
                startTime: startTime,
                endTime: endTime,
                weeklyIncrementMinutes: weeklyIncrementMinutes,
                relatedPhase: relatedPhase,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String programId,
                required int startAgeDays,
                Value<int?> endAgeDays = const Value.absent(),
                required int totalLightMinutes,
                Value<String?> startTime = const Value.absent(),
                Value<String?> endTime = const Value.absent(),
                Value<int> weeklyIncrementMinutes = const Value.absent(),
                Value<String?> relatedPhase = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LightingProgramStepsCompanion.insert(
                id: id,
                programId: programId,
                startAgeDays: startAgeDays,
                endAgeDays: endAgeDays,
                totalLightMinutes: totalLightMinutes,
                startTime: startTime,
                endTime: endTime,
                weeklyIncrementMinutes: weeklyIncrementMinutes,
                relatedPhase: relatedPhase,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LightingProgramStepsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LightingProgramStepsTable,
      LightingProgramStep,
      $$LightingProgramStepsTableFilterComposer,
      $$LightingProgramStepsTableOrderingComposer,
      $$LightingProgramStepsTableAnnotationComposer,
      $$LightingProgramStepsTableCreateCompanionBuilder,
      $$LightingProgramStepsTableUpdateCompanionBuilder,
      (
        LightingProgramStep,
        BaseReferences<
          _$AppDatabase,
          $LightingProgramStepsTable,
          LightingProgramStep
        >,
      ),
      LightingProgramStep,
      PrefetchHooks Function()
    >;
typedef $$LotLightingProgramsTableCreateCompanionBuilder =
    LotLightingProgramsCompanion Function({
      required String id,
      required String lotId,
      required String programId,
      required DateTime assignedAt,
      required String createdBy,
      Value<int> rowid,
    });
typedef $$LotLightingProgramsTableUpdateCompanionBuilder =
    LotLightingProgramsCompanion Function({
      Value<String> id,
      Value<String> lotId,
      Value<String> programId,
      Value<DateTime> assignedAt,
      Value<String> createdBy,
      Value<int> rowid,
    });

class $$LotLightingProgramsTableFilterComposer
    extends Composer<_$AppDatabase, $LotLightingProgramsTable> {
  $$LotLightingProgramsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lotId => $composableBuilder(
    column: $table.lotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get programId => $composableBuilder(
    column: $table.programId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get assignedAt => $composableBuilder(
    column: $table.assignedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LotLightingProgramsTableOrderingComposer
    extends Composer<_$AppDatabase, $LotLightingProgramsTable> {
  $$LotLightingProgramsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lotId => $composableBuilder(
    column: $table.lotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get programId => $composableBuilder(
    column: $table.programId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get assignedAt => $composableBuilder(
    column: $table.assignedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LotLightingProgramsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LotLightingProgramsTable> {
  $$LotLightingProgramsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lotId =>
      $composableBuilder(column: $table.lotId, builder: (column) => column);

  GeneratedColumn<String> get programId =>
      $composableBuilder(column: $table.programId, builder: (column) => column);

  GeneratedColumn<DateTime> get assignedAt => $composableBuilder(
    column: $table.assignedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);
}

class $$LotLightingProgramsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LotLightingProgramsTable,
          LotLightingProgram,
          $$LotLightingProgramsTableFilterComposer,
          $$LotLightingProgramsTableOrderingComposer,
          $$LotLightingProgramsTableAnnotationComposer,
          $$LotLightingProgramsTableCreateCompanionBuilder,
          $$LotLightingProgramsTableUpdateCompanionBuilder,
          (
            LotLightingProgram,
            BaseReferences<
              _$AppDatabase,
              $LotLightingProgramsTable,
              LotLightingProgram
            >,
          ),
          LotLightingProgram,
          PrefetchHooks Function()
        > {
  $$LotLightingProgramsTableTableManager(
    _$AppDatabase db,
    $LotLightingProgramsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LotLightingProgramsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LotLightingProgramsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LotLightingProgramsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> lotId = const Value.absent(),
                Value<String> programId = const Value.absent(),
                Value<DateTime> assignedAt = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LotLightingProgramsCompanion(
                id: id,
                lotId: lotId,
                programId: programId,
                assignedAt: assignedAt,
                createdBy: createdBy,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String lotId,
                required String programId,
                required DateTime assignedAt,
                required String createdBy,
                Value<int> rowid = const Value.absent(),
              }) => LotLightingProgramsCompanion.insert(
                id: id,
                lotId: lotId,
                programId: programId,
                assignedAt: assignedAt,
                createdBy: createdBy,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LotLightingProgramsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LotLightingProgramsTable,
      LotLightingProgram,
      $$LotLightingProgramsTableFilterComposer,
      $$LotLightingProgramsTableOrderingComposer,
      $$LotLightingProgramsTableAnnotationComposer,
      $$LotLightingProgramsTableCreateCompanionBuilder,
      $$LotLightingProgramsTableUpdateCompanionBuilder,
      (
        LotLightingProgram,
        BaseReferences<
          _$AppDatabase,
          $LotLightingProgramsTable,
          LotLightingProgram
        >,
      ),
      LotLightingProgram,
      PrefetchHooks Function()
    >;
typedef $$CalendarEventsTableCreateCompanionBuilder =
    CalendarEventsCompanion Function({
      required String id,
      required String title,
      required String type,
      required DateTime startsAt,
      Value<DateTime?> endsAt,
      Value<String?> lotId,
      Value<String?> referenceType,
      Value<String?> referenceId,
      Value<String?> notes,
      Value<bool> alertEnabled,
      Value<String?> alertMessage,
      Value<String> alertTime,
      Value<String> recurrence,
      Value<DateTime?> repeatUntil,
      Value<String?> weekdays,
      required String createdBy,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CalendarEventsTableUpdateCompanionBuilder =
    CalendarEventsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> type,
      Value<DateTime> startsAt,
      Value<DateTime?> endsAt,
      Value<String?> lotId,
      Value<String?> referenceType,
      Value<String?> referenceId,
      Value<String?> notes,
      Value<bool> alertEnabled,
      Value<String?> alertMessage,
      Value<String> alertTime,
      Value<String> recurrence,
      Value<DateTime?> repeatUntil,
      Value<String?> weekdays,
      Value<String> createdBy,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$CalendarEventsTableFilterComposer
    extends Composer<_$AppDatabase, $CalendarEventsTable> {
  $$CalendarEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startsAt => $composableBuilder(
    column: $table.startsAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endsAt => $composableBuilder(
    column: $table.endsAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lotId => $composableBuilder(
    column: $table.lotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceType => $composableBuilder(
    column: $table.referenceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get alertEnabled => $composableBuilder(
    column: $table.alertEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alertMessage => $composableBuilder(
    column: $table.alertMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alertTime => $composableBuilder(
    column: $table.alertTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get repeatUntil => $composableBuilder(
    column: $table.repeatUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weekdays => $composableBuilder(
    column: $table.weekdays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CalendarEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $CalendarEventsTable> {
  $$CalendarEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startsAt => $composableBuilder(
    column: $table.startsAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endsAt => $composableBuilder(
    column: $table.endsAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lotId => $composableBuilder(
    column: $table.lotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceType => $composableBuilder(
    column: $table.referenceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get alertEnabled => $composableBuilder(
    column: $table.alertEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alertMessage => $composableBuilder(
    column: $table.alertMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alertTime => $composableBuilder(
    column: $table.alertTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get repeatUntil => $composableBuilder(
    column: $table.repeatUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weekdays => $composableBuilder(
    column: $table.weekdays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CalendarEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CalendarEventsTable> {
  $$CalendarEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get startsAt =>
      $composableBuilder(column: $table.startsAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endsAt =>
      $composableBuilder(column: $table.endsAt, builder: (column) => column);

  GeneratedColumn<String> get lotId =>
      $composableBuilder(column: $table.lotId, builder: (column) => column);

  GeneratedColumn<String> get referenceType => $composableBuilder(
    column: $table.referenceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get alertEnabled => $composableBuilder(
    column: $table.alertEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get alertMessage => $composableBuilder(
    column: $table.alertMessage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get alertTime =>
      $composableBuilder(column: $table.alertTime, builder: (column) => column);

  GeneratedColumn<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get repeatUntil => $composableBuilder(
    column: $table.repeatUntil,
    builder: (column) => column,
  );

  GeneratedColumn<String> get weekdays =>
      $composableBuilder(column: $table.weekdays, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CalendarEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CalendarEventsTable,
          CalendarEvent,
          $$CalendarEventsTableFilterComposer,
          $$CalendarEventsTableOrderingComposer,
          $$CalendarEventsTableAnnotationComposer,
          $$CalendarEventsTableCreateCompanionBuilder,
          $$CalendarEventsTableUpdateCompanionBuilder,
          (
            CalendarEvent,
            BaseReferences<_$AppDatabase, $CalendarEventsTable, CalendarEvent>,
          ),
          CalendarEvent,
          PrefetchHooks Function()
        > {
  $$CalendarEventsTableTableManager(
    _$AppDatabase db,
    $CalendarEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CalendarEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CalendarEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CalendarEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> startsAt = const Value.absent(),
                Value<DateTime?> endsAt = const Value.absent(),
                Value<String?> lotId = const Value.absent(),
                Value<String?> referenceType = const Value.absent(),
                Value<String?> referenceId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> alertEnabled = const Value.absent(),
                Value<String?> alertMessage = const Value.absent(),
                Value<String> alertTime = const Value.absent(),
                Value<String> recurrence = const Value.absent(),
                Value<DateTime?> repeatUntil = const Value.absent(),
                Value<String?> weekdays = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CalendarEventsCompanion(
                id: id,
                title: title,
                type: type,
                startsAt: startsAt,
                endsAt: endsAt,
                lotId: lotId,
                referenceType: referenceType,
                referenceId: referenceId,
                notes: notes,
                alertEnabled: alertEnabled,
                alertMessage: alertMessage,
                alertTime: alertTime,
                recurrence: recurrence,
                repeatUntil: repeatUntil,
                weekdays: weekdays,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String type,
                required DateTime startsAt,
                Value<DateTime?> endsAt = const Value.absent(),
                Value<String?> lotId = const Value.absent(),
                Value<String?> referenceType = const Value.absent(),
                Value<String?> referenceId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> alertEnabled = const Value.absent(),
                Value<String?> alertMessage = const Value.absent(),
                Value<String> alertTime = const Value.absent(),
                Value<String> recurrence = const Value.absent(),
                Value<DateTime?> repeatUntil = const Value.absent(),
                Value<String?> weekdays = const Value.absent(),
                required String createdBy,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CalendarEventsCompanion.insert(
                id: id,
                title: title,
                type: type,
                startsAt: startsAt,
                endsAt: endsAt,
                lotId: lotId,
                referenceType: referenceType,
                referenceId: referenceId,
                notes: notes,
                alertEnabled: alertEnabled,
                alertMessage: alertMessage,
                alertTime: alertTime,
                recurrence: recurrence,
                repeatUntil: repeatUntil,
                weekdays: weekdays,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CalendarEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CalendarEventsTable,
      CalendarEvent,
      $$CalendarEventsTableFilterComposer,
      $$CalendarEventsTableOrderingComposer,
      $$CalendarEventsTableAnnotationComposer,
      $$CalendarEventsTableCreateCompanionBuilder,
      $$CalendarEventsTableUpdateCompanionBuilder,
      (
        CalendarEvent,
        BaseReferences<_$AppDatabase, $CalendarEventsTable, CalendarEvent>,
      ),
      CalendarEvent,
      PrefetchHooks Function()
    >;
typedef $$NotificationSettingsTableCreateCompanionBuilder =
    NotificationSettingsCompanion Function({
      required String id,
      required String type,
      Value<bool> isEnabled,
      Value<int> daysBefore,
      Value<String> notificationTime,
      Value<String?> defaultMessage,
      Value<String> defaultRecurrence,
      Value<int> rowid,
    });
typedef $$NotificationSettingsTableUpdateCompanionBuilder =
    NotificationSettingsCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<bool> isEnabled,
      Value<int> daysBefore,
      Value<String> notificationTime,
      Value<String?> defaultMessage,
      Value<String> defaultRecurrence,
      Value<int> rowid,
    });

class $$NotificationSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationSettingsTable> {
  $$NotificationSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get daysBefore => $composableBuilder(
    column: $table.daysBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notificationTime => $composableBuilder(
    column: $table.notificationTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultMessage => $composableBuilder(
    column: $table.defaultMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultRecurrence => $composableBuilder(
    column: $table.defaultRecurrence,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotificationSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationSettingsTable> {
  $$NotificationSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get daysBefore => $composableBuilder(
    column: $table.daysBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notificationTime => $composableBuilder(
    column: $table.notificationTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultMessage => $composableBuilder(
    column: $table.defaultMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultRecurrence => $composableBuilder(
    column: $table.defaultRecurrence,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotificationSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationSettingsTable> {
  $$NotificationSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<int> get daysBefore => $composableBuilder(
    column: $table.daysBefore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notificationTime => $composableBuilder(
    column: $table.notificationTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultMessage => $composableBuilder(
    column: $table.defaultMessage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultRecurrence => $composableBuilder(
    column: $table.defaultRecurrence,
    builder: (column) => column,
  );
}

class $$NotificationSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotificationSettingsTable,
          NotificationSetting,
          $$NotificationSettingsTableFilterComposer,
          $$NotificationSettingsTableOrderingComposer,
          $$NotificationSettingsTableAnnotationComposer,
          $$NotificationSettingsTableCreateCompanionBuilder,
          $$NotificationSettingsTableUpdateCompanionBuilder,
          (
            NotificationSetting,
            BaseReferences<
              _$AppDatabase,
              $NotificationSettingsTable,
              NotificationSetting
            >,
          ),
          NotificationSetting,
          PrefetchHooks Function()
        > {
  $$NotificationSettingsTableTableManager(
    _$AppDatabase db,
    $NotificationSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationSettingsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NotificationSettingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<int> daysBefore = const Value.absent(),
                Value<String> notificationTime = const Value.absent(),
                Value<String?> defaultMessage = const Value.absent(),
                Value<String> defaultRecurrence = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotificationSettingsCompanion(
                id: id,
                type: type,
                isEnabled: isEnabled,
                daysBefore: daysBefore,
                notificationTime: notificationTime,
                defaultMessage: defaultMessage,
                defaultRecurrence: defaultRecurrence,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                Value<bool> isEnabled = const Value.absent(),
                Value<int> daysBefore = const Value.absent(),
                Value<String> notificationTime = const Value.absent(),
                Value<String?> defaultMessage = const Value.absent(),
                Value<String> defaultRecurrence = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotificationSettingsCompanion.insert(
                id: id,
                type: type,
                isEnabled: isEnabled,
                daysBefore: daysBefore,
                notificationTime: notificationTime,
                defaultMessage: defaultMessage,
                defaultRecurrence: defaultRecurrence,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotificationSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotificationSettingsTable,
      NotificationSetting,
      $$NotificationSettingsTableFilterComposer,
      $$NotificationSettingsTableOrderingComposer,
      $$NotificationSettingsTableAnnotationComposer,
      $$NotificationSettingsTableCreateCompanionBuilder,
      $$NotificationSettingsTableUpdateCompanionBuilder,
      (
        NotificationSetting,
        BaseReferences<
          _$AppDatabase,
          $NotificationSettingsTable,
          NotificationSetting
        >,
      ),
      NotificationSetting,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      required DateTime updatedAt,
      Value<String?> updatedBy,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<String?> updatedBy,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required DateTime updatedAt,
                Value<String?> updatedBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$UserPermissionsTableTableManager get userPermissions =>
      $$UserPermissionsTableTableManager(_db, _db.userPermissions);
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db, _db.auditLogs);
  $$LotsTableTableManager get lots => $$LotsTableTableManager(_db, _db.lots);
  $$BirdMovementsTableTableManager get birdMovements =>
      $$BirdMovementsTableTableManager(_db, _db.birdMovements);
  $$EggCollectionsTableTableManager get eggCollections =>
      $$EggCollectionsTableTableManager(_db, _db.eggCollections);
  $$EggStockMovementsTableTableManager get eggStockMovements =>
      $$EggStockMovementsTableTableManager(_db, _db.eggStockMovements);
  $$IngredientsTableTableManager get ingredients =>
      $$IngredientsTableTableManager(_db, _db.ingredients);
  $$IngredientPriceHistoryTableTableManager get ingredientPriceHistory =>
      $$IngredientPriceHistoryTableTableManager(
        _db,
        _db.ingredientPriceHistory,
      );
  $$IngredientLotsTableTableManager get ingredientLots =>
      $$IngredientLotsTableTableManager(_db, _db.ingredientLots);
  $$IngredientStockMovementsTableTableManager get ingredientStockMovements =>
      $$IngredientStockMovementsTableTableManager(
        _db,
        _db.ingredientStockMovements,
      );
  $$FeedFormulasTableTableManager get feedFormulas =>
      $$FeedFormulasTableTableManager(_db, _db.feedFormulas);
  $$FeedFormulaItemsTableTableManager get feedFormulaItems =>
      $$FeedFormulaItemsTableTableManager(_db, _db.feedFormulaItems);
  $$FeedBatchesTableTableManager get feedBatches =>
      $$FeedBatchesTableTableManager(_db, _db.feedBatches);
  $$FeedBatchItemsTableTableManager get feedBatchItems =>
      $$FeedBatchItemsTableTableManager(_db, _db.feedBatchItems);
  $$FeedStockMovementsTableTableManager get feedStockMovements =>
      $$FeedStockMovementsTableTableManager(_db, _db.feedStockMovements);
  $$DailyFeedingsTableTableManager get dailyFeedings =>
      $$DailyFeedingsTableTableManager(_db, _db.dailyFeedings);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$OrdersTableTableManager get orders =>
      $$OrdersTableTableManager(_db, _db.orders);
  $$OrderItemsTableTableManager get orderItems =>
      $$OrderItemsTableTableManager(_db, _db.orderItems);
  $$OrderStatusHistoryTableTableManager get orderStatusHistory =>
      $$OrderStatusHistoryTableTableManager(_db, _db.orderStatusHistory);
  $$SalesTableTableManager get sales =>
      $$SalesTableTableManager(_db, _db.sales);
  $$FinanceTransactionsTableTableManager get financeTransactions =>
      $$FinanceTransactionsTableTableManager(_db, _db.financeTransactions);
  $$InvestmentsTableTableManager get investments =>
      $$InvestmentsTableTableManager(_db, _db.investments);
  $$LightingProgramsTableTableManager get lightingPrograms =>
      $$LightingProgramsTableTableManager(_db, _db.lightingPrograms);
  $$LightingProgramStepsTableTableManager get lightingProgramSteps =>
      $$LightingProgramStepsTableTableManager(_db, _db.lightingProgramSteps);
  $$LotLightingProgramsTableTableManager get lotLightingPrograms =>
      $$LotLightingProgramsTableTableManager(_db, _db.lotLightingPrograms);
  $$CalendarEventsTableTableManager get calendarEvents =>
      $$CalendarEventsTableTableManager(_db, _db.calendarEvents);
  $$NotificationSettingsTableTableManager get notificationSettings =>
      $$NotificationSettingsTableTableManager(_db, _db.notificationSettings);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
