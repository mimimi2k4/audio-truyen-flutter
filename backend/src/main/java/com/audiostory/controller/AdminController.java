package com.audiostory.controller;

import com.audiostory.dto.*;
import com.audiostory.service.CategoryService;
import com.audiostory.service.EpisodeService;
import com.audiostory.service.FileStorageService;
import com.audiostory.service.StoryService;
import com.audiostory.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
public class AdminController {
    
    private final UserService userService;
    private final CategoryService categoryService;
    private final StoryService storyService;
    private final EpisodeService episodeService;
    private final FileStorageService fileStorageService;
    
    // User Management
    @GetMapping("/users")
    public ResponseEntity<ApiResponse<List<UserDTO>>> getAllUsers() {
        List<UserDTO> users = userService.getAllUsers();
        return ResponseEntity.ok(ApiResponse.success(users));
    }
    
    @GetMapping("/users/{id}")
    public ResponseEntity<ApiResponse<UserDTO>> getUserById(@PathVariable Long id) {
        try {
            UserDTO user = userService.getUserById(id);
            return ResponseEntity.ok(ApiResponse.success(user));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @PutMapping("/users/{id}")
    public ResponseEntity<ApiResponse<UserDTO>> updateUser(
            @PathVariable Long id,
            @RequestBody UpdateProfileRequest request) {
        try {
            UserDTO user = userService.updateUser(id, request);
            return ResponseEntity.ok(ApiResponse.success("User updated successfully", user));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @DeleteMapping("/users/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteUser(@PathVariable Long id) {
        try {
            userService.deleteUser(id);
            return ResponseEntity.ok(ApiResponse.success("User deleted successfully", null));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    // Category Management
    @PostMapping("/categories")
    public ResponseEntity<ApiResponse<CategoryDTO>> createCategory(@RequestBody CategoryDTO request) {
        try {
            CategoryDTO category = categoryService.createCategory(request);
            return ResponseEntity.ok(ApiResponse.success("Category created successfully", category));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @PutMapping("/categories/{id}")
    public ResponseEntity<ApiResponse<CategoryDTO>> updateCategory(
            @PathVariable Long id,
            @RequestBody CategoryDTO request) {
        try {
            CategoryDTO category = categoryService.updateCategory(id, request);
            return ResponseEntity.ok(ApiResponse.success("Category updated successfully", category));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @DeleteMapping("/categories/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteCategory(@PathVariable Long id) {
        try {
            categoryService.deleteCategory(id);
            return ResponseEntity.ok(ApiResponse.success("Category deleted successfully", null));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    // Story Management
    @PostMapping("/stories")
    public ResponseEntity<ApiResponse<StoryDTO>> createStory(@RequestBody StoryRequest request) {
        try {
            StoryDTO story = storyService.createStory(request);
            return ResponseEntity.ok(ApiResponse.success("Story created successfully", story));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @PutMapping("/stories/{id}")
    public ResponseEntity<ApiResponse<StoryDTO>> updateStory(
            @PathVariable Long id,
            @RequestBody StoryRequest request) {
        try {
            StoryDTO story = storyService.updateStory(id, request);
            return ResponseEntity.ok(ApiResponse.success("Story updated successfully", story));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @DeleteMapping("/stories/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteStory(@PathVariable Long id) {
        try {
            storyService.deleteStory(id);
            return ResponseEntity.ok(ApiResponse.success("Story deleted successfully", null));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    // Episode Management
    @PostMapping("/stories/{storyId}/episodes")
    public ResponseEntity<ApiResponse<EpisodeDTO>> createEpisode(
            @PathVariable Long storyId,
            @RequestBody EpisodeRequest request) {
        try {
            EpisodeDTO episode = episodeService.createEpisode(storyId, request);
            return ResponseEntity.ok(ApiResponse.success("Episode created successfully", episode));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @PutMapping("/episodes/{id}")
    public ResponseEntity<ApiResponse<EpisodeDTO>> updateEpisode(
            @PathVariable Long id,
            @RequestBody EpisodeRequest request) {
        try {
            EpisodeDTO episode = episodeService.updateEpisode(id, request);
            return ResponseEntity.ok(ApiResponse.success("Episode updated successfully", episode));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @DeleteMapping("/episodes/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteEpisode(@PathVariable Long id) {
        try {
            episodeService.deleteEpisode(id);
            return ResponseEntity.ok(ApiResponse.success("Episode deleted successfully", null));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    // File Upload
    @PostMapping("/upload/image")
    public ResponseEntity<ApiResponse<String>> uploadImage(@RequestParam("file") MultipartFile file) {
        try {
            String imageUrl = fileStorageService.storeImage(file);
            return ResponseEntity.ok(ApiResponse.success("Image uploaded successfully", imageUrl));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @PostMapping("/upload/audio")
    public ResponseEntity<ApiResponse<String>> uploadAudio(@RequestParam("file") MultipartFile file) {
        try {
            String audioUrl = fileStorageService.storeAudio(file);
            return ResponseEntity.ok(ApiResponse.success("Audio uploaded successfully", audioUrl));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
}
