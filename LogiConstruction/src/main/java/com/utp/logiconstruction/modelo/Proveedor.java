package com.utp.logiconstruction.modelo;

public class Proveedor {

    private int id;
    private String nombre;
    private String ruc;
    private String telefono;
    private String correo;

    public Proveedor() {
    }

    public Proveedor(String nombre, String ruc, String telefono, String correo) {
        this.nombre = nombre;
        this.ruc = ruc;
        this.telefono = telefono;
        this.correo = correo;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getRuc() { return ruc; }
    public void setRuc(String ruc) { this.ruc = ruc; }

    public String getTelefono() { return telefono; }
    public void setTelefono(String telefono) { this.telefono = telefono; }

    public String getCorreo() { return correo; }
    public void setCorreo(String correo) { this.correo = correo; }
}