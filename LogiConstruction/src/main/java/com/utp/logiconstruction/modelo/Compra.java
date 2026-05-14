package com.utp.logiconstruction.modelo;

public class Compra {

    private int id;
    private String proveedor;
    private String producto;
    private int cantidad;

    public Compra() {
    }

    public Compra(String proveedor, String producto, int cantidad) {
        this.proveedor = proveedor;
        this.producto = producto;
        this.cantidad = cantidad;
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
}