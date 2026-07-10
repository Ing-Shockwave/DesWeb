package com.utp.logiconstruction.api;

import com.utp.logiconstruction.dao.ProveedorDAO;
import com.utp.logiconstruction.modelo.Proveedor;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "ProveedorApiServlet", urlPatterns = {"/api/proveedores"})
public class ProveedorApiServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        JsonUtil.prepararRespuestaJson(response);
        List<Proveedor> proveedores = new ProveedorDAO().listarProveedores();

        StringBuilder json = new StringBuilder();
        json.append("[");
        for (int i = 0; i < proveedores.size(); i++) {
            Proveedor p = proveedores.get(i);
            if (i > 0) {
                json.append(",");
            }
            json.append("{")
                    .append("\"id\":").append(p.getId()).append(",")
                    .append("\"nombre\":").append(JsonUtil.texto(p.getNombre())).append(",")
                    .append("\"ruc\":").append(JsonUtil.texto(p.getRuc())).append(",")
                    .append("\"telefono\":").append(JsonUtil.texto(p.getTelefono())).append(",")
                    .append("\"correo\":").append(JsonUtil.texto(p.getCorreo()))
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
