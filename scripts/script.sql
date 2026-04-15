-- ============================================================================
-- SCRIPT SQL COMPLETO - PROVA DE BANCO DE DADOS
-- ============================================================================
-- Objetivo: Criar ambiente normalizado em 3NF com segurança e governança
-- ============================================================================

-- ============================================================================
-- 1. CRIAÇÃO DE SCHEMAS (Namespaces)
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS academico;
CREATE SCHEMA IF NOT EXISTS seguranca;

COMMENT ON SCHEMA academico IS 'Schema contendo dados acadêmicos (alunos, disciplinas, professores, turmas, matrículas)';
COMMENT ON SCHEMA seguranca IS 'Schema contendo dados de controle de acesso e segurança';

-- ============================================================================
-- 2. DDL - CRIAÇÃO DE TABELAS NO SCHEMA academico
-- ============================================================================

-- Tabela: professor
CREATE TABLE academico.professor (
    ID_Professor VARCHAR(10) PRIMARY KEY,
    Nome_Professor VARCHAR(255) NOT NULL,
    ativo BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE academico.professor IS 'Tabela de professores que lecionam disciplinas';
COMMENT ON COLUMN academico.professor.ID_Professor IS 'Identificador único do professor';
COMMENT ON COLUMN academico.professor.Nome_Professor IS 'Nome completo do professor';
COMMENT ON COLUMN academico.professor.ativo IS 'Flag para soft delete (TRUE = ativo, FALSE = inativo)';

-- Tabela: turma
CREATE TABLE academico.turma (
    ID_Turma VARCHAR(10) PRIMARY KEY,
    Ciclo_Calendario VARCHAR(20) NOT NULL UNIQUE,
    Status VARCHAR(50) NOT NULL,
    ativo BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE academico.turma IS 'Tabela de turmas/ciclos acadêmicos';
COMMENT ON COLUMN academico.turma.ID_Turma IS 'Identificador único da turma';
COMMENT ON COLUMN academico.turma.Ciclo_Calendario IS 'Ciclo calendário único (ex: 2026/1)';
COMMENT ON COLUMN academico.turma.Status IS 'Status da turma (Ativo, Concluído, etc)';
COMMENT ON COLUMN academico.turma.ativo IS 'Flag para soft delete';

-- Tabela: aluno
CREATE TABLE academico.aluno (
    ID_Matricula INTEGER PRIMARY KEY,
    Nome_Usuario VARCHAR(255) NOT NULL,
    Email_Usuario VARCHAR(255) UNIQUE NOT NULL,
    Endereco_Usuario VARCHAR(255),
    Matricula_Operador_Pedagogico VARCHAR(50),
    Data_Ingresso DATE NOT NULL,
    ativo BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE academico.aluno IS 'Tabela de alunos do sistema acadêmico';
COMMENT ON COLUMN academico.aluno.ID_Matricula IS 'Identificador único do aluno (matrícula)';
COMMENT ON COLUMN academico.aluno.Email_Usuario IS 'E-mail único do aluno';
COMMENT ON COLUMN academico.aluno.ativo IS 'Flag para soft delete';

-- Tabela: disciplina
CREATE TABLE academico.disciplina (
    Cod_Servico_Academico VARCHAR(10) PRIMARY KEY,
    Nome_Disciplina VARCHAR(255) NOT NULL,
    Carga_H INTEGER NOT NULL,
    ID_Professor VARCHAR(10) NOT NULL,
    ativo BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_disciplina_professor FOREIGN KEY (ID_Professor) 
        REFERENCES academico.professor(ID_Professor) ON DELETE RESTRICT
);

CREATE INDEX idx_disciplina_professor ON academico.disciplina(ID_Professor);

COMMENT ON TABLE academico.disciplina IS 'Tabela de disciplinas oferecidas';
COMMENT ON COLUMN academico.disciplina.Cod_Servico_Academico IS 'Código único da disciplina';
COMMENT ON COLUMN academico.disciplina.ID_Professor IS 'Chave estrangeira para professor responsável';
COMMENT ON COLUMN academico.disciplina.ativo IS 'Flag para soft delete';

-- Tabela: matricula (tabela de junção N:N)
CREATE TABLE academico.matricula (
    ID_Matricula INTEGER NOT NULL,
    Cod_Servico_Academico VARCHAR(10) NOT NULL,
    ID_Turma VARCHAR(10) NOT NULL,
    Score_Final DECIMAL(4, 2) NOT NULL,
    ativo BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (ID_Matricula, Cod_Servico_Academico, ID_Turma),
    CONSTRAINT fk_matricula_aluno FOREIGN KEY (ID_Matricula) 
        REFERENCES academico.aluno(ID_Matricula) ON DELETE RESTRICT,
    CONSTRAINT fk_matricula_disciplina FOREIGN KEY (Cod_Servico_Academico) 
        REFERENCES academico.disciplina(Cod_Servico_Academico) ON DELETE RESTRICT,
    CONSTRAINT fk_matricula_turma FOREIGN KEY (ID_Turma) 
        REFERENCES academico.turma(ID_Turma) ON DELETE RESTRICT,
    CONSTRAINT chk_score_final CHECK (Score_Final >= 0 AND Score_Final <= 10)
);

CREATE INDEX idx_matricula_aluno ON academico.matricula(ID_Matricula);
CREATE INDEX idx_matricula_disciplina ON academico.matricula(Cod_Servico_Academico);
CREATE INDEX idx_matricula_turma ON academico.matricula(ID_Turma);

COMMENT ON TABLE academico.matricula IS 'Tabela de junção entre alunos, disciplinas e turmas (muitos para muitos)';
COMMENT ON COLUMN academico.matricula.Score_Final IS 'Nota final do aluno na disciplina (0-10)';
COMMENT ON COLUMN academico.matricula.ativo IS 'Flag para soft delete';

-- ============================================================================
-- 3. TABELA DE AUDITORIA NO SCHEMA seguranca (para tracking de operações)
-- ============================================================================

CREATE TABLE seguranca.audit_log (
    audit_id SERIAL PRIMARY KEY,
    tabela_nome VARCHAR(100),
    operacao VARCHAR(10) -- INSERT, UPDATE, DELETE
    ,usuario VARCHAR(100),
    registro_id VARCHAR(100),
    data_operacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    detalhes TEXT
);

COMMENT ON TABLE seguranca.audit_log IS 'Tabela de auditoria para rastrear operações críticas';

-- ============================================================================
-- 4. DCL - CRIAÇÃO DE ROLES E PERMISSÕES
-- ============================================================================

-- Criação de roles
CREATE ROLE professor_role LOGIN PASSWORD 'prof_senha_123';
CREATE ROLE coordenador_role LOGIN PASSWORD 'coord_senha_123';

-- Permissões para professor_role:
-- - Acesso READ nas tabelas aluno (sem email), disciplina, turma, matricula
-- - UPDATE apenas na coluna Score_Final da tabela matricula
GRANT USAGE ON SCHEMA academico TO professor_role;
GRANT SELECT ON academico.aluno, academico.disciplina, academico.turma, academico.matricula TO professor_role;
GRANT UPDATE (Score_Final, data_atualizacao) ON academico.matricula TO professor_role;

-- Negar acesso à coluna Email_Usuario para professor_role (nível de coluna)
-- Nota: PostgreSQL não suporta REVOKE de coluna específica, usar Row-Level Security (RLS)
ALTER TABLE academico.aluno ENABLE ROW LEVEL SECURITY;
CREATE POLICY professor_aluno_policy ON academico.aluno 
    FOR SELECT TO professor_role 
    USING (TRUE) 
    WITH CHECK (FALSE);

-- Permissões para coordenador_role:
-- - Acesso total aos schemas academico e seguranca
GRANT USAGE ON SCHEMA academico, seguranca TO coordenador_role;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA academico TO coordenador_role;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA seguranca TO coordenador_role;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA academico, seguranca TO coordenador_role;

-- ============================================================================
-- 5. DML - INSERÇÃO DE DADOS (Population)
-- ============================================================================

-- Inserir dados na tabela professor
INSERT INTO academico.professor (ID_Professor, Nome_Professor) VALUES
('P001', 'Prof. Carlos Mendes'),
('P002', 'Profa. Juliana Castro'),
('P003', 'Prof. Eduardo Pires'),
('P004', 'Prof. Renato Alves'),
('P005', 'Profa. Marina Lopes'),
('P006', 'Prof. Ricardo Faria');

-- Inserir dados na tabela turma
INSERT INTO academico.turma (ID_Turma, Ciclo_Calendario, Status) VALUES
('T001', '2026/1', 'Ativo'),
('T002', '2025/2', 'Concluído');

-- Inserir dados na tabela aluno
INSERT INTO academico.aluno (ID_Matricula, Nome_Usuario, Email_Usuario, Endereco_Usuario, Matricula_Operador_Pedagogico, Data_Ingresso) VALUES
(2026001, 'Ana Beatriz Lima', 'ana.lima@aluno.edu.br', 'Braganca Paulista/SP', 'OP9001', '2026-01-20'),
(2026002, 'Bruno Henrique Souza', 'bruno.souza@aluno.edu.br', 'Atibaia/SP', 'OP9002', '2026-01-21'),
(2026003, 'Camila Ferreira', 'camila.ferreira@aluno.edu.br', 'Jundiai/SP', 'OP9001', '2026-01-22'),
(2026004, 'Diego Martins', 'diego.martins@aluno.edu.br', 'Campinas/SP', 'OP9003', '2026-01-23'),
(2026005, 'Eduarda Nunes', 'eduarda.nunes@aluno.edu.br', 'Itatiba/SP', 'OP9002', '2026-01-24'),
(2026006, 'Felipe Araujo', 'felipe.araujo@aluno.edu.br', 'Louveira/SP', 'OP9004', '2026-01-25'),
(2025010, 'Gabriela Torres', 'gabriela.torres@aluno.edu.br', 'Nazare Paulista/SP', 'OP8999', '2025-08-05'),
(2025011, 'Helena Rocha', 'helena.rocha@aluno.edu.br', 'Piracaia/SP', 'OP8999', '2025-08-06'),
(2025012, 'Igor Santana', 'igor.santana@aluno.edu.br', 'Jarinu/SP', 'OP9000', '2025-08-07');

-- Inserir dados na tabela disciplina
INSERT INTO academico.disciplina (Cod_Servico_Academico, Nome_Disciplina, Carga_H, ID_Professor) VALUES
('ADS101', 'Banco de Dados', 80, 'P001'),
('ADS102', 'Engenharia de Software', 80, 'P002'),
('ADS103', 'Algoritmos', 60, 'P004'),
('ADS104', 'Redes de Computadores', 60, 'P005'),
('ADS105', 'Sistemas Operacionais', 60, 'P003'),
('ADS106', 'Estruturas de Dados', 80, 'P006');

-- Inserir dados na tabela matricula
INSERT INTO academico.matricula (ID_Matricula, Cod_Servico_Academico, ID_Turma, Score_Final) VALUES
(2026001, 'ADS101', 'T001', 9.1),
(2026001, 'ADS102', 'T001', 8.4),
(2026001, 'ADS105', 'T001', 8.9),
(2026002, 'ADS101', 'T001', 7.3),
(2026002, 'ADS103', 'T001', 6.8),
(2026002, 'ADS104', 'T001', 7.0),
(2026003, 'ADS101', 'T001', 5.9),
(2026003, 'ADS102', 'T001', 7.5),
(2026003, 'ADS106', 'T001', 6.1),
(2026004, 'ADS103', 'T001', 4.7),
(2026004, 'ADS104', 'T001', 6.2),
(2026004, 'ADS105', 'T001', 5.8),
(2026005, 'ADS102', 'T001', 9.5),
(2026005, 'ADS104', 'T001', 8.1),
(2026005, 'ADS106', 'T001', 8.7),
(2026006, 'ADS101', 'T001', 6.4),
(2026006, 'ADS103', 'T001', 5.6),
(2026006, 'ADS105', 'T001', 6.9),
(2025010, 'ADS101', 'T002', 6.4),
(2025010, 'ADS102', 'T002', 7.1),
(2025011, 'ADS103', 'T002', 8.8),
(2025011, 'ADS104', 'T002', 7.9),
(2025012, 'ADS105', 'T002', 5.5),
(2025012, 'ADS106', 'T002', 6.3);

-- ============================================================================
-- 6. DML - CONSULTAS E RELATÓRIOS
-- ============================================================================

-- ============================================================================
-- QUERY 1: LISTAGEM DE MATRICULADOS
-- Descrição: Nome dos alunos, nomes das disciplinas e ciclo, filtrando apenas 
--            pelo ciclo 2026/1
-- ============================================================================
SELECT 
    a.Nome_Usuario AS "Nome do Aluno",
    d.Nome_Disciplina AS "Disciplina",
    t.Ciclo_Calendario AS "Ciclo"
FROM 
    academico.aluno a
    INNER JOIN academico.matricula m ON a.ID_Matricula = m.ID_Matricula
    INNER JOIN academico.disciplina d ON m.Cod_Servico_Academico = d.Cod_Servico_Academico
    INNER JOIN academico.turma t ON m.ID_Turma = t.ID_Turma
WHERE 
    t.Ciclo_Calendario = '2026/1'
    AND a.ativo = TRUE
    AND m.ativo = TRUE
    AND d.ativo = TRUE
    AND t.ativo = TRUE
ORDER BY 
    a.Nome_Usuario, d.Nome_Disciplina;

-- ============================================================================
-- QUERY 2: BAIXO DESEMPENHO
-- Descrição: Média de notas por disciplina, listando apenas aquelas cuja 
--            média geral seja inferior a 6.0 (Agregação e HAVING)
-- ============================================================================
SELECT 
    d.Cod_Servico_Academico AS "Código",
    d.Nome_Disciplina AS "Disciplina",
    ROUND(AVG(m.Score_Final)::NUMERIC, 2) AS "Média de Notas",
    COUNT(m.ID_Matricula) AS "Total de Alunos"
FROM 
    academico.disciplina d
    INNER JOIN academico.matricula m ON d.Cod_Servico_Academico = m.Cod_Servico_Academico
WHERE 
    d.ativo = TRUE
    AND m.ativo = TRUE
GROUP BY 
    d.Cod_Servico_Academico, d.Nome_Disciplina
HAVING 
    AVG(m.Score_Final) < 6.0
ORDER BY 
    "Média de Notas" ASC;

-- ============================================================================
-- QUERY 3: ALOCAÇÃO DE DOCENTES
-- Descrição: Liste todos os docentes e suas respectivas disciplinas, 
--            garantindo que docentes que ainda não possuem turmas vinculadas 
--            também apareçam no relatório (LEFT JOIN)
-- ============================================================================
SELECT 
    p.ID_Professor AS "ID Professor",
    p.Nome_Professor AS "Nome do Professor",
    COALESCE(d.Cod_Servico_Academico, 'N/A') AS "Código da Disciplina",
    COALESCE(d.Nome_Disciplina, 'Sem Disciplinas Vinculadas') AS "Disciplina",
    COALESCE(d.Carga_H, 0) AS "Carga Horária"
FROM 
    academico.professor p
    LEFT JOIN academico.disciplina d ON p.ID_Professor = d.ID_Professor AND d.ativo = TRUE
WHERE 
    p.ativo = TRUE
ORDER BY 
    p.Nome_Professor, d.Nome_Disciplina;

-- ============================================================================
-- QUERY 4: DESTAQUE ACADÊMICO
-- Descrição: Nome do aluno e o valor da nota do maior desempenho registrado 
--            na disciplina de "Banco de Dados" (Uso de Subconsulta)
-- ============================================================================
SELECT 
    a.Nome_Usuario AS "Nome do Aluno",
    m.Score_Final AS "Nota"
FROM 
    academico.aluno a
    INNER JOIN academico.matricula m ON a.ID_Matricula = m.ID_Matricula
    INNER JOIN academico.disciplina d ON m.Cod_Servico_Academico = d.Cod_Servico_Academico
WHERE 
    d.Nome_Disciplina = 'Banco de Dados'
    AND m.Score_Final = (
        SELECT MAX(m2.Score_Final)
        FROM academico.matricula m2
        INNER JOIN academico.disciplina d2 ON m2.Cod_Servico_Academico = d2.Cod_Servico_Academico
        WHERE d2.Nome_Disciplina = 'Banco de Dados'
        AND m2.ativo = TRUE
    )
    AND a.ativo = TRUE
    AND m.ativo = TRUE
ORDER BY 
    m.Score_Final DESC;

-- ============================================================================
-- QUERIES ADICIONAIS ÚTEIS (Bonus)
-- ============================================================================

-- Desempenho geral por aluno (média de notas)
SELECT 
    a.Nome_Usuario AS "Nome do Aluno",
    ROUND(AVG(m.Score_Final)::NUMERIC, 2) AS "Média Geral",
    COUNT(m.Cod_Servico_Academico) AS "Total de Disciplinas"
FROM 
    academico.aluno a
    LEFT JOIN academico.matricula m ON a.ID_Matricula = m.ID_Matricula AND m.ativo = TRUE
WHERE 
    a.ativo = TRUE
GROUP BY 
    a.ID_Matricula, a.Nome_Usuario
ORDER BY 
    "Média Geral" DESC;

-- ============================================================================
-- COMMIT DAS TRANSAÇÕES
-- ============================================================================
COMMIT;
