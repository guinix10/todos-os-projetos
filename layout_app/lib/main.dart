
import 'package:flutter/material.dart';

void main() => runApp(const MeuLayoutApp());

class MeuLayoutApp extends StatelessWidget {
  const MeuLayoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PPDM - Layout Widgets',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const TelaDashboard(),
    );
  }
}

class TelaDashboard extends StatelessWidget {
  const TelaDashboard({super.key});

  Widget estatistica(IconData icone, String numero, String legenda,
      Color fundo) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icone, size: 30, color: Colors.teal),
          const SizedBox(height: 8),
          Text(numero, style: const TextStyle(
            fontSize: 22, fontWeight: FontWeight.bold)),
          Text(legenda, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PPDM - Dashboard de Observacoes'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Resumo das Observacoes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: estatistica(
                  Icons.flutter_dash, '124', 'Aves Vistas',
                  Colors.teal.shade100)),
                const SizedBox(width: 8),
                Expanded(child: estatistica(
                  Icons.place, '18', 'Locais Visitados',
                  Colors.teal.shade50)),
                const SizedBox(width: 8),
                Expanded(child: estatistica(
                  Icons.camera_alt, '45', 'Fotos',
                  Colors.orange.shade100)),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Destaque da Semana',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Card(
                  elevation: 4,
                  color: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        const Icon(Icons.star, size: 48, color: Colors.amber),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Gaviao-Real', style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                              Text('Avistado no Parque Central',
                                style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: -8,
                  right: -8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Raro', style: TextStyle(
                      color: Colors.white, fontSize: 10,
                      fontWeight: FontWeight.bold)),
                  ),
                ),
                Positioned(
                  bottom: -8,
                  left: -8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Confirmado', style: TextStyle(
                      color: Colors.white, fontSize: 10,
                      fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Últimos Registros',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.list_alt, color: Colors.teal),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('Últimas aves registradas'),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Ver mais'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
