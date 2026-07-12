package com.utp.logiconstruction.dao;

import com.utp.logiconstruction.conexion.Conexion;
import com.utp.logiconstruction.modelo.Requerimiento;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class RequerimientoDAO {

    public boolean registrarRequerimiento(Requerimiento r) {
        String sql = "INSERT INTO requerimientos(nombre, area, cantidad, fecha, estado, observacion) "
                + "VALUES(?,?,?,?,?,?)";

        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql)) {

            asignarCampos(ps, r, false);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean actualizarRequerimiento(Requerimiento r) {
        String sql = "UPDATE requerimientos SET nombre=?, area=?, cantidad=?, fecha=?, estado=?, observacion=? "
                + "WHERE id=?";

        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql)) {

            asignarCampos(ps, r, true);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public Requerimiento obtenerRequerimiento(int id) {
        String sql = "SELECT id, nombre, area, cantidad, fecha, estado, observacion "
                + "FROM requerimientos WHERE id=?";

        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapear(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Requerimiento> listarRequerimientos() {
        List<Requerimiento> lista = new ArrayList<>();
        String sql = "SELECT id, nombre, area, cantidad, fecha, estado, observacion "
                + "FROM requerimientos ORDER BY id DESC";

        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                lista.add(mapear(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return lista;
    }

    public boolean eliminarRequerimiento(int id) {
        String sql = "DELETE FROM requerimientos WHERE id = ?";

        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private void asignarCampos(PreparedStatement ps, Requerimiento r, boolean incluirId)
            throws SQLException {
        ps.setString(1, r.getNombre());
        ps.setString(2, r.getArea());
        ps.setInt(3, r.getCantidad());
        ps.setString(4, r.getFecha());
        ps.setString(5, r.getEstado());
        ps.setString(6, r.getObservacion());
        if (incluirId) {
            ps.setInt(7, r.getId());
        }
    }

    private Requerimiento mapear(ResultSet rs) throws SQLException {
        Requerimiento r = new Requerimiento();
        r.setId(rs.getInt("id"));
        r.setNombre(rs.getString("nombre"));
        r.setArea(rs.getString("area"));
        r.setCantidad(rs.getInt("cantidad"));
        r.setFecha(rs.getString("fecha"));
        r.setEstado(rs.getString("estado"));
        r.setObservacion(rs.getString("observacion"));
        return r;
    }
}
