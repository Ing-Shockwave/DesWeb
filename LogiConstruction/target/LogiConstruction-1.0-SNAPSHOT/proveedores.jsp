<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.utp.logiconstruction.modelo.Proveedor"%>
<%@page import="com.utp.logiconstruction.dao.ProveedorDAO"%>
<%@page import="com.utp.logiconstruction.modelo.Usuario"%>
<%@page import="com.utp.logiconstruction.util.AuthUtil"%>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null) { response.sendRedirect("login.jsp"); return; }
    String rol = usuario.getRol();
    boolean esAdministradorObra = AuthUtil.ADMINISTRADOR_OBRA.equals(rol);
    boolean esJefeLogistica = AuthUtil.JEFE_LOGISTICA.equals(rol);
    boolean esGerencia = AuthUtil.GERENCIA.equals(rol);
    String rolNombre = AuthUtil.nombreRol(rol);
    if (!esJefeLogistica) { response.sendRedirect("dashboard.jsp?acceso=denegado"); return; }
    List<Proveedor> lista = new ProveedorDAO().listarProveedores();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8"><title>Proveedores - LogiConstruction</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.8/css/jquery.dataTables.min.css">
    <link rel="stylesheet" href="css/estilos.css?v=crud-seguro3">
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.8/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body class="compras-page">
<div class="compras-sidebar">
    <div class="compras-logo"><div class="compras-logo-icon"><i class="fa-solid fa-helmet-safety"></i></div><div><h2>Logi<span>Con</span></h2><p>PRO VERSION</p></div></div>
    <nav class="compras-menu">
        <a href="dashboard.jsp"><i class="fa-solid fa-chart-column"></i> Dashboard</a>
        <a href="compras.jsp"><i class="fa-solid fa-cart-shopping"></i> Compras</a>
        <a class="activo" href="proveedores.jsp"><i class="fa-solid fa-users"></i> Proveedores</a>
        <a href="requerimientos.jsp"><i class="fa-solid fa-file-lines"></i> Requerimientos</a>
        <% if (esGerencia) { %><a href="reportes.jsp"><i class="fa-solid fa-chart-simple"></i> Reportes</a><% } %>
    </nav>
    <div class="compras-user"><strong><%= usuario.getNombre() %></strong><small>Rol: <%= rolNombre %></small><small>Sesión activa</small></div>
    <a class="compras-logout" href="LogoutServlet"><i class="fa-solid fa-right-from-bracket"></i> Cerrar Sesión</a>
</div>
<main class="compras-main">
    <header class="compras-header"><div><h1>Módulo de Proveedores</h1><p>Administra datos de contacto, dirección y estado operativo.</p></div><div class="compras-search"><i class="fa-solid fa-magnifying-glass"></i><input id="buscarProveedores" placeholder="Buscar proveedor..."></div></header>
    <section class="compras-body">
        <div class="proveedor-form-card">
            <div class="proveedor-form-title"><div class="proveedor-form-icon"><i class="fa-solid fa-user-plus"></i></div><h2>Nuevo Proveedor</h2></div>
            <form action="ProveedorServlet" method="post" class="crud-form-grid" id="formProveedor">
                <div><label>Nombre comercial</label><input type="text" name="nombre" required minlength="2" maxlength="100"></div>
                <div><label>RUC</label><input type="text" name="ruc" required pattern="[0-9]{11}" minlength="11" maxlength="11" inputmode="numeric"></div>
                <div><label>Teléfono</label><input type="text" name="telefono" required minlength="7" maxlength="20" pattern="[0-9+()\s-]{7,20}"></div>
                <div><label>Correo</label><input type="email" name="correo" required maxlength="100"></div>
                <div><label>Dirección</label><input type="text" name="direccion" maxlength="150"></div>
                <div><label>Estado</label><select name="estado"><option value="ACTIVO">Activo</option><option value="INACTIVO">Inactivo</option></select></div>
                <div class="crud-actions"><button type="submit"><i class="fa-solid fa-floppy-disk"></i> Guardar Proveedor</button></div>
            </form>
            <% if (request.getParameter("ok") != null) { %><p class="compras-ok">Proveedor registrado correctamente.</p><% } %>
            <% if (request.getParameter("actualizado") != null) { %><p class="compras-ok">Proveedor actualizado correctamente.</p><% } %>
            <% if (request.getParameter("eliminado") != null) { %><p class="compras-ok">Proveedor eliminado correctamente.</p><% } %>
            <% if ("validacion".equals(request.getParameter("error"))) { %><p class="compras-error">Revise los campos. El RUC debe tener exactamente 11 dígitos.</p>
            <% } else if ("duplicado".equals(request.getParameter("error"))) { %><p class="compras-error">El RUC ya existe.</p>
            <% } else if (request.getParameter("error") != null) { %><p class="compras-error">No se pudo completar la operación.</p><% } %>
        </div>

        <div class="proveedor-table-card">
            <div class="proveedor-table-top"><div class="proveedor-table-title"><div class="db-icon"><i class="fa-solid fa-database"></i></div><h2>Base de Datos</h2></div></div>
            <div class="table-scroll">
                <table class="proveedor-table tabla-datatables" id="tablaProveedores">
                    <thead><tr><th>ID</th><th>Proveedor</th><th>RUC</th><th>Contacto</th><th>Dirección</th><th>Estado</th><th>Acciones</th></tr></thead>
                    <tbody>
                    <% for (Proveedor p : lista) {
                        String estado = p.getEstado() == null ? "ACTIVO" : p.getEstado();
                    %>
                    <tr>
                        <td>#00<%= p.getId() %></td>
                        <td><strong><%= p.getNombre() %></strong></td>
                        <td><%= p.getRuc() %></td>
                        <td><div class="contacto-box"><span><i class="fa-solid fa-phone"></i> <%= p.getTelefono() %></span><span><i class="fa-solid fa-envelope"></i> <%= p.getCorreo() %></span></div></td>
                        <td><%= p.getDireccion() == null ? "Sin dirección" : p.getDireccion() %></td>
                        <td><span class="estado-crud <%= "ACTIVO".equals(estado) ? "estado-activo" : "estado-inactivo" %>"><%= estado %></span></td>
                        <td>
                            <details class="crud-edit-details">
                                <summary><i class="fa-solid fa-pen"></i> Editar</summary>
                                <form action="ProveedorServlet" method="post" class="crud-inline-form">
                                    <input type="hidden" name="accion" value="actualizar"><input type="hidden" name="id" value="<%= p.getId() %>">
                                    <label>Nombre<input name="nombre" value="<%= p.getNombre() %>" required minlength="2" maxlength="100"></label>
                                    <label>RUC<input name="ruc" value="<%= p.getRuc() %>" required pattern="[0-9]{11}" maxlength="11"></label>
                                    <label>Teléfono<input name="telefono" value="<%= p.getTelefono() %>" required maxlength="20"></label>
                                    <label>Correo<input type="email" name="correo" value="<%= p.getCorreo() %>" required maxlength="100"></label>
                                    <label>Dirección<input name="direccion" value="<%= p.getDireccion() == null ? "" : p.getDireccion() %>" maxlength="150"></label>
                                    <label>Estado<select name="estado"><option value="ACTIVO" <%= "ACTIVO".equals(estado) ? "selected" : "" %>>Activo</option><option value="INACTIVO" <%= "INACTIVO".equals(estado) ? "selected" : "" %>>Inactivo</option></select></label>
                                    <button type="submit" class="crud-save"><i class="fa-solid fa-check"></i> Guardar</button>
                                </form>
                            </details>
                            <form action="ProveedorServlet" method="post" class="delete-form"><input type="hidden" name="accion" value="eliminar"><input type="hidden" name="id" value="<%= p.getId() %>"><button type="button" class="btn-eliminar"><i class="fa-solid fa-trash"></i> Eliminar</button></form>
                        </td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
            <div class="proveedor-footer"><span>Total: <%= lista.size() %> proveedores</span><span>Edición completa habilitada</span></div>
        </div>
    </section>
    <footer class="app-footer">LogiConstruction v1.0 | Usuario: <%= usuario.getNombre() %></footer>
</main>
<script>
const idiomaTabla={emptyTable:'No hay registros',info:'Mostrando _START_ a _END_ de _TOTAL_',infoEmpty:'Mostrando 0',zeroRecords:'Sin coincidencias',paginate:{next:'Siguiente',previous:'Anterior'}};
$(function(){const t=$('#tablaProveedores').DataTable({pageLength:5,lengthChange:false,autoWidth:false,dom:'rtip',language:idiomaTabla,columnDefs:[{orderable:false,targets:6}]});$('#buscarProveedores').on('keyup',function(){t.search(this.value).draw();});});
document.querySelectorAll('.btn-eliminar').forEach(b=>b.addEventListener('click',function(){const f=this.closest('form');Swal.fire({title:'¿Eliminar proveedor?',icon:'warning',showCancelButton:true,confirmButtonText:'Sí, eliminar',cancelButtonText:'Cancelar',background:'#0f172a',color:'#fff'}).then(r=>{if(r.isConfirmed)f.submit();});}));
</script>
<%@ include file="/WEB-INF/jspf/chatbot-widget.jspf" %>
<%@ include file="/WEB-INF/jspf/whatsapp-group-button.jspf" %>
</body>
</html>
