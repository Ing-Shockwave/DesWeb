package com.utp.logiconstruction.jsf;

import java.io.Serializable;
import javax.enterprise.context.ApplicationScoped;
import javax.faces.annotation.FacesConfig;

/**
 * Activa el modo JSF 2.3 y la integración CDI en Tomcat 9.
 */
@FacesConfig(version = FacesConfig.Version.JSF_2_3)
@ApplicationScoped
public class JsfApplicationConfig implements Serializable {

    private static final long serialVersionUID = 1L;
}
