package com.utp.logiconstruction.servlet;

import com.utp.logiconstruction.dao.CompraDAO;
import com.utp.logiconstruction.modelo.Compra;
import com.utp.logiconstruction.util.AuthUtil;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/CompraServlet")
public class CompraServlet extends HttpServlet {

    private static final int MAX_TEXTO = 100;
    private static final int MAX_CANTIDAD = 1000000;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!AuthUtil.validarAcceso(request, response, AuthUtil.JEFE_LOGISTICA)) {
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String accion = request.getParameter("accion");
        CompraDAO dao = new CompraDAO();

        if ("eliminar".equals(accion)) {
            Integer id = convertirEntero(request.getParameter("id"));
            if (id == null || id <= 0) {
                response.sendRedirect("compras.jsp?error=validacion");
                return;
            }

            dao.eliminarCompra(id);
            response.sendRedirect("compras.jsp?eliminado=1");
            return;
        }

        String proveedor = limpiar(request.getParameter("proveedor"));
        String producto = limpiar(request.getParameter("producto"));
        Integer cantidad = convertirEntero(request.getParameter("cantidad"));

        if (!textoValido(proveedor) || !textoValido(producto)
                || cantidad == null || cantidad < 1 || cantidad > MAX_CANTIDAD) {
            response.sendRedirect("compras.jsp?error=validacion");
            return;
        }

        Compra compra = new Compra(proveedor, producto, cantidad);
        boolean registrado = dao.registrarCompra(compra);

        if (registrado) {
            response.sendRedirect("compras.jsp?ok=1");
        } else {
            response.sendRedirect("compras.jsp?error=bd");
        }
    }

    private String limpiar(String valor) {
        return valor == null ? "" : valor.trim();
    }

    private boolean textoValido(String valor) {
        return valor != null && valor.length() >= 2 && valor.length() <= MAX_TEXTO;
    }

    private Integer convertirEntero(String valor) {
        try {
            return Integer.parseInt(limpiar(valor));
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
