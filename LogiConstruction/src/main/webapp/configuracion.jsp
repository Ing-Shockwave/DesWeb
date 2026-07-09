<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.Properties"%>
<%@page import="com.utp.logiconstruction.conexion.DatabaseConfig"%>
<%!
    private String htmlAttr(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("&", "&amp;")
                    .replace("\"", "&quot;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;");
    }
%>
<%
    Properties dbConfig = DatabaseConfig.cargarConfiguracion();

    String jdbcUrl = (String) request.getAttribute("jdbcUrl");
    String dbUser = (String) request.getAttribute("dbUser");
    String dbPassword = (String) request.getAttribute("dbPassword");

    if (jdbcUrl == null) {
        jdbcUrl = dbConfig.getProperty("db.url", DatabaseConfig.DEFAULT_URL);
    }
    if (dbUser == null) {
        dbUser = dbConfig.getProperty("db.user", DatabaseConfig.DEFAULT_USER);
    }
    if (dbPassword == null) {
        dbPassword = dbConfig.getProperty("db.password", DatabaseConfig.DEFAULT_PASSWORD);
    }

    String error = (String) request.getAttribute("error");
    String exito = (String) request.getAttribute("exito");
    String dbError = request.getParameter("dbError");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Configuración de conexión - LogiConstruction</title>
    <link rel="stylesheet" href="css/estilos.css?v=menu4">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        .config-body {
            min-height: 100vh;
            margin: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            background: #08111f;
            font-family: Arial, sans-serif;
            color: #ffffff;
        }
        .config-card {
            width: 520px;
            max-width: 92%;
            background: rgba(11, 24, 43, 0.96);
            border: 1px solid rgba(0, 198, 255, 0.35);
            border-radius: 18px;
            padding: 28px;
            box-shadow: 0 0 25px rgba(0, 198, 255, 0.18);
        }
        .config-title {
            margin: 0 0 8px 0;
            font-size: 26px;
            text-align: center;
        }
        .config-subtitle {
            margin: 0 0 22px 0;
            text-align: center;
            color: #b9c7d8;
            font-size: 14px;
            line-height: 1.5;
        }
        .config-card label {
            display: block;
            margin-top: 14px;
            margin-bottom: 6px;
            font-weight: bold;
            font-size: 14px;
        }
        .config-card input {
            width: 100%;
            box-sizing: border-box;
            padding: 12px;
            border-radius: 10px;
            border: 1px solid #2e4666;
            background: #07101d;
            color: #ffffff;
            outline: none;
        }
        .config-card input:focus {
            border-color: #00c6ff;
        }
        .config-actions {
            display: flex;
            gap: 12px;
            margin-top: 22px;
        }
        .config-actions button,
        .config-actions a {
            flex: 1;
            text-align: center;
            text-decoration: none;
            border-radius: 10px;
            padding: 12px;
            border: none;
            cursor: pointer;
            font-weight: bold;
        }
        .config-actions button {
            background: #00c6ff;
            color: #07101d;
        }
        .config-actions a {
            background: #1b2b40;
            color: #ffffff;
        }
        .alert-error,
        .alert-success,
        .alert-warning {
            padding: 12px;
            border-radius: 10px;
            margin-bottom: 16px;
            font-size: 14px;
            line-height: 1.4;
        }
        .alert-error {
            background: rgba(255, 67, 67, 0.15);
            border: 1px solid rgba(255, 67, 67, 0.5);
            color: #ffb7b7;
        }
        .alert-success {
            background: rgba(65, 214, 126, 0.15);
            border: 1px solid rgba(65, 214, 126, 0.5);
            color: #b9ffd4;
        }
        .alert-warning {
            background: rgba(255, 193, 7, 0.14);
            border: 1px solid rgba(255, 193, 7, 0.45);
            color: #ffe7a3;
        }
        .config-path {
            margin-top: 18px;
            font-size: 12px;
            color: #9fb0c4;
            word-break: break-all;
            text-align: center;
        }
    </style>
</head>
<body class="config-body">

    <div class="config-card">
        <h1 class="config-title"><i class="fa-solid fa-database"></i> Configuración MySQL</h1>
        <p class="config-subtitle">
            Ingresa los datos de conexión de la computadora donde se ejecutará LogiConstruction.
        </p>

        <% if (dbError != null) { %>
            <div class="alert-warning">
                No se pudo conectar a MySQL. Verifica la URL, usuario y contraseña.
            </div>
        <% } %>

        <% if (error != null) { %>
            <div class="alert-error"><%= error %></div>
        <% } %>

        <% if (exito != null) { %>
            <div class="alert-success"><%= exito %></div>
        <% } %>

        <form action="ConfigDBServlet" method="post">
            <label for="jdbcUrl">URL JDBC de MySQL</label>
            <input type="text" id="jdbcUrl" name="jdbcUrl" value="<%= htmlAttr(jdbcUrl) %>" required>

            <label for="dbUser">Usuario de MySQL</label>
            <input type="text" id="dbUser" name="dbUser" value="<%= htmlAttr(dbUser) %>" required>

            <label for="dbPassword">Contraseña de MySQL</label>
            <input type="password" id="dbPassword" name="dbPassword" value="<%= htmlAttr(dbPassword) %>">

            <div class="config-actions">
                <button type="submit">
                    <i class="fa-solid fa-plug-circle-check"></i> Probar y guardar
                </button>
                <a href="login.jsp">Volver al login</a>
            </div>
        </form>

        <div class="config-path">
            Archivo externo: <%= DatabaseConfig.getConfigPath().toString() %>
        </div>
    </div>

</body>
</html>
