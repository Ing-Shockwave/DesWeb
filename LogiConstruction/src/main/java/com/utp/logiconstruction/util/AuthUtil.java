package com.utp.logiconstruction.util;

import com.utp.logiconstruction.modelo.Usuario;
import java.io.IOException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class AuthUtil {

    public static final String ADMINISTRADOR_OBRA = "ADMINISTRADOR_OBRA";
    public static final String JEFE_LOGISTICA = "JEFE_LOGISTICA";
    public static final String GERENCIA = "GERENCIA";

    private AuthUtil() {
    }

    public static Usuario obtenerUsuario(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }
        Object usuarioSesion = session.getAttribute("usuario");
        if (usuarioSesion instanceof Usuario) {
            return (Usuario) usuarioSesion;
        }
        return null;
    }

    public static boolean tieneRol(Usuario usuario, String... rolesPermitidos) {
        if (usuario == null || usuario.getRol() == null) {
            return false;
        }

        for (String rol : rolesPermitidos) {
            if (usuario.getRol().equals(rol)) {
                return true;
            }
        }
        return false;
    }

    public static boolean validarAcceso(HttpServletRequest request, HttpServletResponse response,
            String... rolesPermitidos) throws IOException {

        Usuario usuario = obtenerUsuario(request);

        if (usuario == null) {
            response.sendRedirect("login.jsp");
            return false;
        }

        if (!tieneRol(usuario, rolesPermitidos)) {
            response.sendRedirect("dashboard.jsp?acceso=denegado");
            return false;
        }

        return true;
    }

    public static String nombreRol(String rol) {
        if (ADMINISTRADOR_OBRA.equals(rol)) {
            return "Administrador de Obra";
        }
        if (JEFE_LOGISTICA.equals(rol)) {
            return "Jefe de Logística";
        }
        if (GERENCIA.equals(rol)) {
            return "Gerencia";
        }
        return rol == null ? "Sin rol" : rol;
    }
}
