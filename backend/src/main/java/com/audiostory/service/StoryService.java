package com.audiostory.service;

import com.audiostory.dto.EpisodeDTO;
import com.audiostory.dto.StoryDTO;
import com.audiostory.dto.StoryRequest;
import com.audiostory.model.Category;
import com.audiostory.model.Episode;
import com.audiostory.model.Story;
import com.audiostory.model.StoryImage;
import com.audiostory.repository.CategoryRepository;
import com.audiostory.repository.StoryImageRepository;
import com.audiostory.repository.StoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class StoryService {
    
    private final StoryRepository storyRepository;
    private final CategoryRepository categoryRepository;
    private final StoryImageRepository storyImageRepository;
    
    @Transactional(readOnly = true)
    public List<StoryDTO> getAllStories() {
        return storyRepository.findAll().stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }
    
    @Transactional(readOnly = true)
    public List<StoryDTO> getStoriesByCategory(Long categoryId) {
        return storyRepository.findByCategoryId(categoryId).stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }
    
    @Transactional(readOnly = true)
    public List<StoryDTO> searchStories(String keyword) {
        return storyRepository.searchByKeyword(keyword).stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }
    
    @Transactional(readOnly = true)
    public StoryDTO getStoryById(Long id) {
        Story story = storyRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Story not found"));
        return mapToDetailDTO(story);
    }
    
    @Transactional
    public StoryDTO createStory(StoryRequest request) {
        Category category = null;
        if (request.getCategoryId() != null) {
            category = categoryRepository.findById(request.getCategoryId())
                    .orElseThrow(() -> new RuntimeException("Category not found"));
        }
        
        Story story = Story.builder()
                .title(request.getTitle())
                .description(request.getDescription())
                .author(request.getAuthor())
                .category(category)
                .build();
        
        storyRepository.save(story);
        
        // Add images
        if (request.getImages() != null && !request.getImages().isEmpty()) {
            for (int i = 0; i < request.getImages().size(); i++) {
                StoryImage image = StoryImage.builder()
                        .story(story)
                        .imageUrl(request.getImages().get(i))
                        .sortOrder(i)
                        .build();
                storyImageRepository.save(image);
            }
        }
        
        return mapToDTO(story);
    }
    
    @Transactional
    public StoryDTO updateStory(Long id, StoryRequest request) {
        Story story = storyRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Story not found"));
        
        Category category = null;
        if (request.getCategoryId() != null) {
            category = categoryRepository.findById(request.getCategoryId())
                    .orElseThrow(() -> new RuntimeException("Category not found"));
        }
        
        story.setTitle(request.getTitle());
        story.setDescription(request.getDescription());
        story.setAuthor(request.getAuthor());
        story.setCategory(category);
        
        // Update images
        if (request.getImages() != null) {
            storyImageRepository.deleteByStoryId(id);
            for (int i = 0; i < request.getImages().size(); i++) {
                StoryImage image = StoryImage.builder()
                        .story(story)
                        .imageUrl(request.getImages().get(i))
                        .sortOrder(i)
                        .build();
                storyImageRepository.save(image);
            }
        }
        
        storyRepository.save(story);
        return mapToDTO(story);
    }
    
    @Transactional
    public void deleteStory(Long id) {
        if (!storyRepository.existsById(id)) {
            throw new RuntimeException("Story not found");
        }
        storyRepository.deleteById(id);
    }
    
    private StoryDTO mapToDTO(Story story) {
        List<String> imageUrls = story.getImages() != null 
                ? story.getImages().stream().map(StoryImage::getImageUrl).collect(Collectors.toList())
                : new ArrayList<>();
        
        return StoryDTO.builder()
                .id(story.getId())
                .title(story.getTitle())
                .description(story.getDescription())
                .author(story.getAuthor())
                .categoryId(story.getCategory() != null ? story.getCategory().getId() : null)
                .categoryName(story.getCategory() != null ? story.getCategory().getName() : null)
                .images(imageUrls)
                .episodeCount(story.getEpisodes() != null ? story.getEpisodes().size() : 0)
                .build();
    }
    
    private StoryDTO mapToDetailDTO(Story story) {
        StoryDTO dto = mapToDTO(story);
        
        List<EpisodeDTO> episodes = story.getEpisodes() != null
                ? story.getEpisodes().stream()
                    .map(this::mapEpisodeToDTO)
                    .collect(Collectors.toList())
                : new ArrayList<>();
        
        dto.setEpisodes(episodes);
        return dto;
    }
    
    private EpisodeDTO mapEpisodeToDTO(Episode episode) {
        return EpisodeDTO.builder()
                .id(episode.getId())
                .storyId(episode.getStory().getId())
                .title(episode.getTitle())
                .audioUrl(episode.getAudioUrl())
                .duration(episode.getDuration())
                .episodeNumber(episode.getEpisodeNumber())
                .build();
    }
}
