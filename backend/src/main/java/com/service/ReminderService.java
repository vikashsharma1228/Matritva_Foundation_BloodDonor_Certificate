package com.service;

import com.model.Donor;
import com.repository.DonorRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import java.time.LocalDate;
import java.util.List;

@Service
public class ReminderService {

    @Autowired
    private DonorRepository repository;

    @Autowired 
    private NotificationService notificationService;

    // Har roz subah 10 baje ye function apne aap chalega
    @Scheduled(cron = "0 0 10 * * ?") 
    public void sendReminders() {
        // Aaj se 3 mahine pehle ki date nikalna
        String threeMonthsAgo = LocalDate.now().minusMonths(3).toString();
        
        System.out.println("Checking for donors who donated on: " + threeMonthsAgo);

        // Database se eligible donors ki list lana
        List<Donor> eligibleDonors = repository.findByDonationDate(threeMonthsAgo);

        if (eligibleDonors != null && !eligibleDonors.isEmpty()) {
            for (Donor donor : eligibleDonors) {
                String msg = "Namaste " + donor.getFullName() + 
                             ", Matritva Foundation ki taraf se dhanyawad. Aapne 3 mahine pehle blood donate kiya tha, ab aap phir se ek jaan bacha sakte hain!";

                // 1. Email bhejna
                notificationService.sendEmail(donor.getEmail(), "Time to Donate Again!", msg);

                // 2. SMS bhejna
                notificationService.sendSMS(donor.getMobile(), msg);
            }
        }
    }
}