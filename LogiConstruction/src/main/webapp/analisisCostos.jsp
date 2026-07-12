<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.utp.logiconstruction.api.JsonUtil"%>
<%@page import="com.utp.logiconstruction.dao.AnalisisGerencialDAO"%>
<%@page import="com.utp.logiconstruction.dao.AnalisisGerencialDAO.ResumenCostos"%>
<%@page import="com.utp.logiconstruction.dao.AnalisisGerencialDAO.DatoGrafico"%>
<%@page import="com.utp.logiconstruction.dao.AnalisisGerencialDAO.CompraDetalle"%>
<%@page import="com.utp.logiconstruction.modelo.Usuario"%>
<%@page import="com.utp.logiconstruction.util.AuthUtil"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="java.time.LocalDate"%>
<%@page import="java.time.LocalDateTime"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Locale"%>

<%!
    private String escaparHtml(String valor) {
        if (valor == null) return "";
        return valor.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private String moneda(BigDecimal valor) {
        BigDecimal seguro = valor == null ? BigDecimal.ZERO : valor;
        return String.format(Locale.US, "S/ %,.2f", seguro);
    }

    private LocalDate fechaSegura(String valor) {
        try {
            return valor == null || valor.trim().isEmpty() ? null : LocalDate.parse(valor.trim());
        } catch (Exception e) {
            return null;
        }
    }
%>

<%
    response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String rol = usuario.getRol();
    boolean esGerencia = AuthUtil.GERENCIA.equals(rol);
    String rolNombre = AuthUtil.nombreRol(rol);
    if (!esGerencia) {
        response.sendRedirect("dashboard.jsp?acceso=denegado");
        return;
    }

    String desdeTexto = request.getParameter("desde") == null ? "" : request.getParameter("desde").trim();
    String hastaTexto = request.getParameter("hasta") == null ? "" : request.getParameter("hasta").trim();
    String proveedorFiltro = request.getParameter("proveedor") == null ? "" : request.getParameter("proveedor").trim();
    String productoFiltro = request.getParameter("producto") == null ? "" : request.getParameter("producto").trim();
    String estadoFiltro = request.getParameter("estado") == null ? "" : request.getParameter("estado").trim().toUpperCase();

    if (!(estadoFiltro.isEmpty() || "REGISTRADA".equals(estadoFiltro)
            || "RECIBIDA".equals(estadoFiltro) || "ANULADA".equals(estadoFiltro))) {
        estadoFiltro = "";
    }

    LocalDate desde = fechaSegura(desdeTexto);
    LocalDate hasta = fechaSegura(hastaTexto);
    boolean rangoInvalido = desde != null && hasta != null && desde.isAfter(hasta);
    if (rangoInvalido) {
        LocalDate temporal = desde;
        desde = hasta;
        hasta = temporal;
        desdeTexto = desde.toString();
        hastaTexto = hasta.toString();
    }

    AnalisisGerencialDAO dao = new AnalisisGerencialDAO();
    ResumenCostos resumen = dao.obtenerResumen(desde, hasta, proveedorFiltro, productoFiltro, estadoFiltro);
    List<DatoGrafico> gastoMensual = dao.obtenerGastoMensual(desde, hasta, proveedorFiltro, productoFiltro, estadoFiltro);
    List<DatoGrafico> gastoProveedores = dao.obtenerGastoPorProveedor(desde, hasta, proveedorFiltro, productoFiltro, estadoFiltro);
    List<DatoGrafico> estados = dao.obtenerDistribucionEstados(desde, hasta, proveedorFiltro, productoFiltro, estadoFiltro);
    List<CompraDetalle> compras = dao.listarCompras(desde, hasta, proveedorFiltro, productoFiltro, estadoFiltro);
    List<String> proveedores = dao.listarProveedoresConCompras();

    StringBuilder mesesLabels = new StringBuilder("[");
    StringBuilder mesesValores = new StringBuilder("[");
    for (int i = 0; i < gastoMensual.size(); i++) {
        if (i > 0) { mesesLabels.append(','); mesesValores.append(','); }
        mesesLabels.append(JsonUtil.texto(gastoMensual.get(i).getEtiqueta()));
        mesesValores.append(gastoMensual.get(i).getValor().toPlainString());
    }
    mesesLabels.append(']');
    mesesValores.append(']');

    StringBuilder proveedoresLabels = new StringBuilder("[");
    StringBuilder proveedoresValores = new StringBuilder("[");
    for (int i = 0; i < gastoProveedores.size(); i++) {
        if (i > 0) { proveedoresLabels.append(','); proveedoresValores.append(','); }
        proveedoresLabels.append(JsonUtil.texto(gastoProveedores.get(i).getEtiqueta()));
        proveedoresValores.append(gastoProveedores.get(i).getValor().toPlainString());
    }
    proveedoresLabels.append(']');
    proveedoresValores.append(']');

    StringBuilder estadosLabels = new StringBuilder("[");
    StringBuilder estadosValores = new StringBuilder("[");
    for (int i = 0; i < estados.size(); i++) {
        if (i > 0) { estadosLabels.append(','); estadosValores.append(','); }
        estadosLabels.append(JsonUtil.texto(estados.get(i).getEtiqueta()));
        estadosValores.append(estados.get(i).getValor().toPlainString());
    }
    estadosLabels.append(']');
    estadosValores.append(']');

    DateTimeFormatter formatoFecha = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    String fechaActualizacion = LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss"));
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Análisis de costos - LogiConstruction</title>
    <link rel="icon" type="image/png" href="img/favicon.png">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.8/css/jquery.dataTables.min.css">
    <link rel="stylesheet" href="css/estilos.css?v=gerencia-costos1">
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.8/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body class="rep-page gerencia-page">

<div class="rep-sidebar">
    <div class="rep-logo">
        <div class="rep-logo-icon"><i class="fa-solid fa-helmet-safety"></i></div>
        <div><h2>Logi<span>Con</span></h2><p>PRO VERSION</p></div>
    </div>

    <nav class="rep-menu">
        <a href="dashboard.jsp"><i class="fa-solid fa-chart-column"></i> Dashboard</a>
        <a href="reportes.jsp"><i class="fa-solid fa-chart-simple"></i> Reportes</a>
        <a class="activo" href="analisisCostos.jsp"><i class="fa-solid fa-coins"></i> Análisis de costos</a>
        <a href="alertasGerenciales.jsp"><i class="fa-solid fa-triangle-exclamation"></i> Alertas gerenciales</a>
    </nav>

    <div class="rep-user">
        <strong><%= escaparHtml(usuario.getNombre()) %></strong>
        <small>Rol: <%= escaparHtml(rolNombre) %></small>
        <small>Sesión activa</small>
    </div>
    <a class="rep-logout" href="LogoutServlet"><i class="fa-solid fa-right-from-bracket"></i> Cerrar Sesión</a>
</div>

<main class="rep-main gerencia-main">
    <header class="rep-header gerencia-header">
        <div>
            <h1>Análisis de costos y compras</h1>
            <p>Consulta gerencial de gastos, tendencias y compras registradas.</p>
        </div>
        <div class="rep-top-buttons">
            <button type="button" onclick="window.location.reload()"><i class="fa-solid fa-rotate"></i> Actualizar</button>
            <button type="button" class="export-btn" onclick="window.print()"><i class="fa-solid fa-file-pdf"></i> Exportar</button>
        </div>
    </header>

    <section class="gerencia-content">
        <div class="gerencia-filter-card">
            <div class="gerencia-card-title">
                <div><h2><i class="fa-solid fa-filter"></i> Filtros de análisis</h2><p>Los montos excluyen las compras anuladas.</p></div>
                <small>Actualizado: <%= fechaActualizacion %></small>
            </div>
            <% if (rangoInvalido) { %>
            <div class="gerencia-notice"><i class="fa-solid fa-circle-info"></i> Las fechas se ordenaron automáticamente porque el rango estaba invertido.</div>
            <% } %>
            <form method="get" action="analisisCostos.jsp" class="gerencia-filter-grid">
                <label>Desde<input type="date" name="desde" value="<%= escaparHtml(desdeTexto) %>"></label>
                <label>Hasta<input type="date" name="hasta" value="<%= escaparHtml(hastaTexto) %>"></label>
                <label>Proveedor
                    <select name="proveedor">
                        <option value="">Todos</option>
                        <% for (String proveedor : proveedores) { %>
                        <option value="<%= escaparHtml(proveedor) %>" <%= proveedor.equals(proveedorFiltro) ? "selected" : "" %>><%= escaparHtml(proveedor) %></option>
                        <% } %>
                    </select>
                </label>
                <label>Estado
                    <select name="estado">
                        <option value="">Todos</option>
                        <option value="REGISTRADA" <%= "REGISTRADA".equals(estadoFiltro) ? "selected" : "" %>>Registrada</option>
                        <option value="RECIBIDA" <%= "RECIBIDA".equals(estadoFiltro) ? "selected" : "" %>>Recibida</option>
                        <option value="ANULADA" <%= "ANULADA".equals(estadoFiltro) ? "selected" : "" %>>Anulada</option>
                    </select>
                </label>
                <label class="gerencia-filter-producto">Producto<input type="text" name="producto" maxlength="100" value="<%= escaparHtml(productoFiltro) %>" placeholder="Ejemplo: cemento"></label>
                <div class="gerencia-filter-actions">
                    <button type="submit"><i class="fa-solid fa-magnifying-glass"></i> Aplicar</button>
                    <a href="analisisCostos.jsp"><i class="fa-solid fa-eraser"></i> Limpiar</a>
                </div>
            </form>
        </div>

        <div class="gerencia-summary-grid">
            <article class="gerencia-summary-card summary-orange">
                <div class="gerencia-summary-icon"><i class="fa-solid fa-sack-dollar"></i></div>
                <div><span>Gasto acumulado</span><strong><%= moneda(resumen.getCostoTotal()) %></strong><small>Sin compras anuladas</small></div>
            </article>
            <article class="gerencia-summary-card summary-blue">
                <div class="gerencia-summary-icon"><i class="fa-solid fa-cart-flatbed"></i></div>
                <div><span>Compras consideradas</span><strong><%= resumen.getComprasValidas() %></strong><small><%= resumen.getTotalRegistros() %> registros filtrados</small></div>
            </article>
            <article class="gerencia-summary-card summary-green">
                <div class="gerencia-summary-icon"><i class="fa-solid fa-calculator"></i></div>
                <div><span>Costo promedio</span><strong><%= moneda(resumen.getCostoPromedio()) %></strong><small>Por compra válida</small></div>
            </article>
            <article class="gerencia-summary-card summary-purple">
                <div class="gerencia-summary-icon"><i class="fa-solid fa-arrow-trend-up"></i></div>
                <div><span>Compra de mayor valor</span><strong><%= moneda(resumen.getCompraMayor()) %></strong><small>Dentro del filtro aplicado</small></div>
            </article>
        </div>

        <div class="gerencia-chart-grid">
            <article class="gerencia-chart-card chart-wide">
                <div class="gerencia-card-title"><div><h2>Evolución del gasto</h2><p>Monto acumulado por mes.</p></div><i class="fa-solid fa-chart-line"></i></div>
                <div class="gerencia-canvas"><canvas id="graficoMensual"></canvas></div>
            </article>
            <article class="gerencia-chart-card">
                <div class="gerencia-card-title"><div><h2>Gasto por proveedor</h2><p>Los siete principales.</p></div><i class="fa-solid fa-truck"></i></div>
                <div class="gerencia-canvas"><canvas id="graficoProveedores"></canvas></div>
            </article>
            <article class="gerencia-chart-card">
                <div class="gerencia-card-title"><div><h2>Estados de compra</h2><p>Distribución de registros.</p></div><i class="fa-solid fa-chart-pie"></i></div>
                <div class="gerencia-canvas"><canvas id="graficoEstados"></canvas></div>
            </article>
        </div>

        <div class="gerencia-table-card">
            <div class="gerencia-card-title">
                <div><h2><i class="fa-solid fa-table-list"></i> Detalle de compras</h2><p>Información de consulta; Gerencia no modifica los registros.</p></div>
                <div class="gerencia-table-search"><i class="fa-solid fa-magnifying-glass"></i><input id="buscarAnalisis" type="text" placeholder="Buscar en la tabla..."></div>
            </div>
            <div class="table-scroll">
                <table id="tablaAnalisis" class="gerencia-table tabla-datatables">
                    <thead><tr><th>ID</th><th>Fecha</th><th>Proveedor</th><th>Producto</th><th>Cantidad</th><th>Costo unitario</th><th>Total</th><th>Estado</th></tr></thead>
                    <tbody>
                    <% for (CompraDetalle compra : compras) {
                        String estado = compra.getEstado() == null ? "REGISTRADA" : compra.getEstado().toUpperCase();
                        String claseEstado = "estado-registrada";
                        if ("RECIBIDA".equals(estado)) claseEstado = "estado-recibida";
                        if ("ANULADA".equals(estado)) claseEstado = "estado-anulada";
                    %>
                    <tr>
                        <td>#CMP-<%= compra.getId() %></td>
                        <td><%= compra.getFecha() == null ? "" : compra.getFecha().toLocalDateTime().format(formatoFecha) %></td>
                        <td><%= escaparHtml(compra.getProveedor()) %></td>
                        <td><%= escaparHtml(compra.getProducto()) %></td>
                        <td><%= compra.getCantidad() %></td>
                        <td><%= moneda(compra.getCostoUnitario()) %></td>
                        <td><strong><%= moneda(compra.getCostoTotal()) %></strong></td>
                        <td><span class="estado-crud <%= claseEstado %>"><%= escaparHtml(estado) %></span></td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </section>

    <footer class="app-footer">LogiConstruction v1.0 | Vista de solo lectura | Usuario: <%= escaparHtml(usuario.getNombre()) %></footer>
</main>

<script>
const mesesLabels = <%= mesesLabels.toString() %>;
const mesesValores = <%= mesesValores.toString() %>;
const proveedoresLabels = <%= proveedoresLabels.toString() %>;
const proveedoresValores = <%= proveedoresValores.toString() %>;
const estadosLabels = <%= estadosLabels.toString() %>;
const estadosValores = <%= estadosValores.toString() %>;

const textoComun = {color:'#cbd5e1', font:{family:'Inter, Arial, sans-serif'}};
const rejillaComun = {color:'rgba(148,163,184,.13)'};

new Chart(document.getElementById('graficoMensual'), {
    type:'line',
    data:{labels:mesesLabels,datasets:[{label:'Gasto (S/)',data:mesesValores,borderColor:'#f97316',backgroundColor:'rgba(249,115,22,.16)',fill:true,tension:.35,pointRadius:4}]},
    options:{responsive:true,maintainAspectRatio:false,plugins:{legend:{labels:textoComun}},scales:{x:{ticks:textoComun,grid:rejillaComun},y:{beginAtZero:true,ticks:{...textoComun,callback:v=>'S/ '+Number(v).toLocaleString('es-PE')},grid:rejillaComun}}}
});

new Chart(document.getElementById('graficoProveedores'), {
    type:'bar',
    data:{labels:proveedoresLabels,datasets:[{label:'Gasto (S/)',data:proveedoresValores,backgroundColor:'rgba(59,130,246,.72)',borderRadius:7}]},
    options:{responsive:true,maintainAspectRatio:false,indexAxis:'y',plugins:{legend:{display:false}},scales:{x:{beginAtZero:true,ticks:{...textoComun,callback:v=>'S/ '+Number(v).toLocaleString('es-PE')},grid:rejillaComun},y:{ticks:textoComun,grid:{display:false}}}}
});

new Chart(document.getElementById('graficoEstados'), {
    type:'doughnut',
    data:{labels:estadosLabels,datasets:[{data:estadosValores,backgroundColor:['#f59e0b','#22c55e','#ef4444'],borderColor:'#111827',borderWidth:3}]},
    options:{responsive:true,maintainAspectRatio:false,cutout:'66%',plugins:{legend:{position:'bottom',labels:textoComun}}}
});

const idiomaTabla = {emptyTable:'No hay compras para los filtros seleccionados',info:'Mostrando _START_ a _END_ de _TOTAL_',infoEmpty:'Mostrando 0 registros',infoFiltered:'(filtrado de _MAX_)',zeroRecords:'No se encontraron coincidencias',paginate:{next:'Siguiente',previous:'Anterior'}};
$(function(){
    const tabla=$('#tablaAnalisis').DataTable({pageLength:8,lengthChange:false,autoWidth:false,dom:'rtip',order:[[1,'desc']],language:idiomaTabla});
    $('#buscarAnalisis').on('keyup',function(){tabla.search(this.value).draw();});
});
</script>
<%@ include file="/WEB-INF/jspf/chatbot-widget.jspf" %>
<%@ include file="/WEB-INF/jspf/whatsapp-group-button.jspf" %>
</body>
</html>
