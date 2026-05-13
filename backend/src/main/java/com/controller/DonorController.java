package com.controller;

import com.model.Donor;
import com.repository.DonorRepository;
import com.service.EmailService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@CrossOrigin(origins = "https://matritvabloodregister.vercel.app") // Aapka Vercel URL
@RestController
@RequestMapping("/api/donors")
public class DonorController {

    @Autowired
    private DonorRepository repository;

    @Autowired
    private EmailService emailService;

    // 1. New Donor Registration
    @PostMapping("/register")
    public ResponseEntity<Donor> registerDonor(@RequestBody Donor donor) {
        if (donor == null) {
            return ResponseEntity.badRequest().build();
        }
        Donor savedDonor = repository.save(donor);
        return ResponseEntity.ok(savedDonor);
    }

    // 2. Fetch All Donors (Optional: For Dashboard)
    @GetMapping("/all")
    public List<Donor> getAllDonors() {
        return repository.findAll();
    }

    // 3. Send Certificate via Gmail API (OAuth2)
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
            // Log for Render Debugging
            System.out.println("Received request to send certificate to: " + email);

            if (file.isEmpty()) {
                return ResponseEntity.badRequest().body("Error: PDF file is missing!");
            }

            // PDF bytes ko multipart file se extract karna zaroori hai 
            // taaki async thread safe rahe
            final byte[] pdfBytes = file.getBytes();

            // Email Service call (Kyuki service mein @Async laga hai, 
            // ye background mein chalega bina manual thread banaye)
            emailService.sendEmailWithAttachment(
                email, 
                name, 
                pdfBytes, 
                location, 
                donationDate, 
                donationCount
            );

            return ResponseEntity.ok("Success: Mail processing started in background!");

        } catch (Exception e) {
            System.err.println("Controller Error: " + e.getMessage());
            return ResponseEntity.internalServerError().body("Error: " + e.getMessage());
        }
    }
}