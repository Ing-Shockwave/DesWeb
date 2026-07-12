package com.utp.logiconstruction.servlet;

import com.utp.logiconstruction.dao.ProveedorDAO;
import com.utp.logiconstruction.modelo.Proveedor;
import com.utp.logiconstruction.util.AuthUtil;
import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import java.util.regex.Pattern;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/ProveedorServlet")
public class ProveedorServlet extends HttpServlet {

    private static final Pattern RUC_PATTERN = Pattern.compile("^[0-9]{11}$");
    private static final Pattern TELEFONO_PATTERN = Pattern.compile("^[0-9+()\\s-]{7,20}$");
    private static final Pattern CORREO_PATTERN = Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    private static final Set<String> ESTADOS = new HashSet<>(Arrays.asList("ACTIVO", "INACTIVO"));

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!AuthUtil.validarAcceso(request, response, AuthUtil.JEFE_LOGISTICA)) {
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String accion = limpiar(request.getParameter("accion"));
        ProveedorDAO dao = new ProveedorDAO();

        if ("eliminar".equals(accion)) {
            Integer id = convertirEntero(request.getParameter("id"));
            if (id == null || id <= 0) {
                redirigirError(response);
                return;
            }

            response.sendRedirect(dao.eliminarProveedor(id)
                    ? "proveedores.jsp?eliminado=1"
                    : "proveedores.jsp?error=bd");
            return;
        }

        Integer id = "actualizar".equals(accion)
                ? convertirEntero(request.getParameter("id")) : null;
        String nombre = limpiar(request.getParameter("nombre"));
        String ruc = limpiar(request.getParameter("ruc"));
        String telefono = limpiar(request.getParameter("telefono"));
        String correo = limpiar(request.getParameter("correo")).toLowerCase();
        String direccion = normalizarOpcional(request.getParameter("direccion"));
        String estado = limpiar(request.getParameter("estado")).toUpperCase();

        if (("actualizar".equals(accion) && (id == null || id <= 0))
                || !textoValido(nombre, 2, 100)
                || !RUC_PATTERN.matcher(ruc).matches()
                || !TELEFONO_PATTERN.matcher(telefono).matches()
                || !CORREO_PATTERN.matcher(correo).matches()
                || (direccion != null && direccion.length() > 150)
                || !ESTADOS.contains(estado)) {
            redirigirError(response);
            return;
        }

        Proveedor proveedor = new Proveedor(nombre, ruc, telefono, correo, direccion, estado);
        boolean correcto;

        if ("actualizar".equals(accion)) {
            proveedor.setId(id);
            correcto = dao.actualizarProveedor(proveedor);
            response.sendRedirect(correcto
                    ? "proveedores.jsp?actualizado=1"
                    : construirErrorDao(dao));
        } else {
            correcto = dao.registrarProveedor(proveedor);
            response.sendRedirect(correcto
                    ? "proveedores.jsp?ok=1"
                    : construirErrorDao(dao));
        }
    }

    private String construirErrorDao(ProveedorDAO dao) {
        String errorDao = dao.getUltimoError();
        if (errorDao != null && errorDao.toLowerCase().contains("duplicate")) {
            return "proveedores.jsp?error=duplicado";
        }
        return "proveedores.jsp?error=bd";
    }

    private void redirigirError(HttpServletResponse response) throws IOException {
        response.sendRedirect("proveedores.jsp?error=validacion");
    }

    private String limpiar(String valor) {
        return valor == null ? "" : valor.trim();
    }

    private String normalizarOpcional(String valor) {
        String limpio = limpiar(valor);
        return limpio.isEmpty() ? null : limpio;
    }

    private boolean textoValido(String valor, int minimo, int maximo) {
        return valor != null && valor.length() >= minimo && valor.length() <= maximo;
    }

    private Integer convertirEntero(String valor) {
        try {
            return Integer.valueOf(limpiar(valor));
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
