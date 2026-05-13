package com.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data 
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "donors")
public class Donor {
    @Id
    private String id;
    private String fullName;
    private String fatherName;
    private String gender;
    private String email;
    private String mobile;
    private String dob;
    private String bloodGroup;
    private int donationCount;
    private String donationDate;
    private String location;
    private String certificateId;
}