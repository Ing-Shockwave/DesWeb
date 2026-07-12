package com.utp.logiconstruction.modelo;

import java.math.BigDecimal;

public class Compra {

    private int id;
    private String proveedor;
    private String producto;
    private int cantidad;
    private String fecha;
    private String estado;
    private BigDecimal costoUnitario;
    private String observacion;

    public Compra() {
    }

    public Compra(String proveedor, String producto, int cantidad,
            String estado, BigDecimal costoUnitario, String observacion) {
        this.proveedor = proveedor;
        this.producto = producto;
        this.cantidad = cantidad;
        this.estado = estado;
        this.costoUnitario = costoUnitario;
        this.observacion = observacion;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getProveedor() {
        return proveedor;
    }

    public void setProveedor(String proveedor) {
        this.proveedor = proveedor;
    }

    public String getProducto() {
        return producto;
    }

    public void setProducto(String producto) {
        this.producto = producto;
    }

    public int getCantidad() {
        return cantidad;
    }

    public void setCantidad(int cantidad) {
        this.cantidad = cantidad;
    }

    public String getFecha() {
        return fecha;
    }

    public void setFecha(String fecha) {
        this.fecha = fecha;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public BigDecimal getCostoUnitario() {
        return costoUnitario;
    }

    public void setCostoUnitario(BigDecimal costoUnitario) {
        this.costoUnitario = costoUnitario;
    }

    public String getObservacion() {
        return observacion;
    }

    public void setObservacion(String observacion) {
        this.observacion = observacion;
    }

    public BigDecimal getCostoTotal() {
        if (costoUnitario == null) {
            return BigDecimal.ZERO;
        }
        return costoUnitario.multiply(BigDecimal.valueOf(cantidad));
    }
}
