DROP DATABASE IF EXISTS sorvesys;
CREATE DATABASE IF NOT EXISTS sorvesys;
USE sorvesys;

-- TABELA EMPRESA
CREATE TABLE empresa (
  id INT PRIMARY KEY AUTO_INCREMENT,
  nome_fantasia VARCHAR(200) NOT NULL,
  cnpj CHAR(14) NOT NULL,
  razao_social VARCHAR(100)
);

-- TABELA TIPO DE PERFIL (CARGO)
CREATE TABLE perfil (
  id INT PRIMARY KEY AUTO_INCREMENT,
  tipo VARCHAR(100) NOT NULL,
  CONSTRAINT chk_tipo_usuario CHECK (tipo IN ('Analista', 'Gestor'))
);

-- TABELA USUARIO
CREATE TABLE usuario (
  id INT PRIMARY KEY AUTO_INCREMENT,
  nome VARCHAR(200) NOT NULL,
  email VARCHAR(350) NOT NULL,
  senha VARCHAR(300) NOT NULL,
  fk_empresa INT NOT NULL,
  fk_tipo_usuario INT NOT NULL,
  CONSTRAINT fk_usuario_empresa FOREIGN KEY (fk_empresa) REFERENCES empresa (id),
  CONSTRAINT fk_usuario_perfil FOREIGN KEY (fk_tipo_usuario) REFERENCES perfil (id)
) AUTO_INCREMENT = 10000;

-- TABELA SERVIDORES
CREATE TABLE servidor (
  id INT PRIMARY KEY AUTO_INCREMENT,
  tipo VARCHAR(100) NOT NULL,
  ip VARCHAR(100),
  fk_empresa INT NOT NULL,
  CONSTRAINT fk_servidores_empresa FOREIGN KEY (fk_empresa) REFERENCES empresa (id),
  CONSTRAINT check_servidor CHECK (
    tipo IN ('transito', 'pagamento', 'auditoria')
  )
);

-- TABELA TIPO DE COMPONENTE
CREATE TABLE componente (
  id INT PRIMARY KEY AUTO_INCREMENT,
  nome VARCHAR(100) NOT NULL
);

-- TABELA METRICAS
CREATE TABLE metrica (
  id INT PRIMARY KEY AUTO_INCREMENT,
  tipo VARCHAR(100) NOT NULL,
  fk_componente INT NOT NULL,
  CONSTRAINT fk_metrica_componente FOREIGN KEY (fk_componente) REFERENCES componente (id)
);

-- TABELA ASSOCIATIVA - CONFIG
CREATE TABLE config (
  id INT PRIMARY KEY AUTO_INCREMENT,
  fk_componente INT NOT NULL,
  fk_servidor INT NOT NULL,
  CONSTRAINT fk_cfg_componente FOREIGN KEY (fk_componente) REFERENCES componente (id),
  CONSTRAINT fk_config_servidor FOREIGN KEY (fk_servidor) REFERENCES servidor (id)
);

-- TABELA REGISTRO - MONITORAMENTO
CREATE TABLE registro_monitoramento (
  id INT PRIMARY KEY AUTO_INCREMENT,
  fk_config INT NOT NULL,
  fk_metrica INT NOT NULL,
  valor DECIMAL(5, 2) NOT NULL,
  dt_hora DATETIME NOT NULL,
  CONSTRAINT fk_registro_config FOREIGN KEY (fk_config) REFERENCES config (id),
  CONSTRAINT fk_registro_metrica FOREIGN KEY (fk_metrica) REFERENCES metrica (id)
);

-- TABELA ALERTA
CREATE TABLE alerta (
  id INT PRIMARY KEY AUTO_INCREMENT,
  categoria VARCHAR(15) NOT NULL,
  descricao VARCHAR(300) NOT NULL,
  chk_registro INT NOT NULL,
  fk_config INT NOT NULL,
  CONSTRAINT fk_alerta_config FOREIGN KEY (fk_config) REFERENCES config (id),
  CONSTRAINT chk_categoria_alerta CHECK (
    categoria IN ('Normal', 'Moderado', 'Critico')
  )
);

-- INSERTS: TABELA EMPRESA
INSERT INTO empresa (nome_fantasia, cnpj) VALUES
('AquaTech Solutions', '12345678000100'),
('SorveSys Monitoramento', '98765432000199');

-- INSERTS: TABELA TIPO DE PERFIL
INSERT INTO perfil (tipo) VALUES
('Gestor'),
('Analista');

-- INSERTS: TABELA USUARIO
INSERT INTO usuario (nome, email, senha, fk_empresa, fk_tipo_usuario) VALUES
('Carlos Silva', 'carlos.silva@aquatech.com', 'hash_senha_123', 1, 1),
('Ana Oliveira', 'ana.oliveira@sorvesys.com', 'hash_senha_456', 2, 2),
('Lucas Martins', 'lucas.martins@aquatech.com', 'hash_senha_789', 1, 2);

-- TABELA SERVIDORES
INSERT INTO servidor (tipo, ip, fk_empresa) VALUES
('transito', '192.168.1.10', 1),
('pagamento', '192.168.1.15', 1),
('auditoria', '10.0.0.50', 2);

-- TABELA TIPO DE COMPONENTE
INSERT INTO componente (nome) VALUES
('CPU'),
('Memoria RAM'),
('Disco Rigido'),
('Rede');

-- INSERTS: TABELA METRICAS
INSERT INTO metrica (tipo, fk_componente) VALUES
('Porcentagem de Uso (%)', 1),
('Frequencia (GHz)', 1),
('Consumo de Memoria (GB)', 2),
('Espaco Disponivel (GB)', 3),
('Latência (MS)', 4),
('Status Conectividade (0/1)', 4),
('Status Rede (1/0)', 4);

-- INSERTS: TABELA ASSOCIATIVA - CONFIG
INSERT INTO config (fk_componente, fk_servidor) VALUES
(1, 1), (2, 1), (3, 1), (4, 1), -- Trânsito
(1, 2), (2, 2), (3, 2), (4, 2), -- Pagamento
(1, 3), (2, 3), (3, 3), (4, 3); -- Auditoria

-- INSERTS: TABELA ALERTAS
INSERT INTO alerta (categoria, descricao, chk_registro, fk_config) VALUES
('Normal', 'Uso de CPU do servidor de transito dentro do esperado.', 1, 1),
('Normal', 'Consumo de RAM estavel.', 2, 2),
('Critico', 'Alerta: Uso de CPU do servidor de pagamento atingiu nivel critico (95%).', 3, 5);

-- CONSULTAS
SELECT * FROM registro_monitoramento;
SELECT * FROM componente;

-- Vem o nome do componente, o tipo do servidor e o valor dele 
SELECT 
    rm.id AS id_registro,
    c.nome AS nome_componente,
    s.tipo AS tipo_servidor,
    rm.valor
FROM registro_monitoramento rm
JOIN config cfg ON rm.fk_config = cfg.id
JOIN componente c ON cfg.fk_componente = c.id
JOIN servidor s ON cfg.fk_servidor = s.id;


-- vem o servidor, nome do componente, a metrica e o valor
SELECT 
    s.tipo AS tipo_servidor,
    c.nome AS nome_componente,
    m.tipo AS tipo_metrica,
    rm.valor AS valor_registrado
FROM registro_monitoramento rm
JOIN config cfg ON rm.fk_config = cfg.id
JOIN componente c ON cfg.fk_componente = c.id
JOIN servidor s ON cfg.fk_servidor = s.id
JOIN metrica m ON rm.fk_metrica = m.id;

-- vem o servidor, o IP , Componente e latência
SELECT 
    r.id AS id_registro,
    s.tipo AS servidor_tipo,
    s.ip AS servidor_ip,
    c.nome AS componente,
    r.valor AS latencia_ms
FROM registro_monitoramento r
JOIN config cfg ON r.fk_config = cfg.id
JOIN servidor s ON cfg.fk_servidor = s.id
JOIN componente c ON cfg.fk_componente = c.id
WHERE c.nome = 'Rede';