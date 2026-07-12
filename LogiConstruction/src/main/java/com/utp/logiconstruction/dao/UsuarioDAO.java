package com.utp.logiconstruction.dao;

import com.utp.logiconstruction.conexion.Conexion;
import com.utp.logiconstruction.modelo.Usuario;
import com.utp.logiconstruction.util.PasswordUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UsuarioDAO {

    public Usuario validarLogin(String correo, String passwordIngresada) {
        String sql = "SELECT id_usuario, nombre, correo, password, rol "
                + "FROM usuarios WHERE correo = ? AND estado = 'ACTIVO' LIMIT 1";

        try (Connection con = Conexion.conectar();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, correo == null ? "" : correo.trim().toLowerCase());

            int idUsuario;
            String nombre;
            String correoBD;
            String rol;
            String passwordAlmacenada;

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }

                idUsuario = rs.getInt("id_usuario");
                nombre = rs.getString("nombre");
                correoBD = rs.getString("correo");
                rol = rs.getString("rol");
                passwordAlmacenada = rs.getString("password");
            }

            if (!PasswordUtil.verificar(passwordIngresada, passwordAlmacenada)) {
                return null;
            }

            // Migra automáticamente contraseñas de instalaciones antiguas
            // que aún estuvieran en texto plano.
            if (!PasswordUtil.esFormatoSeguro(passwordAlmacenada)) {
                actualizarPasswordSegura(con, idUsuario,
                        PasswordUtil.generarHash(passwordIngresada));
            }

            return new Usuario(idUsuario, nombre, correoBD, rol);
        } catch (Exception e) {
            System.out.println("Error en validarLogin: " + e.getMessage());
            return null;
        }
    }

    private void actualizarPasswordSegura(Connection con, int idUsuario, String passwordHash)
            throws SQLException {
        String sql = "UPDATE usuarios SET password = ? WHERE id_usuario = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, passwordHash);
            ps.setInt(2, idUsuario);
            ps.executeUpdate();
        }
    }
}
