<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.utp.logiconstruction.dao.RequerimientoDAO"%>
<%@page import="com.utp.logiconstruction.modelo.Requerimiento"%>
<%@page import="com.utp.logiconstruction.modelo.Usuario"%>
<%@page import="com.utp.logiconstruction.util.AuthUtil"%>
<%@page import="java.util.List"%>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null) { response.sendRedirect("login.jsp"); return; }
    String rol = usuario.getRol();
    boolean esAdministradorObra = AuthUtil.ADMINISTRADOR_OBRA.equals(rol);
    boolean esJefeLogistica = AuthUtil.JEFE_LOGISTICA.equals(rol);
    boolean esGerencia = AuthUtil.GERENCIA.equals(rol);
    String rolNombre = AuthUtil.nombreRol(rol);
    if (!esAdministradorObra && !esJefeLogistica) { response.sendRedirect("dashboard.jsp?acceso=denegado"); return; }
    List<Requerimiento> requerimientos = new RequerimientoDAO().listarRequerimientos();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8"><title>Requerimientos - LogiConstruction</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.8/css/jquery.dataTables.min.css">
    <link rel="stylesheet" href="css/estilos.css?v=crud-seguro3">
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.8/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body class="req-page">
<div class="req-sidebar">
    <div class="req-logo"><div class="req-logo-icon"><i class="fa-solid fa-helmet-safety"></i></div><div><h2>Logi<span>Con</span></h2><p>PRO VERSION</p></div></div>
    <nav class="req-menu">
        <a href="dashboard.jsp"><i class="fa-solid fa-chart-column"></i> Dashboard</a>
        <% if (esJefeLogistica) { %><a href="compras.jsp"><i class="fa-solid fa-cart-shopping"></i> Compras</a><a href="proveedores.jsp"><i class="fa-solid fa-users"></i> Proveedores</a><% } %>
        <a class="activo" href="requerimientos.jsp"><i class="fa-solid fa-file-lines"></i> Requerimientos</a>
        <% if (esAdministradorObra) { %><a href="requerimientos-jsf.xhtml"><i class="fa-solid fa-code"></i> Demo JSF</a><% } %>
        <% if (esGerencia) { %><a href="reportes.jsp"><i class="fa-solid fa-chart-simple"></i> Reportes</a><% } %>
    </nav>
    <div class="req-user"><strong><%= usuario.getNombre() %></strong><small>Rol: <%= rolNombre %></small><small>Sesión activa</small></div>
    <a class="req-logout" href="LogoutServlet"><i class="fa-solid fa-right-from-bracket"></i> Cerrar Sesión</a>
</div>
<main class="req-main">
    <header class="req-header"><div><h1>Requerimientos de Obra</h1><p>Registro, observación, aprobación y seguimiento real por estado.</p></div></header>
    <section class="req-body">
        <div class="req-form-card">
            <div class="req-title"><div class="req-title-icon"><i class="fa-solid fa-clipboard-check"></i></div><div><h2>Nuevo Requerimiento</h2><p>Los registros nuevos empiezan en estado PENDIENTE.</p></div></div>
            <form action="RequerimientoServlet" method="post" class="crud-form-grid" id="formRequerimiento">
                <div><label>Material requerido</label><input type="text" name="nombre" required minlength="2" maxlength="100"></div>
                <div><label>Área solicitante</label><input type="text" name="area" required minlength="2" maxlength="100"></div>
                <div><label>Cantidad</label><input type="number" name="cantidad" required min="1" max="1000000"></div>
                <div><label>Fecha límite</label><input type="date" name="fecha" required></div>
                <div class="crud-span-2"><label>Observación</label><textarea name="observacion" maxlength="255" placeholder="Justificación o detalle opcional"></textarea></div>
                <div class="crud-actions"><button type="submit"><i class="fa-solid fa-paper-plane"></i> Registrar Requerimiento</button></div>
            </form>
            <% if (request.getParameter("ok") != null) { %><p class="req-ok">Requerimiento registrado correctamente.</p><% } %>
            <% if (request.getParameter("actualizado") != null) { %><p class="req-ok">Requerimiento actualizado correctamente.</p><% } %>
            <% if (request.getParameter("eliminado") != null) { %><p class="req-ok">Requerimiento eliminado correctamente.</p><% } %>
            <% if ("validacion".equals(request.getParameter("error"))) { %><p class="req-error">Revise material, área, cantidad, fecha, estado y observación.</p>
            <% } else if (request.getParameter("error") != null) { %><p class="req-error">No se pudo completar la operación.</p><% } %>
        </div>

        <div class="req-table-card">
            <div class="req-table-top"><div class="req-table-title"><div class="req-db-icon"><i class="fa-solid fa-wave-square"></i></div><h2>Seguimiento de Obra</h2></div><div class="req-search"><i class="fa-solid fa-magnifying-glass"></i><input id="buscarRequerimientos" placeholder="Buscar requerimiento..."></div></div>
            <div class="table-scroll">
                <table class="req-table tabla-datatables" id="tablaRequerimientos">
                    <thead><tr><th>ID</th><th>Material</th><th>Área</th><th>Cant.</th><th>Estado</th><th>Fecha</th><th>Observación</th><th>Acciones</th></tr></thead>
                    <tbody>
                    <% for (Requerimiento r : requerimientos) {
                        String estado = r.getEstado() == null ? "PENDIENTE" : r.getEstado();
                        String clase = "estado-pendiente";
                        if ("APROBADO".equals(estado)) clase = "estado-aprobado";
                        if ("RECHAZADO".equals(estado)) clase = "estado-rechazado";
                        if ("ATENDIDO".equals(estado)) clase = "estado-atendido";
                    %>
                    <tr>
                        <td>#00<%= r.getId() %></td>
                        <td><strong><%= r.getNombre() %></strong></td>
                        <td><%= r.getArea() %></td>
                        <td><%= r.getCantidad() %> UND</td>
                        <td><span class="estado-crud <%= clase %>"><%= estado %></span></td>
                        <td><%= r.getFecha() %></td>
                        <td><%= r.getObservacion() == null ? "Sin observación" : r.getObservacion() %></td>
                        <td>
                            <details class="crud-edit-details">
                                <summary><i class="fa-solid fa-pen"></i> Editar</summary>
                                <form action="RequerimientoServlet" method="post" class="crud-inline-form">
                                    <input type="hidden" name="accion" value="actualizar"><input type="hidden" name="id" value="<%= r.getId() %>">
                                    <label>Material<input name="nombre" value="<%= r.getNombre() %>" required minlength="2" maxlength="100"></label>
                                    <label>Área<input name="area" value="<%= r.getArea() %>" required minlength="2" maxlength="100"></label>
                                    <label>Cantidad<input type="number" name="cantidad" value="<%= r.getCantidad() %>" required min="1" max="1000000"></label>
                                    <label>Fecha<input type="date" name="fecha" value="<%= r.getFecha() %>" required></label>
                                    <% if (esJefeLogistica) { %>
                                    <label>Estado<select name="estado">
                                        <option value="PENDIENTE" <%= "PENDIENTE".equals(estado) ? "selected" : "" %>>Pendiente</option>
                                        <option value="APROBADO" <%= "APROBADO".equals(estado) ? "selected" : "" %>>Aprobado</option>
                                        <option value="RECHAZADO" <%= "RECHAZADO".equals(estado) ? "selected" : "" %>>Rechazado</option>
                                        <option value="ATENDIDO" <%= "ATENDIDO".equals(estado) ? "selected" : "" %>>Atendido</option>
                                    </select></label>
                                    <% } else { %>
                                    <input type="hidden" name="estado" value="<%= estado %>"><small>El estado solo puede ser modificado por Jefatura de Logística.</small>
                                    <% } %>
                                    <label>Observación<textarea name="observacion" maxlength="255"><%= r.getObservacion() == null ? "" : r.getObservacion() %></textarea></label>
                                    <button type="submit" class="crud-save"><i class="fa-solid fa-check"></i> Guardar</button>
                                </form>
                            </details>
                            <form action="RequerimientoServlet" method="post" class="delete-form"><input type="hidden" name="accion" value="eliminar"><input type="hidden" name="id" value="<%= r.getId() %>"><button type="button" class="btn-eliminar"><i class="fa-solid fa-trash"></i> Eliminar</button></form>
                        </td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
            <div class="req-footer"><span>Total: <%= requerimientos.size() %> requerimientos</span><button onclick="window.print()">Exportar PDF</button></div>
        </div>
    </section>
    <footer class="app-footer">LogiConstruction v1.0 | Usuario: <%= usuario.getNombre() %></footer>
</main>
<script>
const idiomaTabla={emptyTable:'No hay registros',info:'Mostrando _START_ a _END_ de _TOTAL_',infoEmpty:'Mostrando 0',zeroRecords:'Sin coincidencias',paginate:{next:'Siguiente',previous:'Anterior'}};
$(function(){const t=$('#tablaRequerimientos').DataTable({pageLength:5,lengthChange:false,autoWidth:false,dom:'rtip',language:idiomaTabla,columnDefs:[{orderable:false,targets:7}]});$('#buscarRequerimientos').on('keyup',function(){t.search(this.value).draw();});});
document.querySelectorAll('.btn-eliminar').forEach(b=>b.addEventListener('click',function(){const f=this.closest('form');Swal.fire({title:'¿Eliminar requerimiento?',icon:'warning',showCancelButton:true,confirmButtonText:'Sí, eliminar',cancelButtonText:'Cancelar',background:'#0f172a',color:'#fff'}).then(r=>{if(r.isConfirmed)f.submit();});}));
</script>
<%@ include file="/WEB-INF/jspf/chatbot-widget.jspf" %>
<%@ include file="/WEB-INF/jspf/whatsapp-group-button.jspf" %>
</body>
</html>
