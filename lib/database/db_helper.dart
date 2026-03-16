// padrão singleton
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';

class DbHelper {
  DbHelper._(); // construtor privado.

  static final DbHelper instance = DbHelper._(); // instancia do db

  static Database? _database; // instancia do SQLite

  get database async {
    if (_database != null) return _database;

    return await _initDatabase();
  }

  _initDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'enfermagem.db'),
      version: 1,
      onCreate: _onCreate,
    );
  }

  _onCreate(db, versao) async {
    await db.execute(_fornecedor);
    await db.execute(_produto);
    await db.execute(_paciente);
    await db.execute(_gerenciarEstoque);
    await db.execute(_consulta);
    await db.execute(_consultaProduto);
    await db.execute(_tipoPaciente);
    await db.execute(_tipoProduto);
  }

  String get _fornecedor => '''
  CREATE TABLE fornecedor (
    id INT PRIMARY KEY AUTOINCREMENT,
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
''';

  String get _tipoPaciente => '''
  CREATE TABLE TipoPaciente (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    descricao TEXT NOT NULL UNIQUE
''';

  String get _consulta => '''
  CREATE TABLE consulta(
   
  )
''';

  String get _consultaProduto => '''
  CREATE TABLE consultaProduto(
  
  )
''';
}
