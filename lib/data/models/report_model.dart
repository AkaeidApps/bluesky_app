import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String reporterId;
  final String targetType; // 'post', 'user'
  final String targetId;
  final String
  reason; // 'spam', 'harassment', 'hate_speech', 'misinformation', 'other'
  final String notes;
  final DateTime createdAt;
  final String status; // 'pending', 'resolved', 'dismissed'

  const ReportModel({
    required this.id,
    required this.reporterId,
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.notes = '',
    required this.createdAt,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'reporterId': reporterId,
    'targetType': targetType,
    'targetId': targetId,
    'reason': reason,
    'notes': notes,
    'createdAt': Timestamp.fromDate(createdAt),
    'status': status,
  };

  factory ReportModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime parseDate(dynamic date) {
      if (date is Timestamp) return date.toDate();
      if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
      return DateTime.now();
    }

    return ReportModel(
      id: docId ?? map['id'] ?? '',
      reporterId: map['reporterId'] ?? '',
      targetType: map['targetType'] ?? 'post',
      targetId: map['targetId'] ?? '',
      reason: map['reason'] ?? 'spam',
      notes: map['notes'] ?? '',
      createdAt: parseDate(map['createdAt']),
      status: map['status'] ?? 'pending',
    );
  }
}
