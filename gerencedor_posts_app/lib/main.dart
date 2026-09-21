import 'package:flutter/material.dart';
import 'models/post.dart';
import 'services/post_service.dart';

void main() {
  runApp(const GerenciadorPostsApp());
}

class GerenciadorPostsApp extends StatelessWidget {
  const GerenciadorPostsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciador de Posts API',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const PostsScreen(),
    );
  }
}

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  List<Post> _posts = [];

  // Lista utilizada para a pesquisa
  List<Post> _postsFiltrados = [];

  bool _isLoading = true;

  // Controlador da pesquisa
  final TextEditingController _searchController =
      TextEditingController();

  // Indica se a pesquisa está aberta
  bool _pesquisando = false;

  @override
  void initState() {
    super.initState();
    _carregarPosts();
  }

  // =========================================================
  // GET - CARREGAR POSTS
  // =========================================================

  Future<void> _carregarPosts() async {
    setState(() => _isLoading = true);

    try {
      final posts = await PostService.fetchPosts();

      setState(() {
        _posts = posts;
        _postsFiltrados = posts;
      });

      // EXERCÍCIO 03
      // Mostra o statusCode do GET
      _mostrarSnackBar(
        'Posts carregados. StatusCode: ${PostService.lastStatusCode}',
        Colors.green,
      );
    } catch (e) {
      _mostrarSnackBar(
        'Erro ao carregar posts: $e',
        Colors.red,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // =========================================================
  // EXERCÍCIO 02
  // FILTRO DE BUSCA PELO TÍTULO
  // =========================================================

  void _filtrarPosts(String texto) {
    final busca = texto.toLowerCase();

    setState(() {
      _postsFiltrados = _posts.where((post) {
        return post.title.toLowerCase().contains(busca);
      }).toList();
    });
  }

  // =========================================================
  // SNACKBAR
  // =========================================================

  void _mostrarSnackBar(String mensagem, Color cor) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: cor,
      ),
    );
  }

  // =========================================================
  // FORMULÁRIO POST / PUT
  // =========================================================

  void _abrirFormulario({Post? post}) {
    final titleController =
        TextEditingController(text: post?.title ?? '');

    final bodyController =
        TextEditingController(text: post?.body ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          post == null
              ? 'Novo Post (POST)'
              : 'Editar Post (PUT)',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: bodyController,
              decoration: const InputDecoration(
                labelText: 'Conteúdo',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);

              final novoTitle =
                  titleController.text.trim();

              final novoBody =
                  bodyController.text.trim();

              if (novoTitle.isEmpty ||
                  novoBody.isEmpty) {
                return;
              }

              // =================================================
              // POST - CRIAR
              // =================================================

              if (post == null) {
                try {
                  final novoPost =
                      await PostService.createPost(
                    Post(
                      title: novoTitle,
                      body: novoBody,
                    ),
                  );

                  setState(() {
                    _posts.insert(0, novoPost);
                    _postsFiltrados = _posts;
                  });

                  // EXERCÍCIO 03
                  _mostrarSnackBar(
                    'Post criado. StatusCode: '
                    '${PostService.lastStatusCode}',
                    Colors.green,
                  );
                } catch (e) {
                  _mostrarSnackBar(
                    'Erro ao criar post: $e',
                    Colors.red,
                  );
                }
              }

              // =================================================
              // PUT - ATUALIZAR
              // =================================================

              else {
                try {
                  final postAtualizado =
                      await PostService.updatePost(
                    post.id!,
                    Post(
                      id: post.id,
                      title: novoTitle,
                      body: novoBody,
                    ),
                  );

                  setState(() {
                    final index = _posts.indexWhere(
                      (p) => p.id == post.id,
                    );

                    if (index != -1) {
                      _posts[index] = postAtualizado;
                    }

                    _postsFiltrados = List.from(_posts);
                  });

                  // EXERCÍCIO 03
                  _mostrarSnackBar(
                    'Post atualizado. StatusCode: '
                    '${PostService.lastStatusCode}',
                    Colors.blue,
                  );
                } catch (e) {
                  _mostrarSnackBar(
                    'Erro ao atualizar post: $e',
                    Colors.red,
                  );
                }
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // EXERCÍCIO 01
  // CONFIRMAÇÃO ANTES DO DELETE
  // =========================================================

  Future<void> _confirmarExclusao(Post post) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text(
            'Confirmar exclusão',
          ),
          content: Text(
            'Tem certeza que deseja excluir o post '
            '"${post.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx, false);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx, true);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    // Só executa o DELETE se o usuário confirmar
    if (confirmar == true) {
      await _deletarPost(post.id!);
    }
  }

  // =========================================================
  // DELETE
  // =========================================================

  Future<void> _deletarPost(int id) async {
    try {
      final statusCode =
          await PostService.deletePost(id);

      setState(() {
        _posts.removeWhere(
          (p) => p.id == id,
        );

        _postsFiltrados.removeWhere(
          (p) => p.id == id,
        );
      });

      // EXERCÍCIO 03
      _mostrarSnackBar(
        'Post excluído. StatusCode: $statusCode',
        Colors.orange,
      );
    } catch (e) {
      _mostrarSnackBar(
        'Erro ao excluir post: $e',
        Colors.red,
      );
    }
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
            : const Text(
                'Gerenciador de Posts (REST API)',
              ),

        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,

        actions: [
          // =================================================
          // EXERCÍCIO 02
          // BOTÃO DE PESQUISA
          // =================================================

          IconButton(
            icon: Icon(
              _pesquisando
                  ? Icons.close
                  : Icons.search,
            ),
            onPressed: () {
              setState(() {
                if (_pesquisando) {
                  // Fecha a pesquisa
                  _pesquisando = false;

                  _searchController.clear();

                  // Volta a mostrar todos
                  _postsFiltrados =
                      List.from(_posts);
                } else {
                  // Abre a pesquisa
                  _pesquisando = true;
                }
              });
            },
          ),
        ],
      ),

      // =====================================================
      // CORPO
      // =====================================================

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _carregarPosts,
              child: _postsFiltrados.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 250),
                        Center(
                          child: Text(
                            'Nenhum post encontrado.',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemCount: _postsFiltrados.length,
                      itemBuilder: (ctx, index) {
                        final post =
                            _postsFiltrados[index];

                        return Card(
                          margin:
                              const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ListTile(
                            title: Text(
                              post.title,
                              style: const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              post.body,
                            ),
                            trailing: Row(
                              mainAxisSize:
                                  MainAxisSize.min,
                              children: [
                                // EDITAR
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () =>
                                      _abrirFormulario(
                                    post: post,
                                  ),
                                ),

                                // DELETE
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () =>
                                      _confirmarExclusao(
                                    post,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

      // =====================================================
      // BOTÃO ADICIONAR
      // =====================================================

      floatingActionButton:
          FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        backgroundColor: Colors.deepPurple,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
