import 'package:flutter/material.dart';
import 'package:reciepts/database/database_helper.dart';

class DatenView extends StatefulWidget {
  const DatenView({Key? key}) : super(key: key);

  @override
  State<DatenView> createState() => _DatenViewState();
}

class _DatenViewState extends State<DatenView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datenverwaltung'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.business), text: 'Firma'),
            Tab(icon: Icon(Icons.person), text: 'Kunde'),
            Tab(icon: Icon(Icons.engineering), text: 'Monteur'),
            Tab(icon: Icon(Icons.construction), text: 'Baustelle'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          FirmaTab(dbHelper: _dbHelper),
          KundeTab(dbHelper: _dbHelper),
          MonteurTab(dbHelper: _dbHelper),
          BaustelleTab(dbHelper: _dbHelper),
        ],
      ),
    );
  }
}

// ====================== FIRMA TAB ======================
class FirmaTab extends StatefulWidget {
  final DatabaseHelper dbHelper;
  const FirmaTab({Key? key, required this.dbHelper}) : super(key: key);

  @override
  State<FirmaTab> createState() => _FirmaTabState();
}

class _FirmaTabState extends State<FirmaTab> {
  List<Map<String, dynamic>> _firmen = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await widget.dbHelper.queryAllFirmen();
    setState(() => _firmen = data);
  }

  void _showAddDialog() {
    final controllers = {
      'name': TextEditingController(),
      'strasse': TextEditingController(),
      'plz': TextEditingController(),
      'ort': TextEditingController(),
      'telefon': TextEditingController(),
      'email': TextEditingController(),
      'website': TextEditingController(),
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Neue Firma'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: controllers['name'],
                  decoration: const InputDecoration(labelText: 'Name')),
              TextField(
                  controller: controllers['strasse'],
                  decoration: const InputDecoration(labelText: 'Straße')),
              TextField(
                  controller: controllers['plz'],
                  decoration: const InputDecoration(labelText: 'PLZ')),
              TextField(
                  controller: controllers['ort'],
                  decoration: const InputDecoration(labelText: 'Ort')),
              TextField(
                  controller: controllers['telefon'],
                  decoration: const InputDecoration(labelText: 'Telefon')),
              TextField(
                  controller: controllers['email'],
                  decoration: const InputDecoration(labelText: 'E-Mail')),
              TextField(
                  controller: controllers['website'],
                  decoration: const InputDecoration(labelText: 'Website')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen')),
          ElevatedButton(
            onPressed: () async {
              await widget.dbHelper.insertFirma({
                'name': controllers['name']!.text,
                'strasse': controllers['strasse']!.text,
                'plz': controllers['plz']!.text,
                'ort': controllers['ort']!.text,
                'telefon': controllers['telefon']!.text,
                'email': controllers['email']!.text,
                'website': controllers['website']!.text,
              });
              Navigator.pop(context);
              _loadData();
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> firma) {
    final controllers = {
      'name': TextEditingController(text: firma['name']),
      'strasse': TextEditingController(text: firma['strasse']),
      'plz': TextEditingController(text: firma['plz']),
      'ort': TextEditingController(text: firma['ort']),
      'telefon': TextEditingController(text: firma['telefon']),
      'email': TextEditingController(text: firma['email']),
      'website': TextEditingController(text: firma['website']),
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Firma bearbeiten'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: controllers['name'],
                  decoration: const InputDecoration(labelText: 'Name')),
              TextField(
                  controller: controllers['strasse'],
                  decoration: const InputDecoration(labelText: 'Straße')),
              TextField(
                  controller: controllers['plz'],
                  decoration: const InputDecoration(labelText: 'PLZ')),
              TextField(
                  controller: controllers['ort'],
                  decoration: const InputDecoration(labelText: 'Ort')),
              TextField(
                  controller: controllers['telefon'],
                  decoration: const InputDecoration(labelText: 'Telefon')),
              TextField(
                  controller: controllers['email'],
                  decoration: const InputDecoration(labelText: 'E-Mail')),
              TextField(
                  controller: controllers['website'],
                  decoration: const InputDecoration(labelText: 'Website')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen')),
          ElevatedButton(
            onPressed: () async {
              await widget.dbHelper.updateFirma({
                'id': firma['id'],
                'name': controllers['name']!.text,
                'strasse': controllers['strasse']!.text,
                'plz': controllers['plz']!.text,
                'ort': controllers['ort']!.text,
                'telefon': controllers['telefon']!.text,
                'email': controllers['email']!.text,
                'website': controllers['website']!.text,
              });
              Navigator.pop(context);
              _loadData();
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            onPressed: _showAddDialog,
            icon: const Icon(Icons.add),
            label: const Text('Neue Firma'),
          ),
        ),
        Expanded(
          child: _firmen.isEmpty
              ? const Center(child: Text('Keine Firmen vorhanden'))
              : ListView.builder(
                  itemCount: _firmen.length,
                  itemBuilder: (context, index) {
                    final firma = _firmen[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: ListTile(
                        title: Text(firma['name'] ?? ''),
                        subtitle: Text(
                            '${firma['strasse'] ?? ''}, ${firma['plz'] ?? ''} ${firma['ort'] ?? ''}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showEditDialog(firma),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await widget.dbHelper.deleteFirma(firma['id']);
                                _loadData();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ====================== KUNDE TAB ======================
class KundeTab extends StatefulWidget {
  final DatabaseHelper dbHelper;
  const KundeTab({Key? key, required this.dbHelper}) : super(key: key);

  @override
  State<KundeTab> createState() => _KundeTabState();
}

class _KundeTabState extends State<KundeTab> {
  List<Map<String, dynamic>> _kunden = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await widget.dbHelper.queryAllKunden();
    setState(() => _kunden = data);
  }

  void _showAddDialog() {
    final controllers = {
      'name': TextEditingController(),
      'strasse': TextEditingController(),
      'plz': TextEditingController(),
      'ort': TextEditingController(),
      'telefon': TextEditingController(),
      'email': TextEditingController(),
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Neuer Kunde'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: controllers['name'],
                  decoration: const InputDecoration(labelText: 'Name')),
              TextField(
                  controller: controllers['strasse'],
                  decoration: const InputDecoration(labelText: 'Straße')),
              TextField(
                  controller: controllers['plz'],
                  decoration: const InputDecoration(labelText: 'PLZ')),
              TextField(
                  controller: controllers['ort'],
                  decoration: const InputDecoration(labelText: 'Ort')),
              TextField(
                  controller: controllers['telefon'],
                  decoration: const InputDecoration(labelText: 'Telefon')),
              TextField(
                  controller: controllers['email'],
                  decoration: const InputDecoration(labelText: 'E-Mail')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen')),
          ElevatedButton(
            onPressed: () async {
              await widget.dbHelper.insertKunde({
                'name': controllers['name']!.text,
                'strasse': controllers['strasse']!.text,
                'plz': controllers['plz']!.text,
                'ort': controllers['ort']!.text,
                'telefon': controllers['telefon']!.text,
                'email': controllers['email']!.text,
              });
              Navigator.pop(context);
              _loadData();
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> kunde) {
    final controllers = {
      'name': TextEditingController(text: kunde['name']),
      'strasse': TextEditingController(text: kunde['strasse']),
      'plz': TextEditingController(text: kunde['plz']),
      'ort': TextEditingController(text: kunde['ort']),
      'telefon': TextEditingController(text: kunde['telefon']),
      'email': TextEditingController(text: kunde['email']),
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kunde bearbeiten'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: controllers['name'],
                  decoration: const InputDecoration(labelText: 'Name')),
              TextField(
                  controller: controllers['strasse'],
                  decoration: const InputDecoration(labelText: 'Straße')),
              TextField(
                  controller: controllers['plz'],
                  decoration: const InputDecoration(labelText: 'PLZ')),
              TextField(
                  controller: controllers['ort'],
                  decoration: const InputDecoration(labelText: 'Ort')),
              TextField(
                  controller: controllers['telefon'],
                  decoration: const InputDecoration(labelText: 'Telefon')),
              TextField(
                  controller: controllers['email'],
                  decoration: const InputDecoration(labelText: 'E-Mail')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen')),
          ElevatedButton(
            onPressed: () async {
              await widget.dbHelper.updateKunde({
                'id': kunde['id'],
                'name': controllers['name']!.text,
                'strasse': controllers['strasse']!.text,
                'plz': controllers['plz']!.text,
                'ort': controllers['ort']!.text,
                'telefon': controllers['telefon']!.text,
                'email': controllers['email']!.text,
              });
              Navigator.pop(context);
              _loadData();
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            onPressed: _showAddDialog,
            icon: const Icon(Icons.add),
            label: const Text('Neuer Kunde'),
          ),
        ),
        Expanded(
          child: _kunden.isEmpty
              ? const Center(child: Text('Keine Kunden vorhanden'))
              : ListView.builder(
                  itemCount: _kunden.length,
                  itemBuilder: (context, index) {
                    final kunde = _kunden[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: ListTile(
                        title: Text(kunde['name'] ?? ''),
                        subtitle: Text(
                            '${kunde['strasse'] ?? ''}, ${kunde['plz'] ?? ''} ${kunde['ort'] ?? ''}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showEditDialog(kunde),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await widget.dbHelper.deleteKunde(kunde['id']);
                                _loadData();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ====================== MONTEUR TAB ======================
class MonteurTab extends StatefulWidget {
  final DatabaseHelper dbHelper;
  const MonteurTab({Key? key, required this.dbHelper}) : super(key: key);

  @override
  State<MonteurTab> createState() => _MonteurTabState();
}

class _MonteurTabState extends State<MonteurTab> {
  List<Map<String, dynamic>> _monteure = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await widget.dbHelper.queryAllMonteure();
    setState(() => _monteure = data);
  }

  void _showAddDialog() {
    final controllers = {
      'vorname': TextEditingController(),
      'nachname': TextEditingController(),
      'telefon': TextEditingController(),
      'email': TextEditingController(),
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Neuer Monteur'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: controllers['vorname'],
                  decoration: const InputDecoration(labelText: 'Vorname')),
              TextField(
                  controller: controllers['nachname'],
                  decoration: const InputDecoration(labelText: 'Nachname')),
              TextField(
                  controller: controllers['telefon'],
                  decoration: const InputDecoration(labelText: 'Telefon')),
              TextField(
                  controller: controllers['email'],
                  decoration: const InputDecoration(labelText: 'E-Mail')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen')),
          ElevatedButton(
            onPressed: () async {
              await widget.dbHelper.insertMonteur({
                'vorname': controllers['vorname']!.text,
                'nachname': controllers['nachname']!.text,
                'telefon': controllers['telefon']!.text,
                'email': controllers['email']!.text,
              });
              Navigator.pop(context);
              _loadData();
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> monteur) {
    final controllers = {
      'vorname': TextEditingController(text: monteur['vorname']),
      'nachname': TextEditingController(text: monteur['nachname']),
      'telefon': TextEditingController(text: monteur['telefon']),
      'email': TextEditingController(text: monteur['email']),
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Monteur bearbeiten'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: controllers['vorname'],
                  decoration: const InputDecoration(labelText: 'Vorname')),
              TextField(
                  controller: controllers['nachname'],
                  decoration: const InputDecoration(labelText: 'Nachname')),
              TextField(
                  controller: controllers['telefon'],
                  decoration: const InputDecoration(labelText: 'Telefon')),
              TextField(
                  controller: controllers['email'],
                  decoration: const InputDecoration(labelText: 'E-Mail')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen')),
          ElevatedButton(
            onPressed: () async {
              await widget.dbHelper.updateMonteur({
                'id': monteur['id'],
                'vorname': controllers['vorname']!.text,
                'nachname': controllers['nachname']!.text,
                'telefon': controllers['telefon']!.text,
                'email': controllers['email']!.text,
              });
              Navigator.pop(context);
              _loadData();
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            onPressed: _showAddDialog,
            icon: const Icon(Icons.add),
            label: const Text('Neuer Monteur'),
          ),
        ),
        Expanded(
          child: _monteure.isEmpty
              ? const Center(child: Text('Keine Monteure vorhanden'))
              : ListView.builder(
                  itemCount: _monteure.length,
                  itemBuilder: (context, index) {
                    final monteur = _monteure[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: ListTile(
                        title: Text(
                            '${monteur['vorname'] ?? ''} ${monteur['nachname'] ?? ''}'),
                        subtitle: Text(
                            'Tel: ${monteur['telefon'] ?? ''}\nE-Mail: ${monteur['email'] ?? ''}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showEditDialog(monteur),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await widget.dbHelper
                                    .deleteMonteur(monteur['id']);
                                _loadData();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ====================== BAUSTELLE TAB ======================
class BaustelleTab extends StatefulWidget {
  final DatabaseHelper dbHelper;
  const BaustelleTab({Key? key, required this.dbHelper}) : super(key: key);

  @override
  State<BaustelleTab> createState() => _BaustelleTabState();
}

class _BaustelleTabState extends State<BaustelleTab> {
  List<Map<String, dynamic>> _baustellen = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await widget.dbHelper.queryAllBaustellen();
    setState(() => _baustellen = data);
  }

  void _showAddDialog() {
    final controllers = {
      'strasse': TextEditingController(),
      'plz': TextEditingController(),
      'ort': TextEditingController(),
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Neue Baustelle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: controllers['strasse'],
                  decoration: const InputDecoration(labelText: 'Straße')),
              TextField(
                  controller: controllers['plz'],
                  decoration: const InputDecoration(labelText: 'PLZ')),
              TextField(
                  controller: controllers['ort'],
                  decoration: const InputDecoration(labelText: 'Ort')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen')),
          ElevatedButton(
            onPressed: () async {
              await widget.dbHelper.insertBaustelle({
                'strasse': controllers['strasse']!.text,
                'plz': controllers['plz']!.text,
                'ort': controllers['ort']!.text,
              });
              Navigator.pop(context);
              _loadData();
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> baustelle) {
    final controllers = {
      'strasse': TextEditingController(text: baustelle['strasse']),
      'plz': TextEditingController(text: baustelle['plz']),
      'ort': TextEditingController(text: baustelle['ort']),
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Baustelle bearbeiten'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: controllers['strasse'],
                  decoration: const InputDecoration(labelText: 'Straße')),
              TextField(
                  controller: controllers['plz'],
                  decoration: const InputDecoration(labelText: 'PLZ')),
              TextField(
                  controller: controllers['ort'],
                  decoration: const InputDecoration(labelText: 'Ort')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen')),
          ElevatedButton(
            onPressed: () async {
              await widget.dbHelper.updateBaustelle({
                'id': baustelle['id'],
                'strasse': controllers['strasse']!.text,
                'plz': controllers['plz']!.text,
                'ort': controllers['ort']!.text,
              });
              Navigator.pop(context);
              _loadData();
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            onPressed: _showAddDialog,
            icon: const Icon(Icons.add),
            label: const Text('Neue Baustelle'),
          ),
        ),
        Expanded(
          child: _baustellen.isEmpty
              ? const Center(child: Text('Keine Baustellen vorhanden'))
              : ListView.builder(
                  itemCount: _baustellen.length,
                  itemBuilder: (context, index) {
                    final baustelle = _baustellen[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: ListTile(
                        title: Text(baustelle['strasse'] ?? ''),
                        subtitle: Text(
                            '${baustelle['plz'] ?? ''} ${baustelle['ort'] ?? ''}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showEditDialog(baustelle),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await widget.dbHelper
                                    .deleteBaustelle(baustelle['id']);
                                _loadData();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
