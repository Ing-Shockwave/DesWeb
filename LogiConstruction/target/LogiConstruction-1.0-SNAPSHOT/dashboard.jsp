<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.utp.logiconstruction.modelo.Usuario"%>
<%@page import="com.utp.logiconstruction.dao.ReporteDAO"%>
<%@page import="com.utp.logiconstruction.util.AuthUtil"%>

<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");

    if (usuario == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String rol = usuario.getRol();
    boolean esAdministradorObra = AuthUtil.ADMINISTRADOR_OBRA.equals(rol);
    boolean esJefeLogistica = AuthUtil.JEFE_LOGISTICA.equals(rol);
    boolean esGerencia = AuthUtil.GERENCIA.equals(rol);
    String rolNombre = AuthUtil.nombreRol(rol);

    ReporteDAO dao = new ReporteDAO();

    int totalCompras = dao.contarCompras();
    int totalProveedores = dao.contarProveedoresActivos();
    int totalRequerimientos = dao.contarRequerimientos();
    String materialMasComprado = dao.obtenerMaterialMasComprado();
    String ultimaCompra = dao.obtenerUltimaCompra();
    String proveedorMasUsado = dao.obtenerProveedorMasUsado();
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">

    <title>Dashboard - LogiConstruction</title>

    <link rel="stylesheet"
    href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="css/estilos.css?v=chatbot2">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    
</head>

<body class="dash-page">

<div class="dash-sidebar">

    <div class="dash-logo">

        <div class="dash-logo-icon">
            <i class="fa-solid fa-helmet-safety"></i>
        </div>

        <div>
            <h2>Logi<span>Con</span></h2>
            <p>PRO VERSION</p>
        </div>

    </div>

    <nav class="dash-menu">

        <a class="activo" href="dashboard.jsp">
            <i class="fa-solid fa-chart-column"></i>
            Dashboard
        </a>

        <% if (esJefeLogistica) { %>
        <a href="compras.jsp">
            <i class="fa-solid fa-cart-shopping"></i>
            Compras
        </a>

        <a href="proveedores.jsp">
            <i class="fa-solid fa-users"></i>
            Proveedores
        </a>
        <% } %>

        <% if (esAdministradorObra || esJefeLogistica) { %>
        <a href="requerimientos.jsp">
            <i class="fa-solid fa-file-lines"></i>
            Requerimientos
        </a>
        <% } %>

        <% if (esAdministradorObra) { %>
        <a href="requerimientos-jsf.xhtml">
            <i class="fa-solid fa-code"></i>
            Demo JSF
        </a>
        <% } %>

        <% if (esGerencia) { %>
        <a href="reportes.jsp">
            <i class="fa-solid fa-chart-simple"></i>
            Reportes
        </a>
        <a href="analisisCostos.jsp">
            <i class="fa-solid fa-coins"></i>
            Análisis de costos
        </a>
        <a href="alertasGerenciales.jsp">
            <i class="fa-solid fa-triangle-exclamation"></i>
            Alertas gerenciales
        </a>
        <% } %>

    </nav>

    <div class="dash-user">
        <strong><%= usuario.getNombre() %></strong>
        <small>Rol: <%= rolNombre %></small>
        <small>Sesión activa</small>
    </div>

    <a class="dash-logout" href="LogoutServlet">
        <i class="fa-solid fa-right-from-bracket"></i>
        Cerrar Sesión
    </a>

</div>

<main class="dash-main">

    <header class="dash-header">

        <div>
            <h1>Panel de Gestión</h1>
            <p>Bienvenido de nuevo, <%= usuario.getNombre() %></p>
        </div>

        <div class="dash-search">
            <i class="fa-solid fa-magnifying-glass"></i>
            <input type="text" id="buscarDashboard" placeholder="Buscar en resumen...">
        </div>

    </header>

    <section class="dash-body">

        <div class="dash-hero">

            <div>
                <h2>Estado de Obra: Activo</h2>

                <p>
                    Tienes <%= totalRequerimientos %> requerimientos registrados,
                    <%= totalCompras %> órdenes de compra y
                    <%= totalProveedores %> proveedores activos.
                </p>

                <% if (esGerencia) { %>
                <a href="reportes.jsp">Ver reportes gerenciales</a>
                <% } else { %>
                <a href="requerimientos.jsp">Ver requerimientos</a>
                <% } %>
            </div>

            <div class="dash-watermark">
                <i class="fa-solid fa-truck-ramp-box"></i>
            </div>

        </div>

        <div class="dash-cards">

            <div class="dash-card">

                <div class="dash-card-icon orange">
                    <i class="fa-solid fa-cart-shopping"></i>
                </div>

                <h3>Compras</h3>

                <p>
                    Gestión de órdenes de compra,
                    seguimiento de pedidos y facturación.
                </p>

                <% if (esJefeLogistica) { %>
                <a href="compras.jsp">Gestionar ahora ›</a>
                <% } else { %><span class="dash-readonly">Consulta mediante reportes</span><% } %>

            </div>

            <div class="dash-card">

                <div class="dash-card-icon blue">
                    <i class="fa-solid fa-truck"></i>
                </div>

                <h3>Proveedores</h3>

                <p>
                    Administración de contactos,
                    evaluaciones y catálogo de materiales.
                </p>

                <% if (esJefeLogistica) { %>
                <a href="proveedores.jsp">Administrar lista ›</a>
                <% } else { %><span class="dash-readonly">Consulta mediante reportes</span><% } %>

            </div>

            <div class="dash-card">

                <div class="dash-card-icon green">
                    <i class="fa-solid fa-file-lines"></i>
                </div>

                <h3>Requerimientos</h3>

                <p>
                    Registro de necesidades de obra
                    y control de solicitudes internas.
                </p>

                <% if (esAdministradorObra || esJefeLogistica) { %>
                <a href="requerimientos.jsp">Revisar registros ›</a>
                <% } else { %><span class="dash-readonly">Consulta mediante reportes</span><% } %>

            </div>

            <div class="dash-card">

                <div class="dash-card-icon purple">
                    <i class="fa-solid fa-chart-pie"></i>
                </div>

                <h3>Reportes</h3>

                <p>
                    Visualización de KPIs,
                    costos y balances logísticos.
                </p>

                <% if (esGerencia) { %>
                <a href="reportes.jsp">Ver analíticas ›</a>
                <% } %>

            </div>

            <% if (esGerencia) { %>
            <div class="dash-card">
                <div class="dash-card-icon orange"><i class="fa-solid fa-coins"></i></div>
                <h3>Análisis de costos</h3>
                <p>Filtros, tendencias mensuales y detalle de gastos por proveedor.</p>
                <a href="analisisCostos.jsp">Analizar costos ›</a>
            </div>

            <div class="dash-card">
                <div class="dash-card-icon green"><i class="fa-solid fa-triangle-exclamation"></i></div>
                <h3>Alertas gerenciales</h3>
                <p>Seguimiento de requerimientos, compras y proveedores que requieren atención.</p>
                <a href="alertasGerenciales.jsp">Revisar alertas ›</a>
            </div>
            <% } %>

        </div>

        <div class="dash-table-card">

            <div class="dash-table-head">
                <h2>Resumen del Sistema</h2>
                <span>VER TODO</span>
            </div>

            <table class="dash-table" id="tablaDashboard">

                <tr>
                    <th>CÓDIGO</th>
                    <th>MÓDULO</th>
                    <th>TOTAL</th>
                    <th>ESTADO</th>
                    <th>PRIORIDAD</th>
                </tr>

                <tr>
                    <td>#MOD-001</td>
                    <td>Compras registradas</td>
                    <td><%= totalCompras %></td>
                    <td>
                        <span class="badge pending">ACTIVO</span>
                    </td>
                    <td>Alta</td>
                </tr>

                <tr>
                    <td>#MOD-002</td>
                    <td>Proveedores registrados</td>
                    <td><%= totalProveedores %></td>
                    <td>
                        <span class="badge approved">OPERATIVO</span>
                    </td>
                    <td>Media</td>
                </tr>

                <tr>
                    <td>#MOD-003</td>
                    <td>Requerimientos registrados</td>
                    <td><%= totalRequerimientos %></td>
                    <td>
                        <span class="badge pending">PENDIENTE</span>
                    </td>
                    <td>Alta</td>
                </tr>

            </table>

        </div>

    </section>

    <footer class="app-footer">
        LogiConstruction v1.0 | Sistema de Gestión Logística | Usuario: <%= usuario.getNombre() %>
    </footer>

</main>

<script>
document.getElementById('buscarDashboard').addEventListener('keyup', function() {
    const texto = this.value.toLowerCase();
    const filas = document.querySelectorAll('#tablaDashboard tr:not(:first-child)');

    filas.forEach(function(fila) {
        fila.style.display = fila.textContent.toLowerCase().includes(texto) ? '' : 'none';
    });
});
</script>


<% if ("denegado".equals(request.getParameter("acceso"))) { %>
<script>
Swal.fire({
    icon: 'warning',
    title: 'Acceso denegado',
    text: 'Tu rol no tiene permiso para ingresar a ese módulo.',
    background: '#0f172a',
    color: '#ffffff',
    confirmButtonColor: '#00c6ff'
});
</script>
<% } %>


<%@ include file="/WEB-INF/jspf/chatbot-widget.jspf" %>

<%@ include file="/WEB-INF/jspf/whatsapp-group-button.jspf" %>

</body>
</html>