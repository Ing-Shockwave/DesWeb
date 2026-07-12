package com.utp.logiconstruction.api;

import com.utp.logiconstruction.dao.CompraDAO;
import com.utp.logiconstruction.modelo.Compra;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "CompraApiServlet", urlPatterns = {"/api/compras"})
public class CompraApiServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        JsonUtil.prepararRespuestaJson(response);
        List<Compra> compras = new CompraDAO().listarCompras();

        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < compras.size(); i++) {
            Compra c = compras.get(i);
            if (i > 0) json.append(',');
            json.append('{')
                    .append("\"id\":").append(c.getId()).append(',')
                    .append("\"proveedor\":").append(JsonUtil.texto(c.getProveedor())).append(',')
                    .append("\"producto\":").append(JsonUtil.texto(c.getProducto())).append(',')
                    .append("\"cantidad\":").append(c.getCantidad()).append(',')
                    .append("\"fecha\":").append(JsonUtil.texto(c.getFecha())).append(',')
                    .append("\"estado\":").append(JsonUtil.texto(c.getEstado())).append(',')
                    .append("\"costoUnitario\":").append(c.getCostoUnitario() == null ? "0" : c.getCostoUnitario()).append(',')
                    .append("\"costoTotal\":").append(c.getCostoTotal()).append(',')
                    .append("\"observacion\":").append(JsonUtil.texto(c.getObservacion()))
                    .append('}');
        }
        json.append(']');

        try (PrintWriter out = response.getWriter()) {
            out.print(json);
        }
    }

    @Override
    protected void doOptions(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        JsonUtil.prepararRespuestaJson(response);
        response.setStatus(HttpServletResponse.SC_OK);
    }
}
