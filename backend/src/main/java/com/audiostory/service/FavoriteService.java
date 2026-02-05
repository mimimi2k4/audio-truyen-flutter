package com.audiostory.service;

import com.audiostory.dto.StoryDTO;
import com.audiostory.model.Favorite;
import com.audiostory.model.Story;
import com.audiostory.model.StoryImage;
import com.audiostory.model.User;
import com.audiostory.repository.FavoriteRepository;
import com.audiostory.repository.StoryRepository;
import com.audiostory.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FavoriteService {
    
    private final FavoriteRepository favoriteRepository;
    private final UserRepository userRepository;
    private final StoryRepository storyRepository;
    
    public List<StoryDTO> getFavoriteStories(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        return favoriteRepository.findStoriesByUserId(user.getId()).stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }
    
    public boolean isFavorite(String email, Long storyId) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        return favoriteRepository.existsByUserIdAndStoryId(user.getId(), storyId);
    }
    
    @Transactional
    public void addFavorite(String email, Long storyId) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        Story story = storyRepository.findById(storyId)
                .orElseThrow(() -> new RuntimeException("Story not found"));
        
        if (favoriteRepository.existsByUserIdAndStoryId(user.getId(), storyId)) {
            throw new RuntimeException("Story already in favorites");
        }
        
        Favorite favorite = Favorite.builder()
                .user(user)
                .story(story)
                .build();
        
        favoriteRepository.save(favorite);
    }
    
    @Transactional
    public void removeFavorite(String email, Long storyId) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        favoriteRepository.deleteByUserIdAndStoryId(user.getId(), storyId);
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
}
