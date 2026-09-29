DROP DATABASE IF EXISTS sorvesys;
CREATE DATABASE sorvesys;
USE sorvesys;

CREATE TABLE empresa (
    id INT AUTO_INCREMENT PRIMARY KEY,
    razao_social VARCHAR(100) NOT NULL,
    nome_fantasia VARCHAR(100),
    cnpj CHAR(14) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL,
    telefone VARCHAR(20),
    data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE usuario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    senha VARCHAR(200) NOT NULL,
    telefone VARCHAR(20),
    cargo VARCHAR(45),
    data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(15) DEFAULT 'ATIVO',
    empresa_fk INT NOT NULL,

    CONSTRAINT fk_usuario_empresa
        FOREIGN KEY (empresa_fk) REFERENCES empresa(id)
);

CREATE TABLE metrica (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    unidade_medida VARCHAR(45) NOT NULL
);

CREATE TABLE tipo_componente (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tipo VARCHAR(30) NOT NULL
);

CREATE TABLE componente (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tipo_componente_fk INT NOT NULL,

    CONSTRAINT fk_componente_tipo
        FOREIGN KEY (tipo_componente_fk)
        REFERENCES tipo_componente(id)
);

CREATE TABLE componente_metrica (
    id INT AUTO_INCREMENT PRIMARY KEY,
    componente_fk INT NOT NULL,
    metrica_fk INT NOT NULL,

    CONSTRAINT fk_componente_metrica_componente
        FOREIGN KEY (componente_fk) REFERENCES componente(id),

    CONSTRAINT fk_componente_metrica_metrica
        FOREIGN KEY (metrica_fk) REFERENCES metrica(id),

    CONSTRAINT uk_componente_metrica
        UNIQUE (componente_fk, metrica_fk)
);

CREATE TABLE datacenter (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    coordenadas VARCHAR(45),
    empresa_fk INT NOT NULL,

    CONSTRAINT fk_datacenter_empresa
        FOREIGN KEY (empresa_fk) REFERENCES empresa(id)
);

-- TABELA MAQUINA
CREATE TABLE maquina (
    id INT AUTO_INCREMENT PRIMARY KEY,
    hostname VARCHAR(100) NOT NULL,
    mac_address VARCHAR(30) NOT NULL UNIQUE,
    sistema_operacional VARCHAR(45),
    versao_so VARCHAR(45),
    data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
    datacenter_fk INT NOT NULL,

    CONSTRAINT fk_maquina_datacenter
        FOREIGN KEY (datacenter_fk) REFERENCES datacenter(id)
);

CREATE TABLE status_monitor (
    id INT AUTO_INCREMENT PRIMARY KEY,
    estado VARCHAR(15) NOT NULL
);

CREATE TABLE configuracao (
    id INT AUTO_INCREMENT PRIMARY KEY,
    maquina_fk INT NOT NULL,
    componente_fk INT NOT NULL,
    status_monitor_fk INT NOT NULL,

    CONSTRAINT fk_config_maquina
        FOREIGN KEY (maquina_fk) REFERENCES maquina(id),

    CONSTRAINT fk_config_componente
        FOREIGN KEY (componente_fk) REFERENCES componente(id),

    CONSTRAINT fk_config_status
        FOREIGN KEY (status_monitor_fk) REFERENCES status_monitor(id),

    CONSTRAINT uk_maquina_componente
        UNIQUE (maquina_fk, componente_fk)
);

-- TABELA ALERTA
CREATE TABLE alerta (
    id INT AUTO_INCREMENT PRIMARY KEY,
    valor_limite DECIMAL(10,2) NOT NULL,
    empresa_fk INT NOT NULL,
    componente_metrica_fk INT NOT NULL,

    CONSTRAINT fk_alerta_empresa
        FOREIGN KEY (empresa_fk) REFERENCES empresa(id),

    CONSTRAINT fk_alerta_componente_metrica
        FOREIGN KEY (componente_metrica_fk)
        REFERENCES componente_metrica(id),

    CONSTRAINT uk_alerta_componente_metrica
        UNIQUE (componente_metrica_fk)
);

CREATE TABLE leitura (
    id INT AUTO_INCREMENT PRIMARY KEY,
    valor DECIMAL(10,2) NOT NULL,
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    configuracao_fk INT NOT NULL,
    componente_metrica_fk INT NOT NULL,

    CONSTRAINT fk_leitura_configuracao
        FOREIGN KEY (configuracao_fk) REFERENCES configuracao(id),

    CONSTRAINT fk_leitura_componente_metrica
        FOREIGN KEY (componente_metrica_fk)
        REFERENCES componente_metrica(id)
);

CREATE TABLE leitura_alerta (
    id INT AUTO_INCREMENT PRIMARY KEY,
    leitura_fk INT NOT NULL,
    alerta_fk INT NOT NULL,
    data_ocorrencia DATETIME DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_alerta_leitura
        FOREIGN KEY (leitura_fk) REFERENCES leitura(id),

    CONSTRAINT fk_leitura_alerta_alerta
        FOREIGN KEY (alerta_fk) REFERENCES alerta(id)
);



INSERT INTO empresa
    (razao_social, nome_fantasia, cnpj, email)
VALUES
    ('Empresa Teste LTDA', 'SorveSys',
     '12345678000199', 'teste@sorvesys.com');

INSERT INTO datacenter
    (nome, empresa_fk)
VALUES
    ('Datacenter SP', 1);

INSERT INTO maquina
    (hostname, mac_address, sistema_operacional,
     versao_so, datacenter_fk)
VALUES
    ('maquina-01', '00:11:22:33:44:55',
     'Linux', 'Ubuntu 22.04', 1);

INSERT INTO status_monitor (estado)
VALUES ('ATIVO');

INSERT INTO metrica (nome, unidade_medida)
VALUES
    ('Porcentagem', '%'),
    ('Velocidade', 'Mbps'),
    ('Latencia', 'ms'),
    ('Tempo CPU', 's'),
    ('CPUs lógicas', 'núcleos'),
    ('RAM Total', 'GB'),
    ('RAM Disponível', 'GB'),
    ('RAM Usada', 'GB'),
    ('RAM Livre', 'GB'),
    ('Uso da RAM', '%'),
    ('Disco Total', 'GB'),
    ('Disco Usado', 'GB'),
    ('Disco Livre', 'GB'),
    ('Uso do Disco', '%');

INSERT INTO tipo_componente (tipo)
VALUES
    ('CPU'),
    ('Rede'),
    ('Memória'),
    ('Disco');

INSERT INTO componente (tipo_componente_fk)
SELECT id
FROM tipo_componente
WHERE tipo = 'CPU';

INSERT INTO componente (tipo_componente_fk)
SELECT id
FROM tipo_componente
WHERE tipo = 'Rede';

INSERT INTO componente (tipo_componente_fk)
SELECT id
FROM tipo_componente
WHERE tipo = 'Memória';

INSERT INTO componente (tipo_componente_fk)
SELECT id
FROM tipo_componente
WHERE tipo = 'Disco';

INSERT INTO componente_metrica (componente_fk, metrica_fk)
SELECT c.id, m.id
FROM componente c
JOIN tipo_componente t
    ON t.id = c.tipo_componente_fk
JOIN metrica m
    ON m.nome IN ('Porcentagem', 'Tempo CPU', 'CPUs lógicas')
WHERE t.tipo = 'CPU';

INSERT INTO componente_metrica (componente_fk, metrica_fk)
SELECT c.id, m.id
FROM componente c
JOIN tipo_componente t
    ON t.id = c.tipo_componente_fk
JOIN metrica m
    ON m.nome IN ('Velocidade', 'Latencia')
WHERE t.tipo = 'Rede';

INSERT INTO componente_metrica (componente_fk, metrica_fk)
SELECT c.id, m.id
FROM componente c
JOIN tipo_componente t
    ON t.id = c.tipo_componente_fk
JOIN metrica m
    ON m.nome IN (
        'RAM Total',
        'RAM Disponível',
        'RAM Usada',
        'RAM Livre',
        'Uso da RAM'
    )
WHERE t.tipo = 'Memória';

INSERT INTO componente_metrica (componente_fk, metrica_fk)
SELECT c.id, m.id
FROM componente c
JOIN tipo_componente t
    ON t.id = c.tipo_componente_fk
JOIN metrica m
    ON m.nome IN (
        'Disco Total',
        'Disco Usado',
        'Disco Livre',
        'Uso do Disco'
    )
WHERE t.tipo = 'Disco';


INSERT INTO configuracao
    (maquina_fk, componente_fk, status_monitor_fk)
SELECT maq.id, c.id, sm.id FROM maquina maq
CROSS JOIN componente c
JOIN status_monitor sm
    ON sm.estado = 'ATIVO'
JOIN tipo_componente t
    ON t.id = c.tipo_componente_fk
WHERE maq.hostname = 'maquina-01'
  AND t.tipo IN ('CPU', 'Rede', 'Memória', 'Disco');

INSERT INTO alerta
    (valor_limite, empresa_fk, componente_metrica_fk)
SELECT 90.00, e.id,cm.id FROM empresa e
JOIN componente_metrica cm
    ON cm.metrica_fk = (SELECT id FROM metrica WHERE nome = 'Porcentagem')
JOIN componente c
    ON c.id = cm.componente_fk
JOIN tipo_componente t
    ON t.id = c.tipo_componente_fk
WHERE e.nome_fantasia = 'SorveSys'
  AND t.tipo = 'CPU';

INSERT INTO alerta (valor_limite, empresa_fk, componente_metrica_fk)
SELECT 1000.00, e.id, cm.id
FROM empresa e
JOIN componente_metrica cm
    ON cm.metrica_fk = (SELECT id FROM metrica WHERE nome = 'Velocidade')
JOIN componente c
    ON c.id = cm.componente_fk
JOIN tipo_componente t
    ON t.id = c.tipo_componente_fk
WHERE e.nome_fantasia = 'SorveSys'
  AND t.tipo = 'Rede';

INSERT INTO alerta
    (valor_limite, empresa_fk, componente_metrica_fk)
SELECT
    100.00,
    e.id,
    cm.id
FROM empresa e
JOIN componente_metrica cm
    ON cm.metrica_fk = (SELECT id FROM metrica WHERE nome = 'Latencia')
JOIN componente c
    ON c.id = cm.componente_fk
JOIN tipo_componente t
    ON t.id = c.tipo_componente_fk
WHERE e.nome_fantasia = 'SorveSys'
  AND t.tipo = 'Rede';

INSERT INTO alerta (valor_limite, empresa_fk, componente_metrica_fk)
SELECT 90.00, e.id, cm.id FROM empresa e
JOIN componente_metrica cm
    ON cm.metrica_fk = (
        SELECT id FROM metrica WHERE nome = 'Uso da RAM'
    )
JOIN componente c
    ON c.id = cm.componente_fk
JOIN tipo_componente t
    ON t.id = c.tipo_componente_fk
WHERE e.nome_fantasia = 'SorveSys'
  AND t.tipo = 'Memória';

INSERT INTO alerta (valor_limite, empresa_fk, componente_metrica_fk)
SELECT 90.00, e.id, cm.id FROM empresa e
JOIN componente_metrica cm
    ON cm.metrica_fk = (SELECT id FROM metrica WHERE nome = 'Uso do Disco')
JOIN componente c
    ON c.id = cm.componente_fk
JOIN tipo_componente t
    ON t.id = c.tipo_componente_fk
WHERE e.nome_fantasia = 'SorveSys'
  AND t.tipo = 'Disco';
  
  
  
-- VIEW Pra gente usar o csv no R
CREATE VIEW vw_leituras_csv AS
SELECT
    l.id AS leitura_id,
    m.nome AS metrica,
    tc.tipo AS componente,
    l.valor,
    m.unidade_medida,
    l.data_hora,
    maq.hostname
FROM leitura l
JOIN componente_metrica cm
    ON l.componente_metrica_fk = cm.id
JOIN metrica m
    ON cm.metrica_fk = m.id
JOIN componente c
    ON cm.componente_fk = c.id
JOIN tipo_componente tc
    ON c.tipo_componente_fk = tc.id
JOIN configuracao cfg
    ON l.configuracao_fk = cfg.id
JOIN maquina maq
    ON cfg.maquina_fk = maq.id;


SELECT * FROM vw_leituras_csv;
