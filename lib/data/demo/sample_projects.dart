class SampleProjectEntry {
  const SampleProjectEntry({
    required this.title,
    required this.when,
    required this.amount,
    required this.paid,
    required this.category,
    required this.mode,
  });

  final String title;
  final String when;
  final String amount;
  final bool paid;
  final String category;
  final String mode;
}

class SampleProjectDue {
  const SampleProjectDue({
    required this.party,
    required this.amount,
    required this.note,
  });

  final String party;
  final String amount;
  final String note;
}

class SampleProject {
  const SampleProject({
    required this.id,
    required this.name,
    required this.client,
    required this.clientPhone,
    required this.location,
    required this.status,
    required this.startedOn,
    required this.agreement,
    required this.received,
    required this.paid,
    required this.balance,
    required this.notes,
    required this.entries,
    required this.dues,
  });

  final String id;
  final String name;
  final String client;
  final String clientPhone;
  final String location;
  final String status;
  final String startedOn;
  final String agreement;
  final String received;
  final String paid;
  final String balance;
  final String notes;
  final List<SampleProjectEntry> entries;
  final List<SampleProjectDue> dues;
}

const sampleProjects = [
  SampleProject(
    id: 'amrutha-wayanad',
    name: 'AMRUTHA WAYANAD',
    client: 'Amrutha',
    clientPhone: '+91 98765 43101',
    location: 'Kalpetta, Wayanad',
    status: 'In progress',
    startedOn: '12 Aug 2026',
    agreement: '₹ 2,65,000',
    received: '₹ 2,00,000',
    paid: '₹ 1,35,000',
    balance: '₹ 65,000',
    notes: 'Interior finishing and site coordination. Client advance received yesterday.',
    entries: [
      SampleProjectEntry(
        title: 'Client advance',
        when: 'Yesterday',
        amount: '+ ₹25,000',
        paid: false,
        category: 'Advance',
        mode: 'Cash',
      ),
      SampleProjectEntry(
        title: 'Plywood and fittings',
        when: '3 days ago',
        amount: '- ₹18,400',
        paid: true,
        category: 'Material',
        mode: 'UPI',
      ),
      SampleProjectEntry(
        title: 'Painter wages',
        when: 'Last week',
        amount: '- ₹8,000',
        paid: true,
        category: 'Labour',
        mode: 'Cash',
      ),
    ],
    dues: [
      SampleProjectDue(party: 'Amrutha', amount: '₹25,000', note: 'Balance against agreement'),
    ],
  ),
  SampleProject(
    id: 'phino-wayanad',
    name: 'PHINO WAYANAD',
    client: 'Phino',
    clientPhone: '+91 98765 43102',
    location: 'Sulthan Bathery, Wayanad',
    status: 'In progress',
    startedOn: '04 Sep 2026',
    agreement: '₹ 1,85,000',
    received: '₹ 1,20,000',
    paid: '₹ 71,500',
    balance: '₹ 48,500',
    notes: 'Civil and carpentry. Cement purchase booked today.',
    entries: [
      SampleProjectEntry(
        title: 'Cement purchase',
        when: 'Today',
        amount: '- ₹2,500',
        paid: true,
        category: 'Material',
        mode: 'UPI',
      ),
      SampleProjectEntry(
        title: 'Site labour',
        when: 'Yesterday',
        amount: '- ₹6,000',
        paid: true,
        category: 'Labour',
        mode: 'Cash',
      ),
      SampleProjectEntry(
        title: 'Client payment',
        when: 'Last week',
        amount: '+ ₹40,000',
        paid: false,
        category: 'Advance',
        mode: 'UPI',
      ),
    ],
    dues: [
      SampleProjectDue(party: 'Shinto', amount: '₹15,000', note: 'Carpenter — pending'),
    ],
  ),
  SampleProject(
    id: 'sanjana-punnol',
    name: 'SANJANA PUNNOL',
    client: 'Sanjana',
    clientPhone: '+91 98765 43103',
    location: 'Punnol, Kannur',
    status: 'In progress',
    startedOn: '21 Jul 2026',
    agreement: '₹ 3,10,000',
    received: '₹ 2,40,000',
    paid: '₹ 1,73,500',
    balance: '₹ 66,500',
    notes: 'Full interior package. Carpenter wages paid this week.',
    entries: [
      SampleProjectEntry(
        title: 'Carpenter wages',
        when: 'Today',
        amount: '- ₹8,000',
        paid: true,
        category: 'Labour',
        mode: 'Cash',
      ),
      SampleProjectEntry(
        title: 'Hardware and handles',
        when: '2 days ago',
        amount: '- ₹4,200',
        paid: true,
        category: 'Material',
        mode: 'Cash',
      ),
      SampleProjectEntry(
        title: 'Stage payment',
        when: 'Last week',
        amount: '+ ₹50,000',
        paid: false,
        category: 'Advance',
        mode: 'UPI',
      ),
    ],
    dues: [
      SampleProjectDue(party: 'Other supplier', amount: '₹10,000', note: 'Pending material bill'),
    ],
  ),
];
