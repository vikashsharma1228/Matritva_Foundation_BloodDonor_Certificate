package com.controller;

import com.model.Donor;
import com.repository.DonorRepository;
import com.service.EmailService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@CrossOrigin(origins = "https://web-bay-omega-80.vercel.app")
@RestController
@RequestMapping("/api/donors")
public class DonorController {

    @Autowired
    private DonorRepository repository;

    @Autowired
    private EmailService emailService;

    @PostMapping("/register")
    public ResponseEntity<Donor> registerDonor(@RequestBody Donor donor) {
        if (donor == null) {
            return ResponseEntity.badRequest().build();
        }
        Donor savedDonor = repository.save(donor);
        return ResponseEntity.ok(savedDonor);
    }

    @PostMapping("/send-certificate")
    public ResponseEntity<?> sendMail(
            @RequestParam("file") MultipartFile file,
            @RequestParam("email") String email,
            @RequestParam("name") String name,
            @RequestParam("location") String location,
            @RequestParam("donationDate") String donationDate,
            @RequestParam("donationCount") int donationCount
    ) {
        try {
            // PDF bytes ko thread ke bahar nikalna zaroori hai
            final byte[] pdfBytes = file.getBytes();

            // Background thread mein mail bhejna taaki Render timeout na kare
            new Thread(() -> {
                try {
                    emailService.sendEmailWithAttachment(email, name, pdfBytes, location, donationDate, donationCount);
                } catch (Exception e) {
                    System.err.println("Async Mail Error for " + name + ": " + e.getMessage());
                }
            }).start();

            return ResponseEntity.ok("Success: Mail processing started!");
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Error: " + e.getMessage());
        }
    }
}