package com.utp.logiconstruction.dao;

import com.utp.logiconstruction.conexion.Conexion;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class ReporteDAO {

    public int contarCompras() {
        return contar("SELECT COUNT(*) FROM compras");
    }

    public int contarComprasRecibidas() {
        return contar("SELECT COUNT(*) FROM compras WHERE UPPER(TRIM(estado)) = 'RECIBIDA'");
    }

    public int contarProveedores() {
        return contar("SELECT COUNT(*) FROM proveedores");
    }

    public int contarProveedoresActivos() {
        return contar("SELECT COUNT(*) FROM proveedores WHERE UPPER(TRIM(estado)) = 'ACTIVO'");
    }

    public int contarRequerimientos() {
        return contar("SELECT COUNT(*) FROM requerimientos");
    }

    public int contarRequerimientosPendientes() {
        return contarRequerimientosPorEstado("PENDIENTE");
    }

    public int contarRequerimientosAprobados() {
        return contarRequerimientosPorEstado("APROBADO");
    }

    public int contarRequerimientosRechazados() {
        return contarRequerimientosPorEstado("RECHAZADO");
    }

    public int contarRequerimientosAtendidos() {
        return contarRequerimientosPorEstado("ATENDIDO");
    }

    /**
     * Un requerimiento se considera resuelto cuando concluyó su flujo:
     * fue atendido o fue rechazado. Un requerimiento aprobado todavía está
     * pendiente de atención física y por eso no se contabiliza como resuelto.
     */
    public int contarRequerimientosResueltos() {
        return contar("SELECT COUNT(*) FROM requerimientos "
                + "WHERE UPPER(TRIM(estado)) IN ('ATENDIDO','RECHAZADO')");
    }

    /**
     * Incluye todos los registros que todavía requieren seguimiento,
     * principalmente PENDIENTE y APROBADO.
     */
    public int contarRequerimientosPorResolver() {
        return contar("SELECT COUNT(*) FROM requerimientos "
                + "WHERE UPPER(TRIM(estado)) NOT IN ('ATENDIDO','RECHAZADO')");
    }

    private int contarRequerimientosPorEstado(String estado) {
        String sql = "SELECT COUNT(*) FROM requerimientos WHERE UPPER(TRIM(estado)) = ?";
        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, estado);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    public BigDecimal obtenerCostoTotalCompras() {
        String sql = "SELECT COALESCE(SUM(cantidad * costo_unitario), 0) "
                + "FROM compras WHERE UPPER(TRIM(estado)) <> 'ANULADA'";

        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                BigDecimal resultado = rs.getBigDecimal(1);
                return resultado == null ? BigDecimal.ZERO : resultado;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return BigDecimal.ZERO;
    }

    public List<String> obtenerMaterialesMasComprados() {
        List<String> datos = new ArrayList<>();
        String sql = "SELECT producto, SUM(cantidad) AS total FROM compras "
                + "WHERE UPPER(TRIM(estado)) <> 'ANULADA' "
                + "GROUP BY producto ORDER BY total DESC LIMIT 5";

        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
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
        return obtenerPrimero("SELECT producto FROM compras "
                + "WHERE UPPER(TRIM(estado)) <> 'ANULADA' "
                + "GROUP BY producto ORDER BY SUM(cantidad) DESC LIMIT 1", "producto");
    }

    public String obtenerUltimaCompra() {
        return obtenerPrimero("SELECT producto FROM compras ORDER BY id DESC LIMIT 1", "producto");
    }

    public String obtenerProveedorMasUsado() {
        return obtenerPrimero("SELECT proveedor FROM compras "
                + "WHERE UPPER(TRIM(estado)) <> 'ANULADA' "
                + "GROUP BY proveedor ORDER BY COUNT(*) DESC LIMIT 1", "proveedor");
    }

    private String obtenerPrimero(String sql, String columna) {
        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getString(columna);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "Sin registros";
    }

    private int contar(String sql) {
        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
}
