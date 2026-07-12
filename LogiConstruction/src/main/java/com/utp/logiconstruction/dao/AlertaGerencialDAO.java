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
import java.util.Comparator;
import java.util.List;

/**
 * Genera alertas de solo lectura a partir de los datos operativos existentes.
 */
public class AlertaGerencialDAO {

    public List<Alerta> listarAlertas() {
        List<Alerta> alertas = new ArrayList<>();
        agregarAlertasRequerimientos(alertas);
        agregarAlertasCompras(alertas);
        agregarAlertasProveedores(alertas);
        agregarResumenInformativo(alertas);

        alertas.sort(Comparator
                .comparingInt(Alerta::getOrdenPrioridad)
                .thenComparing(Alerta::getFechaOrden, Comparator.nullsLast(Comparator.naturalOrder())));

        if (alertas.isEmpty()) {
            alertas.add(new Alerta("SISTEMA", "INFORMATIVA", "Sin alertas",
                    "No se detectaron situaciones que requieran seguimiento gerencial.",
                    LocalDate.now().toString(), "Operativo", 0, BigDecimal.ZERO));
        }
        return alertas;
    }

    public ResumenAlertas obtenerResumen(List<Alerta> alertas) {
        int criticas = 0;
        int altas = 0;
        int medias = 0;
        int informativas = 0;

        for (Alerta alerta : alertas) {
            switch (alerta.getNivel()) {
                case "CRITICA":
                    criticas++;
                    break;
                case "ALTA":
                    altas++;
                    break;
                case "MEDIA":
                    medias++;
                    break;
                default:
                    informativas++;
                    break;
            }
        }
        return new ResumenAlertas(criticas, altas, medias, informativas, alertas.size());
    }

    private void agregarAlertasRequerimientos(List<Alerta> alertas) {
        String sql = "SELECT id, nombre, area, fecha, estado, "
                + "GREATEST(DATEDIFF(CURDATE(), fecha), 0) AS dias "
                + "FROM requerimientos WHERE UPPER(TRIM(estado)) IN ('PENDIENTE','APROBADO') "
                + "ORDER BY fecha ASC";

        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                int id = rs.getInt("id");
                String nombre = rs.getString("nombre");
                String area = rs.getString("area");
                String estado = rs.getString("estado").toUpperCase();
                int dias = rs.getInt("dias");
                LocalDate fecha = rs.getDate("fecha").toLocalDate();

                String nivel;
                String detalle;
                if ("APROBADO".equals(estado)) {
                    nivel = dias >= 5 ? "CRITICA" : (dias >= 2 ? "ALTA" : "MEDIA");
                    detalle = "El requerimiento de " + nombre + " para " + area
                            + " fue aprobado, pero todavía no figura como atendido.";
                } else {
                    nivel = dias >= 7 ? "CRITICA" : (dias >= 3 ? "ALTA" : "MEDIA");
                    detalle = "El requerimiento de " + nombre + " para " + area
                            + " continúa pendiente de evaluación.";
                }

                alertas.add(new Alerta("REQUERIMIENTO", nivel, "#REQ-" + id,
                        detalle, fecha.toString(), estado, dias, BigDecimal.ZERO));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private void agregarAlertasCompras(List<Alerta> alertas) {
        String sql = "SELECT id, producto, proveedor, fecha, estado, "
                + "COALESCE(cantidad * costo_unitario, 0) AS total, "
                + "GREATEST(TIMESTAMPDIFF(DAY, fecha, NOW()), 0) AS dias "
                + "FROM compras WHERE UPPER(TRIM(estado)) = 'REGISTRADA' "
                + "ORDER BY fecha ASC";

        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                int id = rs.getInt("id");
                String producto = rs.getString("producto");
                String proveedor = rs.getString("proveedor");
                BigDecimal total = rs.getBigDecimal("total");
                int dias = rs.getInt("dias");
                Timestamp fecha = rs.getTimestamp("fecha");

                String nivel;
                if ((total != null && total.compareTo(new BigDecimal("5000")) >= 0) || dias >= 7) {
                    nivel = "CRITICA";
                } else if ((total != null && total.compareTo(new BigDecimal("2500")) >= 0) || dias >= 3) {
                    nivel = "ALTA";
                } else {
                    nivel = "MEDIA";
                }

                String detalle = "La compra de " + producto + " a " + proveedor
                        + " permanece registrada y todavía no ha sido marcada como recibida.";
                alertas.add(new Alerta("COMPRA", nivel, "#CMP-" + id,
                        detalle, fecha == null ? "" : fecha.toLocalDateTime().toLocalDate().toString(),
                        "REGISTRADA", dias, total == null ? BigDecimal.ZERO : total));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private void agregarAlertasProveedores(List<Alerta> alertas) {
        String sql = "SELECT id, nombre, estado, telefono, correo, direccion, fecha_registro "
                + "FROM proveedores WHERE UPPER(TRIM(estado)) = 'INACTIVO' "
                + "OR telefono IS NULL OR TRIM(telefono) = '' "
                + "OR correo IS NULL OR TRIM(correo) = '' "
                + "OR direccion IS NULL OR TRIM(direccion) = '' ORDER BY id DESC";

        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                int id = rs.getInt("id");
                String nombre = rs.getString("nombre");
                String estado = rs.getString("estado");
                String telefono = rs.getString("telefono");
                String correo = rs.getString("correo");
                String direccion = rs.getString("direccion");
                Timestamp fecha = rs.getTimestamp("fecha_registro");

                boolean inactivo = "INACTIVO".equalsIgnoreCase(estado);
                List<String> faltantes = new ArrayList<>();
                if (vacio(telefono)) faltantes.add("teléfono");
                if (vacio(correo)) faltantes.add("correo");
                if (vacio(direccion)) faltantes.add("dirección");

                String nivel = inactivo ? "ALTA" : "MEDIA";
                String detalle;
                if (inactivo && !faltantes.isEmpty()) {
                    detalle = "El proveedor " + nombre + " está inactivo y además tiene datos incompletos: "
                            + String.join(", ", faltantes) + ".";
                } else if (inactivo) {
                    detalle = "El proveedor " + nombre + " se encuentra inactivo y requiere revisión.";
                } else {
                    detalle = "El proveedor " + nombre + " tiene información incompleta: "
                            + String.join(", ", faltantes) + ".";
                }

                alertas.add(new Alerta("PROVEEDOR", nivel, "#PRV-" + id,
                        detalle, fecha == null ? "" : fecha.toLocalDateTime().toLocalDate().toString(),
                        inactivo ? "INACTIVO" : "REVISAR", 0, BigDecimal.ZERO));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private void agregarResumenInformativo(List<Alerta> alertas) {
        int atendidos = contar("SELECT COUNT(*) FROM requerimientos WHERE UPPER(TRIM(estado)) = 'ATENDIDO'");
        int recibidas = contar("SELECT COUNT(*) FROM compras WHERE UPPER(TRIM(estado)) = 'RECIBIDA'");
        int rechazados = contar("SELECT COUNT(*) FROM requerimientos WHERE UPPER(TRIM(estado)) = 'RECHAZADO'");

        if (atendidos > 0) {
            alertas.add(new Alerta("RESUMEN", "INFORMATIVA", "Requerimientos atendidos",
                    "El sistema registra " + atendidos + " requerimiento(s) atendido(s).",
                    LocalDate.now().toString(), "INFORMATIVO", 0, BigDecimal.ZERO));
        }
        if (recibidas > 0) {
            alertas.add(new Alerta("RESUMEN", "INFORMATIVA", "Compras recibidas",
                    "El sistema registra " + recibidas + " compra(s) recibida(s).",
                    LocalDate.now().toString(), "INFORMATIVO", 0, BigDecimal.ZERO));
        }
        if (rechazados > 0) {
            alertas.add(new Alerta("RESUMEN", "INFORMATIVA", "Requerimientos rechazados",
                    "El sistema registra " + rechazados + " requerimiento(s) rechazado(s) para consulta histórica.",
                    LocalDate.now().toString(), "INFORMATIVO", 0, BigDecimal.ZERO));
        }
    }

    private int contar(String sql) {
        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    private boolean vacio(String valor) {
        return valor == null || valor.trim().isEmpty();
    }

    public static final class ResumenAlertas {
        private final int criticas;
        private final int altas;
        private final int medias;
        private final int informativas;
        private final int total;

        public ResumenAlertas(int criticas, int altas, int medias, int informativas, int total) {
            this.criticas = criticas;
            this.altas = altas;
            this.medias = medias;
            this.informativas = informativas;
            this.total = total;
        }

        public int getCriticas() { return criticas; }
        public int getAltas() { return altas; }
        public int getMedias() { return medias; }
        public int getInformativas() { return informativas; }
        public int getTotal() { return total; }
    }

    public static final class Alerta {
        private final String tipo;
        private final String nivel;
        private final String referencia;
        private final String descripcion;
        private final String fecha;
        private final String estado;
        private final int dias;
        private final BigDecimal monto;

        public Alerta(String tipo, String nivel, String referencia, String descripcion,
                String fecha, String estado, int dias, BigDecimal monto) {
            this.tipo = tipo;
            this.nivel = nivel;
            this.referencia = referencia;
            this.descripcion = descripcion;
            this.fecha = fecha;
            this.estado = estado;
            this.dias = dias;
            this.monto = monto == null ? BigDecimal.ZERO : monto;
        }

        public String getTipo() { return tipo; }
        public String getNivel() { return nivel; }
        public String getReferencia() { return referencia; }
        public String getDescripcion() { return descripcion; }
        public String getFecha() { return fecha; }
        public String getEstado() { return estado; }
        public int getDias() { return dias; }
        public BigDecimal getMonto() { return monto; }

        public int getOrdenPrioridad() {
            if ("CRITICA".equals(nivel)) return 1;
            if ("ALTA".equals(nivel)) return 2;
            if ("MEDIA".equals(nivel)) return 3;
            return 4;
        }

        public LocalDate getFechaOrden() {
            try {
                return fecha == null || fecha.isEmpty() ? null : LocalDate.parse(fecha);
            } catch (Exception e) {
                return null;
            }
        }
    }
}
