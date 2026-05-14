package com.utp.logiconstruction.dao;

import com.utp.logiconstruction.conexion.Conexion;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class ReporteDAO {

    public int contarCompras() {
        return contar("SELECT COUNT(*) FROM compras");
    }

    public int contarProveedores() {
        return contar("SELECT COUNT(*) FROM proveedores");
    }

    public int contarRequerimientos() {
        return contar("SELECT COUNT(*) FROM requerimientos");
    }

    private int contar(String sql) {
        int total = 0;

        try (
            Connection con = Conexion.conectar();
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {
            if (rs.next()) {
                total = rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return total;
    }
}