import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:soigne_moi_mobile/service/api.dart';

class PrescriptionOpinion extends StatefulWidget {
  const PrescriptionOpinion({Key? key}) : super(key: key);

  static const route = '/prescriptionopinion';

  @override
  _PrescriptionOpinionState createState() => _PrescriptionOpinionState();
}

class _PrescriptionOpinionState extends State<PrescriptionOpinion> {
  int? patientId;
  int? doctorId;

  // Liste de medicaments prescrits
  List<Map<String, dynamic>> prescriptions = [];

  // Controllers pour les entréees des champs
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateDebutController = TextEditingController();
  final TextEditingController _dateFinController = TextEditingController();
  final TextEditingController _posologieController = TextEditingController();

  // Variables pour la liste des médicaments
  Map<String, dynamic>? selectedDrug;
  List<Map<String, dynamic>>? drugsList;

  @override
  void initState() {
    super.initState();
    _fetchDrugsList();
  }

  Future<void> _fetchDrugsList() async {
    try {
      final api = Api();
      drugsList = await api.getDrugsList();
      setState(() {});
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    patientId = args['patientId'] as int;
    doctorId = args['doctorId'] as int;

    return Scaffold(
      appBar: AppBar(
        title: Text('Formulaire'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              // fieldset Avis
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Avis',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),

                      // Titre de l'avis
                      TextFormField(
                        controller: _titreController,
                        decoration: InputDecoration(
                          labelText: 'Titre',
                          hintText: 'Entrez le titre de votre avis...',
                        ),
                      ),

                      // Description de l'avis
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          hintText: 'Entrez la description de votre avis...',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // fieldset Prescription
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Prescription',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),

                      // Date de début
                      GestureDetector(
                        onTap: () async {
                          // Affiche e datepicker
                          DateTime? dateDebut = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2024, 1, 1),
                            lastDate: DateTime(2025, 12, 31),
                          );
                          if (dateDebut != null) {
                            // Formatte et affiche la date
                            _dateDebutController.text =
                                DateFormat('dd/MM/yyyy').format(dateDebut);
                          }
                        },
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _dateDebutController,
                            decoration: InputDecoration(
                              labelText: 'Date de début',
                              hintText: 'Choisissez une date...',
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),

                      // Date de fin
                      GestureDetector(
                        onTap: () async {
                          // Affiche le datepicker
                          DateTime? dateFin = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2024, 1, 1),
                            lastDate: DateTime(2025, 12, 31),
                          );
                          if (dateFin != null) {
                            // Formatte et affiche la date
                            _dateFinController.text =
                                DateFormat('dd/MM/yyyy').format(dateFin);
                          }
                        },
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _dateFinController,
                            decoration: InputDecoration(
                              labelText: 'Date de fin',
                              hintText: 'Choisissez une date...',
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 10),

                      // Sélection du médicament
                      if (drugsList != null)
                        DropdownButtonFormField<Map<String, dynamic>>(
                          value: selectedDrug,
                          hint: Text('Sélectionnez un médicament'),
                          items: drugsList!
                              .map((drug) =>
                                  DropdownMenuItem<Map<String, dynamic>>(
                                    value: drug,
                                    child: Text(drug['name'] as String),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedDrug = value!;
                            });
                          },
                        ),
                      SizedBox(height: 10),

                      // Posologie
                      TextFormField(
                        controller: _posologieController,
                        decoration: InputDecoration(
                          labelText: 'Posologie',
                          hintText: 'Entrez la posologie ici...',
                        ),
                      ),
                      SizedBox(height: 20),

                      // Bouton "Ajouter ce médicament"
                      ElevatedButton(
                        onPressed: () {
                          prescriptions.add({
                            'name': selectedDrug!['name'], // Medication name
                            'dosage': _posologieController.text,
                            'drug': selectedDrug!['id'], // Medication ID
                          });
                          setState(() {
                            selectedDrug = null;
                            _posologieController.clear();
                          });
                        },
                        child: Text('Ajouter ce médicament'),
                      ),

                      SizedBox(height: 20),

                      // Tableau des prescriptions (sans les dates)
                      DataTable(
                        columns: const <DataColumn>[
                          DataColumn(
                            label: Text('Médicament'),
                          ),
                          DataColumn(
                            label: Text('Posologie'),
                          ),
                        ],
                        rows: prescriptions
                            .map((prescription) => DataRow(
                                  cells: <DataCell>[
                                    DataCell(Text(prescription['name'])),
                                    DataCell(Text(prescription['dosage'])),
                                  ],
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),
              // Bouton d'envoi
              ElevatedButton(
                onPressed: () async {
                  //Récupération des données et mise en forme
                  String titre = _titreController.text;
                  String description = _descriptionController.text;
                  String startDate = DateFormat('yyyy/MM/dd').format(
                      DateFormat('dd/MM/yyyy')
                          .parse(_dateDebutController.text));
                  String endDate = DateFormat('yyyy/MM/dd').format(
                      DateFormat('dd/MM/yyyy').parse(_dateFinController.text));

                  //Génération du Json
                  Map<String, dynamic> jsonData = {
                    "user": patientId,
                    "doctor": doctorId,
                    "opinion": {"title": titre, "description": description},
                    "medicationList": prescriptions,
                    "startDate": startDate,
                    "endDate": endDate
                  };

                  //Envoi à l'api
                  final api = Api();
                  try {
                    await api.setPrescription(jsonData);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Prescription envoyée avec succès!'),
                    ));
                    Navigator.pop(context);
                  } catch (error) {
                    print(error);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'Une erreur est survenue lors de l\'envoi de la prescription.'),
                    ));
                  }
                },
                child: Text('Envoyer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
