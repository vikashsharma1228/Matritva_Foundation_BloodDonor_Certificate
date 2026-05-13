package com.service;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import java.io.UnsupportedEncodingException;

@Service
public class EmailService {

    @Autowired
    private JavaMailSender mailSender;

    @Async
    public void sendEmailWithAttachment(String toEmail, String donorName, byte[] pdfContent,
            String location, String donationDate, int donationCount) {
        
        if (toEmail == null || pdfContent == null) {
            System.err.println("Email Error: toEmail or pdfContent is null!");
            return;
        }

        try {
            // Log for debugging on Render
            System.out.println("Starting Email Process for: " + toEmail);

            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setFrom("matritvafoundation@gmail.com", "Matritva Foundation");
            helper.setTo(toEmail);

            String subject = donorName + " - Blood Donation Appreciation Certificate 🏅 ";
            helper.setSubject(subject);

            String whatsappLink = "https://chat.whatsapp.com/EVcBragy2687Iku5kwovYe";
            String instaLink = "https://www.instagram.com/matritva_foundation/";

            // Aapka Original Stunning HTML Template (No Changes Made)
            String htmlBody = "<div style='font-family: \"Segoe UI\", Tahoma, sans-serif; line-height: 1.6; color: #1a1a1a; max-width: 600px; margin: auto; border: 1px solid #f0f0f0; border-radius: 15px; overflow: hidden;'>"
                    + "<div style='background-color: #800000; padding: 25px; text-align: center;'>"
                    + "<h1 style='color: #ffffff; margin: 0; font-size: 26px; letter-spacing: 1px;'>MATRITVA FOUNDATION</h1>"
                    + "<p style='color: #ffd700; margin: 5px 0; font-size: 14px; font-weight: bold;'>SAVING LIVES, ONE DROP AT A TIME</p>"
                    + "</div>"
                    + "<div style='padding: 30px 25px;'>"
                    + "<h2 style='color: #800000; margin-top: 0;'>Real Heroes Save Lives - Just Like You ❤️</h2>"
                    + "<p style='font-size: 16px;'>Dear <b>" + donorName + "</b>,</p>"
                    + "<p style='font-size:16px;'>Greetings from Matritva Foundation ❤️</p>"
                    + "<p>We sincerely thank you for your generous contribution towards saving lives through blood donation. Your kindness and humanity continue to inspire our community.</p>"
                    + "<div style='background-color: #fff9db; border: 2px dashed #facc15; padding: 20px; border-radius: 12px; text-align: center; margin: 25px 0;'>"
                    + "<p style='font-size: 12px; color: #800000; margin: 5px 0;'><b>📍Donation Location: " + location + "</b></p>"
                    + "<p style='font-size: 12px; color: #800000; margin: 5px 0;'><b>📅 Donation Date:" + donationDate + "</b></p>"
                    + "<p style='font-size: 10px; color: #800000; margin: 5px 0;'><b>🩸Your Total Blood Donation: " + donationCount + " times</b></p>"
                    + "</div>"
                    + "<p>Your selfless act is more than a donation — it is a gift of hope, strength, and life for someone in need. Because of compassionate donors like you, many families receive another chance to smile.</p>"
                    + "<p>Please find your Certificate of Appreciation attached with this email as a token of gratitude and respect.</p>"
                    + "<p>We are proud to have you as a part of the Matritva Foundation donor family and hope to see your continued support in future blood donation drives.</p>"
                    + "<p style='text-align: center; font-size: 13px; color: #070707;'>Don't forget to tag us in your stories!</p>"
                    + "<p><b>We value your feedback!</b><br>\n"
                    + " Please click the link below to complete the form so we can further improve our services:</p>"
                    + "<a href='https://forms.gle/EbJxcT3T2UXj3u9HA' style='color: #800000; font-weight: bold; text-decoration: underline;'>"
                    + "👉 Please fill out the form here" + "</a>"
                    + "<p style= 'font-weight: bold;'> With heartfelt appreciation,</p>"
                    + "<p style= 'font-weight: bold;'>Team Matritva Foundation</p>"
                    + "<p style='font-weight: bold;'>📞 Support & Inquiries: +91 9471438309</p>"
                    + "<div style='text-align: center; margin: 30px 0;'>"
                    + "<a href='" + whatsappLink + "' style='background-color: #25D366; color: white; padding: 12px 25px; text-decoration: none; border-radius: 30px; font-weight: bold; display: inline-block; margin: 10px; box-shadow: 0 4px 10px rgba(37,211,102,0.3);'>Join Community 💬</a>"
                    + "<a href='" + instaLink + "' style='background-color: #E1306C; color: white; padding: 12px 25px; text-decoration: none; border-radius: 30px; font-weight: bold; display: inline-block; margin: 10px; box-shadow: 0 4px 10px rgba(225,48,108,0.3);'>Follow us on Insta 📸</a>"
                    + "</div>"
                    + "</div>"
                    + "</div>";

            helper.setText(htmlBody, true);

            // Dynamic File Name logic
            String fileName = "Certificate_" + donorName.replace(" ", "_") + ".pdf";
            helper.addAttachment(fileName, new ByteArrayResource(pdfContent));

            // Connection Log
            System.out.println("Connection Check: Attempting delivery to " + toEmail + " via SMTP 587");
            
            mailSender.send(message);
            
            // Success Log
            System.out.println("SUCCESS: Mail sent to donor: " + donorName + " (Count: " + donationCount + ")");

        } catch (Exception e) {
            // Detailed Error for Render Logs
            System.err.println("FATAL MAIL ERROR for " + donorName + ": " + e.getMessage());
            e.printStackTrace(); 
        }
    }
}