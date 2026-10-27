# SCRIPT SQL — SORVESYS

-- ATENÇÃO: este script apaga e recria o banco.
DROP DATABASE IF EXISTS sorvesys_db;
CREATE DATABASE sorvesys_db;
USE sorvesys_db;

-- =========================================
-- 1. TABELA EMPRESA
-- =========================================
CREATE TABLE empresa (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome_fantasia VARCHAR(200) NOT NULL,
    cnpj CHAR(14) NOT NULL,
    razao_social VARCHAR(100) NOT NULL
);

-- =========================================
-- 2. TABELA PERFIL
-- =========================================
CREATE TABLE perfil (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo VARCHAR(100) NOT NULL,
    CONSTRAINT chk_tipo_usuario
        CHECK (tipo IN ('Analista', 'Gestor'))
);

-- =========================================
-- 3. TABELA USUARIO
-- =========================================
CREATE TABLE usuario (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(200) NOT NULL,
    email VARCHAR(350) NOT NULL,
    senha VARCHAR(300) NOT NULL,
    fk_empresa INT NOT NULL,
    fk_tipo_usuario INT NOT NULL,
    CONSTRAINT fk_usuario_empresa
        FOREIGN KEY (fk_empresa) REFERENCES empresa(id),
    CONSTRAINT fk_usuario_perfil
        FOREIGN KEY (fk_tipo_usuario) REFERENCES perfil(id)
) AUTO_INCREMENT = 10000;

-- =========================================
-- 4. TABELA SERVIDOR
-- =========================================
CREATE TABLE servidor (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo VARCHAR(100) NOT NULL,
    ip VARCHAR(100),
    fk_empresa INT NOT NULL,
    CONSTRAINT fk_servidores_empresa
        FOREIGN KEY (fk_empresa) REFERENCES empresa(id),
    CONSTRAINT check_servidor
        CHECK (tipo IN ('transito', 'pagamento', 'auditoria'))
);

-- =========================================
-- 5. TABELA COMPONENTE
-- =========================================
CREATE TABLE componente (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL
);

-- =========================================
-- 6. TABELA METRICA
-- =========================================
CREATE TABLE metrica (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo VARCHAR(100) NOT NULL,
    fk_componente INT NOT NULL,
    CONSTRAINT fk_metrica_componente
        FOREIGN KEY (fk_componente) REFERENCES componente(id)
);

-- =========================================
-- 7. TABELA CONFIG
-- =========================================
CREATE TABLE config (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fk_componente INT NOT NULL,
    fk_servidor INT NOT NULL,
    CONSTRAINT fk_cfg_componente
        FOREIGN KEY (fk_componente) REFERENCES componente(id),
    CONSTRAINT fk_config_servidor
        FOREIGN KEY (fk_servidor) REFERENCES servidor(id)
);

-- =========================================
-- 8. TABELA REGISTRO DE MONITORAMENTO
-- =========================================
CREATE TABLE registro_monitoramento (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fk_config INT NOT NULL,
    fk_metrica INT NOT NULL,
    valor DECIMAL(5, 2),
    dt_hora DATETIME NOT NULL,
    CONSTRAINT fk_registro_config
        FOREIGN KEY (fk_config) REFERENCES config(id),
    CONSTRAINT fk_registro_metrica
        FOREIGN KEY (fk_metrica) REFERENCES metrica(id)
);

-- =========================================
-- 9. TABELA ALERTA
-- =========================================
CREATE TABLE alerta (
    id INT PRIMARY KEY AUTO_INCREMENT,
    categoria VARCHAR(15) NOT NULL,
    descricao VARCHAR(300) NOT NULL,
    fk_registro INT NOT NULL,
    CONSTRAINT fk_alerta_registro
        FOREIGN KEY (fk_registro)
        REFERENCES registro_monitoramento(id),
    CONSTRAINT chk_categoria_alerta
        CHECK (categoria IN ('Normal', 'Moderado', 'Critico'))
);

-- =========================================
-- INSERTS: EMPRESA
-- =========================================
INSERT INTO empresa
    (nome_fantasia, cnpj, razao_social)
VALUES
    ('AquaTech Solutions', '12345678000100',
     'AquaTech Solutions LTDA'),
    ('SorveSys Monitoramento', '98765432000199',
     'SorveSys Monitoramento LTDA');

-- =========================================
-- INSERTS: PERFIL
-- =========================================
INSERT INTO perfil (tipo)
VALUES
    ('Gestor'),
    ('Analista');

-- =========================================
-- INSERTS: USUARIO
-- =========================================
INSERT INTO usuario
    (nome, email, senha, fk_empresa, fk_tipo_usuario)
VALUES
    ('Carlos Silva', 'carlos.silva@aquatech.com',
     'hash_senha_123', 1, 1),
    ('Ana Oliveira', 'ana.oliveira@sorvesys.com',
     'hash_senha_456', 2, 2),
    ('Lucas Martins', 'lucas.martins@aquatech.com',
     'hash_senha_789', 1, 2);

-- =========================================
-- INSERTS: SERVIDORES
-- =========================================
INSERT INTO servidor (tipo, ip, fk_empresa)
VALUES
    ('transito', '192.168.1.10', 1),
    ('pagamento', '192.168.1.15', 1),
    ('auditoria', '10.0.0.50', 2);

-- =========================================
-- INSERTS: COMPONENTES
-- =========================================
INSERT INTO componente (nome)
VALUES
    ('CPU'),
    ('Memoria RAM'),
    ('Disco Rigido'),
    ('Rede');

-- =========================================
-- INSERTS: METRICAS
-- IMPORTANTE: cadastradas antes dos registros.
-- Os nomes devem ser iguais aos usados no Python.
-- =========================================
INSERT INTO metrica (tipo, fk_componente)
VALUES
    ('Temperatura (Celsius)', 1),
    ('Porcentagem de Uso (%)', 1),
    ('Uso da Memoria (%)', 2),
    ('Espaco em uso (%)', 3),
    ('Espaco disponivel (%)', 3);

-- =========================================
-- INSERTS: CONFIG
-- Cada servidor terá uma configuração por componente.
-- =========================================
INSERT INTO config (fk_componente, fk_servidor)
VALUES
    (1, 1), (2, 1), (3, 1), (4, 1),
    (1, 2), (2, 2), (3, 2), (4, 2),
    (1, 3), (2, 3), (3, 3), (4, 3);

-- =========================================
-- INSERTS: REGISTROS DE MONITORAMENTO
--
-- IDs de configuração neste banco recém-criado:
-- Trânsito: 1 = CPU, 2 = RAM, 3 = disco
-- Pagamento: 5 = CPU, 6 = RAM, 7 = disco
-- Auditoria: 9 = CPU, 10 = RAM, 11 = disco
--
-- IDs das métricas:
-- 1 = Temperatura (Celsius)
-- 2 = Porcentagem de Uso (%)
-- 3 = Uso da Memoria (%)
-- 4 = Espaco em uso (%)
-- 5 = Espaco disponivel (%)
-- =========================================
INSERT INTO registro_monitoramento
    (fk_config, fk_metrica, valor, dt_hora)
VALUES
    -- Servidor de trânsito
    (1, 1, 45.50, '2026-10-23 10:00:00'),
    (1, 2, 45.50, '2026-10-23 10:00:00'),
    (2, 3, 68.00, '2026-10-23 10:00:00'),
    (3, 4, 55.00, '2026-10-23 10:00:00'),
    (3, 5, 45.00, '2026-10-23 10:00:00'),

    -- Servidor de pagamento
    (5, 1, 92.00, '2026-10-23 10:01:00'),
    (5, 2, 92.00, '2026-10-23 10:01:00'),
    (6, 3, 94.00, '2026-10-23 10:01:00'),
    (7, 4, 93.00, '2026-10-23 10:01:00'),
    (7, 5, 7.00, '2026-10-23 10:01:00'),

    -- Servidor de auditoria
    (9, 1, 78.00, '2026-10-23 10:02:00'),
    (9, 2, 78.00, '2026-10-23 10:02:00'),
    (10, 3, 82.00, '2026-10-23 10:02:00'),
    (11, 4, 80.00, '2026-10-23 10:02:00'),
    (11, 5, 20.00, '2026-10-23 10:02:00');

-- =========================================
-- INSERTS: ALERTAS DE EXEMPLO
--
-- Os IDs abaixo correspondem aos registros acima,
-- neste banco recém-criado.
-- =========================================
INSERT INTO alerta (categoria, descricao, fk_registro)
VALUES
    ('Critico', 'Alerta: Temperatura da CPU Critico', 6),
    ('Critico', 'Alerta: Uso da CPU Critico', 7),
    ('Critico', 'Alerta: Uso da Memoria RAM Critico', 8),
    ('Critico', 'Alerta: Uso do Disco Critico', 9),
    ('Critico', 'Alerta: Espaco livre do Disco Critico', 10),

    ('Moderado', 'Alerta: Temperatura da CPU Moderado', 11),
    ('Moderado', 'Alerta: Uso da CPU Moderado', 12),
    ('Moderado', 'Alerta: Uso da Memoria RAM Moderado', 13),
    ('Moderado', 'Alerta: Uso do Disco Moderado', 14),
    ('Moderado', 'Alerta: Espaco livre do Disco Moderado', 15);

-- =========================================
-- CONSULTAS PARA CONFERIR O BANCO
-- =========================================

-- Conferir componentes e métricas
SELECT
    c.nome AS componente,
    m.id AS id_metrica,
    m.tipo AS metrica
FROM componente AS c
LEFT JOIN metrica AS m
    ON m.fk_componente = c.id
ORDER BY c.id, m.id;

-- Conferir configurações dos servidores
SELECT
    cfg.id AS id_config,
    s.tipo AS servidor,
    s.ip,
    c.nome AS componente
FROM config AS cfg
JOIN servidor AS s
    ON s.id = cfg.fk_servidor
JOIN componente AS c
    ON c.id = cfg.fk_componente
ORDER BY cfg.id;

-- Conferir todos os registros e suas métricas
SELECT
    r.id AS id_registro,
    s.tipo AS servidor,
    c.nome AS componente,
    m.tipo AS metrica,
    r.valor,
    r.dt_hora
FROM registro_monitoramento AS r
JOIN config AS cfg
    ON cfg.id = r.fk_config
JOIN servidor AS s
    ON s.id = cfg.fk_servidor
JOIN componente AS c
    ON c.id = cfg.fk_componente
JOIN metrica AS m
    ON m.id = r.fk_metrica
ORDER BY r.id;

-- Conferir alertas e valores que os provocaram
SELECT
    a.id AS id_alerta,
    a.categoria,
    a.descricao,
    r.valor,
    m.tipo AS metrica,
    r.dt_hora
FROM alerta AS a
JOIN registro_monitoramento AS r
    ON r.id = a.fk_registro
JOIN metrica AS m
    ON m.id = r.fk_metrica
ORDER BY a.id DESC;

-- Conferir a quantidade de registros e alertas
SELECT COUNT(*) AS total_registros
FROM registro_monitoramento;

SELECT COUNT(*) AS total_alertas
FROM alerta;
