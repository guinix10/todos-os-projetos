
import 'dart:io';

import '../lib/models/selecao.dart';
import '../lib/models/partida.dart';
import '../lib/services/dados_service.dart';
import '../lib/utils/classificacao.dart';

// Identifica as partidas que ainda não foram registradas.
List<List<Selecao>> jogosPendentes(
  List<Selecao> selecoes,
  List<Partida> partidas,
) {
  List<List<Selecao>> pendentes = [];

  for (int i = 0; i < selecoes.length; i++) {
    for (int j = i + 1; j < selecoes.length; j++) {
      Selecao timeA = selecoes[i];
      Selecao timeB = selecoes[j];

      bool registrado = partidas.any(
        (p) => p.mesmoConfronto(timeA, timeB),
      );

      if (!registrado) {
        pendentes.add([timeA, timeB]);
      }
    }
  }

  return pendentes;
}

// Exibe as partidas disponíveis.
void exibirJogosPendentes(List<List<Selecao>> jogos) {
  print('\n========== JOGOS DISPONÍVEIS ==========');

  if (jogos.isEmpty) {
    print('Todas as partidas foram realizadas!');
    return;
  }

  for (int i = 0; i < jogos.length; i++) {
    print(
      '${i + 1}. ${jogos[i][0].nome} x ${jogos[i][1].nome}',
    );
  }
}

Future<void> main() async {
  print('========================================');
  print('       SIMULADOR COPA DO MUNDO 2026');
  print('========================================');

  List<Selecao> selecoes;

  // Carrega os dados do arquivo JSON.
  try {
    selecoes = await carregarSelecoes('dados_copa.json');
  } catch (erro) {
    print('\nErro ao carregar os dados: $erro');
    return;
  }

  List<Partida> partidas = [];

  String grupo = selecoes.first.grupo.name;

  bool executando = true;

  while (executando) {
    print('\n========================================');
    print('           SIMULADOR - GRUPO $grupo');
    print('========================================');

    print('1. Registrar resultado de jogo');
    print('2. Ver classificação atual');
    print('3. Ver jogos pendentes');
    print('4. Sair');

    stdout.write('\nEscolha uma opção: ');

    String entrada = stdin.readLineSync() ?? '';

    int? opcao = int.tryParse(entrada);

    if (opcao == null) {
      print('\nErro: Digite uma opção válida!');
      continue;
    }

    switch (opcao) {
      case 1:
        List<List<Selecao>> pendentes =
            jogosPendentes(selecoes, partidas);

        if (pendentes.isEmpty) {
          print('\nTodas as partidas já foram registradas!');
          break;
        }

        exibirJogosPendentes(pendentes);

        stdout.write('\nEscolha o número da partida: ');

        String escolha = stdin.readLineSync() ?? '';

        int? indice = int.tryParse(escolha);

        if (indice == null ||
            indice < 1 ||
            indice > pendentes.length) {
          print('\nErro: Partida inválida!');
          break;
        }

        Selecao timeA = pendentes[indice - 1][0];
        Selecao timeB = pendentes[indice - 1][1];

        try {
          Partida novaPartida = registrarJogo(timeA, timeB);

          partidas.add(novaPartida);
        } catch (erro) {
          print('\nErro ao registrar partida: $erro');
        }

        break;

      case 2:
        exibirClassificacao(selecoes, partidas);
        break;

      case 3:
        List<List<Selecao>> pendentes =
            jogosPendentes(selecoes, partidas);

        exibirJogosPendentes(pendentes);

        print('\nPartidas registradas: ${partidas.length}/6');
        break;

      case 4:
        print('\nEncerrando o simulador...');
        print('Obrigado por utilizar o sistema!');

        executando = false;
        break;

      default:
        print('\nErro: Opção inexistente!');
    }
  }
}
