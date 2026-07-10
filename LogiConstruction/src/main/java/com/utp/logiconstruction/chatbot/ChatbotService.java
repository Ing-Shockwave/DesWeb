package com.utp.logiconstruction.chatbot;

import com.utp.logiconstruction.conexion.Conexion;
import com.utp.logiconstruction.modelo.Usuario;
import com.utp.logiconstruction.util.AuthUtil;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.NumberFormat;
import java.text.Normalizer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Motor informativo de LogiBot basado en reglas y consultas de solo lectura.
 * No ejecuta instrucciones SQL proporcionadas por el usuario ni modifica datos.
 */
public class ChatbotService {

    private static final Pattern NUMERO_PATTERN = Pattern.compile("\\b(\\d+)\\b");
    private static final String WHATSAPP_GRUPO
            = "https://chat.whatsapp.com/Iv5RKWKGjoK0WuNp50knEG";

    public ChatbotResponse responder(String mensajeOriginal, Usuario usuario) {
        String mensaje = normalizar(mensajeOriginal);

        if (mensaje.isEmpty()) {
            return respuestaAyuda(usuario,
                    "Escribe una consulta o selecciona una opción rápida para comenzar.");
        }

        if (esSaludo(mensaje)) {
            String nombre = usuario == null ? "usuario" : usuario.getNombre();
            return new ChatbotResponse(
                    "¡Hola, " + nombre + "! Soy LogiBot, el asistente informativo de "
                    + "LogiConstruction. Puedo orientarte según tu rol y consultar datos "
                    + "actuales del sistema.",
                    "SALUDO",
                    sugerenciasPorRol(usuario)
            );
        }

        if (contieneAlguno(mensaje, "que puedes hacer", "como puedes ayudar", "ayuda", "opciones", "comandos")) {
            return respuestaAyuda(usuario,
                    "Puedo explicar el uso de los módulos, informar tus permisos y consultar "
                    + "compras, proveedores y requerimientos registrados en MySQL.");
        }

        if (contieneAlguno(mensaje, "mi rol", "cual es mi rol", "quien soy", "mis permisos", "que puedo hacer con mi rol")) {
            return respuestaRol(usuario);
        }

        if (contieneAlguno(mensaje, "contactar soporte", "contacto soporte", "whatsapp", "grupo de soporte", "administracion")) {
            return new ChatbotResponse(
                    "Puedes comunicarte con el grupo de soporte académico de LogiConstruction "
                    + "mediante WhatsApp.",
                    "SOPORTE",
                    sugerenciasPorRol(usuario),
                    WHATSAPP_GRUPO,
                    "Abrir grupo de soporte"
            );
        }

        if (contieneAlguno(mensaje, "configurar conexion", "conexion mysql", "cambiar mysql", "db.properties", "configuracion de base")) {
            return new ChatbotResponse(
                    "Abre la pantalla «Configuración MySQL», ingresa la URL JDBC, el usuario y "
                    + "la contraseña, y pulsa «Probar y guardar». La configuración se almacena "
                    + "fuera del código en la carpeta .logiconstruction del usuario.",
                    "GUIA",
                    sugerenciasPorRol(usuario),
                    "configuracion.jsp",
                    "Abrir configuración MySQL"
            );
        }

        if (contieneAlguno(mensaje, "cerrar sesion", "salir del sistema", "logout")) {
            return new ChatbotResponse(
                    "Para cerrar la sesión de forma segura, utiliza la opción «Cerrar Sesión» "
                    + "ubicada en la parte inferior del menú lateral.",
                    "GUIA",
                    sugerenciasPorRol(usuario)
            );
        }

        // Consultas específicas de requerimientos antes de las guías generales.
        if (contieneAlguno(mensaje, "estado del requerimiento", "estado de requerimiento", "consultar requerimiento")) {
            Integer id = extraerPrimerNumero(mensaje);
            if (id == null) {
                return new ChatbotResponse(
                        "Indica el número del requerimiento. Ejemplo: «¿Cuál es el estado del requerimiento 2?». ",
                        "ACLARACION",
                        Arrays.asList("Estado del requerimiento 1", "Requerimientos pendientes")
                );
            }
            return consultarEstadoRequerimiento(id, usuario);
        }

        if (contieneAlguno(mensaje, "requerimientos pendientes", "cuantos pendientes", "solicitudes pendientes")) {
            return consultarRequerimientosPendientes(usuario);
        }

        if (contieneAlguno(mensaje, "ultimos requerimientos", "listar requerimientos", "ver requerimientos recientes")) {
            return consultarUltimosRequerimientos(usuario);
        }

        if (contieneAlguno(mensaje, "como registrar un requerimiento", "como registro un requerimiento", "registrar requerimiento", "crear requerimiento", "nuevo requerimiento")) {
            return guiaRegistrarRequerimiento(usuario);
        }

        if (contieneAlguno(mensaje, "demo jsf", "pagina jsf", "validaciones jsf")) {
            if (usuario != null && AuthUtil.ADMINISTRADOR_OBRA.equals(usuario.getRol())) {
                return new ChatbotResponse(
                        "La demostración JSF permite registrar y consultar requerimientos usando "
                        + "componentes JSF 2.3 y validaciones del lado del servidor.",
                        "GUIA",
                        sugerenciasPorRol(usuario),
                        "requerimientos-jsf.xhtml",
                        "Abrir Demo JSF"
                );
            }
            return accesoNoDisponible("Demo JSF", "Administrador de Obra", usuario);
        }

        // Proveedores.
        if (contieneAlguno(mensaje, "cuantos proveedores", "proveedores activos", "total proveedores")) {
            return consultarTotalProveedores(usuario);
        }

        if (contieneAlguno(mensaje, "listar proveedores", "nombres de proveedores", "que proveedores hay", "proveedores registrados")) {
            return consultarProveedores(usuario);
        }

        if (contieneAlguno(mensaje, "como registrar un proveedor", "como registro un proveedor", "registrar proveedor", "nuevo proveedor", "crear proveedor")) {
            return guiaRegistrarProveedor(usuario);
        }

        // Compras.
        if (contieneAlguno(mensaje, "cuantas compras", "total compras", "compras registradas")) {
            return consultarTotalCompras(usuario);
        }

        if (contieneAlguno(mensaje, "ultimas compras", "compras recientes", "listar compras")) {
            return consultarUltimasCompras(usuario);
        }

        if (contieneAlguno(mensaje, "material mas comprado", "producto mas comprado")) {
            return consultarMaterialMasComprado(usuario);
        }

        if (contieneAlguno(mensaje, "proveedor mas usado", "principal proveedor")) {
            return consultarProveedorMasUsado(usuario);
        }

        if (contieneAlguno(mensaje, "como registrar una compra", "como registro una compra", "registrar compra", "nueva compra", "crear compra")) {
            return guiaRegistrarCompra(usuario);
        }

        // Reportes y resumen.
        if (contieneAlguno(mensaje, "costo total", "monto total", "valor de compras")) {
            return consultarCostoTotal(usuario);
        }

        if (contieneAlguno(mensaje, "resumen del sistema", "resumen general", "estado general", "indicadores")) {
            return consultarResumen(usuario);
        }

        if (contieneAlguno(mensaje, "como veo los reportes", "ver reportes", "modulo reportes", "donde estan los reportes")) {
            if (usuario != null && AuthUtil.GERENCIA.equals(usuario.getRol())) {
                return new ChatbotResponse(
                        "El módulo Reportes se encuentra en el menú lateral de Gerencia. Allí "
                        + "puedes revisar indicadores y gráficos logísticos actualizados.",
                        "GUIA",
                        sugerenciasPorRol(usuario),
                        "reportes.jsp",
                        "Abrir reportes"
                );
            }
            return accesoNoDisponible("Reportes", "Gerencia", usuario);
        }

        if (contieneAlguno(mensaje, "requerimientos", "solicitudes")) {
            return consultarTotalRequerimientos(usuario);
        }

        if (contieneAlguno(mensaje, "proveedores")) {
            return consultarTotalProveedores(usuario);
        }

        if (contieneAlguno(mensaje, "compras")) {
            return consultarTotalCompras(usuario);
        }

        return respuestaAyuda(usuario,
                "No reconocí esa consulta. LogiBot trabaja con preguntas informativas y comandos "
                + "seguros. Prueba con una de las sugerencias disponibles.");
    }

    private ChatbotResponse respuestaRol(Usuario usuario) {
        if (usuario == null) {
            return new ChatbotResponse(
                    "No se encontró una sesión activa. Inicia sesión para recibir orientación según tu rol.",
                    "SESION",
                    Collections.<String>emptyList(),
                    "login.jsp",
                    "Ir al inicio de sesión"
            );
        }

        String rolNombre = AuthUtil.nombreRol(usuario.getRol());
        String funciones;

        if (AuthUtil.ADMINISTRADOR_OBRA.equals(usuario.getRol())) {
            funciones = "Puedes acceder al Dashboard, registrar y consultar requerimientos, "
                    + "y utilizar la página demostrativa JSF.";
        } else if (AuthUtil.JEFE_LOGISTICA.equals(usuario.getRol())) {
            funciones = "Puedes gestionar compras y proveedores, además de consultar y atender "
                    + "los requerimientos de obra.";
        } else if (AuthUtil.GERENCIA.equals(usuario.getRol())) {
            funciones = "Puedes supervisar el Dashboard y consultar reportes e indicadores para "
                    + "la toma de decisiones.";
        } else {
            funciones = "Tu rol no tiene funciones configuradas en LogiBot.";
        }

        return new ChatbotResponse(
                "Tu sesión corresponde a «" + rolNombre + "». " + funciones,
                "ROL",
                sugerenciasPorRol(usuario)
        );
    }

    private ChatbotResponse guiaRegistrarRequerimiento(Usuario usuario) {
        if (!tieneRol(usuario, AuthUtil.ADMINISTRADOR_OBRA, AuthUtil.JEFE_LOGISTICA)) {
            return accesoNoDisponible("Requerimientos", "Administrador de Obra o Jefe de Logística", usuario);
        }

        return new ChatbotResponse(
                "Ingresa al módulo Requerimientos, completa el material, el área, la cantidad y "
                + "la fecha. Los campos son obligatorios y la cantidad debe ser mayor que cero.",
                "GUIA",
                sugerenciasPorRol(usuario),
                "requerimientos.jsp",
                "Abrir requerimientos"
        );
    }

    private ChatbotResponse guiaRegistrarProveedor(Usuario usuario) {
        if (!tieneRol(usuario, AuthUtil.JEFE_LOGISTICA)) {
            return accesoNoDisponible("Proveedores", "Jefe de Logística", usuario);
        }

        return new ChatbotResponse(
                "Ingresa al módulo Proveedores y completa nombre, RUC, teléfono y correo. El RUC "
                + "es obligatorio, numérico, admite hasta 11 dígitos y no puede repetirse.",
                "GUIA",
                sugerenciasPorRol(usuario),
                "proveedores.jsp",
                "Abrir proveedores"
        );
    }

    private ChatbotResponse guiaRegistrarCompra(Usuario usuario) {
        if (!tieneRol(usuario, AuthUtil.JEFE_LOGISTICA)) {
            return accesoNoDisponible("Compras", "Jefe de Logística", usuario);
        }

        return new ChatbotResponse(
                "Ingresa al módulo Compras, selecciona o escribe el proveedor, registra el producto "
                + "y coloca una cantidad mayor que cero. Luego pulsa el botón de registro.",
                "GUIA",
                sugerenciasPorRol(usuario),
                "compras.jsp",
                "Abrir compras"
        );
    }

    private ChatbotResponse consultarResumen(Usuario usuario) {
        if (!tieneRol(usuario, AuthUtil.GERENCIA)) {
            return accesoNoDisponible("Resumen gerencial", "Gerencia", usuario);
        }

        try (Connection con = Conexion.conectar()) {
            int compras = contar(con, "SELECT COUNT(*) FROM compras");
            int proveedores = contarProveedoresActivos(con);
            int requerimientos = contar(con, "SELECT COUNT(*) FROM requerimientos");
            int pendientes = contarPendientes(con);

            return new ChatbotResponse(
                    "Resumen actual: " + compras + " compras registradas, " + proveedores
                    + " proveedores activos, " + requerimientos + " requerimientos en total y "
                    + pendientes + " pendientes.",
                    "BASE_DATOS",
                    sugerenciasPorRol(usuario),
                    "reportes.jsp",
                    "Ver reportes"
            );
        } catch (SQLException e) {
            return errorConexion(usuario, e);
        }
    }

    private ChatbotResponse consultarTotalCompras(Usuario usuario) {
        try (Connection con = Conexion.conectar()) {
            int total = contar(con, "SELECT COUNT(*) FROM compras");
            return new ChatbotResponse(
                    "Actualmente hay " + total + " compras registradas en LogiConstruction.",
                    "BASE_DATOS",
                    sugerenciasPorRol(usuario),
                    tieneRol(usuario, AuthUtil.JEFE_LOGISTICA) ? "compras.jsp" : null,
                    tieneRol(usuario, AuthUtil.JEFE_LOGISTICA) ? "Abrir compras" : null
            );
        } catch (SQLException e) {
            return errorConexion(usuario, e);
        }
    }

    private ChatbotResponse consultarTotalProveedores(Usuario usuario) {
        try (Connection con = Conexion.conectar()) {
            int total = contarProveedoresActivos(con);
            return new ChatbotResponse(
                    "Actualmente hay " + total + " proveedores activos registrados.",
                    "BASE_DATOS",
                    sugerenciasPorRol(usuario),
                    tieneRol(usuario, AuthUtil.JEFE_LOGISTICA) ? "proveedores.jsp" : null,
                    tieneRol(usuario, AuthUtil.JEFE_LOGISTICA) ? "Abrir proveedores" : null
            );
        } catch (SQLException e) {
            return errorConexion(usuario, e);
        }
    }

    private ChatbotResponse consultarTotalRequerimientos(Usuario usuario) {
        try (Connection con = Conexion.conectar()) {
            int total = contar(con, "SELECT COUNT(*) FROM requerimientos");
            return new ChatbotResponse(
                    "Actualmente hay " + total + " requerimientos registrados en el sistema.",
                    "BASE_DATOS",
                    sugerenciasPorRol(usuario),
                    tieneRol(usuario, AuthUtil.ADMINISTRADOR_OBRA, AuthUtil.JEFE_LOGISTICA)
                            ? "requerimientos.jsp" : null,
                    tieneRol(usuario, AuthUtil.ADMINISTRADOR_OBRA, AuthUtil.JEFE_LOGISTICA)
                            ? "Abrir requerimientos" : null
            );
        } catch (SQLException e) {
            return errorConexion(usuario, e);
        }
    }

    private ChatbotResponse consultarRequerimientosPendientes(Usuario usuario) {
        try (Connection con = Conexion.conectar()) {
            int total = contarPendientes(con);
            return new ChatbotResponse(
                    "Hay " + total + " requerimientos con estado PENDIENTE.",
                    "BASE_DATOS",
                    Arrays.asList("Listar últimos requerimientos", "Estado del requerimiento 1"),
                    tieneRol(usuario, AuthUtil.ADMINISTRADOR_OBRA, AuthUtil.JEFE_LOGISTICA)
                            ? "requerimientos.jsp" : null,
                    tieneRol(usuario, AuthUtil.ADMINISTRADOR_OBRA, AuthUtil.JEFE_LOGISTICA)
                            ? "Revisar requerimientos" : null
            );
        } catch (SQLException e) {
            return errorConexion(usuario, e);
        }
    }

    private ChatbotResponse consultarEstadoRequerimiento(int id, Usuario usuario) {
        String sql = "SELECT id, nombre, area, cantidad, fecha, estado FROM requerimientos WHERE id = ?";

        try (Connection con = Conexion.conectar();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return new ChatbotResponse(
                            "No encontré un requerimiento con el ID " + id + ".",
                            "NO_ENCONTRADO",
                            Arrays.asList("Requerimientos pendientes", "Listar últimos requerimientos")
                    );
                }

                String respuesta = "El requerimiento #" + rs.getInt("id") + " corresponde a «"
                        + rs.getString("nombre") + "», área " + rs.getString("area")
                        + ", cantidad " + rs.getInt("cantidad") + ", fecha "
                        + rs.getDate("fecha") + " y estado " + rs.getString("estado") + ".";

                return new ChatbotResponse(
                        respuesta,
                        "BASE_DATOS",
                        Arrays.asList("Requerimientos pendientes", "¿Cómo registro un requerimiento?"),
                        tieneRol(usuario, AuthUtil.ADMINISTRADOR_OBRA, AuthUtil.JEFE_LOGISTICA)
                                ? "requerimientos.jsp" : null,
                        tieneRol(usuario, AuthUtil.ADMINISTRADOR_OBRA, AuthUtil.JEFE_LOGISTICA)
                                ? "Abrir requerimientos" : null
                );
            }
        } catch (SQLException e) {
            return errorConexion(usuario, e);
        }
    }

    private ChatbotResponse consultarUltimosRequerimientos(Usuario usuario) {
        String sql = "SELECT id, nombre, area, cantidad, estado FROM requerimientos ORDER BY id DESC LIMIT 5";

        try (Connection con = Conexion.conectar();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            List<String> filas = new ArrayList<>();
            while (rs.next()) {
                filas.add("#" + rs.getInt("id") + " " + rs.getString("nombre")
                        + " — " + rs.getString("area") + " — " + rs.getInt("cantidad")
                        + " — " + rs.getString("estado"));
            }

            String respuesta = filas.isEmpty()
                    ? "No hay requerimientos registrados."
                    : "Últimos requerimientos:\n• " + String.join("\n• ", filas);

            return new ChatbotResponse(
                    respuesta,
                    "BASE_DATOS",
                    Arrays.asList("Requerimientos pendientes", "Estado del requerimiento 1"),
                    tieneRol(usuario, AuthUtil.ADMINISTRADOR_OBRA, AuthUtil.JEFE_LOGISTICA)
                            ? "requerimientos.jsp" : null,
                    tieneRol(usuario, AuthUtil.ADMINISTRADOR_OBRA, AuthUtil.JEFE_LOGISTICA)
                            ? "Abrir requerimientos" : null
            );
        } catch (SQLException e) {
            return errorConexion(usuario, e);
        }
    }

    private ChatbotResponse consultarProveedores(Usuario usuario) {
        String sql = "SELECT nombre, ruc FROM proveedores WHERE estado = 'ACTIVO' ORDER BY nombre LIMIT 5";

        try (Connection con = Conexion.conectar();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            List<String> filas = new ArrayList<>();
            while (rs.next()) {
                filas.add(rs.getString("nombre") + " — RUC " + rs.getString("ruc"));
            }

            String respuesta = filas.isEmpty()
                    ? "No hay proveedores activos registrados."
                    : "Proveedores activos:\n• " + String.join("\n• ", filas);

            return new ChatbotResponse(
                    respuesta,
                    "BASE_DATOS",
                    Arrays.asList("¿Cuántos proveedores activos hay?", "Proveedor más usado"),
                    tieneRol(usuario, AuthUtil.JEFE_LOGISTICA) ? "proveedores.jsp" : null,
                    tieneRol(usuario, AuthUtil.JEFE_LOGISTICA) ? "Abrir proveedores" : null
            );
        } catch (SQLException e) {
            return errorConexion(usuario, e);
        }
    }

    private ChatbotResponse consultarUltimasCompras(Usuario usuario) {
        String sql = "SELECT producto, proveedor, cantidad, fecha FROM compras ORDER BY id DESC LIMIT 3";

        try (Connection con = Conexion.conectar();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            List<String> filas = new ArrayList<>();
            while (rs.next()) {
                filas.add(rs.getString("producto") + " — " + rs.getString("proveedor")
                        + " — cantidad " + rs.getInt("cantidad") + " — "
                        + rs.getTimestamp("fecha"));
            }

            String respuesta = filas.isEmpty()
                    ? "No hay compras registradas."
                    : "Últimas compras:\n• " + String.join("\n• ", filas);

            return new ChatbotResponse(
                    respuesta,
                    "BASE_DATOS",
                    Arrays.asList("Material más comprado", "Proveedor más usado"),
                    tieneRol(usuario, AuthUtil.JEFE_LOGISTICA) ? "compras.jsp" : null,
                    tieneRol(usuario, AuthUtil.JEFE_LOGISTICA) ? "Abrir compras" : null
            );
        } catch (SQLException e) {
            return errorConexion(usuario, e);
        }
    }

    private ChatbotResponse consultarMaterialMasComprado(Usuario usuario) {
        String sql = "SELECT producto, SUM(cantidad) total FROM compras "
                + "GROUP BY producto ORDER BY total DESC LIMIT 1";
        return consultarDatoDestacado(sql,
                "producto", "total",
                "El material con mayor cantidad comprada es «%s», con %s unidades registradas.",
                "No hay compras suficientes para identificar un material destacado.",
                usuario);
    }

    private ChatbotResponse consultarProveedorMasUsado(Usuario usuario) {
        String sql = "SELECT proveedor, COUNT(*) total FROM compras "
                + "GROUP BY proveedor ORDER BY total DESC LIMIT 1";
        return consultarDatoDestacado(sql,
                "proveedor", "total",
                "El proveedor con más registros de compra es «%s», con %s compras.",
                "No hay compras suficientes para identificar un proveedor destacado.",
                usuario);
    }

    private ChatbotResponse consultarDatoDestacado(String sql, String columnaNombre,
            String columnaTotal, String formato, String sinDatos, Usuario usuario) {
        try (Connection con = Conexion.conectar();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            String respuesta = sinDatos;
            if (rs.next()) {
                respuesta = String.format(formato,
                        rs.getString(columnaNombre), rs.getString(columnaTotal));
            }

            return new ChatbotResponse(
                    respuesta,
                    "BASE_DATOS",
                    sugerenciasPorRol(usuario)
            );
        } catch (SQLException e) {
            return errorConexion(usuario, e);
        }
    }

    private ChatbotResponse consultarCostoTotal(Usuario usuario) {
        if (!tieneRol(usuario, AuthUtil.GERENCIA, AuthUtil.JEFE_LOGISTICA)) {
            return accesoNoDisponible("Costo estimado de compras", "Gerencia o Jefe de Logística", usuario);
        }

        String sql = "SELECT COALESCE(SUM(cantidad * costo_unitario), 0) FROM compras "
                + "WHERE estado <> 'ANULADA'";

        try (Connection con = Conexion.conectar();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            BigDecimal total = BigDecimal.ZERO;
            if (rs.next()) {
                total = rs.getBigDecimal(1);
            }

            NumberFormat formato = NumberFormat.getCurrencyInstance(new Locale("es", "PE"));
            return new ChatbotResponse(
                    "El costo estimado acumulado de las compras no anuladas es "
                    + formato.format(total) + ".",
                    "BASE_DATOS",
                    sugerenciasPorRol(usuario),
                    tieneRol(usuario, AuthUtil.GERENCIA) ? "reportes.jsp" : "compras.jsp",
                    tieneRol(usuario, AuthUtil.GERENCIA) ? "Ver reportes" : "Abrir compras"
            );
        } catch (SQLException e) {
            return errorConexion(usuario, e);
        }
    }

    private int contarProveedoresActivos(Connection con) throws SQLException {
        try {
            return contar(con, "SELECT COUNT(*) FROM proveedores WHERE estado = 'ACTIVO'");
        } catch (SQLException e) {
            // Compatibilidad con una versión anterior de la tabla sin columna estado.
            return contar(con, "SELECT COUNT(*) FROM proveedores");
        }
    }

    private int contarPendientes(Connection con) throws SQLException {
        return contar(con, "SELECT COUNT(*) FROM requerimientos WHERE estado = 'PENDIENTE'");
    }

    private int contar(Connection con, String sql) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    private ChatbotResponse accesoNoDisponible(String modulo, String rolPermitido, Usuario usuario) {
        return new ChatbotResponse(
                "La función «" + modulo + "» está disponible para el rol " + rolPermitido
                + ". Tu sesión actual es «"
                + (usuario == null ? "Sin sesión" : AuthUtil.nombreRol(usuario.getRol())) + "».",
                "PERMISO",
                sugerenciasPorRol(usuario)
        );
    }

    private ChatbotResponse errorConexion(Usuario usuario, SQLException e) {
        System.err.println("LogiBot - error de consulta: " + e.getMessage());
        return new ChatbotResponse(
                "No pude consultar MySQL en este momento. Verifica la conexión desde la pantalla "
                + "de configuración y vuelve a intentarlo.",
                "ERROR_BD",
                Arrays.asList("¿Cómo configuro la conexión MySQL?"),
                "configuracion.jsp",
                "Revisar conexión"
        );
    }

    private ChatbotResponse respuestaAyuda(Usuario usuario, String introduccion) {
        String opciones;
        if (usuario != null && AuthUtil.ADMINISTRADOR_OBRA.equals(usuario.getRol())) {
            opciones = "Puedes preguntarme por requerimientos pendientes, el estado de una solicitud, "
                    + "el registro de requerimientos o la Demo JSF.";
        } else if (usuario != null && AuthUtil.JEFE_LOGISTICA.equals(usuario.getRol())) {
            opciones = "Puedes preguntarme por compras, proveedores, requerimientos pendientes, "
                    + "materiales destacados o costos registrados.";
        } else if (usuario != null && AuthUtil.GERENCIA.equals(usuario.getRol())) {
            opciones = "Puedes pedirme un resumen general, indicadores, costos, proveedores activos "
                    + "o información sobre reportes.";
        } else {
            opciones = "Puedo orientarte sobre los módulos y consultar información logística.";
        }

        return new ChatbotResponse(
                introduccion + " " + opciones,
                "AYUDA",
                sugerenciasPorRol(usuario)
        );
    }

    private List<String> sugerenciasPorRol(Usuario usuario) {
        if (usuario == null) {
            return Arrays.asList("¿Qué puedes hacer?", "¿Cómo configuro la conexión MySQL?");
        }

        if (AuthUtil.ADMINISTRADOR_OBRA.equals(usuario.getRol())) {
            return Arrays.asList(
                    "¿Cuántos requerimientos pendientes hay?",
                    "¿Cómo registro un requerimiento?",
                    "¿Cuál es mi rol?"
            );
        }

        if (AuthUtil.JEFE_LOGISTICA.equals(usuario.getRol())) {
            return Arrays.asList(
                    "¿Cuántos proveedores activos hay?",
                    "Últimas compras",
                    "Requerimientos pendientes"
            );
        }

        if (AuthUtil.GERENCIA.equals(usuario.getRol())) {
            return Arrays.asList(
                    "Resumen del sistema",
                    "Costo total de compras",
                    "Material más comprado"
            );
        }

        return Arrays.asList("¿Qué puedes hacer?", "¿Cuál es mi rol?");
    }

    private boolean tieneRol(Usuario usuario, String... roles) {
        return AuthUtil.tieneRol(usuario, roles);
    }

    private boolean esSaludo(String mensaje) {
        return mensaje.equals("hola")
                || mensaje.equals("buenas")
                || mensaje.equals("buenos dias")
                || mensaje.equals("buenas tardes")
                || mensaje.equals("buenas noches")
                || mensaje.startsWith("hola ");
    }

    private boolean contieneAlguno(String mensaje, String... opciones) {
        for (String opcion : opciones) {
            if (mensaje.contains(opcion)) {
                return true;
            }
        }
        return false;
    }

    private Integer extraerPrimerNumero(String mensaje) {
        Matcher matcher = NUMERO_PATTERN.matcher(mensaje);
        if (!matcher.find()) {
            return null;
        }
        try {
            return Integer.valueOf(matcher.group(1));
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String normalizar(String texto) {
        if (texto == null) {
            return "";
        }

        String sinAcentos = Normalizer.normalize(texto, Normalizer.Form.NFD)
                .replaceAll("\\p{M}+", "");
        return sinAcentos.toLowerCase(Locale.ROOT)
                .replaceAll("[^a-z0-9áéíóúñü ]", " ")
                .replaceAll("\\s+", " ")
                .trim();
    }
}
