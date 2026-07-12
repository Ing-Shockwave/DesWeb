package com.utp.logiconstruction.servlet;

import com.utp.logiconstruction.dao.RequerimientoDAO;
import com.utp.logiconstruction.modelo.Requerimiento;
import com.utp.logiconstruction.modelo.Usuario;
import com.utp.logiconstruction.util.AuthUtil;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/RequerimientoServlet")
public class RequerimientoServlet extends HttpServlet {

    private static final int MAX_TEXTO = 100;
    private static final int MAX_OBSERVACION = 255;
    private static final int MAX_CANTIDAD = 1_000_000;
    private static final Set<String> ESTADOS = new HashSet<>(Arrays.asList(
            "PENDIENTE", "APROBADO", "RECHAZADO", "ATENDIDO"
    ));

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!AuthUtil.validarAcceso(request, response,
                AuthUtil.ADMINISTRADOR_OBRA, AuthUtil.JEFE_LOGISTICA)) {
            return;
        }

        request.setCharacterEncoding("UTF-8");
        RequerimientoDAO dao = new RequerimientoDAO();
        String accion = limpiar(request.getParameter("accion"));

        if ("eliminar".equals(accion)) {
            Integer id = convertirEntero(request.getParameter("id"));
            if (id == null || id <= 0) {
                redirigirError(response);
                return;
            }

            response.sendRedirect(dao.eliminarRequerimiento(id)
                    ? "requerimientos.jsp?eliminado=1"
                    : "requerimientos.jsp?error=bd");
            return;
        }

        Integer id = "actualizar".equals(accion)
                ? convertirEntero(request.getParameter("id")) : null;
        String nombre = limpiar(request.getParameter("nombre"));
        String area = limpiar(request.getParameter("area"));
        Integer cantidad = convertirEntero(request.getParameter("cantidad"));
        String fecha = limpiar(request.getParameter("fecha"));
        String observacion = normalizarOpcional(request.getParameter("observacion"));
        String estadoSolicitado = limpiar(request.getParameter("estado")).toUpperCase();

        if (("actualizar".equals(accion) && (id == null || id <= 0))
                || !textoValido(nombre) || !textoValido(area)
                || cantidad == null || cantidad < 1 || cantidad > MAX_CANTIDAD
                || !fechaValida(fecha)
                || (observacion != null && observacion.length() > MAX_OBSERVACION)) {
            redirigirError(response);
            return;
        }

        String estado = "PENDIENTE";
        if ("actualizar".equals(accion)) {
            Usuario usuario = AuthUtil.obtenerUsuario(request);
            if (AuthUtil.tieneRol(usuario, AuthUtil.JEFE_LOGISTICA)) {
                if (!ESTADOS.contains(estadoSolicitado)) {
                    redirigirError(response);
                    return;
                }
                estado = estadoSolicitado;
            } else {
                Requerimiento actual = dao.obtenerRequerimiento(id);
                if (actual == null) {
                    response.sendRedirect("requerimientos.jsp?error=bd");
                    return;
                }
                estado = actual.getEstado();
            }
        }

        Requerimiento requerimiento = new Requerimiento(
                nombre, area, cantidad, fecha, estado, observacion
        );

        if ("actualizar".equals(accion)) {
            requerimiento.setId(id);
            response.sendRedirect(dao.actualizarRequerimiento(requerimiento)
                    ? "requerimientos.jsp?actualizado=1"
                    : "requerimientos.jsp?error=bd");
        } else {
            response.sendRedirect(dao.registrarRequerimiento(requerimiento)
                    ? "requerimientos.jsp?ok=1"
                    : "requerimientos.jsp?error=bd");
        }
    }

    private void redirigirError(HttpServletResponse response) throws IOException {
        response.sendRedirect("requerimientos.jsp?error=validacion");
    }

    private String limpiar(String valor) {
        return valor == null ? "" : valor.trim();
    }

    private String normalizarOpcional(String valor) {
        String limpio = limpiar(valor);
        return limpio.isEmpty() ? null : limpio;
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
            return Integer.valueOf(limpiar(valor));
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
