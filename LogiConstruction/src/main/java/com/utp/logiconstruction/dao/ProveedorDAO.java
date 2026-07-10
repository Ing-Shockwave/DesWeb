package com.utp.logiconstruction.dao;

import com.utp.logiconstruction.jpa.JpaUtil;
import com.utp.logiconstruction.modelo.Proveedor;
import java.util.ArrayList;
import java.util.List;
import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;

public class ProveedorDAO {

    private String ultimoError;

    public String getUltimoError() {
        return ultimoError;
    }

    public boolean registrarProveedor(Proveedor proveedor) {
        EntityManager entityManager = null;
        EntityTransaction transaction = null;

        ultimoError = null;

        try {
            entityManager = JpaUtil.crearEntityManager();
            transaction = entityManager.getTransaction();
            transaction.begin();
            entityManager.persist(proveedor);
            transaction.commit();
            return true;
        } catch (Exception e) {
            if (transaction != null && transaction.isActive()) {
                transaction.rollback();
            }
            ultimoError = obtenerMensajeCompleto(e);
            e.printStackTrace();
            return false;
        } finally {
            if (entityManager != null && entityManager.isOpen()) {
                entityManager.close();
            }
        }
    }

    public List<Proveedor> listarProveedores() {
        EntityManager entityManager = null;

        try {
            entityManager = JpaUtil.crearEntityManager();
            return entityManager
                    .createQuery("SELECT p FROM Proveedor p ORDER BY p.id DESC", Proveedor.class)
                    .getResultList();
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        } finally {
            if (entityManager != null && entityManager.isOpen()) {
                entityManager.close();
            }
        }
    }

    public boolean eliminarProveedor(int id) {
        EntityManager entityManager = null;
        EntityTransaction transaction = null;

        try {
            entityManager = JpaUtil.crearEntityManager();
            transaction = entityManager.getTransaction();
            transaction.begin();

            Proveedor proveedor = entityManager.find(Proveedor.class, id);
            if (proveedor != null) {
                entityManager.remove(proveedor);
            }

            transaction.commit();
            return true;
        } catch (Exception e) {
            if (transaction != null && transaction.isActive()) {
                transaction.rollback();
            }
            e.printStackTrace();
            return false;
        } finally {
            if (entityManager != null && entityManager.isOpen()) {
                entityManager.close();
            }
        }
    }

    private String obtenerMensajeCompleto(Throwable throwable) {
        StringBuilder mensaje = new StringBuilder();
        Throwable actual = throwable;

        while (actual != null) {
            if (actual.getMessage() != null) {
                if (mensaje.length() > 0) {
                    mensaje.append(" | ");
                }
                mensaje.append(actual.getMessage());
            }
            actual = actual.getCause();
        }

        return mensaje.toString();
    }

}
