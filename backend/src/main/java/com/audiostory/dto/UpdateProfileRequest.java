package com.audiostory.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UpdateProfileRequest {
    private String name;
    private String phone;
    private LocalDate birthday;
    private String gender;
    private String address;
    private String role; // For admin to change user role: USER or ADMIN
}
