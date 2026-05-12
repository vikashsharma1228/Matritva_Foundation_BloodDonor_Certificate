package com.repository;

import com.model.Donor;

import java.util.List;
import java.util.Optional;

import org.springframework.data.mongodb.repository.MongoRepository;

public interface DonorRepository extends MongoRepository<Donor, String> {
    // Basic CRUD (Save, Find, Delete) yahan pehle se mil jayenge
    Optional<Donor>findByCertificateId(String id);

    List<Donor> findByDonationDate(String donationDate);
}