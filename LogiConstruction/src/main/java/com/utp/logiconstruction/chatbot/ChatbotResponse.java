package com.utp.logiconstruction.chatbot;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Respuesta estructurada generada por LogiBot.
 */
public class ChatbotResponse {

    private final String respuesta;
    private final String tipo;
    private final List<String> sugerencias;
    private final String accionUrl;
    private final String accionTexto;

    public ChatbotResponse(String respuesta, String tipo, List<String> sugerencias) {
        this(respuesta, tipo, sugerencias, null, null);
    }

    public ChatbotResponse(String respuesta, String tipo, List<String> sugerencias,
            String accionUrl, String accionTexto) {
        this.respuesta = respuesta;
        this.tipo = tipo;
        this.sugerencias = sugerencias == null
                ? Collections.emptyList()
                : Collections.unmodifiableList(new ArrayList<>(sugerencias));
        this.accionUrl = accionUrl;
        this.accionTexto = accionTexto;
    }

    public String getRespuesta() {
        return respuesta;
    }

    public String getTipo() {
        return tipo;
    }

    public List<String> getSugerencias() {
        return sugerencias;
    }

    public String getAccionUrl() {
        return accionUrl;
    }

    public String getAccionTexto() {
        return accionTexto;
    }
}
