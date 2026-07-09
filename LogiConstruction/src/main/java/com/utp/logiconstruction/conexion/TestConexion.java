package com.utp.logiconstruction.conexion;

import java.sql.Connection;

public class TestConexion {
    public static void main(String[] args) {
        try (Connection con = Conexion.conectar()) {
            System.out.println("Conexión correcta: " + (con != null));
        } catch (Exception e) {
            System.out.println("Error de conexión: " + e.getMessage());
        }
    }
}
