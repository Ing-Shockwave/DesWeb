<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.utp.logiconstruction.dao.CompraDAO"%>
<%@page import="com.utp.logiconstruction.dao.ProveedorDAO"%>
<%@page import="com.utp.logiconstruction.modelo.Compra"%>
<%@page import="com.utp.logiconstruction.modelo.Proveedor"%>
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

    List<Compra> compras = new CompraDAO().listarCompras();
    List<Proveedor> proveedores = new ProveedorDAO().listarProveedores();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Compras - LogiConstruction</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.8/css/jquery.dataTables.min.css">
    <link rel="stylesheet" href="css/estilos.css?v=crud-seguro3">
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.8/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body class="compras-page">
<div class="compras-sidebar">
    <div class="compras-logo">
        <div class="compras-logo-icon">🏗</div>
        <div><h2>Logi<span>Con</span></h2><p>PRO VERSION</p></div>
    </div>
    <nav class="compras-menu">
        <a href="dashboard.jsp"><i class="fa-solid fa-chart-column"></i> Dashboard</a>
        <% if (esJefeLogistica) { %>
        <a class="activo" href="compras.jsp"><i class="fa-solid fa-cart-shopping"></i> Compras</a>
        <a href="proveedores.jsp"><i class="fa-solid fa-users"></i> Proveedores</a>
        <% } %>
        <% if (esAdministradorObra || esJefeLogistica) { %>
        <a href="requerimientos.jsp"><i class="fa-solid fa-file-lines"></i> Requerimientos</a>
        <% } %>
        <% if (esAdministradorObra) { %>
        <a href="requerimientos-jsf.xhtml"><i class="fa-solid fa-code"></i> Demo JSF</a>
        <% } %>
        <% if (esGerencia) { %>
        <a href="reportes.jsp"><i class="fa-solid fa-chart-simple"></i> Reportes</a>
        <% } %>
    </nav>
    <div class="compras-user">
        <strong><%= usuario.getNombre() %></strong>
        <small>Rol: <%= rolNombre %></small>
        <small>Sesión activa</small>
    </div>
    <a class="compras-logout" href="LogoutServlet"><i class="fa-solid fa-right-from-bracket"></i> Cerrar Sesión</a>
</div>

<main class="compras-main">
    <header class="compras-header">
        <div><h1>Gestión de Compras</h1><p>Registra y actualiza compras, costos y estados.</p></div>
        <div class="compras-search"><i class="fa-solid fa-magnifying-glass"></i><input type="text" id="buscarCompras" placeholder="Buscar compras..."></div>
    </header>

    <section class="compras-body">
        <div class="compras-hero">
            <div><h2>Módulo de Compras</h2><p>Controla el ciclo de cada compra y calcula automáticamente su costo total.</p></div>
            <div class="hero-watermark">🛒</div>
        </div>

        <div class="compras-card">
            <h2>Nueva Compra</h2>
            <form action="CompraServlet" method="post" class="crud-form-grid" id="formCompra">
                <div>
                    <label>Proveedor</label>
                    <select name="proveedor" required>
                        <option value="">Seleccione...</option>
                        <% for (Proveedor p : proveedores) {
                            if ("ACTIVO".equals(p.getEstado())) { %>
                        <option value="<%= p.getNombre() %>"><%= p.getNombre() %></option>
                        <% }} %>
                    </select>
                </div>
                <div>
                    <label>Producto o material</label>
                    <input type="text" name="producto" list="listaMateriales" required minlength="2" maxlength="100">
                </div>
                <div>
                    <label>Cantidad</label>
                    <input type="number" name="cantidad" required min="1" max="1000000" step="1">
                </div>
                <div>
                    <label>Costo unitario (S/)</label>
                    <input type="number" name="costoUnitario" required min="0" max="99999999.99" step="0.01">
                </div>
                <div>
                    <label>Estado</label>
                    <select name="estado" required>
                        <option value="REGISTRADA">Registrada</option>
                        <option value="RECIBIDA">Recibida</option>
                        <option value="ANULADA">Anulada</option>
                    </select>
                </div>
                <div class="crud-actions"><button type="submit"><i class="fa-solid fa-floppy-disk"></i> Registrar Compra</button></div>
            </form>

            <datalist id="listaMateriales">
                <option value="Acero corrugado"><option value="Arena fina"><option value="Arena gruesa">
                <option value="Cemento Portland"><option value="Clavos"><option value="Concreto premezclado">
                <option value="Fierro"><option value="Ladrillo King Kong"><option value="Madera">
                <option value="Pintura"><option value="Tornillos"><option value="Tubería PVC"><option value="Yeso">
            </datalist>

            <% if (request.getParameter("ok") != null) { %><p class="compras-ok">Compra registrada correctamente.</p><% } %>
            <% if (request.getParameter("actualizado") != null) { %><p class="compras-ok">Compra actualizada correctamente.</p><% } %>
            <% if (request.getParameter("eliminado") != null) { %><p class="compras-ok">Compra eliminada correctamente.</p><% } %>
            <% if ("validacion".equals(request.getParameter("error"))) { %>
            <p class="compras-error">Revise proveedor, producto, cantidad, costo y estado.</p>
            <% } else if (request.getParameter("error") != null) { %>
            <p class="compras-error">No se pudo completar la operación. Verifique la conexión y los datos.</p>
            <% } %>
        </div>

        <div class="compras-card">
            <div class="compras-card-head"><h2>Compras Registradas</h2><span>Edición completa habilitada</span></div>
            <div class="table-scroll">
                <table class="compras-table tabla-datatables" id="tablaCompras">
                    <thead><tr>
                        <th>ID</th><th>Proveedor</th><th>Producto</th><th>Cantidad</th><th>C. unitario</th>
                        <th>Total</th><th>Estado</th><th>Fecha</th><th>Acciones</th>
                    </tr></thead>
                    <tbody>
                    <% for (Compra c : compras) {
                        String estado = c.getEstado() == null ? "REGISTRADA" : c.getEstado();
                        String clase = "estado-registrada";
                        if ("RECIBIDA".equals(estado)) clase = "estado-recibida";
                        if ("ANULADA".equals(estado)) clase = "estado-anulada";
                    %>
                    <tr>
                        <td>#CMP-<%= c.getId() %></td>
                        <td><%= c.getProveedor() %></td>
                        <td><%= c.getProducto() %></td>
                        <td><%= c.getCantidad() %></td>
                        <td>S/ <%= c.getCostoUnitario() == null ? "0.00" : c.getCostoUnitario().setScale(2) %></td>
                        <td><strong>S/ <%= c.getCostoTotal().setScale(2) %></strong></td>
                        <td><span class="estado-crud <%= clase %>"><%= estado %></span></td>
                        <td><small><%= c.getFecha() == null ? "" : c.getFecha() %></small></td>
                        <td>
                            <details class="crud-edit-details">
                                <summary><i class="fa-solid fa-pen"></i> Editar</summary>
                                <form action="CompraServlet" method="post" class="crud-inline-form">
                                    <input type="hidden" name="accion" value="actualizar">
                                    <input type="hidden" name="id" value="<%= c.getId() %>">
                                    <label>Proveedor<input type="text" name="proveedor" value="<%= c.getProveedor() %>" required minlength="2" maxlength="100"></label>
                                    <label>Producto<input type="text" name="producto" value="<%= c.getProducto() %>" required minlength="2" maxlength="100"></label>
                                    <label>Cantidad<input type="number" name="cantidad" value="<%= c.getCantidad() %>" required min="1" max="1000000"></label>
                                    <label>Costo unitario<input type="number" name="costoUnitario" value="<%= c.getCostoUnitario() == null ? "0.00" : c.getCostoUnitario() %>" required min="0" step="0.01"></label>
                                    <label>Estado<select name="estado">
                                        <option value="REGISTRADA" <%= "REGISTRADA".equals(estado) ? "selected" : "" %>>Registrada</option>
                                        <option value="RECIBIDA" <%= "RECIBIDA".equals(estado) ? "selected" : "" %>>Recibida</option>
                                        <option value="ANULADA" <%= "ANULADA".equals(estado) ? "selected" : "" %>>Anulada</option>
                                    </select></label>
                                    <button type="submit" class="crud-save"><i class="fa-solid fa-check"></i> Guardar</button>
                                </form>
                            </details>
                            <form action="CompraServlet" method="post" class="delete-form">
                                <input type="hidden" name="accion" value="eliminar">
                                <input type="hidden" name="id" value="<%= c.getId() %>">
                                <button type="button" class="btn-eliminar"><i class="fa-solid fa-trash"></i> Eliminar</button>
                            </form>
                        </td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </section>
    <footer class="app-footer">LogiConstruction v1.0 | Usuario: <%= usuario.getNombre() %></footer>
</main>

<script>
const idiomaTabla = {emptyTable:'No hay registros disponibles',info:'Mostrando _START_ a _END_ de _TOTAL_',infoEmpty:'Mostrando 0 registros',infoFiltered:'(filtrado de _MAX_)',zeroRecords:'No se encontraron coincidencias',paginate:{next:'Siguiente',previous:'Anterior'}};
$(function(){
    const tabla=$('#tablaCompras').DataTable({pageLength:5,lengthChange:false,autoWidth:false,dom:'rtip',language:idiomaTabla,columnDefs:[{orderable:false,targets:8}]});
    $('#buscarCompras').on('keyup',function(){tabla.search(this.value).draw();});
});
document.querySelectorAll('.btn-eliminar').forEach(b=>b.addEventListener('click',function(){
    const f=this.closest('form');
    Swal.fire({title:'¿Eliminar compra?',text:'Esta acción no se puede deshacer.',icon:'warning',showCancelButton:true,confirmButtonText:'Sí, eliminar',cancelButtonText:'Cancelar',background:'#0f172a',color:'#fff'}).then(r=>{if(r.isConfirmed)f.submit();});
}));
</script>
<%@ include file="/WEB-INF/jspf/chatbot-widget.jspf" %>
<%@ include file="/WEB-INF/jspf/whatsapp-group-button.jspf" %>
</body>
</html>
