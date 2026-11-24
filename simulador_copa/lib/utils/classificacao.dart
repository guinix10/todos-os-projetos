
import '../models/selecao.dart';
import '../models/partida.dart';

class DesempenhoDireto {
  int pontos = 0;
  int saldoGols = 0;
  int golsPro = 0;
}

DesempenhoDireto calcularConfrontosDiretos(
  Selecao selecao,
  List<Selecao> empatadas,
  List<Partida> partidas,
) {
  DesempenhoDireto desempenho = DesempenhoDireto();

  for (Partida partida in partidas) {
    if (!partida.envolve(selecao)) continue;

    Selecao adversario;
    int golsFeitos;
    int golsRecebidos;

    if (identical(partida.timeA, selecao)) {
      adversario = partida.timeB;
      golsFeitos = partida.golsA;
      golsRecebidos = partida.golsB;
    } else {
      adversario = partida.timeA;
      golsFeitos = partida.golsB;
      golsRecebidos = partida.golsA;
    }

    if (!empatadas.contains(adversario)) continue;

    desempenho.golsPro += golsFeitos;
    desempenho.saldoGols += golsFeitos - golsRecebidos;

    if (golsFeitos > golsRecebidos) {
      desempenho.pontos += 3;
    } else if (golsFeitos == golsRecebidos) {
      desempenho.pontos += 1;
    }
  }

  return desempenho;
}

List<Selecao> ordenarClassificacao(
  List<Selecao> selecoes,
  List<Partida> partidas,
) {
  List<Selecao> classificacao = [];

  List<int> pontuacoes = selecoes
      .map((s) => s.pontos)
      .toSet()
      .toList();

  pontuacoes.sort((a, b) => b.compareTo(a));

  for (int pontos in pontuacoes) {
    List<Selecao> empatadas = selecoes
        .where((s) => s.pontos == pontos)
        .toList();

    empatadas.sort((a, b) {
      DesempenhoDireto diretoA =
          calcularConfrontosDiretos(a, empatadas, partidas);

      DesempenhoDireto diretoB =
          calcularConfrontosDiretos(b, empatadas, partidas);

      // 1º: Pontos nos confrontos diretos.
      int resultado =
          diretoB.pontos.compareTo(diretoA.pontos);

      if (resultado != 0) return resultado;

      // 2º: Saldo de gols nos confrontos diretos.
      resultado =
          diretoB.saldoGols.compareTo(diretoA.saldoGols);

      if (resultado != 0) return resultado;

      // 3º: Gols nos confrontos diretos.
      resultado =
          diretoB.golsPro.compareTo(diretoA.golsPro);

      if (resultado != 0) return resultado;

      // 4º: Saldo de gols geral.
      resultado = b.saldoGols.compareTo(a.saldoGols);

      if (resultado != 0) return resultado;

      // 5º: Gols pró geral.
      resultado = b.golsPro.compareTo(a.golsPro);

      if (resultado != 0) return resultado;

      // 6º: Fair Play (menos cartões é melhor).
      resultado = a.penalidadeFairPlay
          .compareTo(b.penalidadeFairPlay);

      if (resultado != 0) return resultado;

      // 7º: Melhor posição no Ranking FIFA.
      resultado = a.rankingFifa.compareTo(b.rankingFifa);

      if (resultado != 0) return resultado;

      return a.nome.compareTo(b.nome);
    });

    classificacao.addAll(empatadas);
  }

  return classificacao;
}

void exibirClassificacao(
  List<Selecao> selecoes,
  List<Partida> partidas,
) {
  List<Selecao> tabela =
      ordenarClassificacao(selecoes, partidas);

  print('\n==============================================');
  print('           CLASSIFICAÇÃO - GRUPO ${selecoes.first.grupo.name}');
  print('==============================================');

  print('POS  SELEÇÃO                 PTS   SG   GP   FIFA');
  print('----------------------------------------------');

  for (int i = 0; i < tabela.length; i++) {
    Selecao s = tabela[i];

    String posicao = '${i + 1}º'.padRight(5);
    String nome = s.nome.padRight(23);
    String pontos = s.pontos.toString().padLeft(3);

    String saldo = (s.saldoGols >= 0
            ? '+${s.saldoGols}'
            : '${s.saldoGols}')
        .padLeft(4);

    String gols = s.golsPro.toString().padLeft(4);
    String ranking = '${s.rankingFifa}º'.padLeft(6);

    print('$posicao $nome $pontos $saldo $gols $ranking');

    if (i == 1) {
      print('----------------------------------------------');
      print('       ZONA DE CLASSIFICAÇÃO DIRETA');
      print('----------------------------------------------');
    }
  }

  print('----------------------------------------------');

  if (tabela.length >= 3) {
    print('3º colocado: disputa uma das 8 vagas');
    print('entre os terceiros colocados dos grupos.');
  }

  print('==============================================');
}
