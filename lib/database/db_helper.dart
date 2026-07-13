// padrão singleton
import 'dart:io';
import 'package:bcrypt/bcrypt.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  DbHelper._(); // construtor privado.

  static final DbHelper instance = DbHelper._(); // instancia do db

  static Database? _database; // instancia do SQLite

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory appDataDir = await getApplicationSupportDirectory();

    String path = join(appDataDir.path, 'enfermagem.db');

    print("CAMINHO DO BANCO DE DADOS: $path");

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  void _onCreate(db, versao) async {
    await db.execute(_usuario);
    await db.execute(_fornecedor);
    await db.execute(_tipoPaciente);
    await db.execute(_tipoProduto);
    await db.execute(_config);
    await db.execute(_produto);
    await db.execute(_paciente);
    await db.execute(_gerenciarEstoque);
    await db.execute(_consulta);
    await db.execute(_consultaProduto);

    await _inserirDadosIniciais(db);
    //await _preencherBancoTestes(db);
  }

  Future<void> _onUpgrade(
      Database db,
      int oldVersion,
      int newVersion,
      ) async {

    if (oldVersion < 2) {
      await _migrarSenhasParaBcrypt(db);
      await _criarUsuarioLarissa(db);
    }

  }

  Future<void> _migrarSenhasParaBcrypt(Database db) async {

    final usuarios = await db.query('usuario');

    for (final usuario in usuarios) {

      final senhaAtual = usuario['senha'] as String;

      // já está criptografada?
      if (senhaAtual.startsWith(r'$2')) {
        continue;
      }

      final senhaHash =
      BCrypt.hashpw(senhaAtual, BCrypt.gensalt());

      await db.update(
        'usuario',
        {'senha': senhaHash},
        where: 'id = ?',
        whereArgs: [usuario['id']],
      );
    }
  }

  Future<void> _criarUsuarioLarissa(Database db) async {

    final existe = await db.query(
      'usuario',
      where: 'login = ?',
      whereArgs: ['Larissa'],
    );

    if (existe.isEmpty) {
      await db.insert(
        'usuario',
        {
          'login': 'Larissa',
          'senha': BCrypt.hashpw(
            'unifor2026',
            BCrypt.gensalt(),
          ),
        },
      );
    }
  }


  Future<void> _inserirDadosIniciais(Database db) async {
    await db.insert('usuario', {
      'login': 'admin',
      'senha': BCrypt.hashpw('123', BCrypt.gensalt()),
    });

    await db.insert('usuario', {
      'login': 'Larissa',
      'senha': BCrypt.hashpw('unifor2026', BCrypt.gensalt()),
    });

    await db.insert('tipo_produto', {'descricao': 'UND'});

    await db.insert('tipo_paciente', {'descricao': 'ALUNO'});
    await db.insert('tipo_paciente', {'descricao': 'VISITANTE'});
    await db.insert('tipo_paciente', {'descricao': 'PROFESSOR'});
  }

  Future<void> _preencherBancoTestes(Database db) async {
    
    final fornecedorId = await db.insert('fornecedor', {
      'nome': 'Fornecedor Geral',
      'razao_social': 'Fornecedor Geral LTDA',
      'cnpj': '12345678000199',
    });

    
    final pacientesIds = <int>[];

    pacientesIds.add(
      await db.insert('paciente', {
        'nome': 'João Silva',
        'matricula': '2023001',
        'cpf': '11111111111',
        'id_tipo_paciente': 1,
      }),
    );

    pacientesIds.add(
      await db.insert('paciente', {
        'nome': 'Maria Souza',
        'matricula': '2023002',
        'cpf': '22222222222',
        'id_tipo_paciente': 2,
      }),
    );

    pacientesIds.add(
      await db.insert('paciente', {
        'nome': 'Carlos Oliveira',
        'matricula': '2023003',
        'cpf': '33333333333',
        'id_tipo_paciente': 3,
      }),
    );

    pacientesIds.add(
      await db.insert('paciente', {
        'nome': 'Ana Lima',
        'matricula': '2023004',
        'cpf': '44444444444',
        'id_tipo_paciente': 1,
      }),
    );

    pacientesIds.add(
      await db.insert('paciente', {
        'nome': 'Pedro Santos',
        'matricula': '2023005',
        'cpf': '55555555555',
        'id_tipo_paciente': 2,
      }),
    );

    pacientesIds.add(
      await db.insert('paciente', {
        'nome': 'Juliana Costa',
        'matricula': '2023006',
        'cpf': '66666666666',
        'id_tipo_paciente': 3,
      }),
    );

    pacientesIds.add(
      await db.insert('paciente', {
        'nome': 'Fernanda Rocha',
        'matricula': '2023007',
        'cpf': '77777777777',
        'id_tipo_paciente': 1,
      }),
    );

    pacientesIds.add(
      await db.insert('paciente', {
        'nome': 'Lucas Alves',
        'matricula': '2023008',
        'cpf': '88888888888',
        'id_tipo_paciente': 2,
      }),
    );

    pacientesIds.add(
      await db.insert('paciente', {
        'nome': 'Patrícia Gomes',
        'matricula': '2023009',
        'cpf': '99999999999',
        'id_tipo_paciente': 3,
      }),
    );

    pacientesIds.add(
      await db.insert('paciente', {
        'nome': 'Bruno Martins',
        'matricula': '2023010',
        'cpf': '10101010101',
        'id_tipo_paciente': 1,
      }),
    );

    // 💊 PRODUTOS
    final produtosIds = <int>[];

    produtosIds.add(
      await db.insert('produto', {
        'nome': 'Dipirona',
        'estoque': 100,
        'id_fornecedor': fornecedorId,
        'id_tipo_produto': 1,
      }),
    );

    produtosIds.add(
      await db.insert('produto', {
        'nome': 'Paracetamol',
        'estoque': 80,
        'id_fornecedor': fornecedorId,
        'id_tipo_produto': 1,
      }),
    );

    produtosIds.add(
      await db.insert('produto', {
        'nome': 'Ibuprofeno',
        'estoque': 60,
        'id_fornecedor': fornecedorId,
        'id_tipo_produto': 1,
      }),
    );

    produtosIds.add(
      await db.insert('produto', {
        'nome': 'Amoxicilina',
        'estoque': 40,
        'id_fornecedor': fornecedorId,
        'id_tipo_produto': 1,
      }),
    );

    produtosIds.add(
      await db.insert('produto', {
        'nome': 'Soro Fisiológico',
        'estoque': 120,
        'id_fornecedor': fornecedorId,
        'id_tipo_produto': 1,
      }),
    );

    produtosIds.add(
      await db.insert('produto', {
        'nome': 'Álcool 70%',
        'estoque': 200,
        'id_fornecedor': fornecedorId,
        'id_tipo_produto': 1,
      }),
    );

    produtosIds.add(
      await db.insert('produto', {
        'nome': 'Seringa 10ml',
        'estoque': 150,
        'id_fornecedor': fornecedorId,
        'id_tipo_produto': 1,
      }),
    );

    produtosIds.add(
      await db.insert('produto', {
        'nome': 'Luvas Descartáveis',
        'estoque': 300,
        'id_fornecedor': fornecedorId,
        'id_tipo_produto': 1,
      }),
    );

    produtosIds.add(
      await db.insert('produto', {
        'nome': 'Gaze',
        'estoque': 500,
        'id_fornecedor': fornecedorId,
        'id_tipo_produto': 1,
      }),
    );

    produtosIds.add(
      await db.insert('produto', {
        'nome': 'Termômetro',
        'estoque': 30,
        'id_fornecedor': fornecedorId,
        'id_tipo_produto': 1,
      }),
    );

    // 📋 CONSULTAS
    final consultasIds = <int>[];

    for (int i = 0; i < 15; i++) {
      final id = await db.insert('consulta', {
        'id_paciente': pacientesIds[i % pacientesIds.length],
        'observacao': i % 2 == 0 ? 'Observação $i' : null,
        'responsavel': 'Enfermeiro $i',
        'demanda': 'Demanda $i',
        'data': DateTime.now()
            .subtract(Duration(days: i))
            .millisecondsSinceEpoch,
      });

      consultasIds.add(id);
    }

    // 🔗 CONSULTA_PRODUTO
    for (int i = 0; i < consultasIds.length; i++) {
      await db.insert('consulta_produto', {
        'id_consulta': consultasIds[i],
        'id_produto': produtosIds[i % produtosIds.length],
        'quant_produto': (i % 5) + 1,
      });

      // adiciona mais um produto em algumas consultas
      if (i % 2 == 0) {
        await db.insert('consulta_produto', {
          'id_consulta': consultasIds[i],
          'id_produto': produtosIds[(i + 1) % produtosIds.length],
          'quant_produto': 2,
        });
      }
    }
  }

  String get _fornecedor => '''
  CREATE TABLE fornecedor (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    razao_social TEXT,
    cnpj TEXT UNIQUE 
  )
''';

  String get _gerenciarEstoque => '''
  CREATE TABLE gerenciar_estoque(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    numero_nfe TEXT NOT NULL,
    id_produto INTEGER,                 
    quantidade REAL NOT NULL,
    situacao TEXT,
    data DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_produto) REFERENCES Produto(id)
    );
''';

  String get _produto => '''
  CREATE TABLE produto(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    estoque REAL NOT NULL,
    id_fornecedor INTEGER,
    id_tipo_produto INTEGER NOT NULL,
    status TEXT DEFAULT 'ativo',
    FOREIGN KEY (id_fornecedor) REFERENCES Fornecedor(id),
    FOREIGN KEY (id_tipo_produto) REFERENCES TipoProduto(id)
  )
''';

  String get _paciente => '''
  CREATE TABLE paciente(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    matricula TEXT,
    cpf TEXT UNIQUE,
    id_tipo_paciente INTEGER NOT NULL,
    FOREIGN KEY (id_tipo_paciente) REFERENCES tipo_paciente(id)
  )
''';

  String get _tipoProduto => '''
  CREATE TABLE tipo_produto (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    descricao TEXT NOT NULL UNIQUE
    )
''';

  String get _tipoPaciente => '''
  CREATE TABLE tipo_paciente (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    descricao TEXT NOT NULL UNIQUE
    )
''';

  String get _consulta => '''
    CREATE TABLE consulta(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      id_paciente INTEGER NOT NULL,
      observacao TEXT,
      responsavel TEXT,
      demanda TEXT NOT NULL,
      data INTEGER NOT NULL,
      FOREIGN KEY (id_paciente) REFERENCES paciente(id)
    )
  ''';

  String get _consultaProduto => '''
    CREATE TABLE consulta_produto(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      id_produto INTEGER NOT NULL,
      id_consulta INTEGER NOT NULL,
      quant_produto INTEGER NOT NULL,
      FOREIGN  KEY (id_consulta) REFERENCES consulta(id),
      FOREIGN  KEY (id_produto) REFERENCES produto(id)
    )
  ''';

  String get _config => '''
  CREATE TABLE config (
    id INTEGER PRIMARY KEY CHECK (id = 1),
    nome_instituicao TEXT NOT NULL,
    cnpj TEXT,
    endereco TEXT,
    telefone TEXT,
    impressora TEXT
    )
''';

  String get _usuario => '''
  CREATE TABLE usuario (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    login TEXT NOT NULL UNIQUE,
    senha TEXT NOT NULL
    )
''';
}
