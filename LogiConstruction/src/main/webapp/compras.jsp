<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.utp.logiconstruction.dao.CompraDAO"%>
<%@page import="com.utp.logiconstruction.modelo.Compra"%>
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

    if (!esJefeLogistica) {
        response.sendRedirect("dashboard.jsp?acceso=denegado");
        return;
    }

    CompraDAO dao = new CompraDAO();
    List<Compra> compras = dao.listarCompras();
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Compras - LogiConstruction</title>
    <link rel="stylesheet"
    href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="css/estilos.css?v=menu4">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    
</head>

<body class="compras-page">

<div class="compras-sidebar">

    <div class="compras-logo">
        <div class="compras-logo-icon">🏗</div>
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
        <a class="activo" href="compras.jsp">
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
            <h1>Gestión de Compras</h1>
            <p>Registra, controla y elimina órdenes de compra.</p>
        </div>

        <div class="compras-search">
            <i class="fa-solid fa-magnifying-glass"></i>
            <input type="text" id="buscarCompras" placeholder="Buscar compras...">
        </div>
    </header>

    <section class="compras-body">

        <div class="compras-hero">
            <div>
                <h2>Módulo de Compras</h2>
                <p>Registra compras logísticas relacionadas con proveedores, materiales y cantidades necesarias para obra.</p>
            </div>
            <div class="hero-watermark">🛒</div>
        </div>

        <div class="compras-card">
            <h2>Nueva Compra</h2>

            <form action="CompraServlet" method="post" class="compras-form">
                <input type="text" name="proveedor" placeholder="Proveedor" required>

                <input type="text" name="producto" list="listaMateriales" placeholder="Producto o material" autocomplete="off" required>

                <datalist id="listaMateriales">
                    <option value="Acero corrugado"></option>
                    <option value="Alambre galvanizado"></option>
                    <option value="Arena fina"></option>
                    <option value="Arena gruesa"></option>
                    <option value="Bloques de concreto"></option>
                    <option value="Cal"></option>
                    <option value="Calamina"></option>
                    <option value="Cemento Portland"></option>
                    <option value="Cerámica"></option>
                    <option value="Clavos"></option>
                    <option value="Concreto premezclado"></option>
                    <option value="Drywall"></option>
                    <option value="Fierro"></option>
                    <option value="Grava"></option>
                    <option value="Ladrillo King Kong"></option>
                    <option value="Ladrillo Pandereta"></option>
                    <option value="Madera"></option>
                    <option value="Mayólica"></option>
                    <option value="Pegamento para cerámica"></option>
                    <option value="Pernos"></option>
                    <option value="Pintura"></option>
                    <option value="Piso porcelanato"></option>
                    <option value="Plancha OSB"></option>
                    <option value="Puerta metálica"></option>
                    <option value="Tornillos"></option>
                    <option value="Tubería PVC"></option>
                    <option value="Varilla de acero"></option>
                    <option value="Vidrio templado"></option>
                    <option value="Yeso"></option>
                </datalist>

                <input type="number" name="cantidad" placeholder="Cantidad" required>

                <button type="submit">Registrar Compra</button>
            </form>

            <%
                if (request.getParameter("ok") != null) {
            %>
                <p class="compras-ok">Compra registrada correctamente</p>
            <%
                }
                if (request.getParameter("error") != null) {
            %>
                <p class="compras-error">Error al registrar compra</p>
            <%
                }
            %>
        </div>

        <div class="compras-card">
            <div class="compras-card-head">
                <h2>Compras Registradas</h2>
                <span>VER TODO</span>
            </div>

            <table class="compras-table" id="tablaCompras">
                <tr>
                    <th>ID</th>
                    <th>Proveedor</th>
                    <th>Producto</th>
                    <th>Cantidad</th>
                    <th>Acciones</th>
                </tr>

                <%
                    for (Compra c : compras) {
                %>
                <tr>
                    <td>#CMP-<%= c.getId() %></td>
                    <td><%= c.getProveedor() %></td>
                    <td><%= c.getProducto() %></td>
                    <td><%= c.getCantidad() %></td>
                    <td>
                        <form action="CompraServlet" method="post" class="delete-form">
                            <input type="hidden" name="accion" value="eliminar">
                            <input type="hidden" name="id" value="<%= c.getId() %>">
                            <button type="button" class="btn-eliminar">
                                Eliminar
                            </button>
                        </form>
                    </td>
                </tr>
                <%
                    }
                %>
            </table>
        </div>

    </section>

    <footer class="app-footer">
        LogiConstruction v1.0 | Sistema de Gestión Logística | Usuario: <%= usuario.getNombre() %>
    </footer>

</main>

<script>
document.getElementById('buscarCompras').addEventListener('keyup', function() {
    const texto = this.value.toLowerCase();
    const filas = document.querySelectorAll('#tablaCompras tr:not(:first-child)');

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