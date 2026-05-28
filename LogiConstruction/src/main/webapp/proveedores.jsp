<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.utp.logiconstruction.modelo.Proveedor"%>
<%@page import="com.utp.logiconstruction.dao.ProveedorDAO"%>

<%
    ProveedorDAO dao = new ProveedorDAO();
    List<Proveedor> lista = dao.listarProveedores();
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">

    <title>Proveedores - LogiConstruction</title>

    <link rel="stylesheet"
    href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

    <link rel="stylesheet" href="css/estilos.css">
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

        <a href="compras.jsp">
            <i class="fa-solid fa-cart-shopping"></i>
            Compras
        </a>

        <a class="activo" href="proveedores.jsp">
            <i class="fa-solid fa-users"></i>
            Proveedores
        </a>

        <a href="requerimientos.jsp">
            <i class="fa-solid fa-file-lines"></i>
            Requerimientos
        </a>

        <a href="reportes.jsp">
            <i class="fa-solid fa-chart-simple"></i>
            Reportes
        </a>

    </nav>

    <div class="compras-user">
        <strong>Admin Obra</strong>
        <small>Rol: Administrador Logístico</small>
        <small>ID: #8829</small>
    </div>

    <a class="compras-logout" href="login.jsp">
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

        <div class="proveedores-top-buttons">
            <button class="top-active">Lista</button>
            <button>Analíticas</button>
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

            <form action="ProveedorServlet" method="post" class="proveedor-form-grid">

                <div>
                    <label>Nombre Comercial</label>
                    <input type="text" name="nombre"
                    placeholder="Ej. Elegante S.A." required>
                </div>

                <div>
                    <label>RUC</label>
                    <input type="text" name="ruc"
                    placeholder="12345678901" required>
                </div>

                <div>
                    <label>Teléfono</label>
                    <input type="text" name="telefono"
                    placeholder="+51 999 000 000" required>
                </div>

                <div>
                    <label>Correo Electrónico</label>
                    <input type="email" name="correo"
                    placeholder="contacto@empresa.com" required>
                </div>

                <div class="proveedor-btn-box">

                    <button type="submit" class="proveedor-btn">

                        <i class="fa-solid fa-floppy-disk"></i>
                        Guardar Proveedor

                    </button>

                </div>

            </form>

        </div>

        <div class="proveedor-table-card">

            <div class="proveedor-table-top">

                <div class="proveedor-table-title">

                    <div class="db-icon">
                        <i class="fa-solid fa-database"></i>
                    </div>

                    <h2>Base de Datos</h2>

                </div>

                <div class="proveedor-search">

                    <i class="fa-solid fa-magnifying-glass"></i>

                    <input type="text" id="buscarProveedores"
                    placeholder="Buscar proveedor...">

                </div>

            </div>

            <table class="proveedor-table" id="tablaProveedores">

                <tr>
                    <th>ID</th>
                    <th>PROVEEDOR</th>
                    <th>RUC</th>
                    <th>CONTACTO</th>
                    <th>ACCIONES</th>
                </tr>

                <%
                    for(Proveedor p : lista){
                %>

                <tr>

                    <td>#00<%= p.getId() %></td>

                    <td>

                        <div class="proveedor-info">

                            <div class="proveedor-badge">
                                <%= p.getNombre().substring(0,2).toUpperCase() %>
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

                            <button class="edit-btn">
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

                <%
                    }
                %>

            </table>

            <div class="proveedor-footer">

                <span>
                    Mostrando <%= lista.size() %>
                    proveedores registrados
                </span>

                <div class="proveedor-pagination">
                    <button>Anterior</button>
                    <button>Siguiente</button>
                </div>

            </div>

        </div>

    </section>

    <footer class="app-footer">
        LogiConstruction v1.0 | Sistema de Gestión Logística | Usuario: Admin Obra
    </footer>

</main>

<script>
document.getElementById('buscarProveedores').addEventListener('keyup', function() {
    const texto = this.value.toLowerCase();
    const filas = document.querySelectorAll('#tablaProveedores tr:not(:first-child)');

    filas.forEach(function(fila) {
        fila.style.display = fila.textContent.toLowerCase().includes(texto) ? '' : 'none';
    });
});
</script>

<script>
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