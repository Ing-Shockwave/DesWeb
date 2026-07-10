package com.utp.logiconstruction.servlet;

import com.utp.logiconstruction.dao.ProveedorDAO;
import com.utp.logiconstruction.modelo.Proveedor;
import com.utp.logiconstruction.util.AuthUtil;
import java.io.IOException;
import java.util.regex.Pattern;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/ProveedorServlet")
public class ProveedorServlet extends HttpServlet {

    private static final Pattern RUC_PATTERN = Pattern.compile("^[0-9]{1,11}$");
    private static final Pattern TELEFONO_PATTERN = Pattern.compile("^[0-9+()\\s-]{7,20}$");
    private static final Pattern CORREO_PATTERN = Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!AuthUtil.validarAcceso(request, response, AuthUtil.JEFE_LOGISTICA)) {
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String accion = request.getParameter("accion");
        ProveedorDAO dao = new ProveedorDAO();

        if ("eliminar".equals(accion)) {
            Integer id = convertirEntero(request.getParameter("id"));
            if (id == null || id <= 0) {
                response.sendRedirect("proveedores.jsp?error=validacion");
                return;
            }

            dao.eliminarProveedor(id);
            response.sendRedirect("proveedores.jsp?eliminado=1");
            return;
        }

        String nombre = limpiar(request.getParameter("nombre"));
        String ruc = limpiar(request.getParameter("ruc"));
        String telefono = limpiar(request.getParameter("telefono"));
        String correo = limpiar(request.getParameter("correo")).toLowerCase();

        if (!nombreValido(nombre)
                || !RUC_PATTERN.matcher(ruc).matches()
                || !TELEFONO_PATTERN.matcher(telefono).matches()
                || !CORREO_PATTERN.matcher(correo).matches()) {
            response.sendRedirect("proveedores.jsp?error=validacion");
            return;
        }

        Proveedor proveedor = new Proveedor(nombre, ruc, telefono, correo);
        boolean registrado = dao.registrarProveedor(proveedor);

        if (registrado) {
            response.sendRedirect("proveedores.jsp?ok=1");
        } else {
            String errorDao = dao.getUltimoError();

            if (errorDao != null && errorDao.toLowerCase().contains("duplicate")) {
                response.sendRedirect("proveedores.jsp?error=duplicado");
            } else {
                response.sendRedirect("proveedores.jsp?error=bd");
            }
        }
    }

    private String limpiar(String valor) {
        return valor == null ? "" : valor.trim();
    }

    private boolean nombreValido(String valor) {
        return valor != null && valor.length() >= 2 && valor.length() <= 100;
    }

    private Integer convertirEntero(String valor) {
        try {
            return Integer.parseInt(limpiar(valor));
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
