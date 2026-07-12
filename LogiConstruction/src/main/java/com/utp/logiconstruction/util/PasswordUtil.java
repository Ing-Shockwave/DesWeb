package com.utp.logiconstruction.util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

/**
 * Utilidad para almacenar y verificar contraseñas con PBKDF2-HMAC-SHA256.
 * El formato persistido es:
 * pbkdf2_sha256$iteraciones$saltBase64$hashBase64
 */
public final class PasswordUtil {

    private static final String PREFIJO = "pbkdf2_sha256";
    private static final String ALGORITMO = "PBKDF2WithHmacSHA256";
    private static final int ITERACIONES = 210_000;
    private static final int LONGITUD_SALT_BYTES = 16;
    private static final int LONGITUD_HASH_BITS = 256;
    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    private PasswordUtil() {
    }

    public static String generarHash(String password) {
        if (password == null || password.isEmpty()) {
            throw new IllegalArgumentException("La contraseña no puede estar vacía.");
        }

        byte[] salt = new byte[LONGITUD_SALT_BYTES];
        SECURE_RANDOM.nextBytes(salt);
        byte[] hash = derivar(password.toCharArray(), salt, ITERACIONES);

        return PREFIJO + "$" + ITERACIONES + "$"
                + Base64.getEncoder().encodeToString(salt) + "$"
                + Base64.getEncoder().encodeToString(hash);
    }

    public static boolean verificar(String passwordIngresada, String valorAlmacenado) {
        if (passwordIngresada == null || valorAlmacenado == null) {
            return false;
        }

        if (!esFormatoSeguro(valorAlmacenado)) {
            // Compatibilidad temporal: permite iniciar sesión una sola vez con
            // bases antiguas y luego UsuarioDAO migra el valor a PBKDF2.
            return MessageDigest.isEqual(
                    passwordIngresada.getBytes(StandardCharsets.UTF_8),
                    valorAlmacenado.getBytes(StandardCharsets.UTF_8)
            );
        }

        try {
            String[] partes = valorAlmacenado.split("\\$", 4);
            int iteraciones = Integer.parseInt(partes[1]);
            byte[] salt = Base64.getDecoder().decode(partes[2]);
            byte[] esperado = Base64.getDecoder().decode(partes[3]);
            byte[] calculado = derivar(passwordIngresada.toCharArray(), salt, iteraciones);
            return MessageDigest.isEqual(esperado, calculado);
        } catch (RuntimeException e) {
            return false;
        }
    }

    public static boolean esFormatoSeguro(String valorAlmacenado) {
        return valorAlmacenado != null
                && valorAlmacenado.startsWith(PREFIJO + "$")
                && valorAlmacenado.split("\\$", -1).length == 4;
    }

    private static byte[] derivar(char[] password, byte[] salt, int iteraciones) {
        PBEKeySpec spec = new PBEKeySpec(password, salt, iteraciones, LONGITUD_HASH_BITS);
        try {
            SecretKeyFactory factory = SecretKeyFactory.getInstance(ALGORITMO);
            return factory.generateSecret(spec).getEncoded();
        } catch (Exception e) {
            throw new IllegalStateException("No se pudo generar el hash de la contraseña.", e);
        } finally {
            spec.clearPassword();
        }
    }
}
