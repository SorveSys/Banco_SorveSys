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
valor DOUBLE NOT NULL,
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
data_hora TIMESTAMP NOT NULL,
configuracao_maquina_fk INT,
configuracao_componente_fk INT,
metrica_fk INT,
FOREIGN KEY (configuracao_maquina_fk, configuracao_componente_fk) REFERENCES configuracao(maquina_fk, componente_fk),
FOREIGN KEY (metrica_fk) REFERENCES metrica(id)
);

CREATE TABLE leitura_alerta (
id INT PRIMARY KEY AUTO_INCREMENT,
leitura_fk INT,
FOREIGN KEY (leitura_fk) REFERENCES leitura(id)
);