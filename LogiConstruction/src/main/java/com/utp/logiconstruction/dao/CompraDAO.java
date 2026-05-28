package com.utp.logiconstruction.dao;

import com.utp.logiconstruction.conexion.Conexion;
import com.utp.logiconstruction.modelo.Compra;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class CompraDAO {

    public boolean registrarCompra(Compra compra) {

        String sql = "INSERT INTO compras(proveedor, producto, cantidad) VALUES(?,?,?)";

        try (
            Connection con = Conexion.conectar();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setString(1, compra.getProveedor());
            ps.setString(2, compra.getProducto());
            ps.setInt(3, compra.getCantidad());

            ps.executeUpdate();

            return true;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public java.util.List<Compra> listarCompras() {

        java.util.List<Compra> lista = new java.util.ArrayList<>();

        String sql = "SELECT * FROM compras ORDER BY id DESC";

        try (
            Connection con = Conexion.conectar();
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {

            while (rs.next()) {

                Compra compra = new Compra();

                compra.setId(rs.getInt("id"));
                compra.setProveedor(rs.getString("proveedor"));
                compra.setProducto(rs.getString("producto"));
                compra.setCantidad(rs.getInt("cantidad"));

                lista.add(compra);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return lista;
    }

    public boolean eliminarCompra(int id) {

        String sql = "DELETE FROM compras WHERE id = ?";

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