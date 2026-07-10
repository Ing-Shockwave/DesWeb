<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.utp.logiconstruction.modelo.Proveedor"%>
<%@page import="com.utp.logiconstruction.dao.ProveedorDAO"%>
<%@page import="com.utp.logiconstruction.modelo.Usuario"%>
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

    if (!esJefeLogistica) {
        response.sendRedirect("dashboard.jsp?acceso=denegado");
        return;
    }

    ProveedorDAO dao = new ProveedorDAO();
    List<Proveedor> lista = dao.listarProveedores();
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Proveedores - LogiConstruction</title>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.8/css/jquery.dataTables.min.css">
    <link rel="stylesheet" href="css/estilos.css?v=chatbot2">

    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.8/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>

<body class="compras-page">

<div class="compras-sidebar">

    <div class="compras-logo">
        <div class="compras-logo-icon">
            <i class="fa-solid fa-helmet-safety"></i>
        </div>

        <div>
            <h2>Logi<span>Con</span></h2>
            <p>PRO VERSION</p>
        </div>
    </div>

    <nav class="compras-menu">

        <a href="dashboard.jsp">
            <i class="fa-solid fa-chart-column"></i>
            Dashboard
        </a>

        <% if (esJefeLogistica) { %>
        <a href="compras.jsp">
            <i class="fa-solid fa-cart-shopping"></i>
            Compras
        </a>

        <a class="activo" href="proveedores.jsp">
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
        <% } %>

    </nav>

    <div class="compras-user">
        <strong><%= usuario.getNombre() %></strong>
        <small>Rol: <%= rolNombre %></small>
        <small>Sesión activa</small>
    </div>

    <a class="compras-logout" href="LogoutServlet">
        <i class="fa-solid fa-right-from-bracket"></i>
        Cerrar Sesión
    </a>

</div>

<main class="compras-main">

    <header class="compras-header">
        <div>
            <h1>Módulo de Proveedores</h1>
            <p>Registro y administración de socios estratégicos y proveedores.</p>
        </div>

        <div class="compras-search">
            <i class="fa-solid fa-magnifying-glass"></i>
            <input type="text" id="buscarProveedores" placeholder="Buscar proveedor...">
        </div>
    </header>

    <section class="compras-body">

        <div class="proveedor-form-card">

            <div class="proveedor-form-title">
                <div class="proveedor-form-icon">
                    <i class="fa-solid fa-user-plus"></i>
                </div>
                <h2>Nuevo Proveedor</h2>
            </div>

            <form action="ProveedorServlet" method="post" class="proveedor-form-grid" id="formProveedor">

                <div>
                    <label>Nombre Comercial</label>
                    <input type="text" name="nombre" placeholder="Ej. Elegante S.A." required minlength="2" maxlength="100" autocomplete="organization">
                </div>

                <div>
                    <label>RUC</label>
                    <input type="text" name="ruc" placeholder="12345678901" required pattern="[0-9]{1,11}" minlength="1" maxlength="11" inputmode="numeric" title="El RUC es obligatorio y solo debe contener números. Máximo 11 dígitos.">
                </div>

                <div>
                    <label>Teléfono</label>
                    <input type="text" name="telefono" placeholder="+51 999 000 000" required minlength="7" maxlength="20" pattern="[0-9+()\s-]{7,20}" title="Ingrese un teléfono válido">
                </div>

                <div>
                    <label>Correo Electrónico</label>
                    <input type="email" name="correo" placeholder="contacto@empresa.com" required maxlength="100" autocomplete="email">
                </div>

                <div class="proveedor-btn-box">
                    <button type="submit" class="proveedor-btn">
                        <i class="fa-solid fa-floppy-disk"></i>
                        Guardar Proveedor
                    </button>
                </div>

            </form>

            <% if (request.getParameter("ok") != null) { %>
                <p class="compras-ok">Proveedor registrado correctamente.</p>
            <% } %>

            <% if ("validacion".equals(request.getParameter("error"))) { %>
                <p class="compras-error">Revise los campos: el RUC es obligatorio, solo debe contener números y puede tener hasta 11 dígitos. El correo debe ser válido y los datos no pueden estar vacíos.</p>
            <% } else if ("duplicado".equals(request.getParameter("error"))) { %>
                <p class="compras-error">No se pudo registrar el proveedor porque el RUC ya existe en la base de datos.</p>
            <% } else if (request.getParameter("error") != null) { %>
                <p class="compras-error">No se pudo registrar el proveedor. Verifique la conexión o los datos ingresados.</p>
            <% } %>

            <% if (request.getParameter("eliminado") != null) { %>
                <p class="compras-ok">Proveedor eliminado correctamente.</p>
            <% } %>
        </div>

        <div class="proveedor-table-card">

            <div class="proveedor-table-top">
                <div class="proveedor-table-title">
                    <div class="db-icon">
                        <i class="fa-solid fa-database"></i>
                    </div>
                    <h2>Base de Datos</h2>
                </div>
            </div>

            <table class="proveedor-table tabla-datatables" id="tablaProveedores">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>PROVEEDOR</th>
                        <th>RUC</th>
                        <th>CONTACTO</th>
                        <th>ACCIONES</th>
                    </tr>
                </thead>

                <tbody>
                    <% for(Proveedor p : lista){ %>
                    <tr>
                        <td>#00<%= p.getId() %></td>

                        <td>
                            <div class="proveedor-info">
                                <div class="proveedor-badge">
                                    <%= p.getNombre().substring(0, Math.min(2, p.getNombre().length())).toUpperCase() %>
                                </div>

                                <div>
                                    <strong><%= p.getNombre() %></strong>
                                    <small>CONSTRUCCIÓN CIVIL</small>
                                </div>
                            </div>
                        </td>

                        <td><%= p.getRuc() %></td>

                        <td>
                            <div class="contacto-box">
                                <span>
                                    <i class="fa-solid fa-phone"></i>
                                    <%= p.getTelefono() %>
                                </span>

                                <span>
                                    <i class="fa-solid fa-envelope"></i>
                                    <%= p.getCorreo() %>
                                </span>
                            </div>
                        </td>

                        <td>
                            <div class="acciones-box">
                                <button class="edit-btn" type="button" title="Edición pendiente de implementación">
                                    <i class="fa-solid fa-pen"></i>
                                </button>

                                <form action="ProveedorServlet" method="post" style="margin:0;">
                                    <input type="hidden" name="accion" value="eliminar">
                                    <input type="hidden" name="id" value="<%= p.getId() %>">

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

            <div class="proveedor-footer">
                <span>Total: <%= lista.size() %> proveedores registrados</span>
                <span>DataTables habilitado: búsqueda, ordenamiento y paginación</span>
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
    const tablaProveedores = $('#tablaProveedores').DataTable({
        pageLength: 5,
        lengthChange: false,
        ordering: true,
        autoWidth: false,
        dom: 'rtip',
        language: dataTableSpanish,
        columnDefs: [
            { orderable: false, targets: 4 }
        ]
    });

    $('#buscarProveedores').on('keyup', function () {
        tablaProveedores.search(this.value).draw();
    });
});

const formProveedor = document.getElementById('formProveedor');
formProveedor.addEventListener('submit', function (event) {
    const nombre = formProveedor.nombre.value.trim();
    const ruc = formProveedor.ruc.value.trim();
    const telefono = formProveedor.telefono.value.trim();
    const correo = formProveedor.correo.value.trim();
    const correoValido = /^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/.test(correo);

    if (nombre.length < 2 || !/^\d{1,11}$/.test(ruc) || !/^[0-9+()\s-]{7,20}$/.test(telefono) || !correoValido) {
        event.preventDefault();
        Swal.fire({
            icon: 'warning',
            title: 'Datos inválidos',
            text: 'Verifique nombre, RUC numérico obligatorio de hasta 11 dígitos, teléfono y correo electrónico.',
            background: '#0f172a',
            color: '#ffffff',
            confirmButtonColor: '#ff7b2c'
        });
    }
});

document.querySelectorAll('.edit-btn').forEach(boton => {
    boton.addEventListener('click', function () {
        Swal.fire({
            icon: 'info',
            title: 'Función pendiente',
            text: 'La edición de proveedores puede implementarse como siguiente mejora CRUD.',
            background: '#0f172a',
            color: '#ffffff',
            confirmButtonColor: '#ff7b2c'
        });
    });
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


<%@ include file="/WEB-INF/jspf/chatbot-widget.jspf" %>

<%@ include file="/WEB-INF/jspf/whatsapp-group-button.jspf" %>

</body>
</html>
