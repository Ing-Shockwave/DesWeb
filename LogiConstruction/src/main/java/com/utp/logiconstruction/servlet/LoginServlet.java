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

        String correo = request.getParameter("correo");
        String password = request.getParameter("password");

        // Primero se valida la conexión. Si falla, se envía al usuario a configurar MySQL.
        try (Connection connection = DatabaseConfig.probarConexionActual()) {
            // Conexión correcta. Se continúa con el login.
        } catch (Exception e) {
            System.out.println("Error de conexión a MySQL desde LoginServlet: " + e.getMessage());
            response.sendRedirect("configuracion.jsp?dbError=1");
            return;
        }

        UsuarioDAO usuarioDAO = new UsuarioDAO();
        Usuario usuario = usuarioDAO.validarLogin(correo, password);

        if (usuario != null) {
            HttpSession sesion = request.getSession();
            sesion.setAttribute("usuario", usuario);
            response.sendRedirect("dashboard.jsp");
        } else {
            response.sendRedirect("login.jsp?error=1");
        }
    }
}
