import 'package:flutter/material.dart';
import 'package:flyem_app/core/app_theme.dart';

/// شاشة الخصوصية وشروط الاستخدام.
class PrivacyTermsScreen extends StatelessWidget {
  const PrivacyTermsScreen({super.key});

  static const String _title = 'الخصوصية وشروط الاستخدام';
  static const String _privacyHeading = 'سياسة الخصوصية';
  static const String _termsHeading = 'شروط الاستخدام';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(
          backgroundColor: const Color(0xFF2C2C2E),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            _title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionHeading(title: _privacyHeading),
                const SizedBox(height: 12),
                Text(
                  _privacyText,
                  style: TextStyle(fontSize: 15, height: 1.6, color: Colors.grey[800]),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 28),
                _SectionHeading(title: _termsHeading),
                const SizedBox(height: 12),
                Text(
                  _termsText,
                  style: TextStyle(fontSize: 15, height: 1.6, color: Colors.grey[800]),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      textAlign: TextAlign.right,
    );
  }
}

const String _privacyText = '''
نحن في فلاي إم نحترم خصوصيتك. تُستخدم بياناتك الشخصية (الاسم، البريد الإلكتروني، رقم الهاتف) لتقديم الخدمة وتسهيل التواصل بين الشاحنين والمسافرين. لا نشارك بياناتك مع أطراف ثالثة لأغراض تسويقية دون موافقتك. نحتفظ بحقك في طلب الوصول إلى بياناتك أو تصحيحها أو حذفها وفقاً للقانون المعمول به.
''';

const String _termsText = '''
١. القبول: باستخدام تطبيق فلاي إم، فإنك توافق على الالتزام بهذه الشروط.

٢. الخدمة: المنصة تربط بين المستخدمين الراغبين في إرسال شحنات (الشاحنين) والمسافرين القادرين على نقلها. لا نضمن تنفيذ أي صفقة؛ العلاقة التعاقدية بين الشاحن والمسافر.

٣. المسؤولية: المستخدم مسؤول عن دقة بياناته ومحتوى إعلاناته. لا نتحمل مسؤولية الخسائر الناجمة عن تعاملات بين المستخدمين خارج ضمانات المنصة.

٤. السلوك: يُمنع نشر محتوى مخالف للقانون أو مسيء أو احتيالي. نحتفظ بحق تعليق أو حذف الحسابات المخالفة.

٥. التعديلات: قد نعدّل الشروط أو سياسة الخصوصية مع إشعارك عند الاستمرار في استخدام التطبيق بعد التحديث.
''';
