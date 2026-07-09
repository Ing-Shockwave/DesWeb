package com.utp.logiconstruction.servlet;

import com.utp.logiconstruction.dao.RequerimientoDAO;
import com.utp.logiconstruction.modelo.Requerimiento;
import com.utp.logiconstruction.util.AuthUtil;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/RequerimientoServlet")
public class RequerimientoServlet extends HttpServlet {

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
            int id = Integer.parseInt(request.getParameter("id"));
            boolean eliminado = dao.eliminarRequerimiento(id);

            if (eliminado) {
                response.sendRedirect("requerimientos.jsp?eliminado=1");
            } else {
                response.sendRedirect("requerimientos.jsp?error=1");
            }
            return;
        }

        String nombre = request.getParameter("nombre");
        String area = request.getParameter("area");
        int cantidad = Integer.parseInt(request.getParameter("cantidad"));
        String fecha = request.getParameter("fecha");

        Requerimiento requerimiento = new Requerimiento(nombre, area, cantidad, fecha);
        boolean registrado = dao.registrarRequerimiento(requerimiento);

        if (registrado) {
            response.sendRedirect("requerimientos.jsp?ok=1");
        } else {
            response.sendRedirect("requerimientos.jsp?error=1");
        }
    }
}
