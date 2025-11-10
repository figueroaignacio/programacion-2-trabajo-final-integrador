/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {
    private static final String URL = "jdbc:mysql://localhost:3306/vehiculos_db";
    private static final String USER = "root";
    private static final String PASSWORD = "tu_contraseña";

    public static Connection getConnection() {
        Connection connection = null;
        try {
            connection = DriverManager.getConnection(URL, USER, PASSWORD);
            System.out.println(" Conexión exitosa a la base de datos.");
        } catch (SQLException e) {
            System.out.println(" Error al conectar a la base de datos: " + e.getMessage());
        }
        return connection;
    }
}
