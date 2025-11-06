
USE vehiculos_db;
CREATE TABLE SeguroVehicular (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    eliminado BOOLEAN DEFAULT FALSE,
    aseguradora VARCHAR(80) NOT NULL,
    nroPoliza VARCHAR(50) NOT NULL UNIQUE,
    cobertura ENUM('RC', 'TERCEROS', 'TODO_RIESGO') NOT NULL,
    vencimiento DATE NOT NULL
);
CREATE TABLE Vehiculo (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    eliminado BOOLEAN DEFAULT FALSE,
    dominio VARCHAR(10) NOT NULL UNIQUE,
    marca VARCHAR(50) NOT NULL,
    modelo VARCHAR(50) NOT NULL,
    anio INT,
    nroChasis VARCHAR(50) NOT NULL UNIQUE,
    seguro_id BIGINT,
    FOREIGN KEY (seguro_id) REFERENCES SeguroVehicular(id)
);
