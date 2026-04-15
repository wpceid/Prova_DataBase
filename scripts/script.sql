-- Criação dos schemas
CREATE SCHEMA IF NOT EXISTS academico;
CREATE SCHEMA IF NOT EXISTS seguranca;

-- Criação das tabelas no schema academico

-- Tabela aluno
CREATE TABLE academico.aluno (
    ID_Matricula INTEGER PRIMARY KEY,
    Nome_Usuario VARCHAR(255) NOT NULL,
    Email_Usuario VARCHAR(255) NOT NULL,
    Endereco_Usuario VARCHAR(255),
    Matricula_Operador_Pedagogico VARCHAR(50),
    Data_Ingresso DATE,
    Ciclo_Calendario VARCHAR(20),
    ativo BOOLEAN DEFAULT TRUE
);

-- Tabela disciplina
CREATE TABLE academico.disciplina (
    Cod_Servico_Academico VARCHAR(10) PRIMARY KEY,
    Nome_Disciplina VARCHAR(255) NOT NULL,
    Carga_H INTEGER,
    Nome_Docente VARCHAR(255),
    ativo BOOLEAN DEFAULT TRUE
);

-- Tabela matricula
CREATE TABLE academico.matricula (
    ID_Matricula INTEGER REFERENCES academico.aluno(ID_Matricula),
    Cod_Servico_Academico VARCHAR(10) REFERENCES academico.disciplina(Cod_Servico_Academico),
    Score_Final DECIMAL(4,2),
    ativo BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (ID_Matricula, Cod_Servico_Academico)
);

-- Implementação de Soft Delete: Regras para impedir DELETE físico e marcar como inativo

CREATE RULE delete_aluno AS ON DELETE TO academico.aluno
DO INSTEAD UPDATE academico.aluno SET ativo = FALSE WHERE ID_Matricula = OLD.ID_Matricula;

CREATE RULE delete_disciplina AS ON DELETE TO academico.disciplina
DO INSTEAD UPDATE academico.disciplina SET ativo = FALSE WHERE Cod_Servico_Academico = OLD.Cod_Servico_Academico;

CREATE RULE delete_matricula AS ON DELETE TO academico.matricula
DO INSTEAD UPDATE academico.matricula SET ativo = FALSE WHERE ID_Matricula = OLD.ID_Matricula AND Cod_Servico_Academico = OLD.Cod_Servico_Academico;

-- Segurança (DCL): Criação de roles e permissões

-- Criar role professor_role
CREATE ROLE professor_role;

-- Permissão de UPDATE apenas na coluna Score_Final da tabela matricula
GRANT UPDATE (Score_Final) ON academico.matricula TO professor_role;

-- Garantir que professor_role não tenha acesso à coluna Email_Usuario
REVOKE SELECT (Email_Usuario) ON academico.aluno FROM professor_role;

-- Criar role coordenador_role
CREATE ROLE coordenador_role;

-- Acesso total aos schemas academico e seguranca
GRANT ALL ON SCHEMA academico TO coordenador_role;
GRANT ALL ON SCHEMA seguranca TO coordenador_role;

-- Acesso total às tabelas existentes
GRANT ALL ON academico.aluno TO coordenador_role;
GRANT ALL ON academico.disciplina TO coordenador_role;
GRANT ALL ON academico.matricula TO coordenador_role;

-- População de Dados (DML)

-- Inserir dados na tabela academico.aluno
INSERT INTO academico.aluno (ID_Matricula, Nome_Usuario, Email_Usuario, Endereco_Usuario, Matricula_Operador_Pedagogico, Data_Ingresso, Ciclo_Calendario) VALUES
(2026001, 'Ana Beatriz Lima', 'ana.lima@aluno.edu.br', 'Braganca Paulista/SP', 'OP9001', '2026-01-20', '2026/1'),
(2026002, 'Bruno Henrique Souza', 'bruno.souza@aluno.edu.br', 'Atibaia/SP', 'OP9002', '2026-01-21', '2026/1'),
(2026003, 'Camila Ferreira', 'camila.ferreira@aluno.edu.br', 'Jundiai/SP', 'OP9001', '2026-01-22', '2026/1'),
(2026004, 'Diego Martins', 'diego.martins@aluno.edu.br', 'Campinas/SP', 'OP9003', '2026-01-23', '2026/1'),
(2026005, 'Eduarda Nunes', 'eduarda.nunes@aluno.edu.br', 'Itatiba/SP', 'OP9002', '2026-01-24', '2026/1'),
(2026006, 'Felipe Araujo', 'felipe.araujo@aluno.edu.br', 'Louveira/SP', 'OP9004', '2026-01-25', '2026/1'),
(2025010, 'Gabriela Torres', 'gabriela.torres@aluno.edu.br', 'Nazare Paulista/SP', 'OP8999', '2025-08-05', '2025/2'),
(2025011, 'Helena Rocha', 'helena.rocha@aluno.edu.br', 'Piracaia/SP', 'OP8999', '2025-08-06', '2025/2'),
(2025012, 'Igor Santana', 'igor.santana@aluno.edu.br', 'Jarinu/SP', 'OP9000', '2025-08-07', '2025/2');

-- Inserir dados na tabela academico.disciplina
INSERT INTO academico.disciplina (Cod_Servico_Academico, Nome_Disciplina, Carga_H, Nome_Docente) VALUES
('ADS101', 'Banco de Dados', 80, 'Prof. Carlos Mendes'),
('ADS102', 'Engenharia de Software', 80, 'Profa. Juliana Castro'),
('ADS103', 'Algoritmos', 60, 'Prof. Renato Alves'),
('ADS104', 'Redes de Computadores', 60, 'Profa. Marina Lopes'),
('ADS105', 'Sistemas Operacionais', 60, 'Prof. Eduardo Pires'),
('ADS106', 'Estruturas de Dados', 80, 'Prof. Ricardo Faria');

-- Inserir dados na tabela academico.matricula
INSERT INTO academico.matricula (ID_Matricula, Cod_Servico_Academico, Score_Final) VALUES
(2026001, 'ADS101', 9.1),
(2026001, 'ADS102', 8.4),
(2026001, 'ADS105', 8.9),
(2026002, 'ADS101', 7.3),
(2026002, 'ADS103', 6.8),
(2026002, 'ADS104', 7.0),
(2026003, 'ADS101', 5.9),
(2026003, 'ADS102', 7.5),
(2026003, 'ADS106', 6.1),
(2026004, 'ADS103', 4.7),
(2026004, 'ADS104', 6.2),
(2026004, 'ADS105', 5.8),
(2026005, 'ADS102', 9.5),
(2026005, 'ADS104', 8.1),
(2026005, 'ADS106', 8.7),
(2026006, 'ADS101', 6.4),
(2026006, 'ADS103', 5.6),
(2026006, 'ADS105', 6.9),
(2025010, 'ADS101', 6.4),
(2025010, 'ADS102', 7.1),
(2025011, 'ADS103', 8.8),
(2025011, 'ADS104', 7.9),
(2025012, 'ADS105', 5.5),
(2025012, 'ADS106', 6.3);

-- Consultas e Relatórios (DML)

-- 1. Listagem de Matriculados: Nome dos alunos, nomes das disciplinas e ciclo, filtrando apenas pelo ciclo 2026/1
SELECT a.Nome_Usuario, d.Nome_Disciplina, a.Ciclo_Calendario
FROM academico.aluno a
JOIN academico.matricula m ON a.ID_Matricula = m.ID_Matricula
JOIN academico.disciplina d ON m.Cod_Servico_Academico = d.Cod_Servico_Academico
WHERE a.Ciclo_Calendario = '2026/1' AND a.ativo = TRUE AND m.ativo = TRUE AND d.ativo = TRUE;

-- 2. Baixo Desempenho: Média de notas por disciplina, listando apenas aquelas cuja média geral seja inferior a 6.0 (Agregação e HAVING)
SELECT d.Nome_Disciplina, AVG(m.Score_Final) AS Media_Notas
FROM academico.disciplina d
JOIN academico.matricula m ON d.Cod_Servico_Academico = m.Cod_Servico_Academico
WHERE d.ativo = TRUE AND m.ativo = TRUE
GROUP BY d.Nome_Disciplina
HAVING AVG(m.Score_Final) < 6.0;

-- 3. Alocação de Docentes: Liste todos os docentes e suas respectivas disciplinas, garantindo que docentes que ainda não possuem turmas vinculadas também apareçam no relatório (LEFT JOIN)
SELECT d.Nome_Docente, d.Nome_Disciplina
FROM academico.disciplina d
LEFT JOIN academico.matricula m ON d.Cod_Servico_Academico = m.Cod_Servico_Academico
WHERE d.ativo = TRUE AND (m.ativo = TRUE OR m.ativo IS NULL);

-- 4. Destaque Acadêmico: Nome do aluno e o valor da nota do maior desempenho registrado na disciplina de "Banco de Dados" (Uso de Subconsulta)
SELECT a.Nome_Usuario, m.Score_Final
FROM academico.aluno a
JOIN academico.matricula m ON a.ID_Matricula = m.ID_Matricula
JOIN academico.disciplina d ON m.Cod_Servico_Academico = d.Cod_Servico_Academico
WHERE d.Nome_Disciplina = 'Banco de Dados' 
  AND m.Score_Final = (
      SELECT MAX(m2.Score_Final)
      FROM academico.matricula m2
      JOIN academico.disciplina d2 ON m2.Cod_Servico_Academico = d2.Cod_Servico_Academico
      WHERE d2.Nome_Disciplina = 'Banco de Dados' AND m2.ativo = TRUE AND d2.ativo = TRUE
  )
  AND a.ativo = TRUE AND m.ativo = TRUE AND d.ativo = TRUE;

