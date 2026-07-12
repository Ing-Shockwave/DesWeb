package com.utp.logiconstruction.servlet;

import com.utp.logiconstruction.dao.CompraDAO;
import com.utp.logiconstruction.modelo.Compra;
import com.utp.logiconstruction.util.AuthUtil;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/CompraServlet")
public class CompraServlet extends HttpServlet {

    private static final int MAX_TEXTO = 100;
    private static final int MAX_CANTIDAD = 1_000_000;
    private static final BigDecimal MAX_COSTO = new BigDecimal("99999999.99");
    private static final Set<String> ESTADOS = new HashSet<>(Arrays.asList(
            "REGISTRADA", "RECIBIDA", "ANULADA"
    ));

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!AuthUtil.validarAcceso(request, response, AuthUtil.JEFE_LOGISTICA)) {
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String accion = limpiar(request.getParameter("accion"));
        CompraDAO dao = new CompraDAO();

        if ("eliminar".equals(accion)) {
            Integer id = convertirEntero(request.getParameter("id"));
            if (id == null || id <= 0) {
                redirigirError(response);
                return;
            }

            response.sendRedirect(dao.eliminarCompra(id)
                    ? "compras.jsp?eliminado=1"
                    : "compras.jsp?error=bd");
            return;
        }

        Integer id = "actualizar".equals(accion)
                ? convertirEntero(request.getParameter("id")) : null;
        String proveedor = limpiar(request.getParameter("proveedor"));
        String producto = limpiar(request.getParameter("producto"));
        Integer cantidad = convertirEntero(request.getParameter("cantidad"));
        String estado = limpiar(request.getParameter("estado")).toUpperCase();
        BigDecimal costoUnitario = convertirDecimal(request.getParameter("costoUnitario"));

        if (("actualizar".equals(accion) && (id == null || id <= 0))
                || !textoValido(proveedor, MAX_TEXTO)
                || !textoValido(producto, MAX_TEXTO)
                || cantidad == null || cantidad < 1 || cantidad > MAX_CANTIDAD
                || !ESTADOS.contains(estado)
                || costoUnitario == null || costoUnitario.compareTo(BigDecimal.ZERO) < 0
                || costoUnitario.compareTo(MAX_COSTO) > 0) {
            redirigirError(response);
            return;
        }

        Compra compra = new Compra(proveedor, producto, cantidad, estado,
                costoUnitario, null);

        boolean correcto;
        if ("actualizar".equals(accion)) {
            compra.setId(id);
            correcto = dao.actualizarCompra(compra);
            response.sendRedirect(correcto
                    ? "compras.jsp?actualizado=1"
                    : "compras.jsp?error=bd");
        } else {
            correcto = dao.registrarCompra(compra);
            response.sendRedirect(correcto
                    ? "compras.jsp?ok=1"
                    : "compras.jsp?error=bd");
        }
    }

    private void redirigirError(HttpServletResponse response) throws IOException {
        response.sendRedirect("compras.jsp?error=validacion");
    }

    private String limpiar(String valor) {
        return valor == null ? "" : valor.trim();
    }

    private boolean textoValido(String valor, int maximo) {
        return valor != null && valor.length() >= 2 && valor.length() <= maximo;
    }

    private Integer convertirEntero(String valor) {
        try {
            return Integer.valueOf(limpiar(valor));
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private BigDecimal convertirDecimal(String valor) {
        try {
            return new BigDecimal(limpiar(valor).replace(',', '.'));
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
