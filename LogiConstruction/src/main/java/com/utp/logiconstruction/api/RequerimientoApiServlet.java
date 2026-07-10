package com.utp.logiconstruction.api;

import com.utp.logiconstruction.dao.RequerimientoDAO;
import com.utp.logiconstruction.modelo.Requerimiento;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "RequerimientoApiServlet", urlPatterns = {"/api/requerimientos"})
public class RequerimientoApiServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        JsonUtil.prepararRespuestaJson(response);
        List<Requerimiento> requerimientos = new RequerimientoDAO().listarRequerimientos();

        StringBuilder json = new StringBuilder();
        json.append("[");
        for (int i = 0; i < requerimientos.size(); i++) {
            Requerimiento r = requerimientos.get(i);
            if (i > 0) {
                json.append(",");
            }
            json.append("{")
                    .append("\"id\":").append(r.getId()).append(",")
                    .append("\"nombre\":").append(JsonUtil.texto(r.getNombre())).append(",")
                    .append("\"area\":").append(JsonUtil.texto(r.getArea())).append(",")
                    .append("\"cantidad\":").append(r.getCantidad()).append(",")
                    .append("\"fecha\":").append(JsonUtil.texto(r.getFecha()))
                    .append("}");
        }
        json.append("]");

        try (PrintWriter out = response.getWriter()) {
            out.print(json.toString());
        }
    }

    @Override
    protected void doOptions(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        JsonUtil.prepararRespuestaJson(response);
        response.setStatus(HttpServletResponse.SC_OK);
    }
}
