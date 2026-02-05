package com.audiostory.repository;

import com.audiostory.model.Story;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface StoryRepository extends JpaRepository<Story, Long> {
    List<Story> findByCategoryId(Long categoryId);
    
    @Query("SELECT s FROM Story s WHERE LOWER(s.title) LIKE LOWER(CONCAT('%', :keyword, '%')) OR LOWER(s.author) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    List<Story> searchByKeyword(@Param("keyword") String keyword);
    
    @Query("SELECT s FROM Story s LEFT JOIN FETCH s.images LEFT JOIN FETCH s.episodes WHERE s.id = :id")
    Story findByIdWithDetails(@Param("id") Long id);
}
