package com.barc.ims.util;

import java.security.MessageDigest;

/**
 * PasswordUtil - MD5 hashing utility (JDK 1.7 compatible).
 * NOTE: For enhanced security consider SHA-256 with salt in production.
 */
public class PasswordUtil {
    public static String md5(String input) {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] hash = md.digest(input.getBytes("UTF-8"));
            StringBuilder sb = new StringBuilder();
            for (byte b : hash) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) {
            return "";
        }
    }
}
