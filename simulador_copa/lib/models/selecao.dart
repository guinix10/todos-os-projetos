
enum Grupo {
  A, B, C, D, E, F,
  G, H, I, J, K, L
}

class Selecao {
  String nome;
  Grupo grupo;
  int rankingFifa;

  int pontos;
  int golsPro;
  int golsSofridos;
  int cartoesAmarelos;
  int cartoesVermelhos;

  Selecao({
    required this.nome,
    required this.grupo,
    required this.rankingFifa,
    this.pontos = 0,
    this.golsPro = 0,
    this.golsSofridos = 0,
    this.cartoesAmarelos = 0,
    this.cartoesVermelhos = 0,
  });

  int get saldoGols => golsPro - golsSofridos;

  int get penalidadeFairPlay =>
      cartoesAmarelos + (cartoesVermelhos * 4);

  void registrarResultado({
    required int golsFeitos,
    required int golsRecebidos,
    required int amarelos,
    required int vermelhos,
  }) {
    golsPro += golsFeitos;
    golsSofridos += golsRecebidos;
    cartoesAmarelos += amarelos;
    cartoesVermelhos += vermelhos;

    if (golsFeitos > golsRecebidos) {
      pontos += 3;
    } else if (golsFeitos == golsRecebidos) {
      pontos += 1;
    }
  }
}
