package com.utp.logiconstruction.servlet;

import com.utp.logiconstruction.dao.RequerimientoDAO;
import com.utp.logiconstruction.modelo.Requerimiento;
import com.utp.logiconstruction.util.AuthUtil;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/RequerimientoServlet")
public class RequerimientoServlet extends HttpServlet {

    private static final int MAX_TEXTO = 100;
    private static final int MAX_CANTIDAD = 1000000;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!AuthUtil.validarAcceso(request, response,
                AuthUtil.ADMINISTRADOR_OBRA, AuthUtil.JEFE_LOGISTICA)) {
            return;
        }

        request.setCharacterEncoding("UTF-8");
        RequerimientoDAO dao = new RequerimientoDAO();
        String accion = request.getParameter("accion");

        if ("eliminar".equals(accion)) {
            Integer id = convertirEntero(request.getParameter("id"));
            if (id == null || id <= 0) {
                response.sendRedirect("requerimientos.jsp?error=validacion");
                return;
            }

            boolean eliminado = dao.eliminarRequerimiento(id);

            if (eliminado) {
                response.sendRedirect("requerimientos.jsp?eliminado=1");
            } else {
                response.sendRedirect("requerimientos.jsp?error=bd");
            }
            return;
        }

        String nombre = limpiar(request.getParameter("nombre"));
        String area = limpiar(request.getParameter("area"));
        Integer cantidad = convertirEntero(request.getParameter("cantidad"));
        String fecha = limpiar(request.getParameter("fecha"));

        if (!textoValido(nombre) || !textoValido(area)
                || cantidad == null || cantidad < 1 || cantidad > MAX_CANTIDAD
                || !fechaValida(fecha)) {
            response.sendRedirect("requerimientos.jsp?error=validacion");
            return;
        }

        Requerimiento requerimiento = new Requerimiento(nombre, area, cantidad, fecha);
        boolean registrado = dao.registrarRequerimiento(requerimiento);

        if (registrado) {
            response.sendRedirect("requerimientos.jsp?ok=1");
        } else {
            response.sendRedirect("requerimientos.jsp?error=bd");
        }
    }

    private String limpiar(String valor) {
        return valor == null ? "" : valor.trim();
    }

    private boolean textoValido(String valor) {
        return valor != null && valor.length() >= 2 && valor.length() <= MAX_TEXTO;
    }

    private boolean fechaValida(String fecha) {
        try {
            LocalDate.parse(fecha);
            return true;
        } catch (DateTimeParseException | NullPointerException e) {
            return false;
        }
    }

    private Integer convertirEntero(String valor) {
        try {
            return Integer.parseInt(limpiar(valor));
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
