import 'package:flutter/material.dart';
import '../api.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/service_icons.dart';

class ServiceTile extends StatelessWidget {
  const ServiceTile({super.key, required this.service, required this.onTap});
  final Map<String, dynamic> service;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final provider = obj(obj(service['provider'])['provider_profile']);
    final category = obj(service['category']);
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                height: 90,
                width: 87,
                decoration: BoxDecoration(
                  color: const Color(0xFFE4F4EA),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  iconFor('${category['icon']}'),
                  color: green,
                  size: 38,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${category['name'] ?? 'Service'}',
                      style: const TextStyle(
                        color: green,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${service['title']}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${provider['display_name'] ?? 'Provider'} · ${service['city']}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Text(
                          'From ${pesos(service['starting_price'])}',
                          style: const TextStyle(
                            color: green,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.chevron_right, color: green),
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
  }
}
