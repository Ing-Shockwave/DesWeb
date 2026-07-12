<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.utp.logiconstruction.dao.ReporteDAO"%>
<%@page import="com.utp.logiconstruction.modelo.Usuario"%>
<%@page import="com.utp.logiconstruction.util.AuthUtil"%>
<%@page import="java.util.List"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="java.time.LocalDateTime"%>
<%@page import="java.time.format.DateTimeFormatter"%>

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
    int comprasRecibidas = dao.contarComprasRecibidas();
    int totalProveedores = dao.contarProveedores();
    int proveedoresActivos = dao.contarProveedoresActivos();
    int totalRequerimientos = dao.contarRequerimientos();
    int requerimientosAprobados = dao.contarRequerimientosAprobados();
    int requerimientosRechazados = dao.contarRequerimientosRechazados();
    int requerimientosAtendidos = dao.contarRequerimientosAtendidos();
    int requerimientosResueltos = dao.contarRequerimientosResueltos();
    int requerimientosPorResolver = dao.contarRequerimientosPorResolver();
    BigDecimal costoTotalCompras = dao.obtenerCostoTotalCompras();

    int porcentajeComprasRecibidas = totalCompras == 0 ? 0 : (int) Math.round(comprasRecibidas * 100.0 / totalCompras);
    int porcentajeProveedoresActivos = totalProveedores == 0 ? 0 : (int) Math.round(proveedoresActivos * 100.0 / totalProveedores);
    int porcentajeRequerimientosResueltos = totalRequerimientos == 0 ? 0 : (int) Math.round(requerimientosResueltos * 100.0 / totalRequerimientos);
    String fechaGeneracion = LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss"));

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

    <link rel="stylesheet" href="css/estilos.css?v=chatbot2">

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

        <% if (esAdministradorObra) { %>
        <a href="requerimientos-jsf.xhtml">
            <i class="fa-solid fa-code"></i>
            Demo JSF
        </a>
        <% } %>

        <% if (esGerencia) { %>
        <a class="activo" href="reportes.jsp">
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

            <button type="button" id="btnActualizarReportes" onclick="actualizarReportes(true)">
                <i class="fa-solid fa-rotate"></i>
                Actualizar datos
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

                <span class="rep-badge green" id="comprasRecibidasBadge"><%= comprasRecibidas %> recibidas</span>
            </div>

            <h3>Compras</h3>
            <div class="rep-number" id="totalCompras"><%= totalCompras %></div>
            <small>REGISTRADAS</small>

            <div class="rep-progress-text">
                <span>COMPRAS RECIBIDAS</span>
                <span id="porcentajeComprasRecibidas"><%= porcentajeComprasRecibidas %>%</span>
            </div>

            <div class="rep-progress">
                <div id="barraComprasRecibidas" class="rep-progress-fill orange-fill"
                     style="width:<%= porcentajeComprasRecibidas %>%;"></div>
            </div>
        </div>

        <div class="rep-card">
            <div class="rep-card-top">
                <div class="rep-card-icon blue">
                    <i class="fa-solid fa-users"></i>
                </div>

                <span class="rep-badge gray" id="proveedoresActivosBadge"><%= proveedoresActivos %> activos</span>
            </div>

            <h3>Proveedores</h3>
            <div class="rep-number" id="proveedoresActivos"><%= proveedoresActivos %></div>
            <small id="proveedoresDetalle">ACTIVOS DE <%= totalProveedores %> REGISTRADOS</small>

            <div class="rep-progress-text">
                <span>PROVEEDORES ACTIVOS</span>
                <span id="porcentajeProveedoresActivos"><%= porcentajeProveedoresActivos %>%</span>
            </div>

            <div class="rep-progress">
                <div id="barraProveedoresActivos" class="rep-progress-fill blue-fill"
                     style="width:<%= porcentajeProveedoresActivos %>%;"></div>
            </div>
        </div>

        <div class="rep-card">
            <div class="rep-card-top">
                <div class="rep-card-icon green">
                    <i class="fa-solid fa-file-lines"></i>
                </div>

                <span class="rep-badge orange-badge" id="requerimientosPorResolverBadge"><%= requerimientosPorResolver %> por resolver</span>
            </div>

            <h3>Requerimientos</h3>
            <div class="rep-number" id="totalRequerimientos"><%= totalRequerimientos %></div>
            <small id="requerimientosDetalle"><%= requerimientosAtendidos %> atendidos · <%= requerimientosRechazados %> rechazados · <%= requerimientosAprobados %> aprobados</small>

            <div class="rep-progress-text">
                <span>REQUERIMIENTOS RESUELTOS</span>
                <span id="porcentajeRequerimientosResueltos"><%= porcentajeRequerimientosResueltos %>%</span>
            </div>

            <div class="rep-progress">
                <div id="barraRequerimientosResueltos" class="rep-progress-fill green-fill"
                     style="width:<%= porcentajeRequerimientosResueltos %>%;"></div>
            </div>
        </div>

        <div class="rep-card">
            <div class="rep-card-top">
                <div class="rep-card-icon orange"><i class="fa-solid fa-sack-dollar"></i></div>
                <span class="rep-badge green">Sin anuladas</span>
            </div>
            <h3>Costo acumulado</h3>
            <div class="rep-number" id="costoTotalCompras" style="font-size:28px;">S/ <%= costoTotalCompras.setScale(2) %></div>
            <small>COMPRAS VIGENTES</small>
            <div class="rep-progress-text"><span>DATOS REALES DE COSTO</span><span>100%</span></div>
            <div class="rep-progress"><div class="rep-progress-fill orange-fill" style="width:100%;"></div></div>
        </div>

    </section>

    <section class="rep-chart-card">

        <div class="rep-chart-header">

            <div>
                <h2>Movimiento de Materiales</h2>
                <p>MATERIALES CON MAYOR CANTIDAD COMPRADA</p>
            </div>

        </div>

        <div class="chart-container" id="contenedorGrafico"
             style="<%= hayDatos ? "" : "display:none;" %>">
            <canvas id="categoriaChart"></canvas>
        </div>

        <div class="rep-empty-chart" id="graficoVacio"
             style="<%= hayDatos ? "display:none;" : "" %>">
            <i class="fa-solid fa-chart-column"></i>
            <p>No existen datos suficientes para generar estadísticas.</p>
        </div>

    </section>

    <footer class="rep-footer">
        ÚLTIMA ACTUALIZACIÓN: <span id="fechaGeneracion"><%= fechaGeneracion %></span>
    </footer>

</main>

<script>
const ctxCategoria = document.getElementById('categoriaChart');
const contextoAplicacion = '<%= request.getContextPath() %>';

let categoriaChart = new Chart(ctxCategoria, {
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
                        return context.label + ': ' + context.raw + ' unidades';
                    }
                }
            }
        }
    }
});

function establecerTexto(id, valor) {
    const elemento = document.getElementById(id);
    if (elemento) {
        elemento.textContent = valor;
    }
}

function establecerProgreso(id, porcentaje) {
    const elemento = document.getElementById(id);
    if (elemento) {
        const valorSeguro = Math.max(0, Math.min(100, Number(porcentaje) || 0));
        elemento.style.width = valorSeguro + '%';
    }
}

function actualizarGrafico(materiales) {
    const lista = Array.isArray(materiales) ? materiales : [];
    const contenedor = document.getElementById('contenedorGrafico');
    const vacio = document.getElementById('graficoVacio');

    if (lista.length === 0) {
        contenedor.style.display = 'none';
        vacio.style.display = '';
        categoriaChart.data.labels = [];
        categoriaChart.data.datasets[0].data = [];
        categoriaChart.update();
        return;
    }

    contenedor.style.display = '';
    vacio.style.display = 'none';
    categoriaChart.data.labels = lista.map(item => item.nombre);
    categoriaChart.data.datasets[0].data = lista.map(item => item.cantidad);
    window.requestAnimationFrame(function() {
        categoriaChart.resize();
        categoriaChart.update();
    });
}

async function actualizarReportes(mostrarConfirmacion) {
    const boton = document.getElementById('btnActualizarReportes');

    if (boton) {
        boton.disabled = true;
        boton.querySelector('i').classList.add('fa-spin');
    }

    try {
        const respuesta = await fetch(
            contextoAplicacion + '/api/reportes/resumen?t=' + Date.now(),
            {
                method: 'GET',
                cache: 'no-store',
                headers: {
                    'Accept': 'application/json'
                }
            }
        );

        if (respuesta.status === 401) {
            window.location.href = contextoAplicacion + '/login.jsp';
            return;
        }

        if (!respuesta.ok) {
            throw new Error('No fue posible consultar los datos actualizados.');
        }

        const datos = await respuesta.json();

        establecerTexto('comprasRecibidasBadge', datos.comprasRecibidas + ' recibidas');
        establecerTexto('totalCompras', datos.totalCompras);
        establecerTexto('porcentajeComprasRecibidas', datos.porcentajeComprasRecibidas + '%');
        establecerProgreso('barraComprasRecibidas', datos.porcentajeComprasRecibidas);

        establecerTexto('proveedoresActivosBadge', datos.proveedoresActivos + ' activos');
        establecerTexto('proveedoresActivos', datos.proveedoresActivos);
        establecerTexto(
            'proveedoresDetalle',
            'ACTIVOS DE ' + datos.totalProveedores + ' REGISTRADOS'
        );
        establecerTexto('porcentajeProveedoresActivos', datos.porcentajeProveedoresActivos + '%');
        establecerProgreso('barraProveedoresActivos', datos.porcentajeProveedoresActivos);

        establecerTexto(
            'requerimientosPorResolverBadge',
            datos.requerimientosPorResolver + ' por resolver'
        );
        establecerTexto('totalRequerimientos', datos.totalRequerimientos);
        establecerTexto(
            'requerimientosDetalle',
            datos.requerimientosAtendidos + ' atendidos · '
                + datos.requerimientosRechazados + ' rechazados · '
                + datos.requerimientosAprobados + ' aprobados'
        );
        establecerTexto(
            'porcentajeRequerimientosResueltos',
            datos.porcentajeRequerimientosResueltos + '%'
        );
        establecerProgreso(
            'barraRequerimientosResueltos',
            datos.porcentajeRequerimientosResueltos
        );

        const costoFormateado = new Intl.NumberFormat('es-PE', {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        }).format(Number(datos.costoTotalCompras || 0));

        establecerTexto('costoTotalCompras', 'S/ ' + costoFormateado);
        establecerTexto('fechaGeneracion', datos.fechaActualizacion);
        actualizarGrafico(datos.materiales);

        if (mostrarConfirmacion) {
            Swal.fire({
                icon: 'success',
                title: 'Reporte actualizado',
                text: 'Los indicadores se sincronizaron con la base de datos.',
                timer: 1400,
                showConfirmButton: false
            });
        }
    } catch (error) {
        if (mostrarConfirmacion) {
            Swal.fire({
                icon: 'error',
                title: 'No se pudo actualizar',
                text: error.message
            });
        } else {
            console.error('Error al actualizar reportes:', error);
        }
    } finally {
        if (boton) {
            boton.disabled = false;
            boton.querySelector('i').classList.remove('fa-spin');
        }
    }
}

// Actualización automática sin recargar toda la página.
const intervaloReportes = window.setInterval(function() {
    if (!document.hidden) {
        actualizarReportes(false);
    }
}, 10000);

// También se actualiza al volver a la pestaña o ventana.
document.addEventListener('visibilitychange', function() {
    if (!document.hidden) {
        actualizarReportes(false);
    }
});

window.addEventListener('focus', function() {
    actualizarReportes(false);
});

window.addEventListener('beforeunload', function() {
    window.clearInterval(intervaloReportes);
});
</script>

<%@ include file="/WEB-INF/jspf/chatbot-widget.jspf" %>

<%@ include file="/WEB-INF/jspf/whatsapp-group-button.jspf" %>

</body>
</html>