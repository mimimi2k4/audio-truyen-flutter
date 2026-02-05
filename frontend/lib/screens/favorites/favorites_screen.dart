import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/story.dart';
import '../../services/favorite_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/api_constants.dart';
import '../story/story_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoriteService>().fetchFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Truyện yêu thích'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<FavoriteService>().fetchFavorites();
            },
          ),
        ],
      ),
      body: Consumer<FavoriteService>(
        builder: (context, favoriteService, _) {
          if (favoriteService.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (favoriteService.favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_outline,
                      size: 64,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Chưa có truyện yêu thích',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Thêm truyện vào danh sách yêu thích\nđể dễ dàng tìm lại',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => favoriteService.fetchFavorites(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteService.favorites.length,
              itemBuilder: (context, index) {
                final story = favoriteService.favorites[index];
                return _buildFavoriteItem(story, favoriteService);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoriteItem(Story story, FavoriteService favoriteService) {
    final imageUrl = story.coverImage.isNotEmpty 
        ? '${ApiConstants.baseUrl}${story.coverImage}'
        : null;

    return Dismissible(
      key: Key('favorite_${story.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.errorColor,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 28,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Xác nhận'),
            content: Text('Bạn có muốn xóa "${story.title}" khỏi danh sách yêu thích?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Xóa',
                  style: TextStyle(color: AppTheme.errorColor),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        favoriteService.removeFavorite(story.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa "${story.title}" khỏi yêu thích'),
            action: SnackBarAction(
              label: 'Hoàn tác',
              onPressed: () {
                favoriteService.addFavorite(story.id);
              },
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StoryDetailScreen(storyId: story.id),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: SizedBox(
                  width: 100,
                  height: 120,
                  child: imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            child: const Icon(
                              Icons.book,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        )
                      : Container(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          child: const Icon(
                            Icons.book,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                ),
              ),
              
              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (story.author != null && story.author!.isNotEmpty)
                        Text(
                          story.author!,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.headphones,
                                  size: 14,
                                  color: AppTheme.primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${story.episodeCount} tập',
                                  style: const TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Favorite icon
              Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Icons.favorite,
                  color: AppTheme.secondaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
