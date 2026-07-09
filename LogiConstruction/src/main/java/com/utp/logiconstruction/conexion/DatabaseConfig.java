package com.utp.logiconstruction.conexion;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public class DatabaseConfig {

    public static final String DEFAULT_URL = "jdbc:mysql://localhost:3306/logiconstruction?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    public static final String DEFAULT_USER = "root";
    public static final String DEFAULT_PASSWORD = "admin";

    private static final String CONFIG_FOLDER = ".logiconstruction";
    private static final String CONFIG_FILE = "db.properties";
    private static final String KEY_URL = "db.url";
    private static final String KEY_USER = "db.user";
    private static final String KEY_PASSWORD = "db.password";

    private DatabaseConfig() {
        // Clase auxiliar: no necesita instancias.
    }

    public static Path getConfigPath() {
        String userHome = System.getProperty("user.home");
        return Paths.get(userHome, CONFIG_FOLDER, CONFIG_FILE);
    }

    public static Properties cargarConfiguracion() {
        Properties properties = crearConfiguracionPorDefecto();
        Path configPath = getConfigPath();

        if (Files.exists(configPath)) {
            try (InputStream input = Files.newInputStream(configPath)) {
                properties.load(input);
            } catch (IOException e) {
                System.out.println("No se pudo leer db.properties. Se usarán valores por defecto: " + e.getMessage());
            }
        }

        completarValoresVacios(properties);
        return properties;
    }

    public static void guardarConfiguracion(String url, String usuario, String password) throws IOException {
        Properties properties = new Properties();
        properties.setProperty(KEY_URL, limpiar(url, DEFAULT_URL));
        properties.setProperty(KEY_USER, limpiar(usuario, DEFAULT_USER));
        properties.setProperty(KEY_PASSWORD, password == null ? "" : password);

        Path configPath = getConfigPath();
        Files.createDirectories(configPath.getParent());

        try (OutputStream output = Files.newOutputStream(configPath)) {
            properties.store(output, "Configuracion de base de datos - LogiConstruction");
        }
    }

    public static boolean existeConfiguracionGuardada() {
        return Files.exists(getConfigPath());
    }

    public static String getUrl() {
        return cargarConfiguracion().getProperty(KEY_URL, DEFAULT_URL);
    }

    public static String getUsuario() {
        return cargarConfiguracion().getProperty(KEY_USER, DEFAULT_USER);
    }

    public static String getPassword() {
        return cargarConfiguracion().getProperty(KEY_PASSWORD, DEFAULT_PASSWORD);
    }

    public static Connection obtenerConexion() throws SQLException {
        Properties properties = cargarConfiguracion();
        return probarConexion(
                properties.getProperty(KEY_URL, DEFAULT_URL),
                properties.getProperty(KEY_USER, DEFAULT_USER),
                properties.getProperty(KEY_PASSWORD, DEFAULT_PASSWORD)
        );
    }

    public static Connection probarConexionActual() throws SQLException {
        return obtenerConexion();
    }

    public static Connection probarConexion(String url, String usuario, String password) throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("No se encontró el driver JDBC de MySQL.", e);
        }

        return DriverManager.getConnection(
                limpiar(url, DEFAULT_URL),
                limpiar(usuario, DEFAULT_USER),
                password == null ? "" : password
        );
    }

    private static Properties crearConfiguracionPorDefecto() {
        Properties properties = new Properties();
        properties.setProperty(KEY_URL, DEFAULT_URL);
        properties.setProperty(KEY_USER, DEFAULT_USER);
        properties.setProperty(KEY_PASSWORD, DEFAULT_PASSWORD);
        return properties;
    }

    private static void completarValoresVacios(Properties properties) {
        properties.setProperty(KEY_URL, limpiar(properties.getProperty(KEY_URL), DEFAULT_URL));
        properties.setProperty(KEY_USER, limpiar(properties.getProperty(KEY_USER), DEFAULT_USER));

        if (properties.getProperty(KEY_PASSWORD) == null) {
            properties.setProperty(KEY_PASSWORD, DEFAULT_PASSWORD);
        }
    }

    private static String limpiar(String valor, String valorDefecto) {
        if (valor == null || valor.trim().isEmpty()) {
            return valorDefecto;
        }
        return valor.trim();
    }
}
