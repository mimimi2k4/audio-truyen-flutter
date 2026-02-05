package com.audiostory.repository;

import com.audiostory.model.StoryImage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface StoryImageRepository extends JpaRepository<StoryImage, Long> {
    List<StoryImage> findByStoryIdOrderBySortOrder(Long storyId);
    void deleteByStoryId(Long storyId);
}
