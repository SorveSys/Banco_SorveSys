
DROP DATABASE IF EXISTS sorvesys_db;
CREATE DATABASE sorvesys_db;
USE sorvesys_db;

CREATE USER IF NOT EXISTS 'agente_pedagio'@'%' IDENTIFIED BY 'SenhaCaptura123!';
GRANT SELECT, INSERT ON sorvesys_db.* TO 'agente_pedagio'@'%';
FLUSH PRIVILEGES;

CREATE TABLE empresa (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome_fantasia VARCHAR(200) NOT NULL,
    cnpj CHAR(14) NOT NULL,
    razao_social VARCHAR(100) NOT NULL
);

CREATE TABLE concessionaria (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome_praca VARCHAR(150) NOT NULL,
    rodovia VARCHAR(100) NOT NULL,
    km DECIMAL(6,2) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    uf CHAR(2) NOT NULL,
    fk_empresa INT NOT NULL,
    CONSTRAINT fk_concessionaria_empresa 
        FOREIGN KEY (fk_empresa) REFERENCES empresa(id)
);

CREATE TABLE perfil (
  id INT PRIMARY KEY AUTO_INCREMENT,
  tipo VARCHAR(100) NOT NULL,
  CONSTRAINT chk_tipo_usuario CHECK (tipo IN ('Analista', 'Gestor'))
);

CREATE TABLE usuario (
  id INT PRIMARY KEY AUTO_INCREMENT,
  nome VARCHAR(200) NOT NULL,
  email VARCHAR(350) NOT NULL,
  senha VARCHAR(300) NOT NULL,
  fk_empresa INT NULL,          
  fk_concessionaria INT NULL,   
  fk_tipo_usuario INT NOT NULL,
  CONSTRAINT fk_usuario_empresa FOREIGN KEY (fk_empresa) REFERENCES empresa (id),
  CONSTRAINT fk_usuario_concessionaria FOREIGN KEY (fk_concessionaria) REFERENCES concessionaria (id),
  CONSTRAINT fk_usuario_perfil FOREIGN KEY (fk_tipo_usuario) REFERENCES perfil (id)
) AUTO_INCREMENT = 10000;

CREATE TABLE servidor (
  id INT PRIMARY KEY AUTO_INCREMENT,
  tipo VARCHAR(100) NOT NULL,
  ip VARCHAR(100),
  fk_concessionaria INT NOT NULL,
  CONSTRAINT fk_servidores_concessionaria FOREIGN KEY (fk_concessionaria) REFERENCES concessionaria (id),
  CONSTRAINT check_servidor CHECK (
    tipo IN ('transito', 'pagamento', 'auditoria')
  )
);

CREATE TABLE componente (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL
);

CREATE TABLE metrica (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo VARCHAR(100) NOT NULL,
    fk_componente INT NOT NULL,
    CONSTRAINT fk_metrica_componente
        FOREIGN KEY (fk_componente) REFERENCES componente(id)
);

CREATE TABLE config (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fk_componente INT NOT NULL,
    fk_servidor INT NOT NULL,
    CONSTRAINT fk_cfg_componente
        FOREIGN KEY (fk_componente) REFERENCES componente(id),
    CONSTRAINT fk_config_servidor
        FOREIGN KEY (fk_servidor) REFERENCES servidor(id)
);

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

CREATE TABLE chamado (
    id INT PRIMARY KEY AUTO_INCREMENT,
    chave_jira VARCHAR(20) NOT NULL UNIQUE,
    motivo VARCHAR(50) NOT NULL,
    descricao TEXT NOT NULL,
    status_chamado VARCHAR(30) NOT NULL DEFAULT 'TO DO',
    dt_abertura DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fk_usuario INT NOT NULL,
    fk_servidor INT NOT NULL,
    CONSTRAINT fk_chamado_usuario 
        FOREIGN KEY (fk_usuario) REFERENCES usuario(id),
    CONSTRAINT fk_chamado_servidor 
        FOREIGN KEY (fk_servidor) REFERENCES servidor(id),
    CONSTRAINT chk_motivo_chamado 
        CHECK (motivo IN ('Inatividade', 'Solicitar Troca', 'Solicitar Análise'))
);

INSERT INTO empresa
    (nome_fantasia, cnpj, razao_social)
VALUES
    ('AquaTech Solutions', '12345678000100', 'AquaTech Solutions LTDA'),
    ('SorveSys Monitoramento', '98765432000199', 'SorveSys Monitoramento LTDA');

INSERT INTO concessionaria (nome_praca, rodovia, km, cidade, uf, fk_empresa) 
VALUES 
    ('Praça Lapa', 'SP-280', 15.5, 'São Paulo', 'SP', 1),
    ('Praça Barueri', 'SP-280', 26.0, 'Barueri', 'SP', 1),
    ('Praça Campinas', 'SP-330', 88.0, 'Campinas', 'SP', 2);

INSERT INTO perfil (tipo)
VALUES
    ('Gestor'),
    ('Analista');

INSERT INTO usuario
    (nome, email, senha, fk_empresa, fk_concessionaria, fk_tipo_usuario)
VALUES
    ('Carlos Silva', 'carlos.silva@aquatech.com', 'hash_senha_123', 1, NULL, 1),       
    ('Ana Oliveira', 'ana.oliveira@sorvesys.com', 'hash_senha_456', NULL, 3, 2),    
    ('Lucas Martins', 'lucas.martins@aquatech.com', 'hash_senha_789', NULL, 1, 2);  

INSERT INTO servidor (tipo, ip, fk_concessionaria) VALUES
('transito', '192.168.1.10', 1),
('pagamento', '192.168.1.15', 1),
('auditoria', '10.0.0.50', 2);

INSERT INTO componente (nome) VALUES
('CPU'),
('Memoria RAM'),
('Disco Rigido'),
('Rede');

INSERT INTO metrica (tipo, fk_componente)
VALUES
    ('Temperatura (Celsius)', 1),
    ('Porcentagem de Uso (%)', 1),
    ('Uso da Memoria (%)', 2),
    ('Espaco em uso (%)', 3),
    ('Espaco disponivel (%)', 3);

INSERT INTO metrica (tipo, fk_componente)
VALUES
    ('Latencia (ms)', 4),
    ('Status Conectividade', 4),
    ('Status Rede', 4);

INSERT INTO config (fk_componente, fk_servidor)
VALUES
    (1, 1), (2, 1), (3, 1), (4, 1),
    (1, 2), (2, 2), (3, 2), (4, 2),
    (1, 3), (2, 3), (3, 3), (4, 3);

INSERT INTO registro_monitoramento
    (fk_config, fk_metrica, valor, dt_hora)
VALUES
    (1, 1, 45.50, '2026-10-23 10:00:00'),
    (1, 2, 45.50, '2026-10-23 10:00:00'),
    (2, 3, 68.00, '2026-10-23 10:00:00'),
    (3, 4, 55.00, '2026-10-23 10:00:00'),
    (3, 5, 45.00, '2026-10-23 10:00:00'),

    (5, 1, 92.00, '2026-10-23 10:01:00'),
    (5, 2, 92.00, '2026-10-23 10:01:00'),
    (6, 3, 94.00, '2026-10-23 10:01:00'),
    (7, 4, 93.00, '2026-10-23 10:01:00'),
    (7, 5, 7.00, '2026-10-23 10:01:00'),

    (9, 1, 78.00, '2026-10-23 10:02:00'),
    (9, 2, 78.00, '2026-10-23 10:02:00'),
    (10, 3, 82.00, '2026-10-23 10:02:00'),
    (11, 4, 80.00, '2026-10-23 10:02:00'),
    (11, 5, 20.00, '2026-10-23 10:02:00');

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
    
    -- tras as capturas,seus componetes, o valor e de que pedagio é
    
    SELECT 
    rm.id AS id_captura,
    c.nome AS componente,
    rm.valor,
    rm.dt_hora,
    con.nome_praca AS praca_pedagio,
    con.rodovia,
    con.km
FROM registro_monitoramento rm
JOIN config cfg ON rm.fk_config = cfg.id
JOIN componente c ON cfg.fk_componente = c.id
JOIN servidor s ON cfg.fk_servidor = s.id
JOIN concessionaria con ON s.fk_concessionaria = con.id;

 -- view pros graficos
CREATE OR REPLACE VIEW vw_historico_graficos AS
SELECT 
    s.id AS id_servidor,
    rm.dt_hora,
    DATE_FORMAT(rm.dt_hora, '%H:%i') AS horario_label,
    
    -- Pivoteamento das métricas por horário
    MAX(CASE WHEN rm.fk_metrica = 2 THEN rm.valor END) AS cpu_uso_percent,
    MAX(CASE WHEN rm.fk_metrica = 3 THEN rm.valor END) AS ram_uso_percent,
    MAX(CASE WHEN rm.fk_metrica = 6 THEN rm.valor END) AS latencia_ms,
    
    -- Limites críticos fixos para traçar a linha vermelha no gráfico
    85.00 AS limite_critico_cpu,
    20.00 AS limite_critico_latencia

FROM registro_monitoramento rm
JOIN config cfg ON rm.fk_config = cfg.id
JOIN servidor s ON cfg.fk_servidor = s.id
GROUP BY s.id, rm.dt_hora
ORDER BY rm.dt_hora ASC;


-- view para as KPI'S

CREATE OR REPLACE VIEW vw_gauges_servidor AS
SELECT 
    s.id AS id_servidor,
    s.tipo AS tipo_servidor,
    s.ip,
    con.nome_praca AS praca_pedagio,

    -- Últimos valores registrados (usando subquery para pegar sempre o registro mais recente de cada métrica)
    (SELECT rm.valor FROM registro_monitoramento rm 
     JOIN config cfg ON rm.fk_config = cfg.id 
     WHERE cfg.fk_servidor = s.id AND rm.fk_metrica = 2 
     ORDER BY rm.dt_hora DESC LIMIT 1) AS cpu_uso_atual,

    (SELECT rm.valor FROM registro_monitoramento rm 
     JOIN config cfg ON rm.fk_config = cfg.id 
     WHERE cfg.fk_servidor = s.id AND rm.fk_metrica = 1 
     ORDER BY rm.dt_hora DESC LIMIT 1) AS cpu_temp_atual,

    (SELECT rm.valor FROM registro_monitoramento rm 
     JOIN config cfg ON rm.fk_config = cfg.id 
     WHERE cfg.fk_servidor = s.id AND rm.fk_metrica = 3 
     ORDER BY rm.dt_hora DESC LIMIT 1) AS ram_uso_atual,

    (SELECT rm.valor FROM registro_monitoramento rm 
     JOIN config cfg ON rm.fk_config = cfg.id 
     WHERE cfg.fk_servidor = s.id AND rm.fk_metrica = 4 
     ORDER BY rm.dt_hora DESC LIMIT 1) AS disco_uso_atual,

    (SELECT rm.valor FROM registro_monitoramento rm 
     JOIN config cfg ON rm.fk_config = cfg.id 
     WHERE cfg.fk_servidor = s.id AND rm.fk_metrica = 5 
     ORDER BY rm.dt_hora DESC LIMIT 1) AS disco_livre_atual,

    (SELECT rm.valor FROM registro_monitoramento rm 
     JOIN config cfg ON rm.fk_config = cfg.id 
     WHERE cfg.fk_servidor = s.id AND rm.fk_metrica = 6 
     ORDER BY rm.dt_hora DESC LIMIT 1) AS latencia_atual,

    -- Médias e Picos para os rodapés dos cards
    ROUND(AVG(CASE WHEN rm.fk_metrica = 2 THEN rm.valor END), 1) AS cpu_media,
    MAX(CASE WHEN rm.fk_metrica = 2 THEN rm.valor END) AS cpu_pico,
    ROUND(AVG(CASE WHEN rm.fk_metrica = 1 THEN rm.valor END), 1) AS temp_media,
    MAX(CASE WHEN rm.fk_metrica = 1 THEN rm.valor END) AS temp_max,
    ROUND(AVG(CASE WHEN rm.fk_metrica = 6 THEN rm.valor END), 1) AS latencia_media

FROM servidor s
JOIN concessionaria con ON s.fk_concessionaria = con.id
LEFT JOIN config cfg ON cfg.fk_servidor = s.id
LEFT JOIN registro_monitoramento rm ON rm.fk_config = cfg.id
GROUP BY s.id, s.tipo, s.ip, con.nome_praca;