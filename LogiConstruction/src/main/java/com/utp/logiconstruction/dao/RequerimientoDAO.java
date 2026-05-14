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

        String sql = "INSERT INTO requerimientos(nombre, area, cantidad, fecha) VALUES(?,?,?,?)";

        try (
            Connection con = Conexion.conectar();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setString(1, r.getNombre());
            ps.setString(2, r.getArea());
            ps.setInt(3, r.getCantidad());
            ps.setString(4, r.getFecha());

            ps.executeUpdate();

            return true;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Requerimiento> listarRequerimientos() {

        List<Requerimiento> lista = new ArrayList<>();

        String sql = "SELECT * FROM requerimientos ORDER BY id DESC";

        try (
            Connection con = Conexion.conectar();
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {

            while (rs.next()) {
                Requerimiento r = new Requerimiento();

                r.setId(rs.getInt("id"));
                r.setNombre(rs.getString("nombre"));
                r.setArea(rs.getString("area"));
                r.setCantidad(rs.getInt("cantidad"));
                r.setFecha(rs.getString("fecha"));

                lista.add(r);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return lista;
    }
    
    public boolean eliminarRequerimiento(int id) {
    String sql = "DELETE FROM requerimientos WHERE id = ?";

    try (
        Connection con = Conexion.conectar();
        PreparedStatement ps = con.prepareStatement(sql)
    ) {
        ps.setInt(1, id);
        ps.executeUpdate();
        return true;

    } catch (SQLException e) {
        e.printStackTrace();
        return false;
    }
}
}