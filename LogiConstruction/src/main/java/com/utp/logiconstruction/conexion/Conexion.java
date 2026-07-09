package com.utp.logiconstruction.conexion;

import java.sql.Connection;
import java.sql.SQLException;

public class Conexion {

    public static Connection conectar() throws SQLException {
        return DatabaseConfig.obtenerConexion();
    }
}
