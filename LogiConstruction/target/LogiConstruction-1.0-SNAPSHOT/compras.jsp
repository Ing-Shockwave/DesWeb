<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.utp.logiconstruction.dao.CompraDAO"%>
<%@page import="com.utp.logiconstruction.modelo.Compra"%>
<%@page import="java.util.List"%>

<%
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
    <link rel="stylesheet" href="css/estilos.css">
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

    <a class="activo" href="compras.jsp">
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

    <a href="reportes.jsp">
        <i class="fa-solid fa-chart-simple"></i>
        Reportes
    </a>

    </nav>
        <div class="compras-user">
            <strong>Admin Obra</strong>
            <small>ID: #8829</small>
        </div>

        <a class="compras-logout" href="login.jsp">↪ Cerrar Sesión</a>

    </div>

<main class="compras-main">

    <header class="compras-header">
        <div>
            <h1>Gestión de Compras</h1>
            <p>Registra, controla y elimina órdenes de compra.</p>
        </div>

        <div class="compras-search">
            🔍 <input type="text" placeholder="Buscar compras...">
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
                <input type="text" name="producto" placeholder="Producto o material" required>
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

            <table class="compras-table">
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
                            <button type="submit" onclick="return confirm('¿Eliminar esta compra?')">Eliminar</button>
                        </form>
                    </td>
                </tr>
                <%
                    }
                %>
            </table>
        </div>

    </section>

</main>

</body>
</html>