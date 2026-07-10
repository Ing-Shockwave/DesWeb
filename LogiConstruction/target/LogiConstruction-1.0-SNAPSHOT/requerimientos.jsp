<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.utp.logiconstruction.dao.RequerimientoDAO"%>
<%@page import="com.utp.logiconstruction.modelo.Requerimiento"%>
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

    if (!esAdministradorObra && !esJefeLogistica) {
        response.sendRedirect("dashboard.jsp?acceso=denegado");
        return;
    }

    RequerimientoDAO dao = new RequerimientoDAO();
    List<Requerimiento> requerimientos = dao.listarRequerimientos();
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Requerimientos - LogiConstruction</title>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.8/css/jquery.dataTables.min.css">
    <link rel="stylesheet" href="css/estilos.css?v=validaciones1">

    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.8/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>

<body class="req-page">

<div class="req-sidebar">

    <div class="req-logo">
        <div class="req-logo-icon">
            <i class="fa-solid fa-helmet-safety"></i>
        </div>

        <div>
            <h2>Logi<span>Con</span></h2>
            <p>PRO VERSION</p>
        </div>
    </div>

    <nav class="req-menu">

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
        <a class="activo" href="requerimientos.jsp">
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
        <% } %>

    </nav>

    <div class="req-user">
        <strong><%= usuario.getNombre() %></strong>
        <small>Rol: <%= rolNombre %></small>
        <small>Sesión activa</small>
    </div>

    <a class="req-logout" href="LogoutServlet">
        <i class="fa-solid fa-right-from-bracket"></i>
        Cerrar Sesión
    </a>

</div>

<main class="req-main">

    <header class="req-header">
        <div>
            <h1>Módulo de Requerimientos</h1>
            <p>Registro y seguimiento de materiales para obra activa.</p>
        </div>

        <div class="req-team">
            <span>AO</span>
            <span>JD</span>
            <strong>Personal en Obra</strong>
        </div>
    </header>

    <section class="req-body">

        <div class="req-form-card">

            <div class="req-title">
                <div class="req-title-icon">
                    <i class="fa-solid fa-clipboard"></i>
                </div>
                <h2>Nuevo Requerimiento</h2>
            </div>

            <form action="RequerimientoServlet" method="post" class="req-form" id="formRequerimiento">

                <div>
                    <label>Nombre del Material</label>
                    <input type="text" name="nombre" placeholder="Ej. Cemento Portland" required minlength="2" maxlength="100">
                </div>

                <div>
                    <label>Área Solicitante</label>
                    <input type="text" name="area" placeholder="Almacén Central" required minlength="2" maxlength="100">
                </div>

                <div>
                    <label>Cantidad</label>
                    <input type="number" name="cantidad" placeholder="0" required min="1" max="1000000" step="1">
                </div>

                <div>
                    <label>Fecha Límite</label>
                    <input type="date" name="fecha" required>
                </div>

                <div class="req-btn-box">
                    <button type="submit">
                        <i class="fa-solid fa-paper-plane"></i>
                        Registrar Requerimiento
                    </button>
                </div>

            </form>

            <% if (request.getParameter("ok") != null) { %>
                <p class="req-ok">Requerimiento registrado correctamente.</p>
            <% } %>

            <% if ("validacion".equals(request.getParameter("error"))) { %>
                <p class="req-error">Revise los campos: material y área deben tener mínimo 2 caracteres, la cantidad debe ser mayor a 0 y la fecha debe ser válida.</p>
            <% } else if (request.getParameter("error") != null) { %>
                <p class="req-error">No se pudo registrar el requerimiento. Verifique la conexión o los datos ingresados.</p>
            <% } %>

            <% if (request.getParameter("eliminado") != null) { %>
                <p class="req-ok">Requerimiento eliminado correctamente.</p>
            <% } %>

        </div>

        <div class="req-table-card">

            <div class="req-table-top">
                <div class="req-table-title">
                    <div class="req-db-icon">
                        <i class="fa-solid fa-wave-square"></i>
                    </div>
                    <h2>Seguimiento de Obra</h2>
                </div>

                <div class="req-search">
                    <i class="fa-solid fa-magnifying-glass"></i>
                    <input type="text" id="buscarRequerimientos" placeholder="Buscar requerimiento...">
                </div>
            </div>

            <table class="req-table tabla-datatables" id="tablaRequerimientos">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>MATERIAL / REQUERIMIENTO</th>
                        <th>ÁREA</th>
                        <th>CANT.</th>
                        <th>ESTADO</th>
                        <th>FECHA</th>
                        <th>ACCIONES</th>
                    </tr>
                </thead>

                <tbody>
                    <% for (Requerimiento r : requerimientos) {
                        String estado = "PENDIENTE";
                        String claseEstado = "estado-pendiente";

                        if (r.getId() % 3 == 1) {
                            estado = "EN PROCESO";
                            claseEstado = "estado-proceso";
                        } else if (r.getId() % 3 == 2) {
                            estado = "ATENDIDO";
                            claseEstado = "estado-atendido";
                        }
                    %>
                    <tr>
                        <td>#00<%= r.getId() %></td>

                        <td>
                            <div class="req-material">
                                <div class="req-material-icon">
                                    <i class="fa-solid fa-layer-group"></i>
                                </div>

                                <div>
                                    <strong><%= r.getNombre() %></strong>
                                    <small>MATERIAL DE BASE</small>
                                </div>
                            </div>
                        </td>

                        <td>
                            <span class="req-area"><%= r.getArea().replace("AlmacÃ©n", "Almacén") %></span>
                        </td>

                        <td>
                            <strong class="req-cantidad"><%= r.getCantidad() %></strong>
                            <small>UND</small>
                        </td>

                        <td>
                            <span class="req-estado <%= claseEstado %>"><%= estado %></span>
                        </td>

                        <td><%= r.getFecha() %></td>

                        <td>
                            <div class="req-actions">
                                <form action="RequerimientoServlet" method="post" style="margin:0;">
                                    <input type="hidden" name="accion" value="eliminar">
                                    <input type="hidden" name="id" value="<%= r.getId() %>">

                                    <button type="button" class="delete-btn btn-eliminar">
                                        <i class="fa-solid fa-trash"></i>
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>

            <div class="req-footer">
                <span>Total: <%= requerimientos.size() %> requerimientos activos de obra</span>
                <div>
                    <button onclick="window.print()">Exportar PDF</button>
                </div>
            </div>

        </div>

    </section>

    <footer class="app-footer">
        LogiConstruction v1.0 | Sistema de Gestión Logística | Usuario: <%= usuario.getNombre() %>
    </footer>

</main>

<script>
const dataTableSpanish = {
    emptyTable: 'No hay registros disponibles',
    info: 'Mostrando _START_ a _END_ de _TOTAL_ registros',
    infoEmpty: 'Mostrando 0 registros',
    infoFiltered: '(filtrado de _MAX_ registros)',
    lengthMenu: 'Mostrar _MENU_ registros',
    loadingRecords: 'Cargando...',
    processing: 'Procesando...',
    zeroRecords: 'No se encontraron coincidencias',
    paginate: {
        first: 'Primero',
        last: 'Último',
        next: 'Siguiente',
        previous: 'Anterior'
    }
};

$(document).ready(function () {
    const tablaRequerimientos = $('#tablaRequerimientos').DataTable({
        pageLength: 5,
        lengthChange: false,
        ordering: true,
        autoWidth: false,
        dom: 'rtip',
        language: dataTableSpanish,
        columnDefs: [
            { orderable: false, targets: 6 }
        ]
    });

    $('#buscarRequerimientos').on('keyup', function () {
        tablaRequerimientos.search(this.value).draw();
    });
});

const formRequerimiento = document.getElementById('formRequerimiento');
formRequerimiento.addEventListener('submit', function (event) {
    const nombre = formRequerimiento.nombre.value.trim();
    const area = formRequerimiento.area.value.trim();
    const cantidad = Number(formRequerimiento.cantidad.value);
    const fecha = formRequerimiento.fecha.value.trim();

    if (nombre.length < 2 || area.length < 2 || !Number.isInteger(cantidad) || cantidad < 1 || fecha.length === 0) {
        event.preventDefault();
        Swal.fire({
            icon: 'warning',
            title: 'Datos incompletos',
            text: 'Ingrese material, área, cantidad mayor a cero y fecha válida.',
            background: '#0f172a',
            color: '#ffffff',
            confirmButtonColor: '#ff7b2c'
        });
    }
});

document.querySelectorAll('.btn-eliminar').forEach(boton => {
    boton.addEventListener('click', function () {
        const form = this.closest('form');

        Swal.fire({
            title: '¿Eliminar registro?',
            text: 'Esta acción no se puede deshacer.',
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#ff7b2c',
            cancelButtonColor: '#334155',
            confirmButtonText: 'Sí, eliminar',
            cancelButtonText: 'Cancelar',
            background: '#0f172a',
            color: '#ffffff'
        }).then((result) => {
            if (result.isConfirmed) {
                form.submit();
            }
        });
    });
});
</script>

</body>
</html>
