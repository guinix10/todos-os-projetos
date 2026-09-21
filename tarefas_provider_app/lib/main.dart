import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'providers/tarefa_provider.dart';
import 'models/tarefa.dart';

void main() {
  // Configuração necessária para Flutter Web
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => TarefaProvider()..carregarTarefas(),
      child: const TarefasApp(),
    ),
  );
}

class TarefasApp extends StatelessWidget {
  const TarefasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Minhas Tarefas',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int filtro = 0;

  List<Tarefa> aplicarFiltro(List<Tarefa> tarefas) {
    if (filtro == 1) {
      return tarefas.where((t) => !t.concluida).toList();
    }

    if (filtro == 2) {
      return tarefas.where((t) => t.concluida).toList();
    }

    return tarefas;
  }

  void novaTarefa(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nova Tarefa'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Descrição',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Provider.of<TarefaProvider>(
                  context,
                  listen: false,
                ).adicionarTarefa(controller.text);

                Navigator.pop(ctx);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void editarTarefa(
    BuildContext context,
    Tarefa tarefa,
  ) {
    final controller =
        TextEditingController(text: tarefa.titulo);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Tarefa'),
        content: TextField(
          controller: controller,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<TarefaProvider>(
                context,
                listen: false,
              ).editarTarefa(
                tarefa,
                controller.text,
              );

              Navigator.pop(ctx);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Tarefas'),
        centerTitle: true,
      ),
      body: Consumer<TarefaProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final tarefas =
              aplicarFiltro(provider.tarefas);

          final total =
              provider.tarefas.length;

          final concluidas =
              provider.tarefas
                  .where((t) => t.concluida)
                  .length;

          return Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: Text(
                  '$concluidas de $total concluídas',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                children: [
                  ChoiceChip(
                    label: const Text('Todas'),
                    selected: filtro == 0,
                    onSelected: (_) {
                      setState(() => filtro = 0);
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Pendentes'),
                    selected: filtro == 1,
                    onSelected: (_) {
                      setState(() => filtro = 1);
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Concluídas'),
                    selected: filtro == 2,
                    onSelected: (_) {
                      setState(() => filtro = 2);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Expanded(
                child: tarefas.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhuma tarefa',
                        ),
                      )
                    : ListView.builder(
                        itemCount: tarefas.length,
                        itemBuilder: (context, index) {
                          final tarefa =
                              tarefas[index];

                          return Card(
                            margin:
                                const EdgeInsets.all(8),
                            child: ListTile(
                              leading: Checkbox(
                                value:
                                    tarefa.concluida,
                                onChanged: (_) {
                                  provider
                                      .alternarStatus(
                                    tarefa,
                                  );
                                },
                              ),
                              title: Text(
                                tarefa.titulo,
                                style: TextStyle(
                                  decoration:
                                      tarefa.concluida
                                          ? TextDecoration
                                              .lineThrough
                                          : null,
                                ),
                              ),
                              onLongPress: () {
                                editarTarefa(
                                  context,
                                  tarefa,
                                );
                              },
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  provider
                                      .removerTarefa(
                                    tarefa.id!,
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton:
          FloatingActionButton(
        onPressed: () {
          novaTarefa(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}