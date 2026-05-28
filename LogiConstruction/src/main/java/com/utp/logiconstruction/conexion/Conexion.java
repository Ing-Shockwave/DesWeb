package com.utp.logiconstruction.conexion;

import java.sql.Connection;
import java.sql.DriverManager;

public class Conexion {

    private static final String URL = "jdbc:mysql://localhost:3306/LogiConstruction";
    private static final String USER = "root";
    private static final String PASSWORD = "admin";

    public static Connection conectar() {

        Connection con = null;

        try {

            Class.forName("com.mysql.cj.jdbc.Driver");

            con = DriverManager.getConnection(URL, USER, PASSWORD);

            System.out.println("Conexion exitosa a MySQL");

        } catch (Exception e) {

            System.out.println("Error de conexion: " + e.getMessage());

        }

        return con;
    }
}