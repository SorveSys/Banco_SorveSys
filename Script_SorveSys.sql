CREATE DATABASE IF NOT EXISTS sorvesys;
DROP DATABASE sorvesys;
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

-- TABELA USUÁRIO
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
CONSTRAINT check_servidor CHECK (tipo IN('trânsito', 'pagamento', 'auditoria'))
);

-- TABELA TIPO DE COMPONENTE 
CREATE TABLE componente (
id INT PRIMARY KEY AUTO_INCREMENT,
nome VARCHAR(100)
);

-- TABELA MÉTRICAS
CREATE TABLE metrica (
id INT PRIMARY KEY AUTO_INCREMENT,
tipo VARCHAR(100),
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
valor DECIMAL (5,2),
CONSTRAINT fk_registro_config FOREIGN KEY (fk_config)
REFERENCES config(id)
);

-- TABELA MÉTRICAS
CREATE TABLE IF NOT EXISTS alerta (
id INT PRIMARY KEY AUTO_INCREMENT,
categoria VARCHAR(15) NOT NULL,
descricao VARCHAR(300),
chk_registro INT NOT NULL,
CONSTRAINT chk_categoria_alerta CHECK (categoria IN('Normal', 'Moderado', 'Critico'))
);
