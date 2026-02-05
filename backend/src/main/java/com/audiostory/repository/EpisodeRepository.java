package com.audiostory.repository;

import com.audiostory.model.Episode;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface EpisodeRepository extends JpaRepository<Episode, Long> {
    List<Episode> findByStoryIdOrderByEpisodeNumber(Long storyId);
    void deleteByStoryId(Long storyId);
}
