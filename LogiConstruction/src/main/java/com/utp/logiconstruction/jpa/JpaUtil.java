package com.utp.logiconstruction.jpa;

import com.utp.logiconstruction.conexion.DatabaseConfig;
import java.util.HashMap;
import java.util.Map;
import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;

public final class JpaUtil {

    private static final String PERSISTENCE_UNIT = "LogiConstructionPU";
    private static EntityManagerFactory entityManagerFactory;

    private JpaUtil() {
    }

    public static synchronized EntityManagerFactory getEntityManagerFactory() {
        if (entityManagerFactory == null || !entityManagerFactory.isOpen()) {
            entityManagerFactory = Persistence.createEntityManagerFactory(PERSISTENCE_UNIT, crearPropiedades());
        }
        return entityManagerFactory;
    }

    public static EntityManager crearEntityManager() {
        return getEntityManagerFactory().createEntityManager();
    }

    public static synchronized void reiniciar() {
        if (entityManagerFactory != null && entityManagerFactory.isOpen()) {
            entityManagerFactory.close();
        }
        entityManagerFactory = null;
    }

    private static Map<String, String> crearPropiedades() {
        Map<String, String> properties = new HashMap<>();
        properties.put("javax.persistence.jdbc.driver", "com.mysql.cj.jdbc.Driver");
        properties.put("javax.persistence.jdbc.url", DatabaseConfig.getUrl());
        properties.put("javax.persistence.jdbc.user", DatabaseConfig.getUsuario());
        properties.put("javax.persistence.jdbc.password", DatabaseConfig.getPassword());

        properties.put("hibernate.dialect", "org.hibernate.dialect.MySQL8Dialect");
        properties.put("hibernate.hbm2ddl.auto", "none");
        properties.put("hibernate.show_sql", "false");
        properties.put("hibernate.format_sql", "false");
        properties.put("hibernate.temp.use_jdbc_metadata_defaults", "false");
        properties.put("hibernate.connection.characterEncoding", "utf8");
        properties.put("hibernate.connection.useUnicode", "true");
        return properties;
    }
}
