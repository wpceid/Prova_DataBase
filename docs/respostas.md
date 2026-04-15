# Respostas da Prova de Banco de Dados

## SGBD

Um SGBD relacional como PostgreSQL é preferido ao NoSQL devido às propriedades ACID (Atomicidade, Consistência, Isolamento, Durabilidade), essenciais para transações confiáveis e integridade de dados. ACID garante operações atômicas, consistência de regras, isolamento de transações concorrentes e durabilidade contra falhas. Além disso, restrições como chaves primárias e estrangeiras asseguram integridade, prevenindo inconsistências. NoSQL, embora flexível, não oferece essas garantias nativamente, sendo inadequado para dados relacionados e críticos.

## Organização

Em Engenharia de Dados, usar schemas como `academico` e `seguranca` em vez de `public` organiza tabelas por domínio, facilitando navegação e manutenção. Permite permissões granulares por schema, controlando acesso a dados sensíveis. Simplifica backups, migrações e evita conflitos de nomes, seguindo melhores práticas para escalabilidade e governança.
