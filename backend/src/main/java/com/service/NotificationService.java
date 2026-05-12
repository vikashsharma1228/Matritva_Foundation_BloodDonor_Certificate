package com.service;

import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper; // Ye import zaroori hai
import jakarta.mail.internet.MimeMessage;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.web.client.RestTemplate;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@Service
public class NotificationService {

    @Autowired
    private JavaMailSender mailSender;

    // Fast2SMS API Key (Aapko unke panel se milegi)
    private final String FAST2SMS_API_KEY = "paTbOGLYJWKmgNhXdrlk9FBvVP68zSR2EjA5cqDe3nwM1I0UQ41ulKU5tXfANh4xzqvsrc9ZyCiOLTjR";

    // --- SMS Logic (Fast2SMS) ---

    public void sendSMS(String mobileNumber, String donorName) {
        try {
            // Aapka personalized message
            String message = "Namaste " + donorName
                    + ", Matritva Foundation ki taraf se dhanyawad. Aap phir se blood donate karke jaan bacha sakte hain. Kripya sampark karein.";

            // Message ko URL-friendly banana
            String encodedMsg = URLEncoder.encode(message, StandardCharsets.UTF_8.toString());

            // Fast2SMS API URL
            String url = "https://www.fast2sms.com/dev/bulkV2?authorization=" + FAST2SMS_API_KEY +
                    "&route=q&message=" + encodedMsg +
                    "&flash=0&numbers=" + mobileNumber;

            RestTemplate restTemplate = new RestTemplate();
            String result = restTemplate.getForObject(url, String.class);
            System.out.println("SMS Status: " + result);
        } catch (Exception e) {
            System.err.println("SMS Error: " + e.getMessage());
        }
    }

    // --- Email Logic ---
    public void sendEmail(String toEmail, String subject, String body) {
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom("matritvafoundation@gmail.com"); // NGO Email
            message.setTo(toEmail);
            message.setSubject(subject);
            message.setText(body);
            mailSender.send(message);
            System.out.println("Email Sent Successfully!");
        } catch (Exception e) {
            System.err.println("Error sending Email: " + e.getMessage());
        }
    }

    public void sendProfessionalEmail(String toEmail, String donorName) {
     if (toEmail == null || toEmail.isEmpty()) return;
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, "utf-8");

            String htmlMsg = "<div style='font-family: Arial; border: 2px solid #800000; padding: 20px;'>" +
                    "<h2 style='color: #800000;'>Matritva Foundation</h2>" +
                    "<p>Namaste <b>" + donorName + "</b>,</p>" +
                    "<p>Aapne 3 mahine pehle blood donate karke ek misaal pesh ki thi.</p>" +
                    "<p style='background: #fdf2f2; padding: 10px;'>Aap ab dobara blood donate karne ke liye eligible hain.</p>"
                    +
                    "<p>Kripya nazdiki camp mein sampark karein aur phir se ek jaan bachayein.</p>" +
                    "<br><p>Team Matritva Foundation</p></div>";

            helper.setText(htmlMsg, true);
            helper.setTo(toEmail);
            helper.setSubject("Time to be a Hero again!");

            mailSender.send(message);
            System.out.println("Professional Email sent successfully to: " + toEmail);
        } catch (jakarta.mail.MessagingException e) {
            // Exception handle karna zaroori hai compiler ke liye
            System.err.println("Error while creating/sending MimeMessage: " + e.getMessage());
        } catch (Exception e) {
            System.err.println("General Email Error: " + e.getMessage());
        }
    }
}