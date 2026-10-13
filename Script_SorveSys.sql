CREATE DATABASE IF NOT EXISTS sorvesys;
USE sorvesys;

-- TABELA EMPRESA
CREATE TABLE IF NOT EXISTS empresa (
id INT PRIMARY KEY AUTO_INCREMENT,
nome_fantasia VARCHAR(200) NOT NULL,
cnpj CHAR(14) NOT NULL
);

-- TABELA TIPO DE PERFIL (CARGO)
CREATE TABLE IF NOT EXISTS perfil (
id INT PRIMARY KEY AUTO_INCREMENT,
tipo VARCHAR(100) NOT NULL,
CONSTRAINT chk_tipo_usuario CHECK(tipo IN('Analista', 'Gestor'))
);

-- TABELA USUARIO
CREATE TABLE IF NOT EXISTS usuario (
id INT PRIMARY KEY AUTO_INCREMENT,
nome VARCHAR(200) NOT NULL,
email VARCHAR(350) NOT NULL,
senha VARCHAR(300) NOT NULL,
fk_empresa INT NOT NULL,
fk_tipo_usuario INT NOT NULL,
CONSTRAINT fk_usuario_empresa FOREIGN KEY (fk_empresa)
REFERENCES empresa(id),
CONSTRAINT fk_usuario_perfil FOREIGN KEY (fk_tipo_usuario)
REFERENCES perfil(id)
) AUTO_INCREMENT = 10000;

-- TABELA SERVIDORES
CREATE TABLE IF NOT EXISTS servidor (
id INT PRIMARY KEY AUTO_INCREMENT,
tipo VARCHAR (100) NOT NULL,
ip VARCHAR(100),
fk_empresa INT NOT NULL,
CONSTRAINT fk_servidores_empresa FOREIGN KEY (fk_empresa)
REFERENCES empresa(id),
CONSTRAINT check_servidor CHECK (tipo IN('transito', 'pagamento', 'auditoria'))
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
CONSTRAINT fk_metrica_componente FOREIGN KEY (fk_componente)
REFERENCES componente(id)
);

-- TABELA ASSOCIATIVA - CONFIG
CREATE TABLE config (
id INT PRIMARY KEY AUTO_INCREMENT,
fk_componente INT NOT NULL,
fk_servidor INT NOT NULL,
CONSTRAINT fk_config_componente FOREIGN KEY (fk_componente)
REFERENCES componente(id),
CONSTRAINT fk_config_servidor FOREIGN KEY (fk_servidor)
REFERENCES servidor(id)
);

-- TABELA REGISTRO - MONITORAMENTO
CREATE TABLE registro_monitoramento (
id INT PRIMARY KEY AUTO_INCREMENT,
fk_config INT NOT NULL,
valor DECIMAL (5,2) NOT NULL,
CONSTRAINT fk_registro_config FOREIGN KEY (fk_config)
REFERENCES config(id)
);

-- TABELA ALERTA
CREATE TABLE IF NOT EXISTS alerta (
id INT PRIMARY KEY AUTO_INCREMENT,
categoria VARCHAR(15) NOT NULL,
descricao VARCHAR(300) NOT NULL,
chk_registro INT NOT NULL,
fk_cofig INT NOT NULL,
CONSTRAINT fk_alerta_config FOREIGN KEY (fk_config) REFERENCES config(id),
CONSTRAINT chk_categoria_alerta CHECK (categoria IN('Normal', 'Moderado', 'Critico'))
);

-- INSERTS: TABELA EMPRESA
INSERT INTO empresa (nome_fantasia, cnpj) VALUES
('AquaTech Solutions', '12345678000100'),
('SorveSys Monitoramento', '98765432000199');

-- INSERTS: TABELA TIPO DE PERFIL
-- Valores restritos pela constraint: 'Analista', 'Gestor'
INSERT INTO perfil (tipo) VALUES
('Gestor'),
('Analista');

-- INSERTS: TABELA USUARIO
-- O ID iniciara automaticamente em 10000 devido ao AUTO_INCREMENT definido
INSERT INTO usuario (nome, email, senha, fk_empresa, fk_tipo_usuario) VALUES
('Carlos Silva', 'carlos.silva@aquatech.com', 'hash_senha_123', 1, 1),
('Ana Oliveira', 'ana.oliveira@sorvesys.com', 'hash_senha_456', 2, 2),
('Lucas Martins', 'lucas.martins@aquatech.com', 'hash_senha_789', 1, 2);

-- INSERTS: TABELA SERVIDORES
-- Valores restritos pela constraint: 'transito', 'pagamento', 'auditoria'
INSERT INTO servidor (tipo, ip, fk_empresa) VALUES
('transito', '192.168.1.10', 1),
('pagamento', '192.168.1.15', 1),
('auditoria', '10.0.0.50', 2);

-- INSERTS: TABELA TIPO DE COMPONENTE
INSERT INTO componente (nome) VALUES
('CPU'),
('Memoria RAM'),
('Disco Rigido');

-- INSERTS: TABELA METRICAS
INSERT INTO metrica (tipo, fk_componente) VALUES
('Porcentagem de Uso (%)', 1),
('Frequencia (GHz)', 1),
('Consumo de Memoria (GB)', 2),
('Espaco Disponivel (GB)', 3);

-- INSERTS: TABELA ASSOCIATIVA - CONFIG
-- Mapeando quais componentes sao monitorados em quais servidores
INSERT INTO config (fk_componente, fk_servidor) VALUES
(1, 1), -- Monitorando CPU no servidor de transito
(2, 1), -- Monitorando RAM no servidor de transito
(1, 2), -- Monitorando CPU no servidor de pagamento
(3, 3); -- Monitorando Disco no servidor de auditoria

-- INSERTS: TABELA REGISTRO - MONITORAMENTO
-- Valores de exemplo capturados pelo sistema (formato DECIMAL 5,2)
INSERT INTO registro_monitoramento (fk_config, valor) VALUES
(1, 45.50),  -- 45.5% de uso de CPU
(2, 8.20),   -- 8.2 GB de RAM em uso
(3, 95.00),  -- 95% de uso de CPU (Gatilho para alerta critico)
(4, 250.00); -- 250 GB livres no disco

-- INSERTS: TABELA ALERTAS
-- Valores restritos pela constraint: 'Normal', 'Moderado', 'Critico'
INSERT INTO alerta (categoria, descricao, chk_registro) VALUES
('Normal', 'Uso de CPU do servidor de transito dentro do esperado.', 1),
('Normal', 'Consumo de RAM estavel.', 2),
('Critico', 'Alerta: Uso de CPU do servidor de pagamento atingiu nivel critico (95%).', 3);