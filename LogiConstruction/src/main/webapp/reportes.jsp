<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.utp.logiconstruction.dao.ReporteDAO"%>
<%@page import="com.utp.logiconstruction.modelo.Usuario"%>
<%@page import="com.utp.logiconstruction.util.AuthUtil"%>
<%@page import="java.util.List"%>

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

    if (!esGerencia) {
        response.sendRedirect("dashboard.jsp?acceso=denegado");
        return;
    }

    ReporteDAO dao = new ReporteDAO();

    int totalCompras = dao.contarCompras();
    int totalProveedores = dao.contarProveedores();
    int totalRequerimientos = dao.contarRequerimientos();

    List<String> materiales = dao.obtenerMaterialesMasComprados();

    String labels = "";
    String valores = "";

    for (int i = 0; i < materiales.size(); i += 2) {
        labels += "'" + materiales.get(i).replace("'", "\\'") + "'";
        valores += materiales.get(i + 1);

        if (i < materiales.size() - 2) {
            labels += ",";
            valores += ",";
        }
    }

    boolean hayDatos = materiales.size() > 0;
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">

    <title>Reportes - LogiConstruction</title>

    <link rel="icon" type="image/png" href="img/favicon.png">

    <link rel="stylesheet"
    href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

    <link rel="stylesheet" href="css/estilos.css?v=menu4">

    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>

<body class="rep-page">

<div class="rep-sidebar">

    <div class="rep-logo">
        <div class="rep-logo-icon">
            <i class="fa-solid fa-helmet-safety"></i>
        </div>

        <div>
            <h2>Logi<span>Con</span></h2>
            <p>PRO VERSION</p>
        </div>
    </div>

    <nav class="rep-menu">

        <a href="dashboard.jsp">
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

        <% if (esGerencia) { %>
        <a class="activo" href="reportes.jsp">
            <i class="fa-solid fa-chart-simple"></i>
            Reportes
        </a>
        <% } %>

    </nav>

    <div class="rep-user">
        <strong><%= usuario.getNombre() %></strong>
        <small>Rol: <%= rolNombre %></small>
        <small>Sesión activa</small>
    </div>

    <a class="rep-logout" href="LogoutServlet">
        <i class="fa-solid fa-right-from-bracket"></i>
        Cerrar Sesión
    </a>

</div>

<main class="rep-main">

    <header class="rep-header">

        <div>
            <h1>Módulo de Reportes</h1>
            <p>Resumen general y analíticas del sistema LogiConstruction.</p>
        </div>

        <div class="rep-top-buttons">

            <button>
                <i class="fa-solid fa-calendar"></i>
                Últimos 30 días
            </button>

            <button class="export-btn" onclick="window.print()">
                <i class="fa-solid fa-download"></i>
                Exportar Informe
            </button>

        </div>

    </header>

    <section class="rep-cards">

        <div class="rep-card">
            <div class="rep-card-top">
                <div class="rep-card-icon orange">
                    <i class="fa-solid fa-cart-shopping"></i>
                </div>

                <span class="rep-badge green">+12%</span>
            </div>

            <h3>Compras</h3>
            <div class="rep-number"><%= totalCompras %></div>
            <small>REGISTRADAS</small>

            <div class="rep-progress-text">
                <span>EFICIENCIA</span>
                <span><%= totalCompras > 0 ? "85%" : "0%" %></span>
            </div>

            <div class="rep-progress">
                <div class="rep-progress-fill orange-fill"
                     style="width:<%= totalCompras > 0 ? "85%" : "0%" %>;"></div>
            </div>
        </div>

        <div class="rep-card">
            <div class="rep-card-top">
                <div class="rep-card-icon blue">
                    <i class="fa-solid fa-users"></i>
                </div>

                <span class="rep-badge gray">Estable</span>
            </div>

            <h3>Proveedores</h3>
            <div class="rep-number"><%= totalProveedores %></div>
            <small>REGISTRADOS</small>

            <div class="rep-progress-text">
                <span>CALIFICACIÓN PROMEDIO</span>
                <span><%= totalProveedores > 0 ? "4.8/5" : "0/5" %></span>
            </div>

            <div class="rep-progress">
                <div class="rep-progress-fill blue-fill"
                     style="width:<%= totalProveedores > 0 ? "92%" : "0%" %>;"></div>
            </div>
        </div>

        <div class="rep-card">
            <div class="rep-card-top">
                <div class="rep-card-icon green">
                    <i class="fa-solid fa-file-lines"></i>
                </div>

                <span class="rep-badge orange-badge">Urgente</span>
            </div>

            <h3>Requerimientos</h3>
            <div class="rep-number"><%= totalRequerimientos %></div>
            <small>REGISTRADOS</small>

            <div class="rep-progress-text">
                <span>ATENCIÓN DE OBRA</span>
                <span><%= totalRequerimientos > 0 ? "40%" : "0%" %></span>
            </div>

            <div class="rep-progress">
                <div class="rep-progress-fill green-fill"
                     style="width:<%= totalRequerimientos > 0 ? "40%" : "0%" %>;"></div>
            </div>
        </div>

    </section>

    <section class="rep-chart-card">

        <div class="rep-chart-header">

            <div>
                <h2>Movimiento de Materiales</h2>
                <p>MATERIALES MÁS REGISTRADOS EN COMPRAS</p>
            </div>

        </div>

        <% if (hayDatos) { %>

        <div class="chart-container">
            <canvas id="categoriaChart"></canvas>
        </div>

        <% } else { %>

        <div class="rep-empty-chart">
            <i class="fa-solid fa-chart-column"></i>
            <p>No existen datos suficientes para generar estadísticas.</p>
        </div>

        <% } %>

    </section>

    <footer class="rep-footer">
        GENERADO: 14 MAYO 2026 - 03:00 AM
    </footer>

</main>

<% if (hayDatos) { %>
<script>
const ctxCategoria = document.getElementById('categoriaChart');

new Chart(ctxCategoria, {
    type: 'doughnut',

    data: {
        labels: [<%= labels %>],

        datasets: [{
            data: [<%= valores %>],

            backgroundColor: [
                '#f97316',
                '#3b82f6',
                '#10b981',
                '#facc15',
                '#8b5cf6'
            ],

            borderColor: '#101a2e',
            borderWidth: 6,
            hoverOffset: 12
        }]
    },

    options: {
        responsive: true,
        maintainAspectRatio: false,
        cutout: '62%',

        plugins: {
            legend: {
                position: 'right',

                labels: {
                    color: '#cbd5e1',

                    font: {
                        size: 14,
                        weight: 'bold'
                    },

                    padding: 22,
                    usePointStyle: true,
                    pointStyle: 'circle'
                }
            },

            tooltip: {
                backgroundColor: '#020817',
                titleColor: '#ffffff',
                bodyColor: '#cbd5e1',
                borderColor: '#334155',
                borderWidth: 1,
                padding: 12,

                callbacks: {
                    label: function(context) {
                        return context.label + ': ' + context.raw + ' registros';
                    }
                }
            }
        }
    }
});
</script>
<% } %>

</body>
</html>