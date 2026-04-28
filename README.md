# 🚀 Social Feed — High-Performance Flutter App

A highly optimized, infinite-scrolling social feed built with **Flutter**, **Riverpod**, and **Supabase**. This app demonstrates GPU protection, RAM efficiency, optimistic state management, and edge-case resilience.

---

## 📸 Features

- **Infinite Scrolling Feed** — Paginated REST fetch (10 items/page) with pull-to-refresh
- **GPU Protection** — `RepaintBoundary` wraps every post card to cache heavy `BoxShadow` rasterization
- **RAM Protection** — `memCacheWidth` constrains decoded image bitmaps to display size
- **Hero Animation + Tiered Loading** — Smooth transition from feed to detail with progressive image upgrade (thumb → 1080p → full res)
- **Optimistic UI** — Instant like/unlike with debounced server sync
- **Spam Click Safe** — Per-post debouncer coalesces 15 rapid taps into 1 RPC call
- **Offline Revert** — Failed likes automatically revert UI with a snackbar notification

---

## 🏗️ Architecture

### Feature-Sliced Design

```
lib/
├── main.dart                          # Entry: ProviderScope + Supabase init
├── app/
│   ├── app.dart                       # MaterialApp.router
│   ├── router.dart                    # GoRouter (feed, detail)
│   └── theme/
│       ├── app_theme.dart             # Dark + Light ThemeData
│       └── app_colors.dart            # Color palette
├── core/
│   ├── constants/                     # App & Supabase constants
│   ├── network/                       # Supabase client accessor
│   ├── utils/                         # Debouncer, ImageUtils
│   └── extensions/                    # Context extensions (snackbars)
└── features/
    ├── feed/
    │   ├── data/
    │   │   ├── models/post_model.dart
    │   │   └── repositories/feed_repository.dart
    │   ├── presentation/
    │   │   ├── screens/feed_screen.dart
    │   │   ├── widgets/ (post_card, like_button, feed_list, shimmer)
    │   │   └── controllers/feed_controller.dart
    │   └── providers/feed_providers.dart
    └── detail/
        └── presentation/
            ├── screens/detail_screen.dart
            └── widgets/ (tiered_image, download_button)
```

### Riverpod State Management

Uses **Riverpod 3.x `Notifier`** pattern (not legacy `StateNotifier`):

- `FeedController extends Notifier<FeedState>` — manages all feed state
- `FeedState` — immutable state class with `posts`, `isLoading`, `isLoadingMore`, `hasMore`, `currentOffset`, `error`
- Providers are co-located with the controller for discoverability

**Data Flow:**
```
User scrolls → FeedController.fetchNextPage()
  → FeedRepository.fetchPosts() [REST]
  → FeedRepository.fetchUserLikes() [batch check]
  → State updated with enriched posts

User taps like → FeedController.toggleLike()
  → Instant UI update (optimistic)
  → Per-post debouncer (500ms)
  → Supabase RPC toggle_like (only if state differs from server)
  → On failure: revert UI + SnackBar
```

---

## 🛡️ Performance Verification

### RepaintBoundary (GPU Protection)

Every `PostCard` in the feed list is wrapped in `RepaintBoundary`:

```dart
// feed_list.dart
RepaintBoundary(
  child: PostCard(
    key: ValueKey(post.id),
    post: post,
  ),
)
```

**Verification:** Open Flutter DevTools → Widget Inspector → search for `RepaintBoundary` → confirm each post card has its own repaint layer. The heavy `BoxShadow` (blur: 24, spread: 4) is rasterized once and cached.

### memCacheWidth (RAM Protection)

All feed images use `memCacheWidth` to match the decoded bitmap to display size:

```dart
// post_card.dart
CachedNetworkImage(
  imageUrl: post.mediaThumbUrl,
  memCacheWidth: ImageUtils.getCacheWidth(context, displayWidth: screenWidth),
)
```

**Verification:** Open DevTools → Memory tab → scroll through 50+ posts → memory should remain flat without unbounded growth.

### Spam Clicker Protection

```
Tap 1 (t=0ms):    UI: liked=true   | Timer starts (500ms)
Tap 2 (t=100ms):  UI: liked=false  | Timer reset
...
Tap 15 (t=1400ms): UI: liked=true  | Timer reset
--- 500ms silence ---
t=1900ms: Timer fires → compare desired vs server → 1 RPC call
```

---

## 🚦 Running the App

### Prerequisites
- Flutter 3.x+
- A Supabase project with the tables and RPC set up (see assignment)

### Setup

1. Clone the repo
2. Create `assets/.env` with your Supabase credentials:
   ```
   SUPABASE_URL = https://your-project.supabase.co
   SUPABASE_KEY = your-anon-or-service-key
   ```
3. Run:
   ```bash
   cd social_feed
   flutter pub get
   flutter run
   ```

---

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | State management (Notifier pattern) |
| `supabase_flutter` | Backend (Auth, DB, Storage, RPC) |
| `cached_network_image` | Disk-cached network images |
| `flutter_dotenv` | Environment variable loading |
| `go_router` | Declarative routing |
| `shimmer` | Loading skeletons |
| `connectivity_plus` | Network status detection |
| `path_provider` | File system access for downloads |
| `http` | Streaming download for full-res images |

---

## 📝 License

This project was built as a Flutter engineering assignment submission.
