package com.utp.logiconstruction.servlet;

import com.utp.logiconstruction.conexion.DatabaseConfig;
import com.utp.logiconstruction.dao.UsuarioDAO;
import com.utp.logiconstruction.modelo.Usuario;
import java.io.IOException;
import java.sql.Connection;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "LoginServlet", urlPatterns = {"/LoginServlet"})
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String correo = limpiar(request.getParameter("correo")).toLowerCase();
        String password = request.getParameter("password");

        if (correo.isEmpty() || password == null || password.isEmpty()) {
            response.sendRedirect("login.jsp?error=1");
            return;
        }

        try (Connection connection = DatabaseConfig.probarConexionActual()) {
            // Conexión correcta. Se continúa con el login.
        } catch (Exception e) {
            System.out.println("Error de conexión a MySQL desde LoginServlet: " + e.getMessage());
            response.sendRedirect("configuracion.jsp?dbError=1");
            return;
        }

        Usuario usuario = new UsuarioDAO().validarLogin(correo, password);

        if (usuario != null) {
            // Evita reutilizar un identificador de sesión previo al login.
            HttpSession anterior = request.getSession(false);
            if (anterior != null) {
                anterior.invalidate();
            }

            HttpSession sesion = request.getSession(true);
            sesion.setMaxInactiveInterval(30 * 60);
            sesion.setAttribute("usuario", usuario);
            response.sendRedirect("dashboard.jsp");
        } else {
            response.sendRedirect("login.jsp?error=1");
        }
    }

    private String limpiar(String valor) {
        return valor == null ? "" : valor.trim();
    }
}
