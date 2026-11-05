import 'package:flutter/material.dart';
import '../../api.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/service_tile.dart';
import '../../widgets/error_notice.dart';
import '../services/service_detail_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key, required this.session});
  final AppSession session;
  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final query = TextEditingController();
  List<Map<String, dynamic>> services = [], categories = [];
  int? categoryId;
  bool busy = true;
  String? error;
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    query.dispose();
    super.dispose();
  }

  Future<void> load() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final params = <String, String>{};
      if (query.text.trim().isNotEmpty) params['q'] = query.text.trim();
      if (categoryId != null) params['category_id'] = '$categoryId';
      final uri = Uri(
        path: '/services',
        queryParameters: params.isEmpty ? null : params,
      );
      final results = await Future.wait([
        widget.session.api.request(uri.toString()),
        widget.session.api.request('/categories'),
      ]);
      if (!mounted) return;
      setState(() {
        services = listOf(obj(results[0])['data']);
        categories = listOf(results[1]);
      });
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: load,
    child: ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
      children: [
        Row(
          children: [
            const Icon(Icons.handyman_rounded, color: green, size: 30),
            const SizedBox(width: 9),
            const Text(
              'serbisyo',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 24,
                color: dark,
              ),
            ),
            const Text(
              'hub',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 24,
                color: green,
              ),
            ),
            const Spacer(),
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.notifications_none,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 23),
        Container(
          padding: const EdgeInsets.all(23),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFF167D52), Color(0xFF2EAD75)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Trusted local services',
                style: TextStyle(
                  color: Color(0xFFDEFFE9),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 9),
              const Text(
                'Find the right help,\nright around you.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: query,
                onSubmitted: (_) => load(),
                decoration: InputDecoration(
                  hintText: 'What service do you need?',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    onPressed: load,
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        const Text(
          'Browse categories',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: dark,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 45,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              filterChip('All', null),
              ...categories.map(
                (c) => filterChip('${c['name']}', c['id'] as int),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Available services',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: dark,
                ),
              ),
            ),
            IconButton(onPressed: load, icon: const Icon(Icons.refresh)),
          ],
        ),
        if (busy)
          const Padding(
            padding: EdgeInsets.all(28),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (error != null) ErrorNotice(error!),
        if (!busy && services.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 26),
            child: Center(
              child: Text('No matching services yet. Try another category.'),
            ),
          ),
        ...services.map(
          (service) => ServiceTile(
            service: service,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ServiceDetailPage(
                  session: widget.session,
                  service: service,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
  Widget filterChip(String label, int? id) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(label),
      selected: categoryId == id,
      onSelected: (_) {
        setState(() => categoryId = id);
        load();
      },
    ),
  );
}
