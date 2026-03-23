package com.audiostory.controller;

import com.audiostory.dto.ApiResponse;
import com.audiostory.dto.StoryDTO;
import com.audiostory.service.FavoriteService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/favorites")
@RequiredArgsConstructor
public class FavoriteController {
    
    private final FavoriteService favoriteService;
    
    @GetMapping
    public ResponseEntity<ApiResponse<List<StoryDTO>>> getFavorites(
            @AuthenticationPrincipal UserDetails userDetails) {
        List<StoryDTO> favorites = favoriteService.getFavoriteStories(userDetails.getUsername());
        return ResponseEntity.ok(ApiResponse.success(favorites));
    }
    
    @GetMapping("/{storyId}/check")
    public ResponseEntity<ApiResponse<Boolean>> checkFavorite(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable(name = "storyId") Long storyId) {
        boolean isFavorite = favoriteService.isFavorite(userDetails.getUsername(), storyId);
        return ResponseEntity.ok(ApiResponse.success(isFavorite));
    }
    
    @PostMapping("/{storyId}")
    public ResponseEntity<ApiResponse<Void>> addFavorite(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable(name = "storyId") Long storyId) {
        try {
            favoriteService.addFavorite(userDetails.getUsername(), storyId);
            return ResponseEntity.ok(ApiResponse.success("Added to favorites", null));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @DeleteMapping("/{storyId}")
    public ResponseEntity<ApiResponse<Void>> removeFavorite(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable(name = "storyId") Long storyId) {
        try {
            favoriteService.removeFavorite(userDetails.getUsername(), storyId);
            return ResponseEntity.ok(ApiResponse.success("Removed from favorites", null));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
}
