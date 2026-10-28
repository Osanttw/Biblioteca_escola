# Biblioteca Escolar – Banco de Dados

Atividade III – SEDUC DEST2 · Planejar, criar e testar um banco de dados.

**Autor:** Eduardo D. Lima

## 1. Domínio
Gerenciamento de uma **biblioteca escolar**: alunos, turmas, livros, exemplares e empréstimos.

## 2. Contextualização
A biblioteca de uma escola estadual controla os empréstimos em cadernos e planilhas soltas. Problemas:

- dados repetidos (nome e turma do aluno digitados a cada empréstimo) e com erros de grafia;
- o mesmo livro com títulos ou autores diferentes em planilhas distintas;
- difícil saber quem está com um livro ou quais empréstimos estão atrasados;
- nada impede emprestar um livro ou para um aluno que não existe;
- duas pessoas editando o mesmo arquivo perdem dados;
- sem backup confiável e sem relatórios (multas, livros mais lidos).

## 3. Proposta de melhoria
Usar um **SGBD relacional (MySQL/MariaDB)**, com dados centralizados e normalizados, chaves primárias e estrangeiras para garantir integridade, consultas SQL para relatórios, acesso simultâneo seguro e dump para backup.

## 4. Modelagem lógica

### Tabelas, campos e tipos

| Tabela | Campos |
|---|---|
| **turma** | id_turma INT PK AI · nome VARCHAR(20) · serie VARCHAR(20) · turno VARCHAR(10) |
| **aluno** | id_aluno INT PK AI · nome VARCHAR(100) · matricula VARCHAR(15) UNIQUE · email VARCHAR(100) · data_nascimento DATE · id_turma INT FK |
| **carteirinha** | id_carteirinha INT PK AI · id_aluno INT FK UNIQUE · data_emissao DATE · status VARCHAR(10) |
| **categoria** | id_categoria INT PK AI · nome VARCHAR(50) |
| **editora** | id_editora INT PK AI · nome VARCHAR(80) · cidade VARCHAR(50) |
| **autor** | id_autor INT PK AI · nome VARCHAR(100) · nacionalidade VARCHAR(50) |
| **livro** | id_livro INT PK AI · titulo VARCHAR(150) · ano_publicacao INT · id_categoria INT FK · id_editora INT FK |
| **livro_autor** | id_livro INT FK · id_autor INT FK · PK composta (id_livro, id_autor) |
| **exemplar** | id_exemplar INT PK AI · id_livro INT FK · codigo_tombo VARCHAR(10) UNIQUE · estado VARCHAR(10) |
| **emprestimo** | id_emprestimo INT PK AI · id_aluno INT FK · id_exemplar INT FK · data_emprestimo DATE · data_prevista DATE · data_devolucao DATE NULL · multa DECIMAL(6,2) |

### Relacionamentos e cardinalidades

| Relacionamento | Cardinalidade |
|---|---|
| turma → aluno | 1 : N |
| aluno ↔ carteirinha | 1 : 1 |
| categoria → livro | 1 : N |
| editora → livro | 1 : N |
| livro ↔ autor | N : N (tabela `livro_autor`) |
| livro → exemplar | 1 : N |
| aluno ↔ exemplar | N : N (tabela `emprestimo`) |



> Print da modelagem: `imagens/modelagem.png` (adicione o seu print nessa pasta).

## 5. Formas Normais

| Forma | O que foi aplicado | Por quê |
|---|---|---|
| **1FN** | Valores atômicos: os vários autores de um livro deixaram de ficar num único campo e viraram linhas (`autor` + `livro_autor`). | Permite buscar por autor e evita textos como "Machado, Graciliano". |
| **2FN** | Nenhum atributo depende de só parte de uma chave composta; dados do livro e do autor ficam em tabelas próprias. | Evita repetir título ou nacionalidade a cada par livro-autor. |
| **3FN** | `turno` foi para `turma` e `cidade` para `editora`; `categoria` e `editora` saíram de `livro`. | Remove dependências transitivas; cada dado é atualizado em um só lugar. |
| **4FN** | Autores e exemplares de um livro são fatos independentes, então ficam em tabelas separadas (`livro_autor` e `exemplar`). | Evita combinações artificiais (autor × exemplar) e linhas duplicadas. |

## 6. Como executar

Pré-requisito: MySQL 8+ ou MariaDB.

```bash
mysql -u root -p < biblioteca_escolar.sql
```

O script:
1. cria o banco `biblioteca_escolar`;
2. cria as 10 tabelas;
3. popula todas (turma 5, aluno 8, carteirinha 6, categoria 5, editora 5, autor 7, livro 9, livro_autor 10, exemplar 10, emprestimo 12);
4. executa as 15 consultas abaixo.

## 7. Consultas e respostas

| # | Contexto | Recursos | Resposta |
|---|---|---|---|
| 1 | Alunos com turma e turno | INNER JOIN, ORDER BY | 8 alunos (ex.: Ana Souza – 1º A – Manhã) |
| 2 | Catálogo com categoria e editora | INNER JOIN (3 tabelas) | 9 livros (ex.: Dom Casmurro – Romance – Ática) |
| 3 | Livros e seus autores | INNER JOIN N:N | 10 linhas; *Contos Brasileiros* tem 2 autores |
| 4 | Títulos que começam com "C" | LIKE | Capitães da Areia, Cosmos, Contos Brasileiros |
| 5 | Livros publicados entre 1930 e 1990 | BETWEEN | Capitães da Areia, Vidas Secas, Contos Brasileiros, Cosmos, Uma Breve História do Tempo |
| 6 | Empréstimos por aluno | GROUP BY, COUNT | Ana, Bruno, Carla e Elisa: 2 cada; demais: 1 |
| 7 | Total de multas | SUM | R$ 14,00 |
| 8 | Empréstimos não devolvidos | WHERE IS NULL | Gabriela, Carla e Bruno |
| 9 | Categorias com 2 ou mais livros | GROUP BY, HAVING | Romance 5; Ciência 2 |
| 10 | Top 3 livros mais emprestados | GROUP BY, ORDER BY, LIMIT | Dom Casmurro 3; Cosmos 2; Capitães da Areia 1 |
| 11 | Alunos que pagaram multa | WHERE, ORDER BY | Diego R$ 7,00; Bruno R$ 4,00; Ana R$ 3,00 |
| 12 | Média de dias de atraso | AVG, DATEDIFF | ≈ 9,33 dias |
| 13 | Empréstimos de setembro/2026 | BETWEEN com datas | 6 empréstimos |
| 14 | Empréstimos por turno | GROUP BY, JOIN (3 tabelas) | Manhã 6; Tarde 4; Noite 2 |
| 15 | Carteirinhas suspensas | INNER JOIN, WHERE | Diego Alves |

## 8. Dump do banco (estrutura + dados)

**Terminal (mysqldump)**
```bash
# Estrutura + dados
mysqldump -u root -p --databases biblioteca_escolar > biblioteca_escolar_dump.sql

# Somente estrutura
mysqldump -u root -p --no-data biblioteca_escolar > estrutura.sql

# Somente dados
mysqldump -u root -p --no-create-info biblioteca_escolar > dados.sql

# Restaurar
mysql -u root -p < biblioteca_escolar_dump.sql
```

**MySQL Workbench:** Server → Data Export → marcar `biblioteca_escolar` → *Dump Structure and Data* → *Export to Self-Contained File* → Start Export.

**phpMyAdmin:** selecionar o banco → aba Exportar → método Rápido, formato SQL → Executar.

## 9. Arquivos do repositório

| Arquivo | Conteúdo |
|---|---|
| `biblioteca_escolar.sql` | Criação do banco, tabelas, dados e as 15 consultas |
| `biblioteca_escolar_dump.sql` | Dump gerado com mysqldump (estrutura + dados) |
| `imagens/modelagem.png` | Print da modelagem |
| `README.md` | Este documento |
