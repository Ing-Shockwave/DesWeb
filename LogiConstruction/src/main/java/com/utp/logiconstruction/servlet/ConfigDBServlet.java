package com.utp.logiconstruction.servlet;

import com.utp.logiconstruction.conexion.DatabaseConfig;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class ConfigDBServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("configuracion.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String jdbcUrl = request.getParameter("jdbcUrl");
        String dbUser = request.getParameter("dbUser");
        String dbPassword = request.getParameter("dbPassword");

        request.setAttribute("jdbcUrl", jdbcUrl);
        request.setAttribute("dbUser", dbUser);
        request.setAttribute("dbPassword", dbPassword);

        if (jdbcUrl == null || jdbcUrl.trim().isEmpty()
                || dbUser == null || dbUser.trim().isEmpty()) {
            request.setAttribute("error", "La URL JDBC y el usuario de MySQL son obligatorios.");
            request.getRequestDispatcher("configuracion.jsp").forward(request, response);
            return;
        }

        try (Connection connection = DatabaseConfig.probarConexion(jdbcUrl, dbUser, dbPassword)) {
            DatabaseConfig.guardarConfiguracion(jdbcUrl, dbUser, dbPassword);
            request.setAttribute("exito", "Conexión exitosa. La configuración fue guardada correctamente.");
        } catch (SQLException e) {
            request.setAttribute("error", "No se pudo conectar a MySQL: " + e.getMessage());
        }

        request.getRequestDispatcher("configuracion.jsp").forward(request, response);
    }
}
