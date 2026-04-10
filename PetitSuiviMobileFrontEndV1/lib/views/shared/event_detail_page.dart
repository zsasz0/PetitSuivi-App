import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:newv/app_theme.dart';
import 'package:newv/theme_manager.dart';
import 'package:newv/theme_colors.dart';

class EventDetailPage extends StatelessWidget {
  final Map<String, dynamic> eventData;

  const EventDetailPage({super.key, required this.eventData});

  static Color get _baseDark => ThemeManager.instance.isLightMode
      ? const Color(0xFFF0F2F5)
      : const Color(0xFF141B2D);
  static Color get _tealAccent => ThemeManager.instance.isLightMode
      ? const Color(0xFF009688)
      : const Color(0xFF4CCEAC);
  static Color get _indigoAccent => ThemeManager.instance.isLightMode
      ? const Color(0xFF3F51B5)
      : const Color(0xFF6870FA);
  static Color get _lightText => ThemeManager.instance.isLightMode
      ? const Color(0xFF212529)
      : const Color(0xFFF2F0F0);
  static Color get _mutedText => ThemeManager.instance.isLightMode
      ? const Color(0xFF6C757D)
      : const Color(0xFFA1A4AB);

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeManager>();
    final name = eventData['event_name'] ?? eventData['name'] ?? 'Événement';
    final description =
        eventData['event_description'] ?? eventData['description'] ?? '';
    final date = eventData['event_date'] ?? eventData['date'] ?? '';
    final startTime =
        eventData['event_start_time'] ?? eventData['start_time'] ?? '';
    final endTime = eventData['event_end_time'] ?? eventData['end_time'] ?? '';

    String formattedDate = date;
    if (date.isNotEmpty) {
      try {
        final parsed = DateTime.parse(date);
        formattedDate =
            '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
      } catch (_) {}
    }

    String formattedStart = startTime.length >= 5
        ? startTime.substring(0, 5)
        : startTime;
    String formattedEnd = endTime.length >= 5
        ? endTime.substring(0, 5)
        : endTime;

    return Container(
      color: _baseDark,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Détails de l\'événement',
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: _lightText,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: _lightText),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event icon and name
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _tealAccent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _tealAccent.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(Icons.event, color: _tealAccent, size: 48),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTheme.fontName,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _lightText,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Date & Time card
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: ThemeColors.glassBorderSubtle,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ThemeColors.glassBorder),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          Icons.calendar_today,
                          'Date',
                          formattedDate,
                        ),
                        if (formattedStart.isNotEmpty ||
                            formattedEnd.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Divider(color: Color(0xFF2A2F4A), height: 1),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            Icons.access_time,
                            'Horaire',
                            '$formattedStart — $formattedEnd',
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // Description card
              if (description.isNotEmpty) ...[
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: ThemeColors.glassBorderSubtle,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: ThemeColors.glassBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.description_outlined,
                                color: _indigoAccent,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Description',
                                style: TextStyle(
                                  fontFamily: AppTheme.fontName,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: _indigoAccent,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            description,
                            style: TextStyle(
                              fontFamily: AppTheme.fontName,
                              fontSize: 15,
                              color: _lightText.withValues(alpha: 0.9),
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: _tealAccent, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.fontName,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _mutedText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontFamily: AppTheme.fontName,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _lightText,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
