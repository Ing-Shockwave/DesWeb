<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Login - LogiConstruction</title>
    <link rel="stylesheet"
    href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

    <link rel="stylesheet" href="css/estilos.css?v=menu4">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        .config-link {
            display: block;
            margin-top: 14px;
            text-align: center;
            color: #00c6ff;
            text-decoration: none;
            font-weight: bold;
            font-size: 14px;
        }
        .config-link:hover {
            text-decoration: underline;
        }
        .success-neon {
            margin-top: 14px;
            padding: 10px;
            border-radius: 8px;
            background: rgba(65, 214, 126, 0.15);
            color: #b9ffd4;
            border: 1px solid rgba(65, 214, 126, 0.5);
            text-align: center;
        }
    </style>
</head>

<body class="login-neon-body">

    <div class="neon-bg"></div>

    <div class="login-wrapper">

        <div class="helmet-icon">⛑</div>

        <h1 class="login-title">
            Logi<span>Construction</span>
        </h1>

        <p class="login-subtitle">
            Sistema de Gestión Logística en Construcción
        </p>

        <div class="login-neon-card">

            <form action="LoginServlet" method="post">

                <label>Correo electrónico</label>
                <input type="email" name="correo" placeholder="nombre@empresa.com" required>

                <div class="password-row">
                    <label>Contraseña</label>
                    <a href="#">¿Olvidaste tu contraseña?</a>
                </div>

                <input type="password" name="password" placeholder="••••••••" required>

                <div class="remember">
                    <input type="checkbox">
                    <span>Recordar sesión</span>
                </div>

                <button type="submit">
                    Iniciar sesión
                </button>

                <a class="config-link" href="configuracion.jsp">
                    <i class="fa-solid fa-gear"></i> Configurar conexión
                </a>

            </form>

            <%
                String error = request.getParameter("error");
                if (error != null) {
            %>
                <div class="error-neon">Correo o contraseña incorrectos</div>
            <%
                }

                String configOk = request.getParameter("config");
                if (configOk != null) {
            %>
                <div class="success-neon">Configuración guardada correctamente</div>
            <%
                }
            %>

            <div class="login-footer">
                ¿No tienes acceso?
                <span>Contacta con administración</span>
            </div>

        </div>

        <p class="copyright">
            © 2026 LOGICONSTRUCTION SOLUTIONS S.A.C.
        </p>

    </div>

</body>
</html>
