package com.audiostory.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EpisodeRequest {
    private String title;
    private String audioUrl;
    private Integer duration;
    private Integer episodeNumber;
}
