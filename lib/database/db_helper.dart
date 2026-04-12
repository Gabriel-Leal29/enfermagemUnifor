// padrão singleton
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  DbHelper._(); // construtor privado.

  static final DbHelper instance = DbHelper._(); // instancia do db

  static Database? _database; // instancia do SQLite

  get database async {
    if (_database != null) return _database;

    _database = await _initDatabase(); // guarda a instancia do banco
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'enfermagem.db');
    print("CAMINHO DO DB: $path");

    // =====================================================================
    // ATENÇÃO: RODE O APP UMA VEZ COM ESSA LINHA DESCOMENTADA PARA ZERAR O BANCO.
    // DEPOIS QUE FUNCIONAR, COMENTE OU APAGUE ESTA LINHA, SENÃO VAI PERDER OS DADOS TODO DIA!
   // await deleteDatabase(path);
    // =====================================================================

    return await openDatabase(
      path, // não precisa do join aqui de novo, pois já está na variável path
      version: 1,
      onCreate: _onCreate,
    );
  }

  void _onCreate(db, versao) async {
    await db.execute(_fornecedor);
    await db.execute(_tipoPaciente);
    await db.execute(_tipoProduto);
    await db.execute(_config);
    await db.execute(_produto);
    await db.execute(_paciente);
    await db.execute(_gerenciarEstoque);
    //await db.execute(_consulta);
    //await db.execute(_consultaProduto);
    
    await _inserirDadosIniciais(db);
  }

  Future<void> _inserirDadosIniciais(Database db) async {
    // Inserindo Tipos de Produto
    await db.insert('tipoProduto', {'descricao': 'ML'});
    await db.insert('tipoProduto', {'descricao': 'UND'});

    // Inserindo Tipos de Paciente
    await db.insert('TipoPaciente', {'descricao': 'ALUNO'});
    await db.insert('TipoPaciente', {'descricao': 'VISITANTE'});
    await db.insert('TipoPaciente', {'descricao': 'PROFESSOR'});

    // Inserindo Fornecedor Fictício (Cimed)
    await db.insert('fornecedor', {
      'nome': 'Cimed', 
      'cnpj': '02.814.497/0001-07' // CNPJ gerado aleatoriamente para preencher
    });
  }

  String get _fornecedor => '''
  CREATE TABLE fornecedor (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    cnpj TEXT
  )
''';

  String get _gerenciarEstoque => '''
  CREATE TABLE gerenciar_estoque(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    numero_nfe TEXT NOT NULL,
    id_fornecedor INTEGER,
    id_produto INTEGER,                 
    quantidade REAL NOT NULL,
    data DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_fornecedor) REFERENCES Fornecedor(id),
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
    FOREIGN KEY (id_fornecedor) REFERENCES Fornecedor(id),
    FOREIGN KEY (id_tipo_produto) REFERENCES TipoProduto(id)
  )
''';

  String get _paciente => '''
  CREATE TABLE paciente(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    id_tipo_paciente INTEGER NOT NULL,
    FOREIGN KEY (id_tipo_paciente) REFERENCES TipoPaciente(id)
  )
''';

  String get _tipoProduto => '''
  CREATE TABLE tipoProduto (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    descricao TEXT NOT NULL UNIQUE
    )
''';

  String get _tipoPaciente => '''
  CREATE TABLE TipoPaciente (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    descricao TEXT NOT NULL UNIQUE
    )
''';

  //TODO: (gabriel_leal29) Vou fazer dps essas tabelas
//   String get _consulta => '''
//   CREATE TABLE consulta(
//
//   )
// ''';
//
//   String get _consultaProduto => '''
//   CREATE TABLE consultaProduto(
//
//   )
// ''';

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
}