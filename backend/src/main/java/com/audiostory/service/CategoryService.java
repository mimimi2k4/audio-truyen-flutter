package com.audiostory.service;

import com.audiostory.dto.CategoryDTO;
import com.audiostory.model.Category;
import com.audiostory.repository.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CategoryService {
    
    private final CategoryRepository categoryRepository;
    
    public List<CategoryDTO> getAllCategories() {
        return categoryRepository.findAll().stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }
    
    public CategoryDTO getCategoryById(Long id) {
        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Category not found"));
        return mapToDTO(category);
    }
    
    public CategoryDTO createCategory(CategoryDTO request) {
        Category category = Category.builder()
                .name(request.getName())
                .description(request.getDescription())
                .build();
        
        categoryRepository.save(category);
        return mapToDTO(category);
    }
    
    public CategoryDTO updateCategory(Long id, CategoryDTO request) {
        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Category not found"));
        
        category.setName(request.getName());
        category.setDescription(request.getDescription());
        
        categoryRepository.save(category);
        return mapToDTO(category);
    }
    
    public void deleteCategory(Long id) {
        if (!categoryRepository.existsById(id)) {
            throw new RuntimeException("Category not found");
        }
        categoryRepository.deleteById(id);
    }
    
    private CategoryDTO mapToDTO(Category category) {
        return CategoryDTO.builder()
                .id(category.getId())
                .name(category.getName())
                .description(category.getDescription())
                .build();
    }
}
