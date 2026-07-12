<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.utp.logiconstruction.dao.AlertaGerencialDAO"%>
<%@page import="com.utp.logiconstruction.dao.AlertaGerencialDAO.Alerta"%>
<%@page import="com.utp.logiconstruction.dao.AlertaGerencialDAO.ResumenAlertas"%>
<%@page import="com.utp.logiconstruction.modelo.Usuario"%>
<%@page import="com.utp.logiconstruction.util.AuthUtil"%>
<%@page import="java.math.BigDecimal"%>
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

    private String monedaAlerta(BigDecimal valor) {
        if (valor == null || valor.compareTo(BigDecimal.ZERO) <= 0) return "";
        return String.format(Locale.US, "S/ %,.2f", valor);
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

    AlertaGerencialDAO dao = new AlertaGerencialDAO();
    List<Alerta> alertas = dao.listarAlertas();
    ResumenAlertas resumen = dao.obtenerResumen(alertas);
    String fechaActualizacion = LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss"));
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Alertas gerenciales - LogiConstruction</title>
    <link rel="icon" type="image/png" href="img/favicon.png">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="css/estilos.css?v=gerencia-alertas1">
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
        <a href="analisisCostos.jsp"><i class="fa-solid fa-coins"></i> Análisis de costos</a>
        <a class="activo" href="alertasGerenciales.jsp"><i class="fa-solid fa-triangle-exclamation"></i> Alertas gerenciales</a>
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
            <h1>Alertas y seguimiento gerencial</h1>
            <p>Situaciones detectadas automáticamente en requerimientos, compras y proveedores.</p>
        </div>
        <div class="rep-top-buttons">
            <button type="button" onclick="window.location.reload()"><i class="fa-solid fa-rotate"></i> Actualizar</button>
            <button type="button" class="export-btn" onclick="window.print()"><i class="fa-solid fa-file-pdf"></i> Exportar</button>
        </div>
    </header>

    <section class="gerencia-content">
        <div class="alertas-status-bar">
            <div><i class="fa-solid fa-clock-rotate-left"></i><span>Última actualización</span><strong><%= fechaActualizacion %></strong></div>
            <div><i class="fa-solid fa-shield-halved"></i><span>Modo</span><strong>Solo lectura</strong></div>
            <div><i class="fa-solid fa-list-check"></i><span>Total de avisos</span><strong id="totalAlertasVisible"><%= resumen.getTotal() %></strong></div>
        </div>

        <div class="gerencia-summary-grid alertas-summary-grid">
            <article class="gerencia-summary-card alerta-card-critica" data-nivel-card="CRITICA">
                <div class="gerencia-summary-icon"><i class="fa-solid fa-circle-exclamation"></i></div>
                <div><span>Críticas</span><strong><%= resumen.getCriticas() %></strong><small>Atención inmediata</small></div>
            </article>
            <article class="gerencia-summary-card alerta-card-alta" data-nivel-card="ALTA">
                <div class="gerencia-summary-icon"><i class="fa-solid fa-triangle-exclamation"></i></div>
                <div><span>Altas</span><strong><%= resumen.getAltas() %></strong><small>Revisión prioritaria</small></div>
            </article>
            <article class="gerencia-summary-card alerta-card-media" data-nivel-card="MEDIA">
                <div class="gerencia-summary-icon"><i class="fa-solid fa-bell"></i></div>
                <div><span>Medias</span><strong><%= resumen.getMedias() %></strong><small>Seguimiento preventivo</small></div>
            </article>
            <article class="gerencia-summary-card alerta-card-info" data-nivel-card="INFORMATIVA">
                <div class="gerencia-summary-icon"><i class="fa-solid fa-circle-info"></i></div>
                <div><span>Informativas</span><strong><%= resumen.getInformativas() %></strong><small>Resumen operativo</small></div>
            </article>
        </div>

        <div class="gerencia-filter-card alertas-filter-card">
            <div class="gerencia-card-title">
                <div><h2><i class="fa-solid fa-filter"></i> Filtrar alertas</h2><p>La clasificación se calcula con la antigüedad, el estado y el monto registrado.</p></div>
            </div>
            <div class="alertas-filter-grid">
                <label>Nivel
                    <select id="filtroNivelAlerta">
                        <option value="">Todos</option>
                        <option value="CRITICA">Crítica</option>
                        <option value="ALTA">Alta</option>
                        <option value="MEDIA">Media</option>
                        <option value="INFORMATIVA">Informativa</option>
                    </select>
                </label>
                <label>Tipo
                    <select id="filtroTipoAlerta">
                        <option value="">Todos</option>
                        <option value="REQUERIMIENTO">Requerimiento</option>
                        <option value="COMPRA">Compra</option>
                        <option value="PROVEEDOR">Proveedor</option>
                        <option value="RESUMEN">Resumen</option>
                        <option value="SISTEMA">Sistema</option>
                    </select>
                </label>
                <label class="alertas-search-label">Buscar
                    <div class="gerencia-table-search"><i class="fa-solid fa-magnifying-glass"></i><input id="buscarAlerta" type="text" placeholder="Referencia, detalle o estado..."></div>
                </label>
                <button type="button" id="limpiarAlertas"><i class="fa-solid fa-eraser"></i> Limpiar</button>
            </div>
        </div>

        <div class="gerencia-table-card alertas-table-card">
            <div class="gerencia-card-title">
                <div><h2><i class="fa-solid fa-radar"></i> Bandeja de seguimiento</h2><p>Ordenada de mayor a menor prioridad.</p></div>
                <span class="alertas-counter"><strong id="contadorFiltrado"><%= resumen.getTotal() %></strong> visibles</span>
            </div>
            <div class="table-scroll">
                <table class="gerencia-table alertas-table" id="tablaAlertas">
                    <thead><tr><th>Nivel</th><th>Tipo</th><th>Referencia</th><th>Descripción</th><th>Fecha / Antigüedad</th><th>Monto</th><th>Estado</th></tr></thead>
                    <tbody>
                    <% for (Alerta alerta : alertas) {
                        String claseNivel = alerta.getNivel().toLowerCase();
                        String icono = "fa-circle-info";
                        if ("CRITICA".equals(alerta.getNivel())) icono = "fa-circle-exclamation";
                        else if ("ALTA".equals(alerta.getNivel())) icono = "fa-triangle-exclamation";
                        else if ("MEDIA".equals(alerta.getNivel())) icono = "fa-bell";
                    %>
                    <tr data-nivel="<%= escaparHtml(alerta.getNivel()) %>" data-tipo="<%= escaparHtml(alerta.getTipo()) %>">
                        <td><span class="alerta-nivel nivel-<%= claseNivel %>"><i class="fa-solid <%= icono %>"></i> <%= escaparHtml(alerta.getNivel()) %></span></td>
                        <td><span class="alerta-tipo"><%= escaparHtml(alerta.getTipo()) %></span></td>
                        <td><strong><%= escaparHtml(alerta.getReferencia()) %></strong></td>
                        <td class="alerta-descripcion"><%= escaparHtml(alerta.getDescripcion()) %></td>
                        <td><%= escaparHtml(alerta.getFecha()) %><% if (alerta.getDias() > 0) { %><small><%= alerta.getDias() %> día(s)</small><% } %></td>
                        <td><%= escaparHtml(monedaAlerta(alerta.getMonto())) %></td>
                        <td><span class="alerta-estado"><%= escaparHtml(alerta.getEstado()) %></span></td>
                    </tr>
                    <% } %>
                    <tr id="sinAlertasFiltradas" style="display:none"><td colspan="7" class="alertas-empty"><i class="fa-solid fa-filter-circle-xmark"></i> No hay alertas que coincidan con los filtros.</td></tr>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="alertas-rules-card">
            <i class="fa-solid fa-circle-info"></i>
            <div><strong>Reglas de seguimiento</strong><p>Los requerimientos pendientes o aprobados aumentan de prioridad según sus días de antigüedad. Las compras registradas consideran antigüedad y monto; los proveedores se alertan cuando están inactivos o tienen información incompleta.</p></div>
        </div>
    </section>

    <footer class="app-footer">LogiConstruction v1.0 | Alertas calculadas desde MySQL | Usuario: <%= escaparHtml(usuario.getNombre()) %></footer>
</main>

<script>
const filasAlertas = Array.from(document.querySelectorAll('#tablaAlertas tbody tr[data-nivel]'));
const nivel = document.getElementById('filtroNivelAlerta');
const tipo = document.getElementById('filtroTipoAlerta');
const buscar = document.getElementById('buscarAlerta');
const contador = document.getElementById('contadorFiltrado');
const totalVisible = document.getElementById('totalAlertasVisible');
const vacio = document.getElementById('sinAlertasFiltradas');

function aplicarFiltrosAlertas(){
    const n = nivel.value;
    const t = tipo.value;
    const q = buscar.value.trim().toLowerCase();
    let visibles = 0;
    filasAlertas.forEach(fila => {
        const coincideNivel = !n || fila.dataset.nivel === n;
        const coincideTipo = !t || fila.dataset.tipo === t;
        const coincideTexto = !q || fila.textContent.toLowerCase().includes(q);
        const mostrar = coincideNivel && coincideTipo && coincideTexto;
        fila.style.display = mostrar ? '' : 'none';
        if (mostrar) visibles++;
    });
    contador.textContent = visibles;
    totalVisible.textContent = visibles;
    vacio.style.display = visibles === 0 ? '' : 'none';
}

nivel.addEventListener('change', aplicarFiltrosAlertas);
tipo.addEventListener('change', aplicarFiltrosAlertas);
buscar.addEventListener('input', aplicarFiltrosAlertas);
document.getElementById('limpiarAlertas').addEventListener('click', () => {
    nivel.value=''; tipo.value=''; buscar.value=''; aplicarFiltrosAlertas();
});

document.querySelectorAll('[data-nivel-card]').forEach(card => card.addEventListener('click', () => {
    nivel.value = card.dataset.nivelCard;
    aplicarFiltrosAlertas();
    document.getElementById('tablaAlertas').scrollIntoView({behavior:'smooth',block:'start'});
}));
</script>
<%@ include file="/WEB-INF/jspf/chatbot-widget.jspf" %>
<%@ include file="/WEB-INF/jspf/whatsapp-group-button.jspf" %>
</body>
</html>
