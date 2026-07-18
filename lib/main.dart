import 'dart:ui';
import 'package:flutter/material.dart';

void main() => runApp(const HilmApp());

class AppColors {
  static const green = Color(0xFF0D6B4E);
  static const greenDark = Color(0xFF064735);
  static const greenSoft = Color(0xFFE9F4EF);
  static const gold = Color(0xFFD5A84A);
  static const cream = Color(0xFFFBF8F0);
  static const cream2 = Color(0xFFF4EBDC);
  static const ink = Color(0xFF10231C);
  static const muted = Color(0xFF66736D);
  static const border = Color(0xFFE4E8E5);
  static const white = Colors.white;
}

enum AppLanguage { en, ur, de, ar }

extension AppLanguageX on AppLanguage {
  String get code => switch (this) {
        AppLanguage.en => 'EN',
        AppLanguage.ur => 'UR',
        AppLanguage.de => 'DE',
        AppLanguage.ar => 'AR',
      };
  String get label => switch (this) {
        AppLanguage.en => 'English',
        AppLanguage.ur => 'اردو',
        AppLanguage.de => 'Deutsch',
        AppLanguage.ar => 'العربية',
      };
  bool get rtl => this == AppLanguage.ur || this == AppLanguage.ar;
}

class T {
  static String pick(AppLanguage lang, String en, String ur, String de, String ar) {
    return switch (lang) {
      AppLanguage.en => en,
      AppLanguage.ur => ur,
      AppLanguage.de => de,
      AppLanguage.ar => ar,
    };
  }
}

class SiteRoute {
  final String id;
  final String section;
  const SiteRoute(this.id, this.section);
}

class HilmApp extends StatefulWidget {
  const HilmApp({super.key});

  @override
  State<HilmApp> createState() => _HilmAppState();
}

class _HilmAppState extends State<HilmApp> {
  AppLanguage language = AppLanguage.en;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HILM Institute',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.cream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.green,
          primary: AppColors.green,
        ),
        fontFamily: 'Segoe UI',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink),
          displayMedium: TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink),
          headlineLarge: TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink),
          headlineMedium: TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink),
          titleLarge: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink),
          bodyLarge: TextStyle(height: 1.65, color: AppColors.muted),
          bodyMedium: TextStyle(height: 1.55, color: AppColors.muted),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.green, width: 1.5),
          ),
        ),
      ),
      home: Directionality(
        textDirection: language.rtl ? TextDirection.rtl : TextDirection.ltr,
        child: HilmWebsite(
          language: language,
          onLanguageChanged: (value) => setState(() => language = value),
        ),
      ),
    );
  }
}

class HilmWebsite extends StatefulWidget {
  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;

  const HilmWebsite({
    super.key,
    required this.language,
    required this.onLanguageChanged,
  });

  @override
  State<HilmWebsite> createState() => _HilmWebsiteState();
}

class _HilmWebsiteState extends State<HilmWebsite> {
  SiteRoute route = const SiteRoute('home', 'home');
  bool mobileMenu = false;
  bool showCookie = true;
  bool chatOpen = false;
  final ScrollController _scrollController = ScrollController();

  AppLanguage get lang => widget.language;

  void go(String id, [String section = '']) {
    setState(() {
      route = SiteRoute(id, section);
      mobileMenu = false;
    });
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              SiteHeader(
                lang: lang,
                currentRoute: route.id,
                mobileMenu: mobileMenu,
                onToggleMobile: () => setState(() => mobileMenu = !mobileMenu),
                onNavigate: go,
                onLanguageChanged: widget.onLanguageChanged,
                onTrial: () => showTrialDialog(context, lang),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: KeyedSubtree(
                          key: ValueKey('${route.id}-${route.section}-${lang.code}'),
                          child: _buildPage(),
                        ),
                      ),
                      SiteFooter(lang: lang, onNavigate: go),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (mobileMenu)
            Positioned(
              top: 76,
              left: 0,
              right: 0,
              child: MobileNavPanel(
                lang: lang,
                onNavigate: go,
                onClose: () => setState(() => mobileMenu = false),
              ),
            ),
          Positioned(
            right: lang.rtl ? null : 24,
            left: lang.rtl ? 24 : null,
            bottom: 24,
            child: FloatingActionButton.extended(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              onPressed: () => setState(() => chatOpen = !chatOpen),
              icon: const Icon(Icons.smart_toy_outlined),
              label: Text(T.pick(lang, 'Ask HILM', 'HILM سے پوچھیں', 'HILM fragen', 'اسأل HILM')),
            ),
          ),
          if (chatOpen)
            Positioned(
              right: lang.rtl ? null : 24,
              left: lang.rtl ? 24 : null,
              bottom: 92,
              child: AiChatCard(
                lang: lang,
                onClose: () => setState(() => chatOpen = false),
              ),
            ),
          if (showCookie)
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: CookieBanner(
                lang: lang,
                onAccept: () => setState(() => showCookie = false),
                onPolicy: () {
                  setState(() {
                    showCookie = false;
                    route = const SiteRoute('legal', 'cookie');
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPage() {
    switch (route.id) {
      case 'about':
        return AboutPage(lang: lang, section: route.section);
      case 'programs':
        return ProgramsPage(lang: lang, section: route.section, onTrial: () => showTrialDialog(context, lang));
      case 'countries':
        return CountriesPage(lang: lang, section: route.section);
      case 'teachers':
        return TeachersPage(lang: lang, section: route.section);
      case 'student':
        return StudentPortalPage(lang: lang, section: route.section);
      case 'parent':
        return ParentPortalPage(lang: lang, section: route.section);
      case 'community':
        return CommunityPage(lang: lang, section: route.section);
      case 'media':
        return MediaPage(lang: lang, section: route.section);
      case 'donate':
        return DonatePage(lang: lang, section: route.section);
      case 'contact':
        return ContactPage(lang: lang, section: route.section);
      case 'legal':
        return LegalPage(lang: lang, section: route.section);
      default:
        return HomePage(
          lang: lang,
          onNavigate: go,
          onTrial: () => showTrialDialog(context, lang),
        );
    }
  }
}

class SiteHeader extends StatelessWidget {
  final AppLanguage lang;
  final String currentRoute;
  final bool mobileMenu;
  final VoidCallback onToggleMobile;
  final void Function(String id, [String section]) onNavigate;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final VoidCallback onTrial;

  const SiteHeader({
    super.key,
    required this.lang,
    required this.currentRoute,
    required this.mobileMenu,
    required this.onToggleMobile,
    required this.onNavigate,
    required this.onLanguageChanged,
    required this.onTrial,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1,
      color: Colors.white.withOpacity(.97),
      child: SizedBox(
        height: 76,
        child: MaxWidth(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: LayoutBuilder(
              builder: (context, c) {
                final compact = c.maxWidth < 1180;
                return Row(
                  children: [
                    InkWell(
                      onTap: () => onNavigate('home'),
                      borderRadius: BorderRadius.circular(14),
                      child: const BrandMark(),
                    ),
                    const Spacer(),
                    if (!compact) ...[
                      NavButton(label: T.pick(lang, 'Home', 'ہوم', 'Start', 'الرئيسية'), onTap: () => onNavigate('home')),
                      NavPopup(
                        label: T.pick(lang, 'About', 'ہمارے بارے میں', 'Über uns', 'من نحن'),
                        items: aboutMenu(lang),
                        onSelected: (s) => onNavigate('about', s),
                      ),
                      NavPopup(
                        label: T.pick(lang, 'Programs', 'پروگرامز', 'Programme', 'البرامج'),
                        items: programMenu(lang),
                        onSelected: (s) => onNavigate('programs', s),
                      ),
                      NavPopup(
                        label: T.pick(lang, 'Countries', 'ممالک', 'Länder', 'الدول'),
                        items: countryMenu(lang),
                        onSelected: (s) => onNavigate('countries', s),
                      ),
                      NavButton(label: T.pick(lang, 'Teachers', 'اساتذہ', 'Lehrkräfte', 'المعلمون'), onTap: () => onNavigate('teachers')),
                      NavPopup(
                        label: T.pick(lang, 'Portals', 'پورٹلز', 'Portale', 'البوابات'),
                        items: [
                          MenuEntry('student', T.pick(lang, 'Student Portal', 'اسٹوڈنٹ پورٹل', 'Schülerportal', 'بوابة الطالب')),
                          MenuEntry('parent', T.pick(lang, 'Parent Portal', 'والدین پورٹل', 'Elternportal', 'بوابة الوالدين')),
                        ],
                        onSelected: (s) => onNavigate(s),
                      ),
                      NavButton(label: T.pick(lang, 'Community', 'کمیونٹی', 'Community', 'المجتمع'), onTap: () => onNavigate('community')),
                      NavButton(label: T.pick(lang, 'Media', 'میڈیا', 'Medien', 'الإعلام'), onTap: () => onNavigate('media')),
                      NavButton(label: T.pick(lang, 'Donate', 'عطیہ', 'Spenden', 'تبرع'), onTap: () => onNavigate('donate')),
                      NavButton(label: T.pick(lang, 'Contact', 'رابطہ', 'Kontakt', 'تواصل'), onTap: () => onNavigate('contact')),
                      const SizedBox(width: 8),
                    ],
                    LanguageMenu(lang: lang, onChanged: onLanguageChanged),
                    const SizedBox(width: 10),
                    if (!compact)
                      FilledButton.icon(
                        onPressed: onTrial,
                        icon: const Icon(Icons.play_circle_outline_rounded, size: 18),
                        label: Text(T.pick(lang, 'Free Trial', 'مفت ٹرائل', 'Kostenlos testen', 'تجربة مجانية')),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        ),
                      )
                    else
                      IconButton(
                        onPressed: onToggleMobile,
                        icon: Icon(mobileMenu ? Icons.close : Icons.menu),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class MenuEntry {
  final String value;
  final String label;
  const MenuEntry(this.value, this.label);
}

List<MenuEntry> aboutMenu(AppLanguage l) => [
      MenuEntry('vision', T.pick(l, 'Vision & Mission', 'وژن اور مشن', 'Vision & Mission', 'الرؤية والرسالة')),
      MenuEntry('values', T.pick(l, 'Our Values', 'ہماری اقدار', 'Unsere Werte', 'قيمنا')),
      MenuEntry('leadership', T.pick(l, 'Leadership & Shura', 'قیادت اور شوریٰ', 'Leitung & Schura', 'القيادة والشورى')),
      MenuEntry('partners', T.pick(l, 'Partners', 'شراکت دار', 'Partner', 'الشركاء')),
      MenuEntry('careers', T.pick(l, 'Careers', 'کیریئرز', 'Karriere', 'الوظائف')),
    ];

List<MenuEntry> programMenu(AppLanguage l) => [
      MenuEntry('kids', T.pick(l, 'Kids', 'بچے', 'Kinder', 'الأطفال')),
      MenuEntry('youth', T.pick(l, 'Youth', 'نوجوان', 'Jugend', 'الشباب')),
      MenuEntry('adults', T.pick(l, 'Adults', 'بالغ افراد', 'Erwachsene', 'الكبار')),
      MenuEntry('sisters', T.pick(l, 'Sisters', 'خواتین', 'Schwestern', 'الأخوات')),
      MenuEntry('quran', T.pick(l, 'Quran', 'قرآن', 'Koran', 'القرآن')),
      MenuEntry('tajweed', T.pick(l, 'Tajweed', 'تجوید', 'Tajweed', 'التجويد')),
      MenuEntry('hifz', T.pick(l, 'Hifz', 'حفظ', 'Hifz', 'الحفظ')),
      MenuEntry('arabic', T.pick(l, 'Arabic', 'عربی', 'Arabisch', 'العربية')),
      MenuEntry('islamic-studies', T.pick(l, 'Islamic Studies', 'اسلامک اسٹڈیز', 'Islamische Studien', 'الدراسات الإسلامية')),
      MenuEntry('special', T.pick(l, 'Special Courses', 'خصوصی کورسز', 'Spezialkurse', 'الدورات الخاصة')),
    ];

List<MenuEntry> countryMenu(AppLanguage l) => [
      const MenuEntry('germany', 'Germany'),
      const MenuEntry('uk', 'UK'),
      const MenuEntry('usa', 'USA'),
      const MenuEntry('canada', 'Canada'),
      const MenuEntry('australia', 'Australia'),
      const MenuEntry('gcc', 'GCC'),
    ];

class NavButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const NavButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(foregroundColor: AppColors.ink, padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 18)),
      child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }
}

class NavPopup extends StatelessWidget {
  final String label;
  final List<MenuEntry> items;
  final ValueChanged<String> onSelected;
  const NavPopup({super.key, required this.label, required this.items, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: label,
      onSelected: onSelected,
      itemBuilder: (_) => items
          .map((e) => PopupMenuItem<String>(value: e.value, child: Text(e.label)))
          .toList(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 18),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink)),
            const SizedBox(width: 3),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 17),
          ],
        ),
      ),
    );
  }
}

class LanguageMenu extends StatelessWidget {
  final AppLanguage lang;
  final ValueChanged<AppLanguage> onChanged;
  const LanguageMenu({super.key, required this.lang, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AppLanguage>(
      onSelected: onChanged,
      itemBuilder: (_) => AppLanguage.values
          .map((e) => PopupMenuItem(value: e, child: Row(children: [Text(e.code, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(width: 10), Text(e.label)])))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: AppColors.greenSoft, borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.language, size: 18, color: AppColors.green), const SizedBox(width: 6), Text(lang.code, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.green))]),
      ),
    );
  }
}

class MobileNavPanel extends StatelessWidget {
  final AppLanguage lang;
  final void Function(String id, [String section]) onNavigate;
  final VoidCallback onClose;
  const MobileNavPanel({super.key, required this.lang, required this.onNavigate, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final items = <MenuEntry>[
      MenuEntry('home', T.pick(lang, 'Home', 'ہوم', 'Start', 'الرئيسية')),
      MenuEntry('about', T.pick(lang, 'About HILM', 'HILM کے بارے میں', 'Über HILM', 'عن HILM')),
      MenuEntry('programs', T.pick(lang, 'Programs', 'پروگرامز', 'Programme', 'البرامج')),
      MenuEntry('countries', T.pick(lang, 'Countries', 'ممالک', 'Länder', 'الدول')),
      MenuEntry('teachers', T.pick(lang, 'Teachers', 'اساتذہ', 'Lehrkräfte', 'المعلمون')),
      MenuEntry('student', T.pick(lang, 'Student Portal', 'اسٹوڈنٹ پورٹل', 'Schülerportal', 'بوابة الطالب')),
      MenuEntry('parent', T.pick(lang, 'Parent Portal', 'والدین پورٹل', 'Elternportal', 'بوابة الوالدين')),
      MenuEntry('community', T.pick(lang, 'Community', 'کمیونٹی', 'Community', 'المجتمع')),
      MenuEntry('media', T.pick(lang, 'Media', 'میڈیا', 'Medien', 'الإعلام')),
      MenuEntry('donate', T.pick(lang, 'Donate', 'عطیہ', 'Spenden', 'تبرع')),
      MenuEntry('contact', T.pick(lang, 'Contact', 'رابطہ', 'Kontakt', 'تواصل')),
    ];
    return Material(
      elevation: 12,
      color: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 520),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: items
              .map((e) => ListTile(
                    title: Text(e.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () => onNavigate(e.value),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.green, AppColors.greenDark]),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.auto_stories_rounded, color: Colors.white),
        ),
        const SizedBox(width: 10),
        const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('HILM', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: AppColors.ink)),
            Text('INSTITUTE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 2, color: AppColors.green)),
          ],
        ),
      ],
    );
  }
}

class HomePage extends StatelessWidget {
  final AppLanguage lang;
  final void Function(String id, [String section]) onNavigate;
  final VoidCallback onTrial;
  const HomePage({super.key, required this.lang, required this.onNavigate, required this.onTrial});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HeroSection(lang: lang, onTrial: onTrial, onPrograms: () => onNavigate('programs')),
        HomeAboutSection(lang: lang, onMore: () => onNavigate('about')),
        WhyChooseSection(lang: lang),
        HomeProgramsSection(lang: lang, onAll: () => onNavigate('programs')),
        FreeTrialSection(lang: lang, onTrial: onTrial),
        TestimonialsSection(lang: lang),
        StatisticsSection(lang: lang),
        LatestNewsSection(lang: lang, onCommunity: () => onNavigate('community')),
        HomeDonateSection(lang: lang, onDonate: () => onNavigate('donate')),
        HomeContactSection(lang: lang, onContact: () => onNavigate('contact')),
      ],
    );
  }
}

class HeroSection extends StatelessWidget {
  final AppLanguage lang;
  final VoidCallback onTrial;
  final VoidCallback onPrograms;
  const HeroSection({super.key, required this.lang, required this.onTrial, required this.onPrograms});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF7F1E4), Color(0xFFFFFFFF), Color(0xFFEAF5EF)],
        ),
      ),
      child: MaxWidth(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 72),
          child: LayoutBuilder(
            builder: (context, c) {
              final stacked = c.maxWidth < 900;
              final copy = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Tag(text: T.pick(lang, 'Learn • Grow • Serve', 'سیکھیں • بڑھیں • خدمت کریں', 'Lernen • Wachsen • Dienen', 'تعلّم • ارتقِ • اخدم')),
                  const SizedBox(height: 24),
                  Text(
                    T.pick(
                      lang,
                      'Islamic learning for every stage of life.',
                      'زندگی کے ہر مرحلے کے لیے اسلامی تعلیم۔',
                      'Islamisches Lernen für jede Lebensphase.',
                      'تعليم إسلامي لكل مرحلة من مراحل الحياة.',
                    ),
                    style: TextStyle(fontSize: stacked ? 42 : 64, height: 1.05, fontWeight: FontWeight.w900, color: AppColors.ink),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    T.pick(
                      lang,
                      'Live online Quran, Tajweed, Hifz, Arabic and Islamic Studies with trusted teachers, flexible schedules and a caring global community.',
                      'قابلِ اعتماد اساتذہ، لچکدار اوقات اور عالمی کمیونٹی کے ساتھ قرآن، تجوید، حفظ، عربی اور اسلامیات کی لائیو آن لائن تعلیم۔',
                      'Live-Onlineunterricht in Koran, Tajweed, Hifz, Arabisch und Islamischen Studien mit qualifizierten Lehrkräften und flexiblen Zeiten.',
                      'دروس مباشرة عبر الإنترنت في القرآن والتجويد والحفظ والعربية والدراسات الإسلامية مع معلمين موثوقين وجداول مرنة.',
                    ),
                    style: const TextStyle(fontSize: 18, height: 1.7, color: AppColors.muted),
                  ),
                  const SizedBox(height: 30),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed: onTrial,
                        icon: const Icon(Icons.play_circle_outline_rounded),
                        label: Text(T.pick(lang, 'Start Free Trial', 'مفت ٹرائل شروع کریں', 'Kostenlos starten', 'ابدأ التجربة المجانية')),
                        style: FilledButton.styleFrom(backgroundColor: AppColors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 19)),
                      ),
                      OutlinedButton.icon(
                        onPressed: onPrograms,
                        icon: const Icon(Icons.grid_view_rounded),
                        label: Text(T.pick(lang, 'Explore Programs', 'پروگرامز دیکھیں', 'Programme entdecken', 'استكشف البرامج')),
                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.green, side: const BorderSide(color: AppColors.green), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 19)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 34),
                  Wrap(
                    spacing: 24,
                    runSpacing: 12,
                    children: [
                      MiniFeature(icon: Icons.verified_user_outlined, text: T.pick(lang, 'Qualified Teachers', 'ماہر اساتذہ', 'Qualifizierte Lehrkräfte', 'معلمون مؤهلون')),
                      MiniFeature(icon: Icons.public, text: T.pick(lang, 'Global Access', 'عالمی رسائی', 'Weltweiter Zugang', 'وصول عالمي')),
                      MiniFeature(icon: Icons.schedule, text: T.pick(lang, 'Flexible Timings', 'لچکدار اوقات', 'Flexible Zeiten', 'مواعيد مرنة')),
                    ],
                  ),
                ],
              );
              final art = HeroArt(lang: lang);
              if (stacked) {
                return Column(children: [copy, const SizedBox(height: 46), art]);
              }
              return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [Expanded(flex: 11, child: copy), const SizedBox(width: 50), Expanded(flex: 9, child: art)]);
            },
          ),
        ),
      ),
    );
  }
}

class HeroArt extends StatelessWidget {
  final AppLanguage lang;
  const HeroArt({super.key, required this.lang});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 470,
      decoration: BoxDecoration(
        color: AppColors.greenDark,
        borderRadius: BorderRadius.circular(34),
        boxShadow: const [BoxShadow(color: Color(0x24064735), blurRadius: 40, offset: Offset(0, 22))],
      ),
      child: Stack(
        children: [
          Positioned(top: -40, right: -35, child: _orb(170, const Color(0x22FFFFFF))),
          Positioned(bottom: -55, left: -30, child: _orb(210, const Color(0x18D5A84A))),
          Padding(
            padding: const EdgeInsets.all(34),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_stories_rounded, color: AppColors.gold, size: 56),
                const SizedBox(height: 26),
                Text(T.pick(lang, '“The best of you are those who learn the Quran and teach it.”', '“تم میں سب سے بہتر وہ ہے جو قرآن سیکھے اور سکھائے۔”', '„Die Besten unter euch sind jene, die den Koran lernen und lehren.“', '«خيركم من تعلم القرآن وعلمه»'), style: const TextStyle(color: Colors.white, fontSize: 28, height: 1.45, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                const Text('— Sahih al-Bukhari', style: TextStyle(color: Color(0xFFBDD6CC), fontWeight: FontWeight.w600)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(.09), borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white.withOpacity(.14))),
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 24, backgroundColor: AppColors.gold, child: Icon(Icons.groups_rounded, color: AppColors.greenDark)),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(T.pick(lang, 'Join learners worldwide', 'دنیا بھر کے طلبہ کے ساتھ جڑیں', 'Lerne mit Teilnehmenden weltweit', 'انضم إلى طلاب من حول العالم'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(T.pick(lang, 'One community. Meaningful learning.', 'ایک کمیونٹی، بامقصد تعلیم۔', 'Eine Gemeinschaft. Sinnvolles Lernen.', 'مجتمع واحد. تعلم هادف.'), style: const TextStyle(color: Color(0xFFBDD6CC))) ])),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _orb(double size, Color color) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color));
}

class HomeAboutSection extends StatelessWidget {
  final AppLanguage lang;
  final VoidCallback onMore;
  const HomeAboutSection({super.key, required this.lang, required this.onMore});

  @override
  Widget build(BuildContext context) {
    return SectionShell(
      child: ResponsiveTwoColumn(
        left: Container(
          height: 390,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(colors: [AppColors.greenDark, AppColors.green]),
          ),
          child: Stack(children: [
            const Center(child: Icon(Icons.mosque_rounded, size: 155, color: Color(0x22FFFFFF))),
            Positioned(left: 28, right: 28, bottom: 28, child: GlassInfo(text: T.pick(lang, 'Faith-centered learning, delivered with excellence.', 'ایمان پر مبنی تعلیم، بہترین انداز میں۔', 'Glaubensorientiertes Lernen mit Qualität.', 'تعليم قائم على الإيمان بجودة عالية.'))),
          ]),
        ),
        right: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionEyebrow(T.pick(lang, 'ABOUT HILM', 'HILM کے بارے میں', 'ÜBER HILM', 'عن HILM')),
            const SizedBox(height: 12),
            SectionTitle(T.pick(lang, 'Knowledge that shapes hearts, homes and communities.', 'ایسا علم جو دلوں، گھروں اور معاشروں کو سنوارے۔', 'Wissen, das Herzen, Familien und Gemeinschaften prägt.', 'علم يبني القلوب والبيوت والمجتمعات.')),
            const SizedBox(height: 18),
            Text(T.pick(lang, 'HILM is a modern Islamic learning institute connecting students and families with structured, accessible and spiritually grounded education.', 'HILM ایک جدید اسلامی تعلیمی ادارہ ہے جو طلبہ اور خاندانوں کو منظم، آسان اور روحانی بنیادوں پر قائم تعلیم سے جوڑتا ہے۔', 'HILM ist ein modernes islamisches Bildungsinstitut für strukturierte, zugängliche und spirituell fundierte Bildung.', 'HILM معهد تعليمي إسلامي حديث يربط الطلاب والأسر بتعليم منظم وميسر ومتجذر روحياً.'), style: const TextStyle(fontSize: 17, height: 1.7, color: AppColors.muted)),
            const SizedBox(height: 24),
            const Wrap(spacing: 12, runSpacing: 12, children: [InfoChip(icon: Icons.favorite_outline, text: 'Character'), InfoChip(icon: Icons.menu_book_rounded, text: 'Knowledge'), InfoChip(icon: Icons.groups_2_outlined, text: 'Community')]),
            const SizedBox(height: 26),
            FilledButton(onPressed: onMore, style: FilledButton.styleFrom(backgroundColor: AppColors.green, foregroundColor: Colors.white), child: Text(T.pick(lang, 'Discover Our Story', 'ہماری کہانی جانیں', 'Unsere Geschichte', 'اكتشف قصتنا'))),
          ],
        ),
      ),
    );
  }
}

class WhyChooseSection extends StatelessWidget {
  final AppLanguage lang;
  const WhyChooseSection({super.key, required this.lang});
  @override
  Widget build(BuildContext context) {
    final items = [
      FeatureData(Icons.school_outlined, T.pick(lang, 'Trusted Teachers', 'قابلِ اعتماد اساتذہ', 'Vertrauenswürdige Lehrkräfte', 'معلمون موثوقون'), T.pick(lang, 'Qualified teachers with strong subject knowledge and compassionate teaching.', 'ماہر اساتذہ جو علم اور شفقت کے ساتھ پڑھاتے ہیں۔', 'Qualifizierte Lehrkräfte mit Fachwissen und einfühlsamer Didaktik.', 'معلمون مؤهلون بعلم راسخ وتعليم رحيم.')),
      FeatureData(Icons.video_camera_front_outlined, T.pick(lang, 'Live Interactive Classes', 'لائیو انٹرایکٹو کلاسز', 'Live-Unterricht', 'حصص مباشرة تفاعلية'), T.pick(lang, 'Engaging online sessions with questions, feedback and guided practice.', 'سوالات، فیڈبیک اور عملی رہنمائی کے ساتھ آن لائن کلاسز۔', 'Interaktive Online-Sitzungen mit Fragen, Feedback und Übungen.', 'جلسات تفاعلية مع الأسئلة والتغذية الراجعة والتطبيق.')),
      FeatureData(Icons.family_restroom_outlined, T.pick(lang, 'For Every Age', 'ہر عمر کے لیے', 'Für jedes Alter', 'لكل الأعمار'), T.pick(lang, 'Age-appropriate pathways for kids, youth, adults and sisters.', 'بچوں، نوجوانوں، بڑوں اور خواتین کے لیے موزوں پروگرامز۔', 'Passende Lernwege für Kinder, Jugendliche, Erwachsene und Schwestern.', 'مسارات مناسبة للأطفال والشباب والكبار والأخوات.')),
      FeatureData(Icons.language_outlined, T.pick(lang, 'Global & Multilingual', 'عالمی اور کثیر لسانی', 'Global & mehrsprachig', 'عالمي ومتعدد اللغات'), T.pick(lang, 'Learn across countries in English, Urdu, German and Arabic.', 'انگریزی، اردو، جرمن اور عربی میں دنیا بھر سے سیکھیں۔', 'Lernen Sie weltweit auf Englisch, Urdu, Deutsch und Arabisch.', 'تعلم عالمياً بالإنجليزية والأردية والألمانية والعربية.')),
    ];
    return Container(
      color: Colors.white,
      child: SectionShell(
        child: Column(children: [
          CenteredHeader(eyebrow: T.pick(lang, 'WHY CHOOSE HILM', 'HILM کیوں؟', 'WARUM HILM', 'لماذا HILM'), title: T.pick(lang, 'A learning experience built around you.', 'ایک تعلیمی تجربہ جو آپ کے لیے بنایا گیا ہے۔', 'Ein Lernerlebnis, das zu Ihnen passt.', 'تجربة تعليمية مصممة من أجلك.')),
          const SizedBox(height: 36),
          ResponsiveGrid(minItemWidth: 245, children: items.map((e) => FeatureCard(data: e)).toList()),
        ]),
      ),
    );
  }
}

class HomeProgramsSection extends StatelessWidget {
  final AppLanguage lang;
  final VoidCallback onAll;
  const HomeProgramsSection({super.key, required this.lang, required this.onAll});
  @override
  Widget build(BuildContext context) {
    final items = corePrograms(lang).take(6).toList();
    return SectionShell(
      child: Column(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Expanded(child: SectionTitle(T.pick(lang, 'Programs for every learner.', 'ہر سیکھنے والے کے لیے پروگرامز۔', 'Programme für alle Lernenden.', 'برامج لكل متعلم.'))), TextButton.icon(onPressed: onAll, icon: const Icon(Icons.arrow_forward_rounded), label: Text(T.pick(lang, 'View all', 'سب دیکھیں', 'Alle ansehen', 'عرض الكل')))]),
        const SizedBox(height: 30),
        ResponsiveGrid(minItemWidth: 300, children: items.map((e) => ProgramCard(data: e, lang: lang)).toList()),
      ]),
    );
  }
}

class FreeTrialSection extends StatelessWidget {
  final AppLanguage lang;
  final VoidCallback onTrial;
  const FreeTrialSection({super.key, required this.lang, required this.onTrial});
  @override
  Widget build(BuildContext context) {
    return SectionShell(
      vertical: 30,
      child: Container(
        padding: const EdgeInsets.all(36),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.greenDark, AppColors.green]), borderRadius: BorderRadius.circular(30)),
        child: LayoutBuilder(builder: (context, c) {
          final stacked = c.maxWidth < 760;
          final copy = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(T.pick(lang, 'Try your first class free.', 'اپنی پہلی کلاس مفت آزمائیں۔', 'Testen Sie Ihre erste Stunde kostenlos.', 'جرّب حصتك الأولى مجاناً.'), style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white)), const SizedBox(height: 10), Text(T.pick(lang, 'Meet a teacher, experience the class and choose the right learning path.', 'استاد سے ملیں، کلاس کا تجربہ کریں اور اپنے لیے درست تعلیمی راستہ منتخب کریں۔', 'Lernen Sie eine Lehrkraft kennen und finden Sie den passenden Lernweg.', 'قابل معلماً وجرّب الحصة واختر المسار التعليمي المناسب.'), style: const TextStyle(color: Color(0xFFD6E9E1), fontSize: 16, height: 1.6))]);
          final button = FilledButton.icon(onPressed: onTrial, style: FilledButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.greenDark, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18)), icon: const Icon(Icons.calendar_month_outlined), label: Text(T.pick(lang, 'Book Free Trial', 'مفت ٹرائل بک کریں', 'Gratis-Probestunde buchen', 'احجز تجربة مجانية')));
          if (stacked) return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [copy, const SizedBox(height: 24), button]);
          return Row(children: [Expanded(child: copy), const SizedBox(width: 24), button]);
        }),
      ),
    );
  }
}

class TestimonialsSection extends StatelessWidget {
  final AppLanguage lang;
  const TestimonialsSection({super.key, required this.lang});
  @override
  Widget build(BuildContext context) {
    final testimonials = [
      TestimonialData('Ayesha Khan', 'Parent', T.pick(lang, 'The teachers are patient and the structure is excellent. My children look forward to every class.', 'اساتذہ بہت صبر والے ہیں اور نظام بہترین ہے۔ میرے بچے ہر کلاس کا انتظار کرتے ہیں۔', 'Die Lehrkräfte sind geduldig und die Struktur ist hervorragend. Meine Kinder freuen sich auf jede Stunde.', 'المعلمون صبورون والنظام ممتاز. أطفالي يتطلعون إلى كل حصة.')),
      TestimonialData('Rashid Ali', 'Student', T.pick(lang, 'HILM helped me build a consistent relationship with Quran despite a busy work schedule.', 'مصروف کام کے باوجود HILM نے قرآن کے ساتھ مستقل تعلق بنانے میں میری مدد کی۔', 'HILM half mir trotz meines vollen Arbeitsalltags eine beständige Beziehung zum Koran aufzubauen.', 'ساعدني HILM على بناء علاقة مستمرة مع القرآن رغم انشغالي بالعمل.')),
      TestimonialData('Sarah Ahmed', 'Sister Program', T.pick(lang, 'A respectful, supportive environment where I can learn at my own pace.', 'ایک باوقار اور معاون ماحول جہاں میں اپنی رفتار سے سیکھ سکتی ہوں۔', 'Eine respektvolle und unterstützende Umgebung, in der ich in meinem Tempo lernen kann.', 'بيئة محترمة وداعمة أتعلم فيها بالسرعة التي تناسبني.')),
    ];
    return Container(color: Colors.white, child: SectionShell(child: Column(children: [CenteredHeader(eyebrow: T.pick(lang, 'TESTIMONIALS', 'تاثرات', 'ERFAHRUNGEN', 'آراء الطلاب'), title: T.pick(lang, 'Loved by learners and families.', 'طلبہ اور خاندانوں کا اعتماد۔', 'Von Lernenden und Familien geschätzt.', 'محبوب لدى الطلاب والأسر.')), const SizedBox(height: 34), ResponsiveGrid(minItemWidth: 300, children: testimonials.map((e) => TestimonialCard(data: e)).toList())])));
  }
}

class StatisticsSection extends StatelessWidget {
  final AppLanguage lang;
  const StatisticsSection({super.key, required this.lang});
  @override
  Widget build(BuildContext context) {
    return SectionShell(child: ResponsiveGrid(minItemWidth: 220, children: [
      StatCard(number: '4,500+', label: T.pick(lang, 'Learners', 'طلبہ', 'Lernende', 'طلاب')),
      StatCard(number: '80+', label: T.pick(lang, 'Teachers', 'اساتذہ', 'Lehrkräfte', 'معلمون')),
      StatCard(number: '25+', label: T.pick(lang, 'Countries Reached', 'ممالک', 'Erreichte Länder', 'دولة')),
      StatCard(number: '92%', label: T.pick(lang, 'Learner Satisfaction', 'طلبہ کا اطمینان', 'Zufriedenheit', 'رضا الطلاب')),
    ]));
  }
}

class LatestNewsSection extends StatelessWidget {
  final AppLanguage lang;
  final VoidCallback onCommunity;
  const LatestNewsSection({super.key, required this.lang, required this.onCommunity});
  @override
  Widget build(BuildContext context) {
    final news = [
      NewsData('12 Aug', T.pick(lang, 'Summer Quran Intensive', 'سمر قرآن انٹینسیو', 'Sommer-Koran-Intensivkurs', 'برنامج القرآن الصيفي المكثف'), T.pick(lang, 'A focused four-week learning journey for youth and adults.', 'نوجوانوں اور بڑوں کے لیے چار ہفتوں کا خصوصی پروگرام۔', 'Vier Wochen intensives Lernen für Jugendliche und Erwachsene.', 'رحلة تعليمية مكثفة لمدة أربعة أسابيع للشباب والكبار.')),
      NewsData('24 Aug', T.pick(lang, 'Parents Learning Circle', 'والدین لرننگ سرکل', 'Lernkreis für Eltern', 'حلقة تعلم للوالدين'), T.pick(lang, 'Practical guidance for nurturing faith and character at home.', 'گھر میں ایمان اور کردار کی تربیت کے لیے عملی رہنمائی۔', 'Praktische Impulse für Glauben und Charakter in der Familie.', 'إرشادات عملية لتعزيز الإيمان والأخلاق في المنزل.')),
      NewsData('05 Sep', T.pick(lang, 'Teacher Development Workshop', 'ٹیچر ڈویلپمنٹ ورکشاپ', 'Workshop für Lehrkräfte', 'ورشة تطوير المعلمين'), T.pick(lang, 'Training educators in engaging online Islamic teaching methods.', 'اساتذہ کے لیے مؤثر آن لائن اسلامی تدریس کی تربیت۔', 'Fortbildung für ansprechenden islamischen Online-Unterricht.', 'تدريب المعلمين على أساليب التعليم الإسلامي التفاعلي عبر الإنترنت.')),
    ];
    return Container(color: AppColors.greenSoft, child: SectionShell(child: Column(children: [Row(children: [Expanded(child: SectionTitle(T.pick(lang, 'Latest news & upcoming events.', 'تازہ خبریں اور آنے والے پروگرامز۔', 'Neuigkeiten & kommende Veranstaltungen.', 'آخر الأخبار والفعاليات القادمة.'))), TextButton(onPressed: onCommunity, child: Text(T.pick(lang, 'Visit Community', 'کمیونٹی دیکھیں', 'Community öffnen', 'زيارة المجتمع')))]), const SizedBox(height: 28), ResponsiveGrid(minItemWidth: 300, children: news.map((e) => NewsCard(data: e)).toList())])));
  }
}

class HomeDonateSection extends StatelessWidget {
  final AppLanguage lang;
  final VoidCallback onDonate;
  const HomeDonateSection({super.key, required this.lang, required this.onDonate});
  @override
  Widget build(BuildContext context) {
    return SectionShell(child: ResponsiveTwoColumn(left: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [SectionEyebrow(T.pick(lang, 'GIVE & GROW', 'عطیہ', 'SPENDEN', 'تبرع')), const SizedBox(height: 12), SectionTitle(T.pick(lang, 'Help a student access meaningful Islamic education.', 'ایک طالب علم کو بامقصد اسلامی تعلیم تک رسائی دیں۔', 'Ermöglichen Sie einem Schüler wertvolle islamische Bildung.', 'ساعد طالباً على الوصول إلى تعليم إسلامي هادف.')), const SizedBox(height: 16), Text(T.pick(lang, 'Your support can sponsor lessons, learning resources and teacher time for families who need assistance.', 'آپ کی مدد ضرورت مند خاندانوں کے لیے کلاسز، تعلیمی وسائل اور اساتذہ کی خدمات فراہم کر سکتی ہے۔', 'Ihre Unterstützung finanziert Unterricht, Lernmaterialien und Lehrzeit für bedürftige Familien.', 'يساهم دعمك في توفير الدروس والمواد التعليمية ووقت المعلمين للأسر المحتاجة.')), const SizedBox(height: 22), FilledButton.icon(onPressed: onDonate, icon: const Icon(Icons.volunteer_activism_outlined), label: Text(T.pick(lang, 'Donate Now', 'اب عطیہ دیں', 'Jetzt spenden', 'تبرع الآن')), style: FilledButton.styleFrom(backgroundColor: AppColors.green, foregroundColor: Colors.white))]), right: const DonationVisual()));
  }
}

class HomeContactSection extends StatelessWidget {
  final AppLanguage lang;
  final VoidCallback onContact;
  const HomeContactSection({super.key, required this.lang, required this.onContact});
  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.white, child: SectionShell(child: Container(padding: const EdgeInsets.all(34), decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(28)), child: LayoutBuilder(builder: (context, c) { final stacked = c.maxWidth < 700; final copy = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [SectionTitle(T.pick(lang, 'Have a question? Let’s talk.', 'کوئی سوال ہے؟ ہم سے بات کریں۔', 'Fragen? Sprechen Sie mit uns.', 'لديك سؤال؟ تواصل معنا.')), const SizedBox(height: 8), Text(T.pick(lang, 'Our team can help you choose a program, teacher or study schedule.', 'ہماری ٹیم پروگرام، استاد یا شیڈول منتخب کرنے میں آپ کی مدد کر سکتی ہے۔', 'Unser Team hilft bei der Wahl von Programm, Lehrkraft oder Zeitplan.', 'فريقنا يساعدك في اختيار البرنامج والمعلم والجدول المناسب.'))]); final action = FilledButton.icon(onPressed: onContact, icon: const Icon(Icons.chat_bubble_outline), label: Text(T.pick(lang, 'Contact HILM', 'HILM سے رابطہ کریں', 'HILM kontaktieren', 'تواصل مع HILM')), style: FilledButton.styleFrom(backgroundColor: AppColors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17))); return stacked ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [copy, const SizedBox(height: 20), action]) : Row(children: [Expanded(child: copy), const SizedBox(width: 20), action]); }))));
  }
}
class AboutPage extends StatelessWidget {
  final AppLanguage lang;
  final String section;
  const AboutPage({super.key, required this.lang, required this.section});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      PageHero(
        icon: Icons.info_outline_rounded,
        eyebrow: T.pick(lang, 'ABOUT HILM', 'HILM کے بارے میں', 'ÜBER HILM', 'عن HILM'),
        title: T.pick(lang, 'Rooted in knowledge. Guided by service.', 'علم میں جڑیں، خدمت میں رہنمائی۔', 'Im Wissen verwurzelt. Vom Dienst geleitet.', 'راسخون في العلم وموجّهون بالخدمة.'),
        description: T.pick(lang, 'Meet the vision, values and people behind HILM Institute.', 'HILM انسٹیٹیوٹ کے وژن، اقدار اور لوگوں سے ملیں۔', 'Lernen Sie Vision, Werte und Menschen hinter HILM kennen.', 'تعرّف على رؤية HILM وقيمه وفريقه.'),
      ),
      SectionShell(child: Column(children: [
        AnchorCard(
          highlighted: section == 'vision',
          icon: Icons.visibility_outlined,
          title: T.pick(lang, 'Vision & Mission', 'وژن اور مشن', 'Vision & Mission', 'الرؤية والرسالة'),
          body: T.pick(lang, 'Our vision is a global community that learns Islam with clarity, lives it with character and shares it with wisdom. Our mission is to make authentic Islamic education accessible through structured programs, trusted teachers and modern learning tools.', 'ہمارا وژن ایک ایسی عالمی کمیونٹی ہے جو اسلام کو وضاحت سے سیکھے، کردار کے ساتھ اپنائے اور حکمت سے آگے پہنچائے۔ ہمارا مشن منظم پروگرامز، قابلِ اعتماد اساتذہ اور جدید تعلیمی ذرائع کے ذریعے مستند اسلامی تعلیم کو آسان بنانا ہے۔', 'Unsere Vision ist eine globale Gemeinschaft, die den Islam klar lernt, charaktervoll lebt und weise weitergibt. Unsere Mission ist zugängliche authentische islamische Bildung durch strukturierte Programme, vertrauenswürdige Lehrkräfte und moderne Lernwerkzeuge.', 'رؤيتنا مجتمع عالمي يتعلم الإسلام بوضوح ويعيشه بأخلاق وينقله بحكمة. ورسالتنا إتاحة تعليم إسلامي أصيل عبر برامج منظمة ومعلمين موثوقين وأدوات تعليم حديثة.'),
        ),
        const SizedBox(height: 18),
        AnchorCard(
          highlighted: section == 'values',
          icon: Icons.favorite_border_rounded,
          title: T.pick(lang, 'Our Values', 'ہماری اقدار', 'Unsere Werte', 'قيمنا'),
          bodyWidget: ResponsiveGrid(minItemWidth: 220, children: [
            ValueTile(Icons.menu_book_outlined, T.pick(lang, 'Authenticity', 'مستند تعلیم', 'Authentizität', 'الأصالة')),
            ValueTile(Icons.self_improvement_outlined, T.pick(lang, 'Character', 'کردار', 'Charakter', 'الأخلاق')),
            ValueTile(Icons.diversity_3_outlined, T.pick(lang, 'Compassion', 'شفقت', 'Mitgefühl', 'الرحمة')),
            ValueTile(Icons.workspace_premium_outlined, T.pick(lang, 'Excellence', 'بہترین معیار', 'Exzellenz', 'الإتقان')),
          ]),
        ),
        const SizedBox(height: 18),
        AnchorCard(
          highlighted: section == 'leadership',
          icon: Icons.groups_2_outlined,
          title: T.pick(lang, 'Leadership & Shura', 'قیادت اور شوریٰ', 'Leitung & Schura', 'القيادة والشورى'),
          bodyWidget: ResponsiveGrid(minItemWidth: 270, children: [
            PersonCard(name: 'Dr. Ahmad Rahman', role: T.pick(lang, 'Academic Director', 'اکیڈمک ڈائریکٹر', 'Akademischer Leiter', 'المدير الأكاديمي'), icon: Icons.school_outlined),
            PersonCard(name: 'Ustadh Bilal Kareem', role: T.pick(lang, 'Shura Member', 'شوریٰ ممبر', 'Schura-Mitglied', 'عضو الشورى'), icon: Icons.account_balance_outlined),
            PersonCard(name: 'Sr. Maryam Ali', role: T.pick(lang, 'Women & Family Programs', 'خواتین و فیملی پروگرامز', 'Frauen- & Familienprogramme', 'برامج النساء والأسرة'), icon: Icons.family_restroom_outlined),
          ]),
        ),
        const SizedBox(height: 18),
        AnchorCard(
          highlighted: section == 'partners',
          icon: Icons.handshake_outlined,
          title: T.pick(lang, 'Partners', 'شراکت دار', 'Partner', 'الشركاء'),
          bodyWidget: Wrap(spacing: 14, runSpacing: 14, children: const [PartnerBadge('Community Mosques'), PartnerBadge('Education Trusts'), PartnerBadge('Youth Networks'), PartnerBadge('Family Organisations')]),
        ),
        const SizedBox(height: 18),
        AnchorCard(
          highlighted: section == 'careers',
          icon: Icons.work_outline_rounded,
          title: T.pick(lang, 'Careers', 'کیریئرز', 'Karriere', 'الوظائف'),
          bodyWidget: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(T.pick(lang, 'Join a mission-driven team building meaningful Islamic learning experiences.', 'ایک بامقصد ٹیم کا حصہ بنیں جو اسلامی تعلیم کے بہترین تجربات بنا رہی ہے۔', 'Werden Sie Teil eines Teams, das sinnvolle islamische Lernerlebnisse schafft.', 'انضم إلى فريق صاحب رسالة يبني تجارب تعليم إسلامي هادفة.')),
            const SizedBox(height: 16),
            ResponsiveGrid(minItemWidth: 260, children: [
              VacancyTile(title: T.pick(lang, 'Quran Teacher', 'قرآن ٹیچر', 'Koranlehrkraft', 'معلم قرآن'), type: 'Remote'),
              VacancyTile(title: T.pick(lang, 'Arabic Instructor', 'عربی انسٹرکٹر', 'Arabisch-Lehrkraft', 'مدرس لغة عربية'), type: 'Remote'),
              VacancyTile(title: T.pick(lang, 'Student Support', 'اسٹوڈنٹ سپورٹ', 'Studierendenbetreuung', 'دعم الطلاب'), type: 'Hybrid'),
            ]),
          ]),
        ),
      ])),
    ]);
  }
}

class ProgramData {
  final String id;
  final IconData icon;
  final String title;
  final String subtitle;
  final String audience;
  const ProgramData(this.id, this.icon, this.title, this.subtitle, this.audience);
}

List<ProgramData> corePrograms(AppLanguage l) => [
      ProgramData('kids', Icons.child_care_outlined, T.pick(l, 'Kids', 'بچے', 'Kinder', 'الأطفال'), T.pick(l, 'Joyful foundational learning for young hearts.', 'چھوٹے بچوں کے لیے دلچسپ بنیادی اسلامی تعلیم۔', 'Freudiges Grundlagenlernen für junge Herzen.', 'تعلم تأسيسي ممتع للقلوب الصغيرة.'), 'Age 5–11'),
      ProgramData('youth', Icons.groups_outlined, T.pick(l, 'Youth', 'نوجوان', 'Jugend', 'الشباب'), T.pick(l, 'Faith, identity and leadership for the next generation.', 'نئی نسل کے لیے ایمان، شناخت اور قیادت۔', 'Glaube, Identität und Führung für die nächste Generation.', 'إيمان وهوية وقيادة للجيل القادم.'), 'Age 12–18'),
      ProgramData('adults', Icons.person_outline_rounded, T.pick(l, 'Adults', 'بالغ افراد', 'Erwachsene', 'الكبار'), T.pick(l, 'Structured learning for busy adult lives.', 'مصروف بالغ افراد کے لیے منظم تعلیم۔', 'Strukturiertes Lernen für den Erwachsenenalltag.', 'تعلم منظم يناسب حياة الكبار.'), '18+'),
      ProgramData('sisters', Icons.spa_outlined, T.pick(l, 'Sisters', 'خواتین', 'Schwestern', 'الأخوات'), T.pick(l, 'Supportive women-only learning spaces.', 'خواتین کے لیے محفوظ اور معاون تعلیمی ماحول۔', 'Unterstützende Lernräume nur für Frauen.', 'مساحات تعليمية داعمة للنساء فقط.'), 'Women'),
      ProgramData('quran', Icons.auto_stories_outlined, T.pick(l, 'Quran', 'قرآن', 'Koran', 'القرآن'), T.pick(l, 'Recitation, understanding and reflection.', 'تلاوت، فہم اور تدبر۔', 'Rezitation, Verständnis und Reflexion.', 'تلاوة وفهم وتدبر.'), 'All Levels'),
      ProgramData('tajweed', Icons.record_voice_over_outlined, T.pick(l, 'Tajweed', 'تجوید', 'Tajweed', 'التجويد'), T.pick(l, 'Correct pronunciation, makharij and fluent recitation.', 'صحیح تلفظ، مخارج اور روانی۔', 'Aussprache, Artikulation und flüssige Rezitation.', 'تصحيح النطق والمخارج والطلاقة.'), 'Beginner–Advanced'),
      ProgramData('hifz', Icons.psychology_alt_outlined, T.pick(l, 'Hifz', 'حفظ', 'Hifz', 'الحفظ'), T.pick(l, 'Personal memorisation and revision plans.', 'ذاتی حفظ اور دہرائی کے منصوبے۔', 'Individuelle Memorier- und Wiederholungspläne.', 'خطط شخصية للحفظ والمراجعة.'), 'Personal Plan'),
      ProgramData('arabic', Icons.translate_outlined, T.pick(l, 'Arabic', 'عربی', 'Arabisch', 'العربية'), T.pick(l, 'Quranic vocabulary, grammar and communication.', 'قرآنی الفاظ، گرامر اور گفتگو۔', 'Koranischer Wortschatz, Grammatik und Kommunikation.', 'مفردات قرآنية وقواعد وتواصل.'), 'Foundation–Intermediate'),
      ProgramData('islamic-studies', Icons.mosque_outlined, T.pick(l, 'Islamic Studies', 'اسلامک اسٹڈیز', 'Islamische Studien', 'الدراسات الإسلامية'), T.pick(l, 'Aqeedah, Fiqh, Seerah, Hadith and character.', 'عقیدہ، فقہ، سیرت، حدیث اور اخلاق۔', 'Aqeedah, Fiqh, Seerah, Hadith und Charakter.', 'العقيدة والفقه والسيرة والحديث والأخلاق.'), 'Structured Path'),
      ProgramData('special', Icons.workspace_premium_outlined, T.pick(l, 'Special Courses', 'خصوصی کورسز', 'Spezialkurse', 'الدورات الخاصة'), T.pick(l, 'Seasonal intensives, workshops and masterclasses.', 'موسمی کورسز، ورکشاپس اور ماسٹرکلاسز۔', 'Intensivkurse, Workshops und Masterclasses.', 'دورات مكثفة وورش عمل ودروس متخصصة.'), 'Seasonal'),
    ];

class ProgramsPage extends StatelessWidget {
  final AppLanguage lang;
  final String section;
  final VoidCallback onTrial;
  const ProgramsPage({super.key, required this.lang, required this.section, required this.onTrial});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      PageHero(
        icon: Icons.grid_view_rounded,
        eyebrow: T.pick(lang, 'PROGRAMS', 'پروگرامز', 'PROGRAMME', 'البرامج'),
        title: T.pick(lang, 'Choose a path. Build a lifelong connection.', 'اپنا راستہ منتخب کریں، عمر بھر کا تعلق بنائیں۔', 'Wählen Sie Ihren Weg. Bauen Sie eine lebenslange Verbindung auf.', 'اختر مسارك وابنِ صلة تدوم مدى الحياة.'),
        description: T.pick(lang, 'Age-based and subject-based programs designed for consistent progress.', 'عمر اور موضوع کے مطابق پروگرامز جو مسلسل ترقی کے لیے بنائے گئے ہیں۔', 'Alters- und fachbezogene Programme für kontinuierlichen Fortschritt.', 'برامج حسب العمر والموضوع مصممة للتقدم المستمر.'),
      ),
      SectionShell(child: Column(children: [
        ResponsiveGrid(minItemWidth: 300, children: corePrograms(lang).map((p) => ProgramCard(data: p, lang: lang, highlighted: p.id == section)).toList()),
        const SizedBox(height: 36),
        Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(color: AppColors.greenDark, borderRadius: BorderRadius.circular(28)),
          child: LayoutBuilder(builder: (context, c) {
            final stacked = c.maxWidth < 700;
            final copy = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(T.pick(lang, 'Not sure where to begin?', 'سمجھ نہیں آ رہا کہاں سے شروع کریں؟', 'Nicht sicher, wo Sie anfangen sollen?', 'لست متأكداً من أين تبدأ؟'), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)), const SizedBox(height: 8), Text(T.pick(lang, 'Book a free trial and our team will recommend the right level and program.', 'مفت ٹرائل بک کریں، ہماری ٹیم آپ کے لیے درست لیول اور پروگرام تجویز کرے گی۔', 'Buchen Sie eine kostenlose Probestunde und wir empfehlen das passende Niveau.', 'احجز تجربة مجانية وسنقترح لك المستوى والبرنامج المناسبين.'), style: const TextStyle(color: Color(0xFFD6E9E1)))]);
            final action = FilledButton(onPressed: onTrial, style: FilledButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.greenDark), child: Text(T.pick(lang, 'Book Free Trial', 'مفت ٹرائل بک کریں', 'Probestunde buchen', 'احجز تجربة مجانية')));
            return stacked ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [copy, const SizedBox(height: 20), action]) : Row(children: [Expanded(child: copy), const SizedBox(width: 20), action]);
          }),
        ),
      ])),
    ]);
  }
}

class CountriesPage extends StatelessWidget {
  final AppLanguage lang;
  final String section;
  const CountriesPage({super.key, required this.lang, required this.section});

  @override
  Widget build(BuildContext context) {
    final countries = [
      CountryData('germany', 'Germany', '🇩🇪', 'CET / CEST', 'EUR'),
      CountryData('uk', 'United Kingdom', '🇬🇧', 'GMT / BST', 'GBP'),
      CountryData('usa', 'United States', '🇺🇸', 'Multiple time zones', 'USD'),
      CountryData('canada', 'Canada', '🇨🇦', 'Multiple time zones', 'CAD'),
      CountryData('australia', 'Australia', '🇦🇺', 'Multiple time zones', 'AUD'),
      CountryData('gcc', 'GCC', '🌍', 'GST / AST', 'Local currencies'),
    ];
    return Column(children: [
      PageHero(icon: Icons.public_rounded, eyebrow: T.pick(lang, 'COUNTRIES', 'ممالک', 'LÄNDER', 'الدول'), title: T.pick(lang, 'Global learning, locally convenient.', 'عالمی تعلیم، آپ کے مقامی وقت کے مطابق۔', 'Globales Lernen, lokal passend.', 'تعلم عالمي بتوقيت يناسبك.'), description: T.pick(lang, 'Country-specific schedules, currencies and learner support for our international community.', 'عالمی کمیونٹی کے لیے ملک کے مطابق اوقات، کرنسی اور سپورٹ۔', 'Länderspezifische Zeiten, Währungen und Betreuung für unsere internationale Community.', 'جداول وعملات ودعم مناسب لكل دولة في مجتمعنا العالمي.')),
      SectionShell(child: ResponsiveGrid(minItemWidth: 320, children: countries.map((c) => CountryCard(data: c, highlighted: c.id == section, lang: lang)).toList())),
    ]);
  }
}

class TeachersPage extends StatelessWidget {
  final AppLanguage lang;
  final String section;
  const TeachersPage({super.key, required this.lang, required this.section});

  @override
  Widget build(BuildContext context) {
    final teachers = [
      TeacherData('Ustadh Hamza Noor', 'Quran & Tajweed', ['Ijazah in Hafs', '10+ years'], ['English', 'Urdu', 'Arabic'], '4.9'),
      TeacherData('Ustadha Maryam Zahra', 'Arabic & Sisters', ['MA Arabic', 'Female students'], ['English', 'Arabic', 'German'], '4.9'),
      TeacherData('Shaykh Yusuf Kareem', 'Islamic Studies', ['Shariah Graduate', 'Seerah specialist'], ['English', 'Arabic'], '4.8'),
      TeacherData('Ustadha Amina Saleh', 'Kids & Hifz', ['Hifz certified', 'Child pedagogy'], ['English', 'Urdu'], '4.9'),
    ];
    return Column(children: [
      PageHero(icon: Icons.school_outlined, eyebrow: T.pick(lang, 'TEACHERS', 'اساتذہ', 'LEHRKRÄFTE', 'المعلمون'), title: T.pick(lang, 'Learn with teachers you can trust.', 'ایسے اساتذہ سے سیکھیں جن پر آپ اعتماد کر سکیں۔', 'Lernen Sie mit Lehrkräften, denen Sie vertrauen können.', 'تعلم مع معلمين يمكنك الوثوق بهم.'), description: T.pick(lang, 'Explore teacher profiles, qualifications, languages and learner reviews.', 'اساتذہ کی پروفائلز، قابلیت، زبانیں اور طلبہ کے تاثرات دیکھیں۔', 'Profile, Qualifikationen, Sprachen und Bewertungen entdecken.', 'استعرض ملفات المعلمين ومؤهلاتهم ولغاتهم وتقييمات الطلاب.')),
      SectionShell(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 9, runSpacing: 9, children: [
          TinyChip(T.pick(lang, 'Teacher Profiles', 'اساتذہ کی پروفائلز', 'Lehrkräfteprofile', 'ملفات المعلمين')),
          TinyChip(T.pick(lang, 'Qualifications', 'قابلیت', 'Qualifikationen', 'المؤهلات')),
          TinyChip(T.pick(lang, 'Languages', 'زبانیں', 'Sprachen', 'اللغات')),
          TinyChip(T.pick(lang, 'Reviews', 'تاثرات', 'Bewertungen', 'التقييمات')),
        ]),
        const SizedBox(height: 22),
        ResponsiveGrid(minItemWidth: 330, children: teachers.map((t) => TeacherCard(data: t, lang: lang)).toList()),
        const SizedBox(height: 40),
        SectionTitle(T.pick(lang, 'How we select teachers', 'ہم اساتذہ کا انتخاب کیسے کرتے ہیں', 'Wie wir Lehrkräfte auswählen', 'كيف نختار المعلمين')),
        const SizedBox(height: 20),
        ResponsiveGrid(minItemWidth: 250, children: [
          FeatureCard(data: FeatureData(Icons.workspace_premium_outlined, T.pick(lang, 'Qualifications', 'قابلیت', 'Qualifikationen', 'المؤهلات'), T.pick(lang, 'Relevant Islamic and academic credentials are verified.', 'متعلقہ اسلامی اور تعلیمی اسناد کی تصدیق کی جاتی ہے۔', 'Relevante islamische und akademische Qualifikationen werden geprüft.', 'يتم التحقق من المؤهلات الإسلامية والأكاديمية ذات الصلة.'))),
          FeatureCard(data: FeatureData(Icons.record_voice_over_outlined, T.pick(lang, 'Teaching Skill', 'تدریسی مہارت', 'Didaktik', 'مهارة التدريس'), T.pick(lang, 'Teachers are assessed for clarity, empathy and online delivery.', 'اساتذہ کی وضاحت، شفقت اور آن لائن تدریس کی صلاحیت دیکھی جاتی ہے۔', 'Lehrkräfte werden auf Klarheit, Empathie und Online-Didaktik geprüft.', 'يتم تقييم المعلمين في الوضوح والتعاطف والقدرة على التعليم عبر الإنترنت.'))),
          FeatureCard(data: FeatureData(Icons.shield_outlined, T.pick(lang, 'Safety & Conduct', 'حفاظت اور ضابطہ', 'Sicherheit & Verhalten', 'السلامة والسلوك'), T.pick(lang, 'Safeguarding standards and professional conduct are required.', 'بچوں کی حفاظت اور پیشہ ورانہ اخلاق لازمی ہیں۔', 'Schutzstandards und professionelles Verhalten sind verpflichtend.', 'معايير حماية الطفل والسلوك المهني إلزامية.'))),
        ]),
      ])),
    ]);
  }
}
class StudentPortalPage extends StatelessWidget {
  final AppLanguage lang;
  final String section;
  const StudentPortalPage({super.key, required this.lang, required this.section});

  @override
  Widget build(BuildContext context) {
    return PortalShell(
      lang: lang,
      portalTitle: T.pick(lang, 'Student Portal', 'اسٹوڈنٹ پورٹل', 'Schülerportal', 'بوابة الطالب'),
      portalSubtitle: T.pick(lang, 'Your learning, organised in one place.', 'آپ کی تعلیم، ایک جگہ منظم۔', 'Dein Lernen an einem Ort organisiert.', 'تعلمك منظم في مكان واحد.'),
      accentIcon: Icons.school_outlined,
      cards: [
        PortalCardData(Icons.login_rounded, T.pick(lang, 'Login', 'لاگ اِن', 'Anmelden', 'تسجيل الدخول'), T.pick(lang, 'Secure sign-in screen with email, password and 2FA verification UI.', 'ای میل، پاس ورڈ اور 2FA کے ساتھ محفوظ لاگ اِن اسکرین۔', 'Sichere Anmeldung mit E-Mail, Passwort und 2FA-Oberfläche.', 'واجهة دخول آمنة بالبريد وكلمة المرور والتحقق بخطوتين.')),
        PortalCardData(Icons.video_camera_front_outlined, T.pick(lang, 'Live Classes', 'لائیو کلاسز', 'Live-Unterricht', 'الحصص المباشرة'), T.pick(lang, 'Upcoming Zoom/Google Meet classes, join buttons and class timings.', 'آنے والی Zoom/Google Meet کلاسز، جوائن بٹن اور اوقات۔', 'Kommende Zoom/Google-Meet-Termine mit Teilnahmebuttons.', 'حصص Zoom/Google Meet القادمة مع أزرار الانضمام والمواعيد.')),
        PortalCardData(Icons.assignment_outlined, T.pick(lang, 'Assignments', 'اسائنمنٹس', 'Aufgaben', 'الواجبات'), T.pick(lang, 'View pending work, due dates, submissions and teacher feedback.', 'زیرِ التوا کام، آخری تاریخ، جمع شدہ کام اور استاد کا فیڈبیک۔', 'Offene Aufgaben, Fristen, Abgaben und Feedback.', 'عرض الواجبات والمواعيد والتسليمات وملاحظات المعلم.')),
        PortalCardData(Icons.trending_up_rounded, T.pick(lang, 'Progress', 'پروگریس', 'Fortschritt', 'التقدم'), T.pick(lang, 'Track attendance, course completion, milestones and learning goals.', 'حاضری، کورس تکمیل، سنگِ میل اور تعلیمی اہداف دیکھیں۔', 'Anwesenheit, Kursfortschritt, Meilensteine und Lernziele verfolgen.', 'متابعة الحضور وإكمال الدورة والإنجازات والأهداف التعليمية.')),
        PortalCardData(Icons.workspace_premium_outlined, T.pick(lang, 'Certificates', 'سرٹیفکیٹس', 'Zertifikate', 'الشهادات'), T.pick(lang, 'Preview and download earned course certificates.', 'حاصل شدہ کورس سرٹیفکیٹس دیکھیں اور ڈاؤن لوڈ کریں۔', 'Erworbene Kurszertifikate ansehen und herunterladen.', 'معاينة وتحميل شهادات الدورات المكتسبة.')),
      ],
      showStudentDashboard: true,
    );
  }
}

class ParentPortalPage extends StatelessWidget {
  final AppLanguage lang;
  final String section;
  const ParentPortalPage({super.key, required this.lang, required this.section});

  @override
  Widget build(BuildContext context) {
    return PortalShell(
      lang: lang,
      portalTitle: T.pick(lang, 'Parent Portal', 'والدین پورٹل', 'Elternportal', 'بوابة الوالدين'),
      portalSubtitle: T.pick(lang, 'Stay connected with your child’s learning journey.', 'اپنے بچے کی تعلیمی پیش رفت سے جڑے رہیں۔', 'Bleiben Sie mit dem Lernweg Ihres Kindes verbunden.', 'ابقَ على اطلاع بمسيرة تعلم طفلك.'),
      accentIcon: Icons.family_restroom_outlined,
      cards: [
        PortalCardData(Icons.fact_check_outlined, T.pick(lang, 'Attendance', 'حاضری', 'Anwesenheit', 'الحضور'), T.pick(lang, 'Daily and monthly attendance overview with missed-class indicators.', 'روزانہ اور ماہانہ حاضری، غیر حاضر کلاسز کی نشاندہی کے ساتھ۔', 'Tägliche und monatliche Anwesenheitsübersicht.', 'نظرة يومية وشهرية على الحضور مع مؤشرات الغياب.')),
        PortalCardData(Icons.analytics_outlined, T.pick(lang, 'Progress Reports', 'پروگریس رپورٹس', 'Fortschrittsberichte', 'تقارير التقدم'), T.pick(lang, 'Teacher comments, learning milestones and subject-wise performance.', 'استاد کے تبصرے، تعلیمی سنگِ میل اور مضمون وار کارکردگی۔', 'Lehrerkommentare, Lernmeilensteine und Leistungen nach Fach.', 'تعليقات المعلم والإنجازات والأداء حسب المادة.')),
        PortalCardData(Icons.account_balance_wallet_outlined, T.pick(lang, 'Fee Status', 'فیس اسٹیٹس', 'Gebührenstatus', 'حالة الرسوم'), T.pick(lang, 'Invoices, paid amounts, upcoming dues and online payment UI.', 'انوائسز، ادا شدہ رقم، آنے والی واجبات اور آن لائن پیمنٹ UI۔', 'Rechnungen, Zahlungen, Fälligkeiten und Online-Zahlungsoberfläche.', 'الفواتير والمبالغ المدفوعة والمستحقات وواجهة الدفع الإلكتروني.')),
        PortalCardData(Icons.forum_outlined, T.pick(lang, 'Communication', 'کمیونیکیشن', 'Kommunikation', 'التواصل'), T.pick(lang, 'Message teachers and student support from a central inbox.', 'ایک مرکزی ان باکس سے اساتذہ اور اسٹوڈنٹ سپورٹ کو پیغام بھیجیں۔', 'Lehrkräfte und Support über einen zentralen Posteingang kontaktieren.', 'مراسلة المعلمين ودعم الطلاب من صندوق وارد مركزي.')),
      ],
      showStudentDashboard: false,
    );
  }
}

class PortalShell extends StatelessWidget {
  final AppLanguage lang;
  final String portalTitle;
  final String portalSubtitle;
  final IconData accentIcon;
  final List<PortalCardData> cards;
  final bool showStudentDashboard;

  const PortalShell({
    super.key,
    required this.lang,
    required this.portalTitle,
    required this.portalSubtitle,
    required this.accentIcon,
    required this.cards,
    required this.showStudentDashboard,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      PageHero(icon: accentIcon, eyebrow: T.pick(lang, 'SECURE PORTAL', 'محفوظ پورٹل', 'SICHERES PORTAL', 'بوابة آمنة'), title: portalTitle, description: portalSubtitle),
      SectionShell(child: Column(children: [
        ResponsiveTwoColumn(
          left: PortalLoginMock(lang: lang, title: portalTitle),
          right: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SectionEyebrow(T.pick(lang, 'PORTAL PREVIEW', 'پورٹل پری ویو', 'PORTAL-VORSCHAU', 'معاينة البوابة')),
            const SizedBox(height: 12),
            SectionTitle(T.pick(lang, 'Everything important, at a glance.', 'تمام اہم چیزیں، ایک نظر میں۔', 'Alles Wichtige auf einen Blick.', 'كل ما يهمك في لمحة واحدة.')),
            const SizedBox(height: 20),
            PortalDashboardMock(lang: lang, student: showStudentDashboard),
          ]),
        ),
        const SizedBox(height: 42),
        ResponsiveGrid(minItemWidth: 300, children: cards.map((e) => PortalFeatureCard(data: e)).toList()),
      ])),
    ]);
  }
}

class CommunityPage extends StatelessWidget {
  final AppLanguage lang;
  final String section;
  const CommunityPage({super.key, required this.lang, required this.section});

  @override
  Widget build(BuildContext context) {
    final items = [
      CommunityData(Icons.event_outlined, T.pick(lang, 'Events', 'ایونٹس', 'Veranstaltungen', 'الفعاليات'), T.pick(lang, 'Online and local gatherings, workshops and family sessions.', 'آن لائن اور مقامی اجتماعات، ورکشاپس اور فیملی سیشنز۔', 'Online- und Vor-Ort-Veranstaltungen, Workshops und Familientreffen.', 'فعاليات عبر الإنترنت ومحلية وورش عمل وجلسات عائلية.')),
      CommunityData(Icons.groups_3_outlined, T.pick(lang, 'Youth Club', 'یوتھ کلب', 'Jugendclub', 'نادي الشباب'), T.pick(lang, 'A safe space for identity, friendships, mentoring and service.', 'شناخت، دوستی، رہنمائی اور خدمت کے لیے محفوظ جگہ۔', 'Ein sicherer Raum für Identität, Freundschaft, Mentoring und Engagement.', 'مساحة آمنة للهوية والصداقة والإرشاد والخدمة.')),
      CommunityData(Icons.volunteer_activism_outlined, T.pick(lang, 'Volunteer', 'رضاکار', 'Ehrenamt', 'التطوع'), T.pick(lang, 'Give your time and skills to support learners and community projects.', 'طلبہ اور کمیونٹی پروجیکٹس کے لیے اپنا وقت اور مہارت دیں۔', 'Zeit und Fähigkeiten für Lernende und Community-Projekte einsetzen.', 'قدّم وقتك ومهاراتك لدعم الطلاب ومشاريع المجتمع.')),
      CommunityData(Icons.article_outlined, T.pick(lang, 'Blogs', 'بلاگز', 'Blogs', 'المدونة'), T.pick(lang, 'Practical reflections on faith, family, learning and Muslim life.', 'ایمان، خاندان، تعلیم اور مسلم زندگی پر عملی مضامین۔', 'Praktische Impulse zu Glaube, Familie, Lernen und muslimischem Leben.', 'مقالات عملية حول الإيمان والأسرة والتعلم والحياة المسلمة.')),
      CommunityData(Icons.mark_email_read_outlined, T.pick(lang, 'Newsletter', 'نیوز لیٹر', 'Newsletter', 'النشرة البريدية'), T.pick(lang, 'Monthly learning notes, events and updates from HILM.', 'HILM سے ماہانہ تعلیمی نوٹس، ایونٹس اور اپڈیٹس۔', 'Monatliche Lernimpulse, Veranstaltungen und Neuigkeiten von HILM.', 'ملاحظات تعليمية شهرية وفعاليات وأخبار من HILM.')),
    ];
    return Column(children: [
      PageHero(icon: Icons.diversity_3_outlined, eyebrow: T.pick(lang, 'COMMUNITY', 'کمیونٹی', 'COMMUNITY', 'المجتمع'), title: T.pick(lang, 'Learning is stronger together.', 'مل کر سیکھنا زیادہ مضبوط ہے۔', 'Gemeinsam lernt es sich besser.', 'التعلم أقوى معاً.'), description: T.pick(lang, 'Connect beyond the classroom through events, youth programs, volunteering and meaningful content.', 'کلاس روم سے آگے ایونٹس، یوتھ پروگرامز، رضاکارانہ خدمت اور بامقصد مواد کے ذریعے جڑیں۔', 'Über den Unterricht hinaus durch Veranstaltungen, Jugendprogramme, Ehrenamt und Inhalte verbunden bleiben.', 'تواصل خارج الفصل عبر الفعاليات وبرامج الشباب والتطوع والمحتوى الهادف.')),
      SectionShell(child: Column(children: [
        ResponsiveGrid(minItemWidth: 300, children: items.map((e) => CommunityCard(data: e)).toList()),
        const SizedBox(height: 38),
        NewsletterBox(lang: lang),
      ])),
    ]);
  }
}

class MediaPage extends StatelessWidget {
  final AppLanguage lang;
  final String section;
  const MediaPage({super.key, required this.lang, required this.section});

  @override
  Widget build(BuildContext context) {
    final media = [
      MediaData(Icons.play_circle_outline_rounded, T.pick(lang, 'Videos', 'ویڈیوز', 'Videos', 'الفيديوهات'), '48', T.pick(lang, 'Lectures, course previews and community highlights.', 'لیکچرز، کورس پری ویوز اور کمیونٹی جھلکیاں۔', 'Vorträge, Kursvorschauen und Community-Highlights.', 'محاضرات ومعاينات للدورات ولقطات من المجتمع.')),
      MediaData(Icons.photo_library_outlined, T.pick(lang, 'Gallery', 'گیلری', 'Galerie', 'المعرض'), '120+', T.pick(lang, 'Moments from events, workshops and student activities.', 'ایونٹس، ورکشاپس اور طلبہ کی سرگرمیوں کی جھلکیاں۔', 'Momente aus Veranstaltungen, Workshops und Aktivitäten.', 'لحظات من الفعاليات وورش العمل وأنشطة الطلاب.')),
      MediaData(Icons.menu_book_outlined, T.pick(lang, 'Publications', 'پبلیکیشنز', 'Publikationen', 'المنشورات'), '24', T.pick(lang, 'Guides, booklets and learning resources from HILM.', 'HILM کی گائیڈز، کتابچے اور تعلیمی وسائل۔', 'Leitfäden, Broschüren und Lernressourcen von HILM.', 'أدلة وكتيبات ومواد تعليمية من HILM.')),
      MediaData(Icons.download_outlined, T.pick(lang, 'Downloads', 'ڈاؤن لوڈز', 'Downloads', 'التنزيلات'), '60+', T.pick(lang, 'Worksheets, planners and student support materials.', 'ورک شیٹس، پلانرز اور طلبہ کے معاون مواد۔', 'Arbeitsblätter, Planer und Lernmaterialien.', 'أوراق عمل ومخططات ومواد دعم للطلاب.')),
    ];
    return Column(children: [
      PageHero(icon: Icons.perm_media_outlined, eyebrow: T.pick(lang, 'MEDIA', 'میڈیا', 'MEDIEN', 'الإعلام'), title: T.pick(lang, 'Watch, read, reflect and learn.', 'دیکھیں، پڑھیں، غور کریں اور سیکھیں۔', 'Ansehen, lesen, reflektieren und lernen.', 'شاهد واقرأ وتأمل وتعلم.'), description: T.pick(lang, 'Explore HILM videos, galleries, publications and downloadable resources.', 'HILM کی ویڈیوز، گیلری، پبلیکیشنز اور ڈاؤن لوڈ وسائل دیکھیں۔', 'Entdecken Sie Videos, Galerien, Publikationen und Downloads von HILM.', 'استكشف فيديوهات HILM ومعارضه ومنشوراته وموارده القابلة للتنزيل.')),
      SectionShell(child: ResponsiveGrid(minItemWidth: 320, children: media.map((e) => MediaCard(data: e, lang: lang)).toList())),
    ]);
  }
}
class DonatePage extends StatelessWidget {
  final AppLanguage lang;
  final String section;
  const DonatePage({super.key, required this.lang, required this.section});

  @override
  Widget build(BuildContext context) {
    final options = [
      DonationData('sponsor', Icons.school_outlined, T.pick(lang, 'Sponsor a Student', 'ایک طالب علم کی کفالت', 'Schüler fördern', 'اكفل طالباً'), T.pick(lang, 'Fund classes for a learner whose family needs financial support.', 'ایسے طالب علم کی کلاسز سپانسر کریں جس کے خاندان کو مالی مدد درکار ہو۔', 'Finanzieren Sie Unterricht für Lernende aus bedürftigen Familien.', 'موّل دروس طالب تحتاج أسرته إلى دعم مالي.')),
      DonationData('zakat', Icons.favorite_outline_rounded, 'Zakat', T.pick(lang, 'Direct eligible Zakat toward approved student support cases.', 'مستحق طلبہ کے منظور شدہ کیسز کے لیے زکوٰۃ دیں۔', 'Zakat für geprüfte und berechtigte Unterstützungsfälle.', 'وجّه الزكاة إلى حالات دعم طلاب مستحقة ومعتمدة.')),
      DonationData('sadaqah', Icons.volunteer_activism_outlined, 'Sadaqah', T.pick(lang, 'Support learning resources, scholarships and community initiatives.', 'تعلیمی وسائل، اسکالرشپس اور کمیونٹی اقدامات میں مدد کریں۔', 'Lernressourcen, Stipendien und Community-Initiativen unterstützen.', 'ادعم الموارد التعليمية والمنح ومبادرات المجتمع.')),
      DonationData('general', Icons.card_giftcard_outlined, T.pick(lang, 'General Donation', 'عمومی عطیہ', 'Allgemeine Spende', 'تبرع عام'), T.pick(lang, 'Give where the need is greatest across HILM programs.', 'HILM پروگرامز میں جہاں سب سے زیادہ ضرورت ہو وہاں مدد کریں۔', 'Unterstützen Sie dort, wo der Bedarf bei HILM am größten ist.', 'ساهم حيث تكون الحاجة أكبر عبر برامج HILM.')),
    ];
    return Column(children: [
      PageHero(icon: Icons.volunteer_activism_outlined, eyebrow: T.pick(lang, 'DONATE', 'عطیہ', 'SPENDEN', 'تبرع'), title: T.pick(lang, 'Give knowledge. Multiply impact.', 'علم دیں، اثر بڑھائیں۔', 'Wissen schenken. Wirkung vervielfachen.', 'امنح العلم وضاعف الأثر.'), description: T.pick(lang, 'Support access to Islamic learning through sponsorship, Zakat, Sadaqah or a general donation.', 'کفالت، زکوٰۃ، صدقہ یا عمومی عطیہ کے ذریعے اسلامی تعلیم تک رسائی میں مدد کریں۔', 'Unterstützen Sie islamische Bildung durch Förderung, Zakat, Sadaqah oder allgemeine Spenden.', 'ادعم الوصول إلى التعليم الإسلامي عبر الكفالة والزكاة والصدقة أو التبرع العام.')),
      SectionShell(child: ResponsiveTwoColumn(
        left: Column(children: options.map((e) => Padding(padding: const EdgeInsets.only(bottom: 14), child: DonationOptionCard(data: e, highlighted: e.id == section))).toList()),
        right: DonationFormMock(lang: lang),
      )),
      Container(color: Colors.white, child: SectionShell(vertical: 42, child: ResponsiveGrid(minItemWidth: 260, children: [
        FeatureCard(data: FeatureData(Icons.lock_outline_rounded, T.pick(lang, 'Secure Checkout', 'محفوظ ادائیگی', 'Sicher bezahlen', 'دفع آمن'), T.pick(lang, 'Frontend-ready payment flow prepared for gateway integration.', 'پیمنٹ گیٹ وے انٹیگریشن کے لیے فرنٹ اینڈ فلو تیار ہے۔', 'Frontend-Zahlungsablauf ist für Gateway-Integration vorbereitet.', 'واجهة الدفع جاهزة للربط مع بوابة الدفع.'))),
        FeatureCard(data: FeatureData(Icons.receipt_long_outlined, T.pick(lang, 'Donation Receipt', 'عطیہ رسید', 'Spendenbeleg', 'إيصال التبرع'), T.pick(lang, 'Receipt and confirmation screens are included in the experience.', 'رسید اور کنفرمیشن اسکرینز تجربے میں شامل ہیں۔', 'Beleg- und Bestätigungsansichten sind enthalten.', 'شاشات الإيصال والتأكيد مشمولة في التجربة.'))),
        FeatureCard(data: FeatureData(Icons.public_outlined, T.pick(lang, 'International Giving', 'عالمی عطیات', 'International spenden', 'تبرع دولي'), T.pick(lang, 'Currency-ready UI for donors across HILM countries.', 'HILM ممالک کے عطیہ دہندگان کے لیے کرنسی ریڈی UI۔', 'Währungsfähige Oberfläche für internationale Spenden.', 'واجهة جاهزة للعملات للمتبرعين من مختلف الدول.'))),
      ]))),
    ]);
  }
}

class ContactPage extends StatelessWidget {
  final AppLanguage lang;
  final String section;
  const ContactPage({super.key, required this.lang, required this.section});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      PageHero(icon: Icons.support_agent_outlined, eyebrow: T.pick(lang, 'CONTACT', 'رابطہ', 'KONTAKT', 'تواصل'), title: T.pick(lang, 'We’re here to help.', 'ہم آپ کی مدد کے لیے حاضر ہیں۔', 'Wir helfen Ihnen gerne.', 'نحن هنا لمساعدتك.'), description: T.pick(lang, 'Contact HILM by form, WhatsApp or email, explore locations and find quick answers in the FAQ.', 'فارم، واٹس ایپ یا ای میل سے رابطہ کریں، لوکیشنز دیکھیں اور FAQ میں فوری جواب حاصل کریں۔', 'Kontakt per Formular, WhatsApp oder E-Mail sowie Standorte und FAQ.', 'تواصل عبر النموذج أو واتساب أو البريد واستعرض المواقع والأسئلة الشائعة.')),
      SectionShell(child: ResponsiveTwoColumn(
        left: ContactFormMock(lang: lang),
        right: Column(children: [
          ContactMethod(icon: Icons.chat_outlined, title: 'WhatsApp', value: '+49 000 000 0000', action: T.pick(lang, 'Start chat', 'چیٹ شروع کریں', 'Chat starten', 'ابدأ المحادثة')),
          const SizedBox(height: 14),
          ContactMethod(icon: Icons.email_outlined, title: T.pick(lang, 'Email', 'ای میل', 'E-Mail', 'البريد الإلكتروني'), value: 'hello@hilm.example', action: T.pick(lang, 'Send email', 'ای میل بھیجیں', 'E-Mail senden', 'أرسل بريداً')),
          const SizedBox(height: 14),
          ContactMethod(icon: Icons.schedule_outlined, title: T.pick(lang, 'Support Hours', 'سپورٹ اوقات', 'Supportzeiten', 'ساعات الدعم'), value: 'Mon–Sat • 09:00–20:00', action: T.pick(lang, 'Local time varies', 'مقامی وقت مختلف ہو سکتا ہے', 'Lokale Zeiten variieren', 'يختلف حسب التوقيت المحلي')),
        ]),
      )),
      Container(color: Colors.white, child: SectionShell(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionTitle(T.pick(lang, 'Locations', 'لوکیشنز', 'Standorte', 'المواقع')),
        const SizedBox(height: 22),
        ResponsiveGrid(minItemWidth: 280, children: const [
          LocationCard(city: 'Berlin', country: 'Germany', icon: '🇩🇪'),
          LocationCard(city: 'London', country: 'United Kingdom', icon: '🇬🇧'),
          LocationCard(city: 'Online Campus', country: 'Global', icon: '🌍'),
        ]),
      ]))),
      SectionShell(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionTitle(T.pick(lang, 'Frequently asked questions', 'اکثر پوچھے گئے سوالات', 'Häufige Fragen', 'الأسئلة الشائعة')),
        const SizedBox(height: 16),
        FaqTile(question: T.pick(lang, 'How does the free trial work?', 'مفت ٹرائل کیسے کام کرتا ہے؟', 'Wie funktioniert die kostenlose Probestunde?', 'كيف تعمل التجربة المجانية؟'), answer: T.pick(lang, 'Submit the trial form and the support team will match you with a suitable teacher and time slot.', 'ٹرائل فارم جمع کریں، سپورٹ ٹیم آپ کے لیے مناسب استاد اور وقت منتخب کرے گی۔', 'Nach dem Formular ordnet das Support-Team eine passende Lehrkraft und Zeit zu.', 'أرسل نموذج التجربة وسيختار فريق الدعم معلماً وموعداً مناسبين.')),
        FaqTile(question: T.pick(lang, 'Can I choose my class timing?', 'کیا میں کلاس کا وقت منتخب کر سکتا ہوں؟', 'Kann ich meine Unterrichtszeit wählen?', 'هل يمكنني اختيار موعد الحصة؟'), answer: T.pick(lang, 'Yes. Available slots are shown according to your country and teacher availability.', 'جی ہاں، دستیاب اوقات آپ کے ملک اور استاد کی دستیابی کے مطابق دکھائے جاتے ہیں۔', 'Ja. Verfügbare Zeiten richten sich nach Land und Lehrkraft.', 'نعم. تظهر المواعيد المتاحة حسب بلدك وتوفر المعلم.')),
        FaqTile(question: T.pick(lang, 'Are classes recorded?', 'کیا کلاسز ریکارڈ ہوتی ہیں؟', 'Werden Kurse aufgezeichnet?', 'هل يتم تسجيل الحصص؟'), answer: T.pick(lang, 'Recording availability depends on the program and safeguarding policy.', 'ریکارڈنگ کی دستیابی پروگرام اور حفاظتی پالیسی پر منحصر ہے۔', 'Aufzeichnungen hängen vom Programm und den Schutzrichtlinien ab.', 'توفر التسجيل يعتمد على البرنامج وسياسة الحماية.')),
      ])),
    ]);
  }
}

class LegalPage extends StatelessWidget {
  final AppLanguage lang;
  final String section;
  const LegalPage({super.key, required this.lang, required this.section});

  @override
  Widget build(BuildContext context) {
    final selected = section.isEmpty ? 'privacy' : section;
    final docs = <String, LegalDoc>{
      'privacy': LegalDoc(T.pick(lang, 'Privacy Policy', 'پرائیویسی پالیسی', 'Datenschutzerklärung', 'سياسة الخصوصية'), T.pick(lang, 'This frontend placeholder explains how HILM may collect, use, store and protect account, learning and contact information. Final legal wording must be reviewed for the operating entity and jurisdictions before launch.', 'یہ فرنٹ اینڈ پلیس ہولڈر وضاحت کرتا ہے کہ HILM اکاؤنٹ، تعلیمی اور رابطہ معلومات کیسے جمع، استعمال، محفوظ اور تحفظ کر سکتا ہے۔ لانچ سے پہلے حتمی قانونی متن کی متعلقہ ماہر سے جانچ ضروری ہے۔', 'Dieser Frontend-Platzhalter beschreibt die mögliche Erhebung, Nutzung, Speicherung und den Schutz von Konto-, Lern- und Kontaktdaten. Die endgültige Fassung muss vor dem Start rechtlich geprüft werden.', 'يوضح هذا النص المؤقت كيفية جمع بيانات الحساب والتعلم والتواصل واستخدامها وحمايتها. يجب مراجعة الصياغة القانونية النهائية قبل الإطلاق.')),
      'terms': LegalDoc(T.pick(lang, 'Terms & Conditions', 'شرائط و ضوابط', 'Allgemeine Geschäftsbedingungen', 'الشروط والأحكام'), T.pick(lang, 'Covers account use, course access, acceptable behaviour, payment responsibilities and service limitations in frontend placeholder form.', 'اکاؤنٹ استعمال، کورس رسائی، مناسب رویہ، ادائیگی کی ذمہ داری اور سروس کی حدود کا فرنٹ اینڈ پلیس ہولڈر۔', 'Behandelt Kontonutzung, Kurszugang, Verhalten, Zahlungen und Leistungsgrenzen als Frontend-Platzhalter.', 'يغطي استخدام الحساب والوصول للدورات والسلوك والمدفوعات وحدود الخدمة كنص مؤقت.')),
      'cookie': LegalDoc(T.pick(lang, 'Cookie Policy', 'کوکی پالیسی', 'Cookie-Richtlinie', 'سياسة ملفات الارتباط'), T.pick(lang, 'Explains essential, analytics and preference cookies with consent controls designed for GDPR-aware deployment.', 'ضروری، اینالیٹکس اور ترجیحی کوکیز کی وضاحت، GDPR کے مطابق رضامندی کنٹرولز کے ساتھ۔', 'Erläutert notwendige, Analyse- und Präferenz-Cookies mit Einwilligungssteuerung für eine DSGVO-konforme Bereitstellung.', 'تشرح ملفات الارتباط الضرورية والتحليلية والتفضيلية مع عناصر تحكم بالموافقة بما يراعي GDPR.')),
      'gdpr': LegalDoc('GDPR', T.pick(lang, 'Frontend privacy controls include cookie consent, data-access request entry points and clear legal navigation. Backend data retention, export and deletion workflows require server-side implementation.', 'فرنٹ اینڈ میں کوکی رضامندی، ڈیٹا رسائی درخواست اور واضح قانونی نیویگیشن شامل ہے۔ ڈیٹا محفوظ رکھنے، ایکسپورٹ اور حذف کرنے کے لیے بیک اینڈ درکار ہوگا۔', 'Das Frontend enthält Cookie-Einwilligung, Datenzugriffs-Anfragen und klare Rechtsnavigation. Aufbewahrung, Export und Löschung benötigen Backend-Implementierung.', 'تشمل الواجهة موافقة ملفات الارتباط ونقاط طلب الوصول للبيانات وتنقلاً قانونياً واضحاً. يتطلب الاحتفاظ والتصدير والحذف تنفيذاً خلفياً.')),
      'child': LegalDoc(T.pick(lang, 'Child Protection', 'چائلڈ پروٹیکشن', 'Kinderschutz', 'حماية الطفل'), T.pick(lang, 'HILM prioritises safeguarding, age-appropriate interaction, responsible teacher conduct and clear reporting channels. Final policy must match local safeguarding law and operational procedures.', 'HILM بچوں کی حفاظت، عمر کے مطابق تعامل، ذمہ دار اساتذہ اور واضح رپورٹنگ چینلز کو ترجیح دیتا ہے۔ حتمی پالیسی مقامی قانون کے مطابق ہونی چاہیے۔', 'HILM priorisiert Schutz, altersgerechte Interaktion, professionelles Verhalten und klare Meldewege. Die endgültige Richtlinie muss lokales Recht berücksichtigen.', 'تعطي HILM الأولوية لحماية الطفل والتفاعل المناسب للعمر وسلوك المعلم المسؤول وقنوات الإبلاغ الواضحة. يجب مواءمة السياسة النهائية مع القانون المحلي.')),
      'refund': LegalDoc(T.pick(lang, 'Refund Policy', 'ریفنڈ پالیسی', 'Erstattungsrichtlinie', 'سياسة الاسترداد'), T.pick(lang, 'Defines the intended frontend section for trial periods, cancellations, missed classes and eligible refunds. Exact terms should be aligned with payment providers and local consumer law.', 'ٹرائل، کینسلیشن، مسڈ کلاسز اور اہل ریفنڈز کے لیے فرنٹ اینڈ سیکشن۔ حتمی شرائط پیمنٹ پرووائیڈرز اور مقامی قانون کے مطابق ہوں۔', 'Vorgesehener Abschnitt für Probezeit, Kündigung, versäumte Stunden und Erstattungen. Endgültige Regeln müssen zu Zahlungsanbietern und Verbraucherrecht passen.', 'قسم مخصص لفترات التجربة والإلغاء والحصص الفائتة والاسترداد المؤهل. يجب مواءمة الشروط مع مزودي الدفع والقانون المحلي.')),
      'impressum': LegalDoc('Impressum (Germany)', T.pick(lang, 'German legal notice placeholder for company name, authorised representative, registered address, contact details, registration information and responsible content owner.', 'جرمنی کے لیے قانونی نوٹس پلیس ہولڈر جس میں کمپنی نام، مجاز نمائندہ، رجسٹرڈ پتہ، رابطہ، رجسٹریشن معلومات اور ذمہ دار شخص شامل ہوں گے۔', 'Platzhalter für Anbieterkennzeichnung mit Firmenname, Vertretungsberechtigten, Anschrift, Kontakt, Registerangaben und Inhaltsverantwortung.', 'نص مؤقت للإشعار القانوني الألماني ويشمل اسم الشركة والممثل والعنوان وبيانات الاتصال والتسجيل والمسؤول عن المحتوى.')),
    };
    final doc = docs[selected] ?? docs['privacy']!;
    return Column(children: [
      PageHero(icon: Icons.gavel_outlined, eyebrow: T.pick(lang, 'LEGAL', 'قانونی', 'RECHTLICHES', 'قانوني'), title: T.pick(lang, 'Clear policies. Responsible learning.', 'واضح پالیسیاں، ذمہ دار تعلیم۔', 'Klare Richtlinien. Verantwortungsvolles Lernen.', 'سياسات واضحة وتعليم مسؤول.'), description: T.pick(lang, 'Privacy, terms, cookies, GDPR, child protection, refunds and German Impressum sections are all included.', 'پرائیویسی، شرائط، کوکیز، GDPR، چائلڈ پروٹیکشن، ریفنڈ اور جرمن Impressum سب شامل ہیں۔', 'Datenschutz, AGB, Cookies, DSGVO, Kinderschutz, Erstattung und Impressum sind enthalten.', 'الخصوصية والشروط والكوكيز وGDPR وحماية الطفل والاسترداد وImpressum كلها مشمولة.')),
      SectionShell(child: LayoutBuilder(builder: (context, c) {
        final stacked = c.maxWidth < 820;
        final nav = LegalNav(lang: lang, selected: selected);
        final content = Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(doc.title, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: AppColors.ink)),
            const SizedBox(height: 8),
            Text(T.pick(lang, 'Last updated: Frontend draft', 'آخری اپڈیٹ: فرنٹ اینڈ ڈرافٹ', 'Zuletzt aktualisiert: Frontend-Entwurf', 'آخر تحديث: مسودة الواجهة'), style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w700)),
            const SizedBox(height: 24),
            Text(doc.body, style: const TextStyle(fontSize: 16, height: 1.8, color: AppColors.muted)),
            const SizedBox(height: 24),
            ...List.generate(3, (i) => Padding(padding: const EdgeInsets.only(bottom: 18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${i + 1}. ${T.pick(lang, 'Policy section', 'پالیسی سیکشن', 'Richtlinienabschnitt', 'قسم السياسة')}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.ink)), const SizedBox(height: 6), Text(T.pick(lang, 'Detailed production legal copy can be inserted here without changing the page structure or design system.', 'تفصیلی حتمی قانونی متن یہاں بغیر صفحہ اسٹرکچر یا ڈیزائن بدلے شامل کیا جا سکتا ہے۔', 'Der endgültige Rechtstext kann hier ohne Änderung von Struktur oder Design eingefügt werden.', 'يمكن إدراج النص القانوني النهائي هنا دون تغيير هيكل الصفحة أو نظام التصميم.'))]))),
          ]),
        );
        return stacked ? Column(children: [nav, const SizedBox(height: 20), content]) : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 280, child: nav), const SizedBox(width: 24), Expanded(child: content)]);
      })),
    ]);
  }
}

class LegalNav extends StatelessWidget {
  final AppLanguage lang;
  final String selected;
  const LegalNav({super.key, required this.lang, required this.selected});
  @override
  Widget build(BuildContext context) {
    final labels = {
      'privacy': T.pick(lang, 'Privacy Policy', 'پرائیویسی پالیسی', 'Datenschutz', 'سياسة الخصوصية'),
      'terms': T.pick(lang, 'Terms & Conditions', 'شرائط و ضوابط', 'AGB', 'الشروط والأحكام'),
      'cookie': T.pick(lang, 'Cookie Policy', 'کوکی پالیسی', 'Cookie-Richtlinie', 'سياسة الكوكيز'),
      'gdpr': 'GDPR',
      'child': T.pick(lang, 'Child Protection', 'چائلڈ پروٹیکشن', 'Kinderschutz', 'حماية الطفل'),
      'refund': T.pick(lang, 'Refund Policy', 'ریفنڈ پالیسی', 'Erstattung', 'سياسة الاسترداد'),
      'impressum': 'Impressum (Germany)',
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
      child: Column(children: labels.entries.map((e) => Container(
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(color: e.key == selected ? AppColors.greenSoft : Colors.transparent, borderRadius: BorderRadius.circular(12)),
        child: ListTile(dense: true, leading: Icon(Icons.description_outlined, color: e.key == selected ? AppColors.green : AppColors.muted), title: Text(e.value, style: TextStyle(fontWeight: FontWeight.w700, color: e.key == selected ? AppColors.green : AppColors.ink))),
      )).toList()),
    );
  }
}
class PageHero extends StatelessWidget {
  final IconData icon;
  final String eyebrow;
  final String title;
  final String description;
  const PageHero({super.key, required this.icon, required this.eyebrow, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFF6EFE1), Color(0xFFE8F4EE)])),
      child: MaxWidth(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 64),
          child: LayoutBuilder(builder: (context, c) {
            final compact = c.maxWidth < 650;
            final iconBox = Container(width: 74, height: 74, decoration: BoxDecoration(color: AppColors.green, borderRadius: BorderRadius.circular(24)), child: Icon(icon, color: Colors.white, size: 36));
            final copy = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [SectionEyebrow(eyebrow), const SizedBox(height: 8), Text(title, style: TextStyle(fontSize: compact ? 34 : 42, height: 1.1, fontWeight: FontWeight.w900, color: AppColors.ink)), const SizedBox(height: 12), ConstrainedBox(constraints: const BoxConstraints(maxWidth: 880), child: Text(description, style: const TextStyle(fontSize: 17, height: 1.65, color: AppColors.muted)))]);
            if (compact) return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [iconBox, const SizedBox(height: 20), copy]);
            return Row(children: [iconBox, const SizedBox(width: 24), Expanded(child: copy)]);
          }),
        ),
      ),
    );
  }
}

class MaxWidth extends StatelessWidget {
  final Widget child;
  const MaxWidth({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1720),
          child: SizedBox(width: double.infinity, child: child),
        ),
      );
}

class SectionShell extends StatelessWidget {
  final Widget child;
  final double vertical;
  const SectionShell({super.key, required this.child, this.vertical = 70});
  @override
  Widget build(BuildContext context) {
    return MaxWidth(child: Padding(padding: EdgeInsets.symmetric(horizontal: 28, vertical: vertical), child: child));
  }
}

class ResponsiveTwoColumn extends StatelessWidget {
  final Widget left;
  final Widget right;
  const ResponsiveTwoColumn({super.key, required this.left, required this.right});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      if (c.maxWidth < 850) return Column(children: [left, const SizedBox(height: 34), right]);
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: left), const SizedBox(width: 44), Expanded(child: right)]);
    });
  }
}

class ResponsiveGrid extends StatelessWidget {
  final double minItemWidth;
  final List<Widget> children;
  const ResponsiveGrid({super.key, required this.minItemWidth, required this.children});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final count = (c.maxWidth / minItemWidth).floor().clamp(1, 4);
      final itemWidth = (c.maxWidth - ((count - 1) * 18)) / count;
      return Wrap(spacing: 18, runSpacing: 18, children: children.map((e) => SizedBox(width: itemWidth, child: e)).toList());
    });
  }
}

class SectionEyebrow extends StatelessWidget {
  final String text;
  const SectionEyebrow(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontSize: 12, letterSpacing: 1.7, fontWeight: FontWeight.w900, color: AppColors.green));
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontSize: 36, height: 1.15, fontWeight: FontWeight.w900, color: AppColors.ink));
}

class CenteredHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  const CenteredHeader({super.key, required this.eyebrow, required this.title});
  @override
  Widget build(BuildContext context) => Column(children: [SectionEyebrow(eyebrow), const SizedBox(height: 10), Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 38, height: 1.15, fontWeight: FontWeight.w900, color: AppColors.ink))]);
}

class Tag extends StatelessWidget {
  final String text;
  const Tag({super.key, required this.text});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9), decoration: BoxDecoration(color: AppColors.greenSoft, borderRadius: BorderRadius.circular(99)), child: Text(text, style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w800)));
}

class MiniFeature extends StatelessWidget {
  final IconData icon;
  final String text;
  const MiniFeature({super.key, required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 18, color: AppColors.green), const SizedBox(width: 7), Text(text, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink))]);
}

class GlassInfo extends StatelessWidget {
  final String text;
  const GlassInfo({super.key, required this.text});
  @override
  Widget build(BuildContext context) => ClipRRect(borderRadius: BorderRadius.circular(18), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), child: Container(padding: const EdgeInsets.all(18), color: Colors.white.withOpacity(.12), child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17, height: 1.5)))));
}

class InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const InfoChip({super.key, required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11), decoration: BoxDecoration(color: AppColors.greenSoft, borderRadius: BorderRadius.circular(14)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 18, color: AppColors.green), const SizedBox(width: 7), Text(text, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink))]));
}

class FeatureData {
  final IconData icon;
  final String title;
  final String body;
  const FeatureData(this.icon, this.title, this.body);
}

class FeatureCard extends StatelessWidget {
  final FeatureData data;
  const FeatureCard({super.key, required this.data});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(22)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.greenSoft, borderRadius: BorderRadius.circular(14)), child: Icon(data.icon, color: AppColors.green)), const SizedBox(height: 18), Text(data.title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.ink)), const SizedBox(height: 9), Text(data.body, style: const TextStyle(height: 1.6, color: AppColors.muted))]),
      );
}

class ProgramCard extends StatelessWidget {
  final ProgramData data;
  final AppLanguage lang;
  final bool highlighted;
  const ProgramCard({super.key, required this.data, required this.lang, this.highlighted = false});
  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: highlighted ? AppColors.greenSoft : Colors.white, border: Border.all(color: highlighted ? AppColors.green : AppColors.border, width: highlighted ? 1.5 : 1), borderRadius: BorderRadius.circular(24)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Container(width: 52, height: 52, decoration: BoxDecoration(color: AppColors.greenSoft, borderRadius: BorderRadius.circular(16)), child: Icon(data.icon, color: AppColors.green)), const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: AppColors.cream2, borderRadius: BorderRadius.circular(99)), child: Text(data.audience, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.ink)))]),
          const SizedBox(height: 20),
          Text(data.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.ink)),
          const SizedBox(height: 8),
          Text(data.subtitle, style: const TextStyle(height: 1.55, color: AppColors.muted)),
          const SizedBox(height: 18),
          Row(children: [Text(T.pick(lang, 'Learn more', 'مزید جانیں', 'Mehr erfahren', 'اعرف المزيد'), style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w800)), const SizedBox(width: 6), const Icon(Icons.arrow_forward_rounded, size: 17, color: AppColors.green)]),
        ]),
      );
}

class TestimonialData {
  final String name;
  final String role;
  final String quote;
  const TestimonialData(this.name, this.role, this.quote);
}

class TestimonialCard extends StatelessWidget {
  final TestimonialData data;
  const TestimonialCard({super.key, required this.data});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(26), decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Row(children: [Icon(Icons.star_rounded, color: AppColors.gold), Icon(Icons.star_rounded, color: AppColors.gold), Icon(Icons.star_rounded, color: AppColors.gold), Icon(Icons.star_rounded, color: AppColors.gold), Icon(Icons.star_rounded, color: AppColors.gold)]), const SizedBox(height: 18), Text('“${data.quote}”', style: const TextStyle(fontSize: 16, height: 1.7, color: AppColors.ink)), const SizedBox(height: 20), Text(data.name, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.ink)), Text(data.role, style: const TextStyle(color: AppColors.green, fontSize: 13))]));
}

class StatCard extends StatelessWidget {
  final String number;
  final String label;
  const StatCard({super.key, required this.number, required this.label});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(26), decoration: BoxDecoration(color: AppColors.greenDark, borderRadius: BorderRadius.circular(22)), child: Column(children: [Text(number, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.gold)), const SizedBox(height: 4), Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))]));
}

class NewsData {
  final String date;
  final String title;
  final String body;
  const NewsData(this.date, this.title, this.body);
}

class NewsCard extends StatelessWidget {
  final NewsData data;
  const NewsCard({super.key, required this.data});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(data.date, style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w900)), const SizedBox(height: 12), Text(data.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.ink)), const SizedBox(height: 8), Text(data.body, style: const TextStyle(height: 1.55, color: AppColors.muted))]));
}

class DonationVisual extends StatelessWidget {
  const DonationVisual({super.key});
  @override
  Widget build(BuildContext context) => Container(height: 360, decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.gold, Color(0xFFF1D596)]), borderRadius: BorderRadius.circular(30)), child: Stack(children: [const Center(child: Icon(Icons.volunteer_activism_rounded, size: 140, color: Color(0x55064735))), Positioned(left: 26, right: 26, bottom: 26, child: Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: const Row(children: [Icon(Icons.favorite_rounded, color: AppColors.green), SizedBox(width: 12), Expanded(child: Text('Support access. Strengthen families. Build lasting impact.', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink)))])))]));
}

class AnchorCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? body;
  final Widget? bodyWidget;
  final bool highlighted;
  const AnchorCard({super.key, required this.icon, required this.title, this.body, this.bodyWidget, this.highlighted = false});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: highlighted ? AppColors.greenSoft : Colors.white, border: Border.all(color: highlighted ? AppColors.green : AppColors.border), borderRadius: BorderRadius.circular(24)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Container(width: 46, height: 46, decoration: BoxDecoration(color: AppColors.greenSoft, borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: AppColors.green)), const SizedBox(width: 14), Expanded(child: Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.ink)))]), const SizedBox(height: 18), if (body != null) Text(body!, style: const TextStyle(fontSize: 16, height: 1.75, color: AppColors.muted)), if (bodyWidget != null) bodyWidget!]),
      );
}

class ValueTile extends StatelessWidget {
  final IconData icon;
  final String title;
  const ValueTile(this.icon, this.title, {super.key});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(18)), child: Row(children: [Icon(icon, color: AppColors.green), const SizedBox(width: 12), Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink)))]));
}

class PersonCard extends StatelessWidget {
  final String name;
  final String role;
  final IconData icon;
  const PersonCard({super.key, required this.name, required this.role, required this.icon});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(20)), child: Row(children: [CircleAvatar(radius: 28, backgroundColor: AppColors.green, child: Icon(icon, color: Colors.white)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.ink)), Text(role, style: const TextStyle(color: AppColors.muted))]))]));
}

class PartnerBadge extends StatelessWidget {
  final String text;
  const PartnerBadge(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14), decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(14)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.verified_outlined, color: AppColors.green), const SizedBox(width: 8), Text(text, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink))]));
}

class VacancyTile extends StatelessWidget {
  final String title;
  final String type;
  const VacancyTile({super.key, required this.title, required this.type});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(18)), child: Row(children: [const Icon(Icons.work_outline, color: AppColors.green), const SizedBox(width: 12), Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink))), Text(type, style: const TextStyle(fontSize: 12, color: AppColors.muted))]));
}
class CountryData {
  final String id;
  final String name;
  final String flag;
  final String timezone;
  final String currency;
  const CountryData(this.id, this.name, this.flag, this.timezone, this.currency);
}

class CountryCard extends StatelessWidget {
  final CountryData data;
  final bool highlighted;
  final AppLanguage lang;
  const CountryCard({super.key, required this.data, required this.highlighted, required this.lang});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: highlighted ? AppColors.greenSoft : Colors.white, border: Border.all(color: highlighted ? AppColors.green : AppColors.border), borderRadius: BorderRadius.circular(24)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(data.flag, style: const TextStyle(fontSize: 44)), const SizedBox(height: 12), Text(data.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.ink)), const SizedBox(height: 16), _info(Icons.schedule_outlined, data.timezone), const SizedBox(height: 9), _info(Icons.payments_outlined, data.currency), const SizedBox(height: 9), _info(Icons.support_agent_outlined, T.pick(lang, 'Local learner support', 'مقامی طلبہ سپورٹ', 'Lokale Betreuung', 'دعم محلي للطلاب'))]));
  Widget _info(IconData icon, String text) => Row(children: [Icon(icon, size: 18, color: AppColors.green), const SizedBox(width: 8), Expanded(child: Text(text, style: const TextStyle(color: AppColors.muted)))]);
}

class TeacherData {
  final String name;
  final String subject;
  final List<String> qualifications;
  final List<String> languages;
  final String rating;
  const TeacherData(this.name, this.subject, this.qualifications, this.languages, this.rating);
}

class TeacherCard extends StatelessWidget {
  final TeacherData data;
  final AppLanguage lang;
  const TeacherCard({super.key, required this.data, required this.lang});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(24)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [CircleAvatar(radius: 31, backgroundColor: AppColors.greenSoft, child: const Icon(Icons.person_outline_rounded, color: AppColors.green, size: 32)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(data.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.ink)), Text(data.subject, style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w700))])), const Icon(Icons.star_rounded, color: AppColors.gold, size: 20), Text(data.rating, style: const TextStyle(fontWeight: FontWeight.w800))]), const SizedBox(height: 20), Text(T.pick(lang, 'Qualifications', 'قابلیت', 'Qualifikationen', 'المؤهلات'), style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink)), const SizedBox(height: 8), Wrap(spacing: 8, runSpacing: 8, children: data.qualifications.map((e) => TinyChip(e)).toList()), const SizedBox(height: 16), Text(T.pick(lang, 'Languages', 'زبانیں', 'Sprachen', 'اللغات'), style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink)), const SizedBox(height: 8), Wrap(spacing: 8, runSpacing: 8, children: data.languages.map((e) => TinyChip(e)).toList()), const SizedBox(height: 18), Row(children: [const Icon(Icons.rate_review_outlined, size: 18, color: AppColors.green), const SizedBox(width: 8), Expanded(child: Text(T.pick(lang, 'Highly rated by learners', 'طلبہ کی بہترین ریٹنگ', 'Von Lernenden sehr gut bewertet', 'تقييم مرتفع من الطلاب'), style: const TextStyle(color: AppColors.muted)))]) ]));
}

class TinyChip extends StatelessWidget {
  final String text;
  const TinyChip(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(99)), child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ink)));
}

class PortalCardData {
  final IconData icon;
  final String title;
  final String body;
  const PortalCardData(this.icon, this.title, this.body);
}

class PortalFeatureCard extends StatelessWidget {
  final PortalCardData data;
  const PortalFeatureCard({super.key, required this.data});
  @override
  Widget build(BuildContext context) => FeatureCard(data: FeatureData(data.icon, data.title, data.body));
}

class PortalLoginMock extends StatelessWidget {
  final AppLanguage lang;
  final String title;
  const PortalLoginMock({super.key, required this.lang, required this.title});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(28), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(26)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.ink)), const SizedBox(height: 6), Text(T.pick(lang, 'Secure login preview', 'محفوظ لاگ اِن پری ویو', 'Sichere Login-Vorschau', 'معاينة تسجيل الدخول الآمن')), const SizedBox(height: 24), TextField(enabled: false, decoration: InputDecoration(labelText: T.pick(lang, 'Email address', 'ای میل ایڈریس', 'E-Mail-Adresse', 'البريد الإلكتروني'), prefixIcon: const Icon(Icons.email_outlined))), const SizedBox(height: 14), TextField(enabled: false, obscureText: true, decoration: InputDecoration(labelText: T.pick(lang, 'Password', 'پاس ورڈ', 'Passwort', 'كلمة المرور'), prefixIcon: const Icon(Icons.lock_outline))), const SizedBox(height: 14), Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.greenSoft, borderRadius: BorderRadius.circular(14)), child: Row(children: [const Icon(Icons.phonelink_lock, color: AppColors.green), const SizedBox(width: 10), Expanded(child: Text(T.pick(lang, '2FA verification ready', '2FA ویریفکیشن تیار', '2FA-Verifizierung vorbereitet', 'التحقق بخطوتين جاهز'), style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.green)))])), const SizedBox(height: 18), SizedBox(width: double.infinity, child: FilledButton(onPressed: () {}, style: FilledButton.styleFrom(backgroundColor: AppColors.green, foregroundColor: Colors.white, padding: const EdgeInsets.all(17)), child: Text(T.pick(lang, 'Sign In', 'لاگ اِن کریں', 'Anmelden', 'تسجيل الدخول'))))]));
}

class PortalDashboardMock extends StatelessWidget {
  final AppLanguage lang;
  final bool student;
  const PortalDashboardMock({super.key, required this.lang, required this.student});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: AppColors.greenDark, borderRadius: BorderRadius.circular(24)), child: Column(children: [Row(children: [Expanded(child: _metric(student ? '82%' : '94%', student ? T.pick(lang, 'Course progress', 'کورس پروگریس', 'Kursfortschritt', 'تقدم الدورة') : T.pick(lang, 'Attendance', 'حاضری', 'Anwesenheit', 'الحضور'))), const SizedBox(width: 12), Expanded(child: _metric(student ? '3' : '2', student ? T.pick(lang, 'Assignments', 'اسائنمنٹس', 'Aufgaben', 'الواجبات') : T.pick(lang, 'Reports', 'رپورٹس', 'Berichte', 'التقارير')))]), const SizedBox(height: 14), Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(.08), borderRadius: BorderRadius.circular(16)), child: Row(children: [const Icon(Icons.video_camera_front_outlined, color: AppColors.gold), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(T.pick(lang, 'Next live class', 'اگلی لائیو کلاس', 'Nächster Live-Unterricht', 'الحصة المباشرة القادمة'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)), const SizedBox(height: 3), const Text('Quran • Today 18:30', style: TextStyle(color: Color(0xFFD6E9E1)))])), FilledButton(onPressed: () {}, style: FilledButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.greenDark), child: Text(T.pick(lang, 'Join', 'جوائن', 'Beitreten', 'انضم')))]))]));
  Widget _metric(String value, String label) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(.08), borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.gold)), Text(label, style: const TextStyle(color: Colors.white))]));
}

class CommunityData {
  final IconData icon;
  final String title;
  final String body;
  const CommunityData(this.icon, this.title, this.body);
}

class CommunityCard extends StatelessWidget {
  final CommunityData data;
  const CommunityCard({super.key, required this.data});
  @override
  Widget build(BuildContext context) => FeatureCard(data: FeatureData(data.icon, data.title, data.body));
}

class NewsletterBox extends StatelessWidget {
  final AppLanguage lang;
  const NewsletterBox({super.key, required this.lang});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(28), decoration: BoxDecoration(color: AppColors.greenDark, borderRadius: BorderRadius.circular(26)), child: LayoutBuilder(builder: (context, c) { final stacked = c.maxWidth < 720; final copy = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(T.pick(lang, 'Get the HILM newsletter', 'HILM نیوز لیٹر حاصل کریں', 'HILM-Newsletter erhalten', 'اشترك في نشرة HILM'), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)), const SizedBox(height: 7), Text(T.pick(lang, 'Monthly events, learning notes and community updates.', 'ماہانہ ایونٹس، تعلیمی نوٹس اور کمیونٹی اپڈیٹس۔', 'Monatliche Veranstaltungen, Lernimpulse und Updates.', 'فعاليات شهرية وملاحظات تعليمية وأخبار المجتمع.'), style: const TextStyle(color: Color(0xFFD6E9E1)))]); final form = ConstrainedBox(constraints: const BoxConstraints(maxWidth: 460), child: Row(children: [Expanded(child: TextField(decoration: InputDecoration(hintText: 'you@example.com', fillColor: Colors.white, filled: true))), const SizedBox(width: 10), FilledButton(onPressed: () {}, style: FilledButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.greenDark, padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 18)), child: Text(T.pick(lang, 'Subscribe', 'سبسکرائب', 'Abonnieren', 'اشترك')))])); return stacked ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [copy, const SizedBox(height: 20), form]) : Row(children: [Expanded(child: copy), const SizedBox(width: 24), Expanded(child: form)]); }));
}

class MediaData {
  final IconData icon;
  final String title;
  final String count;
  final String body;
  const MediaData(this.icon, this.title, this.count, this.body);
}

class MediaCard extends StatelessWidget {
  final MediaData data;
  final AppLanguage lang;
  const MediaCard({super.key, required this.data, required this.lang});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(26), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(24)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Container(width: 52, height: 52, decoration: BoxDecoration(color: AppColors.greenSoft, borderRadius: BorderRadius.circular(16)), child: Icon(data.icon, color: AppColors.green)), const Spacer(), Text(data.count, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.gold))]), const SizedBox(height: 20), Text(data.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.ink)), const SizedBox(height: 8), Text(data.body, style: const TextStyle(height: 1.6, color: AppColors.muted)), const SizedBox(height: 20), OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.open_in_new_rounded, size: 17), label: Text(T.pick(lang, 'Explore', 'دیکھیں', 'Entdecken', 'استكشف')))]));
}

class DonationData {
  final String id;
  final IconData icon;
  final String title;
  final String body;
  const DonationData(this.id, this.icon, this.title, this.body);
}

class DonationOptionCard extends StatelessWidget {
  final DonationData data;
  final bool highlighted;
  const DonationOptionCard({super.key, required this.data, required this.highlighted});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: highlighted ? AppColors.greenSoft : Colors.white, border: Border.all(color: highlighted ? AppColors.green : AppColors.border), borderRadius: BorderRadius.circular(22)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.greenSoft, borderRadius: BorderRadius.circular(14)), child: Icon(data.icon, color: AppColors.green)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(data.title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: AppColors.ink)), const SizedBox(height: 7), Text(data.body, style: const TextStyle(height: 1.55, color: AppColors.muted))]))]));
}

class DonationFormMock extends StatelessWidget {
  final AppLanguage lang;
  const DonationFormMock({super.key, required this.lang});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(28), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(26), border: Border.all(color: AppColors.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(T.pick(lang, 'Donation checkout', 'ڈونیشن چیک آؤٹ', 'Spenden-Checkout', 'إتمام التبرع'), style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900, color: AppColors.ink)), const SizedBox(height: 20), Wrap(spacing: 10, runSpacing: 10, children: ['€25', '€50', '€100', '€250'].map((e) => ChoiceChip(selected: e == '€50', label: Text(e), onSelected: (_) {})).toList()), const SizedBox(height: 18), TextField(enabled: false, decoration: InputDecoration(labelText: T.pick(lang, 'Custom amount', 'اپنی رقم', 'Eigener Betrag', 'مبلغ مخصص'), prefixIcon: const Icon(Icons.euro))), const SizedBox(height: 14), TextField(enabled: false, decoration: InputDecoration(labelText: T.pick(lang, 'Full name', 'پورا نام', 'Vollständiger Name', 'الاسم الكامل'), prefixIcon: const Icon(Icons.person_outline))), const SizedBox(height: 14), TextField(enabled: false, decoration: InputDecoration(labelText: T.pick(lang, 'Email', 'ای میل', 'E-Mail', 'البريد الإلكتروني'), prefixIcon: const Icon(Icons.email_outlined))), const SizedBox(height: 18), Text(T.pick(lang, 'Payment methods', 'ادائیگی کے طریقے', 'Zahlungsmethoden', 'طرق الدفع'), style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink)), const SizedBox(height: 10), Wrap(spacing: 9, runSpacing: 9, children: const [TinyChip('Card'), TinyChip('PayPal'), TinyChip('Bank Transfer'), TinyChip('Apple / Google Pay')]), const SizedBox(height: 22), SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.lock_outline), label: Text(T.pick(lang, 'Continue Securely', 'محفوظ طریقے سے جاری رکھیں', 'Sicher fortfahren', 'متابعة آمنة')), style: FilledButton.styleFrom(backgroundColor: AppColors.green, foregroundColor: Colors.white, padding: const EdgeInsets.all(17))))]));
}

class ContactFormMock extends StatelessWidget {
  final AppLanguage lang;
  const ContactFormMock({super.key, required this.lang});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(28), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(26)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [SectionEyebrow(T.pick(lang, 'CONTACT FORM', 'رابطہ فارم', 'KONTAKTFORMULAR', 'نموذج التواصل')), const SizedBox(height: 8), Text(T.pick(lang, 'Send us a message', 'ہمیں پیغام بھیجیں', 'Nachricht senden', 'أرسل لنا رسالة'), style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900, color: AppColors.ink)), const SizedBox(height: 20), TextField(decoration: InputDecoration(labelText: T.pick(lang, 'Full name', 'پورا نام', 'Vollständiger Name', 'الاسم الكامل'))), const SizedBox(height: 14), TextField(decoration: InputDecoration(labelText: T.pick(lang, 'Email address', 'ای میل ایڈریس', 'E-Mail-Adresse', 'البريد الإلكتروني'))), const SizedBox(height: 14), TextField(decoration: InputDecoration(labelText: T.pick(lang, 'Phone / WhatsApp', 'فون / واٹس ایپ', 'Telefon / WhatsApp', 'الهاتف / واتساب'))), const SizedBox(height: 14), TextField(maxLines: 5, decoration: InputDecoration(labelText: T.pick(lang, 'How can we help?', 'ہم آپ کی کیسے مدد کر سکتے ہیں؟', 'Wie können wir helfen?', 'كيف يمكننا مساعدتك؟'))), const SizedBox(height: 18), SizedBox(width: double.infinity, child: FilledButton(onPressed: () {}, style: FilledButton.styleFrom(backgroundColor: AppColors.green, foregroundColor: Colors.white, padding: const EdgeInsets.all(17)), child: Text(T.pick(lang, 'Send Message', 'پیغام بھیجیں', 'Nachricht senden', 'إرسال الرسالة'))))]));
}

class ContactMethod extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String action;
  const ContactMethod({super.key, required this.icon, required this.title, required this.value, required this.action});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(20)), child: Row(children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.greenSoft, borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: AppColors.green)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.ink)), Text(value, style: const TextStyle(color: AppColors.muted))])), Text(action, style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w700))]));
}

class LocationCard extends StatelessWidget {
  final String city;
  final String country;
  final String icon;
  const LocationCard({super.key, required this.city, required this.country, required this.icon});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(20)), child: Row(children: [Text(icon, style: const TextStyle(fontSize: 34)), const SizedBox(width: 14), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(city, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.ink)), Text(country, style: const TextStyle(color: AppColors.muted))]) ]));
}

class FaqTile extends StatelessWidget {
  final String question;
  final String answer;
  const FaqTile({super.key, required this.question, required this.answer});
  @override
  Widget build(BuildContext context) => ExpansionTile(tilePadding: const EdgeInsets.symmetric(horizontal: 4), title: Text(question, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink)), children: [Padding(padding: const EdgeInsets.fromLTRB(4, 0, 4, 18), child: Align(alignment: Alignment.centerLeft, child: Text(answer, style: const TextStyle(height: 1.6, color: AppColors.muted))))]);
}

class LegalDoc {
  final String title;
  final String body;
  const LegalDoc(this.title, this.body);
}
Future<void> showTrialDialog(BuildContext context, AppLanguage lang) async {
  await showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                Container(width: 50, height: 50, decoration: BoxDecoration(color: AppColors.greenSoft, borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.play_circle_outline_rounded, color: AppColors.green)),
                const SizedBox(width: 14),
                Expanded(child: Text(T.pick(lang, 'Book a Free Trial', 'مفت ٹرائل بک کریں', 'Kostenlose Probestunde', 'احجز تجربة مجانية'), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.ink))),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ]),
              const SizedBox(height: 20),
              TextField(decoration: InputDecoration(labelText: T.pick(lang, 'Student name', 'طالب علم کا نام', 'Name des Lernenden', 'اسم الطالب'))),
              const SizedBox(height: 14),
              TextField(decoration: InputDecoration(labelText: T.pick(lang, 'Email', 'ای میل', 'E-Mail', 'البريد الإلكتروني'))),
              const SizedBox(height: 14),
              TextField(decoration: InputDecoration(labelText: T.pick(lang, 'Phone / WhatsApp', 'فون / واٹس ایپ', 'Telefon / WhatsApp', 'الهاتف / واتساب'))),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: 'Quran',
                decoration: InputDecoration(labelText: T.pick(lang, 'Interested program', 'پسندیدہ پروگرام', 'Interessiertes Programm', 'البرنامج المطلوب')),
                items: const ['Quran', 'Tajweed', 'Hifz', 'Arabic', 'Islamic Studies', 'Kids / Youth'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (_) {},
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: 'English',
                decoration: InputDecoration(labelText: T.pick(lang, 'Preferred language', 'پسندیدہ زبان', 'Bevorzugte Sprache', 'اللغة المفضلة')),
                items: const ['English', 'Urdu', 'German', 'Arabic'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (_) {},
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(T.pick(lang, 'Request Free Trial', 'مفت ٹرائل کی درخواست دیں', 'Probestunde anfragen', 'اطلب تجربة مجانية')),
                  style: FilledButton.styleFrom(backgroundColor: AppColors.green, foregroundColor: Colors.white, padding: const EdgeInsets.all(18)),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class AiChatCard extends StatelessWidget {
  final AppLanguage lang;
  final VoidCallback onClose;
  const AiChatCard({super.key, required this.lang, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 18,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: MediaQuery.sizeOf(context).width < 392 ? MediaQuery.sizeOf(context).width - 32 : 360,
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [const CircleAvatar(backgroundColor: AppColors.green, child: Icon(Icons.smart_toy_outlined, color: Colors.white)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(T.pick(lang, 'HILM Assistant', 'HILM اسسٹنٹ', 'HILM-Assistent', 'مساعد HILM'), style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.ink)), Text(T.pick(lang, 'AI chatbot frontend preview', 'AI چیٹ بوٹ فرنٹ اینڈ پری ویو', 'KI-Chatbot Frontend-Vorschau', 'معاينة واجهة روبوت المحادثة'), style: const TextStyle(fontSize: 11, color: AppColors.muted))])), IconButton(onPressed: onClose, icon: const Icon(Icons.close))]),
          const SizedBox(height: 14),
          Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.greenSoft, borderRadius: BorderRadius.circular(16)), child: Text(T.pick(lang, 'Assalamu Alaikum! I can help you find a program, teacher, country schedule or free trial.', 'السلام علیکم! میں پروگرام، استاد، ملک کے شیڈول یا مفت ٹرائل کے بارے میں مدد کر سکتا ہوں۔', 'Assalamu Alaikum! Ich helfe bei Programmen, Lehrkräften, Länderzeiten oder Probestunden.', 'السلام عليكم! يمكنني مساعدتك في البرامج والمعلمين والمواعيد والتجربة المجانية.'), style: const TextStyle(height: 1.5, color: AppColors.ink))),
          const SizedBox(height: 12),
          Wrap(spacing: 7, runSpacing: 7, children: [TinyChip(T.pick(lang, 'Find a course', 'کورس تلاش کریں', 'Kurs finden', 'ابحث عن دورة')), TinyChip(T.pick(lang, 'Free trial', 'مفت ٹرائل', 'Probestunde', 'تجربة مجانية')), TinyChip(T.pick(lang, 'Talk to support', 'سپورٹ سے بات کریں', 'Support', 'تحدث للدعم'))]),
          const SizedBox(height: 12),
          TextField(decoration: InputDecoration(hintText: T.pick(lang, 'Type your question...', 'اپنا سوال لکھیں...', 'Frage eingeben...', 'اكتب سؤالك...'), suffixIcon: const Icon(Icons.send_rounded, color: AppColors.green))),
        ]),
      ),
    );
  }
}

class CookieBanner extends StatelessWidget {
  final AppLanguage lang;
  final VoidCallback onAccept;
  final VoidCallback onPolicy;
  const CookieBanner({super.key, required this.lang, required this.onAccept, required this.onPolicy});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980),
        child: Material(
          elevation: 16,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
            child: LayoutBuilder(builder: (context, c) {
              final stacked = c.maxWidth < 700;
              final copy = Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.cookie_outlined, color: AppColors.green), const SizedBox(width: 12), Expanded(child: Text(T.pick(lang, 'We use essential cookies and provide controls for optional analytics/preferences. This frontend is prepared for GDPR-aware consent management.', 'ہم ضروری کوکیز استعمال کرتے ہیں اور اختیاری اینالیٹکس/ترجیحات کے لیے کنٹرول فراہم کرتے ہیں۔ یہ فرنٹ اینڈ GDPR کے مطابق رضامندی مینجمنٹ کے لیے تیار ہے۔', 'Wir verwenden notwendige Cookies und bieten Kontrollen für optionale Analyse/Präferenzen. Das Frontend ist für DSGVO-bewusstes Einwilligungsmanagement vorbereitet.', 'نستخدم ملفات ارتباط ضرورية ونوفر عناصر تحكم للتحليلات والتفضيلات الاختيارية. الواجهة مهيأة لإدارة موافقة تراعي GDPR.'), style: const TextStyle(height: 1.5, color: AppColors.ink)))]);
              final actions = Wrap(spacing: 8, runSpacing: 8, children: [TextButton(onPressed: onPolicy, child: Text(T.pick(lang, 'Cookie Policy', 'کوکی پالیسی', 'Cookie-Richtlinie', 'سياسة الكوكيز'))), FilledButton(onPressed: onAccept, style: FilledButton.styleFrom(backgroundColor: AppColors.green, foregroundColor: Colors.white), child: Text(T.pick(lang, 'Accept', 'قبول کریں', 'Akzeptieren', 'موافق')))]);
              return stacked ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [copy, const SizedBox(height: 12), actions]) : Row(children: [Expanded(child: copy), const SizedBox(width: 14), actions]);
            }),
          ),
        ),
      ),
    );
  }
}

class SiteFooter extends StatelessWidget {
  final AppLanguage lang;
  final void Function(String id, [String section]) onNavigate;
  const SiteFooter({super.key, required this.lang, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final legal = [
      MenuEntry('privacy', T.pick(lang, 'Privacy Policy', 'پرائیویسی پالیسی', 'Datenschutz', 'سياسة الخصوصية')),
      MenuEntry('terms', T.pick(lang, 'Terms & Conditions', 'شرائط و ضوابط', 'AGB', 'الشروط والأحكام')),
      MenuEntry('cookie', T.pick(lang, 'Cookie Policy', 'کوکی پالیسی', 'Cookie-Richtlinie', 'سياسة الكوكيز')),
      const MenuEntry('gdpr', 'GDPR'),
      MenuEntry('child', T.pick(lang, 'Child Protection', 'چائلڈ پروٹیکشن', 'Kinderschutz', 'حماية الطفل')),
      MenuEntry('refund', T.pick(lang, 'Refund Policy', 'ریفنڈ پالیسی', 'Erstattung', 'سياسة الاسترداد')),
      const MenuEntry('impressum', 'Impressum (Germany)'),
    ];
    return Container(
      color: AppColors.greenDark,
      width: double.infinity,
      child: MaxWidth(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 56, 28, 28),
          child: Column(children: [
            LayoutBuilder(builder: (context, c) {
              final stacked = c.maxWidth < 850;
              final brand = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const BrandMarkLight(), const SizedBox(height: 18), SizedBox(width: 360, child: Text(T.pick(lang, 'Accessible, structured Islamic learning for students and families around the world.', 'دنیا بھر کے طلبہ اور خاندانوں کے لیے آسان اور منظم اسلامی تعلیم۔', 'Zugängliche, strukturierte islamische Bildung für Lernende und Familien weltweit.', 'تعليم إسلامي منظم وميسر للطلاب والأسر حول العالم.'), style: const TextStyle(color: Color(0xFFBFD5CC), height: 1.6))), const SizedBox(height: 16), const Wrap(spacing: 10, children: [FooterSocial(Icons.play_arrow_rounded), FooterSocial(Icons.camera_alt_outlined), FooterSocial(Icons.public), FooterSocial(Icons.chat_outlined)])]);
              final links = Wrap(spacing: 42, runSpacing: 30, children: [
                FooterColumn(title: T.pick(lang, 'Explore', 'دیکھیں', 'Entdecken', 'استكشف'), items: [MenuEntry('programs', T.pick(lang, 'Programs', 'پروگرامز', 'Programme', 'البرامج')), MenuEntry('teachers', T.pick(lang, 'Teachers', 'اساتذہ', 'Lehrkräfte', 'المعلمون')), MenuEntry('countries', T.pick(lang, 'Countries', 'ممالک', 'Länder', 'الدول')), MenuEntry('community', T.pick(lang, 'Community', 'کمیونٹی', 'Community', 'المجتمع'))], onTap: (e) => onNavigate(e.value)),
                FooterColumn(title: T.pick(lang, 'Portals', 'پورٹلز', 'Portale', 'البوابات'), items: [MenuEntry('student', T.pick(lang, 'Student Portal', 'اسٹوڈنٹ پورٹل', 'Schülerportal', 'بوابة الطالب')), MenuEntry('parent', T.pick(lang, 'Parent Portal', 'والدین پورٹل', 'Elternportal', 'بوابة الوالدين')), MenuEntry('contact', T.pick(lang, 'Contact', 'رابطہ', 'Kontakt', 'تواصل')), MenuEntry('donate', T.pick(lang, 'Donate', 'عطیہ', 'Spenden', 'تبرع'))], onTap: (e) => onNavigate(e.value)),
                FooterColumn(title: T.pick(lang, 'Legal', 'قانونی', 'Rechtliches', 'قانوني'), items: legal, onTap: (e) => onNavigate('legal', e.value)),
              ]);
              if (stacked) return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [brand, const SizedBox(height: 38), links]);
              return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: brand), const SizedBox(width: 40), Expanded(flex: 2, child: links)]);
            }),
            const SizedBox(height: 42),
            const Divider(color: Color(0x33FFFFFF)),
            const SizedBox(height: 18),
            Wrap(spacing: 24, runSpacing: 8, alignment: WrapAlignment.spaceBetween, children: [Text('© 2026 HILM Institute. ${T.pick(lang, 'All rights reserved.', 'تمام حقوق محفوظ ہیں۔', 'Alle Rechte vorbehalten.', 'جميع الحقوق محفوظة.')}', style: const TextStyle(color: Color(0xFF9EBAB0), fontSize: 12)), const Text('English • اردو • Deutsch • العربية', style: TextStyle(color: Color(0xFF9EBAB0), fontSize: 12))]),
          ]),
        ),
      ),
    );
  }
}

class BrandMarkLight extends StatelessWidget {
  const BrandMarkLight({super.key});
  @override
  Widget build(BuildContext context) => const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.auto_stories_rounded, color: AppColors.gold, size: 38), SizedBox(width: 10), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('HILM', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: Colors.white)), Text('INSTITUTE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 2, color: AppColors.gold))])]);
}

class FooterColumn extends StatelessWidget {
  final String title;
  final List<MenuEntry> items;
  final ValueChanged<MenuEntry> onTap;
  const FooterColumn({super.key, required this.title, required this.items, required this.onTap});
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
            const SizedBox(height: 12),
            ...items.map(
              (e) => InkWell(
                onTap: () => onTap(e),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(e.label, style: const TextStyle(color: Color(0xFFBFD5CC), fontSize: 13)),
                ),
              ),
            ),
          ],
        ),
      );
}

class FooterSocial extends StatelessWidget {
  final IconData icon;
  const FooterSocial(this.icon, {super.key});
  @override
  Widget build(BuildContext context) => Container(width: 38, height: 38, decoration: BoxDecoration(color: Colors.white.withOpacity(.08), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: Colors.white, size: 18));
}
