create database projeto_pet_care;
use projeto_pet_care;

create table login (
	id_login int auto_increment,
    email varchar(256) not null UNIQUE,
    senha varchar(256) not null,
    tipo_user enum('Tutor', 'Clinica', 'ADM') not null,
    primary key (id_login)
);

create table adm (
	id_adm int auto_increment,
    nome varchar(80),
    fk_id_login int not null,
    foreign key (fk_id_login) references login (id_login),
    primary key (id_adm)
);

create table pessoa (
	id_pessoa int auto_increment,
	nome varchar(80) not null,
    foto blob,
    descricao text,
    telefone varchar(15) not null,
    fk_id_login int not null,
    foreign key (fk_id_login) references login (id_login),
    primary key (id_pessoa)
);

create table tutor (
	id_tutor int auto_increment,
    dt_nascimento date,
    fk_id_pessoa int not null,
    foreign key (fk_id_pessoa) references pessoa (id_pessoa),
    primary key (id_tutor)
);

create table clinica (
	id_clinica int auto_increment,
    funcionamento text not null,
    cfmv_crmv varchar(15) not null UNIQUE,
    fk_id_pessoa int not null,
    foreign key (fk_id_pessoa) references pessoa (id_pessoa),
    primary key (id_clinica)
);

create table endereco (
	id_endereco int auto_increment,
    logradouro varchar(60) not null,
    numero varchar(4) not null,
    complemento text,
    bairro varchar(60) not null,
    cidade varchar(60) not null,
    cep varchar(8),
    estado char(2) not null,
    fk_id_pessoa int not null,
    foreign key (fk_id_pessoa) references pessoa (id_pessoa),
    primary key (id_endereco)
);

create table pet (
	id_pet int auto_increment,
    nome varchar(40) not null,
    foto blob,
    descricao text,
    especie varchar(40),
    raca varchar(60),
    cor varchar(20),
    sexo enum('M', 'F') not null,
    porte enum('Pequeno', 'Médio', 'Grande') not null,
    peso decimal(4,2),
    dt_nascimento datetime,
    fk_id_tutor int not null,
    foreign key (fk_id_tutor) references tutor (id_tutor),
    primary key (id_pet)
);

create table cartao_vacinacao (
	id_cartao_vacinacao int auto_increment,
    nome_vacina varchar(40) not null,
    dt_vacinacao date not null,
    lote_vacina varchar(24),
    medico_vet varchar(80),
    clinica_vet varchar(60),
    fk_id_pet int not null,
    foreign key (fk_id_pet) references pet (id_pet),
    primary key (id_cartao_vacinacao)
);

create table prox_vacina (
	id_prox_vacina int auto_increment,
    nome_vacina varchar(40),
    dt_vacina date,
    fk_id_pet int not null,
    foreign key (fk_id_pet) references pet (id_pet),
    primary key (id_prox_vacina)
);

create table alerta_campanhas (
	id_alerta_campanha int auto_increment,
	desc_campanha text not null,
    inicio_campanha datetime not null,
    fim_campanha datetime not null,
    fonte_web varchar(256) not null,
    fk_id_clinica int not null,
    foreign key (fk_id_clinica) references clinica (id_clinica),
    primary key (id_alerta_campanha)
);

create table endereco_campanha (
	id_endereco_campanha int auto_increment,
    logradouro varchar(60) not null,
    numero varchar(4) not null,
    complemento varchar(60),
    bairro varchar(60) not null,
    cidade varchar(60) not null,
    cep varchar(8),
    estado char(2) not null,
    fk_id_alerta_campanhas int not null,
    foreign key (fk_id_alerta_campanhas) references alerta_campanhas (id_alerta_campanha),
    primary key (id_endereco_campanha)
);

select*from logim;
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) NOT NULL,
    senha VARCHAR(100) NOT NULL
);



CREATE DATABASE IF NOT EXISTS projeto_pet_care;
USE projeto_pet_care;

CREATE TABLE IF NOT EXISTS doencas (
    id_doenca INT AUTO_INCREMENT,
    especie VARCHAR(40) NOT NULL,
    nome_animal VARCHAR(80) NOT NULL,
    raca_animal VARCHAR(60) NOT NULL,
    nome_doenca VARCHAR(60) NOT NULL,
    detalhes_doenca TEXT NOT NULL,
    PRIMARY KEY (id_doenca)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Exemplo de dados iniciais
INSERT INTO doencas (especie, nome_animal, raca_animal, nome_doenca, detalhes_doenca) VALUES
('Cão', 'Rex', 'Labrador', 'Cinomose', 'Doença viral altamente contagiosa que afeta o sistema respiratório, gastrointestinal e nervoso'),
('Cão', 'Bella', 'Poodle', 'Parvovirose', 'Doença viral grave que causa vômitos e diarreia com sangue'),
('Gato', 'Mimi', 'Siamês', 'Panleucopenia', 'Doença viral felina que causa febre, vômitos e diarreia'),
('Gato', 'Luna', 'Persa', 'Rinotraqueíte', 'Infecção respiratória viral comum em gatos');


create table mensagens
  (
  id_mensagem int auto_increment,
  id_remetente int not null,
  id_destinatario int not null,
  mensagem text not null,
  dt_hr_mensagem datetime not null,
  primary key (id_mensagem),
  foreign key (id_remetente) references pessoa (id_pessoa),
  foreign key (id_destinatario) references pessoa (id_pessoa)
  );



-- TRIGGERS

DELIMITER $$
DROP TRIGGER IF EXISTS inserir_ao_criar_login;
CREATE TRIGGER inserir_ao_criar_login
AFTER INSERT ON login
FOR EACH ROW
BEGIN
    -- Inserir na tabela 'pessoa'
    INSERT INTO pessoa (id_pessoa, nome, foto, descricao, telefone, fk_id_login)
    VALUES (NEW.id_login, 'Nome Padrão', NULL, NULL, '', NEW.id_login);

    -- Verificar o tipo_user
    IF NEW.tipo_user = 'Tutor' THEN
        INSERT INTO tutor (id_tutor, dt_nascimento, fk_id_pessoa)
        VALUES (NEW.id_login, NULL, NEW.id_login); 
    ELSEIF NEW.tipo_user = 'Clinica' THEN
        INSERT INTO clinica (id_clinica, funcionamento, cfmv_crmv, fk_id_pessoa)
        VALUES (NEW.id_login, '', NEW.id_login, NEW.id_login);
	ELSEIF NEW.tipo_user = 'ADM' THEN
        INSERT INTO adm (id_adm, nome, fk_id_login)
        VALUES (NEW.id_login, 'Nome Padrão', NEW.id_login);
    END IF;
    
    -- Inserir na tabela 'endereco', garantindo que o 'id_endereco' seja igual ao 'id_pessoa'
    INSERT INTO endereco (id_endereco, logradouro, numero, complemento, bairro, cidade, cep, estado, fk_id_pessoa)
    VALUES (NEW.id_login, 'Logradouro Padrão', '000', NULL, 'Bairro Padrão', 'Cidade Padrão', '00000000', 'BR', NEW.id_login);
END $$
DELIMITER ;



-- Insert ADM

INSERT INTO login (email, senha, tipo_user)
VALUES ('@admin', UPPER(MD5('admin')), 'ADM');



-- VIEWS

DROP VIEW IF EXISTS info_clinica;
CREATE VIEW info_clinica AS
SELECT
ps.id_pessoa,
ps.nome,
ps.foto,
ps.descricao,
ps.telefone,
cl.funcionamento,
cl.cfmv_crmv,
en.logradouro,
en.numero,
en.complemento,
en.bairro,
en.cidade,
en.cep,
en.estado
FROM pessoa ps
INNER JOIN clinica cl ON ps.id_pessoa = cl.id_clinica
INNER JOIN endereco en ON ps.id_pessoa = en.id_endereco;


DROP VIEW IF EXISTS info_tutor;
CREATE VIEW info_tutor AS
SELECT
ps.id_pessoa,
ps.nome,
ps.descricao,
ps.telefone,
t.dt_nascimento,
en.logradouro,
en.numero,
en.complemento,
en.bairro,
en.cidade,
en.cep,
en.estado
FROM pessoa ps
INNER JOIN tutor t ON ps.id_pessoa = t.id_tutor
INNER JOIN endereco en ON ps.id_pessoa = en.id_endereco;


DROP VIEW IF EXISTS buscar_clinicas;
CREATE VIEW buscar_clinicas AS
SELECT l.id_login, p.nome FROM login AS l
INNER JOIN pessoa p ON l.id_login = p.id_pessoa
WHERE l.tipo_user = 'Clinica'
ORDER BY p.nome ASC;


DROP VIEW IF EXISTS info_campanha;
CREATE VIEW info_campanha AS
SELECT
ac.id_alerta_campanha,
ac.desc_campanha,
ac.inicio_campanha,
ac.fim_campanha,
ac.fonte_web,
ec.cep as cep,
ec.logradouro as logradouro,
ec.numero as numero,
ec.complemento as complemento,
ec.bairro as bairro,
ec.cidade as cidade,
ec.estado as estado
FROM alerta_campanhas ac
INNER JOIN endereco_campanha ec ON ec.id_endereco_campanha = ac.id_alerta_campanha
;


DROP VIEW IF EXISTS mini_info_clinica;
CREATE VIEW mini_info_clinica AS
SELECT p.id_pessoa, p.nome, p.descricao, p.telefone, c.funcionamento, e.bairro, e.cidade, e.estado
FROM pessoa p
INNER JOIN clinica c ON p.id_pessoa = c.fk_id_pessoa
INNER JOIN endereco e ON p.id_pessoa = e.fk_id_pessoa;


CREATE USER 'senac'@'%' IDENTIFIED BY '123';
GRANT ALL PRIVILEGES ON projeto_pet_care.* TO 'senac'@'%';
FLUSH PRIVILEGES;


/*GRANT ALL ON *.* TO 'senac'@'%';*/
-- Fiz o select diretamente no codigo para passar parametros
/*
DROP VIEW IF EXISTS mostrar_tutor;
CREATE VIEW mostrar_tutor AS
SELECT DISTINCT l.id_login, p.nome
FROM login AS l
INNER JOIN pessoa p ON l.id_login = p.id_pessoa
INNER JOIN mensagens m ON m.id_remetente = p.id_pessoa
WHERE l.tipo_user = 'Tutor' AND m.id_remetente = ?
ORDER BY p.nome ASC;
*/