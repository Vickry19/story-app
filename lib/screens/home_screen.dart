import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../widgets/story_loading.dart';
import '../providers/auth_provider.dart';
import '../providers/story_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();

      context.read<StoryProvider>().refresh(auth.token!);
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final provider = context.read<StoryProvider>();

    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !provider.loading &&
        provider.hasMore) {
      final auth = context.read<AuthProvider>();

      provider.fetchStories(auth.token!);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final storyProvider = context.watch<StoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Stories',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: auth.logout,
              icon: const Icon(Icons.logout_rounded),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        elevation: 0,
        onPressed: () async {
          final result = await context.push('/add');

          if (result == true) {
            context.read<StoryProvider>().refresh(auth.token!);
          }
        },
        icon: const Icon(Icons.add_a_photo_rounded),
        label: const Text('Add Story'),
      ),

      body: storyProvider.loading && storyProvider.stories.isEmpty
          ? const Center(child: const StoryLoading())
          : RefreshIndicator(
              onRefresh: () async {
                await storyProvider.refresh(auth.token!);
              },
              child: ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                itemCount: storyProvider.hasMore
                    ? storyProvider.stories.length + 1
                    : storyProvider.stories.length,
                itemBuilder: (context, index) {
                  if (index >= storyProvider.stories.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: StoryLoading(),
                        ),
                      ),
                    );
                  }

                  final story = storyProvider.stories[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: () {
                        context.push('/detail', extra: story);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Hero(
                              tag: story.id,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(28),
                                ),
                                child: Image.network(
                                  story.photoUrl,
                                  height: 240,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;

                                    return Container(
                                      height: 240,
                                      color: Colors.grey.shade300,
                                      child: const Center(
                                        child: SizedBox(
                                          width: 40,
                                          height: 40,
                                          child: StoryLoading(),
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 240,
                                      color: Colors.grey.shade200,
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.broken_image_rounded,
                                        size: 50,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    story.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  Text(
                                    story.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      height: 1.5,
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_rounded,
                                        size: 18,
                                        color: Colors.deepPurple.shade400,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'View Detail Story',
                                        style: TextStyle(
                                          color: Colors.deepPurple.shade400,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
