package com.utp.logiconstruction.servlet;

import com.utp.logiconstruction.dao.CompraDAO;
import com.utp.logiconstruction.modelo.Compra;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/CompraServlet")
public class CompraServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String accion = request.getParameter("accion");

        CompraDAO dao = new CompraDAO();

        if ("eliminar".equals(accion)) {

            int id = Integer.parseInt(request.getParameter("id"));

            dao.eliminarCompra(id);

            response.sendRedirect("compras.jsp");

            return;
        }

        String proveedor = request.getParameter("proveedor");
        String producto = request.getParameter("producto");
        int cantidad = Integer.parseInt(request.getParameter("cantidad"));

        Compra compra = new Compra(proveedor, producto, cantidad);

        boolean registrado = dao.registrarCompra(compra);

        if (registrado) {
            response.sendRedirect("compras.jsp?ok=1");
        } else {
            response.sendRedirect("compras.jsp?error=1");
        }
    }
}