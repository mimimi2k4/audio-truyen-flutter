package com.audiostory.service;

import com.audiostory.dto.EpisodeDTO;
import com.audiostory.dto.EpisodeRequest;
import com.audiostory.model.Episode;
import com.audiostory.model.Story;
import com.audiostory.repository.EpisodeRepository;
import com.audiostory.repository.StoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class EpisodeService {
    
    private final EpisodeRepository episodeRepository;
    private final StoryRepository storyRepository;
    
    public List<EpisodeDTO> getEpisodesByStory(Long storyId) {
        return episodeRepository.findByStoryIdOrderByEpisodeNumber(storyId).stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }
    
    public EpisodeDTO getEpisodeById(Long id) {
        Episode episode = episodeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Episode not found"));
        return mapToDTO(episode);
    }
    
    public EpisodeDTO createEpisode(Long storyId, EpisodeRequest request) {
        Story story = storyRepository.findById(storyId)
                .orElseThrow(() -> new RuntimeException("Story not found"));
        
        Episode episode = Episode.builder()
                .story(story)
                .title(request.getTitle())
                .audioUrl(request.getAudioUrl())
                .duration(request.getDuration())
                .episodeNumber(request.getEpisodeNumber())
                .build();
        
        episodeRepository.save(episode);
        return mapToDTO(episode);
    }
    
    public EpisodeDTO updateEpisode(Long id, EpisodeRequest request) {
        Episode episode = episodeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Episode not found"));
        
        episode.setTitle(request.getTitle());
        episode.setAudioUrl(request.getAudioUrl());
        episode.setDuration(request.getDuration());
        episode.setEpisodeNumber(request.getEpisodeNumber());
        
        episodeRepository.save(episode);
        return mapToDTO(episode);
    }
    
    public void deleteEpisode(Long id) {
        if (!episodeRepository.existsById(id)) {
            throw new RuntimeException("Episode not found");
        }
        episodeRepository.deleteById(id);
    }
    
    private EpisodeDTO mapToDTO(Episode episode) {
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
