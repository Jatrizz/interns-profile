import 'package:flutter/material.dart';
import '../widgets/Developer-Page-Widgets/janna_id_card.dart';
import '../widgets/Developer-Page-Widgets/nathaniel_id_card.dart';
import '../widgets/Developer-Page-Widgets/lester_card.dart';
import '../utils/responsive.dart';

class DeveloperTeamPage extends StatelessWidget {
  final bool isDarkMode;
  const DeveloperTeamPage({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);

    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor =
        isDarkMode ? Colors.white.withOpacity(0.35) : Colors.black45;
    final labelColor =
        isDarkMode ? Colors.white.withOpacity(0.30) : Colors.black38;
    final dividerColor =
        isDarkMode ? Colors.white.withOpacity(0.08) : Colors.black12;
    final dotColor = const Color(0xFF3b82f6);
    final lineColor = const Color(0xFF3b82f6).withOpacity(0.4);
    final footerColor =
        isDarkMode ? Colors.white.withOpacity(0.15) : Colors.black26;

    // Scale cards down on smaller screens
    final cardScale = isMobile ? 0.75 : (isTablet ? 0.88 : 1.0);

    Widget _scaledCard(Widget card) => Transform.scale(
          scale: cardScale,
          child: card,
        );

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      child: Stack(
        children: [
          // Background glow circles
          Positioned(
            top: -100,
            left: -80,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1d4ed8)
                    .withOpacity(isDarkMode ? 0.08 : 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            right: -100,
            child: Container(
              width: 450,
              height: 450,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3b82f6)
                    .withOpacity(isDarkMode ? 0.06 : 0.04),
              ),
            ),
          ),
          Positioned(
            top: 80,
            right: 60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF60a5fa)
                    .withOpacity(isDarkMode ? 0.04 : 0.03),
              ),
            ),
          ),

          // Content
          Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.fromLTRB(isMobile ? 20 : 40,
                    isMobile ? 24 : 40, isMobile ? 20 : 40, 0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 40, height: 1, color: lineColor),
                        const SizedBox(width: 14),
                        Flexible(
                          child: Text(
                            'FDS ASYA PHILIPPINES INC. INTERNS',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 0.15,
                              color: labelColor,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Container(width: 40, height: 1, color: lineColor),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Meet the Dev Team',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isMobile ? 24 : 34,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'The people who designed and built this system',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: subTextColor,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 70, height: 0.5, color: dividerColor),
                        const SizedBox(width: 10),
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: dotColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(width: 70, height: 0.5, color: dividerColor),
                      ],
                    ),
                  ],
                ),
              ),

              // Cards
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 60,
                    vertical: isMobile ? 16 : 36,
                  ),
                  child: isMobile
                      // Mobile: stacked column, centered
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _scaledCard(const LesterCard()),
                            SizedBox(height: isMobile ? 0 : 24),
                            _scaledCard(const JannaIDCard()),
                            SizedBox(height: isMobile ? 0 : 24),
                            _scaledCard(const NathanielIDCard()),
                          ],
                        )
                      // Tablet/Desktop: row
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: Center(
                                    child: _scaledCard(const LesterCard()))),
                            SizedBox(width: isTablet ? 20 : 60),
                            Center(child: _scaledCard(const JannaIDCard())),
                            SizedBox(width: isTablet ? 20 : 60),
                            Expanded(
                                child: Center(
                                    child:
                                        _scaledCard(const NathanielIDCard()))),
                          ],
                        ),
                ),
              ),

              // Footer
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  isMobile
                      ? 'Tap a card to interact'
                      : 'Hover over a card to interact  ·  Click to view full profile',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: footerColor,
                    letterSpacing: 0.05,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
