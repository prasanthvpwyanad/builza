import 'package:builza/core/utils/money.dart';
import 'package:builza/core/utils/validators.dart';
import 'package:builza/core/widgets/company_logo.dart';
import 'package:builza/data/models/cashbook_entry.dart';
import 'package:builza/features/reports/report_math.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('rejects weak company and auth fields', () {
    expect(validateCompanyName(''), isNotNull);
    expect(validateCompanyName('DRUVA'), isNull);
    expect(validateEmail('not-an-email'), isNotNull);
    expect(validateEmail('admin@druva.test'), isNull);
    expect(validateOptionalEmail(''), isNull);
    expect(validatePassword('secret'), isNotNull);
    expect(validatePassword('secret12'), isNull);
    expect(validateConfirmPassword('secret12', 'secret12'), isNull);
    expect(validateInviteCode('ABCD-2345'), isNull);
  });

  test('company initials fall back until a logo is provided', () {
    expect(companyInitials(''), 'CO');
    expect(companyInitials('DRUVA'), 'DR');
    expect(companyInitials('Phino Interiors'), 'PI');
  });

  test('parses and formats rupee amounts', () {
    expect(parseRupees('2500'), 2500);
    expect(parseRupees('2,500'), 2500);
    expect(parseRupees(''), isNull);
    expect(formatSignedInr(2500, paid: true), contains('2,500'));
  });

  test('report totals split received and paid', () {
    final entries = [
      CashbookEntry(
        id: '1',
        type: 'received',
        amount: 10000,
        projectId: 'a',
        projectName: 'A',
        category: 'Advance',
        paymentMode: 'Cash',
        description: 'Advance',
        createdBy: 'u',
        createdByName: 'Admin',
        createdAt: DateTime(2026, 11, 1),
      ),
      CashbookEntry(
        id: '2',
        type: 'paid',
        amount: 2500,
        projectId: 'a',
        projectName: 'A',
        category: 'Material',
        paymentMode: 'UPI',
        description: 'Cement',
        createdBy: 'u',
        createdByName: 'Admin',
        createdAt: DateTime(2026, 11, 2),
      ),
    ];
    final split = totalsOf(entries);
    expect(split.received, 10000);
    expect(split.paid, 2500);
    expect(split.balance, 7500);
    expect(paidByCategory(entries)['Material'], 2500);
  });
}
