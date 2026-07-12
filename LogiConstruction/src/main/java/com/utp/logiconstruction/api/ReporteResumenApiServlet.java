package com.utp.logiconstruction.api;

import com.utp.logiconstruction.dao.ReporteDAO;
import com.utp.logiconstruction.modelo.Usuario;
import com.utp.logiconstruction.util.AuthUtil;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "ReporteResumenApiServlet", urlPatterns = {"/api/reportes/resumen"})
public class ReporteResumenApiServlet extends HttpServlet {

    private static final DateTimeFormatter FECHA_FORMATO
            = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        prepararRespuesta(response);

        Usuario usuario = AuthUtil.obtenerUsuario(request);
        if (usuario == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            escribirError(response, "La sesión ha expirado.");
            return;
        }

        if (!AuthUtil.tieneRol(usuario, AuthUtil.GERENCIA)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            escribirError(response, "No cuenta con permisos para consultar los reportes.");
            return;
        }

        ReporteDAO dao = new ReporteDAO();

        int totalCompras = dao.contarCompras();
        int comprasRecibidas = dao.contarComprasRecibidas();
        int totalProveedores = dao.contarProveedores();
        int proveedoresActivos = dao.contarProveedoresActivos();

        int totalRequerimientos = dao.contarRequerimientos();
        int requerimientosPendientes = dao.contarRequerimientosPendientes();
        int requerimientosAprobados = dao.contarRequerimientosAprobados();
        int requerimientosRechazados = dao.contarRequerimientosRechazados();
        int requerimientosAtendidos = dao.contarRequerimientosAtendidos();
        int requerimientosResueltos = dao.contarRequerimientosResueltos();
        int requerimientosPorResolver = dao.contarRequerimientosPorResolver();

        int porcentajeComprasRecibidas = porcentaje(comprasRecibidas, totalCompras);
        int porcentajeProveedoresActivos = porcentaje(proveedoresActivos, totalProveedores);
        int porcentajeRequerimientosResueltos = porcentaje(requerimientosResueltos, totalRequerimientos);

        BigDecimal costoTotal = dao.obtenerCostoTotalCompras();
        List<String> materiales = dao.obtenerMaterialesMasComprados();

        StringBuilder json = new StringBuilder(768);
        json.append('{')
                .append("\"totalCompras\":").append(totalCompras).append(',')
                .append("\"comprasRecibidas\":").append(comprasRecibidas).append(',')
                .append("\"porcentajeComprasRecibidas\":").append(porcentajeComprasRecibidas).append(',')
                .append("\"totalProveedores\":").append(totalProveedores).append(',')
                .append("\"proveedoresActivos\":").append(proveedoresActivos).append(',')
                .append("\"porcentajeProveedoresActivos\":").append(porcentajeProveedoresActivos).append(',')
                .append("\"totalRequerimientos\":").append(totalRequerimientos).append(',')
                .append("\"requerimientosPendientes\":").append(requerimientosPendientes).append(',')
                .append("\"requerimientosAprobados\":").append(requerimientosAprobados).append(',')
                .append("\"requerimientosRechazados\":").append(requerimientosRechazados).append(',')
                .append("\"requerimientosAtendidos\":").append(requerimientosAtendidos).append(',')
                .append("\"requerimientosResueltos\":").append(requerimientosResueltos).append(',')
                .append("\"requerimientosPorResolver\":").append(requerimientosPorResolver).append(',')
                .append("\"porcentajeRequerimientosResueltos\":").append(porcentajeRequerimientosResueltos).append(',')
                .append("\"costoTotalCompras\":").append(costoTotal.toPlainString()).append(',')
                .append("\"fechaActualizacion\":").append(JsonUtil.texto(LocalDateTime.now().format(FECHA_FORMATO))).append(',')
                .append("\"materiales\":[");

        for (int i = 0; i + 1 < materiales.size(); i += 2) {
            if (i > 0) {
                json.append(',');
            }
            json.append('{')
                    .append("\"nombre\":").append(JsonUtil.texto(materiales.get(i))).append(',')
                    .append("\"cantidad\":").append(materiales.get(i + 1))
                    .append('}');
        }

        json.append("]}");

        try (PrintWriter out = response.getWriter()) {
            out.print(json);
        }
    }

    private int porcentaje(int parte, int total) {
        return total <= 0 ? 0 : (int) Math.round(parte * 100.0 / total);
    }

    private void prepararRespuesta(HttpServletResponse response) {
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
    }

    private void escribirError(HttpServletResponse response, String mensaje) throws IOException {
        try (PrintWriter out = response.getWriter()) {
            out.print("{\"error\":" + JsonUtil.texto(mensaje) + "}");
        }
    }
}
