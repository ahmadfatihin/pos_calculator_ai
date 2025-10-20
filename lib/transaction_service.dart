import 'dart:convert';
import 'package:flutter/services.dart';

class Transaction {
  final String id;
  final String time;
  final int total;
  final String paymentMethod;
  final DateTime date;

  Transaction({
    required this.id,
    required this.time,
    required this.total,
    required this.paymentMethod,
    required this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      time: json['time'],
      total: json['total'],
      paymentMethod: json['paymentMethod'],
      date: DateTime.parse(json['date']),
    );
  }
}

class TransactionService {
  static List<Transaction>? _cachedTransactions;

  static Future<List<Transaction>> loadTransactions() async {
    if (_cachedTransactions != null) {
      return _cachedTransactions!;
    }

    try {
      final String jsonString =
          await rootBundle.loadString('assets/dummy_transactions.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> transactionList = jsonData['transactions'];

      _cachedTransactions =
          transactionList.map((json) => Transaction.fromJson(json)).toList();

      return _cachedTransactions!;
    } catch (e) {
      print('Error loading transactions: $e');
      return [];
    }
  }

  static List<Transaction> filterTransactions(
      List<Transaction> transactions, String filter) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (filter) {
      case 'Today':
        return transactions.where((t) {
          final transactionDate =
              DateTime(t.date.year, t.date.month, t.date.day);
          return transactionDate.isAtSameMomentAs(today);
        }).toList();

      case '7 Days':
        final sevenDaysAgo = today.subtract(const Duration(days: 6));
        return transactions.where((t) {
          final transactionDate =
              DateTime(t.date.year, t.date.month, t.date.day);
          return transactionDate
                  .isAfter(sevenDaysAgo.subtract(const Duration(days: 1))) &&
              transactionDate.isBefore(today.add(const Duration(days: 1)));
        }).toList();

      case '30 Days':
        final thirtyDaysAgo = today.subtract(const Duration(days: 29));
        return transactions.where((t) {
          final transactionDate =
              DateTime(t.date.year, t.date.month, t.date.day);
          return transactionDate
                  .isAfter(thirtyDaysAgo.subtract(const Duration(days: 1))) &&
              transactionDate.isBefore(today.add(const Duration(days: 1)));
        }).toList();

      case 'Custom':
        // For now, return last 60 days. In real app, you'd show date picker
        final sixtyDaysAgo = today.subtract(const Duration(days: 59));
        return transactions.where((t) {
          final transactionDate =
              DateTime(t.date.year, t.date.month, t.date.day);
          return transactionDate
                  .isAfter(sixtyDaysAgo.subtract(const Duration(days: 1))) &&
              transactionDate.isBefore(today.add(const Duration(days: 1)));
        }).toList();

      default:
        return transactions;
    }
  }

  static Map<String, dynamic> getFilterStats(
      List<Transaction> transactions, String filter) {
    final filteredTransactions = filterTransactions(transactions, filter);
    final totalAmount =
        filteredTransactions.fold<int>(0, (sum, t) => sum + t.total);
    final transactionCount = filteredTransactions.length;

    return {
      'totalAmount': totalAmount,
      'transactionCount': transactionCount,
      'averageAmount':
          transactionCount > 0 ? (totalAmount / transactionCount).round() : 0,
    };
  }
}
