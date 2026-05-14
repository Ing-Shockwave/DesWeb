<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.utp.logiconstruction.dao.ReporteDAO"%>

<%
    ReporteDAO dao = new ReporteDAO();

    int totalCompras = dao.contarCompras();
    int totalProveedores = dao.contarProveedores();
    int totalRequerimientos = dao.contarRequerimientos();

    boolean hayDatos = totalCompras > 0 || totalRequerimientos > 0;
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">

    <title>Reportes - LogiConstruction</title>

    <link rel="stylesheet"
    href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

    <link rel="stylesheet" href="css/estilos.css">
</head>

<body class="rep-page">

<div class="rep-sidebar">

    <div class="rep-logo">
        <div class="rep-logo-icon">
            <i class="fa-solid fa-helmet-safety"></i>
        </div>

        <div>
            <h2>Logi<span>Con</span></h2>
        </div>
    </div>

    <nav class="rep-menu">

        <a href="dashboard.jsp">
            <i class="fa-solid fa-chart-column"></i>
            Dashboard
        </a>

        <a href="compras.jsp">
            <i class="fa-solid fa-cart-shopping"></i>
            Compras
        </a>

        <a href="proveedores.jsp">
            <i class="fa-solid fa-users"></i>
            Proveedores
        </a>

        <a href="requerimientos.jsp">
            <i class="fa-solid fa-file-lines"></i>
            Requerimientos
        </a>

        <a class="activo" href="reportes.jsp">
            <i class="fa-solid fa-chart-simple"></i>
            Reportes
        </a>

    </nav>

    <a class="rep-logout" href="login.jsp">
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
                <p>COMPARATIVA SEMANAL POR CATEGORÍAS</p>
            </div>

            <div class="rep-legend">
                <span><div class="dot orange-dot"></div> CEMENTO</span>
                <span><div class="dot blue-dot"></div> FIERRO</span>
            </div>

        </div>

        <% if (hayDatos) { %>

        <div class="rep-chart">

            <div class="bar-group">
                <div class="bar orange-bar h1" data-value="Cemento: 95"></div>
                <div class="bar blue-bar h2" data-value="Fierro: 62"></div>
                <small>LUN</small>
            </div>

            <div class="bar-group">
                <div class="bar orange-bar h3" data-value="Cemento: 130"></div>
                <div class="bar blue-bar h4" data-value="Fierro: 82"></div>
                <small>MAR</small>
            </div>

            <div class="bar-group">
                <div class="bar orange-bar h5" data-value="Cemento: 115"></div>
                <div class="bar blue-bar h6" data-value="Fierro: 105"></div>
                <small>MIÉ</small>
            </div>

            <div class="bar-group">
                <div class="bar orange-bar h7" data-value="Cemento: 160"></div>
                <div class="bar blue-bar h8" data-value="Fierro: 145"></div>
                <small>JUE</small>
            </div>

            <div class="bar-group">
                <div class="bar orange-bar h9" data-value="Cemento: 88"></div>
                <div class="bar blue-bar h10" data-value="Fierro: 72"></div>
                <small>VIE</small>
            </div>

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

</body>
</html>