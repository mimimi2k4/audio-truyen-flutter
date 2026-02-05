package com.audiostory.service;

import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

@Service
public class FileStorageService {
    
    @Value("${app.upload.audio-dir}")
    private String audioDir;
    
    @Value("${app.upload.image-dir}")
    private String imageDir;
    
    @Value("${app.upload.avatar-dir}")
    private String avatarDir;
    
    @PostConstruct
    public void init() {
        try {
            Files.createDirectories(Paths.get(audioDir));
            Files.createDirectories(Paths.get(imageDir));
            Files.createDirectories(Paths.get(avatarDir));
        } catch (IOException e) {
            throw new RuntimeException("Could not create upload directories", e);
        }
    }
    
    public String storeAudio(MultipartFile file) {
        return storeFile(file, audioDir, "audio");
    }
    
    public String storeImage(MultipartFile file) {
        return storeFile(file, imageDir, "images");
    }
    
    public String storeAvatar(MultipartFile file) {
        return storeFile(file, avatarDir, "avatars");
    }
    
    private String storeFile(MultipartFile file, String directory, String urlPath) {
        String originalFilename = StringUtils.cleanPath(file.getOriginalFilename());
        String extension = originalFilename.substring(originalFilename.lastIndexOf("."));
        String newFilename = UUID.randomUUID().toString() + extension;
        
        try {
            Path targetLocation = Paths.get(directory).resolve(newFilename);
            Files.copy(file.getInputStream(), targetLocation, StandardCopyOption.REPLACE_EXISTING);
            return "/uploads/" + urlPath + "/" + newFilename;
        } catch (IOException e) {
            throw new RuntimeException("Could not store file " + originalFilename, e);
        }
    }
    
    public void deleteFile(String fileUrl) {
        if (fileUrl == null || fileUrl.isEmpty()) return;
        
        try {
            String filename = fileUrl.substring(fileUrl.lastIndexOf("/") + 1);
            String directory;
            
            if (fileUrl.contains("/audio/")) {
                directory = audioDir;
            } else if (fileUrl.contains("/images/")) {
                directory = imageDir;
            } else if (fileUrl.contains("/avatars/")) {
                directory = avatarDir;
            } else {
                return;
            }
            
            Path filePath = Paths.get(directory).resolve(filename);
            Files.deleteIfExists(filePath);
        } catch (IOException e) {
            // Log error but don't throw
        }
    }
}
