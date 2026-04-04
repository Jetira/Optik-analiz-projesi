# StatCard Widget Documentation

## Overview

The `StatCard` widget is a reusable component designed to display statistics in a visually appealing card format. It's optimized for use in grid layouts and follows the Material 3 design system.

## Features

- **Icon + Label + Value Layout**: Clean, hierarchical display of statistical information
- **Optional Trend Indicator**: Shows percentage changes with color-coded arrows
- **Customizable Icon Color**: Allows semantic color coding (success, warning, error, info)
- **Grid-Optimized**: Designed to work seamlessly in responsive grid layouts
- **Theme-Aware**: Automatically adapts to light/dark themes

## Usage

### Basic Usage

```dart
StatCard(
  icon: Icons.school,
  label: 'Total Students',
  value: '42',
)
```

### With Trend Indicator

```dart
StatCard(
  icon: Icons.quiz,
  label: 'Questions',
  value: '100',
  trendPercentage: 15.5, // Positive trend (green, upward arrow)
)

StatCard(
  icon: Icons.check_circle,
  label: 'Avg Score',
  value: '85%',
  trendPercentage: -5.2, // Negative trend (red, downward arrow)
)
```

### With Custom Icon Color

```dart
StatCard(
  icon: Icons.check_circle,
  label: 'Success Rate',
  value: '95%',
  iconColor: AppColors.success,
)
```

### In Grid Layout (Recommended)

```dart
GridView.count(
  crossAxisCount: 2,
  crossAxisSpacing: AppSpacing.md,
  mainAxisSpacing: AppSpacing.md,
  children: [
    StatCard(
      icon: Icons.school,
      label: 'Total Students',
      value: '42',
      trendPercentage: 15.5,
    ),
    StatCard(
      icon: Icons.quiz,
      label: 'Questions',
      value: '100',
      trendPercentage: -5.2,
    ),
    // ... more cards
  ],
)
```

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `icon` | `IconData` | Yes | The icon to display at the top of the card |
| `label` | `String` | Yes | The label text that describes the statistic |
| `value` | `String` | Yes | The main value to display (e.g., "85", "42%", "1,234") |
| `trendPercentage` | `double?` | No | Optional trend showing percentage change. Positive = upward trend (green), Negative = downward trend (red) |
| `iconColor` | `Color?` | No | Optional custom color for the icon. Defaults to theme's primary color |

## Design Specifications

- **Card Padding**: 16dp (AppSpacing.md)
- **Icon Size**: 24dp
- **Icon-Label Spacing**: 8dp (AppSpacing.sm)
- **Label-Value Spacing**: 8dp (AppSpacing.sm)
- **Value-Trend Spacing**: 4dp (AppSpacing.xs)
- **Label Style**: titleSmall from theme
- **Value Style**: displaySmall from theme (bold)
- **Trend Icon Size**: 16dp
- **Trend Text Style**: bodySmall from theme (medium weight)

## Semantic Colors

The widget uses semantic colors from `AppColors`:
- **Success** (Green): Positive trends, success metrics
- **Error** (Red): Negative trends, error metrics
- **Info** (Blue): Informational metrics
- **Warning** (Orange): Warning metrics

## Accessibility

- Minimum touch target size is maintained through card padding
- Text overflow is handled with ellipsis for long labels
- Color contrast meets WCAG AA requirements
- Works with both light and dark themes

## Requirements Mapping

This widget satisfies the following requirements from the UI Redesign spec:

- **Requirement 6.1**: Display statistics using cards with large numbers, labels, and icons
- **Requirement 6.5**: Organize statistics in a grid layout with equal-sized cards
- **Requirement 6.6**: Display trend indicators with arrows and percentage changes

## Testing

The widget includes comprehensive unit tests covering:
- Basic rendering (icon, label, value)
- Icon sizing and coloring
- Trend indicator display (positive/negative/zero)
- Theme integration
- Grid layout compatibility
- Text overflow handling
- Spacing and padding

Run tests with:
```bash
flutter test test/widget_test/stat_card_test.dart
```

## Example

See `lib/widgets/stat_card_example.dart` for a complete example demonstrating StatCard usage in a grid layout.
