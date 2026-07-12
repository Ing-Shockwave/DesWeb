package com.utp.logiconstruction.modelo;

public class Requerimiento {

    private int id;
    private String nombre;
    private String area;
    private int cantidad;
    private String fecha;
    private String estado;
    private String observacion;

    public Requerimiento() {
    }

    public Requerimiento(String nombre, String area, int cantidad, String fecha,
            String estado, String observacion) {
        this.nombre = nombre;
        this.area = area;
        this.cantidad = cantidad;
        this.fecha = fecha;
        this.estado = estado;
        this.observacion = observacion;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getArea() {
        return area;
    }

    public void setArea(String area) {
        this.area = area;
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

    public String getObservacion() {
        return observacion;
    }

    public void setObservacion(String observacion) {
        this.observacion = observacion;
    }
}
