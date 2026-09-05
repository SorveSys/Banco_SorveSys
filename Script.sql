CREATE DATABASE SorveSys;

USE SorveSys;

CREATE TABLE empresa (
id INT PRIMARY KEY AUTO_INCREMENT,
razao_social VARCHAR(100) NOT NULL,
nome_fantasia VARCHAR(100) NOT NULL,
cnpj CHAR(14) UNIQUE NOT NULL,
email VARCHAR(45) UNIQUE NOT NULL,
telefone VARCHAR(20) NOT NULL,
data_cadastro TIMESTAMP NOT NULL
);

CREATE TABLE metrica (
id INT PRIMARY KEY AUTO_INCREMENT,
unidade_medida VARCHAR(45) NOT NULL
);

CREATE TABLE status_monitor (
id INT PRIMARY KEY AUTO_INCREMENT,
estado VARCHAR(15) NOT NULL
);

CREATE TABLE usuario (
id INT PRIMARY KEY AUTO_INCREMENT,
nome VARCHAR(100) NOT NULL,
email VARCHAR(100) UNIQUE NOT NULL,
senha VARCHAR(200) NOT NULL,
telefone VARCHAR(20) NOT NULL,
cargo VARCHAR(45) NOT NULL,
data_cadastro TIMESTAMP NOT NULL,
status VARCHAR(15) NOT NULL,
empresa_fk INT, FOREIGN KEY (empresa_fk) REFERENCES empresa(id)
);

CREATE TABLE alerta (
id INT PRIMARY KEY AUTO_INCREMENT,
valor_limite DECIMAL(10,2) NOT NULL,
empresa_fk INT, FOREIGN KEY (empresa_fk) REFERENCES empresa(id)
);

CREATE TABLE datacenter (
id INT PRIMARY KEY AUTO_INCREMENT,
nome VARCHAR(100) NOT NULL,
coordenadas VARCHAR(45),
empresa_fk INT, FOREIGN KEY (empresa_fk) REFERENCES empresa(id)
);

CREATE TABLE tipo_componente (
id INT PRIMARY KEY AUTO_INCREMENT,
tipo VARCHAR(30) NOT NULL,
metrica_fk INT, FOREIGN KEY (metrica_fk) REFERENCES metrica(id)
);

CREATE TABLE maquina (
id INT PRIMARY KEY AUTO_INCREMENT,
hostname VARCHAR(100) NOT NULL,
mac_adress VARCHAR(30) NOT NULL,
sistema_operacional VARCHAR(10) NOT NULL,
versao_so VARCHAR(10) NOT NULL,
data_cadastro TIMESTAMP NOT NULL,
datacenter_fk INT, FOREIGN KEY (datacenter_fk) REFERENCES datacenter(id)
);

CREATE TABLE componente (
id INT PRIMARY KEY AUTO_INCREMENT,
valor_maximo DOUBLE NOT NULL,
tipo_componente_fk INT,
alerta_fk INT,
FOREIGN KEY (tipo_componente_fk) REFERENCES tipo_componente(id),
FOREIGN KEY (alerta_fk) REFERENCES alerta(id)
);

CREATE TABLE configuracao (
maquina_fk INT,
componente_fk INT,
status_monitor_fk INT,
PRIMARY KEY (maquina_fk, componente_fk, status_monitor_fk),
FOREIGN KEY (maquina_fk) REFERENCES maquina(id),
FOREIGN KEY (componente_fk) REFERENCES componente(id),
FOREIGN KEY (status_monitor_fk) REFERENCES status_monitor(id)
);

CREATE TABLE leitura (
id INT PRIMARY KEY AUTO_INCREMENT,
valor DOUBLE NOT NULL,
data_hora TIMESTAMP NOT NULL,
configuracao_maquina_fk INT,
configuracao_componente_fk INT,
configuracao_status_monitor_fk INT,
metrica_fk INT,
FOREIGN KEY (configuracao_maquina_fk, configuracao_componente_fk, configuracao_status_monitor_fk)
REFERENCES configuracao(maquina_fk, componente_fk, status_monitor_fk),
FOREIGN KEY (metrica_fk) REFERENCES metrica(id)
);

CREATE TABLE leitura_alerta (
id INT PRIMARY KEY AUTO_INCREMENT,
leitura_fk INT,
FOREIGN KEY (leitura_fk) REFERENCES leitura(id)
);

-- Mostrar todas as máquinas, suas empresas e seus datacenters.
CREATE VIEW vw_infraestrutura AS
SELECT
    e.nome_fantasia AS empresa,
    d.nome AS datacenter,
    m.id AS maquina_id,
    m.hostname,
    m.mac_adress,
    m.sistema_operacional,
    m.versao_so,
    m.data_cadastro
FROM empresa AS e
JOIN datacenter AS d
    ON d.empresa_fk = e.id
JOIN maquina AS m
    ON m.datacenter_fk = d.id;

-- Consulta do histórico de monitoramento das máquinas.
CREATE VIEW vw_historico_monitoramento AS
SELECT
    m.id AS maquina_id,
    m.hostname,
    tc.tipo AS componente,
    l.valor,
    mt.unidade_medida,
    l.data_hora
FROM leitura AS l
JOIN configuracao AS cfg
	ON cfg.maquina_fk = l.configuracao_maquina_fk
	AND cfg.componente_fk = l.configuracao_componente_fk
	AND cfg.status_monitor_fk = l.configuracao_status_monitor_fk
JOIN maquina AS m
    ON m.id = cfg.maquina_fk
JOIN componente AS c
    ON c.id = cfg.componente_fk
JOIN tipo_componente AS tc
    ON tc.id = c.tipo_componente_fk
JOIN metrica AS mt
    ON mt.id = l.metrica_fk;

-- Mostrar as leituras que geraram alertas e os limites configurados.
CREATE VIEW vw_alertas AS
SELECT
    la.id AS alerta_leitura_id,
    m.hostname,
    tc.tipo AS componente,
    l.valor,
    mt.unidade_medida,
    a.valor_limite,
    l.data_hora
FROM leitura_alerta AS la
JOIN leitura AS l
    ON l.id = la.leitura_fk
JOIN configuracao AS cfg
	ON cfg.maquina_fk = l.configuracao_maquina_fk
	AND cfg.componente_fk = l.configuracao_componente_fk
	AND cfg.status_monitor_fk = l.configuracao_status_monitor_fk
JOIN maquina AS m
    ON m.id = cfg.maquina_fk
JOIN componente AS c
    ON c.id = cfg.componente_fk
JOIN tipo_componente AS tc
    ON tc.id = c.tipo_componente_fk
JOIN metrica AS mt
    ON mt.id = l.metrica_fk
JOIN alerta AS a
    ON a.id = c.alerta_fk;

-- Mostrar a quantidade de alertas registrados para cada máquina.
CREATE VIEW vw_resumo_alertas_maquina AS
SELECT
    m.id AS maquina_id,
    m.hostname,
    COUNT(la.id) AS quantidade_alertas
FROM leitura_alerta AS la
JOIN leitura AS l
    ON l.id = la.leitura_fk
JOIN configuracao AS cfg
    ON cfg.maquina_fk = l.configuracao_maquina_fk
	AND cfg.componente_fk = l.configuracao_componente_fk
	AND cfg.status_monitor_fk = l.configuracao_status_monitor_fk
JOIN maquina AS m
    ON m.id = cfg.maquina_fk
GROUP BY
    m.id,
    m.hostname;

-- Consultar a infraestrutura cadastrada no sistema.
SELECT *
FROM vw_infraestrutura
ORDER BY empresa, datacenter, hostname;

-- Consultar o histórico completo de monitoramento.
SELECT *
FROM vw_historico_monitoramento
ORDER BY data_hora DESC;

-- Consultar todas as leituras que geraram alertas.
SELECT *
FROM vw_alertas
ORDER BY data_hora DESC;

-- Consultar o resumo de alertas por máquina.
SELECT *
FROM vw_resumo_alertas_maquina
ORDER BY quantidade_alertas DESC;

-- Mostrar quais componentes estão sendo monitorados em cada máquina e seu status.
SELECT
    m.hostname,
    tc.tipo AS componente,
    c.id AS componente_id,
    sm.estado AS status_monitor
FROM maquina AS m
JOIN configuracao AS cfg
    ON cfg.maquina_fk = m.id
JOIN componente AS c
    ON c.id = cfg.componente_fk
JOIN tipo_componente AS tc
    ON tc.id = c.tipo_componente_fk
JOIN status_monitor AS sm
    ON sm.id = cfg.status_monitor_fk
ORDER BY m.hostname, tc.tipo;

-- Mostrar a unidade de medida utilizada por cada tipo de componente.
SELECT
    tc.tipo AS componente,
    mt.unidade_medida
FROM tipo_componente AS tc
JOIN metrica AS mt
    ON mt.id = tc.metrica_fk
ORDER BY tc.tipo;

-- Consultar o histórico de leituras de uma máquina específica.
SELECT
    m.hostname,
    tc.tipo AS componente,
    l.valor,
    mt.unidade_medida,
    l.data_hora
FROM leitura AS l
JOIN configuracao AS cfg
    ON cfg.maquina_fk = l.configuracao_maquina_fk
	AND cfg.componente_fk = l.configuracao_componente_fk
	AND cfg.status_monitor_fk = l.configuracao_status_monitor_fk
JOIN maquina AS m
    ON m.id = cfg.maquina_fk
JOIN componente AS c
    ON c.id = cfg.componente_fk
JOIN tipo_componente AS tc
    ON tc.id = c.tipo_componente_fk
JOIN metrica AS mt
    ON mt.id = l.metrica_fk
WHERE m.id = 1
ORDER BY l.data_hora DESC;

-- Calcular a média dos valores registrados para cada componente de cada máquina.
SELECT
    m.hostname,
    tc.tipo AS componente,
    ROUND(AVG(l.valor), 2) AS media_valor,
    mt.unidade_medida
FROM leitura AS l
JOIN configuracao AS cfg
    ON cfg.maquina_fk = l.configuracao_maquina_fk
	AND cfg.componente_fk = l.configuracao_componente_fk
	AND cfg.status_monitor_fk = l.configuracao_status_monitor_fk
JOIN maquina AS m
    ON m.id = cfg.maquina_fk
JOIN componente AS c
    ON c.id = cfg.componente_fk
JOIN tipo_componente AS tc
    ON tc.id = c.tipo_componente_fk
JOIN metrica AS mt
    ON mt.id = l.metrica_fk
GROUP BY
    m.id,
    m.hostname,
    tc.id,
    tc.tipo,
    mt.id,
    mt.unidade_medida
ORDER BY m.hostname, tc.tipo;

-- Identificar o maior valor registrado para cada componente de cada máquina.
SELECT
    m.hostname,
    tc.tipo AS componente,
    MAX(l.valor) AS maior_valor,
    mt.unidade_medida
FROM leitura AS l
JOIN configuracao AS cfg
    ON cfg.maquina_fk = l.configuracao_maquina_fk
	AND cfg.componente_fk = l.configuracao_componente_fk
	AND cfg.status_monitor_fk = l.configuracao_status_monitor_fk
JOIN maquina AS m
    ON m.id = cfg.maquina_fk
JOIN componente AS c
    ON c.id = cfg.componente_fk
JOIN tipo_componente AS tc
    ON tc.id = c.tipo_componente_fk
JOIN metrica AS mt
    ON mt.id = l.metrica_fk
GROUP BY
    m.id,
    m.hostname,
    tc.id,
    tc.tipo,
    mt.id,
    mt.unidade_medida
ORDER BY maior_valor DESC;

-- Identificar quais tipos de componentes geram mais alertas.
SELECT
    tc.tipo AS componente,
    COUNT(la.id) AS quantidade_alertas
FROM leitura_alerta AS la
JOIN leitura AS l
    ON l.id = la.leitura_fk
JOIN configuracao AS cfg
    ON cfg.maquina_fk = l.configuracao_maquina_fk
	AND cfg.componente_fk = l.configuracao_componente_fk
	AND cfg.status_monitor_fk = l.configuracao_status_monitor_fk
JOIN componente AS c
    ON c.id = cfg.componente_fk
JOIN tipo_componente AS tc
    ON tc.id = c.tipo_componente_fk
GROUP BY
    tc.id,
    tc.tipo
ORDER BY quantidade_alertas DESC;

-- Contabilizar a quantidade de alertas registrados para cada empresa.
SELECT
    e.nome_fantasia AS empresa,
    COUNT(la.id) AS quantidade_alertas
FROM leitura_alerta AS la
JOIN leitura AS l
    ON l.id = la.leitura_fk
JOIN configuracao AS cfg
    ON cfg.maquina_fk = l.configuracao_maquina_fk
	AND cfg.componente_fk = l.configuracao_componente_fk
	AND cfg.status_monitor_fk = l.configuracao_status_monitor_fk
JOIN maquina AS m
    ON m.id = cfg.maquina_fk
JOIN datacenter AS d
    ON d.id = m.datacenter_fk
JOIN empresa AS e
    ON e.id = d.empresa_fk
GROUP BY
    e.id,
    e.nome_fantasia
ORDER BY quantidade_alertas DESC;