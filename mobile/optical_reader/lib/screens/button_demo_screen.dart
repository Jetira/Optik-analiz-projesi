import 'package:flutter/material.dart';

/// Demo screen to showcase all button styles and states
/// This demonstrates Requirements 8.1-8.6:
/// - ElevatedButton (primary actions)
/// - OutlinedButton (secondary actions)
/// - TextButton (tertiary actions)
/// - FloatingActionButton
/// - Disabled states
/// - Minimum touch target (48x48dp)
class ButtonDemoScreen extends StatelessWidget {
  const ButtonDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Button Styles Demo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            title: 'Primary Actions (ElevatedButton)',
            description: 'Filled background, used for primary actions',
            children: [
              ElevatedButton(
                onPressed: () {},
                child: const Text('Enabled'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: null,
                child: const Text('Disabled'),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('With Icon'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'Secondary Actions (OutlinedButton)',
            description: 'Outlined style, used for secondary actions',
            children: [
              OutlinedButton(
                onPressed: () {},
                child: const Text('Enabled'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: null,
                child: const Text('Disabled'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit),
                label: const Text('With Icon'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'Tertiary Actions (TextButton)',
            description: 'Text-only style, used for tertiary actions',
            children: [
              TextButton(
                onPressed: () {},
                child: const Text('Enabled'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: null,
                child: const Text('Disabled'),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.info),
                label: const Text('With Icon'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'Touch Target Size',
            description: 'All buttons have minimum 48x48dp touch target',
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 1),
                    ),
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('48x48'),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 1),
                    ),
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('48x48'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Red borders show the minimum touch target area',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'Button Hierarchy Example',
            description: 'Visual hierarchy in action',
            children: [
              ElevatedButton(
                onPressed: () {},
                child: const Text('Primary Action'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {},
                child: const Text('Secondary Action'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {},
                child: const Text('Tertiary Action'),
              ),
            ],
          ),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('FAB Extended'),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String description,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}
