# Prova Prática: Sistema de Gestão Acadêmica "SigaEdu"

Este desafio simula um cenário real onde você deverá transformar dados brutos e desorganizados em um sistema de gestão acadêmica profissional, seguro e escalável.

## O Desafio

O objetivo deste projeto é projetar e implementar o núcleo de um sistema universitário. Você partirá de uma lista de dados brutos em planilha e deverá chegar a um banco de dados relacional totalmente normalizado, organizado em esquemas e funcional.

---

## Estrutura do Trabalho

### 1. Modelagem e Arquitetura (Teoria)

**Tarefa:** No arquivo `/docs/respostas.md`, responda às seguintes questões:

- **SGBD:** Justifique a escolha de um SGBD Relacional (ex: PostgreSQL) em vez de um modelo NoSQL para este cenário, focando em propriedades **ACID** e integridade de dados.
- **Organização:** Por que em um ambiente profissional de Engenharia de Dados é recomendado o uso de **Schemas** (ex: `academico`, `seguranca`) em vez de criar todas as tabelas no esquema padrão `public`?

### 2. Projeto e Normalização

**Tarefa:** Aplique as regras de **1NF, 2NF e 3NF** sobre a planilha legada disponível em [`/dados/PLANILHA_LEGADA.xlsx`](./dados/PLANILHA_LEGADA.xlsx).

**Entrega desta fase:**

- Imagem do **DER (Diagrama Entidade-Relacionamento)** na pasta `/docs`.
- Esquema do **Modelo Lógico** detalhado no arquivo `/docs/respostas.md`.

### 3. Implementação SQL (DDL, DCL e DML)

**Tarefa:** Desenvolva o script SQL criando o ambiente completo:

- **Namespaces:** Crie os schemas `academico` e `seguranca`.
- **Estrutura (DDL):** Crie as tabelas dentro dos schemas adequados, definindo **Primary Keys (PK)** e **Foreign Keys (FK)**.
- **Governança (Soft Delete):** Implemente uma lógica que impeça a perda de histórico. Em vez de permitir o `DELETE` físico de um registro, garanta que o sistema suporte uma marcação de status (ex: coluna `ativo` ou `situacao`) para desativar registros sem romper a integridade referencial.
- **Segurança (DCL):** - Criar o perfil `professor_role`: permissão de `UPDATE` apenas na coluna de notas da tabela correspondente.
  - Criar o perfil `coordenador_role`: acesso total aos schemas criados.
  - **Privacidade:** Garanta que o `professor_role` não tenha acesso à coluna de e-mail dos usuários.
- **População de Dados (DML):** Insira no banco os dados fornecidos na planilha legada [`/dados/PLANILHA_LEGADA.xlsx`](./dados/PLANILHA_LEGADA.xlsx), garantindo que a carga permita a execução de todas as queries do Item 4.

### 4. Consultas e Relatórios (DML)

**Tarefa:** Escreva queries SQL para atender às seguintes demandas:

1. **Listagem de Matriculados:** Nome dos alunos, nomes das disciplinas e ciclo, filtrando apenas pelo ciclo `2026/1`.
2. **Baixo Desempenho:** Média de notas por disciplina, listando apenas aquelas cuja média geral seja inferior a `6.0` (**Agregação e HAVING**).
3. **Alocação de Docentes:** Liste todos os docentes e suas respectivas disciplinas, garantindo que docentes que ainda não possuem turmas vinculadas também apareçam no relatório (**LEFT JOIN**).
4. **Destaque Acadêmico:** Nome do aluno e o valor da nota do maior desempenho registrado na disciplina de "Banco de Dados" (**Uso de Subconsulta**).

### 5. Transações e Concorrência

**Tarefa:** No arquivo `/docs/respostas.md`, analise o seguinte cenário: _Dois operadores da secretaria tentam alterar a nota do mesmo ID_Matricula exatamente ao mesmo tempo._

- Explique como os conceitos de **Isolamento (ACID)** e o uso de **Locks** (bloqueios) pelo SGBD garantem que o dado final seja consistente e não corrompido.

---

## ⚠️ Instruções de Entrega

1. Faça um **Fork** deste repositório para a sua conta GitHub.
1. **Método:** Faça um **Fork** deste repositório para sua conta GitHub.
1. **Organização de Pastas:**
   - **`/docs`**: Contendo a imagem do **DER** e o arquivo **`respostas.md`** (respostas teóricas (Itens 1 e 5) + Modelo Lógico).
   - **`/scripts`**: Arquivo **`.sql`** único contendo todo o código (DDL, DCL, Inserts e Queries).
1. **Finalização:** Abra um **Pull Request (PR)** do seu fork para o repositório original.
1. **Identificação Obrigatória:** O título do Pull Request **deve** seguir o padrão:
   > **Nome Completo - [Seu RA]**
1. **Link Forms:** Envie o link da sua Pull Request no link: https://forms.gle/MapD3gBWkSrgPiaL9
1. **Horário Limite:** A entrega (Push e Pull Request) deve ocorrer até o horário estipulado por mim.
1. **Penalidade Máxima:** Entregas ou modificações após o horário resultarão em **nota ZERO (0,0)**. O timestamp do GitHub é a única referência válida.
1. **Execução:** O script SQL será executado por mim. Se o script falhar ou as tabelas estiverem vazias, será descontado ponto do erro.

---

**Penalidades:**

- Código SQL com erros de sintaxe: até -2.0 pontos.
- Repositório desorganizado ou fora da estrutura solicitada: -0.5 ponto.

---

## ⚠️ Regras Cruciais de Entrega

- **Horário Limite:** A entrega deve ser realizada até o horário estipulado por mim.
- **Data de Modificação:** O GitHub registra o horário exato de cada Ação.
- **Penalidade Máxima:** Entregas ou modificações no repositório realizadas **após o horário estipulado resultarão em nota ZERO (0,0)**, sem exceções.

---

## Critérios de Avaliação (Total: 10 Pontos)

| Item                | Critério                                                            | Pontuação |
| ------------------- | ------------------------------------------------------------------- | --------- |
| **Arquitetura**     | Justificativa técnica coerente sobre SGBD e Schemas.                | 1.0       |
| **Modelagem**       | Aplicação correta das FN (1NF, 2NF, 3NF) e qualidade do DER.        | 3.0       |
| **Scripts DDL/DML** | Criação de tabelas, PK/FK, Soft Delete e população de dados.        | 1.5       |
| **Segurança**       | Implementação de Roles e restrição de privacidade por coluna (DCL). | 1.0       |
| **Consultas**       | Precisão técnica nas 4 queries DML (Joins, Agregações, Subqueries). | 2.5       |
| **Teoria**          | Explicação correta sobre Concorrência e propriedades ACID.          | 1.0       |
