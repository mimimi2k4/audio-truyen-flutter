import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/story.dart';
import '../../models/category.dart';
import '../../services/api_service.dart';
import '../../utils/api_constants.dart';
import '../../utils/app_theme.dart';

class StoryManagementScreen extends StatefulWidget {
  const StoryManagementScreen({super.key});

  @override
  State<StoryManagementScreen> createState() => _StoryManagementScreenState();
}

class _StoryManagementScreenState extends State<StoryManagementScreen> {
  List<Story> _stories = [];
  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final storiesResponse = await ApiService.get(ApiConstants.stories, auth: false);
      if (storiesResponse['success'] == true) {
        _stories = (storiesResponse['data'] as List)
            .map((json) => Story.fromJson(json))
            .toList();
      }

      final categoriesResponse = await ApiService.get(ApiConstants.categories, auth: false);
      if (categoriesResponse['success'] == true) {
        _categories = (categoriesResponse['data'] as List)
            .map((json) => Category.fromJson(json))
            .toList();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  void _showStoryDialog({Story? story}) {
    final titleController = TextEditingController(text: story?.title ?? '');
    final authorController = TextEditingController(text: story?.author ?? '');
    final descController = TextEditingController(text: story?.description ?? '');
    int? selectedCategoryId = story?.categoryId;
    List<String> imageUrls = List<String>.from(story?.images ?? []);
    bool isUploading = false;
    final isEdit = story != null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Sửa truyện' : 'Thêm truyện'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Tên truyện',
                    prefixIcon: Icon(Icons.book),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: authorController,
                  decoration: const InputDecoration(
                    labelText: 'Tác giả',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Danh mục',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: _categories.map((cat) => DropdownMenuItem(
                    value: cat.id,
                    child: Text(cat.name),
                  )).toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedCategoryId = value);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả',
                    prefixIcon: Icon(Icons.description),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                // Image upload section
                const Text(
                  'Ảnh truyện',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...imageUrls.map((url) => Stack(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage('${ApiConstants.baseUrl}$url'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: -8,
                          right: -8,
                          child: IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
                            onPressed: () {
                              setDialogState(() => imageUrls.remove(url));
                            },
                          ),
                        ),
                      ],
                    )),
                    // Add image button
                    InkWell(
                      onTap: isUploading
                          ? null
                          : () async {
                              FilePickerResult? result = await FilePicker.platform.pickFiles(
                                type: FileType.image,
                                allowMultiple: true,
                              );

                              if (result != null && result.files.isNotEmpty) {
                                setDialogState(() => isUploading = true);

                                for (var file in result.files) {
                                  if (file.path != null) {
                                    try {
                                      final response = await ApiService.uploadFile(
                                        '/api/admin/upload/image',
                                        file.path!,
                                        'file',
                                      );
                                      if (response['success'] == true) {
                                        setDialogState(() {
                                          imageUrls.add(response['data']);
                                        });
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Lỗi upload: ${e.toString()}'),
                                          backgroundColor: AppTheme.errorColor,
                                        ),
                                      );
                                    }
                                  }
                                }
                                setDialogState(() => isUploading = false);
                              }
                            },
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: isUploading
                            ? const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : const Icon(Icons.add_photo_alternate, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: isUploading
                  ? null
                  : () async {
                      if (titleController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Vui lòng nhập tên truyện')),
                        );
                        return;
                      }

                      try {
                        final data = {
                          'title': titleController.text.trim(),
                          'author': authorController.text.trim(),
                          'description': descController.text.trim(),
                          'categoryId': selectedCategoryId,
                          'images': imageUrls,
                        };

                        if (isEdit) {
                          await ApiService.put(
                            '${ApiConstants.adminStories}/${story!.id}',
                            data,
                          );
                        } else {
                          await ApiService.post(ApiConstants.adminStories, data);
                        }

                        if (mounted) {
                          Navigator.pop(context);
                          _loadData();
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text(isEdit 
                                  ? 'Đã cập nhật truyện' 
                                  : 'Đã thêm truyện'),
                              backgroundColor: AppTheme.successColor,
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Lỗi: ${e.toString()}'),
                            backgroundColor: AppTheme.errorColor,
                          ),
                        );
                      }
                    },
              child: Text(isEdit ? 'Cập nhật' : 'Thêm'),
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _deleteStory(Story story) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa truyện "${story.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.delete('${ApiConstants.adminStories}/${story.id}');
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa truyện'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${e.toString()}'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  void _showEpisodeManagement(Story story) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EpisodeManagementScreen(story: story),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.library_books_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có truyện',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _stories.length,
                    itemBuilder: (context, index) {
                      return _buildStoryCard(_stories[index]);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showStoryDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStoryCard(Story story) {
    final imageUrl = story.coverImage.isNotEmpty 
        ? '${ApiConstants.baseUrl}${story.coverImage}'
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 60,
                height: 80,
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          child: const Icon(Icons.book, color: AppTheme.primaryColor),
                        ),
                      )
                    : Container(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        child: const Icon(Icons.book, color: AppTheme.primaryColor),
                      ),
              ),
            ),
            title: Text(
              story.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (story.author?.isNotEmpty == true)
                  Text('Tác giả: ${story.author}'),
                if (story.categoryName?.isNotEmpty == true)
                  Text('Danh mục: ${story.categoryName}'),
                Text('${story.episodeCount} tập'),
              ],
            ),
          ),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _showEpisodeManagement(story),
                  icon: const Icon(Icons.headphones, size: 18),
                  label: const Text('Quản lý tập'),
                ),
              ),
              Container(width: 1, height: 24, color: Colors.grey[300]),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _showStoryDialog(story: story),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Sửa'),
                ),
              ),
              Container(width: 1, height: 24, color: Colors.grey[300]),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _deleteStory(story),
                  icon: const Icon(Icons.delete, size: 18, color: AppTheme.errorColor),
                  label: const Text('Xóa', style: TextStyle(color: AppTheme.errorColor)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Episode Management Screen
class EpisodeManagementScreen extends StatefulWidget {
  final Story story;

  const EpisodeManagementScreen({super.key, required this.story});

  @override
  State<EpisodeManagementScreen> createState() => _EpisodeManagementScreenState();
}

class _EpisodeManagementScreenState extends State<EpisodeManagementScreen> {
  List<dynamic> _episodes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEpisodes();
  }

  Future<void> _loadEpisodes() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await ApiService.get(
        ApiConstants.storyEpisodes(widget.story.id),
        auth: false,
      );
      if (response['success'] == true) {
        _episodes = response['data'] as List;
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  void _showEpisodeDialog({Map<String, dynamic>? episode}) {
    final titleController = TextEditingController(text: episode?['title'] ?? '');
    final audioUrlController = TextEditingController(text: episode?['audioUrl'] ?? '');
    final durationController = TextEditingController(
      text: episode?['duration']?.toString() ?? '',
    );
    final episodeNumberController = TextEditingController(
      text: episode?['episodeNumber']?.toString() ?? '${_episodes.length + 1}',
    );
    final isEdit = episode != null;
    String? selectedFileName;
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Sửa tập' : 'Thêm tập'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Tiêu đề tập',
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 16),
                // Audio file picker row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: audioUrlController,
                        decoration: InputDecoration(
                          labelText: 'URL Audio',
                          prefixIcon: const Icon(Icons.audiotrack),
                          hintText: '/uploads/audio/file.mp3',
                          suffixIcon: selectedFileName != null
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: isUploading
                          ? null
                          : () async {
                              FilePickerResult? result = await FilePicker.platform.pickFiles(
                                type: FileType.audio,
                              );

                              if (result != null && result.files.single.path != null) {
                                setDialogState(() {
                                  isUploading = true;
                                  selectedFileName = result.files.single.name;
                                });

                                try {
                                  final response = await ApiService.uploadFile(
                                    '/api/admin/upload/audio',
                                    result.files.single.path!,
                                    'file',
                                  );

                                  if (response['success'] == true) {
                                    setDialogState(() {
                                      audioUrlController.text = response['data'];
                                      isUploading = false;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Upload thành công!'),
                                        backgroundColor: AppTheme.successColor,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  setDialogState(() => isUploading = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Lỗi upload: ${e.toString()}'),
                                      backgroundColor: AppTheme.errorColor,
                                    ),
                                  );
                                }
                              }
                            },
                      icon: isUploading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.upload_file, size: 18),
                      label: Text(isUploading ? 'Đang tải...' : 'Chọn file'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ],
                ),
                if (selectedFileName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'File: $selectedFileName',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                const SizedBox(height: 16),
                TextField(
                  controller: episodeNumberController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Số tập',
                    prefixIcon: Icon(Icons.format_list_numbered),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: durationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Thời lượng (giây)',
                    prefixIcon: Icon(Icons.timer),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: isUploading
                  ? null
                  : () async {
                      if (titleController.text.trim().isEmpty ||
                          audioUrlController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
                        );
                        return;
                      }

                      try {
                        final data = {
                          'title': titleController.text.trim(),
                          'audioUrl': audioUrlController.text.trim(),
                          'episodeNumber': int.tryParse(episodeNumberController.text) ?? 1,
                          'duration': int.tryParse(durationController.text),
                        };

                        if (isEdit) {
                          await ApiService.put(
                            '${ApiConstants.adminEpisodes}/${episode!['id']}',
                            data,
                          );
                        } else {
                          await ApiService.post(
                            ApiConstants.adminStoryEpisodes(widget.story.id),
                            data,
                          );
                        }

                        if (mounted) {
                          Navigator.pop(context);
                          _loadEpisodes();
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text(isEdit ? 'Đã cập nhật tập' : 'Đã thêm tập'),
                              backgroundColor: AppTheme.successColor,
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Lỗi: ${e.toString()}'),
                            backgroundColor: AppTheme.errorColor,
                          ),
                        );
                      }
                    },
              child: Text(isEdit ? 'Cập nhật' : 'Thêm'),
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _deleteEpisode(Map<String, dynamic> episode) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa tập "${episode['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.delete('${ApiConstants.adminEpisodes}/${episode['id']}');
        _loadEpisodes();
      } catch (e) {
        // Handle error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tập - ${widget.story.title}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _episodes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.headphones_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có tập nào',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadEpisodes,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _episodes.length,
                    itemBuilder: (context, index) {
                      final episode = _episodes[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${episode['episodeNumber']}',
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          title: Text(episode['title']),
                          subtitle: Text(episode['audioUrl'] ?? ''),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                                onPressed: () => _showEpisodeDialog(episode: episode),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: AppTheme.errorColor),
                                onPressed: () => _deleteEpisode(episode),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEpisodeDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
