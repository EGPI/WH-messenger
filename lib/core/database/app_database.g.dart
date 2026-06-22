// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalConversationsTable extends LocalConversations
    with TableInfo<$LocalConversationsTable, LocalConversation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalConversationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastMessagePreviewMeta =
      const VerificationMeta('lastMessagePreview');
  @override
  late final GeneratedColumn<String> lastMessagePreview =
      GeneratedColumn<String>(
        'last_message_preview',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastMessageIdMeta = const VerificationMeta(
    'lastMessageId',
  );
  @override
  late final GeneratedColumn<int> lastMessageId = GeneratedColumn<int>(
    'last_message_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastMessageSenderIdMeta =
      const VerificationMeta('lastMessageSenderId');
  @override
  late final GeneratedColumn<int> lastMessageSenderId = GeneratedColumn<int>(
    'last_message_sender_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastMessageAtMeta = const VerificationMeta(
    'lastMessageAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastMessageAt =
      GeneratedColumn<DateTime>(
        'last_message_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _unreadCountMeta = const VerificationMeta(
    'unreadCount',
  );
  @override
  late final GeneratedColumn<int> unreadCount = GeneratedColumn<int>(
    'unread_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _myRoleMeta = const VerificationMeta('myRole');
  @override
  late final GeneratedColumn<String> myRole = GeneratedColumn<String>(
    'my_role',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locallyUpdatedAtMeta = const VerificationMeta(
    'locallyUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> locallyUpdatedAt =
      GeneratedColumn<DateTime>(
        'locally_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    title,
    lastMessagePreview,
    lastMessageId,
    lastMessageSenderId,
    lastMessageAt,
    unreadCount,
    myRole,
    updatedAt,
    locallyUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_conversations';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalConversation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('last_message_preview')) {
      context.handle(
        _lastMessagePreviewMeta,
        lastMessagePreview.isAcceptableOrUnknown(
          data['last_message_preview']!,
          _lastMessagePreviewMeta,
        ),
      );
    }
    if (data.containsKey('last_message_id')) {
      context.handle(
        _lastMessageIdMeta,
        lastMessageId.isAcceptableOrUnknown(
          data['last_message_id']!,
          _lastMessageIdMeta,
        ),
      );
    }
    if (data.containsKey('last_message_sender_id')) {
      context.handle(
        _lastMessageSenderIdMeta,
        lastMessageSenderId.isAcceptableOrUnknown(
          data['last_message_sender_id']!,
          _lastMessageSenderIdMeta,
        ),
      );
    }
    if (data.containsKey('last_message_at')) {
      context.handle(
        _lastMessageAtMeta,
        lastMessageAt.isAcceptableOrUnknown(
          data['last_message_at']!,
          _lastMessageAtMeta,
        ),
      );
    }
    if (data.containsKey('unread_count')) {
      context.handle(
        _unreadCountMeta,
        unreadCount.isAcceptableOrUnknown(
          data['unread_count']!,
          _unreadCountMeta,
        ),
      );
    }
    if (data.containsKey('my_role')) {
      context.handle(
        _myRoleMeta,
        myRole.isAcceptableOrUnknown(data['my_role']!, _myRoleMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('locally_updated_at')) {
      context.handle(
        _locallyUpdatedAtMeta,
        locallyUpdatedAt.isAcceptableOrUnknown(
          data['locally_updated_at']!,
          _locallyUpdatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalConversation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalConversation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      lastMessagePreview: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_message_preview'],
      ),
      lastMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_message_id'],
      ),
      lastMessageSenderId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_message_sender_id'],
      ),
      lastMessageAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_message_at'],
      ),
      unreadCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unread_count'],
      )!,
      myRole: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}my_role'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      locallyUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}locally_updated_at'],
      )!,
    );
  }

  @override
  $LocalConversationsTable createAlias(String alias) {
    return $LocalConversationsTable(attachedDatabase, alias);
  }
}

class LocalConversation extends DataClass
    implements Insertable<LocalConversation> {
  /// Server conversation ID from Laravel.
  final int id;
  final String type;
  final String? title;
  final String? lastMessagePreview;
  final int? lastMessageId;
  final int? lastMessageSenderId;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final String? myRole;
  final DateTime? updatedAt;
  final DateTime locallyUpdatedAt;
  const LocalConversation({
    required this.id,
    required this.type,
    this.title,
    this.lastMessagePreview,
    this.lastMessageId,
    this.lastMessageSenderId,
    this.lastMessageAt,
    required this.unreadCount,
    this.myRole,
    this.updatedAt,
    required this.locallyUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || lastMessagePreview != null) {
      map['last_message_preview'] = Variable<String>(lastMessagePreview);
    }
    if (!nullToAbsent || lastMessageId != null) {
      map['last_message_id'] = Variable<int>(lastMessageId);
    }
    if (!nullToAbsent || lastMessageSenderId != null) {
      map['last_message_sender_id'] = Variable<int>(lastMessageSenderId);
    }
    if (!nullToAbsent || lastMessageAt != null) {
      map['last_message_at'] = Variable<DateTime>(lastMessageAt);
    }
    map['unread_count'] = Variable<int>(unreadCount);
    if (!nullToAbsent || myRole != null) {
      map['my_role'] = Variable<String>(myRole);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['locally_updated_at'] = Variable<DateTime>(locallyUpdatedAt);
    return map;
  }

  LocalConversationsCompanion toCompanion(bool nullToAbsent) {
    return LocalConversationsCompanion(
      id: Value(id),
      type: Value(type),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      lastMessagePreview: lastMessagePreview == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessagePreview),
      lastMessageId: lastMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageId),
      lastMessageSenderId: lastMessageSenderId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageSenderId),
      lastMessageAt: lastMessageAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageAt),
      unreadCount: Value(unreadCount),
      myRole: myRole == null && nullToAbsent
          ? const Value.absent()
          : Value(myRole),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      locallyUpdatedAt: Value(locallyUpdatedAt),
    );
  }

  factory LocalConversation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalConversation(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String?>(json['title']),
      lastMessagePreview: serializer.fromJson<String?>(
        json['lastMessagePreview'],
      ),
      lastMessageId: serializer.fromJson<int?>(json['lastMessageId']),
      lastMessageSenderId: serializer.fromJson<int?>(
        json['lastMessageSenderId'],
      ),
      lastMessageAt: serializer.fromJson<DateTime?>(json['lastMessageAt']),
      unreadCount: serializer.fromJson<int>(json['unreadCount']),
      myRole: serializer.fromJson<String?>(json['myRole']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      locallyUpdatedAt: serializer.fromJson<DateTime>(json['locallyUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String?>(title),
      'lastMessagePreview': serializer.toJson<String?>(lastMessagePreview),
      'lastMessageId': serializer.toJson<int?>(lastMessageId),
      'lastMessageSenderId': serializer.toJson<int?>(lastMessageSenderId),
      'lastMessageAt': serializer.toJson<DateTime?>(lastMessageAt),
      'unreadCount': serializer.toJson<int>(unreadCount),
      'myRole': serializer.toJson<String?>(myRole),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'locallyUpdatedAt': serializer.toJson<DateTime>(locallyUpdatedAt),
    };
  }

  LocalConversation copyWith({
    int? id,
    String? type,
    Value<String?> title = const Value.absent(),
    Value<String?> lastMessagePreview = const Value.absent(),
    Value<int?> lastMessageId = const Value.absent(),
    Value<int?> lastMessageSenderId = const Value.absent(),
    Value<DateTime?> lastMessageAt = const Value.absent(),
    int? unreadCount,
    Value<String?> myRole = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    DateTime? locallyUpdatedAt,
  }) => LocalConversation(
    id: id ?? this.id,
    type: type ?? this.type,
    title: title.present ? title.value : this.title,
    lastMessagePreview: lastMessagePreview.present
        ? lastMessagePreview.value
        : this.lastMessagePreview,
    lastMessageId: lastMessageId.present
        ? lastMessageId.value
        : this.lastMessageId,
    lastMessageSenderId: lastMessageSenderId.present
        ? lastMessageSenderId.value
        : this.lastMessageSenderId,
    lastMessageAt: lastMessageAt.present
        ? lastMessageAt.value
        : this.lastMessageAt,
    unreadCount: unreadCount ?? this.unreadCount,
    myRole: myRole.present ? myRole.value : this.myRole,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    locallyUpdatedAt: locallyUpdatedAt ?? this.locallyUpdatedAt,
  );
  LocalConversation copyWithCompanion(LocalConversationsCompanion data) {
    return LocalConversation(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      lastMessagePreview: data.lastMessagePreview.present
          ? data.lastMessagePreview.value
          : this.lastMessagePreview,
      lastMessageId: data.lastMessageId.present
          ? data.lastMessageId.value
          : this.lastMessageId,
      lastMessageSenderId: data.lastMessageSenderId.present
          ? data.lastMessageSenderId.value
          : this.lastMessageSenderId,
      lastMessageAt: data.lastMessageAt.present
          ? data.lastMessageAt.value
          : this.lastMessageAt,
      unreadCount: data.unreadCount.present
          ? data.unreadCount.value
          : this.unreadCount,
      myRole: data.myRole.present ? data.myRole.value : this.myRole,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      locallyUpdatedAt: data.locallyUpdatedAt.present
          ? data.locallyUpdatedAt.value
          : this.locallyUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalConversation(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('lastMessagePreview: $lastMessagePreview, ')
          ..write('lastMessageId: $lastMessageId, ')
          ..write('lastMessageSenderId: $lastMessageSenderId, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('myRole: $myRole, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('locallyUpdatedAt: $locallyUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    title,
    lastMessagePreview,
    lastMessageId,
    lastMessageSenderId,
    lastMessageAt,
    unreadCount,
    myRole,
    updatedAt,
    locallyUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalConversation &&
          other.id == this.id &&
          other.type == this.type &&
          other.title == this.title &&
          other.lastMessagePreview == this.lastMessagePreview &&
          other.lastMessageId == this.lastMessageId &&
          other.lastMessageSenderId == this.lastMessageSenderId &&
          other.lastMessageAt == this.lastMessageAt &&
          other.unreadCount == this.unreadCount &&
          other.myRole == this.myRole &&
          other.updatedAt == this.updatedAt &&
          other.locallyUpdatedAt == this.locallyUpdatedAt);
}

class LocalConversationsCompanion extends UpdateCompanion<LocalConversation> {
  final Value<int> id;
  final Value<String> type;
  final Value<String?> title;
  final Value<String?> lastMessagePreview;
  final Value<int?> lastMessageId;
  final Value<int?> lastMessageSenderId;
  final Value<DateTime?> lastMessageAt;
  final Value<int> unreadCount;
  final Value<String?> myRole;
  final Value<DateTime?> updatedAt;
  final Value<DateTime> locallyUpdatedAt;
  const LocalConversationsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.lastMessagePreview = const Value.absent(),
    this.lastMessageId = const Value.absent(),
    this.lastMessageSenderId = const Value.absent(),
    this.lastMessageAt = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.myRole = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.locallyUpdatedAt = const Value.absent(),
  });
  LocalConversationsCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    this.title = const Value.absent(),
    this.lastMessagePreview = const Value.absent(),
    this.lastMessageId = const Value.absent(),
    this.lastMessageSenderId = const Value.absent(),
    this.lastMessageAt = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.myRole = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.locallyUpdatedAt = const Value.absent(),
  }) : type = Value(type);
  static Insertable<LocalConversation> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? lastMessagePreview,
    Expression<int>? lastMessageId,
    Expression<int>? lastMessageSenderId,
    Expression<DateTime>? lastMessageAt,
    Expression<int>? unreadCount,
    Expression<String>? myRole,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? locallyUpdatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (lastMessagePreview != null)
        'last_message_preview': lastMessagePreview,
      if (lastMessageId != null) 'last_message_id': lastMessageId,
      if (lastMessageSenderId != null)
        'last_message_sender_id': lastMessageSenderId,
      if (lastMessageAt != null) 'last_message_at': lastMessageAt,
      if (unreadCount != null) 'unread_count': unreadCount,
      if (myRole != null) 'my_role': myRole,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (locallyUpdatedAt != null) 'locally_updated_at': locallyUpdatedAt,
    });
  }

  LocalConversationsCompanion copyWith({
    Value<int>? id,
    Value<String>? type,
    Value<String?>? title,
    Value<String?>? lastMessagePreview,
    Value<int?>? lastMessageId,
    Value<int?>? lastMessageSenderId,
    Value<DateTime?>? lastMessageAt,
    Value<int>? unreadCount,
    Value<String?>? myRole,
    Value<DateTime?>? updatedAt,
    Value<DateTime>? locallyUpdatedAt,
  }) {
    return LocalConversationsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      myRole: myRole ?? this.myRole,
      updatedAt: updatedAt ?? this.updatedAt,
      locallyUpdatedAt: locallyUpdatedAt ?? this.locallyUpdatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (lastMessagePreview.present) {
      map['last_message_preview'] = Variable<String>(lastMessagePreview.value);
    }
    if (lastMessageId.present) {
      map['last_message_id'] = Variable<int>(lastMessageId.value);
    }
    if (lastMessageSenderId.present) {
      map['last_message_sender_id'] = Variable<int>(lastMessageSenderId.value);
    }
    if (lastMessageAt.present) {
      map['last_message_at'] = Variable<DateTime>(lastMessageAt.value);
    }
    if (unreadCount.present) {
      map['unread_count'] = Variable<int>(unreadCount.value);
    }
    if (myRole.present) {
      map['my_role'] = Variable<String>(myRole.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (locallyUpdatedAt.present) {
      map['locally_updated_at'] = Variable<DateTime>(locallyUpdatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalConversationsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('lastMessagePreview: $lastMessagePreview, ')
          ..write('lastMessageId: $lastMessageId, ')
          ..write('lastMessageSenderId: $lastMessageSenderId, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('myRole: $myRole, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('locallyUpdatedAt: $locallyUpdatedAt')
          ..write(')'))
        .toString();
  }
}

class $LocalMessagesTable extends LocalMessages
    with TableInfo<$LocalMessagesTable, LocalMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<int> conversationId = GeneratedColumn<int>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderIdMeta = const VerificationMeta(
    'senderId',
  );
  @override
  late final GeneratedColumn<int> senderId = GeneratedColumn<int>(
    'sender_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
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
    requiredDuringInsert: false,
    defaultValue: const Constant('text'),
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
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
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _clientMessageIdMeta = const VerificationMeta(
    'clientMessageId',
  );
  @override
  late final GeneratedColumn<String> clientMessageId = GeneratedColumn<String>(
    'client_message_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _serverSequenceMeta = const VerificationMeta(
    'serverSequence',
  );
  @override
  late final GeneratedColumn<int> serverSequence = GeneratedColumn<int>(
    'server_sequence',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
  static const VerificationMeta _serverReceivedAtMeta = const VerificationMeta(
    'serverReceivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> serverReceivedAt =
      GeneratedColumn<DateTime>(
        'server_received_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _deliveredAtMeta = const VerificationMeta(
    'deliveredAt',
  );
  @override
  late final GeneratedColumn<DateTime> deliveredAt = GeneratedColumn<DateTime>(
    'delivered_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
    'read_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locallyUpdatedAtMeta = const VerificationMeta(
    'locallyUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> locallyUpdatedAt =
      GeneratedColumn<DateTime>(
        'locally_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    serverId,
    conversationId,
    senderId,
    body,
    type,
    payloadJson,
    status,
    clientMessageId,
    serverSequence,
    createdAt,
    serverReceivedAt,
    deliveredAt,
    readAt,
    locallyUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(
        _senderIdMeta,
        senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('client_message_id')) {
      context.handle(
        _clientMessageIdMeta,
        clientMessageId.isAcceptableOrUnknown(
          data['client_message_id']!,
          _clientMessageIdMeta,
        ),
      );
    }
    if (data.containsKey('server_sequence')) {
      context.handle(
        _serverSequenceMeta,
        serverSequence.isAcceptableOrUnknown(
          data['server_sequence']!,
          _serverSequenceMeta,
        ),
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
    if (data.containsKey('server_received_at')) {
      context.handle(
        _serverReceivedAtMeta,
        serverReceivedAt.isAcceptableOrUnknown(
          data['server_received_at']!,
          _serverReceivedAtMeta,
        ),
      );
    }
    if (data.containsKey('delivered_at')) {
      context.handle(
        _deliveredAtMeta,
        deliveredAt.isAcceptableOrUnknown(
          data['delivered_at']!,
          _deliveredAtMeta,
        ),
      );
    }
    if (data.containsKey('read_at')) {
      context.handle(
        _readAtMeta,
        readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta),
      );
    }
    if (data.containsKey('locally_updated_at')) {
      context.handle(
        _locallyUpdatedAtMeta,
        locallyUpdatedAt.isAcceptableOrUnknown(
          data['locally_updated_at']!,
          _locallyUpdatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  LocalMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalMessage(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conversation_id'],
      )!,
      senderId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sender_id'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      clientMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_message_id'],
      ),
      serverSequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_sequence'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      serverReceivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}server_received_at'],
      ),
      deliveredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}delivered_at'],
      ),
      readAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}read_at'],
      ),
      locallyUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}locally_updated_at'],
      )!,
    );
  }

  @override
  $LocalMessagesTable createAlias(String alias) {
    return $LocalMessagesTable(attachedDatabase, alias);
  }
}

class LocalMessage extends DataClass implements Insertable<LocalMessage> {
  /// Local auto ID used even before the server creates a real message ID.
  final int localId;

  /// Server message ID from Laravel. Nullable while message is pending.
  final int? serverId;
  final int conversationId;
  final int senderId;
  final String body;

  /// For v1 this will be "text".
  final String type;
  final String? payloadJson;

  /// pending, sent, delivered, read, failed
  final String status;

  /// UUID generated by Flutter before sending.
  final String? clientMessageId;

  /// Server-side ordering inside conversation.
  /// Nullable while message is still pending locally.
  final int? serverSequence;

  /// Local created time. Used temporarily for pending display.
  final DateTime createdAt;

  /// Server accepted the message.
  final DateTime? serverReceivedAt;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final DateTime locallyUpdatedAt;
  const LocalMessage({
    required this.localId,
    this.serverId,
    required this.conversationId,
    required this.senderId,
    required this.body,
    required this.type,
    this.payloadJson,
    required this.status,
    this.clientMessageId,
    this.serverSequence,
    required this.createdAt,
    this.serverReceivedAt,
    this.deliveredAt,
    this.readAt,
    required this.locallyUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['conversation_id'] = Variable<int>(conversationId);
    map['sender_id'] = Variable<int>(senderId);
    map['body'] = Variable<String>(body);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || payloadJson != null) {
      map['payload_json'] = Variable<String>(payloadJson);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || clientMessageId != null) {
      map['client_message_id'] = Variable<String>(clientMessageId);
    }
    if (!nullToAbsent || serverSequence != null) {
      map['server_sequence'] = Variable<int>(serverSequence);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || serverReceivedAt != null) {
      map['server_received_at'] = Variable<DateTime>(serverReceivedAt);
    }
    if (!nullToAbsent || deliveredAt != null) {
      map['delivered_at'] = Variable<DateTime>(deliveredAt);
    }
    if (!nullToAbsent || readAt != null) {
      map['read_at'] = Variable<DateTime>(readAt);
    }
    map['locally_updated_at'] = Variable<DateTime>(locallyUpdatedAt);
    return map;
  }

  LocalMessagesCompanion toCompanion(bool nullToAbsent) {
    return LocalMessagesCompanion(
      localId: Value(localId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      conversationId: Value(conversationId),
      senderId: Value(senderId),
      body: Value(body),
      type: Value(type),
      payloadJson: payloadJson == null && nullToAbsent
          ? const Value.absent()
          : Value(payloadJson),
      status: Value(status),
      clientMessageId: clientMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientMessageId),
      serverSequence: serverSequence == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSequence),
      createdAt: Value(createdAt),
      serverReceivedAt: serverReceivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverReceivedAt),
      deliveredAt: deliveredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveredAt),
      readAt: readAt == null && nullToAbsent
          ? const Value.absent()
          : Value(readAt),
      locallyUpdatedAt: Value(locallyUpdatedAt),
    );
  }

  factory LocalMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalMessage(
      localId: serializer.fromJson<int>(json['localId']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      conversationId: serializer.fromJson<int>(json['conversationId']),
      senderId: serializer.fromJson<int>(json['senderId']),
      body: serializer.fromJson<String>(json['body']),
      type: serializer.fromJson<String>(json['type']),
      payloadJson: serializer.fromJson<String?>(json['payloadJson']),
      status: serializer.fromJson<String>(json['status']),
      clientMessageId: serializer.fromJson<String?>(json['clientMessageId']),
      serverSequence: serializer.fromJson<int?>(json['serverSequence']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      serverReceivedAt: serializer.fromJson<DateTime?>(
        json['serverReceivedAt'],
      ),
      deliveredAt: serializer.fromJson<DateTime?>(json['deliveredAt']),
      readAt: serializer.fromJson<DateTime?>(json['readAt']),
      locallyUpdatedAt: serializer.fromJson<DateTime>(json['locallyUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'serverId': serializer.toJson<int?>(serverId),
      'conversationId': serializer.toJson<int>(conversationId),
      'senderId': serializer.toJson<int>(senderId),
      'body': serializer.toJson<String>(body),
      'type': serializer.toJson<String>(type),
      'payloadJson': serializer.toJson<String?>(payloadJson),
      'status': serializer.toJson<String>(status),
      'clientMessageId': serializer.toJson<String?>(clientMessageId),
      'serverSequence': serializer.toJson<int?>(serverSequence),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'serverReceivedAt': serializer.toJson<DateTime?>(serverReceivedAt),
      'deliveredAt': serializer.toJson<DateTime?>(deliveredAt),
      'readAt': serializer.toJson<DateTime?>(readAt),
      'locallyUpdatedAt': serializer.toJson<DateTime>(locallyUpdatedAt),
    };
  }

  LocalMessage copyWith({
    int? localId,
    Value<int?> serverId = const Value.absent(),
    int? conversationId,
    int? senderId,
    String? body,
    String? type,
    Value<String?> payloadJson = const Value.absent(),
    String? status,
    Value<String?> clientMessageId = const Value.absent(),
    Value<int?> serverSequence = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> serverReceivedAt = const Value.absent(),
    Value<DateTime?> deliveredAt = const Value.absent(),
    Value<DateTime?> readAt = const Value.absent(),
    DateTime? locallyUpdatedAt,
  }) => LocalMessage(
    localId: localId ?? this.localId,
    serverId: serverId.present ? serverId.value : this.serverId,
    conversationId: conversationId ?? this.conversationId,
    senderId: senderId ?? this.senderId,
    body: body ?? this.body,
    type: type ?? this.type,
    payloadJson: payloadJson.present ? payloadJson.value : this.payloadJson,
    status: status ?? this.status,
    clientMessageId: clientMessageId.present
        ? clientMessageId.value
        : this.clientMessageId,
    serverSequence: serverSequence.present
        ? serverSequence.value
        : this.serverSequence,
    createdAt: createdAt ?? this.createdAt,
    serverReceivedAt: serverReceivedAt.present
        ? serverReceivedAt.value
        : this.serverReceivedAt,
    deliveredAt: deliveredAt.present ? deliveredAt.value : this.deliveredAt,
    readAt: readAt.present ? readAt.value : this.readAt,
    locallyUpdatedAt: locallyUpdatedAt ?? this.locallyUpdatedAt,
  );
  LocalMessage copyWithCompanion(LocalMessagesCompanion data) {
    return LocalMessage(
      localId: data.localId.present ? data.localId.value : this.localId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      body: data.body.present ? data.body.value : this.body,
      type: data.type.present ? data.type.value : this.type,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      status: data.status.present ? data.status.value : this.status,
      clientMessageId: data.clientMessageId.present
          ? data.clientMessageId.value
          : this.clientMessageId,
      serverSequence: data.serverSequence.present
          ? data.serverSequence.value
          : this.serverSequence,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      serverReceivedAt: data.serverReceivedAt.present
          ? data.serverReceivedAt.value
          : this.serverReceivedAt,
      deliveredAt: data.deliveredAt.present
          ? data.deliveredAt.value
          : this.deliveredAt,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
      locallyUpdatedAt: data.locallyUpdatedAt.present
          ? data.locallyUpdatedAt.value
          : this.locallyUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalMessage(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('conversationId: $conversationId, ')
          ..write('senderId: $senderId, ')
          ..write('body: $body, ')
          ..write('type: $type, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('status: $status, ')
          ..write('clientMessageId: $clientMessageId, ')
          ..write('serverSequence: $serverSequence, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverReceivedAt: $serverReceivedAt, ')
          ..write('deliveredAt: $deliveredAt, ')
          ..write('readAt: $readAt, ')
          ..write('locallyUpdatedAt: $locallyUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    serverId,
    conversationId,
    senderId,
    body,
    type,
    payloadJson,
    status,
    clientMessageId,
    serverSequence,
    createdAt,
    serverReceivedAt,
    deliveredAt,
    readAt,
    locallyUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalMessage &&
          other.localId == this.localId &&
          other.serverId == this.serverId &&
          other.conversationId == this.conversationId &&
          other.senderId == this.senderId &&
          other.body == this.body &&
          other.type == this.type &&
          other.payloadJson == this.payloadJson &&
          other.status == this.status &&
          other.clientMessageId == this.clientMessageId &&
          other.serverSequence == this.serverSequence &&
          other.createdAt == this.createdAt &&
          other.serverReceivedAt == this.serverReceivedAt &&
          other.deliveredAt == this.deliveredAt &&
          other.readAt == this.readAt &&
          other.locallyUpdatedAt == this.locallyUpdatedAt);
}

class LocalMessagesCompanion extends UpdateCompanion<LocalMessage> {
  final Value<int> localId;
  final Value<int?> serverId;
  final Value<int> conversationId;
  final Value<int> senderId;
  final Value<String> body;
  final Value<String> type;
  final Value<String?> payloadJson;
  final Value<String> status;
  final Value<String?> clientMessageId;
  final Value<int?> serverSequence;
  final Value<DateTime> createdAt;
  final Value<DateTime?> serverReceivedAt;
  final Value<DateTime?> deliveredAt;
  final Value<DateTime?> readAt;
  final Value<DateTime> locallyUpdatedAt;
  const LocalMessagesCompanion({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.senderId = const Value.absent(),
    this.body = const Value.absent(),
    this.type = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.status = const Value.absent(),
    this.clientMessageId = const Value.absent(),
    this.serverSequence = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.serverReceivedAt = const Value.absent(),
    this.deliveredAt = const Value.absent(),
    this.readAt = const Value.absent(),
    this.locallyUpdatedAt = const Value.absent(),
  });
  LocalMessagesCompanion.insert({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    required int conversationId,
    required int senderId,
    required String body,
    this.type = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.status = const Value.absent(),
    this.clientMessageId = const Value.absent(),
    this.serverSequence = const Value.absent(),
    required DateTime createdAt,
    this.serverReceivedAt = const Value.absent(),
    this.deliveredAt = const Value.absent(),
    this.readAt = const Value.absent(),
    this.locallyUpdatedAt = const Value.absent(),
  }) : conversationId = Value(conversationId),
       senderId = Value(senderId),
       body = Value(body),
       createdAt = Value(createdAt);
  static Insertable<LocalMessage> custom({
    Expression<int>? localId,
    Expression<int>? serverId,
    Expression<int>? conversationId,
    Expression<int>? senderId,
    Expression<String>? body,
    Expression<String>? type,
    Expression<String>? payloadJson,
    Expression<String>? status,
    Expression<String>? clientMessageId,
    Expression<int>? serverSequence,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? serverReceivedAt,
    Expression<DateTime>? deliveredAt,
    Expression<DateTime>? readAt,
    Expression<DateTime>? locallyUpdatedAt,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (serverId != null) 'server_id': serverId,
      if (conversationId != null) 'conversation_id': conversationId,
      if (senderId != null) 'sender_id': senderId,
      if (body != null) 'body': body,
      if (type != null) 'type': type,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (status != null) 'status': status,
      if (clientMessageId != null) 'client_message_id': clientMessageId,
      if (serverSequence != null) 'server_sequence': serverSequence,
      if (createdAt != null) 'created_at': createdAt,
      if (serverReceivedAt != null) 'server_received_at': serverReceivedAt,
      if (deliveredAt != null) 'delivered_at': deliveredAt,
      if (readAt != null) 'read_at': readAt,
      if (locallyUpdatedAt != null) 'locally_updated_at': locallyUpdatedAt,
    });
  }

  LocalMessagesCompanion copyWith({
    Value<int>? localId,
    Value<int?>? serverId,
    Value<int>? conversationId,
    Value<int>? senderId,
    Value<String>? body,
    Value<String>? type,
    Value<String?>? payloadJson,
    Value<String>? status,
    Value<String?>? clientMessageId,
    Value<int?>? serverSequence,
    Value<DateTime>? createdAt,
    Value<DateTime?>? serverReceivedAt,
    Value<DateTime?>? deliveredAt,
    Value<DateTime?>? readAt,
    Value<DateTime>? locallyUpdatedAt,
  }) {
    return LocalMessagesCompanion(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      body: body ?? this.body,
      type: type ?? this.type,
      payloadJson: payloadJson ?? this.payloadJson,
      status: status ?? this.status,
      clientMessageId: clientMessageId ?? this.clientMessageId,
      serverSequence: serverSequence ?? this.serverSequence,
      createdAt: createdAt ?? this.createdAt,
      serverReceivedAt: serverReceivedAt ?? this.serverReceivedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      readAt: readAt ?? this.readAt,
      locallyUpdatedAt: locallyUpdatedAt ?? this.locallyUpdatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<int>(conversationId.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<int>(senderId.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (clientMessageId.present) {
      map['client_message_id'] = Variable<String>(clientMessageId.value);
    }
    if (serverSequence.present) {
      map['server_sequence'] = Variable<int>(serverSequence.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (serverReceivedAt.present) {
      map['server_received_at'] = Variable<DateTime>(serverReceivedAt.value);
    }
    if (deliveredAt.present) {
      map['delivered_at'] = Variable<DateTime>(deliveredAt.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    if (locallyUpdatedAt.present) {
      map['locally_updated_at'] = Variable<DateTime>(locallyUpdatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalMessagesCompanion(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('conversationId: $conversationId, ')
          ..write('senderId: $senderId, ')
          ..write('body: $body, ')
          ..write('type: $type, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('status: $status, ')
          ..write('clientMessageId: $clientMessageId, ')
          ..write('serverSequence: $serverSequence, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverReceivedAt: $serverReceivedAt, ')
          ..write('deliveredAt: $deliveredAt, ')
          ..write('readAt: $readAt, ')
          ..write('locallyUpdatedAt: $locallyUpdatedAt')
          ..write(')'))
        .toString();
  }
}

class $LocalOutboxTable extends LocalOutbox
    with TableInfo<$LocalOutboxTable, LocalOutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<int> conversationId = GeneratedColumn<int>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientMessageIdMeta = const VerificationMeta(
    'clientMessageId',
  );
  @override
  late final GeneratedColumn<String> clientMessageId = GeneratedColumn<String>(
    'client_message_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
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
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextRetryAtMeta = const VerificationMeta(
    'nextRetryAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextRetryAt = GeneratedColumn<DateTime>(
    'next_retry_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    conversationId,
    clientMessageId,
    body,
    status,
    attemptCount,
    lastError,
    nextRetryAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalOutboxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('client_message_id')) {
      context.handle(
        _clientMessageIdMeta,
        clientMessageId.isAcceptableOrUnknown(
          data['client_message_id']!,
          _clientMessageIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clientMessageIdMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('next_retry_at')) {
      context.handle(
        _nextRetryAtMeta,
        nextRetryAt.isAcceptableOrUnknown(
          data['next_retry_at']!,
          _nextRetryAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalOutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalOutboxData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conversation_id'],
      )!,
      clientMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_message_id'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      nextRetryAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_retry_at'],
      ),
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
  $LocalOutboxTable createAlias(String alias) {
    return $LocalOutboxTable(attachedDatabase, alias);
  }
}

class LocalOutboxData extends DataClass implements Insertable<LocalOutboxData> {
  final int id;
  final int conversationId;
  final String clientMessageId;
  final String body;

  /// pending, sending, failed
  final String status;
  final int attemptCount;
  final String? lastError;
  final DateTime? nextRetryAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LocalOutboxData({
    required this.id,
    required this.conversationId,
    required this.clientMessageId,
    required this.body,
    required this.status,
    required this.attemptCount,
    this.lastError,
    this.nextRetryAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['conversation_id'] = Variable<int>(conversationId);
    map['client_message_id'] = Variable<String>(clientMessageId);
    map['body'] = Variable<String>(body);
    map['status'] = Variable<String>(status);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    if (!nullToAbsent || nextRetryAt != null) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalOutboxCompanion toCompanion(bool nullToAbsent) {
    return LocalOutboxCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      clientMessageId: Value(clientMessageId),
      body: Value(body),
      status: Value(status),
      attemptCount: Value(attemptCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      nextRetryAt: nextRetryAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRetryAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalOutboxData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalOutboxData(
      id: serializer.fromJson<int>(json['id']),
      conversationId: serializer.fromJson<int>(json['conversationId']),
      clientMessageId: serializer.fromJson<String>(json['clientMessageId']),
      body: serializer.fromJson<String>(json['body']),
      status: serializer.fromJson<String>(json['status']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      nextRetryAt: serializer.fromJson<DateTime?>(json['nextRetryAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'conversationId': serializer.toJson<int>(conversationId),
      'clientMessageId': serializer.toJson<String>(clientMessageId),
      'body': serializer.toJson<String>(body),
      'status': serializer.toJson<String>(status),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'lastError': serializer.toJson<String?>(lastError),
      'nextRetryAt': serializer.toJson<DateTime?>(nextRetryAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalOutboxData copyWith({
    int? id,
    int? conversationId,
    String? clientMessageId,
    String? body,
    String? status,
    int? attemptCount,
    Value<String?> lastError = const Value.absent(),
    Value<DateTime?> nextRetryAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LocalOutboxData(
    id: id ?? this.id,
    conversationId: conversationId ?? this.conversationId,
    clientMessageId: clientMessageId ?? this.clientMessageId,
    body: body ?? this.body,
    status: status ?? this.status,
    attemptCount: attemptCount ?? this.attemptCount,
    lastError: lastError.present ? lastError.value : this.lastError,
    nextRetryAt: nextRetryAt.present ? nextRetryAt.value : this.nextRetryAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalOutboxData copyWithCompanion(LocalOutboxCompanion data) {
    return LocalOutboxData(
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      clientMessageId: data.clientMessageId.present
          ? data.clientMessageId.value
          : this.clientMessageId,
      body: data.body.present ? data.body.value : this.body,
      status: data.status.present ? data.status.value : this.status,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      nextRetryAt: data.nextRetryAt.present
          ? data.nextRetryAt.value
          : this.nextRetryAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalOutboxData(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('clientMessageId: $clientMessageId, ')
          ..write('body: $body, ')
          ..write('status: $status, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastError: $lastError, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    conversationId,
    clientMessageId,
    body,
    status,
    attemptCount,
    lastError,
    nextRetryAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalOutboxData &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.clientMessageId == this.clientMessageId &&
          other.body == this.body &&
          other.status == this.status &&
          other.attemptCount == this.attemptCount &&
          other.lastError == this.lastError &&
          other.nextRetryAt == this.nextRetryAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalOutboxCompanion extends UpdateCompanion<LocalOutboxData> {
  final Value<int> id;
  final Value<int> conversationId;
  final Value<String> clientMessageId;
  final Value<String> body;
  final Value<String> status;
  final Value<int> attemptCount;
  final Value<String?> lastError;
  final Value<DateTime?> nextRetryAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const LocalOutboxCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.clientMessageId = const Value.absent(),
    this.body = const Value.absent(),
    this.status = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  LocalOutboxCompanion.insert({
    this.id = const Value.absent(),
    required int conversationId,
    required String clientMessageId,
    required String body,
    this.status = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : conversationId = Value(conversationId),
       clientMessageId = Value(clientMessageId),
       body = Value(body);
  static Insertable<LocalOutboxData> custom({
    Expression<int>? id,
    Expression<int>? conversationId,
    Expression<String>? clientMessageId,
    Expression<String>? body,
    Expression<String>? status,
    Expression<int>? attemptCount,
    Expression<String>? lastError,
    Expression<DateTime>? nextRetryAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (clientMessageId != null) 'client_message_id': clientMessageId,
      if (body != null) 'body': body,
      if (status != null) 'status': status,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (lastError != null) 'last_error': lastError,
      if (nextRetryAt != null) 'next_retry_at': nextRetryAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  LocalOutboxCompanion copyWith({
    Value<int>? id,
    Value<int>? conversationId,
    Value<String>? clientMessageId,
    Value<String>? body,
    Value<String>? status,
    Value<int>? attemptCount,
    Value<String?>? lastError,
    Value<DateTime?>? nextRetryAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return LocalOutboxCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      clientMessageId: clientMessageId ?? this.clientMessageId,
      body: body ?? this.body,
      status: status ?? this.status,
      attemptCount: attemptCount ?? this.attemptCount,
      lastError: lastError ?? this.lastError,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<int>(conversationId.value);
    }
    if (clientMessageId.present) {
      map['client_message_id'] = Variable<String>(clientMessageId.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (nextRetryAt.present) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalOutboxCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('clientMessageId: $clientMessageId, ')
          ..write('body: $body, ')
          ..write('status: $status, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastError: $lastError, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $LocalSyncStateTable extends LocalSyncState
    with TableInfo<$LocalSyncStateTable, LocalSyncStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSyncStateTable(this.attachedDatabase, [this._alias]);
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_sync_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalSyncStateData> instance, {
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
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  LocalSyncStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSyncStateData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalSyncStateTable createAlias(String alias) {
    return $LocalSyncStateTable(attachedDatabase, alias);
  }
}

class LocalSyncStateData extends DataClass
    implements Insertable<LocalSyncStateData> {
  /// Example keys:
  /// last_event_id
  /// last_full_conversation_sync_at
  /// device_id
  final String key;
  final String? value;
  final DateTime updatedAt;
  const LocalSyncStateData({
    required this.key,
    this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalSyncStateCompanion toCompanion(bool nullToAbsent) {
    return LocalSyncStateCompanion(
      key: Value(key),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalSyncStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSyncStateData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalSyncStateData copyWith({
    String? key,
    Value<String?> value = const Value.absent(),
    DateTime? updatedAt,
  }) => LocalSyncStateData(
    key: key ?? this.key,
    value: value.present ? value.value : this.value,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalSyncStateData copyWithCompanion(LocalSyncStateCompanion data) {
    return LocalSyncStateData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSyncStateData(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSyncStateData &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class LocalSyncStateCompanion extends UpdateCompanion<LocalSyncStateData> {
  final Value<String> key;
  final Value<String?> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalSyncStateCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalSyncStateCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<LocalSyncStateData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalSyncStateCompanion copyWith({
    Value<String>? key,
    Value<String?>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalSyncStateCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSyncStateCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalUsersTable extends LocalUsers
    with TableInfo<$LocalUsersTable, LocalUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeenAt = GeneratedColumn<DateTime>(
    'last_seen_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locallyUpdatedAtMeta = const VerificationMeta(
    'locallyUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> locallyUpdatedAt =
      GeneratedColumn<DateTime>(
        'locally_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    email,
    avatarUrl,
    phone,
    isActive,
    lastSeenAt,
    locallyUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_users';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalUser> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    }
    if (data.containsKey('locally_updated_at')) {
      context.handle(
        _locallyUpdatedAtMeta,
        locallyUpdatedAt.isAcceptableOrUnknown(
          data['locally_updated_at']!,
          _locallyUpdatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalUser(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen_at'],
      ),
      locallyUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}locally_updated_at'],
      )!,
    );
  }

  @override
  $LocalUsersTable createAlias(String alias) {
    return $LocalUsersTable(attachedDatabase, alias);
  }
}

class LocalUser extends DataClass implements Insertable<LocalUser> {
  /// Server user ID from Laravel.
  final int id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? phone;
  final bool isActive;
  final DateTime? lastSeenAt;
  final DateTime locallyUpdatedAt;
  const LocalUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.phone,
    required this.isActive,
    this.lastSeenAt,
    required this.locallyUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['email'] = Variable<String>(email);
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || lastSeenAt != null) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt);
    }
    map['locally_updated_at'] = Variable<DateTime>(locallyUpdatedAt);
    return map;
  }

  LocalUsersCompanion toCompanion(bool nullToAbsent) {
    return LocalUsersCompanion(
      id: Value(id),
      name: Value(name),
      email: Value(email),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      isActive: Value(isActive),
      lastSeenAt: lastSeenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeenAt),
      locallyUpdatedAt: Value(locallyUpdatedAt),
    );
  }

  factory LocalUser.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalUser(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String>(json['email']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      phone: serializer.fromJson<String?>(json['phone']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      lastSeenAt: serializer.fromJson<DateTime?>(json['lastSeenAt']),
      locallyUpdatedAt: serializer.fromJson<DateTime>(json['locallyUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String>(email),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'phone': serializer.toJson<String?>(phone),
      'isActive': serializer.toJson<bool>(isActive),
      'lastSeenAt': serializer.toJson<DateTime?>(lastSeenAt),
      'locallyUpdatedAt': serializer.toJson<DateTime>(locallyUpdatedAt),
    };
  }

  LocalUser copyWith({
    int? id,
    String? name,
    String? email,
    Value<String?> avatarUrl = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    bool? isActive,
    Value<DateTime?> lastSeenAt = const Value.absent(),
    DateTime? locallyUpdatedAt,
  }) => LocalUser(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
    phone: phone.present ? phone.value : this.phone,
    isActive: isActive ?? this.isActive,
    lastSeenAt: lastSeenAt.present ? lastSeenAt.value : this.lastSeenAt,
    locallyUpdatedAt: locallyUpdatedAt ?? this.locallyUpdatedAt,
  );
  LocalUser copyWithCompanion(LocalUsersCompanion data) {
    return LocalUser(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      phone: data.phone.present ? data.phone.value : this.phone,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
      locallyUpdatedAt: data.locallyUpdatedAt.present
          ? data.locallyUpdatedAt.value
          : this.locallyUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalUser(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('phone: $phone, ')
          ..write('isActive: $isActive, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('locallyUpdatedAt: $locallyUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    email,
    avatarUrl,
    phone,
    isActive,
    lastSeenAt,
    locallyUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalUser &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.avatarUrl == this.avatarUrl &&
          other.phone == this.phone &&
          other.isActive == this.isActive &&
          other.lastSeenAt == this.lastSeenAt &&
          other.locallyUpdatedAt == this.locallyUpdatedAt);
}

class LocalUsersCompanion extends UpdateCompanion<LocalUser> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> email;
  final Value<String?> avatarUrl;
  final Value<String?> phone;
  final Value<bool> isActive;
  final Value<DateTime?> lastSeenAt;
  final Value<DateTime> locallyUpdatedAt;
  const LocalUsersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.phone = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.locallyUpdatedAt = const Value.absent(),
  });
  LocalUsersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String email,
    this.avatarUrl = const Value.absent(),
    this.phone = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.locallyUpdatedAt = const Value.absent(),
  }) : name = Value(name),
       email = Value(email);
  static Insertable<LocalUser> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? avatarUrl,
    Expression<String>? phone,
    Expression<bool>? isActive,
    Expression<DateTime>? lastSeenAt,
    Expression<DateTime>? locallyUpdatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (phone != null) 'phone': phone,
      if (isActive != null) 'is_active': isActive,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (locallyUpdatedAt != null) 'locally_updated_at': locallyUpdatedAt,
    });
  }

  LocalUsersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? email,
    Value<String?>? avatarUrl,
    Value<String?>? phone,
    Value<bool>? isActive,
    Value<DateTime?>? lastSeenAt,
    Value<DateTime>? locallyUpdatedAt,
  }) {
    return LocalUsersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      locallyUpdatedAt: locallyUpdatedAt ?? this.locallyUpdatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt.value);
    }
    if (locallyUpdatedAt.present) {
      map['locally_updated_at'] = Variable<DateTime>(locallyUpdatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalUsersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('phone: $phone, ')
          ..write('isActive: $isActive, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('locallyUpdatedAt: $locallyUpdatedAt')
          ..write(')'))
        .toString();
  }
}

class $LocalConversationParticipantsTable extends LocalConversationParticipants
    with
        TableInfo<
          $LocalConversationParticipantsTable,
          LocalConversationParticipant
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalConversationParticipantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<int> conversationId = GeneratedColumn<int>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _joinedAtMeta = const VerificationMeta(
    'joinedAt',
  );
  @override
  late final GeneratedColumn<DateTime> joinedAt = GeneratedColumn<DateTime>(
    'joined_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _leftAtMeta = const VerificationMeta('leftAt');
  @override
  late final GeneratedColumn<DateTime> leftAt = GeneratedColumn<DateTime>(
    'left_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locallyUpdatedAtMeta = const VerificationMeta(
    'locallyUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> locallyUpdatedAt =
      GeneratedColumn<DateTime>(
        'locally_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  @override
  List<GeneratedColumn> get $columns => [
    conversationId,
    userId,
    role,
    joinedAt,
    leftAt,
    locallyUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_conversation_participants';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalConversationParticipant> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('joined_at')) {
      context.handle(
        _joinedAtMeta,
        joinedAt.isAcceptableOrUnknown(data['joined_at']!, _joinedAtMeta),
      );
    }
    if (data.containsKey('left_at')) {
      context.handle(
        _leftAtMeta,
        leftAt.isAcceptableOrUnknown(data['left_at']!, _leftAtMeta),
      );
    }
    if (data.containsKey('locally_updated_at')) {
      context.handle(
        _locallyUpdatedAtMeta,
        locallyUpdatedAt.isAcceptableOrUnknown(
          data['locally_updated_at']!,
          _locallyUpdatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {conversationId, userId};
  @override
  LocalConversationParticipant map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalConversationParticipant(
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conversation_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      ),
      joinedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}joined_at'],
      ),
      leftAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}left_at'],
      ),
      locallyUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}locally_updated_at'],
      )!,
    );
  }

  @override
  $LocalConversationParticipantsTable createAlias(String alias) {
    return $LocalConversationParticipantsTable(attachedDatabase, alias);
  }
}

class LocalConversationParticipant extends DataClass
    implements Insertable<LocalConversationParticipant> {
  final int conversationId;
  final int userId;

  /// owner, admin, member
  final String? role;
  final DateTime? joinedAt;

  /// Null means active participant.
  /// Non-null means removed/left.
  final DateTime? leftAt;
  final DateTime locallyUpdatedAt;
  const LocalConversationParticipant({
    required this.conversationId,
    required this.userId,
    this.role,
    this.joinedAt,
    this.leftAt,
    required this.locallyUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['conversation_id'] = Variable<int>(conversationId);
    map['user_id'] = Variable<int>(userId);
    if (!nullToAbsent || role != null) {
      map['role'] = Variable<String>(role);
    }
    if (!nullToAbsent || joinedAt != null) {
      map['joined_at'] = Variable<DateTime>(joinedAt);
    }
    if (!nullToAbsent || leftAt != null) {
      map['left_at'] = Variable<DateTime>(leftAt);
    }
    map['locally_updated_at'] = Variable<DateTime>(locallyUpdatedAt);
    return map;
  }

  LocalConversationParticipantsCompanion toCompanion(bool nullToAbsent) {
    return LocalConversationParticipantsCompanion(
      conversationId: Value(conversationId),
      userId: Value(userId),
      role: role == null && nullToAbsent ? const Value.absent() : Value(role),
      joinedAt: joinedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(joinedAt),
      leftAt: leftAt == null && nullToAbsent
          ? const Value.absent()
          : Value(leftAt),
      locallyUpdatedAt: Value(locallyUpdatedAt),
    );
  }

  factory LocalConversationParticipant.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalConversationParticipant(
      conversationId: serializer.fromJson<int>(json['conversationId']),
      userId: serializer.fromJson<int>(json['userId']),
      role: serializer.fromJson<String?>(json['role']),
      joinedAt: serializer.fromJson<DateTime?>(json['joinedAt']),
      leftAt: serializer.fromJson<DateTime?>(json['leftAt']),
      locallyUpdatedAt: serializer.fromJson<DateTime>(json['locallyUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'conversationId': serializer.toJson<int>(conversationId),
      'userId': serializer.toJson<int>(userId),
      'role': serializer.toJson<String?>(role),
      'joinedAt': serializer.toJson<DateTime?>(joinedAt),
      'leftAt': serializer.toJson<DateTime?>(leftAt),
      'locallyUpdatedAt': serializer.toJson<DateTime>(locallyUpdatedAt),
    };
  }

  LocalConversationParticipant copyWith({
    int? conversationId,
    int? userId,
    Value<String?> role = const Value.absent(),
    Value<DateTime?> joinedAt = const Value.absent(),
    Value<DateTime?> leftAt = const Value.absent(),
    DateTime? locallyUpdatedAt,
  }) => LocalConversationParticipant(
    conversationId: conversationId ?? this.conversationId,
    userId: userId ?? this.userId,
    role: role.present ? role.value : this.role,
    joinedAt: joinedAt.present ? joinedAt.value : this.joinedAt,
    leftAt: leftAt.present ? leftAt.value : this.leftAt,
    locallyUpdatedAt: locallyUpdatedAt ?? this.locallyUpdatedAt,
  );
  LocalConversationParticipant copyWithCompanion(
    LocalConversationParticipantsCompanion data,
  ) {
    return LocalConversationParticipant(
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      userId: data.userId.present ? data.userId.value : this.userId,
      role: data.role.present ? data.role.value : this.role,
      joinedAt: data.joinedAt.present ? data.joinedAt.value : this.joinedAt,
      leftAt: data.leftAt.present ? data.leftAt.value : this.leftAt,
      locallyUpdatedAt: data.locallyUpdatedAt.present
          ? data.locallyUpdatedAt.value
          : this.locallyUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalConversationParticipant(')
          ..write('conversationId: $conversationId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('leftAt: $leftAt, ')
          ..write('locallyUpdatedAt: $locallyUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    conversationId,
    userId,
    role,
    joinedAt,
    leftAt,
    locallyUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalConversationParticipant &&
          other.conversationId == this.conversationId &&
          other.userId == this.userId &&
          other.role == this.role &&
          other.joinedAt == this.joinedAt &&
          other.leftAt == this.leftAt &&
          other.locallyUpdatedAt == this.locallyUpdatedAt);
}

class LocalConversationParticipantsCompanion
    extends UpdateCompanion<LocalConversationParticipant> {
  final Value<int> conversationId;
  final Value<int> userId;
  final Value<String?> role;
  final Value<DateTime?> joinedAt;
  final Value<DateTime?> leftAt;
  final Value<DateTime> locallyUpdatedAt;
  final Value<int> rowid;
  const LocalConversationParticipantsCompanion({
    this.conversationId = const Value.absent(),
    this.userId = const Value.absent(),
    this.role = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.leftAt = const Value.absent(),
    this.locallyUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalConversationParticipantsCompanion.insert({
    required int conversationId,
    required int userId,
    this.role = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.leftAt = const Value.absent(),
    this.locallyUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : conversationId = Value(conversationId),
       userId = Value(userId);
  static Insertable<LocalConversationParticipant> custom({
    Expression<int>? conversationId,
    Expression<int>? userId,
    Expression<String>? role,
    Expression<DateTime>? joinedAt,
    Expression<DateTime>? leftAt,
    Expression<DateTime>? locallyUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (conversationId != null) 'conversation_id': conversationId,
      if (userId != null) 'user_id': userId,
      if (role != null) 'role': role,
      if (joinedAt != null) 'joined_at': joinedAt,
      if (leftAt != null) 'left_at': leftAt,
      if (locallyUpdatedAt != null) 'locally_updated_at': locallyUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalConversationParticipantsCompanion copyWith({
    Value<int>? conversationId,
    Value<int>? userId,
    Value<String?>? role,
    Value<DateTime?>? joinedAt,
    Value<DateTime?>? leftAt,
    Value<DateTime>? locallyUpdatedAt,
    Value<int>? rowid,
  }) {
    return LocalConversationParticipantsCompanion(
      conversationId: conversationId ?? this.conversationId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      leftAt: leftAt ?? this.leftAt,
      locallyUpdatedAt: locallyUpdatedAt ?? this.locallyUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (conversationId.present) {
      map['conversation_id'] = Variable<int>(conversationId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (joinedAt.present) {
      map['joined_at'] = Variable<DateTime>(joinedAt.value);
    }
    if (leftAt.present) {
      map['left_at'] = Variable<DateTime>(leftAt.value);
    }
    if (locallyUpdatedAt.present) {
      map['locally_updated_at'] = Variable<DateTime>(locallyUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalConversationParticipantsCompanion(')
          ..write('conversationId: $conversationId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('leftAt: $leftAt, ')
          ..write('locallyUpdatedAt: $locallyUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalConversationsTable localConversations =
      $LocalConversationsTable(this);
  late final $LocalMessagesTable localMessages = $LocalMessagesTable(this);
  late final $LocalOutboxTable localOutbox = $LocalOutboxTable(this);
  late final $LocalSyncStateTable localSyncState = $LocalSyncStateTable(this);
  late final $LocalUsersTable localUsers = $LocalUsersTable(this);
  late final $LocalConversationParticipantsTable localConversationParticipants =
      $LocalConversationParticipantsTable(this);
  late final ChatLocalDao chatLocalDao = ChatLocalDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localConversations,
    localMessages,
    localOutbox,
    localSyncState,
    localUsers,
    localConversationParticipants,
  ];
}

typedef $$LocalConversationsTableCreateCompanionBuilder =
    LocalConversationsCompanion Function({
      Value<int> id,
      required String type,
      Value<String?> title,
      Value<String?> lastMessagePreview,
      Value<int?> lastMessageId,
      Value<int?> lastMessageSenderId,
      Value<DateTime?> lastMessageAt,
      Value<int> unreadCount,
      Value<String?> myRole,
      Value<DateTime?> updatedAt,
      Value<DateTime> locallyUpdatedAt,
    });
typedef $$LocalConversationsTableUpdateCompanionBuilder =
    LocalConversationsCompanion Function({
      Value<int> id,
      Value<String> type,
      Value<String?> title,
      Value<String?> lastMessagePreview,
      Value<int?> lastMessageId,
      Value<int?> lastMessageSenderId,
      Value<DateTime?> lastMessageAt,
      Value<int> unreadCount,
      Value<String?> myRole,
      Value<DateTime?> updatedAt,
      Value<DateTime> locallyUpdatedAt,
    });

class $$LocalConversationsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalConversationsTable> {
  $$LocalConversationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastMessagePreview => $composableBuilder(
    column: $table.lastMessagePreview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastMessageId => $composableBuilder(
    column: $table.lastMessageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastMessageSenderId => $composableBuilder(
    column: $table.lastMessageSenderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastMessageAt => $composableBuilder(
    column: $table.lastMessageAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get myRole => $composableBuilder(
    column: $table.myRole,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get locallyUpdatedAt => $composableBuilder(
    column: $table.locallyUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalConversationsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalConversationsTable> {
  $$LocalConversationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastMessagePreview => $composableBuilder(
    column: $table.lastMessagePreview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastMessageId => $composableBuilder(
    column: $table.lastMessageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastMessageSenderId => $composableBuilder(
    column: $table.lastMessageSenderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastMessageAt => $composableBuilder(
    column: $table.lastMessageAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get myRole => $composableBuilder(
    column: $table.myRole,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get locallyUpdatedAt => $composableBuilder(
    column: $table.locallyUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalConversationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalConversationsTable> {
  $$LocalConversationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get lastMessagePreview => $composableBuilder(
    column: $table.lastMessagePreview,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastMessageId => $composableBuilder(
    column: $table.lastMessageId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastMessageSenderId => $composableBuilder(
    column: $table.lastMessageSenderId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastMessageAt => $composableBuilder(
    column: $table.lastMessageAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get myRole =>
      $composableBuilder(column: $table.myRole, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get locallyUpdatedAt => $composableBuilder(
    column: $table.locallyUpdatedAt,
    builder: (column) => column,
  );
}

class $$LocalConversationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalConversationsTable,
          LocalConversation,
          $$LocalConversationsTableFilterComposer,
          $$LocalConversationsTableOrderingComposer,
          $$LocalConversationsTableAnnotationComposer,
          $$LocalConversationsTableCreateCompanionBuilder,
          $$LocalConversationsTableUpdateCompanionBuilder,
          (
            LocalConversation,
            BaseReferences<
              _$AppDatabase,
              $LocalConversationsTable,
              LocalConversation
            >,
          ),
          LocalConversation,
          PrefetchHooks Function()
        > {
  $$LocalConversationsTableTableManager(
    _$AppDatabase db,
    $LocalConversationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalConversationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalConversationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalConversationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> lastMessagePreview = const Value.absent(),
                Value<int?> lastMessageId = const Value.absent(),
                Value<int?> lastMessageSenderId = const Value.absent(),
                Value<DateTime?> lastMessageAt = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
                Value<String?> myRole = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime> locallyUpdatedAt = const Value.absent(),
              }) => LocalConversationsCompanion(
                id: id,
                type: type,
                title: title,
                lastMessagePreview: lastMessagePreview,
                lastMessageId: lastMessageId,
                lastMessageSenderId: lastMessageSenderId,
                lastMessageAt: lastMessageAt,
                unreadCount: unreadCount,
                myRole: myRole,
                updatedAt: updatedAt,
                locallyUpdatedAt: locallyUpdatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String type,
                Value<String?> title = const Value.absent(),
                Value<String?> lastMessagePreview = const Value.absent(),
                Value<int?> lastMessageId = const Value.absent(),
                Value<int?> lastMessageSenderId = const Value.absent(),
                Value<DateTime?> lastMessageAt = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
                Value<String?> myRole = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime> locallyUpdatedAt = const Value.absent(),
              }) => LocalConversationsCompanion.insert(
                id: id,
                type: type,
                title: title,
                lastMessagePreview: lastMessagePreview,
                lastMessageId: lastMessageId,
                lastMessageSenderId: lastMessageSenderId,
                lastMessageAt: lastMessageAt,
                unreadCount: unreadCount,
                myRole: myRole,
                updatedAt: updatedAt,
                locallyUpdatedAt: locallyUpdatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalConversationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalConversationsTable,
      LocalConversation,
      $$LocalConversationsTableFilterComposer,
      $$LocalConversationsTableOrderingComposer,
      $$LocalConversationsTableAnnotationComposer,
      $$LocalConversationsTableCreateCompanionBuilder,
      $$LocalConversationsTableUpdateCompanionBuilder,
      (
        LocalConversation,
        BaseReferences<
          _$AppDatabase,
          $LocalConversationsTable,
          LocalConversation
        >,
      ),
      LocalConversation,
      PrefetchHooks Function()
    >;
typedef $$LocalMessagesTableCreateCompanionBuilder =
    LocalMessagesCompanion Function({
      Value<int> localId,
      Value<int?> serverId,
      required int conversationId,
      required int senderId,
      required String body,
      Value<String> type,
      Value<String?> payloadJson,
      Value<String> status,
      Value<String?> clientMessageId,
      Value<int?> serverSequence,
      required DateTime createdAt,
      Value<DateTime?> serverReceivedAt,
      Value<DateTime?> deliveredAt,
      Value<DateTime?> readAt,
      Value<DateTime> locallyUpdatedAt,
    });
typedef $$LocalMessagesTableUpdateCompanionBuilder =
    LocalMessagesCompanion Function({
      Value<int> localId,
      Value<int?> serverId,
      Value<int> conversationId,
      Value<int> senderId,
      Value<String> body,
      Value<String> type,
      Value<String?> payloadJson,
      Value<String> status,
      Value<String?> clientMessageId,
      Value<int?> serverSequence,
      Value<DateTime> createdAt,
      Value<DateTime?> serverReceivedAt,
      Value<DateTime?> deliveredAt,
      Value<DateTime?> readAt,
      Value<DateTime> locallyUpdatedAt,
    });

class $$LocalMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalMessagesTable> {
  $$LocalMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientMessageId => $composableBuilder(
    column: $table.clientMessageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSequence => $composableBuilder(
    column: $table.serverSequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get serverReceivedAt => $composableBuilder(
    column: $table.serverReceivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deliveredAt => $composableBuilder(
    column: $table.deliveredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get locallyUpdatedAt => $composableBuilder(
    column: $table.locallyUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalMessagesTable> {
  $$LocalMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientMessageId => $composableBuilder(
    column: $table.clientMessageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSequence => $composableBuilder(
    column: $table.serverSequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get serverReceivedAt => $composableBuilder(
    column: $table.serverReceivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deliveredAt => $composableBuilder(
    column: $table.deliveredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get locallyUpdatedAt => $composableBuilder(
    column: $table.locallyUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalMessagesTable> {
  $$LocalMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<int> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get clientMessageId => $composableBuilder(
    column: $table.clientMessageId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverSequence => $composableBuilder(
    column: $table.serverSequence,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get serverReceivedAt => $composableBuilder(
    column: $table.serverReceivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deliveredAt => $composableBuilder(
    column: $table.deliveredAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);

  GeneratedColumn<DateTime> get locallyUpdatedAt => $composableBuilder(
    column: $table.locallyUpdatedAt,
    builder: (column) => column,
  );
}

class $$LocalMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalMessagesTable,
          LocalMessage,
          $$LocalMessagesTableFilterComposer,
          $$LocalMessagesTableOrderingComposer,
          $$LocalMessagesTableAnnotationComposer,
          $$LocalMessagesTableCreateCompanionBuilder,
          $$LocalMessagesTableUpdateCompanionBuilder,
          (
            LocalMessage,
            BaseReferences<_$AppDatabase, $LocalMessagesTable, LocalMessage>,
          ),
          LocalMessage,
          PrefetchHooks Function()
        > {
  $$LocalMessagesTableTableManager(_$AppDatabase db, $LocalMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<int> conversationId = const Value.absent(),
                Value<int> senderId = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> payloadJson = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> clientMessageId = const Value.absent(),
                Value<int?> serverSequence = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> serverReceivedAt = const Value.absent(),
                Value<DateTime?> deliveredAt = const Value.absent(),
                Value<DateTime?> readAt = const Value.absent(),
                Value<DateTime> locallyUpdatedAt = const Value.absent(),
              }) => LocalMessagesCompanion(
                localId: localId,
                serverId: serverId,
                conversationId: conversationId,
                senderId: senderId,
                body: body,
                type: type,
                payloadJson: payloadJson,
                status: status,
                clientMessageId: clientMessageId,
                serverSequence: serverSequence,
                createdAt: createdAt,
                serverReceivedAt: serverReceivedAt,
                deliveredAt: deliveredAt,
                readAt: readAt,
                locallyUpdatedAt: locallyUpdatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                required int conversationId,
                required int senderId,
                required String body,
                Value<String> type = const Value.absent(),
                Value<String?> payloadJson = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> clientMessageId = const Value.absent(),
                Value<int?> serverSequence = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> serverReceivedAt = const Value.absent(),
                Value<DateTime?> deliveredAt = const Value.absent(),
                Value<DateTime?> readAt = const Value.absent(),
                Value<DateTime> locallyUpdatedAt = const Value.absent(),
              }) => LocalMessagesCompanion.insert(
                localId: localId,
                serverId: serverId,
                conversationId: conversationId,
                senderId: senderId,
                body: body,
                type: type,
                payloadJson: payloadJson,
                status: status,
                clientMessageId: clientMessageId,
                serverSequence: serverSequence,
                createdAt: createdAt,
                serverReceivedAt: serverReceivedAt,
                deliveredAt: deliveredAt,
                readAt: readAt,
                locallyUpdatedAt: locallyUpdatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalMessagesTable,
      LocalMessage,
      $$LocalMessagesTableFilterComposer,
      $$LocalMessagesTableOrderingComposer,
      $$LocalMessagesTableAnnotationComposer,
      $$LocalMessagesTableCreateCompanionBuilder,
      $$LocalMessagesTableUpdateCompanionBuilder,
      (
        LocalMessage,
        BaseReferences<_$AppDatabase, $LocalMessagesTable, LocalMessage>,
      ),
      LocalMessage,
      PrefetchHooks Function()
    >;
typedef $$LocalOutboxTableCreateCompanionBuilder =
    LocalOutboxCompanion Function({
      Value<int> id,
      required int conversationId,
      required String clientMessageId,
      required String body,
      Value<String> status,
      Value<int> attemptCount,
      Value<String?> lastError,
      Value<DateTime?> nextRetryAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$LocalOutboxTableUpdateCompanionBuilder =
    LocalOutboxCompanion Function({
      Value<int> id,
      Value<int> conversationId,
      Value<String> clientMessageId,
      Value<String> body,
      Value<String> status,
      Value<int> attemptCount,
      Value<String?> lastError,
      Value<DateTime?> nextRetryAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$LocalOutboxTableFilterComposer
    extends Composer<_$AppDatabase, $LocalOutboxTable> {
  $$LocalOutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientMessageId => $composableBuilder(
    column: $table.clientMessageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
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

class $$LocalOutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalOutboxTable> {
  $$LocalOutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientMessageId => $composableBuilder(
    column: $table.clientMessageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
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

class $$LocalOutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalOutboxTable> {
  $$LocalOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get clientMessageId => $composableBuilder(
    column: $table.clientMessageId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalOutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalOutboxTable,
          LocalOutboxData,
          $$LocalOutboxTableFilterComposer,
          $$LocalOutboxTableOrderingComposer,
          $$LocalOutboxTableAnnotationComposer,
          $$LocalOutboxTableCreateCompanionBuilder,
          $$LocalOutboxTableUpdateCompanionBuilder,
          (
            LocalOutboxData,
            BaseReferences<_$AppDatabase, $LocalOutboxTable, LocalOutboxData>,
          ),
          LocalOutboxData,
          PrefetchHooks Function()
        > {
  $$LocalOutboxTableTableManager(_$AppDatabase db, $LocalOutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> conversationId = const Value.absent(),
                Value<String> clientMessageId = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime?> nextRetryAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => LocalOutboxCompanion(
                id: id,
                conversationId: conversationId,
                clientMessageId: clientMessageId,
                body: body,
                status: status,
                attemptCount: attemptCount,
                lastError: lastError,
                nextRetryAt: nextRetryAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int conversationId,
                required String clientMessageId,
                required String body,
                Value<String> status = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime?> nextRetryAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => LocalOutboxCompanion.insert(
                id: id,
                conversationId: conversationId,
                clientMessageId: clientMessageId,
                body: body,
                status: status,
                attemptCount: attemptCount,
                lastError: lastError,
                nextRetryAt: nextRetryAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalOutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalOutboxTable,
      LocalOutboxData,
      $$LocalOutboxTableFilterComposer,
      $$LocalOutboxTableOrderingComposer,
      $$LocalOutboxTableAnnotationComposer,
      $$LocalOutboxTableCreateCompanionBuilder,
      $$LocalOutboxTableUpdateCompanionBuilder,
      (
        LocalOutboxData,
        BaseReferences<_$AppDatabase, $LocalOutboxTable, LocalOutboxData>,
      ),
      LocalOutboxData,
      PrefetchHooks Function()
    >;
typedef $$LocalSyncStateTableCreateCompanionBuilder =
    LocalSyncStateCompanion Function({
      required String key,
      Value<String?> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$LocalSyncStateTableUpdateCompanionBuilder =
    LocalSyncStateCompanion Function({
      Value<String> key,
      Value<String?> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalSyncStateTableFilterComposer
    extends Composer<_$AppDatabase, $LocalSyncStateTable> {
  $$LocalSyncStateTableFilterComposer({
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
}

class $$LocalSyncStateTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalSyncStateTable> {
  $$LocalSyncStateTableOrderingComposer({
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
}

class $$LocalSyncStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalSyncStateTable> {
  $$LocalSyncStateTableAnnotationComposer({
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
}

class $$LocalSyncStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalSyncStateTable,
          LocalSyncStateData,
          $$LocalSyncStateTableFilterComposer,
          $$LocalSyncStateTableOrderingComposer,
          $$LocalSyncStateTableAnnotationComposer,
          $$LocalSyncStateTableCreateCompanionBuilder,
          $$LocalSyncStateTableUpdateCompanionBuilder,
          (
            LocalSyncStateData,
            BaseReferences<
              _$AppDatabase,
              $LocalSyncStateTable,
              LocalSyncStateData
            >,
          ),
          LocalSyncStateData,
          PrefetchHooks Function()
        > {
  $$LocalSyncStateTableTableManager(
    _$AppDatabase db,
    $LocalSyncStateTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalSyncStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalSyncStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalSyncStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String?> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSyncStateCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                Value<String?> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSyncStateCompanion.insert(
                key: key,
                value: value,
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

typedef $$LocalSyncStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalSyncStateTable,
      LocalSyncStateData,
      $$LocalSyncStateTableFilterComposer,
      $$LocalSyncStateTableOrderingComposer,
      $$LocalSyncStateTableAnnotationComposer,
      $$LocalSyncStateTableCreateCompanionBuilder,
      $$LocalSyncStateTableUpdateCompanionBuilder,
      (
        LocalSyncStateData,
        BaseReferences<_$AppDatabase, $LocalSyncStateTable, LocalSyncStateData>,
      ),
      LocalSyncStateData,
      PrefetchHooks Function()
    >;
typedef $$LocalUsersTableCreateCompanionBuilder =
    LocalUsersCompanion Function({
      Value<int> id,
      required String name,
      required String email,
      Value<String?> avatarUrl,
      Value<String?> phone,
      Value<bool> isActive,
      Value<DateTime?> lastSeenAt,
      Value<DateTime> locallyUpdatedAt,
    });
typedef $$LocalUsersTableUpdateCompanionBuilder =
    LocalUsersCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> email,
      Value<String?> avatarUrl,
      Value<String?> phone,
      Value<bool> isActive,
      Value<DateTime?> lastSeenAt,
      Value<DateTime> locallyUpdatedAt,
    });

class $$LocalUsersTableFilterComposer
    extends Composer<_$AppDatabase, $LocalUsersTable> {
  $$LocalUsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get locallyUpdatedAt => $composableBuilder(
    column: $table.locallyUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalUsersTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalUsersTable> {
  $$LocalUsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get locallyUpdatedAt => $composableBuilder(
    column: $table.locallyUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalUsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalUsersTable> {
  $$LocalUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get locallyUpdatedAt => $composableBuilder(
    column: $table.locallyUpdatedAt,
    builder: (column) => column,
  );
}

class $$LocalUsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalUsersTable,
          LocalUser,
          $$LocalUsersTableFilterComposer,
          $$LocalUsersTableOrderingComposer,
          $$LocalUsersTableAnnotationComposer,
          $$LocalUsersTableCreateCompanionBuilder,
          $$LocalUsersTableUpdateCompanionBuilder,
          (
            LocalUser,
            BaseReferences<_$AppDatabase, $LocalUsersTable, LocalUser>,
          ),
          LocalUser,
          PrefetchHooks Function()
        > {
  $$LocalUsersTableTableManager(_$AppDatabase db, $LocalUsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime?> lastSeenAt = const Value.absent(),
                Value<DateTime> locallyUpdatedAt = const Value.absent(),
              }) => LocalUsersCompanion(
                id: id,
                name: name,
                email: email,
                avatarUrl: avatarUrl,
                phone: phone,
                isActive: isActive,
                lastSeenAt: lastSeenAt,
                locallyUpdatedAt: locallyUpdatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String email,
                Value<String?> avatarUrl = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime?> lastSeenAt = const Value.absent(),
                Value<DateTime> locallyUpdatedAt = const Value.absent(),
              }) => LocalUsersCompanion.insert(
                id: id,
                name: name,
                email: email,
                avatarUrl: avatarUrl,
                phone: phone,
                isActive: isActive,
                lastSeenAt: lastSeenAt,
                locallyUpdatedAt: locallyUpdatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalUsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalUsersTable,
      LocalUser,
      $$LocalUsersTableFilterComposer,
      $$LocalUsersTableOrderingComposer,
      $$LocalUsersTableAnnotationComposer,
      $$LocalUsersTableCreateCompanionBuilder,
      $$LocalUsersTableUpdateCompanionBuilder,
      (LocalUser, BaseReferences<_$AppDatabase, $LocalUsersTable, LocalUser>),
      LocalUser,
      PrefetchHooks Function()
    >;
typedef $$LocalConversationParticipantsTableCreateCompanionBuilder =
    LocalConversationParticipantsCompanion Function({
      required int conversationId,
      required int userId,
      Value<String?> role,
      Value<DateTime?> joinedAt,
      Value<DateTime?> leftAt,
      Value<DateTime> locallyUpdatedAt,
      Value<int> rowid,
    });
typedef $$LocalConversationParticipantsTableUpdateCompanionBuilder =
    LocalConversationParticipantsCompanion Function({
      Value<int> conversationId,
      Value<int> userId,
      Value<String?> role,
      Value<DateTime?> joinedAt,
      Value<DateTime?> leftAt,
      Value<DateTime> locallyUpdatedAt,
      Value<int> rowid,
    });

class $$LocalConversationParticipantsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalConversationParticipantsTable> {
  $$LocalConversationParticipantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get leftAt => $composableBuilder(
    column: $table.leftAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get locallyUpdatedAt => $composableBuilder(
    column: $table.locallyUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalConversationParticipantsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalConversationParticipantsTable> {
  $$LocalConversationParticipantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get leftAt => $composableBuilder(
    column: $table.leftAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get locallyUpdatedAt => $composableBuilder(
    column: $table.locallyUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalConversationParticipantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalConversationParticipantsTable> {
  $$LocalConversationParticipantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<DateTime> get joinedAt =>
      $composableBuilder(column: $table.joinedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get leftAt =>
      $composableBuilder(column: $table.leftAt, builder: (column) => column);

  GeneratedColumn<DateTime> get locallyUpdatedAt => $composableBuilder(
    column: $table.locallyUpdatedAt,
    builder: (column) => column,
  );
}

class $$LocalConversationParticipantsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalConversationParticipantsTable,
          LocalConversationParticipant,
          $$LocalConversationParticipantsTableFilterComposer,
          $$LocalConversationParticipantsTableOrderingComposer,
          $$LocalConversationParticipantsTableAnnotationComposer,
          $$LocalConversationParticipantsTableCreateCompanionBuilder,
          $$LocalConversationParticipantsTableUpdateCompanionBuilder,
          (
            LocalConversationParticipant,
            BaseReferences<
              _$AppDatabase,
              $LocalConversationParticipantsTable,
              LocalConversationParticipant
            >,
          ),
          LocalConversationParticipant,
          PrefetchHooks Function()
        > {
  $$LocalConversationParticipantsTableTableManager(
    _$AppDatabase db,
    $LocalConversationParticipantsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalConversationParticipantsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalConversationParticipantsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalConversationParticipantsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> conversationId = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<String?> role = const Value.absent(),
                Value<DateTime?> joinedAt = const Value.absent(),
                Value<DateTime?> leftAt = const Value.absent(),
                Value<DateTime> locallyUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalConversationParticipantsCompanion(
                conversationId: conversationId,
                userId: userId,
                role: role,
                joinedAt: joinedAt,
                leftAt: leftAt,
                locallyUpdatedAt: locallyUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int conversationId,
                required int userId,
                Value<String?> role = const Value.absent(),
                Value<DateTime?> joinedAt = const Value.absent(),
                Value<DateTime?> leftAt = const Value.absent(),
                Value<DateTime> locallyUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalConversationParticipantsCompanion.insert(
                conversationId: conversationId,
                userId: userId,
                role: role,
                joinedAt: joinedAt,
                leftAt: leftAt,
                locallyUpdatedAt: locallyUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalConversationParticipantsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalConversationParticipantsTable,
      LocalConversationParticipant,
      $$LocalConversationParticipantsTableFilterComposer,
      $$LocalConversationParticipantsTableOrderingComposer,
      $$LocalConversationParticipantsTableAnnotationComposer,
      $$LocalConversationParticipantsTableCreateCompanionBuilder,
      $$LocalConversationParticipantsTableUpdateCompanionBuilder,
      (
        LocalConversationParticipant,
        BaseReferences<
          _$AppDatabase,
          $LocalConversationParticipantsTable,
          LocalConversationParticipant
        >,
      ),
      LocalConversationParticipant,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalConversationsTableTableManager get localConversations =>
      $$LocalConversationsTableTableManager(_db, _db.localConversations);
  $$LocalMessagesTableTableManager get localMessages =>
      $$LocalMessagesTableTableManager(_db, _db.localMessages);
  $$LocalOutboxTableTableManager get localOutbox =>
      $$LocalOutboxTableTableManager(_db, _db.localOutbox);
  $$LocalSyncStateTableTableManager get localSyncState =>
      $$LocalSyncStateTableTableManager(_db, _db.localSyncState);
  $$LocalUsersTableTableManager get localUsers =>
      $$LocalUsersTableTableManager(_db, _db.localUsers);
  $$LocalConversationParticipantsTableTableManager
  get localConversationParticipants =>
      $$LocalConversationParticipantsTableTableManager(
        _db,
        _db.localConversationParticipants,
      );
}
