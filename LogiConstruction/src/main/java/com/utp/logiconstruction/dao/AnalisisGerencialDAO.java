package com.utp.logiconstruction.dao;

import com.utp.logiconstruction.conexion.Conexion;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * Consultas de solo lectura para el módulo gerencial de análisis de costos.
 */
public class AnalisisGerencialDAO {

    public ResumenCostos obtenerResumen(LocalDate desde, LocalDate hasta,
            String proveedor, String producto, String estado) {

        FiltroSql filtro = construirFiltro(desde, hasta, proveedor, producto, estado);
        String sql = "SELECT COUNT(*) AS total_registros, "
                + "SUM(CASE WHEN UPPER(TRIM(estado)) <> 'ANULADA' THEN 1 ELSE 0 END) AS compras_validas, "
                + "COALESCE(SUM(CASE WHEN UPPER(TRIM(estado)) <> 'ANULADA' "
                + "THEN cantidad * costo_unitario ELSE 0 END), 0) AS costo_total, "
                + "COALESCE(AVG(CASE WHEN UPPER(TRIM(estado)) <> 'ANULADA' "
                + "THEN cantidad * costo_unitario END), 0) AS costo_promedio, "
                + "COALESCE(MAX(CASE WHEN UPPER(TRIM(estado)) <> 'ANULADA' "
                + "THEN cantidad * costo_unitario END), 0) AS compra_mayor "
                + "FROM compras WHERE 1=1 " + filtro.sql;

        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql)) {
            asignarParametros(ps, filtro.parametros);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new ResumenCostos(
                            rs.getInt("total_registros"),
                            rs.getInt("compras_validas"),
                            valor(rs.getBigDecimal("costo_total")),
                            valor(rs.getBigDecimal("costo_promedio")),
                            valor(rs.getBigDecimal("compra_mayor")));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return new ResumenCostos(0, 0, BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO);
    }

    public List<DatoGrafico> obtenerGastoMensual(LocalDate desde, LocalDate hasta,
            String proveedor, String producto, String estado) {

        FiltroSql filtro = construirFiltro(desde, hasta, proveedor, producto, estado);
        String sql = "SELECT DATE_FORMAT(fecha, '%Y-%m') AS periodo_orden, "
                + "DATE_FORMAT(fecha, '%m/%Y') AS etiqueta, "
                + "COALESCE(SUM(cantidad * costo_unitario), 0) AS total "
                + "FROM compras WHERE UPPER(TRIM(estado)) <> 'ANULADA' "
                + filtro.sql + " GROUP BY periodo_orden, etiqueta ORDER BY periodo_orden";
        return consultarGrafico(sql, filtro.parametros, "etiqueta", "total", 24);
    }

    public List<DatoGrafico> obtenerGastoPorProveedor(LocalDate desde, LocalDate hasta,
            String proveedor, String producto, String estado) {

        FiltroSql filtro = construirFiltro(desde, hasta, proveedor, producto, estado);
        String sql = "SELECT proveedor AS etiqueta, "
                + "COALESCE(SUM(cantidad * costo_unitario), 0) AS total "
                + "FROM compras WHERE UPPER(TRIM(estado)) <> 'ANULADA' "
                + filtro.sql + " GROUP BY proveedor ORDER BY total DESC LIMIT 7";
        return consultarGrafico(sql, filtro.parametros, "etiqueta", "total", 7);
    }

    public List<DatoGrafico> obtenerDistribucionEstados(LocalDate desde, LocalDate hasta,
            String proveedor, String producto, String estado) {

        FiltroSql filtro = construirFiltro(desde, hasta, proveedor, producto, estado);
        String sql = "SELECT UPPER(TRIM(estado)) AS etiqueta, COUNT(*) AS total "
                + "FROM compras WHERE 1=1 " + filtro.sql
                + " GROUP BY UPPER(TRIM(estado)) ORDER BY etiqueta";
        return consultarGrafico(sql, filtro.parametros, "etiqueta", "total", 10);
    }

    public List<CompraDetalle> listarCompras(LocalDate desde, LocalDate hasta,
            String proveedor, String producto, String estado) {

        List<CompraDetalle> lista = new ArrayList<>();
        FiltroSql filtro = construirFiltro(desde, hasta, proveedor, producto, estado);
        String sql = "SELECT id, proveedor, producto, cantidad, fecha, estado, costo_unitario, "
                + "(cantidad * costo_unitario) AS costo_total "
                + "FROM compras WHERE 1=1 " + filtro.sql
                + " ORDER BY fecha DESC, id DESC LIMIT 500";

        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql)) {
            asignarParametros(ps, filtro.parametros);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    lista.add(new CompraDetalle(
                            rs.getInt("id"),
                            rs.getString("proveedor"),
                            rs.getString("producto"),
                            rs.getInt("cantidad"),
                            rs.getTimestamp("fecha"),
                            rs.getString("estado"),
                            valor(rs.getBigDecimal("costo_unitario")),
                            valor(rs.getBigDecimal("costo_total"))));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }

    public List<String> listarProveedoresConCompras() {
        List<String> lista = new ArrayList<>();
        String sql = "SELECT DISTINCT proveedor FROM compras "
                + "WHERE proveedor IS NOT NULL AND TRIM(proveedor) <> '' ORDER BY proveedor";
        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(rs.getString("proveedor"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }

    private List<DatoGrafico> consultarGrafico(String sql, List<Object> parametros,
            String columnaEtiqueta, String columnaValor, int limite) {

        List<DatoGrafico> lista = new ArrayList<>();
        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql)) {
            asignarParametros(ps, parametros);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next() && lista.size() < limite) {
                    lista.add(new DatoGrafico(
                            rs.getString(columnaEtiqueta),
                            valor(rs.getBigDecimal(columnaValor))));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }

    private FiltroSql construirFiltro(LocalDate desde, LocalDate hasta,
            String proveedor, String producto, String estado) {

        StringBuilder sql = new StringBuilder();
        List<Object> parametros = new ArrayList<>();

        if (desde != null) {
            sql.append(" AND fecha >= ?");
            parametros.add(Timestamp.valueOf(desde.atStartOfDay()));
        }
        if (hasta != null) {
            sql.append(" AND fecha < ?");
            parametros.add(Timestamp.valueOf(hasta.plusDays(1).atStartOfDay()));
        }
        if (proveedor != null && !proveedor.trim().isEmpty()) {
            sql.append(" AND proveedor = ?");
            parametros.add(proveedor.trim());
        }
        if (producto != null && !producto.trim().isEmpty()) {
            sql.append(" AND LOWER(producto) LIKE ?");
            parametros.add("%" + producto.trim().toLowerCase() + "%");
        }
        if (estado != null && !estado.trim().isEmpty()) {
            sql.append(" AND UPPER(TRIM(estado)) = ?");
            parametros.add(estado.trim().toUpperCase());
        }

        return new FiltroSql(sql.toString(), parametros);
    }

    private void asignarParametros(PreparedStatement ps, List<Object> parametros)
            throws SQLException {
        for (int i = 0; i < parametros.size(); i++) {
            Object valor = parametros.get(i);
            if (valor instanceof Timestamp) {
                ps.setTimestamp(i + 1, (Timestamp) valor);
            } else {
                ps.setObject(i + 1, valor);
            }
        }
    }

    private BigDecimal valor(BigDecimal numero) {
        return numero == null ? BigDecimal.ZERO : numero;
    }

    private static final class FiltroSql {
        private final String sql;
        private final List<Object> parametros;

        private FiltroSql(String sql, List<Object> parametros) {
            this.sql = sql;
            this.parametros = parametros;
        }
    }

    public static final class ResumenCostos {
        private final int totalRegistros;
        private final int comprasValidas;
        private final BigDecimal costoTotal;
        private final BigDecimal costoPromedio;
        private final BigDecimal compraMayor;

        public ResumenCostos(int totalRegistros, int comprasValidas,
                BigDecimal costoTotal, BigDecimal costoPromedio, BigDecimal compraMayor) {
            this.totalRegistros = totalRegistros;
            this.comprasValidas = comprasValidas;
            this.costoTotal = costoTotal;
            this.costoPromedio = costoPromedio;
            this.compraMayor = compraMayor;
        }

        public int getTotalRegistros() { return totalRegistros; }
        public int getComprasValidas() { return comprasValidas; }
        public BigDecimal getCostoTotal() { return costoTotal; }
        public BigDecimal getCostoPromedio() { return costoPromedio; }
        public BigDecimal getCompraMayor() { return compraMayor; }
    }

    public static final class DatoGrafico {
        private final String etiqueta;
        private final BigDecimal valor;

        public DatoGrafico(String etiqueta, BigDecimal valor) {
            this.etiqueta = etiqueta;
            this.valor = valor;
        }

        public String getEtiqueta() { return etiqueta; }
        public BigDecimal getValor() { return valor; }
    }

    public static final class CompraDetalle {
        private final int id;
        private final String proveedor;
        private final String producto;
        private final int cantidad;
        private final Timestamp fecha;
        private final String estado;
        private final BigDecimal costoUnitario;
        private final BigDecimal costoTotal;

        public CompraDetalle(int id, String proveedor, String producto, int cantidad,
                Timestamp fecha, String estado, BigDecimal costoUnitario, BigDecimal costoTotal) {
            this.id = id;
            this.proveedor = proveedor;
            this.producto = producto;
            this.cantidad = cantidad;
            this.fecha = fecha;
            this.estado = estado;
            this.costoUnitario = costoUnitario;
            this.costoTotal = costoTotal;
        }

        public int getId() { return id; }
        public String getProveedor() { return proveedor; }
        public String getProducto() { return producto; }
        public int getCantidad() { return cantidad; }
        public Timestamp getFecha() { return fecha; }
        public String getEstado() { return estado; }
        public BigDecimal getCostoUnitario() { return costoUnitario; }
        public BigDecimal getCostoTotal() { return costoTotal; }
    }
}
