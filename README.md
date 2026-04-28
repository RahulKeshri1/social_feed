# Social Feed Application

## Overview
This repository contains the source code for a high-performance, fully functional social media feed application built using **Flutter** and **Supabase**. The application was developed as a technical assignment to demonstrate proficiency in modern mobile application development, focusing on high-quality UI/UX, robust state management, and edge-case handling such as offline capabilities.

The primary objective was to build a mobile application that matches production standards, ensuring a seamless, reliable, and fluid user experience under varying network conditions.

## Features
- **Infinite Scrolling Feed:** Implements pagination to fetch posts from Supabase in efficient batches, optimizing network and memory utilization.
- **Offline-First Engagement:** Provides robust offline support. Users can interact with posts (e.g., "like" a post) without an active internet connection. Offline actions are persisted to local storage (`SharedPreferences`) and automatically synchronized with the backend once connectivity is restored. This queue persists even across application restarts.
- **Dynamic Theme Switching:** Full support for Light, Dark, and System default themes. Theme changes are applied instantaneously across the entire application.
- **Smooth Animations:** Utilizes Hero animations for fluid transitions between the feed and detailed post views, complementing a progressive loading strategy for high-resolution assets.
- **Optimistic UI & Rate Limiting:** Implements immediate UI updates for user interactions to enhance perceived responsiveness. A custom debouncer prevents excessive API calls and mitigates rapid, repeated interactions before synchronizing with the database.

## Technical Architecture & Stack
- **Framework:** Flutter / Dart, structured using a feature-sliced architecture (separating core utilities, feed, profile, and detail features).
- **State Management:** Riverpod 3.x, utilizing `NotifierProvider` for robust, reactive state management across the feed, offline synchronization queue, and application theming.
- **Backend as a Service:** Supabase. *(Note: The backend schema and initial data setup—specifically the SQL queries for the database and a Python script for populating the storage images—were provided as part of the assignment requirements. This application connects to that established backend configuration.)*
- **Routing:** GoRouter for a declarative and type-safe navigation implementation.
- **Connectivity:** `connectivity_plus` actively monitors network status to trigger background synchronization when the device regains connectivity.

## Performance Optimizations
Significant attention was given to application performance and resource management:
- **Memory Management:** Leveraged `memCacheWidth` with `cached_network_image` to restrict image decoding to screen-appropriate dimensions. This prevents memory bloat from unnecessarily loading large image assets into memory.
- **Rendering Efficiency:** Applied `RepaintBoundary` to complex UI elements (such as cards utilizing heavy box shadows) to minimize the rendering area during scroll events, significantly improving scroll smoothness and battery efficiency.

## Local Setup Instructions

1. Clone the repository to your local machine.
2. In the root directory, create an `assets/` folder and add a `.env` file to it.
3. Configure your Supabase environment variables within the `.env` file:
   ```env
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_KEY=your-anon-key
   ```
4. Fetch the dependencies and launch the application:
   ```bash
   flutter pub get
   flutter run
   ```

## Conclusion
This submission highlights a strong focus on edge-case handling and resilient application design. Ensuring immediate UI updates across multiple screens, reliable tracking of offline actions across application lifecycles, and a responsive UI demonstrates a comprehensive approach to modern mobile development.

To review the offline synchronization implementation specifically, please refer to the `feed_controller.dart` file. 
