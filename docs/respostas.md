# Respostas da Prova de Banco de Dados

## SGBD

Um SGBD relacional como PostgreSQL é preferido ao NoSQL devido às propriedades ACID (Atomicidade, Consistência, Isolamento, Durabilidade), essenciais para transações confiáveis e integridade de dados. ACID garante operações atômicas, consistência de regras, isolamento de transações concorrentes e durabilidade contra falhas. Além disso, restrições como chaves primárias e estrangeiras asseguram integridade, prevenindo inconsistências. NoSQL, embora flexível, não oferece essas garantias nativamente, sendo inadequado para dados relacionados e críticos.

## Organização

Em Engenharia de Dados, usar schemas como `academico` e `seguranca` em vez de `public` organiza tabelas por domínio, facilitando navegação e manutenção. Permite permissões granulares por schema, controlando acesso a dados sensíveis. Simplifica backups, migrações e evita conflitos de nomes, seguindo melhores práticas para escalabilidade e governança.

## Normalização do Arquivo PLANILHA_LEGADA.csv

### Modelo Lógico

O modelo lógico detalha as tabelas, atributos, tipos de dados, chaves primárias (PK) e estrangeiras (FK), além dos relacionamentos.

#### Tabela: academico.aluno

- **ID_Matricula** (INTEGER, PK): Identificador único do aluno.
- **Nome_Usuario** (VARCHAR(255)): Nome completo do aluno.
- **Email_Usuario** (VARCHAR(255)): E-mail do aluno.
- **Endereco_Usuario** (VARCHAR(255)): Endereço do aluno.
- **Matricula_Operador_Pedagogico** (VARCHAR(50)): Matrícula do operador pedagógico responsável.
- **Data_Ingresso** (DATE): Data de ingresso do aluno.
- **Ciclo_Calendario** (VARCHAR(20)): Ciclo calendário (ex.: 2026/1).
- **ativo** (BOOLEAN, DEFAULT TRUE): Flag para soft delete.

#### Tabela: academico.disciplina

- **Cod_Servico_Academico** (VARCHAR(10), PK): Código único da disciplina.
- **Nome_Disciplina** (VARCHAR(255)): Nome da disciplina.
- **Carga_H** (INTEGER): Carga horária em horas.
- **Nome_Docente** (VARCHAR(255)): Nome do docente responsável.
- **ativo** (BOOLEAN, DEFAULT TRUE): Flag para soft delete.

#### Tabela: academico.matricula

- **ID_Matricula** (INTEGER, FK para academico.aluno.ID_Matricula): Identificador do aluno.
- **Cod_Servico_Academico** (VARCHAR(10), FK para academico.disciplina.Cod_Servico_Academico): Código da disciplina.
- **Score_Final** (DECIMAL(4,2)): Nota final do aluno na disciplina.
- **ativo** (BOOLEAN, DEFAULT TRUE): Flag para soft delete.
- **PK composta**: (ID_Matricula, Cod_Servico_Academico)

#### Relacionamentos

- **aluno** 1:N **matricula** (Um aluno pode se matricular em várias disciplinas).
- **disciplina** 1:N **matricula** (Uma disciplina pode ter várias matrículas de alunos).

O DER correspondente está disponível em `docs/der_normalizado.md` e `docs/DER.JPG`.

## Análise de Concorrência e Propriedades ACID

Em transações simultâneas para alterar a mesma nota, o **Isolamento (ACID)** impede interferências, fazendo cada transação ver o banco isoladamente (evitando leituras sujas ou fantasmas). Os **Locks** aplicam bloqueios exclusivos na linha afetada, forçando a segunda transação a aguardar o commit da primeira, garantindo consistência sem corrupção de dados.
