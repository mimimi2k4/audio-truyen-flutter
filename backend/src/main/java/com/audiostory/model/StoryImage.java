package com.audiostory.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "story_images")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StoryImage {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "story_id", nullable = false)
    private Story story;
    
    @Column(name = "image_url", nullable = false)
    private String imageUrl;
    
    @Column(name = "sort_order")
    private Integer sortOrder = 0;
}
