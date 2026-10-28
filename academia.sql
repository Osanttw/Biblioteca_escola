

DROP DATABASE IF EXISTS biblioteca_escolar;
CREATE DATABASE biblioteca_escolar CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE biblioteca_escolar;


CREATE TABLE turma (
    id_turma   INT AUTO_INCREMENT PRIMARY KEY,
    nome       VARCHAR(20) NOT NULL,
    serie      VARCHAR(20) NOT NULL,
    turno      VARCHAR(10) NOT NULL
);

CREATE TABLE aluno (
    id_aluno        INT AUTO_INCREMENT PRIMARY KEY,
    nome            VARCHAR(100) NOT NULL,
    matricula       VARCHAR(15) NOT NULL UNIQUE,
    email           VARCHAR(100),
    data_nascimento DATE NOT NULL,
    id_turma        INT NOT NULL,
    FOREIGN KEY (id_turma) REFERENCES turma(id_turma)
);

-- 1:1 com aluno
CREATE TABLE carteirinha (
    id_carteirinha INT AUTO_INCREMENT PRIMARY KEY,
    id_aluno       INT NOT NULL UNIQUE,
    data_emissao   DATE NOT NULL,
    status         VARCHAR(10) NOT NULL DEFAULT 'Ativa',
    FOREIGN KEY (id_aluno) REFERENCES aluno(id_aluno)
);

CREATE TABLE categoria (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nome         VARCHAR(50) NOT NULL
);

CREATE TABLE editora (
    id_editora INT AUTO_INCREMENT PRIMARY KEY,
    nome       VARCHAR(80) NOT NULL,
    cidade     VARCHAR(50)
);

CREATE TABLE autor (
    id_autor     INT AUTO_INCREMENT PRIMARY KEY,
    nome         VARCHAR(100) NOT NULL,
    nacionalidade VARCHAR(50)
);

CREATE TABLE livro (
    id_livro        INT AUTO_INCREMENT PRIMARY KEY,
    titulo          VARCHAR(150) NOT NULL,
    ano_publicacao  INT,
    id_categoria    INT NOT NULL,
    id_editora      INT NOT NULL,
    FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria),
    FOREIGN KEY (id_editora)   REFERENCES editora(id_editora)
);

-- N:N entre livro e autor
CREATE TABLE livro_autor (
    id_livro INT NOT NULL,
    id_autor INT NOT NULL,
    PRIMARY KEY (id_livro, id_autor),
    FOREIGN KEY (id_livro) REFERENCES livro(id_livro),
    FOREIGN KEY (id_autor) REFERENCES autor(id_autor)
);

CREATE TABLE exemplar (
    id_exemplar INT AUTO_INCREMENT PRIMARY KEY,
    id_livro    INT NOT NULL,
    codigo_tombo VARCHAR(10) NOT NULL UNIQUE,
    estado      VARCHAR(10) NOT NULL,
    FOREIGN KEY (id_livro) REFERENCES livro(id_livro)
);

-- N:N entre aluno e exemplar (resolvido pela tabela emprestimo)
CREATE TABLE emprestimo (
    id_emprestimo    INT AUTO_INCREMENT PRIMARY KEY,
    id_aluno         INT NOT NULL,
    id_exemplar      INT NOT NULL,
    data_emprestimo  DATE NOT NULL,
    data_prevista    DATE NOT NULL,
    data_devolucao   DATE NULL,
    multa            DECIMAL(6,2) NOT NULL DEFAULT 0.00,
    FOREIGN KEY (id_aluno)    REFERENCES aluno(id_aluno),
    FOREIGN KEY (id_exemplar) REFERENCES exemplar(id_exemplar)
);

-- ---------------- DADOS ----------------
INSERT INTO turma (nome, serie, turno) VALUES
('1º A','1º ano','Manhã'),('2º A','2º ano','Manhã'),('3º A','3º ano','Tarde'),
('1º B','1º ano','Tarde'),('2º B','2º ano','Noite');

INSERT INTO aluno (nome, matricula, email, data_nascimento, id_turma) VALUES
('Ana Souza','2026001','ana@escola.sp.gov.br','2010-03-15',1),
('Bruno Lima','2026002','bruno@escola.sp.gov.br','2009-07-22',2),
('Carla Mendes','2026003','carla@escola.sp.gov.br','2008-11-05',3),
('Diego Alves','2026004','diego@escola.sp.gov.br','2010-01-30',4),
('Elisa Rocha','2026005','elisa@escola.sp.gov.br','2009-09-12',5),
('Felipe Santos','2026006','felipe@escola.sp.gov.br','2010-05-08',1),
('Gabriela Costa','2026007','gabi@escola.sp.gov.br','2008-12-19',3),
('Henrique Dias','2026008','henrique@escola.sp.gov.br','2009-04-25',2);

INSERT INTO carteirinha (id_aluno, data_emissao, status) VALUES
(1,'2026-02-01','Ativa'),(2,'2026-02-01','Ativa'),(3,'2026-02-02','Ativa'),
(4,'2026-02-03','Suspensa'),(5,'2026-02-03','Ativa'),(6,'2026-02-04','Ativa');

INSERT INTO categoria (nome) VALUES
('Romance'),('Ciência'),('História'),('Contos'),('Poesia');

INSERT INTO editora (nome, cidade) VALUES
('Ática','São Paulo'),('Saraiva','São Paulo'),('Record','Rio de Janeiro'),
('Companhia das Letras','São Paulo'),('Intrínseca','Rio de Janeiro');

INSERT INTO autor (nome, nacionalidade) VALUES
('Machado de Assis','Brasileira'),('Aluísio Azevedo','Brasileira'),
('Graciliano Ramos','Brasileira'),('Jorge Amado','Brasileira'),
('Carl Sagan','Americana'),('Stephen Hawking','Britânica'),
('Yuval Noah Harari','Israelense');

INSERT INTO livro (titulo, ano_publicacao, id_categoria, id_editora) VALUES
('Dom Casmurro',1899,1,1),
('Memórias Póstumas de Brás Cubas',1881,1,1),
('O Cortiço',1890,1,2),
('Vidas Secas',1938,1,3),
('Capitães da Areia',1937,1,4),
('Cosmos',1980,2,4),
('Uma Breve História do Tempo',1988,2,5),
('Sapiens',2011,3,4),
('Contos Brasileiros',1960,4,2);

INSERT INTO livro_autor (id_livro, id_autor) VALUES
(1,1),(2,1),(3,2),(4,3),(5,4),(6,5),(7,6),(8,7),(9,1),(9,3);

INSERT INTO exemplar (id_livro, codigo_tombo, estado) VALUES
(1,'TB001','Bom'),(1,'TB002','Regular'),(2,'TB003','Bom'),(3,'TB004','Bom'),
(4,'TB005','Ótimo'),(5,'TB006','Bom'),(6,'TB007','Ótimo'),(7,'TB008','Regular'),
(8,'TB009','Bom'),(9,'TB010','Bom');

INSERT INTO emprestimo (id_aluno, id_exemplar, data_emprestimo, data_prevista, data_devolucao, multa) VALUES
(1,1,'2026-09-01','2026-09-15','2026-09-14',0.00),
(2,3,'2026-09-03','2026-09-17','2026-09-25',4.00),
(3,5,'2026-09-05','2026-09-19','2026-09-19',0.00),
(1,7,'2026-09-10','2026-09-24','2026-09-30',3.00),
(4,2,'2026-09-12','2026-09-26','2026-10-10',7.00),
(5,9,'2026-09-15','2026-09-29','2026-09-28',0.00),
(6,4,'2026-10-01','2026-10-15','2026-10-14',0.00),
(7,8,'2026-10-02','2026-10-16',NULL,0.00),
(8,6,'2026-10-05','2026-10-19','2026-10-18',0.00),
(3,10,'2026-10-08','2026-10-22',NULL,0.00),
(2,1,'2026-10-12','2026-10-26',NULL,0.00),
(5,7,'2026-10-15','2026-10-29','2026-10-20',0.00);


-- 1) Listar todos os alunos com sua turma (INNER JOIN + ORDER BY)
SELECT a.nome AS aluno, t.nome AS turma, t.turno
FROM aluno a INNER JOIN turma t ON a.id_turma = t.id_turma
ORDER BY a.nome;

-- 2) Livros com categoria e editora (INNER JOIN múltiplo)
SELECT l.titulo, c.nome AS categoria, e.nome AS editora
FROM livro l
INNER JOIN categoria c ON l.id_categoria = c.id_categoria
INNER JOIN editora e ON l.id_editora = e.id_editora
ORDER BY l.titulo;

-- 3) Livros com seus autores (N:N)
SELECT l.titulo, a.nome AS autor
FROM livro l
INNER JOIN livro_autor la ON l.id_livro = la.id_livro
INNER JOIN autor a ON la.id_autor = a.id_autor
ORDER BY l.titulo, a.nome;

-- 4) Livros cujo título começa com "C" (LIKE)
SELECT titulo FROM livro WHERE titulo LIKE 'C%';

-- 5) Livros publicados entre 1930 e 1990 (BETWEEN)
SELECT titulo, ano_publicacao FROM livro
WHERE ano_publicacao BETWEEN 1930 AND 1990
ORDER BY ano_publicacao;

-- 6) Quantidade de empréstimos por aluno (GROUP BY + COUNT)
SELECT a.nome, COUNT(*) AS total_emprestimos
FROM emprestimo e INNER JOIN aluno a ON e.id_aluno = a.id_aluno
GROUP BY a.nome
ORDER BY total_emprestimos DESC, a.nome;

-- 7) Total de multas arrecadadas (SUM)
SELECT SUM(multa) AS total_multas FROM emprestimo;

-- 8) Empréstimos ainda não devolvidos (WHERE IS NULL)
SELECT a.nome AS aluno, l.titulo, e.data_prevista
FROM emprestimo e
INNER JOIN aluno a ON e.id_aluno = a.id_aluno
INNER JOIN exemplar x ON e.id_exemplar = x.id_exemplar
INNER JOIN livro l ON x.id_livro = l.id_livro
WHERE e.data_devolucao IS NULL;

-- 9) Quantidade de livros por categoria (GROUP BY + HAVING)
SELECT c.nome AS categoria, COUNT(l.id_livro) AS qtd_livros
FROM categoria c INNER JOIN livro l ON c.id_categoria = l.id_categoria
GROUP BY c.nome
HAVING COUNT(l.id_livro) >= 2
ORDER BY qtd_livros DESC;

-- 10) Livros mais emprestados (GROUP BY + ORDER BY + LIMIT)
SELECT l.titulo, COUNT(*) AS vezes_emprestado
FROM emprestimo e
INNER JOIN exemplar x ON e.id_exemplar = x.id_exemplar
INNER JOIN livro l ON x.id_livro = l.id_livro
GROUP BY l.titulo
ORDER BY vezes_emprestado DESC, l.titulo
LIMIT 3;

-- 11) Alunos que pagaram multa e valor (WHERE > 0)
SELECT a.nome, e.multa
FROM emprestimo e INNER JOIN aluno a ON e.id_aluno = a.id_aluno
WHERE e.multa > 0
ORDER BY e.multa DESC;

-- 12) Média de atraso em dias dos empréstimos devolvidos com atraso (AVG, DATEDIFF)
SELECT AVG(DATEDIFF(data_devolucao, data_prevista)) AS media_dias_atraso
FROM emprestimo
WHERE data_devolucao > data_prevista;

-- 13) Empréstimos feitos em setembro/2026 (BETWEEN com datas)
SELECT a.nome, e.data_emprestimo
FROM emprestimo e INNER JOIN aluno a ON e.id_aluno = a.id_aluno
WHERE e.data_emprestimo BETWEEN '2026-09-01' AND '2026-09-30'
ORDER BY e.data_emprestimo;

-- 14) Empréstimos por turno da turma (GROUP BY com JOIN em 3 tabelas)
SELECT t.turno, COUNT(*) AS total_emprestimos
FROM emprestimo e
INNER JOIN aluno a ON e.id_aluno = a.id_aluno
INNER JOIN turma t ON a.id_turma = t.id_turma
GROUP BY t.turno
ORDER BY total_emprestimos DESC;

-- 15) Alunos com carteirinha suspensa (INNER JOIN + WHERE)
SELECT a.nome, c.status, c.data_emissao
FROM aluno a INNER JOIN carteirinha c ON a.id_aluno = c.id_aluno
WHERE c.status = 'Suspensa';