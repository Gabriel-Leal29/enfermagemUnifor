# 🏥 Sistema de Gestão da Enfermaria - Unifor

Sistema desktop desenvolvido para auxiliar o setor de enfermagem da instituição no gerenciamento de consultas, pacientes, medicamentos e controle de estoque.

O projeto foi desenvolvido como atividade da disciplina de **Extensão V** do curso de **Ciência da Computação**.

---

# 🎯 Objetivo do Projeto

O sistema tem como objetivo substituir os registros manuais realizados em cadernos e documentos físicos, proporcionando maior organização, rapidez e segurança no controle das consultas realizadas pela enfermaria.

---

# ⚙️ Funcionalidades

## 👥 Pacientes

* Cadastro de pacientes
* Edição e exclusão de pacientes
* Identificação por tipo:

  * 🎓 Aluno
  * 👨‍🏫 Professor
  * 🚶 Visitante
* Validação de CPF

## 💊 Produtos e Medicamentos

* Cadastro de medicamentos e produtos
* Controle de estoque
* Registro de movimentações de entrada e saída
* Associação com fornecedores

## 📋 Consultas

* Cadastro de consultas
* Edição e exclusão de consultas
* Associação de medicamentos utilizados
* Registro de responsável, data, queixa e observações
* Impressão de relatórios em PDF

## 📊 Dashboard

* Indicadores gerais do sistema
* Quantidade de pacientes
* Quantidade de consultas
* Controle visual do estoque

---

# 🛠️ Tecnologias Utilizadas

## 💻 Frontend/Desktop

* Flutter

## 🗄️ Banco de Dados

* SQLite
* sqflite_common_ffi

## 🧱 Arquitetura

* DAO (Data Access Object)
* Service Layer
* DTOs

## 📚 Bibliotecas

* provider
* intl
* pdf
* printing
* mocktail
* flutter_test

---

# 📁 Estrutura do Projeto

```bash
lib/
├── dao/
├── dto/
├── exceptions/
├── model/
├── pages/
├── service/
├── theme/
├── widgets/
└── main.dart
```

---

# 🧪 Testes

O projeto possui testes unitários implementados utilizando:

* flutter_test
* mocktail

Os testes abrangem:

* ✅ Cadastro de pacientes
* ✅ Edição de pacientes
* ✅ Exclusão de pacientes
* ✅ Cadastro de consultas
* ✅ Listagem paginada
* ✅ Tratamento de exceções
* ✅ Validações de regras de negócio

---

# 🚀 Funcionalidades Futuras

* 🔐 Sistema de login
* 👤 Controle de permissões
* ☁️ Backup automático
* 📑 Relatórios avançados
* 🌐 Multiusuário em rede local

---

# 👨‍💻 Equipe Desenvolvedora

Projeto desenvolvido pelos alunos:

* Gabriel Diniz Prates
* Gustavo de Castro
* João César Serwinks
* Gabriel Leal de Oliveira

---

# 📄 Licença

Projeto desenvolvido exclusivamente para fins acadêmicos na disciplina de **Extensão V**.
