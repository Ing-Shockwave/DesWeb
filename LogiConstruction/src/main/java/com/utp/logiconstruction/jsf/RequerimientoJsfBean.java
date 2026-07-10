package com.utp.logiconstruction.jsf;

import com.utp.logiconstruction.dao.RequerimientoDAO;
import com.utp.logiconstruction.modelo.Requerimiento;
import com.utp.logiconstruction.modelo.Usuario;
import com.utp.logiconstruction.util.AuthUtil;
import java.io.IOException;
import java.io.Serializable;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import javax.annotation.PostConstruct;
import javax.faces.application.FacesMessage;
import javax.enterprise.context.RequestScoped;
import javax.inject.Named;
import javax.faces.context.ExternalContext;
import javax.faces.context.FacesContext;

@Named("requerimientoJsfBean")
@RequestScoped
public class RequerimientoJsfBean implements Serializable {

    private String nombre;
    private String area;
    private Integer cantidad;
    private String fecha;
    private List<Requerimiento> requerimientos;

    @PostConstruct
    public void init() {
        if (!tieneAccesoAdministradorObra()) {
            redirigirSegunAcceso();
            return;
        }

        fecha = LocalDate.now().toString();
        cargarRequerimientos();
    }

    public String registrar() {
        if (!tieneAccesoAdministradorObra()) {
            redirigirSegunAcceso();
            return null;
        }

        if (!validarDatos()) {
            cargarRequerimientos();
            return null;
        }

        Requerimiento requerimiento = new Requerimiento(
                nombre.trim(),
                area.trim(),
                cantidad,
                fecha.trim()
        );

        boolean registrado = new RequerimientoDAO().registrarRequerimiento(requerimiento);

        if (registrado) {
            agregarMensaje(FacesMessage.SEVERITY_INFO,
                    "Requerimiento registrado",
                    "El registro fue guardado correctamente desde la página JSF.");
            limpiarFormulario();
        } else {
            agregarMensaje(FacesMessage.SEVERITY_ERROR,
                    "No se pudo registrar",
                    "Verifique la conexión a MySQL o los datos ingresados.");
        }

        cargarRequerimientos();
        return null;
    }

    public void cargarRequerimientos() {
        requerimientos = new RequerimientoDAO().listarRequerimientos();
    }

    private boolean validarDatos() {
        boolean valido = true;

        if (nombre == null || nombre.trim().length() < 2) {
            agregarMensaje(FacesMessage.SEVERITY_ERROR,
                    "Material inválido",
                    "El nombre del material es obligatorio y debe tener al menos 2 caracteres.");
            valido = false;
        }

        if (area == null || area.trim().length() < 2) {
            agregarMensaje(FacesMessage.SEVERITY_ERROR,
                    "Área inválida",
                    "El área solicitante es obligatoria y debe tener al menos 2 caracteres.");
            valido = false;
        }

        if (cantidad == null || cantidad < 1) {
            agregarMensaje(FacesMessage.SEVERITY_ERROR,
                    "Cantidad inválida",
                    "La cantidad debe ser mayor a cero.");
            valido = false;
        }

        if (fecha == null || fecha.trim().isEmpty()) {
            agregarMensaje(FacesMessage.SEVERITY_ERROR,
                    "Fecha inválida",
                    "La fecha del requerimiento es obligatoria.");
            valido = false;
        }

        return valido;
    }

    private void limpiarFormulario() {
        nombre = "";
        area = "";
        cantidad = null;
        fecha = LocalDate.now().toString();
    }

    public boolean tieneAccesoAdministradorObra() {
        Usuario usuario = getUsuarioSesion();
        return AuthUtil.tieneRol(usuario, AuthUtil.ADMINISTRADOR_OBRA);
    }

    private void redirigirSegunAcceso() {
        FacesContext facesContext = FacesContext.getCurrentInstance();
        ExternalContext externalContext = facesContext.getExternalContext();
        String contextPath = externalContext.getRequestContextPath();

        try {
            Usuario usuario = getUsuarioSesion();
            if (usuario == null) {
                externalContext.redirect(contextPath + "/login.jsp");
            } else {
                externalContext.redirect(contextPath + "/dashboard.jsp?acceso=denegado");
            }
            facesContext.responseComplete();
        } catch (IOException e) {
            agregarMensaje(FacesMessage.SEVERITY_ERROR,
                    "Error de navegación",
                    "No se pudo redirigir al usuario: " + e.getMessage());
        }
    }

    private Usuario getUsuarioSesion() {
        FacesContext facesContext = FacesContext.getCurrentInstance();
        if (facesContext == null) {
            return null;
        }

        Map<String, Object> sessionMap = facesContext.getExternalContext().getSessionMap();
        Object usuario = sessionMap.get("usuario");

        if (usuario instanceof Usuario) {
            return (Usuario) usuario;
        }
        return null;
    }

    private void agregarMensaje(FacesMessage.Severity severity, String resumen, String detalle) {
        FacesContext.getCurrentInstance().addMessage(null, new FacesMessage(severity, resumen, detalle));
    }

    public String getUsuarioNombre() {
        Usuario usuario = getUsuarioSesion();
        return usuario == null ? "Usuario" : usuario.getNombre();
    }

    public String getRolNombre() {
        Usuario usuario = getUsuarioSesion();
        return usuario == null ? "Sin rol" : AuthUtil.nombreRol(usuario.getRol());
    }

    public int getTotalRequerimientos() {
        if (requerimientos == null) {
            cargarRequerimientos();
        }
        return requerimientos == null ? 0 : requerimientos.size();
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

    public Integer getCantidad() {
        return cantidad;
    }

    public void setCantidad(Integer cantidad) {
        this.cantidad = cantidad;
    }

    public String getFecha() {
        return fecha;
    }

    public void setFecha(String fecha) {
        this.fecha = fecha;
    }

    public List<Requerimiento> getRequerimientos() {
        if (requerimientos == null) {
            cargarRequerimientos();
        }
        return requerimientos;
    }
}
