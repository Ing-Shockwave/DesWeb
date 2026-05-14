package com.utp.logiconstruction.dao;

import com.utp.logiconstruction.conexion.Conexion;
import com.utp.logiconstruction.modelo.Usuario;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class UsuarioDAO {

    public Usuario validarLogin(String correo, String password) {
        Usuario usuario = null;

        String sql = "SELECT * FROM usuarios WHERE correo = ? AND password = ?";

        try {
            Connection con = Conexion.conectar();
            PreparedStatement ps = con.prepareStatement(sql);

            ps.setString(1, correo);
            ps.setString(2, password);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                usuario = new Usuario();
                usuario.setIdUsuario(rs.getInt("id_usuario"));
                usuario.setNombre(rs.getString("nombre"));
                usuario.setCorreo(rs.getString("correo"));
                usuario.setPassword(rs.getString("password"));
                usuario.setRol(rs.getString("rol"));
            }

            rs.close();
            ps.close();
            con.close();

        } catch (Exception e) {
            System.out.println("Error en validarLogin: " + e.getMessage());
        }

        return usuario;
    }
}