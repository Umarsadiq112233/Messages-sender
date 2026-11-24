import 'dart:math';

import '../core/utils/phone.dart';
import 'models.dart';

/// Realistic demo data so every screen has something to show until the
/// backend (Phase 3) is connected. All names/numbers are fictional.
class SampleData {
  SampleData._(this.groups, this.contacts, this.campaigns, this.activities);

  final List<Group> groups;
  final List<Contact> contacts;
  final List<Campaign> campaigns;
  final List<Activity> activities;

  static FailReason randomFailure(Random rng) => const [
    FailReason.networkBusy,
    FailReason.numberOff,
    FailReason.timeout,
    FailReason.lowBalance,
    FailReason.notExist,
  ][rng.nextInt(5)];

  static const messages = [
    'Assalam-o-Alaikum! Hamari Winter Sale shuru ho gayi hai — har cheez par 30% off. Aaj hi tashreef layen. Shukriya!',
    'Dear Student, kal ki class subah 10 baje hogi. Apni assignment saath zaroor layen.',
    'Payment reminder: Aap ki qist 25 tareekh tak jama karwa dein. Shukriya.',
    'Staff meeting aaj shaam 5 baje office mein hogi. Waqt ki pabandi karein.',
    'عید مبارک! آپ اور آپ کے اہل خانہ کو دلی مبارکباد۔',
    'Naya stock aa gaya hai! Order ke liye isi number par rabta karein.',
    'Reminder: Kal parents-teacher meeting hai, 11 baje. Zaroor tashreef layen.',
  ];

  static const _first = [
    'Ali',
    'Ahmed',
    'Fatima',
    'Ayesha',
    'Usman',
    'Bilal',
    'Hira',
    'Zainab',
    'Hamza',
    'Sana',
    'Imran',
    'Nadia',
    'Kashif',
    'Saad',
    'Mariam',
    'Fahad',
    'Rabia',
    'Waqas',
    'Sobia',
    'Junaid',
    'Mehwish',
    'Asad',
    'Komal',
    'Danish',
    'Iqra',
    'Talha',
    'Areeba',
    'Shoaib',
    'Noor',
    'Haris',
  ];
  static const _last = [
    'Raza',
    'Khan',
    'Noor',
    'Siddiqui',
    'Tariq',
    'Ahmed',
    'Shah',
    'Malik',
    'Iqbal',
    'Javed',
    'Qureshi',
    'Hussain',
    'Mehmood',
    'Butt',
    'Akhtar',
    'Aslam',
    'Anwar',
    'Haider',
    'Rehman',
    'Akram',
  ];
  static const _prefixes = ['0300', '0301', '0302', '0312', '0315', '0321', '0322', '0333', '0336', '0345', '0346'];
  static const _notes = ['Regular customer', 'Fee pending', 'Wholesale', 'Morning batch', 'VIP', ''];

  static SampleData generate() {
    final rng = Random(7);
    final now = DateTime.now();
    var seq = 1;
    String id(String p) => '$p${seq++}';

    final groups = [
      Group(id: 'g1', name: 'Customers', colorIndex: 0, createdAt: now.subtract(const Duration(days: 60))),
      Group(id: 'g2', name: 'Students', colorIndex: 1, createdAt: now.subtract(const Duration(days: 55))),
      Group(id: 'g3', name: 'Staff', colorIndex: 2, createdAt: now.subtract(const Duration(days: 50))),
      Group(id: 'g4', name: 'Suppliers', colorIndex: 3, createdAt: now.subtract(const Duration(days: 40))),
    ];
    const groupWeights = ['g1', 'g1', 'g1', 'g2', 'g2', 'g2', 'g3', 'g4', null];

    final usedPhones = <String>{};
    final contacts = <Contact>[];
    for (var i = 0; i < 68; i++) {
      String phone;
      do {
        final p = _prefixes[rng.nextInt(_prefixes.length)];
        phone = '$p${List.generate(7, (_) => rng.nextInt(10)).join()}';
      } while (!usedPhones.add(phone));
      contacts.add(
        Contact(
          id: id('c'),
          name: '${_first[rng.nextInt(_first.length)]} ${_last[rng.nextInt(_last.length)]}',
          phone: phone,
          groupId: groupWeights[rng.nextInt(groupWeights.length)],
          note: rng.nextInt(4) == 0 ? _notes[rng.nextInt(_notes.length)] : '',
          createdAt: now.subtract(Duration(days: rng.nextInt(45), hours: rng.nextInt(20), minutes: rng.nextInt(60))),
        ),
      );
    }
    contacts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final campaigns = <Campaign>[];
    final activities = <Activity>[];
    final plan = <(int, int, String?)>[
      (6, 42, 'g1'),
      (5, 28, 'g2'),
      (4, 64, null),
      (3, 18, 'g3'),
      (2, 51, 'g1'),
      (1, 36, 'g2'),
      (0, 34, null),
    ];
    for (final (daysAgo, size, groupId) in plan) {
      final recent = now.subtract(const Duration(minutes: 45));
      final start = daysAgo == 0
          ? (recent.day == now.day ? recent : DateTime(now.year, now.month, now.day))
          : DateTime(
              now.year,
              now.month,
              now.day,
              9 + rng.nextInt(3),
              rng.nextInt(60),
            ).subtract(Duration(days: daysAgo));
      final pool = groupId == null ? contacts : contacts.where((c) => c.groupId == groupId).toList();
      final picked = (List.of(pool)..shuffle(rng)).take(size).toList();
      while (picked.length < size) {
        picked.add(contacts[rng.nextInt(contacts.length)]);
      }
      final msg = messages[(daysAgo + rng.nextInt(3)) % messages.length];
      final cid = id('cmp');
      var t = start;
      final logs = <DeliveryLog>[];
      for (final c in picked) {
        t = t.add(Duration(seconds: 20 + rng.nextInt(10)));
        final failed = rng.nextDouble() < .05;
        logs.add(
          DeliveryLog(
            id: id('l'),
            campaignId: cid,
            contactId: c.id,
            name: c.name,
            phone: c.phone,
            status: failed ? DeliveryStatus.failed : DeliveryStatus.sent,
            reason: failed ? randomFailure(rng) : null,
            time: t,
          ),
        );
      }
      final group = groups.where((g) => g.id == groupId).firstOrNull;
      final campaign = Campaign(
        id: cid,
        message: msg,
        createdAt: start,
        audience: group == null ? const Audience(AudienceKind.all) : Audience(AudienceKind.group, name: group.name),
        segments: msg.length > 160 ? 2 : 1,
        logs: logs,
        state: CampaignState.completed,
        finishedAt: t,
      );
      campaigns.insert(0, campaign);
      activities.add(Activity(ActivityEvent.campaignSent, t, ['${campaign.sent}', '${campaign.failed}']));
    }

    for (final c in contacts.take(5)) {
      activities.add(Activity(ActivityEvent.contactAdded, c.createdAt, [c.name, Phone.format(c.phone)]));
    }
    activities.add(
      Activity(ActivityEvent.imported, now.subtract(const Duration(days: 2, hours: 3)), ['24', 'Students']),
    );
    activities.add(
      Activity(ActivityEvent.gatewayConnected, now.subtract(const Duration(hours: 5)), ['Samsung Galaxy A14']),
    );
    activities.sort((a, b) => b.time.compareTo(a.time));

    return SampleData._(groups, contacts, campaigns, activities);
  }
}
