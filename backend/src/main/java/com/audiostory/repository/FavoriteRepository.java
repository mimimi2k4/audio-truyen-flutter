package com.audiostory.repository;

import com.audiostory.model.Favorite;
import com.audiostory.model.Story;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface FavoriteRepository extends JpaRepository<Favorite, Long> {
    @Query("SELECT f.story FROM Favorite f WHERE f.user.id = :userId")
    List<Story> findStoriesByUserId(@Param("userId") Long userId);
    
    Optional<Favorite> findByUserIdAndStoryId(Long userId, Long storyId);
    
    boolean existsByUserIdAndStoryId(Long userId, Long storyId);
    
    void deleteByUserIdAndStoryId(Long userId, Long storyId);
}
