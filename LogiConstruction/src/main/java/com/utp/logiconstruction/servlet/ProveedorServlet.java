package com.utp.logiconstruction.servlet;

import com.utp.logiconstruction.dao.ProveedorDAO;
import com.utp.logiconstruction.modelo.Proveedor;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/ProveedorServlet")
public class ProveedorServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String accion = request.getParameter("accion");

        ProveedorDAO dao = new ProveedorDAO();

        if ("eliminar".equals(accion)) {

            int id = Integer.parseInt(request.getParameter("id"));
            dao.eliminarProveedor(id);

            response.sendRedirect("proveedores.jsp");
            return;
        }

        String nombre = request.getParameter("nombre");
        String ruc = request.getParameter("ruc");
        String telefono = request.getParameter("telefono");
        String correo = request.getParameter("correo");

        Proveedor proveedor = new Proveedor(nombre, ruc, telefono, correo);

        boolean registrado = dao.registrarProveedor(proveedor);

        if (registrado) {
            response.sendRedirect("proveedores.jsp?ok=1");
        } else {
            response.sendRedirect("proveedores.jsp?error=1");
        }
    }
}