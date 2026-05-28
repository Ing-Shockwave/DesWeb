package com.utp.logiconstruction.dao;

import com.utp.logiconstruction.conexion.Conexion;
import com.utp.logiconstruction.modelo.Proveedor;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ProveedorDAO {

    public boolean registrarProveedor(Proveedor proveedor) {

        String sql = "INSERT INTO proveedores(nombre, ruc, telefono, correo) VALUES(?,?,?,?)";

        try (
            Connection con = Conexion.conectar();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setString(1, proveedor.getNombre());
            ps.setString(2, proveedor.getRuc());
            ps.setString(3, proveedor.getTelefono());
            ps.setString(4, proveedor.getCorreo());

            ps.executeUpdate();

            return true;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Proveedor> listarProveedores() {

        List<Proveedor> lista = new ArrayList<>();

        String sql = "SELECT * FROM proveedores ORDER BY id DESC";

        try (
            Connection con = Conexion.conectar();
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {

            while (rs.next()) {
                Proveedor proveedor = new Proveedor();

                proveedor.setId(rs.getInt("id"));
                proveedor.setNombre(rs.getString("nombre"));
                proveedor.setRuc(rs.getString("ruc"));
                proveedor.setTelefono(rs.getString("telefono"));
                proveedor.setCorreo(rs.getString("correo"));

                lista.add(proveedor);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return lista;
    }
    
    public boolean eliminarProveedor(int id) {

    String sql = "DELETE FROM proveedores WHERE id = ?";

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