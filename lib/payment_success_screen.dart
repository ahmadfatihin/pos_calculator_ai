import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_calculator_ai/app_pallete.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final int totalAmount;
  final int changeAmount;
  final String paymentMethod;
  final String transactionId;

  const PaymentSuccessScreen({
    Key? key,
    required this.totalAmount,
    required this.changeAmount,
    required this.paymentMethod,
    required this.transactionId,
  }) : super(key: key);

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentDate = DateFormat('dd MMM yyyy').format(DateTime.now());

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppPalette.headerGradient),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),

                      // Success Icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check,
                          color: AppPalette.green800,
                          size: 50,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Changes Label
                      const Text(
                        'Changes:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Payment Successful
                      const Text(
                        'Payment Successful',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Change Amount
                      Text(
                        'Rp. ${_formatCurrency(changeAmount)}',
                        style: const TextStyle(
                          fontSize: 48,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Transaction Details Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildDetailRow(
                              'Total',
                              'Rp ${_formatCurrency(totalAmount)}',
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow('Transaction ID', transactionId),
                            const SizedBox(height: 16),
                            _buildDetailRow('Payment Method', paymentMethod),
                            const SizedBox(height: 16),
                            _buildDetailRow('Date', currentDate),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Back to Calculator Button
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      // Navigate back to calculator and clear all previous screens
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppPalette.green800,
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Back to Calculator',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.green800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white70,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
