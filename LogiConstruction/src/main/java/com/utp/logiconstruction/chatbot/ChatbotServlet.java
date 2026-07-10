package com.utp.logiconstruction.chatbot;

import com.utp.logiconstruction.api.JsonUtil;
import com.utp.logiconstruction.modelo.Usuario;
import com.utp.logiconstruction.util.AuthUtil;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Controlador del chatbot informativo LogiBot.
 */
@WebServlet(name = "ChatbotServlet", urlPatterns = {"/ChatbotServlet"})
public class ChatbotServlet extends HttpServlet {

    private static final int LONGITUD_MAXIMA = 400;
    private final ChatbotService chatbotService = new ChatbotService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        prepararRespuesta(response);

        Usuario usuario = AuthUtil.obtenerUsuario(request);
        if (usuario == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            escribirJson(response, new ChatbotResponse(
                    "Tu sesión ha finalizado. Inicia sesión nuevamente para usar LogiBot.",
                    "SESION",
                    java.util.Collections.<String>emptyList(),
                    "login.jsp",
                    "Ir al inicio de sesión"
            ));
            return;
        }

        String mensaje = request.getParameter("mensaje");
        if (mensaje != null) {
            mensaje = mensaje.trim();
        }

        if (mensaje == null || mensaje.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            escribirJson(response, new ChatbotResponse(
                    "Escribe una consulta antes de enviarla.",
                    "VALIDACION",
                    java.util.Collections.<String>emptyList()
            ));
            return;
        }

        if (mensaje.length() > LONGITUD_MAXIMA) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            escribirJson(response, new ChatbotResponse(
                    "La consulta es demasiado extensa. Utiliza como máximo "
                    + LONGITUD_MAXIMA + " caracteres.",
                    "VALIDACION",
                    java.util.Collections.<String>emptyList()
            ));
            return;
        }

        ChatbotResponse chatbotResponse = chatbotService.responder(mensaje, usuario);
        escribirJson(response, chatbotResponse);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED,
                "LogiBot recibe consultas mediante POST.");
    }

    private void prepararRespuesta(HttpServletResponse response) {
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
    }

    private void escribirJson(HttpServletResponse response, ChatbotResponse chatbotResponse)
            throws IOException {
        try (PrintWriter out = response.getWriter()) {
            out.print("{");
            out.print("\"respuesta\":" + JsonUtil.texto(chatbotResponse.getRespuesta()));
            out.print(",\"tipo\":" + JsonUtil.texto(chatbotResponse.getTipo()));
            out.print(",\"sugerencias\":" + listaJson(chatbotResponse.getSugerencias()));
            out.print(",\"accionUrl\":" + JsonUtil.texto(chatbotResponse.getAccionUrl()));
            out.print(",\"accionTexto\":" + JsonUtil.texto(chatbotResponse.getAccionTexto()));
            out.print("}");
        }
    }

    private String listaJson(List<String> valores) {
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < valores.size(); i++) {
            if (i > 0) {
                json.append(',');
            }
            json.append(JsonUtil.texto(valores.get(i)));
        }
        json.append(']');
        return json.toString();
    }
}
