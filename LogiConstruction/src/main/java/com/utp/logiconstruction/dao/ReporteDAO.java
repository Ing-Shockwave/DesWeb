package com.utp.logiconstruction.dao;

import com.utp.logiconstruction.conexion.Conexion;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

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

    public List<String> obtenerMaterialesMasComprados() {
        List<String> datos = new ArrayList<>();

        String sql = "SELECT producto, COUNT(*) AS total FROM compras GROUP BY producto ORDER BY total DESC LIMIT 5";

        try (
            Connection con = Conexion.conectar();
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {
            while (rs.next()) {
                datos.add(rs.getString("producto"));
                datos.add(String.valueOf(rs.getInt("total")));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return datos;
    }

    public String obtenerMaterialMasComprado() {
        String resultado = "Sin registros";

        String sql = "SELECT producto, COUNT(*) AS total FROM compras GROUP BY producto ORDER BY total DESC LIMIT 1";

        try (
            Connection con = Conexion.conectar();
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {
            if (rs.next()) {
                resultado = rs.getString("producto");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return resultado;
    }

    public String obtenerUltimaCompra() {
        String resultado = "Sin registros";

        String sql = "SELECT producto FROM compras ORDER BY id DESC LIMIT 1";

        try (
            Connection con = Conexion.conectar();
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {
            if (rs.next()) {
                resultado = rs.getString("producto");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return resultado;
    }

    public String obtenerProveedorMasUsado() {
        String resultado = "Sin registros";

        String sql = "SELECT proveedor, COUNT(*) AS total FROM compras GROUP BY proveedor ORDER BY total DESC LIMIT 1";

        try (
            Connection con = Conexion.conectar();
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {
            if (rs.next()) {
                resultado = rs.getString("proveedor");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return resultado;
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