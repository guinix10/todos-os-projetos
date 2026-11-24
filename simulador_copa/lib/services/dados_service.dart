
import 'dart:convert';
import 'dart:io';

import '../models/selecao.dart';

Future<List<Selecao>> carregarSelecoes(String caminho) async {
  print('\nCarregando dados das seleções...');

  await Future.delayed(Duration(seconds: 2));

  File arquivo = File(caminho);

  if (!await arquivo.exists()) {
    throw Exception('Arquivo JSON não encontrado!');
  }

  String conteudo = await arquivo.readAsString();

  Map<String, dynamic> dados = jsonDecode(conteudo);

  String grupoTexto = dados['grupo'];

  Grupo grupo = Grupo.values.firstWhere(
    (item) => item.name == grupoTexto,
    orElse: () => throw FormatException('Grupo inválido!'),
  );

  List<dynamic> lista = dados['selecoes'];

  if (lista.length != 4) {
    throw FormatException(
      'O grupo precisa possuir exatamente 4 seleções!',
    );
  }

  List<Selecao> selecoes = lista.map((item) {
    return Selecao(
      nome: item['nome'],
      grupo: grupo,
      rankingFifa: item['rankingFifa'],
    );
  }).toList();

  print('Dados carregados com sucesso!');

  return selecoes;
}
