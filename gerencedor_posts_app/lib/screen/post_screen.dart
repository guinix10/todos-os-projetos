import 'package:flutter/material.dart';

import '../models/post.dart';
import '../services/post_service.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final PostService _postService = PostService();

  List<Post> _posts = [];
  List<Post> _postsFiltrados = [];

  final TextEditingController _searchController =
      TextEditingController();

  bool _pesquisando = false;

  @override
  void initState() {
    super.initState();
    _carregarPosts();
  }

  // =========================================================
  // BUSCAR POSTS
  // =========================================================

  Future<void> _carregarPosts() async {
    try {
      final resultado = await _postService.getPosts();

      setState(() {
        _posts = resultado.posts;
        _postsFiltrados = resultado.posts;
      });

      // Exercício 03:
      // Mostrar statusCode na SnackBar
      _mostrarStatusCode(resultado.statusCode);
    } catch (e) {
      _mostrarMensagem(
        'Erro ao carregar posts: $e',
      );
    }
  }

  // =========================================================
  // EXERCÍCIO 02
  // FILTRO DE BUSCA LOCAL
  // =========================================================

  void _filtrarPosts(String texto) {
    final busca = texto.toLowerCase();

    setState(() {
      _postsFiltrados = _posts.where((post) {
        return post.title
            .toLowerCase()
            .contains(busca);
      }).toList();
    });
  }

  // =========================================================
  // EXERCÍCIO 01
  // CONFIRMAÇÃO ANTES DO DELETE
  // =========================================================

  Future<void> _confirmarExclusao(Post post) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Confirmar exclusão',
          ),
          content: Text(
            'Deseja realmente excluir o post "${post.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    // Só executa o DELETE se o usuário confirmar
    if (confirmar == true) {
      await _deletarPost(post);
    }
  }

  // =========================================================
  // DELETE
  // =========================================================

  Future<void> _deletarPost(Post post) async {
    try {
      final statusCode =
          await _postService.deletePost(post.id!);

      setState(() {
        _posts.removeWhere(
          (item) => item.id == post.id,
        );

        _postsFiltrados.removeWhere(
          (item) => item.id == post.id,
        );
      });

      // Exercício 03:
      // Mostrar statusCode do DELETE
      _mostrarStatusCode(statusCode);
    } catch (e) {
      _mostrarMensagem(
        'Erro ao excluir post: $e',
      );
    }
  }

  // =========================================================
  // EXERCÍCIO 03
  // SNACKBAR COM STATUS CODE
  // =========================================================

  void _mostrarStatusCode(int statusCode) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'StatusCode: $statusCode',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // =========================================================
  // MENSAGEM DE ERRO
  // =========================================================

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
      ),
    );
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // =========================================================
  // INTERFACE
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _pesquisando
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Pesquisar pelo título...',
                  border: InputBorder.none,
                ),
                onChanged: _filtrarPosts,
              )
            : const Text('Posts'),

        actions: [
          // Exercício 02:
          // Botão para abrir a pesquisa
          IconButton(
            icon: Icon(
              _pesquisando
                  ? Icons.close
                  : Icons.search,
            ),
            onPressed: () {
              setState(() {
                if (_pesquisando) {
                  _pesquisando = false;

                  _searchController.clear();

                  _postsFiltrados = _posts;
                } else {
                  _pesquisando = true;
                }
              });
            },
          ),
        ],
      ),

      body: _postsFiltrados.isEmpty
          ? const Center(
              child: Text(
                'Nenhum post encontrado.',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            )
          : ListView.builder(
              itemCount: _postsFiltrados.length,
              itemBuilder: (context, index) {
                final post =
                    _postsFiltrados[index];

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(
                      post.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Text(
                      post.body,
                    ),

                    // Exercício 01:
                    // Botão DELETE
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        _confirmarExclusao(post);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}