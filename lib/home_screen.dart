import 'package:flutter/material.dart';
import 'package:soigne_moi_mobile/service/api.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const route = '/home';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> schedules = [];

  @override
  void initState() {
    super.initState();
    _getSchedule();
  }

  Future<void> _getSchedule() async {
    try {
      final api = Api();
      schedules = await api.getSchedule();
      setState(() {});
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SoigneMoi App'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Nombre de visites de la journée : ${schedules.length}',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: schedules.length,
                  itemBuilder: (context, index) {
                    final schedule = schedules[index];
                    final String formattedTimeDebut = DateFormat('hh:mm')
                        .format(DateTime.parse(schedule['dateDebut']));
                    final String formattedTimeFin = DateFormat('hh:mm')
                        .format(DateTime.parse(schedule['dateFin']));
                    return Card(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/prescriptionopinion',
                            arguments: {
                              'patientId': schedule['patient']['id'],
                              'doctorId': schedule['doctor']['id'],
                            },
                          );
                        },
                        child: ListTile(
                          title: Text(
                            '${schedule['patient']['prenom']} ${schedule['patient']['nom']}',
                            style: TextStyle(fontSize: 18),
                          ),
                          subtitle: Text(
                            'Heure du rendez-vous : $formattedTimeDebut - $formattedTimeFin',
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
