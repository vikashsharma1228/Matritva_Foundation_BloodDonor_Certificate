package com.controller;

import com.model.Donor;
import com.repository.DonorRepository;
import com.service.EmailService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

@RestController
@RequestMapping("/api/donors")
@CrossOrigin(origins = "*")
public class DonorController {

    @Autowired
    private DonorRepository repository;

    @Autowired
    private EmailService emailService;

    @PostMapping("/register")
    public ResponseEntity<Donor> registerDonor(@RequestBody Donor donor) {
        // Null check for safety
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
            @RequestParam("donationCount") int donationCount // <--- Check spelling!
    ) {
        try {
            emailService.sendEmailWithAttachment(email, name, file.getBytes(), location, donationDate, donationCount);
            return ResponseEntity.ok("Mail sent!");
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(e.getMessage());
        }
    }
}