
import 'dart:io';
import 'selecao.dart';

class Partida {
  Selecao timeA;
  Selecao timeB;

  int golsA;
  int golsB;

  int amarelosA;
  int amarelosB;

  int vermelhosA;
  int vermelhosB;

  Partida({
    required this.timeA,
    required this.timeB,
    required this.golsA,
    required this.golsB,
    required this.amarelosA,
    required this.amarelosB,
    required this.vermelhosA,
    required this.vermelhosB,
  });

  bool envolve(Selecao selecao) {
    return identical(timeA, selecao) ||
        identical(timeB, selecao);
  }

  bool mesmoConfronto(Selecao a, Selecao b) {
    return (identical(timeA, a) && identical(timeB, b)) ||
        (identical(timeA, b) && identical(timeB, a));
  }
}

int lerNumero(String mensagem) {
  while (true) {
    stdout.write(mensagem);

    try {
      String entrada = stdin.readLineSync() ?? '';
      int valor = int.parse(entrada);

      if (valor < 0) {
        throw FormatException();
      }

      return valor;
    } on FormatException {
      print('Erro: Digite um placar válido!');
    }
  }
}

Partida registrarJogo(Selecao timeA, Selecao timeB) {
  print('\n=== REGISTRO DE PARTIDA ===');
  print('${timeA.nome} x ${timeB.nome}');

  int golsA = lerNumero('Gols de ${timeA.nome}: ');
  int golsB = lerNumero('Gols de ${timeB.nome}: ');

  print('\n--- Cartões ---');

  int amarelosA =
      lerNumero('Cartões amarelos de ${timeA.nome}: ');

  int vermelhosA =
      lerNumero('Cartões vermelhos de ${timeA.nome}: ');

  int amarelosB =
      lerNumero('Cartões amarelos de ${timeB.nome}: ');

  int vermelhosB =
      lerNumero('Cartões vermelhos de ${timeB.nome}: ');

  timeA.registrarResultado(
    golsFeitos: golsA,
    golsRecebidos: golsB,
    amarelos: amarelosA,
    vermelhos: vermelhosA,
  );

  timeB.registrarResultado(
    golsFeitos: golsB,
    golsRecebidos: golsA,
    amarelos: amarelosB,
    vermelhos: vermelhosB,
  );

  Partida partida = Partida(
    timeA: timeA,
    timeB: timeB,
    golsA: golsA,
    golsB: golsB,
    amarelosA: amarelosA,
    amarelosB: amarelosB,
    vermelhosA: vermelhosA,
    vermelhosB: vermelhosB,
  );

  print('\nResultado registrado com sucesso!');
  print('${timeA.nome} $golsA x $golsB ${timeB.nome}');

  return partida;
}
