git clone: https://github.com/Ing-Shockwave/DesWeb/tree/logiconstruction

# LogiConstruction

![Java](https://img.shields.io/badge/Java-11%2B-orange)
![Tomcat](https://img.shields.io/badge/Apache%20Tomcat-9.0-yellow)
![MySQL](https://img.shields.io/badge/MySQL-8.x-blue)
![Maven](https://img.shields.io/badge/Maven-WAR-red)
![Estado](https://img.shields.io/badge/Estado-Acad%C3%A9mico%20funcional-success)

**LogiConstruction** es un sistema web académico para la gestión logística de proyectos de construcción. Permite administrar requerimientos de materiales, compras, proveedores, reportes e indicadores mediante una aplicación tradicional desarrollada con **JSP, Servlets, JDBC, JPA, JSF y MySQL**.

El proyecto está preparado para ejecutarse en **Apache Tomcat 9** y utiliza paquetes `javax.*`.

---

## Características principales

- Inicio de sesión con control de acceso por roles.
- Gestión de requerimientos de materiales.
- Gestión de compras.
- Gestión de proveedores.
- Dashboard y reportes logísticos.
- DataTables con búsqueda, ordenamiento y paginación.
- Validaciones en frontend y backend.
- Configuración portable de conexión a MySQL.
- Persistencia con JPA en el módulo de proveedores.
- API REST de consulta en formato JSON.
- Página demostrativa desarrollada con JSF.
- Chatbot informativo **LogiBot** integrado en la aplicación.
- Botón de contacto mediante grupo de WhatsApp.
- Codificación UTF-8 para caracteres especiales.
- Diseño adaptable y menú lateral según el rol del usuario.

---

## Roles del sistema

| Rol | Funciones principales |
|---|---|
| `ADMINISTRADOR_OBRA` | Consulta y registro de requerimientos; acceso a la demostración JSF. |
| `JEFE_LOGISTICA` | Gestión de compras, proveedores y requerimientos. |
| `GERENCIA` | Consulta del dashboard, reportes e indicadores generales. |

Los permisos también se validan en el backend para evitar el acceso directo a módulos no autorizados.

---

## Tecnologías utilizadas

### Backend

- Java 11
- JSP y Servlets 4.0
- JDBC
- JPA 2.2
- Hibernate 5.6
- JSF 2.3 / Mojarra
- CDI con Weld Servlet
- Maven

### Frontend

- HTML5
- CSS3
- JavaScript
- Bootstrap
- DataTables
- SweetAlert2
- Chart.js
- Font Awesome

### Infraestructura

- Apache Tomcat 9
- MySQL 8.x
- Apache NetBeans
- Git y GitHub

---

## Arquitectura general

```text
Navegador web
      |
      v
JSP / JSF / JavaScript
      |
      v
Servlets y LogiBot
      |
      v
DAO / JPA / JDBC
      |
      v
MySQL - logiconstruction
```

La aplicación mantiene una arquitectura web tradicional basada en capas:

- **Presentación:** JSP, JSF, CSS y JavaScript.
- **Controladores:** Servlets.
- **Lógica y acceso a datos:** servicios, DAO, JDBC y JPA.
- **Persistencia:** MySQL.

---

## Requisitos previos

Antes de ejecutar el proyecto, instala:

- **JDK 11 o superior**
- **Apache NetBeans**
- **Apache Tomcat 9**
- **MySQL Server 8.x**
- **MySQL Workbench**, opcional
- **Git**, para control de versiones

> El proyecto no está preparado para Tomcat 10, GlassFish 7 ni paquetes `jakarta.*` sin realizar una migración.

---

## Instalación

### 1. Clonar el repositorio

```bash
git clone https://github.com/Ing-Shockwave/DesWeb.git
cd LogiConstruction
```

También puedes descargar el proyecto como ZIP y descomprimirlo.

### 2. Crear la base de datos

Abre MySQL Workbench y ejecuta:

```text
BaseDatos/logiconstruction_bd_ordenada_compatible.sql
```

El script:

- crea la base de datos `logiconstruction`;
- crea las tablas necesarias;
- registra datos iniciales;
- crea vistas de apoyo para los reportes.

### 3. Abrir el proyecto en NetBeans

1. Abre Apache NetBeans.
2. Selecciona **File > Open Project**.
3. Elige la carpeta que contiene `pom.xml`.
4. Configura **Apache Tomcat 9** como servidor.
5. Ejecuta **Clean and Build**.
6. Ejecuta **Run**.

La aplicación normalmente estará disponible en:

```text
http://localhost:8080/LogiConstruction/
```

---

## Configuración portable de MySQL

El proyecto no requiere modificar `Conexion.java` para cambiar las credenciales de la base de datos.

Desde el login, abre:

```text
Configurar conexión
```

También puedes ingresar directamente a:

```text
http://localhost:8080/LogiConstruction/configuracion.jsp
```

Valores predeterminados:

```properties
db.url=jdbc:mysql://localhost:3306/logiconstruction?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
db.user=root
db.password=admin
```

La configuración se guarda fuera del proyecto:

```text
C:\Users\USUARIO\.logiconstruction\db.properties
```

En Linux o macOS se guarda dentro del directorio personal del usuario:

```text
~/.logiconstruction/db.properties
```

---

## Usuarios de demostración

| Rol | Correo | Contraseña |
|---|---|---|
| Administrador de Obra | `obra@logiconstruction.com` | `123456` |
| Jefe de Logística | `logistica@logiconstruction.com` | `123456` |
| Gerencia | `gerencia@logiconstruction.com` | `123456` |

Estas credenciales son únicamente para fines académicos y de demostración.

---

## API REST

El sistema incorpora endpoints de solo consulta:

| Método | Endpoint | Descripción |
|---|---|---|
| `GET` | `/LogiConstruction/api/proveedores` | Devuelve los proveedores en JSON. |
| `GET` | `/LogiConstruction/api/compras` | Devuelve las compras en JSON. |
| `GET` | `/LogiConstruction/api/requerimientos` | Devuelve los requerimientos en JSON. |

Ejemplo:

```text
http://localhost:8080/LogiConstruction/api/proveedores
```

Respuesta aproximada:

```json
[
  {
    "id": 1,
    "nombre": "MATEL S.A.C.",
    "ruc": "20123456789",
    "telefono": "997011272",
    "correo": "ventas@matel.com"
  }
]
```

---

## JPA

JPA se aplica en el módulo de proveedores mediante:

- `Proveedor.java` como entidad.
- `ProveedorDAO.java` con `EntityManager`.
- `JpaUtil.java`.
- `META-INF/persistence.xml`.
- Hibernate 5.6 como proveedor de persistencia.

Los demás módulos mantienen JDBC para conservar la arquitectura original y demostrar ambas formas de acceso a datos.

---

## Demostración JSF

La página demostrativa JSF está disponible en:

```text
http://localhost:8080/LogiConstruction/requerimientos-jsf.xhtml
```

Está orientada al rol **Administrador de Obra** e incluye:

- formulario con componentes JSF;
- validaciones de campos;
- mensajes de error;
- tabla de requerimientos;
- integración con la base de datos.

Para ejecutar JSF 2.3 en Tomcat 9, el proyecto incluye Mojarra y CDI mediante Weld Servlet.

---

## LogiBot

**LogiBot** es un chatbot informativo desarrollado con Java, Servlet y JavaScript. Funciona dentro de la aplicación y no depende de tokens ni APIs externas.

Puede:

- identificar el rol del usuario;
- orientar sobre los módulos disponibles;
- consultar proveedores activos;
- consultar compras registradas;
- consultar requerimientos pendientes;
- buscar el estado de un requerimiento por ID;
- mostrar las últimas compras y requerimientos;
- calcular resúmenes e indicadores;
- dirigir al canal de soporte.

Ejemplos de consultas:

```text
Hola
¿Qué puedes hacer?
¿Cuál es mi rol?
¿Cuántos proveedores activos hay?
¿Cuántos requerimientos pendientes hay?
Estado del requerimiento 2
Últimas compras
Material más comprado
Costo total de compras
Resumen del sistema
Contactar soporte
```

LogiBot es únicamente informativo: no registra, modifica ni elimina datos.

---

## WhatsApp

La aplicación incluye:

- enlace de soporte en el login;
- botón flotante en las páginas internas;
- acceso al grupo académico de soporte.

El botón aparece cerca del final de la página y se muestra junto a LogiBot.

---

## Estructura principal

```text
LogiConstruction/
├── BaseDatos/
│   └── logiconstruction_bd_ordenada_compatible.sql
├── src/
│   └── main/
│       ├── java/com/utp/logiconstruction/
│       │   ├── api/
│       │   ├── chatbot/
│       │   ├── conexion/
│       │   ├── dao/
│       │   ├── filter/
│       │   ├── jpa/
│       │   ├── jsf/
│       │   ├── modelo/
│       │   ├── servlet/
│       │   └── util/
│       ├── resources/
│       │   └── META-INF/persistence.xml
│       └── webapp/
│           ├── css/
│           ├── js/
│           ├── WEB-INF/
│           ├── login.jsp
│           ├── dashboard.jsp
│           ├── compras.jsp
│           ├── proveedores.jsp
│           ├── requerimientos.jsp
│           ├── reportes.jsp
│           ├── configuracion.jsp
│           └── requerimientos-jsf.xhtml
├── pom.xml
└── README.md
```

---

## Compilación con Maven

Desde una terminal ubicada en la raíz del proyecto:

```bash
mvn clean package
```

El archivo WAR se generará en:

```text
target/LogiConstruction-1.0-SNAPSHOT.war
```

Para el desarrollo habitual se recomienda ejecutar el proyecto desde NetBeans con Tomcat 9.

---

## Validaciones implementadas

Los formularios cuentan con validaciones en distintas capas:

- atributos HTML5;
- validaciones con JavaScript;
- mensajes visuales con SweetAlert2;
- validaciones en Servlets;
- restricciones definidas en MySQL.

Esto evita depender únicamente de las validaciones del navegador.

---

## Seguridad y consideraciones

Este proyecto fue desarrollado con fines académicos. Antes de utilizarlo en un entorno productivo se recomienda:

- almacenar contraseñas con `BCrypt` o `Argon2`;
- proteger los endpoints REST con autenticación y autorización;
- utilizar un usuario MySQL exclusivo para la aplicación;
- no utilizar `root` en producción;
- mantener las credenciales fuera del repositorio;
- aplicar HTTPS;
- agregar protección CSRF;
- implementar registros de auditoría;
- incorporar pruebas automatizadas.

---

## Próximas mejoras

- Migrar los módulos restantes de JDBC a JPA.
- Incorporar edición completa de registros.
- Implementar autenticación segura para la API REST.
- Agregar pruebas unitarias y de integración.
- Incorporar recuperación real de contraseña.
- Añadir auditoría de acciones por usuario.
- Desplegar el sistema en un servidor de producción.
- Integrar opcionalmente LogiBot con una API de inteligencia artificial.

---

## Proyecto académico

Desarrollado como parte del curso **Desarrollo Web Integrado** de la carrera de Ingeniería de Sistemas e Informática.

**Proyecto:** Sistema de Gestión Logística en Construcción  
**Nombre del sistema:** LogiConstruction  
**Modalidad:** trabajo académico grupal

---

## Licencia

Este repositorio se distribuye con fines educativos y demostrativos. Su uso comercial o productivo requiere una revisión adicional de seguridad, infraestructura y protección de datos.
