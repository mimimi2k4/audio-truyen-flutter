package com.audiostory.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StoryDTO {
    private Long id;
    private String title;
    private String description;
    private String author;
    private Long categoryId;
    private String categoryName;
    private List<String> images;
    private List<EpisodeDTO> episodes;
    private int episodeCount;
}
