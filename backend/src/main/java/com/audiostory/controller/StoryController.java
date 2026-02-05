package com.audiostory.controller;

import com.audiostory.dto.ApiResponse;
import com.audiostory.dto.EpisodeDTO;
import com.audiostory.dto.StoryDTO;
import com.audiostory.service.EpisodeService;
import com.audiostory.service.StoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/stories")
@RequiredArgsConstructor
public class StoryController {
    
    private final StoryService storyService;
    private final EpisodeService episodeService;
    
    @GetMapping
    public ResponseEntity<ApiResponse<List<StoryDTO>>> getAllStories(
            @RequestParam(required = false) Long categoryId) {
        List<StoryDTO> stories;
        if (categoryId != null) {
            stories = storyService.getStoriesByCategory(categoryId);
        } else {
            stories = storyService.getAllStories();
        }
        return ResponseEntity.ok(ApiResponse.success(stories));
    }
    
    @GetMapping("/search")
    public ResponseEntity<ApiResponse<List<StoryDTO>>> searchStories(@RequestParam String keyword) {
        List<StoryDTO> stories = storyService.searchStories(keyword);
        return ResponseEntity.ok(ApiResponse.success(stories));
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<StoryDTO>> getStoryById(@PathVariable Long id) {
        try {
            StoryDTO story = storyService.getStoryById(id);
            return ResponseEntity.ok(ApiResponse.success(story));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @GetMapping("/{storyId}/episodes")
    public ResponseEntity<ApiResponse<List<EpisodeDTO>>> getEpisodesByStory(@PathVariable Long storyId) {
        List<EpisodeDTO> episodes = episodeService.getEpisodesByStory(storyId);
        return ResponseEntity.ok(ApiResponse.success(episodes));
    }
}
