package com.utp.logiconstruction.dao;

import com.utp.logiconstruction.conexion.Conexion;
import com.utp.logiconstruction.modelo.Compra;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class CompraDAO {

    public boolean registrarCompra(Compra compra) {
        String sql = "INSERT INTO compras(proveedor, producto, cantidad, estado, costo_unitario, observacion) "
                + "VALUES(?,?,?,?,?,?)";

        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql)) {

            asignarCampos(ps, compra, false);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean actualizarCompra(Compra compra) {
        String sql = "UPDATE compras SET proveedor=?, producto=?, cantidad=?, estado=?, "
                + "costo_unitario=?, observacion=? WHERE id=?";

        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql)) {

            asignarCampos(ps, compra, true);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Compra> listarCompras() {
        List<Compra> lista = new ArrayList<>();
        String sql = "SELECT id, proveedor, producto, cantidad, fecha, estado, costo_unitario, observacion "
                + "FROM compras ORDER BY id DESC";

        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Compra compra = new Compra();
                compra.setId(rs.getInt("id"));
                compra.setProveedor(rs.getString("proveedor"));
                compra.setProducto(rs.getString("producto"));
                compra.setCantidad(rs.getInt("cantidad"));
                compra.setFecha(rs.getTimestamp("fecha") == null
                        ? null : rs.getTimestamp("fecha").toString());
                compra.setEstado(rs.getString("estado"));
                compra.setCostoUnitario(rs.getBigDecimal("costo_unitario"));
                compra.setObservacion(rs.getString("observacion"));
                lista.add(compra);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return lista;
    }

    public boolean eliminarCompra(int id) {
        String sql = "DELETE FROM compras WHERE id = ?";

        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private void asignarCampos(PreparedStatement ps, Compra compra, boolean incluirId)
            throws SQLException {
        ps.setString(1, compra.getProveedor());
        ps.setString(2, compra.getProducto());
        ps.setInt(3, compra.getCantidad());
        ps.setString(4, compra.getEstado());
        ps.setBigDecimal(5, compra.getCostoUnitario());
        ps.setString(6, compra.getObservacion());
        if (incluirId) {
            ps.setInt(7, compra.getId());
        }
    }
}
