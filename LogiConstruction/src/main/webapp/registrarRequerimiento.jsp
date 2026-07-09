<%@page contentType="text/html" pageEncoding="UTF-8"%>
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

    if (!esAdministradorObra && !esJefeLogistica) {
        response.sendRedirect("dashboard.jsp?acceso=denegado");
        return;
    }

    response.sendRedirect("requerimientos.jsp");
%>
